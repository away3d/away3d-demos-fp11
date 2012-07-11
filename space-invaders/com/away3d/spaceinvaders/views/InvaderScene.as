package com.away3d.spaceinvaders.views
{

	import away3d.materials.methods.EnvMapAmbientMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.CubeTextureBase;

	import com.away3d.spaceinvaders.*;

	import com.away3d.spaceinvaders.gameobjects.invaders.*;

	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;

	import com.away3d.spaceinvaders.GameSettings;
	import com.away3d.spaceinvaders.events.GameObjectEvent;
	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;
	import com.away3d.spaceinvaders.gameobjects.player.Player;
	import com.away3d.spaceinvaders.gameobjects.projectiles.Projectile;
	import com.away3d.spaceinvaders.gameobjects.projectiles.ProjectilePool;
	import com.away3d.spaceinvaders.utils.MathUtils;

	import flash.display.BitmapData;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.setTimeout;

	use namespace arcane; // TODO: Ugly, used to get the camera's aspect ratio

	public class InvaderScene extends Sprite
	{
		[Embed(source="../../../../assets/skybox/space.jpg")]
		private var ImageNegX:Class;

		private var _view:View3D;
		private var _cameraLight:LightBase;
		private var _lightPicker:StaticLightPicker;
		private var _playerPosition:Point = new Point();

		private var _player:Player;
		private var _playerVector:Vector.<GameObject>;

		private var _ui:UIView;

		private var _invaderPool:InvaderPool;
		private var _projectilePool:ProjectilePool;
		private var _cellPool:InvaderCellPool;
		private var _gameObjectPools:Vector.<GameObjectPool>;
		private var _totalKills:uint;
		private var _currentLevelKills:uint;

		private var _cubeMap:BitmapCubeTexture;

		private var _currentLevel:uint;

		public function InvaderScene() {
			addEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
		}

		private function stageInitHandler( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
			initUI();
			initEngine();
			initScene();
		}

		private function initUI():void {
			_ui = new UIView();
			addChild( _ui );
		}

		private function initEngine():void {
			_view = new View3D();
//			_view.backgroundColor = 0xFFFFFF;
			_view.camera.lens.far = 100000;
			addChild( _view );
		}

		private function initScene():void {

			// Init Lights.
			_cameraLight = new PointLight();
			_lightPicker = new StaticLightPicker( [ _cameraLight ] );

			// Stats.
			var stats:AwayStats = new AwayStats( _view );
			addChild( stats );

			// Skybox.
			var bmd:BitmapData = new ImageNegX().bitmapData;
			_cubeMap = new BitmapCubeTexture(
					bmd, bmd, bmd, bmd, bmd, bmd
			);
			var skyBox:SkyBox = new SkyBox( _cubeMap );
			_view.scene.addChild( skyBox );

			// Init objects.
			_gameObjectPools = new Vector.<GameObjectPool>();
			createInvaders();
			createProjectiles();

			// Player.
			_player = new Player( _view.camera );
			_player.position = new Vector3D( 0, 0, -1000 );
			_player.enabled = true;
			_cameraLight.position = new Vector3D( 0, 0, -2000 );
			_playerVector = new Vector.<GameObject>();
			_playerVector.push( _player );

			// Back fire plane.
			// TODO: can use view?
			var backFirePlane:Mesh = new Mesh( new PlaneGeometry( 1000000, 1000000 ), new ColorMaterial( 0x000000, 0.01 ) );
			backFirePlane.mouseEnabled = true;
			backFirePlane.addEventListener( MouseEvent3D.MOUSE_DOWN, onBackFirePlaneMouseDown );
			backFirePlane.rotationX = -90;
			backFirePlane.z = 50000;
			_view.scene.addChild( backFirePlane );

			loadLevel();
		}

		private function onBackFirePlaneMouseDown( event:MouseEvent3D ):void {
			firePlayer();
		}

		private function createProjectiles():void {

			// Reusable mesh.
			var projectileMaterial:ColorMaterial = new ColorMaterial( 0xFF0000 );
			var projectileMesh:Mesh = new Mesh( new CubeGeometry( 25, 25, 200 ), projectileMaterial );

			// Crete pool.
			_projectilePool = new ProjectilePool( projectileMesh );
			_gameObjectPools.push( _projectilePool );
			_view.scene.addChild( _projectilePool );
		}

		private function createInvaders():void {

			// Same material for all invaders.
			var invaderMaterial:ColorMaterial = new ColorMaterial( 0x666666 );
			invaderMaterial.addMethod( new EnvMapMethod( _cubeMap, 0.5 ) );
			invaderMaterial.lightPicker = _lightPicker;

			// Create invaders.
			_invaderPool = new InvaderPool( invaderMaterial );
			_invaderPool.addEventListener( MouseEvent3D.MOUSE_DOWN, onInvaderMouseDown );
			_invaderPool.addEventListener( GameObjectEvent.DEAD, onInvaderDead );
			_invaderPool.addEventListener( GameObjectEvent.FIRE, onInvaderFire );
			_gameObjectPools.push( _invaderPool );
			_view.scene.addChild( _invaderPool );

			// Create cells ( used for invader death explosions ).
			var cellMesh:Mesh = new Mesh( new CubeGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeXY, GameSettings.invaderSizeZ ), invaderMaterial );
			_cellPool = new InvaderCellPool( cellMesh as Mesh );
			_gameObjectPools.push( _cellPool );
			_view.scene.addChild( _cellPool );
		}

		private function onInvaderFire( event:GameObjectEvent ):void {
			fireProjectile( event.objectA.position, new Vector3D( 0, 0, -100 ), _playerVector );
		}

		private function onInvaderMouseDown( event:MouseEvent3D ):void {
			var position:Vector3D = event.scenePosition;
			position.z = _player.z;
			fireProjectile( position, new Vector3D( 0, 0, 200 ), _invaderPool.gameObjects );
		}

		private function loadLevel():void {
			_invaderPool.targetNumInvaders = GameSettings.levelInvaderNum[ _currentLevel ];
			_invaderPool.creationProbability = GameSettings.levelInvaderProb[ _currentLevel ];
			_invaderPool.invaderFireRate = GameSettings.levelInvaderMaxFireRate[ _currentLevel ];
			_ui.updateCurrentLevelKills( _currentLevelKills, GameSettings.levelKillCount[ _currentLevel ] );
		}

		private function onInvaderDead( event:GameObjectEvent ):void {
			_currentLevelKills++;
			_totalKills++;
			_ui.updateCurrentLevelKills( _currentLevelKills, GameSettings.levelKillCount[ _currentLevel ] );
			_ui.updateTotalKills( _totalKills );
			if( _currentLevelKills > GameSettings.levelKillCount[ _currentLevel ] ) {
				_currentLevelKills = 0;
				_currentLevel++;
				loadLevel();
				_ui.updateLevel( _currentLevel );
			}
			createInvaderDeathAnimation( event.objectA as Invader, event.objectB as Projectile );
		}

		private function createInvaderDeathAnimation( invader:Invader, hitter:Projectile ):void {

			var intensity:Number = GameSettings.deathExplosionIntensity;
			var positions:Vector.<Point> = invader.cellPositions;
			var len:uint = positions.length;
			for( var i:uint; i < len; ++i ) {
				var cell:InvaderCell = _cellPool.addItem() as InvaderCell;
				// Set cell position according to dummy child position.
				var pos:Point = positions[ i ];
				cell.position = invader.position;
				cell.x += pos.x;
				cell.y += pos.y;
				// Determine explosion velocity of cell.
				var dx:Number = cell.x - hitter.x;
				var dy:Number = cell.y - hitter.y;
				var distanceSq:Number = dx * dx + dy * dy;
				var rotSpeed:Number = 0;// intensity * 500 / distanceSq; // TODO: produces ugly collapse
				cell.rotationalVelocity.x = MathUtils.rand( -rotSpeed, rotSpeed );
				cell.rotationalVelocity.y = MathUtils.rand( -rotSpeed, rotSpeed );
				cell.rotationalVelocity.z = MathUtils.rand( -rotSpeed, rotSpeed );
				cell.velocity.x = intensity * MathUtils.rand( 100, 500 ) * dx / distanceSq;
				cell.velocity.y = intensity * MathUtils.rand( 100, 500 ) * dy / distanceSq;
				cell.velocity.z = intensity * 50 * hitter.velocity.z / distanceSq + invader.velocity.z;
			}
		}

		public function movePlayerTowards( x:Number, y:Number ):void {
			// Ease camera towards target position.
			var dx:Number = x - _playerPosition.x;
			var dy:Number = y - _playerPosition.y;
			_player.x += dx * GameSettings.cameraMotionEase;
			_player.y += dy * GameSettings.cameraMotionEase;
			_playerPosition.x = _player.x;
			_playerPosition.y = _player.y;
		}

		public function update():void {

			// Update all game object pools.
			for( var i:uint; i < _gameObjectPools.length; ++i ) {
				var gameObjectPool:GameObjectPool = _gameObjectPools[ i ];
				gameObjectPool.update();
			}

			// Update player.
			_player.update();

			// Render scene.
			_view.render();
		}

		public function firePlayer():void {
			fireProjectile( _player.position, new Vector3D( 0, 0, 200 ), _invaderPool.gameObjects );
		}

		public function fireProjectile( position:Vector3D, velocity:Vector3D, targets:Vector.<GameObject> ):void {
	   		var projectile:Projectile = _projectilePool.addItem() as Projectile;
			projectile.targets = targets;
			projectile.position = position;
			projectile.velocity = velocity;
		}
	}
}
