package 
{

	import flash.net.SharedObject;
	import flash.display.SimpleButton;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.DisplayObject;
	import flash.sensors.Accelerometer;
	import flash.events.AccelerometerEvent;
	import invaders.sound.SoundLibrary;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import invaders.gameobjects.invaders.InvaderCell;
	import invaders.utils.MathUtils;
	import invaders.gameobjects.projectiles.Projectile;
	import invaders.gameobjects.blast.Blast;
	import invaders.gameobjects.invaders.InvaderDefinitions;
	import invaders.gameobjects.invaders.Invader;
	import invaders.gameobjects.player.Player;
	import invaders.gameobjects.GameObject;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import invaders.gameobjects.projectiles.ProjectilePool;
	import invaders.gameobjects.invaders.InvaderCellPool;
	import invaders.events.GameObjectEvent;
	import invaders.gameobjects.invaders.InvaderPool;
	import away3d.core.base.Geometry;
	import invaders.gameobjects.blast.BlastPool;
	import invaders.gameobjects.GameObjectPool;
	import away3d.containers.*;
	import away3d.materials.lightpickers.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.entities.*;
	import away3d.debug.*;
	import away3d.lights.*;
	
	import flash.geom.*;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.ui.Mouse;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class Main extends Sprite
	{
		private var _view:View3D;
		private var _lightPicker:StaticLightPicker;
		private var _playerPosition:Point = new Point();
		
		private var _cameraLight:PointLight;
		private var _cameraLightPicker:StaticLightPicker;
		private var _gameObjectPools:Vector.<GameObjectPool>;
		
		private var _player:Player;
		private var _playerVector:Vector.<GameObject>;

		private var _invaderPool:InvaderPool;
		private var _soundLibrary:SoundLibrary;
		
		private var _playerProjectilePool:ProjectilePool;
		private var _invaderProjectilePool:ProjectilePool;
		private var _blastPool:BlastPool;
		private var _cellPool:InvaderCellPool;
		private var _totalKills:uint;
		private var _currentLevelKills:uint;
		
		private var _playerFireCounter:uint;
		private var _fireReleased:Boolean = true;
		private var _fireReleaseTimer:Timer;
		private var _leftBlaster:Mesh;
		private var _rightBlaster:Mesh;
		
		private var _showingMouse:Boolean = true;
		
		private var _currentLevel:uint;
		private var _active:Boolean;
		
		private var _currentPosition:Point = new Point();
		private var _accelerometer:Accelerometer = new Accelerometer();
		private var _isFiring:Boolean;
		private var _mouseIsOnStage:Boolean = true;
		private var _firstAccY:Number;
		
		private var _scoreText:TextField;
		private var _livesText:TextField;
		private var _popUp:MovieClip;
		private var _restartButton:SimpleButton;
		private var _pauseButton:SimpleButton;
		private var _liveIconsContainer:Sprite;
		private var _crossHair:Sprite;
		
		private var _score:uint;
		private var _highScore:uint;
		private var _lives:uint;
		
		private const SO_NAME:String = "away3dSpaceInvadersUserData";
		
		/**
		 * Constructor
		 */
		public function Main()
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initGame();
			initEngine();
			initScene();
			initInvaders();
			initPlayer();
			initUI();
			initInput();
		}
		
		/**
		 * Initialise the game
		 */		
		private function initGame():void
		{
			//initialise the highscore
			_highScore = loadHighScore();
			
			//set stage properties
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//update game settings
			GameSettings.windowWidth = stage.stageWidth;
			GameSettings.windowHeight = stage.stageHeight;
			
			//initialise sound manager
			_soundLibrary = SoundLibrary.getInstance();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			_view = new View3D();
			_view.camera.lens.near = 50;
			_view.camera.lens.far = 100000;
			_view.width = GameSettings.windowWidth;
			_view.height = GameSettings.windowHeight;
			addChild( _view );
			
			// Stats.
			if( GameSettings.debugMode ) {
				var stats:AwayStats = new AwayStats( _view );
				addChild( stats );
				var tri:Trident = new Trident();
				_view.scene.addChild( tri );
			}
		}
		
		private function initScene():void
		{
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


			// Skybox.
//			_cubeMap = new BitmapCubeTexture(
//				new SkyboxImagePosX().bitmapData, new SkyboxImageNegX().bitmapData,
//				new SkyboxImagePosY().bitmapData, new SkyboxImageNegY().bitmapData,
//				new SkyboxImagePosZ().bitmapData, new SkyboxImageNegZ().bitmapData
//			);
//			_skyBox = new SkyBox( _cubeMap );
//			_view.scene.addChild( _skyBox );

			// Init objects.
			_gameObjectPools = new Vector.<GameObjectPool>();
		}
		
		/**
		 * Initialise the invader objects
		 */
		private function initInvaders():void
		{
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
		
		/**
		 * 
		 */
		private function initPlayer():void
		{
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
		
		/**
		 * Initialise the UI
		 */		
		private function initUI():void
		{
			//initialise UI
			// Cross hair.
			_crossHair = new Crosshair();
			_crossHair.x = GameSettings.windowWidth / 2;
			_crossHair.y = GameSettings.windowHeight / 2;
			addChild( _crossHair );

			// Score text.
			_scoreText = getTextField();
			addChild( _scoreText );

			// Lives text.
			_livesText = getTextField();
			_livesText.y = GameSettings.windowHeight - 35;
			fitClip( _livesText );
			addChild( _livesText );

			// Lives icons.
			_liveIconsContainer = new Sprite();
			addChild( _liveIconsContainer );
			for( var i:uint; i < GameSettings.playerLives; i++ ) {
				var live:Sprite = new InvaderLive();
				live.x = i * ( live.width + 5 );
				_liveIconsContainer.addChild( live );
			}
			_liveIconsContainer.y = _livesText.y + 12;
			fitClip( _liveIconsContainer );

			// Buttons.
			_restartButton = new RestartButton();
			_restartButton.addEventListener( MouseEvent.MOUSE_UP, onRestart );
			initializeButton( _restartButton );
			addChild( _restartButton );
			_pauseButton = new PauseButton();
			_pauseButton.x = GameSettings.windowWidth - _pauseButton.width;
			fitClip( _pauseButton );
			_pauseButton.addEventListener( MouseEvent.MOUSE_UP, onPause );
			initializeButton( _pauseButton );
			addChild( _pauseButton );

			showSplashPopUp();
			
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		/**
		 * 
		 */
		private function initInput():void
		{
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.addEventListener( Event.MOUSE_LEAVE, onMouseLeave );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
			_accelerometer.addEventListener(AccelerometerEvent.UPDATE, onAccelerometerUpdate);
		}
		
		/**
		 * 
		 */
		private function setLevel():void
		{
			if( _currentLevel > 0 ) _invaderPool.spawnTimeFactor -= GameSettings.spawnTimeDecreasePerLevel;
			if( _invaderPool.spawnTimeFactor < GameSettings.minimumSpawnTime ) _invaderPool.spawnTimeFactor = GameSettings.minimumSpawnTime;
		}
		
		// -----------------------
		// App flow.
		// -----------------------

		private function stopGame():void {
			showMouse();
			_invaderPool.stop();
			_active = false;
			_player.visible = false;
		}

		private function startGame():void {
			hideMouse();
			
			_firstAccY = 0;
			
			// Reset all game object pools.
			for( var i:uint; i < _gameObjectPools.length; ++i ) {
				var gameObjectPool:GameObjectPool = _gameObjectPools[ i ];
				gameObjectPool.reset();
			}
			_currentLevel = 0;
			_currentLevelKills = 0;
			_totalKills = 0;
			_invaderPool.spawnTimeFactor = 1;
			
			setLevel();
			
			_invaderPool.resume();
			_active = true;
			_player.visible = true;
			
			_score = 0;
			_lives = GameSettings.playerLives;
			updateScore();
			updateLives();
		}
		
		// -----------------------
		// Pop ups.
		// -----------------------

		public function showPausePopUp():void
		{
			var popUp:MovieClip = new PausePopUp();
			var resumeButton:SimpleButton = popUp.resumeButton;
			resumeButton.addEventListener( MouseEvent.MOUSE_UP, onResume, false, 0, true );
			initializeButton( resumeButton );
			initializePopUp( popUp );
		}

		public function hidePausePopUp():void
		{
			if( !_popUp || !( _popUp is PausePopUp ) ) return;
			var resumeButton:SimpleButton = _popUp.resumeButton;
			resumeButton.removeEventListener( MouseEvent.MOUSE_UP, onResume );
			destroyButton( resumeButton );
			destroyPopUp();
		}

		public function showGameOverPopUp():void
		{
			var popUp:MovieClip = new GameOverPopUp();
			var playAgainButton:SimpleButton = popUp.playAgainButton;
			playAgainButton.addEventListener( MouseEvent.MOUSE_UP, onPlay, false, 0, true );
			initializeButton( playAgainButton );
			var scoreText:TextField = popUp.scoreText;
			scoreText.text =     "SCORE................................... " + uintToString( _score );
			var highScoreText:TextField = popUp.highScoreText;
			highScoreText.text = "HIGH-SCORE.............................. " + uintToString( _highScore );
			scoreText.width = scoreText.textWidth * 1.05;
			scoreText.x = -scoreText.width / 2;
			fitClip( scoreText );
			highScoreText.width = highScoreText.textWidth * 1.05;
			highScoreText.x = -highScoreText.width / 2;
			fitClip( highScoreText );
			initializePopUp( popUp );
		}

		public function hideGameOverPopUp():void
		{
			if( !_popUp || !( _popUp is GameOverPopUp ) ) return;
			var playAgainButton:SimpleButton = _popUp.playAgainButton;
			playAgainButton.removeEventListener( MouseEvent.MOUSE_UP, onPlay );
			destroyButton( playAgainButton );
			destroyPopUp();
		}

		public function showSplashPopUp():void
		{
			var popUp:SplashPopUp = new SplashPopUp();
			var playButton:SimpleButton = popUp.playButton;
			playButton.addEventListener( MouseEvent.MOUSE_UP, onPlay, false, 0, true );
			initializeButton( playButton );
			initializePopUp( popUp );
		}

		public function hideSplashPopUp():void
		{
			if( !_popUp || !( _popUp is SplashPopUp ) ) return;
			var playButton:SimpleButton = _popUp.playButton;
			playButton.removeEventListener( MouseEvent.MOUSE_UP, onPlay );
			destroyButton( playButton );
			destroyPopUp();
		}

		private function destroyPopUp():void
		{
			removeChild( _popUp );
			_popUp = null;
			_scoreText.visible = true;
			_livesText.visible = true;
			_restartButton.visible = true;
			_pauseButton.visible = true;
			_liveIconsContainer.visible = true;
			_crossHair.visible = true;
		}

		private function initializePopUp( popUp:MovieClip ):void
		{
			popUp.x = GameSettings.windowWidth / 2;
			popUp.y = GameSettings.windowHeight / 2;
			var bg:Sprite = popUp.bg;
			bg.width = GameSettings.windowWidth;
			bg.height = GameSettings.windowHeight;
			bg.x = -GameSettings.windowWidth / 2;
			bg.y = -GameSettings.windowHeight / 2;
			_popUp = popUp;
			addChild( popUp );
			_scoreText.visible = false;
			_livesText.visible = false;
			_restartButton.visible = false;
			_pauseButton.visible = false;
			_liveIconsContainer.visible = false;
			_crossHair.visible = false;
		}

		private function initializeButton( button:SimpleButton ):void
		{
			button.addEventListener( MouseEvent.MOUSE_DOWN, onBtnMouseDown, false, 0, true );
		}

		private function destroyButton( button:SimpleButton ):void
		{
			button.removeEventListener( MouseEvent.MOUSE_DOWN, onBtnMouseDown );
		}
		
		public function updateLives():void
		{
			// Update icons.
			for( var i:uint; i < GameSettings.playerLives; i++ ) {
				var child:Sprite = _liveIconsContainer.getChildAt( i ) as Sprite;
				child.visible = _lives >= i + 1;
			}
			// Update text.
			_livesText.text = "LIVES " + _lives + "";
			_livesText.width = _livesText.textWidth * 1.05;
			_livesText.x = GameSettings.windowWidth / 2 - _livesText.width / 2 - _liveIconsContainer.width / 2 - 5;
			_liveIconsContainer.x = _livesText.x + _livesText.width + 10;
			fitClip( _livesText );
			fitClip( _liveIconsContainer );
		}

		public function updateScore():void
		{
			_scoreText.text = "SCORE " + uintToString( _score ) + "   ";
			_scoreText.text += "HIGH-SCORE " + uintToString( _highScore );
			_scoreText.width = _scoreText.textWidth * 1.05;
			_scoreText.x = GameSettings.windowWidth / 2 - _scoreText.width / 2;
			fitClip( _scoreText );
		}

		private function getTextField():TextField {
			var clip:CustomTextField = new CustomTextField();
			return clip.tf;
		}

		private function fitClip( clip:DisplayObject ):void {
			clip.x = Math.floor( clip.x );
			clip.y = Math.floor( clip.y );
		}

		private function uintToString( value:uint ):String {
			if( value == 0 ) return "00000";
			var str:String = "";
			var compare:Number = 10000;
			while( compare > value ) {
				str += "0";
				compare /= 10;
			}
			str += value;
			return str;
		}
		
		public function saveHighScore( score:uint ):void {
			var sharedObject:SharedObject = SharedObject.getLocal( SO_NAME );
			sharedObject.data.highScore = score;
			sharedObject.flush();
		}

		public function loadHighScore():uint {
			var sharedObject:SharedObject = SharedObject.getLocal( SO_NAME );
			if( sharedObject ) {
				var score:uint = sharedObject.data.highScore;
				if( score ) {
					return score;
				}
			}
			return 0;
		}
		
		/**
		 * Navigation and render loop
		 */		
		private function onEnterFrame( event:Event ):void
		{
			if( _isFiring && _fireReleased && _active) {
				_soundLibrary.playSound( SoundLibrary.PLAYER_FIRE, 0.5 );
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
				
				var projectile:Projectile = _playerProjectilePool.addItem() as Projectile;
				projectile.targets = _invaderPool.gameObjects;
				projectile.transform = _player.transform.clone();
				projectile.velocity = velocity;
				if( offset ) {
					projectile.position = projectile.position.add( offset );
				}
				_fireReleased = false;
				_fireReleaseTimer.reset();
				_fireReleaseTimer.start();
			}

			if( _mouseIsOnStage ) {
				if( stage.mouseX > 0 && stage.mouseX < 100000 ) {
					_currentPosition.x = stage.mouseX;
				}
				if( stage.mouseY > 0 && stage.mouseY < 100000 ) {
					_currentPosition.y = stage.mouseY;
				}
			}

			var hw:Number = GameSettings.windowWidth / 2;
			var hh:Number = GameSettings.windowHeight / 2;
			
			var dx:Number = GameSettings.mouseMotionFactor * ( _currentPosition.x - hw ) / hw - _playerPosition.x;
			var dy:Number = -GameSettings.mouseMotionFactor * ( _currentPosition.y - hh ) / hh - _playerPosition.y;
			_player.x += dx * GameSettings.mouseCameraMotionEase;
			_player.y += dy * GameSettings.mouseCameraMotionEase;
			if( GameSettings.panTiltFactor != 0 ) {
				_player.rotationY = -GameSettings.panTiltFactor * _player.x;
				_player.rotationX =  GameSettings.panTiltFactor * _player.y;
			}
			_playerPosition.x = _player.x;
			_playerPosition.y = _player.y;
			
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
			
			// Restore blasters from recoil.
			_leftBlaster.z += 0.25 * (GameSettings.blasterOffsetD - _leftBlaster.z);
			_rightBlaster.z += 0.25 * (GameSettings.blasterOffsetD - _rightBlaster.z);

			// Camera light follows player's position.
			_cameraLight.transform = _player.transform;
			_cameraLight.y += 500;
			
			// Render the main scene
			_view.render();
			
			if( _active ) {
				if( mouseY < 50 ) showMouse();
				else hideMouse();
			}
		}
		
		// -----------------------------
		// Game event handlers.
		// -----------------------------
		
		private function onFireReleaseTimerComplete( event:TimerEvent ):void {
			_fireReleased = true;
		}
		
		private function onInvaderHit( event:GameObjectEvent ):void {
			_soundLibrary.playSound( SoundLibrary.BOING );
			var blast:Blast = _blastPool.addItem() as Blast;
			blast.position = event.objectB.position;
			blast.velocity.z = event.objectA.velocity.z;
			blast.z -= GameSettings.invaderSizeZ;
		}

		private function onInvaderCreated( event:GameObjectEvent ):void {
			var invader:Invader = event.objectA as Invader;
			if( invader.invaderType == InvaderDefinitions.MOTHERSHIP ) {
				_soundLibrary.playSound( SoundLibrary.MOTHERSHIP );
			}
		}
		
		private function onInvaderDead( event:GameObjectEvent ):void {

			var invader:Invader = event.objectA as Invader;

			// Check level update and update UI.
			_currentLevelKills++;
			_totalKills++;
			
			_score += InvaderDefinitions.getScoreForInvaderType( invader.invaderType );
			if( _score > _highScore ) {
				_highScore = _score;
				var sharedObject:SharedObject = SharedObject.getLocal( SO_NAME );
				sharedObject.data.highScore = _score;
				sharedObject.flush();
			}
			
			updateScore();
			
			if( _currentLevelKills > GameSettings.killsToAdvanceDifficulty ) {
				_currentLevelKills = 0;
				_currentLevel++;
				setLevel();
			}

			// Play sounds.
			if( invader.invaderType == InvaderDefinitions.MOTHERSHIP ) {
				_soundLibrary.playSound( SoundLibrary.EXPLOSION_STRONG );
			}
			else {
				_soundLibrary.playSound( SoundLibrary.INVADER_DEATH );
			}

			// Show invader destruction.
			var hitter:Projectile = event.objectB as Projectile;
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
		
		private function onPlayerHit( event:GameObjectEvent ):void
		{
			_soundLibrary.playSound( SoundLibrary.EXPLOSION_SOFT );
			_lives--;
			updateLives();
			
			//game over
			if( _lives == 0 ) {
				showGameOverPopUp();
				stopGame();
			}
		}
		
		private function onInvaderFire( event:GameObjectEvent ):void {
			var invader:Invader = event.objectA as Invader;
			var projectile:Projectile = _invaderProjectilePool.addItem() as Projectile;
			projectile.targets = _playerVector;
			projectile.transform = invader.transform.clone();
			projectile.velocity = new Vector3D( 0, 0, -100 );
			
			if( invader.invaderType != InvaderDefinitions.MOTHERSHIP ) {
				_soundLibrary.playSound( SoundLibrary.INVADER_FIRE, 0.5 );
			}
			else {
				var offset:Vector3D = new Vector3D();
				offset.x = MathUtils.rand( -700, 700 );
				offset.y = MathUtils.rand( -150, 150 );
				projectile.position = projectile.position.add( offset );
			}
			
			if( offset ) {
				projectile.position = projectile.position.add( offset );
			}
		}
		
		// -----------------------------
		// User interface interaction.
		// -----------------------------

		private function showMouse():void {
			if( _showingMouse ) return;
			Mouse.show();
			_showingMouse = true;
		}

		private function hideMouse():void {
			if( !_showingMouse ) return;
			Mouse.hide();
			_showingMouse = false;
		}

		private function onResume( event:MouseEvent ):void {
			_firstAccY = 0;
			hideMouse();
			hidePausePopUp();
			
			_invaderPool.resume();
			_active = true;
			_player.visible = true;
		}

		private function onPause( event:MouseEvent ):void {
			stopGame();
			showPausePopUp();
		}

		private function onRestart( event:MouseEvent ):void {
			_score = 0;
			_lives = GameSettings.playerLives;
			startGame();
			updateScore();
			updateLives();
		}

		private function onPlay( event:MouseEvent ):void {
			startGame();
			hideSplashPopUp();
			hideGameOverPopUp();
		}
		
		private function onBtnMouseDown( event:MouseEvent ):void {
			SoundLibrary.getInstance().playSound( SoundLibrary.UFO );
		}
				
		// -----------------------------
		// Input event handlers.
		// -----------------------------
		
		private function onMouseMove( event:MouseEvent ):void {
			_mouseIsOnStage = true;
		}

		private function onMouseLeave( event:Event ):void {
			_mouseIsOnStage = false;
		}

		private function onMouseDown( event:MouseEvent ):void {
			_isFiring = true;
		}

		private function onMouseUp( event:MouseEvent ):void {
			_isFiring = false;
		}
		
		private function onKeyDown( event:KeyboardEvent ):void {
			switch( event.keyCode ) {
				case Keyboard.SPACE:
					_isFiring = true;
					break;
			}
		}
		
		private function onKeyUp( event:KeyboardEvent ):void {
			switch( event.keyCode ) {
				case Keyboard.SPACE:
					_isFiring = false;
					break;
			}
		}
		
		
		private function onAccelerometerUpdate( event:AccelerometerEvent ):void {
//			trace( "accelerometer: " + event.accelerationX + ", " + event.accelerationY + ", " + event.accelerationZ );
			// Use first encountered acc Y as Y center.
			if( _firstAccY == 0 ) {
				_firstAccY = event.accelerationY;
			}
			// Update position.
			_currentPosition.x = -GameSettings.accelerometerMotionFactorX * event.accelerationX * GameSettings.cameraPanRange;
			_currentPosition.y =  GameSettings.accelerometerMotionFactorY * ( _firstAccY - event.accelerationY ) * GameSettings.cameraPanRange;
			// Containment.
//			if( _currentPosition.x < -GameSettings.cameraPanRange ) _currentPosition.x = -GameSettings.cameraPanRange;
//			if( _currentPosition.x >  GameSettings.cameraPanRange ) _currentPosition.x =  GameSettings.cameraPanRange;
//			if( _currentPosition.y < -GameSettings.cameraPanRange ) _currentPosition.y = -GameSettings.cameraPanRange;
//			if( _currentPosition.y >  GameSettings.cameraPanRange ) _currentPosition.y =  GameSettings.cameraPanRange;
		}

	}
}
