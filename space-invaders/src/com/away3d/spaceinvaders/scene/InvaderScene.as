package com.away3d.spaceinvaders.scene
{

	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.Object3D;
	import away3d.debug.AwayStats;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;

	import com.away3d.spaceinvaders.GameVariables;
	import com.away3d.spaceinvaders.events.GameObjectEvent;
	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;
	import com.away3d.spaceinvaders.gameobjects.invaders.*;
	import com.away3d.spaceinvaders.gameobjects.player.Player;
	import com.away3d.spaceinvaders.gameobjects.projectiles.Projectile;
	import com.away3d.spaceinvaders.gameobjects.projectiles.ProjectilePool;
	import com.away3d.spaceinvaders.gameobjects.stars.StarPool;
	import com.away3d.spaceinvaders.sound.SoundManager;
	import com.away3d.spaceinvaders.sound.Sounds;
	import com.away3d.spaceinvaders.utils.MathUtils;
	import com.away3d.spaceinvaders.utils.ScoreManager;

	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	use namespace arcane; // TODO: Ugly, used to get the camera's aspect ratio

	public class InvaderScene extends Sprite
	{
		[Embed(source="../../../../assets/skybox/space_posX.jpg")]
		private var SkyboxImagePosX:Class;
		[Embed(source="../../../../assets/skybox/space_negX.jpg")]
		private var SkyboxImageNegX:Class;
		[Embed(source="../../../../assets/skybox/space_posY.jpg")]
		private var SkyboxImagePosY:Class;
		[Embed(source="../../../../assets/skybox/space_negY.jpg")]
		private var SkyboxImageNegY:Class;
		[Embed(source="../../../../assets/skybox/space_posZ.jpg")]
		private var SkyboxImagePosZ:Class;
		[Embed(source="../../../../assets/skybox/space_negZ.jpg")]
		private var SkyboxImageNegZ:Class;

		private var _view:View3D;
		private var _lightPicker:StaticLightPicker;
		private var _playerPosition:Point = new Point();

		private var _cubeMap:BitmapCubeTexture;

		private var _player:Player;
		private var _playerVector:Vector.<GameObject>;

		private var _invaderPool:InvaderPool;
		private var _starPool:StarPool;
		private var _playerProjectilePool:ProjectilePool;
		private var _invaderProjectilePool:ProjectilePool;
		private var _cellPool:InvaderCellPool;
		private var _gameObjectPools:Vector.<GameObjectPool>;
		private var _totalKills:uint;
		private var _currentLevelKills:uint;
		private var _skyBox:SkyBox;

		private var _fireReleased:Boolean = true;
		private var _fireReleaseTimer:Timer;

		private var _currentLevel:uint;

		private var _active:Boolean;

		public var cameraMotionEase:Number;

		public function InvaderScene() {
			addEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
		}

		private function stageInitHandler( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
			initEngine();
			initScene();
			update();
		}

		private function initEngine():void {
			_view = new View3D();
			_view.antiAlias = 4;
			_view.backgroundColor = 0x000000;
			_view.camera.lens.near = 50;
			_view.camera.lens.far = 100000;
			_view.width = GameVariables.windowWidth;
			_view.height = GameVariables.windowHeight;
			addChild( _view );
		}

		private function initScene():void {

			// Init Lights.
			var frontLight:DirectionalLight = new DirectionalLight();
			frontLight.direction = new Vector3D( 0.5, 0, 1 );
			frontLight.color = 0xFFFFFF;
			frontLight.ambient = 0.1;
			frontLight.ambientColor = 0xFF00FF;
			_view.scene.addChild( frontLight );
			_lightPicker = new StaticLightPicker( [ frontLight ] );

			// Stats.
			if( GameVariables.debugMode ) {
				var stats:AwayStats = new AwayStats( _view );
				addChild( stats );
				var tri:Trident = new Trident();
				_view.scene.addChild( tri );
			}

			// Skybox.
			_cubeMap = new BitmapCubeTexture(
				new SkyboxImagePosX().bitmapData, new SkyboxImageNegX().bitmapData,
				new SkyboxImagePosY().bitmapData, new SkyboxImageNegY().bitmapData,
				new SkyboxImagePosZ().bitmapData, new SkyboxImageNegZ().bitmapData
			);
			_skyBox = new SkyBox( _cubeMap );
			_view.scene.addChild( _skyBox );

			// Init objects.
			_gameObjectPools = new Vector.<GameObjectPool>();
			createInvaders();

			// Stars.
			var starMesh:Mesh = new Mesh( new CubeGeometry( 10, 10, 10 ), new ColorMaterial( 0xFFFFFF ) );
			_starPool = new StarPool( starMesh );
			_gameObjectPools.push( _starPool );
			_view.scene.addChild( _starPool );

			createPlayer();

			loadLevel();
		}

		public function update():void {

			// Update all game object pools.
			if( _active ) {
				for( var i:uint; i < _gameObjectPools.length; ++i ) {
					var gameObjectPool:GameObjectPool = _gameObjectPools[ i ];
					gameObjectPool.update();
				}
			}

			// Update player.
			if( _active ) {
				_player.update();
			}

			// Render scene.
			_view.render(); // Always render scene ( so 2D content updates properly on mobile with render mode = direct ).
		}

		// -----------------------
		// Game control.
		// -----------------------

		public function resume():void {
			_invaderPool.resume();
			_active = true;
		}

		public function stop():void {
			_invaderPool.stop();
			_active = false;
		}

		private function loadLevel():void {
			if( _currentLevel > 0 ) _invaderPool.spawnTimeFactor -= GameVariables.spawnTimeDecreasePerLevel;
			if( _invaderPool.spawnTimeFactor < GameVariables.minimumSpawnTime ) _invaderPool.spawnTimeFactor = GameVariables.minimumSpawnTime;
		}

		public function reset():void {
			// Reset all game object pools.
			for( var i:uint; i < _gameObjectPools.length; ++i ) {
				var gameObjectPool:GameObjectPool = _gameObjectPools[ i ];
				gameObjectPool.reset();
			}
			_currentLevel = 0;
			_currentLevelKills = 0;
			_totalKills = 0;
			_invaderPool.spawnTimeFactor = 1;
			loadLevel();
		}

		public function get active():Boolean {
			return _active;
		}

		// -----------------------
		// Player creation.
		// -----------------------

		private function createPlayer():void {

			// Reusable projectile mesh.
			var playerProjectileMaterial:ColorMaterial = new ColorMaterial( 0x00FFFF );
			playerProjectileMaterial.blendMode = BlendMode.ADD;
			var playerProjectileMesh:Mesh = new Mesh( new CubeGeometry( 25, 25, 200 ), playerProjectileMaterial );

			// Crete pool.
			_playerProjectilePool = new ProjectilePool( playerProjectileMesh );
			_gameObjectPools.push( _playerProjectilePool );
			_view.scene.addChild( _playerProjectilePool );

			// Player.
			_player = new Player( _view.camera );
			_player.position = new Vector3D( 0, 0, -1000 );
			_player.enabled = true;
			_player.addEventListener( GameObjectEvent.HIT, onPlayerHit );
			_player.targets = _invaderPool.gameObjects;
			_playerVector = new Vector.<GameObject>();
			_playerVector.push( _player );

			_fireReleaseTimer = new Timer( 50, 1 );
			_fireReleaseTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onFireReleaseTimerComplete );
		}

		private function onFireReleaseTimerComplete( event:TimerEvent ):void {
			_fireReleased = true;
		}

		// -----------------------
		// Invader creation.
		// -----------------------

		private function createInvaders():void {

			// Same material for all invaders.
			var invaderMaterial:ColorMaterial = new ColorMaterial( 0xFFFFFF, 1 );
			invaderMaterial.addMethod( new EnvMapMethod( _cubeMap, 0.5 ) );
			invaderMaterial.lightPicker = _lightPicker;

			// Reusable projectile mesh.
			var invaderProjectileGeometry:Geometry = new CubeGeometry( 25, 25, 200, 1, 1, 4 );
			var invaderProjectileMaterial:ColorMaterial = new ColorMaterial( 0xFF0000 );
			var invaderProjectileMesh:Mesh = new Mesh( invaderProjectileGeometry, invaderProjectileMaterial );
			// Slant vertices a little.
			var vertices:Vector.<Number> = invaderProjectileGeometry.subGeometries[ 0 ].vertexData;
			var index:uint;
			var pz:Number;
			for( var i:uint; i < vertices.length / 3; i++ ) {
				index = i * 3;
				pz = vertices[ index + 2 ];
				if( pz > -75 && pz < 75 ) {
					vertices[ index + 0 ] += pz > 0 ? 25 : pz == 0 ? 0 : -25;
				}
			}
			invaderProjectileGeometry.subGeometries[ 0 ].updateVertexData( vertices );

			// Crete pool.
			_invaderProjectilePool = new ProjectilePool( invaderProjectileMesh );
			_gameObjectPools.push( _invaderProjectilePool );
			_view.scene.addChild( _invaderProjectilePool );

			// Create invaders.
			_invaderPool = new InvaderPool( invaderMaterial );
			_invaderPool.addEventListener( GameObjectEvent.CREATED, onInvaderCreated );
			_invaderPool.addEventListener( GameObjectEvent.DEAD, onInvaderDead );
			_invaderPool.addEventListener( GameObjectEvent.FIRE, onInvaderFire );
			_gameObjectPools.push( _invaderPool );
			_view.scene.addChild( _invaderPool );

			// Create cells ( used for invader death explosions ).
			var cellMaterial:ColorMaterial = new ColorMaterial( 0x0000FF, 0.5 );
			cellMaterial.blendMode = BlendMode.ADD;
			var cellMesh:Mesh = new Mesh( new CubeGeometry( GameVariables.invaderSizeXY, GameVariables.invaderSizeXY, GameVariables.invaderSizeZ ), cellMaterial );
			_cellPool = new InvaderCellPool( cellMesh as Mesh );
			_gameObjectPools.push( _cellPool );
			_view.scene.addChild( _cellPool );
		}

		private function onInvaderCreated( event:GameObjectEvent ):void {
			var invader:Invader = event.objectA as Invader;
			if( invader.invaderType == InvaderDefinitions.MOTHERSHIP ) {
				SoundManager.playSound( Sounds.MOTHERSHIP );
			}
		}

		// -----------------------
		// Invader deaths.
		// -----------------------

		private function createInvaderDeathAnimation( invader:Invader, hitter:Projectile ):void {
			var intensity:Number = GameVariables.deathExplosionIntensity * MathUtils.rand( 1, 4 );
			var positions:Vector.<Point> = invader.cellPositions;
			var len:uint = positions.length;
			var sc:Number = invader.scaleX;
			for( var i:uint; i < len; ++i ) {
				var cell:InvaderCell = _cellPool.addItem() as InvaderCell;
				cell.scaleX = cell.scaleY = cell.scaleZ = sc;
				// Set cell position according to dummy child position.
				var pos:Point = positions[ i ];
				cell.position = invader.position;
				cell.x += sc * pos.x;
				cell.y += sc * pos.y;
				// Determine explosion velocity of cell.
				var dx:Number = cell.x - hitter.x;
				var dy:Number = cell.y - hitter.y;
				var distanceSq:Number = dx * dx + dy * dy;
				var rotSpeed:Number = intensity * 5000 / distanceSq;
				cell.rotationalVelocity.x = MathUtils.rand( -rotSpeed, rotSpeed );
				cell.rotationalVelocity.y = MathUtils.rand( -rotSpeed, rotSpeed );
				cell.rotationalVelocity.z = MathUtils.rand( -rotSpeed, rotSpeed );
				cell.velocity.x = intensity * MathUtils.rand( 100, 500 ) * dx / distanceSq;
				cell.velocity.y = intensity * MathUtils.rand( 100, 500 ) * dy / distanceSq;
				cell.velocity.z = intensity * 50 * hitter.velocity.z / distanceSq + invader.velocity.z;
			}
		}

		private function onInvaderDead( event:GameObjectEvent ):void {

			var invader:Invader = event.objectA as Invader;

			// Check level update and update UI.
			_currentLevelKills++;
			_totalKills++;
			ScoreManager.instance.registerKill( invader.invaderType );
			if( _currentLevelKills > GameVariables.killsToAdvanceDifficulty ) {
				_currentLevelKills = 0;
				_currentLevel++;
				loadLevel();
			}

			// Play sounds.
			if( invader.invaderType == InvaderDefinitions.MOTHERSHIP ) {
				SoundManager.playSound( Sounds.EXPLOSION_STRONG );
			}
			else {
				SoundManager.playSound( Sounds.INVADER_DEATH );
			}

			// Show invader destruction.
			createInvaderDeathAnimation( event.objectA as Invader, event.objectB as Projectile );
		}

		// -----------------------
		// Projectiles.
		// -----------------------

		private function onPlayerHit( event:GameObjectEvent ):void {
			SoundManager.playSound( Sounds.EXPLOSION_SOFT );
			ScoreManager.instance.registerPlayerHit();
		}

		private function onInvaderFire( event:GameObjectEvent ):void {
			SoundManager.playSound( Sounds.INVADER_FIRE, 0.5 );
			fireProjectile( event.objectA, new Vector3D( 0, 0, -100 ), _playerVector, _invaderProjectilePool );
		}

		public function firePlayer():void {
			if( !_fireReleased ) return;
			if( !_active ) return;
			SoundManager.playSound( Sounds.PLAYER_FIRE, 0.5 );
			var velocity:Vector3D = new Vector3D( 0, 0, 200 );
			velocity = _player.transform.deltaTransformVector( velocity );
			fireProjectile( _player, velocity, _invaderPool.gameObjects, _playerProjectilePool );
			_fireReleased = false;
			_fireReleaseTimer.reset();
			_fireReleaseTimer.start();
		}

		public function fireProjectile( source:Object3D, velocity:Vector3D, targets:Vector.<GameObject>, pool:GameObjectPool ):void {
			var projectile:Projectile = pool.addItem() as Projectile;
			projectile.targets = targets;
			projectile.transform = source.transform.clone();
			projectile.velocity = velocity;
		}

		// -----------------------
		// Player motion.
		// -----------------------

		public function movePlayerTowards( x:Number, y:Number ):void {
			var dx:Number = x - _playerPosition.x;
			var dy:Number = y - _playerPosition.y;
			_player.x += dx * cameraMotionEase;
			_player.y += dy * cameraMotionEase;
			_player.rotationY = -GameVariables.panTiltFactor * _player.x;
			_player.rotationX =  GameVariables.panTiltFactor * _player.y;
			_playerPosition.x = _player.x;
			_playerPosition.y = _player.y;
		}

		public function get playerPosition():Point {
			return _playerPosition;
		}
	}
}
