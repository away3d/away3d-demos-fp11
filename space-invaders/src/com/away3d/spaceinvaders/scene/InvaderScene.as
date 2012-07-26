package com.away3d.spaceinvaders.scene
{

	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.Object3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.events.Stage3DEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.SkyBox;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapCubeTexture;

	import com.away3d.spaceinvaders.GameSettings;
	import com.away3d.spaceinvaders.events.GameObjectEvent;
	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;
	import com.away3d.spaceinvaders.gameobjects.blast.Blast;
	import com.away3d.spaceinvaders.gameobjects.blast.BlastPool;
	import com.away3d.spaceinvaders.gameobjects.invaders.*;
	import com.away3d.spaceinvaders.gameobjects.player.Player;
	import com.away3d.spaceinvaders.gameobjects.projectiles.Projectile;
	import com.away3d.spaceinvaders.gameobjects.projectiles.ProjectilePool;
	import com.away3d.spaceinvaders.gameobjects.stars.StarPool;
	import com.away3d.spaceinvaders.sound.SoundManager;
	import com.away3d.spaceinvaders.sound.Sounds;
	import com.away3d.spaceinvaders.utils.MathUtils;
	import com.away3d.spaceinvaders.utils.ScoreManager;
	import com.starling.rootsprites.StarlingExplosionSprite;
	import com.starling.rootsprites.StarlingVortexSprite;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Timer;

	import starling.core.Starling;

	use namespace arcane; // TODO: Ugly, used to get the camera's aspect ratio

	public class InvaderScene extends Sprite
	{
//		[Embed(source="../../../../assets/skybox/space_posX.jpg")]
//		private var SkyboxImagePosX:Class;
//		[Embed(source="../../../../assets/skybox/space_negX.jpg")]
//		private var SkyboxImageNegX:Class;
//		[Embed(source="../../../../assets/skybox/space_posY.jpg")]
//		private var SkyboxImagePosY:Class;
//		[Embed(source="../../../../assets/skybox/space_negY.jpg")]
//		private var SkyboxImageNegY:Class;
//		[Embed(source="../../../../assets/skybox/space_posZ.jpg")]
//		private var SkyboxImagePosZ:Class;
//		[Embed(source="../../../../assets/skybox/space_negZ.jpg")]
//		private var SkyboxImageNegZ:Class;

		private var _stage3DProxy:Stage3DProxy;
		private var _view:View3D;
		private var _lightPicker:StaticLightPicker;
		private var _playerPosition:Point = new Point();

//		private var _cubeMap:BitmapCubeTexture;

		private var _player:Player;
		private var _playerVector:Vector.<GameObject>;

		private var _invaderPool:InvaderPool;
		//private var _starPool:StarPool;
		private var _playerProjectilePool:ProjectilePool;
		private var _invaderProjectilePool:ProjectilePool;
		private var _blastPool:BlastPool;
		private var _cellPool:InvaderCellPool;
		private var _gameObjectPools:Vector.<GameObjectPool>;
		private var _totalKills:uint;
		private var _currentLevelKills:uint;
		//private var _skyBox:SkyBox;
		private var _playerFireCounter:uint;
		private var _fireReleased:Boolean = true;
		private var _fireReleaseTimer:Timer;
		private var _starlingVortexScene : Starling;
		private var _starlingVortexSprite : StarlingVortexSprite;
		private var _starlingExplosionScene : Starling;
		private var _starlingExplosionSprite : StarlingExplosionSprite;

		private var _currentLevel:uint;

		private var _active:Boolean;

		public var cameraMotionEase : Number;

		public function InvaderScene() {
			addEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
		}

		private function stageInitHandler( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
			_stage3DProxy = Stage3DManager.getInstance(stage).getFreeStage3DProxy();
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, gameInitHandler);
			_stage3DProxy.antiAlias = 4;
			_stage3DProxy.color = 0x000000;
			_stage3DProxy.width = GameSettings.windowWidth;
			_stage3DProxy.height = GameSettings.windowHeight;
		}
		
		private function gameInitHandler( event:Stage3DEvent ):void {
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, gameInitHandler);
			initStarling();
			initEngine();
			initScene();
			update();
		}

		private function initStarling() : void {
			//Create the Starling scene to add the background wall/fireplace. This is positioned on top of the floor scene starting at the top of the screen. It slightly covers the wooden floor layer to avoid any gaps appearing.
			_starlingVortexScene = new Starling(StarlingVortexSprite, stage, _stage3DProxy.viewPort, _stage3DProxy.stage3D);
			_starlingVortexSprite = StarlingVortexSprite.getInstance();
			_starlingVortexSprite.touchable = false;
			
			_starlingExplosionScene = new Starling(StarlingExplosionSprite, stage, _stage3DProxy.viewPort, _stage3DProxy.stage3D);
			_starlingExplosionSprite = StarlingExplosionSprite.getInstance();
			_starlingExplosionSprite.touchable = false;
		}

		private function initEngine():void {
			_view = new View3D();
			_view.stage3DProxy = _stage3DProxy;
			_view.shareContext = true;
			_view.camera.lens.near = 50;
			_view.camera.lens.far = 100000;
			_view.width = GameSettings.windowWidth;
			_view.height = GameSettings.windowHeight;
			addChild( _view );
		}

		private var _cameraLight:PointLight;
		private var _cameraLightPicker:StaticLightPicker;
		private function initScene():void {

			// Init Lights.
			var frontLight:DirectionalLight = new DirectionalLight();
			frontLight.direction = new Vector3D( 0.5, 0, 1 );
			frontLight.color = 0xFFFFFF;
			frontLight.ambient = 0.1;
			frontLight.ambientColor = 0xFFFFFF;
			_view.scene.addChild( frontLight );
			_cameraLight = new PointLight();
			_view.scene.addChild( _cameraLight );
			_cameraLightPicker = new StaticLightPicker( [ _cameraLight ] );
			_lightPicker = new StaticLightPicker( [ frontLight ] );

			// Stats.
			if( GameSettings.debugMode ) {
				var stats:AwayStats = new AwayStats( _view );
				addChild( stats );
				var tri:Trident = new Trident();
				_view.scene.addChild( tri );
			}

			// Skybox.
//			_cubeMap = new BitmapCubeTexture(
//				new SkyboxImagePosX().bitmapData, new SkyboxImageNegX().bitmapData,
//				new SkyboxImagePosY().bitmapData, new SkyboxImageNegY().bitmapData,
//				new SkyboxImagePosZ().bitmapData, new SkyboxImageNegZ().bitmapData
//			);
//			_skyBox = new SkyBox( _cubeMap );
//			_view.scene.addChild( _skyBox );

			// Vortex black area.
			var vortexHole:Mesh = new Mesh( new SphereGeometry( 2500 ), new ColorMaterial( 0x000000 ) );
			vortexHole.position = new Vector3D( 0, 0, 90000 );
			_view.scene.addChild( vortexHole );

			// Init objects.
			_gameObjectPools = new Vector.<GameObjectPool>();
			createInvaders();

			// Stars.
			//var starMesh:Mesh = new Mesh( new CubeGeometry( 10, 10, 10 ), new ColorMaterial( 0xFFFFFF ) );
			//_starPool = new StarPool( starMesh );
			//_gameObjectPools.push( _starPool );
			//_view.scene.addChild( _starPool );

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

			// Update the vortex location
			var vortexScreenPosition:Vector3D = _view.project( new Vector3D( 0, 0, 90000 ) );
			_starlingVortexSprite.updatePosition( vortexScreenPosition.x, vortexScreenPosition.y );
			
			// Restore blasters from recoil.
			restoreBlaster( _leftBlaster );
			restoreBlaster( _rightBlaster );

			// Camera light follows player's position.
			_cameraLight.transform = _player.transform;
			_cameraLight.y += 500;

			// Render scene.
			//_view.render(); // Always render scene ( so 2D content updates properly on mobile with render mode = direct ).
			
			// Clear the stage3D instance
			_stage3DProxy.clear();
			
			// Render the Starling particle vortex
			_starlingVortexScene.nextFrame();
			
			// Render the main scene
			_view.render();

			// Render the Starling particle vortex
			_starlingExplosionScene.nextFrame();
			
			// Present the stage3D for display
			_stage3DProxy.present();
		}

		private function restoreBlaster( blaster:Mesh ):void {
			var dz:Number = GameSettings.blasterOffsetD - blaster.z;
			blaster.z += 0.25 * dz;
		}

		// -----------------------
		// Game control.
		// -----------------------

		public function resume():void {
			_invaderPool.resume();
			_active = true;
			_player.visible = true;
		}

		public function stop():void {
			_invaderPool.stop();
			_active = false;
			_player.visible = false;
		}

		private function loadLevel():void {
			if( _currentLevel > 0 ) _invaderPool.spawnTimeFactor -= GameSettings.spawnTimeDecreasePerLevel;
			if( _invaderPool.spawnTimeFactor < GameSettings.minimumSpawnTime ) _invaderPool.spawnTimeFactor = GameSettings.minimumSpawnTime;
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
			var playerProjectileMaterial:ColorMaterial = new ColorMaterial( 0x00FFFF, 0.75 );
			playerProjectileMaterial.lightPicker = _lightPicker;
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
			_player.visible = false;
			_view.scene.addChild( _player );

			// Blasters.
			var playerMaterial:ColorMaterial = new ColorMaterial( 0xFFFFFF );
			playerMaterial.lightPicker = _cameraLightPicker;
			_leftBlaster = new Mesh( new CubeGeometry( 25, 25, 500 ), playerMaterial );
			_rightBlaster = _leftBlaster.clone() as Mesh;
			_leftBlaster.position = new Vector3D( -GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, GameSettings.blasterOffsetD );
			_rightBlaster.position = new Vector3D( GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, GameSettings.blasterOffsetD );
			_player.addChild( _leftBlaster );
			_player.addChild( _rightBlaster );

			// Used for rapid fire.
			_fireReleaseTimer = new Timer( GameSettings.blasterFireRateMS, 1 );
			_fireReleaseTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onFireReleaseTimerComplete );
		}
		private var _leftBlaster:Mesh;
		private var _rightBlaster:Mesh;

		private function onFireReleaseTimerComplete( event:TimerEvent ):void {
			_fireReleased = true;
		}

		// -----------------------
		// Invader creation.
		// -----------------------

		private function createInvaders():void {

			// TODO: review and unify materials of the same color

			// Blasts.
			var blastMaterial:ColorMaterial = new ColorMaterial( 0x00FFFF, 0.5 );
			var blastMesh:Mesh = new Mesh( new SphereGeometry(), blastMaterial );
			_blastPool = new BlastPool( blastMesh );
			_gameObjectPools.push( _blastPool );
			_view.scene.addChild( _blastPool );

			// Same material for all invaders.
			var invaderMaterial:ColorMaterial = new ColorMaterial( 0x777780, 1 );
//			invaderMaterial.addMethod( new EnvMapMethod( _cubeMap, 0.5 ) );
			invaderMaterial.lightPicker = _lightPicker;

			// Reusable projectile mesh.
			var invaderProjectileGeometry:Geometry = new CubeGeometry( 25, 25, 200, 1, 1, 4 );
			var invaderProjectileMaterial:ColorMaterial = new ColorMaterial( 0xFF0000, 0.75 );
			invaderProjectileMaterial.lightPicker = _lightPicker;
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
			_invaderPool.addEventListener( GameObjectEvent.HIT, onInvaderHit );
			_gameObjectPools.push( _invaderPool );
			_view.scene.addChild( _invaderPool );

			// Create cells ( used for invader death explosions ).
//			var cellMaterial:ColorMaterial = new ColorMaterial( 0xFF0000, 0.75 );
//			cellMaterial.lightPicker = _lightPicker;
//			cellMaterial.blendMode = BlendMode.ADD;
			var cellMesh:Mesh = new Mesh( new CubeGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeXY, GameSettings.invaderSizeZ ), invaderMaterial );
			_cellPool = new InvaderCellPool( cellMesh as Mesh );
			_gameObjectPools.push( _cellPool );
			_view.scene.addChild( _cellPool );
		}

		private function onInvaderHit( event:GameObjectEvent ):void {
			SoundManager.playSound( Sounds.BOING );
			var blast:Blast = _blastPool.addItem() as Blast;
			blast.position = event.objectB.position;
			blast.velocity.z = event.objectA.velocity.z;
			blast.z -= GameSettings.invaderSizeZ;
			
			var blastXY:Vector3D = _view.project(blast.scenePosition);
			_starlingExplosionSprite.explode(blastXY.x, blastXY.y, ((15000 - blast.z) / 7500) - 0.25);
		}

		private function onInvaderCreated( event:GameObjectEvent ):void {
			var invader:Invader = event.objectA as Invader;
			if( invader.invaderType == InvaderDefinitions.MOTHERSHIP ) {
				SoundManager.playSound( Sounds.MOTHERSHIP );
			}
			_starlingVortexSprite.spawn();
		}

		// -----------------------
		// Invader deaths.
		// -----------------------

		private function createInvaderDeathAnimation( invader:Invader, hitter:Projectile ):void {
			var intensity:Number = GameSettings.deathExplosionIntensity * MathUtils.rand( 1, 4 );
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
			if( _currentLevelKills > GameSettings.killsToAdvanceDifficulty ) {
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
			var invader:Invader = event.objectA as Invader;
			if( invader.invaderType != InvaderDefinitions.MOTHERSHIP ) {
				SoundManager.playSound( Sounds.INVADER_FIRE, 0.5 );
				fireProjectile( event.objectA, new Vector3D( 0, 0, -100 ), _playerVector, _invaderProjectilePool );
			}
			else {
				var offset:Vector3D = new Vector3D();
				offset.x = MathUtils.rand( -700, 700 );
				offset.y = MathUtils.rand( -150, 150 );
				fireProjectile( event.objectA, new Vector3D( 0, 0, -100 ), _playerVector, _invaderProjectilePool, offset );
			}
		}

		public function firePlayer():void {
			if( !_fireReleased ) return;
			if( !_active ) return;
			SoundManager.playSound( Sounds.PLAYER_FIRE, 0.5 );
			var velocity:Vector3D = new Vector3D( 0, 0, 200 );
			velocity = _player.transform.deltaTransformVector( velocity );
			_playerFireCounter++;
			var offset:Vector3D;
			var blaster:Mesh = _playerFireCounter % 2 ? _rightBlaster : _leftBlaster;
			if( blaster == _rightBlaster ) {
				offset = new Vector3D( GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, 0 );
			}
			else {
				offset = new Vector3D( -GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, 0 );
			}
			blaster.z -= 500;
			fireProjectile( _player, velocity, _invaderPool.gameObjects, _playerProjectilePool, offset );
			_fireReleased = false;
			_fireReleaseTimer.reset();
			_fireReleaseTimer.start();
		}

		public function fireProjectile( source:Object3D, velocity:Vector3D, targets:Vector.<GameObject>, pool:GameObjectPool, offset:Vector3D = null ):void {
			var projectile:Projectile = pool.addItem() as Projectile;
			projectile.targets = targets;
			projectile.transform = source.transform.clone();
			projectile.velocity = velocity;
			if( offset ) {
				projectile.position = projectile.position.add( offset );
			}
		}

		// -----------------------
		// Player motion.
		// -----------------------

		public function movePlayerTowards( x:Number, y:Number ):void {
			var dx:Number = x - _playerPosition.x;
			var dy:Number = y - _playerPosition.y;
			_player.x += dx * cameraMotionEase;
			_player.y += dy * cameraMotionEase;
			if( GameSettings.panTiltFactor != 0 ) {
				_player.rotationY = -GameSettings.panTiltFactor * _player.x;
				_player.rotationX =  GameSettings.panTiltFactor * _player.y;
			}
			_playerPosition.x = _player.x;
			_playerPosition.y = _player.y;
		}

		public function get playerPosition():Point {
			return _playerPosition;
		}
	}
}
