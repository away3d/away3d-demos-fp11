package 
{
	import invaders.events.*;
	import invaders.objects.*;
	import invaders.pools.*;
	import invaders.sounds.*;
	import invaders.utils.*;
	
	import away3d.containers.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.lights.*;
	import away3d.materials.lightpickers.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.sensors.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.*;
	
	
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
		
		
		//hud variables
		private var _hudContainer:Sprite;
		private var _scoreText:TextField;
		private var _livesText:TextField;
		private var _restartButton:SimpleButton;
		private var _pauseButton:SimpleButton;
		
		//popup variables
		private var _activePopUp:MovieClip;
		private var _popUpContainer:Sprite;
		private var _splashPopUp:MovieClip;
		private var _playButton:SimpleButton;
		private var _pausePopUp:MovieClip;
		private var _resumeButton:SimpleButton;
		private var _gameOverPopUp:MovieClip;
		private var _goScoreText:TextField;
		private var _goHighScoreText:TextField;
		private var _playAgainButton:SimpleButton;
		private var _liveIconsContainer:Sprite;
		private var _crossHair:Sprite;
		
		//score variables
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
			initListeners();
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
			// Reusable blasts.
			_blastPool = new BlastPool( new Mesh( new SphereGeometry(), new ColorMaterial( 0x00FFFF, 0.5 ) ) );
			_gameObjectPools.push( _blastPool );
			_view.scene.addChild( _blastPool );
			
			// Reusable invader projectiles.
			var invaderProjectileMaterial:ColorMaterial = new ColorMaterial( 0xFF0000 );
			invaderProjectileMaterial.lightPicker = _lightPicker;
			_invaderProjectilePool = new ProjectilePool(  new Mesh( new CubeGeometry( 25, 25, 200, 1, 1, 4 ), invaderProjectileMaterial ) );
			_gameObjectPools.push( _invaderProjectilePool );
			_view.scene.addChild( _invaderProjectilePool );
			
			// Reusable invaders.
			var invaderMaterial:ColorMaterial = new ColorMaterial( 0x777780, 1 );
//			invaderMaterial.addMethod( new EnvMapMethod( _cubeMap, 0.5 ) );
			invaderMaterial.lightPicker = _lightPicker;
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
			_cellPool = new InvaderCellPool( new Mesh( new CubeGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeXY, GameSettings.invaderSizeZ ), invaderMaterial ) );
			_gameObjectPools.push( _cellPool );
			_view.scene.addChild( _cellPool );
		}
		
		/**
		 * 
		 */
		private function initPlayer():void
		{
			// Reusable player projectiles.
			var playerProjectileMaterial:ColorMaterial = new ColorMaterial( 0x00FFFF, 0.75 );
			playerProjectileMaterial.lightPicker = _lightPicker;
			_playerProjectilePool = new ProjectilePool( new Mesh( new CubeGeometry( 25, 25, 200 ), playerProjectileMaterial ) );
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
			// Initialise the HUD
			_hudContainer = new Sprite();
			addChild(_hudContainer);
			
			// Cross hair.
			_crossHair = new Crosshair();
			_hudContainer.addChild( _crossHair );
			
			// Score text.
			_scoreText = getTextField();
			_hudContainer.addChild( _scoreText );
			
			// Lives text.
			_livesText = getTextField();
			_hudContainer.addChild( _livesText );
			
			// Lives icons.
			_liveIconsContainer = new Sprite();
			_hudContainer.addChild( _liveIconsContainer );
			for( var i:uint; i < GameSettings.playerLives; i++ ) {
				var live:Sprite = new InvaderLive();
				live.x = i * ( live.width + 5 );
				_liveIconsContainer.addChild( live );
			}
			
			// Restart button
			_restartButton = new RestartButton();
			_restartButton.addEventListener( MouseEvent.MOUSE_UP, onRestart );
			_hudContainer.addChild( _restartButton );
			
			// Pause button
			_pauseButton = new PauseButton();
			_pauseButton.addEventListener( MouseEvent.MOUSE_UP, onPause );
			_hudContainer.addChild( _pauseButton );
			
			// Initialise the popups
			_popUpContainer = new Sprite();
			addChild(_popUpContainer);
			
			// Splash popup
			_splashPopUp = new SplashPopUp();
			_splashPopUp.visible = false;
			_popUpContainer.addChild(_splashPopUp);
			_playButton = _splashPopUp.playButton;
			_playButton.addEventListener( MouseEvent.MOUSE_UP, onPlay );
			
			// Pause popup
			_pausePopUp = new PausePopUp();
			_pausePopUp.visible = false;
			_popUpContainer.addChild(_pausePopUp);
			_resumeButton = _pausePopUp.resumeButton;
			_resumeButton.addEventListener( MouseEvent.MOUSE_UP, onResume );
			
			// Game over popup
			_gameOverPopUp = new GameOverPopUp();
			_gameOverPopUp.visible = false;
			_popUpContainer.addChild(_gameOverPopUp);
			_playAgainButton = _gameOverPopUp.playAgainButton;
			_playAgainButton.addEventListener( MouseEvent.MOUSE_UP, onPlay, false, 0, true );
			_goScoreText = _gameOverPopUp.scoreText;
			
			showPopUp( _splashPopUp );
			
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.addEventListener( Event.MOUSE_LEAVE, onMouseLeave );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
			stage.addEventListener( Event.RESIZE, onResize);
			_accelerometer.addEventListener(AccelerometerEvent.UPDATE, onAccelerometerUpdate);
			onResize();
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
			for( var i:uint; i < _gameObjectPools.length; ++i )
				_gameObjectPools[ i ].reset();
			
			//reset level data
			_currentLevel = 0;
			_currentLevelKills = 0;
			_totalKills = 0;
			_invaderPool.spawnTimeFactor = 1;
			
			_invaderPool.resume();
			_active = true;
			_player.visible = true;
			
			updateScore(0);
			updateLives(GameSettings.playerLives);
			onResize();
		}
		
		// -----------------------
		// Pop ups.
		// -----------------------

		private function hidePopUp():void
		{
			_hudContainer.visible = true;
			_activePopUp.visible = false;
		}

		private function showPopUp( popUp:MovieClip ):void
		{
			_activePopUp = popUp;
			_hudContainer.visible = false;
			_activePopUp.visible = true;
		}
		
		private function updateLives(lives:uint):void
		{
			_lives = lives;
			
			// Update icons.
			for( var i:uint; i < GameSettings.playerLives; i++ ) {
				var child:Sprite = _liveIconsContainer.getChildAt( i ) as Sprite;
				child.visible = _lives >= i + 1;
			}
			// Update text.
			_livesText.text = "LIVES " + _lives + "";
			_livesText.width = _livesText.textWidth * 1.05;
		}
		
		private function updateScore(score:uint):void
		{
			_score = score;
			_scoreText.text = "SCORE " + uintToString( _score ) + "   HIGH-SCORE " + uintToString( _highScore );
			_scoreText.width = int(_scoreText.textWidth * 1.05);
		}

		private function getTextField():TextField {
			var clip:CustomTextField = new CustomTextField();
			return clip.tf;
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
				_playerFireCounter++;
				
				_soundLibrary.playSound( SoundLibrary.PLAYER_FIRE, 0.5 );
				
				//kick bacl on the right blaster
				var blaster:Mesh = _playerFireCounter % 2 ? _rightBlaster : _leftBlaster;
				blaster.z -= 500;
				
				//create a new projectile
				var projectile:Projectile = _playerProjectilePool.getGameObject() as Projectile;
				projectile.targets = _invaderPool.gameObjects;
				projectile.transform = _player.transform.clone();
				projectile.velocity = _player.transform.deltaTransformVector( new Vector3D( 0, 0, 200 ) );
				projectile.position = projectile.position.add( new Vector3D( _playerFireCounter % 2 ? GameSettings.blasterOffsetH : -GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, -750 ) );
				
				_fireReleased = false;
				_fireReleaseTimer.reset();
				_fireReleaseTimer.start();
			}

			if( _mouseIsOnStage ) {
				if( stage.mouseX > 0 && stage.mouseX < 100000 )
					_currentPosition.x = stage.mouseX;
				
				if( stage.mouseY > 0 && stage.mouseY < 100000 )
					_currentPosition.y = stage.mouseY;
			}

			var hw:Number = stage.stageWidth / 2;
			var hh:Number = stage.stageHeight / 2;
			
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
		
		private function onResize(event:Event = null):void
		{
			var w:int = stage.stageWidth;
			var h:int = stage.stageHeight;
			var hw:int = w/2;
			var hh:int = h/2;
			
			//update view size
			_view.width = w;
			_view.height = h;
			
			//update crosshair & popup position
			_popUpContainer.x = _crossHair.x = hw;
			_popUpContainer.y = _crossHair.y = hh;
			
			//update lives text position
			_livesText.x = hw - _livesText.width / 2 - _liveIconsContainer.width / 2 - 5;
			_livesText.y = h - 35;
			_liveIconsContainer.x = _livesText.x + _livesText.width + 10;
			_liveIconsContainer.y = _livesText.y + 12;
			
			_pauseButton.x = w - _pauseButton.width;
			_scoreText.x = hw - _scoreText.width / 2;
		}
		
		// -----------------------------
		// Game event handlers.
		// -----------------------------
		
		private function onFireReleaseTimerComplete( event:TimerEvent ):void
		{
			_fireReleased = true;
		}
		
		private function onInvaderHit( event:GameObjectEvent ):void
		{
			_soundLibrary.playSound( SoundLibrary.BOING );
			var blast:Blast = _blastPool.getGameObject() as Blast;
			blast.position = event.objectB.position;
			blast.velocity.z = event.objectA.velocity.z;
			blast.z -= GameSettings.invaderSizeZ;
		}
		
		private function onInvaderCreated( event:GameObjectEvent ):void
		{
			var invader:Invader = event.objectA as Invader;
			
			if( invader.invaderType == InvaderDefinitions.MOTHERSHIP )
				_soundLibrary.playSound( SoundLibrary.MOTHERSHIP );
		}
		
		private function onInvaderDead( event:GameObjectEvent ):void
		{
			var invader:Invader = event.objectA as Invader;
			
			// Check level update and update UI.
			_currentLevelKills++;
			_totalKills++;
			
			updateScore(_score + InvaderDefinitions.getScoreForInvaderType( invader.invaderType ));
			
			// Update highscore
			if( _score > _highScore ) {
				_highScore = _score;
				var sharedObject:SharedObject = SharedObject.getLocal( SO_NAME );
				sharedObject.data.highScore = _score;
				sharedObject.flush();
			}
			
			// Update level
			if( _currentLevelKills > GameSettings.killsToAdvanceDifficulty ) {
				_currentLevelKills = 0;
				_currentLevel++;
				_invaderPool.spawnTimeFactor -= GameSettings.spawnTimeDecreasePerLevel;
				
				if( _invaderPool.spawnTimeFactor < GameSettings.minimumSpawnTime )
					_invaderPool.spawnTimeFactor = GameSettings.minimumSpawnTime;
			}

			// Play sound
			if( invader.invaderType == InvaderDefinitions.MOTHERSHIP )
				_soundLibrary.playSound( SoundLibrary.EXPLOSION_STRONG );
			else
				_soundLibrary.playSound( SoundLibrary.INVADER_DEATH );

			// Show invader destruction
			var hitter:Projectile = event.objectB as Projectile;
			var intensity:Number = GameSettings.deathExplosionIntensity * MathUtils.rand( 1, 4 );
			var positions:Vector.<Point> = invader.cellPositions;
			var len:uint = positions.length;
			var sc:Number = invader.scaleX;
			for( var i:uint; i < len; ++i ) {
				var cell:InvaderCell = _cellPool.getGameObject() as InvaderCell;
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
			
			updateLives(_lives - 1);
			
			//game over
			if( _lives <= 0 ) {
				_goScoreText.text =     "SCORE................................... " + uintToString( _score );
				_goHighScoreText = _gameOverPopUp.highScoreText;
				_goHighScoreText.text = "HIGH-SCORE.............................. " + uintToString( _highScore );
				_goScoreText.width = int(_goScoreText.textWidth * 1.05);
				_goScoreText.x = -int(_goScoreText.width / 2);
				_goHighScoreText.width = int(_goHighScoreText.textWidth * 1.05);
				_goHighScoreText.x = -int(_goHighScoreText.width / 2);
				showPopUp( _gameOverPopUp );
				stopGame();
			}
		}
		
		private function onInvaderFire( event:GameObjectEvent ):void
		{
			var invader:Invader = event.objectA as Invader;
			var projectile:Projectile = _invaderProjectilePool.getGameObject() as Projectile;
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
		
		private function showMouse():void
		{
			if( _showingMouse )
				return;
			
			Mouse.show();
			
			_showingMouse = true;
		}
		
		private function hideMouse():void
		{
			if( !_showingMouse )
				return;
			
			Mouse.hide();
			
			_showingMouse = false;
		}
		
		private function onResume( event:MouseEvent ):void
		{
			_firstAccY = 0;
			hideMouse();
			hidePopUp();
			
			_invaderPool.resume();
			_active = true;
			_player.visible = true;
		}
		
		private function onPause( event:MouseEvent ):void
		{
			stopGame();
			showPopUp( _pausePopUp );
		}
		
		private function onRestart( event:MouseEvent ):void
		{
			startGame();
		}
		
		private function onPlay( event:MouseEvent ):void
		{
			startGame();
			hidePopUp();
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
		
		private function onMouseDown( event:MouseEvent ):void
		{
			switch(event.target){
				case _playButton:
				case _restartButton:
				case _pauseButton:
				case _playAgainButton:
				case _resumeButton:
					SoundLibrary.getInstance().playSound( SoundLibrary.UFO );
					break;
				default:
					_isFiring = true;
					break;
			}
		}

		private function onMouseUp( event:MouseEvent ):void
		{
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