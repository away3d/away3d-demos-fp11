/*

AWD file loading example in Away3d

Demonstrates:

How to use the Loader3D object to load an embedded internal awd model.
How to create character interaction
How to set custom material on a model.

Code by Rob Bateman and LoTh
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
3dflashlo@gmail.com
http://3dflashlo.wordpress.com

Model and Map by LoTH
3dflashlo@gmail.com
http://3dflashlo.wordpress.com

This code is distributed under the MIT License

Copyright (c)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

 */
package
{
    import away3d.animators.data.Skeleton;
    import away3d.animators.SkeletonAnimator;
    import away3d.animators.SkeletonAnimationSet;
    import away3d.animators.nodes.SkeletonClipNode;
    import away3d.animators.transitions.CrossfadeTransition;
    
    import away3d.loaders.parsers.AWD2Parser;
    import away3d.cameras.lenses.*;
    import away3d.containers.*;
    import away3d.controllers.*;
    import away3d.core.base.*;
    import away3d.debug.*;
    import away3d.entities.*;
    import away3d.events.*;
    import away3d.library.assets.*;
    import away3d.lights.*;
    import away3d.lights.shadowmaps.*;
    import away3d.loaders.*;
    import away3d.materials.*;
    import away3d.materials.lightpickers.StaticLightPicker;
    import away3d.materials.methods.*;
    import away3d.primitives.*;
    import away3d.textures.*;
    import away3d.utils.*;
    
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.text.*;
    import flash.ui.*;

    import utils.VectorSkyEffects;
    //import utils.Terrain;


    [SWF(backgroundColor="#333338", frameRate="60", quality="LOW")]
    public class Intermediate_Onkba_FPS extends Sprite
	{
    	//signature swf
    	[Embed(source="/../embeds/signature.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
        
        private static const SCALE:int = 1;

		private var assetsRoot:String = "assets/onkba/";
		private var textureStrings:Vector.<String>;
        private var textureBitmapData:Vector.<BitmapData>;
		private var n:uint = 0;

        private var sunColor:uint = 0xAAAAA9;
		private var sunAmbient:Number = 0.5;
		private var sunDiffuse:Number = 0.0;
		private var sunSpecular:Number = 1.3;
		private var skyColor:uint = 0x333338;
		private var skyAmbient:Number = 0.1;
		private var skyDiffuse:Number = 0.0;
		private var skySpecular:Number = 1.3//0.5;
		private var fogColor:uint = 0x333338;
		private var zenithColor:uint = 0x445465;
		private var fogNear:Number = 1000;
		private var fogFar:Number = 128 * 32 * 2;
        
        //engine variables
        private var _view:View3D;
        private var _stats:AwayStats;
		private var _signature:Sprite;
        private var _lightPicker:StaticLightPicker;
        private var _cameraController:HoverController;

		//light variables
		private var _sunLight:DirectionalLight;
		private var _skyLight:PointLight;
        private var _skyProbe:LightProbe;
        private var _sky:SkyBox;
        
        private var _fogMethode:FogMethod;
        private var _specularMethod:FresnelSpecularMethod;
        private var _shadowMethod:NearShadowMapMethod;
        private var _rimLightMethod:RimLightMethod;
        // Sky
        private var _skyMap:BitmapCubeTexture;
        
        //Materials
        private var _materials:Vector.<TextureMaterial>;
        private var _groundMaterial:TextureMaterial;
        private var _heroMaterial:TextureMaterial;
		private var _gunMaterial:TextureMaterial;
        private var _eyesClosedMaterial:TextureMaterial;
        private var _eyesOpenMaterial:TextureMaterial;
        
        // Terrain utils
        //private var _terrain:Terrain;
        private var ground:Mesh;

        //animation variables
        private var transition:CrossfadeTransition = new CrossfadeTransition(0.3);
        private var animator:SkeletonAnimator;
        private var animationSet:SkeletonAnimationSet;
        private var currentRotationInc:Number=0;
        private var movementDirection:Number;
       
        private var currentAnim:String;
        private var currentWeapon:int = 0;
        
        private const WEAPON:Array = ['', 'Gun', 'Machine', 'Sniper', 'Gatling', 'Bazooka']
        private const AMMO:Array = ['', '', '', '', '', 'Rocket']
        private const ANIMATION:Array = ['Idle', 'Walk', 'WalkL', 'WalkR', 'Run', 'CrouchIdle', 'CrouchWalk', 'Reload', 'WaterIdle', 'WaterSwim', 'StandBack', 'StandFace', 'JumpDown'];
        
        //animation 
        private const ANIM_BREATHE:String = "Idle";
        private const ANIM_WALK:String = "Walk";
        private const ANIM_RUN:String = "Run";
        
        private const ROTATION_SPEED:Number = 3;
        private const RUN_SPEED:Number = 1;
        private const WALK_SPEED:Number = 1;
        private const BREATHE_SPEED:Number = 0.7;
        private const RELOAD_SPEED:Number = 1;
        
        private var isCrouch:Boolean = false;
        private var isRunning:Boolean;
        private var isMoving:Boolean;
        
        //scene objects
        private var _hero:Mesh;
		private var _heroPieces:ObjectContainer3D;
        private var _heroWeapon:Mesh;
        private var _weapons:Vector.<Mesh>;
        private var _bonesVector:Vector.<Mesh>;
        
        //advanced eye
        private var _eyePosition:Vector3D; 
        private var _eyes:ObjectContainer3D;
        private var _eyeLook:Mesh;
        private var _eyeL:Mesh;
        private var _eyeR:Mesh;
        private var _eyeCount:int;
        
        //navigation
        private var _prevMouseX:Number;
        private var _prevMouseY:Number;
        private var _mouseMove:Boolean;
        private var _cameraHeight:Number = 50;
        
        private var _isResize:Boolean;
        private var _cloneActif:Boolean;
        private var _dynamicsEyes:Boolean;
        private var _debugRay:Boolean;
        
        private var _text:TextField;
        
        /**
         * Constructor
         */
        public function Intermediate_Onkba_FPS()
		{
            textureBitmapData = new Vector.<BitmapData>();
            textureStrings = new Vector.<String>();
            // terrain map
            textureStrings.push("rock.jpg", "arid.jpg", "sand.jpg");
            // hero map
            textureStrings.push("onkba_diffuse.png", "onkba_normals.jpg", "onkba_lightmap.jpg");
            // gun map
            textureStrings.push("gun_diffuse.jpg", "gun_normals.jpg", "gun_lightmap.jpg");
        
            init();
        }
        
        /**
         * Global initialise function
         */
        private function init():void
		{
            initEngine();
            initText();
            initLights();
			initListeners();

			// kickoff asset loading
			load(textureStrings[n]);
        }
        
        /**
         * Initialise the engine
         */
        private function initEngine():void
		{
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			//create the view
            _view = new View3D();
			_view.forceMouseMove = true;
            _view.backgroundColor = skyColor;
            _view.antiAlias = 4;
            addChild(_view);
            
			//create custom lens
            _view.camera.lens = new PerspectiveLens(60);
            _view.camera.lens.far = fogFar;
            _view.camera.lens.near = 1;
            
			//setup controller to be used on the camera
            _cameraController = new HoverController(_view.camera, null, 180, 0, 100, 10, 90);
            _cameraController.tiltAngle = 0;
            _cameraController.panAngle = 180;
            _cameraController.minTiltAngle = -60;
            _cameraController.maxTiltAngle = 60;
            _cameraController.autoUpdate = false;
            
            //add signature
			addChild(_signature = new SignatureSwf());
            _signature.y = stage.stageHeight - _signature.height;
            _signature.x = 10;
            
            //add stats
            addChild(_stats = new AwayStats(_view, false, true));
            _stats.x = stage.stageWidth - _stats.width - 5;
            _stats.alpha = 0.5;
            _stats.y = 2;
        }
        
        
		/**
         * Create an instructions overlay
         */
        private function initText():void
		{
            _text = new TextField();
            _text.defaultTextFormat = new TextFormat("Verdana", 11, 0xFFFFFF);
			/*_text.embedFonts = true;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.gridFitType = GridFitType.PIXEL;*/
            _text.width = 300;
            _text.height = 250;
            _text.selectable = false;
            _text.mouseEnabled = true;
            _text.wordWrap = true;
            _text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
            addChild(_text);
        }
        
        //-------------------------------------------------------LIGHT
        
        /**
         * Initialise the lights
         */
        private function initLights():void
		{
            //create a light for shadows that mimics the sun's position in the skybox
            _sunLight = new DirectionalLight(-0.5, -1, 0.3);
            _sunLight.color = sunColor;
            _sunLight.ambientColor = sunColor;
            _sunLight.ambient = sunAmbient;
            _sunLight.diffuse = sunDiffuse;
            _sunLight.specular = sunSpecular;
            
            _sunLight.castsShadows = true;
            _sunLight.shadowMapper = new NearDirectionalShadowMapper(.1);
            _view.scene.addChild(_sunLight);
            
            //create a light for ambient effect that mimics the sky
            _skyLight = new PointLight();
            _skyLight.color = zenithColor//skyColor;
            _skyLight.ambientColor = zenithColor//skyColor;
            _skyLight.ambient = skyAmbient;
            _skyLight.diffuse = skyDiffuse;
            _skyLight.specular = skySpecular;
            _skyLight.y = 300;
            _skyLight.x = -300;
            _skyLight.z = 500;
            
            _skyLight.radius = 1000;
            _skyLight.fallOff = 2500;
            _view.scene.addChild(_skyLight);
            
			//generate cube texture for sky and probe
            _skyMap = VectorSkyEffects.vectorSky(zenithColor, fogColor, fogColor, 8);
            
            _skyProbe = new LightProbe(_skyMap);
            _view.scene.addChild(_skyProbe);
            
            //create light picker for materials
            _lightPicker = new StaticLightPicker([_sunLight, _skyLight, _skyProbe]);
        }
        
        
        //-------------------------------------------------------SKY
        
        /** 
         * Genarate random sky 
         */
        private function randomSky():void {
            zenithColor = 0xFFFFFF * Math.random();
            fogColor = 0xFFFFFF * Math.random();
            
            _skyMap = VectorSkyEffects.vectorSky(zenithColor, fogColor, fogColor, 8);
            _fogMethode.fogColor = fogColor;
            _skyProbe.diffuseMap = _skyMap;
            _sky.dispose();
            _sky = new SkyBox(_skyMap);
            _view.scene.addChild(_sky);
            
            // test rim Light methode slow down engine
            for (var i:int=0; i < _materials.length; i++ ) {
                _materials[i].removeMethod(_rimLightMethod);
            }
            
            _rimLightMethod = new RimLightMethod(zenithColor, 0.5, 2.5, RimLightMethod.ADD);
            
            for ( i = 0; i < _materials.length; i++ ) {
                _materials[i].addMethod(_rimLightMethod);
            }
        }
        
        
        //-------------------------------------------------------MATERIALS
        
        /**
         * Initialise the scene materials
         */
        private function initMaterials():void
		{
            _materials = new Vector.<TextureMaterial>();
            
			//create gobal specular method
			_specularMethod = new FresnelSpecularMethod();
            _specularMethod.normalReflectance = 0.6;
            
			//create global shadow method
            _shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
            _shadowMethod.epsilon = .0007;
            
            //create Rim light method
            _rimLightMethod = new RimLightMethod(zenithColor, 0.5, 2, RimLightMethod.ADD);
            
            
            //create global fog method
            _fogMethode = new FogMethod(fogNear, fogFar, fogColor);
            
			//create the hero material
            _heroMaterial = new TextureMaterial(Cast.bitmapTexture(textureBitmapData[3]));
			_heroMaterial.normalMap = Cast.bitmapTexture(textureBitmapData[4]);
            
            _heroMaterial.addMethod(new LightMapMethod(Cast.bitmapTexture(textureBitmapData[5])));
            _heroMaterial.gloss = 10;
            _heroMaterial.specular = 0.6;
            _heroMaterial.bothSides = false;
            _heroMaterial.alphaThreshold = 0.9;
            _heroMaterial.alphaPremultiplied = true;
            _materials[0] = _heroMaterial;
            
			//create the gun material
            _gunMaterial = new TextureMaterial(Cast.bitmapTexture(textureBitmapData[6]));
			_gunMaterial.normalMap = Cast.bitmapTexture(textureBitmapData[7]);
            _gunMaterial.addMethod(new LightMapMethod(Cast.bitmapTexture(textureBitmapData[8])));
			_gunMaterial.lightPicker = _lightPicker;
			_gunMaterial.gloss = 16;
            _gunMaterial.specular = 0.6;
            
            _materials[1] = _gunMaterial;
            // create eye ball close material
            var b:BitmapData;
            b = new BitmapData(64, 64, false, 0xA13D1E);
            _eyesClosedMaterial = new TextureMaterial(Cast.bitmapTexture(b));
            _eyesClosedMaterial.gloss = 12;
            _eyesClosedMaterial.specular = 0.6;
            _materials[2] = _eyesClosedMaterial;
            
            // create eye ball open material
            b = new BitmapData(256/2, 256/2, false);
            b.draw(textureBitmapData[3], new Matrix(1, 0, 0, 1, -283/2, -197/2));
            _eyesOpenMaterial = new TextureMaterial(Cast.bitmapTexture(b));
            _eyesOpenMaterial.addMethod(new EnvMapMethod(_skyMap, 0.5));
            _eyesOpenMaterial.gloss = 300;
            _eyesOpenMaterial.specular = 5;
            _eyesOpenMaterial.repeat = true;
            _materials[3] = _eyesOpenMaterial;
            
            // create ground texture
            _groundMaterial = new TextureMaterial(Cast.bitmapTexture(textureBitmapData[1]));
            _groundMaterial.gloss = 10;
            _groundMaterial.specular = 0.1;
            _groundMaterial.addMethod(_fogMethode);
            _groundMaterial.repeat = true;
            _materials[4] = _groundMaterial;
            
            
            // apply light and effect for all material
            for (var i:int; i < _materials.length; i++ ) {
                _materials[i].lightPicker = _lightPicker;
                _materials[i].diffuseLightSources = LightSources.PROBES;
                _materials[i].specularLightSources = LightSources.LIGHTS;
                _materials[i].shadowMethod = _shadowMethod;
                _materials[i].ambient = 0.85;
                _materials[i].addMethod(_rimLightMethod);
                // _materials[i].specularMethod = _specularMethod;
            }
		}
        
        
        //-------------------------------------------------------3D OBJECTS
        
        /**
         * Initialise the scene objects
         */
        private function initObjects():void
		{
			//create skybox
            _sky = new SkyBox(_skyMap);
            _view.scene.addChild(_sky);
            
            // optional terrain
            /*_terrain = new Terrain({b0:textureBitmapData[0], b1:textureBitmapData[1], b2:textureBitmapData[2], repeat:60});
            _view.scene.addChild(Terrain.ground);
			_view.scene.addChild(Terrain.water);
            Terrain.terrainMaterial.lightPicker = _lightPicker;
            Terrain.waterMaterial.lightPicker = _lightPicker;
            Terrain.terrainMaterial.addMethod(_fogMethode);
            Terrain.waterMaterial.addMethod(_fogMethode);
            Terrain.terrainMaterial.shadowMethod = _shadowMethod;
            Terrain.waterMaterial.shadowMethod = _shadowMethod;
            
            Terrain.terrainMaterial.diffuseLightSources = LightSources.PROBES;
            Terrain.terrainMaterial.specularLightSources = LightSources.LIGHTS;
            Terrain.terrainMaterial.ambient = 0.85;
            Terrain.waterMaterial.diffuseLightSources = LightSources.PROBES;
            Terrain.waterMaterial.specularLightSources = LightSources.LIGHTS;
            Terrain.waterMaterial.ambient = 0.85;
            
            _materials[4] = Terrain.terrainMaterial;
            _materials[5] = Terrain.waterMaterial;*/
            
            // Terrain.terrainMaterial.addMethod(_rimLightMethod);
            // Terrain.waterMaterial.addMethod(_rimLightMethod);
           
            // basic ground
            ground = new Mesh(new PlaneGeometry(fogFar*2, fogFar*2), _groundMaterial);
            ground.geometry.scaleUV(100, 100);
            ground.y = -3;
            ground.castsShadows = false;
            _view.scene.addChild(ground); 
            
            
            // weapon referency
            _weapons = new Vector.<Mesh>(WEAPON.length);
            
            // fake mesh if no weapon 
            _weapons[0] = new Mesh(new CubeGeometry(1,1,1), null);

			// Now load Onkba character and weapons
            load("onkba_fps.awd");
		}
        
        //-------------------------------------------------------GLOBAL LISTENERS
        
        /**
         * Initialise the listeners
         */
        private function initListeners():void
		{
            //add render loop
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            //add key listeners
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            
            //navigation
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseLeave);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
            stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
            
            //add resize event
            stage.addEventListener(Event.RESIZE, onResize);
        }
        
        
        //-------------------------------------------------------RENDER LOOP
        
        /**
         * Render loop
         */
        private function onEnterFrame(event:Event):void
		{
            // update character animation
            if (_hero) {
                _hero.rotationY += currentRotationInc;
				
                // update eyes
                if (_dynamicsEyes) updateEyes();
                // update bones
                if (_debugRay) updateBones();
                
                // get the hand bone for weapon
                if (animator.globalPose.numJointPoses >= 22) {
                    _heroWeapon.transform = animator.globalPose.jointPoses[22].toMatrix3D();
				}
                
                // update camera
                _cameraController.lookAtPosition = new Vector3D(_hero.x, _cameraHeight, _hero.z);
                _cameraController.update();
                
                //update light
               // _skyLight.position = _view.camera.position;
            }
            
            if (_isResize) {
                _view.width = stage.stageWidth;
                _view.height = stage.stageHeight;
                _stats.x = stage.stageWidth - _stats.width;
                _signature.y = stage.stageHeight - _signature.height;
                _isResize = false;
            }
            
            //update view
            _view.render();
        }
        
        
        //-------------------------------------------------------LOADING SIDE
        
        /**
         * Global binary file loader
         */
        private function load(url:String):void
		{
            var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;

            switch (url.substring(url.length - 3)) {
                case "AWD": 
                case "awd": 
                    loader.addEventListener(Event.COMPLETE, parseAWD, false, 0, true);
                    break;
                case "png": 
                case "jpg": 
                    loader.addEventListener(Event.COMPLETE, parseBitmap, false, 0, true);
                    break;
            }
            
            loader.addEventListener(ProgressEvent.PROGRESS, loadProgress, false, 0, true);
            loader.load(new URLRequest(assetsRoot + url));
        }
        
        /**
         * Display current load progress
         */
        private function loadProgress(e:ProgressEvent):void
		{
            var P:int = int(e.bytesLoaded / e.bytesTotal * 100);
            if (P != 100)
                log('Load : ' + P + ' % | ' + int((e.bytesLoaded / 1024) << 0) + ' ko\n');
            else {
	            _text.text = "Cursor keys / WSAD / ZSQD - move\n";
	            _text.appendText("SHIFT - hold down to run\n");
                _text.appendText("O - next weapon\n");
	            _text.appendText("R - reload weapon\n");
                _text.appendText("C - crouch\n");
	            _text.appendText("\n");
                _text.appendText("I - full screen\n");
	            _text.appendText("N - random sky\n");
                _text.appendText("P - xray bones\n");
	            _text.appendText("B - clone\n");
                
                
			}
        }
        
        /**
         * Bitmap find
         */
        private function parseBitmap(e:Event):void 
		{
            var urlLoader:URLLoader = e.target as URLLoader;
            var loader:Loader = new Loader();
            loader.loadBytes(urlLoader.data);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapComplete, false, 0, true);
            urlLoader.removeEventListener(Event.COMPLETE, parseBitmap);
            urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
        }
        
        private function onBitmapComplete(e:Event):void
		{
            var loader:Loader = LoaderInfo(e.target).loader;
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapComplete);
            textureBitmapData.push(e.target.content.bitmapData);
            loader.unload();
            loader = null;
            n++;
            
            if (n < textureStrings.length){
                // load next bitmap
                load(textureStrings[n]);
            } else {
                // Init material and objects
                initMaterials();
				initObjects();
            }
        }

        /**
         * AWD find
         */
        private function parseAWD(e:Event):void
		{
            var loader:URLLoader = e.target as URLLoader;
            var loader3d:Loader3D = new Loader3D(false);
            loader3d.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete, false, 0, true);
            loader3d.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete, false, 0, true);
            loader3d.loadData(loader.data, null, null, new AWD2Parser());
            loader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
            loader.removeEventListener(Event.COMPLETE, parseAWD);
            loader = null;
        }
        
        /**
         * Listener function for AWD asset complete event on loader
         */
        private function onAssetComplete(event:AssetEvent):void
		{
            if (event.asset.assetType == AssetType.SKELETON) {
                // Create a new skeleton animation set (! 3 joints per vertex for awd exporter in 3dsmax)
                animationSet = new SkeletonAnimationSet(3);
                // Wrap our skeleton animation set in an animator object and add our sequence objects
                animator = new SkeletonAnimator(animationSet, event.asset as Skeleton);
                
            } else if (event.asset.assetType == AssetType.ANIMATION_NODE) {
                //add each animation node to the animation set (! see sequenceFPS.txt in res)
                var animationNode:SkeletonClipNode = event.asset as SkeletonClipNode;
                animationSet.addAnimation(animationNode.name, animationNode);
                
                //play the default idle animation
                if (animationNode.name == ANIM_BREATHE) stop();
                
            } else if (event.asset.assetType == AssetType.MESH) {
                
                var mesh:Mesh = event.asset as Mesh;
                
                // Onkba character
                if (mesh.name == "Onkba") {
                    _hero = mesh;
                    _hero.material = _heroMaterial;
                    _hero.scale(SCALE);
                }
                
                // weapons resources
                for (var i:int = 0; i < WEAPON.length; i++ ) {
                    if (mesh.name == WEAPON[i] + 'Test') {
                        if (i == 3) {mesh.rotationY = -5; mesh.rotationZ = -2;}// decal for sniper
                        mesh.material = _gunMaterial;
                        _weapons[i] = mesh;
                    }
                }
            }
        }
        
        /**
         * Check if all resource loaded
         */
        private function onResourceComplete(e:LoaderEvent):void
		{
            var loader3d:Loader3D = e.target as Loader3D;
            loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
            loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
            
            //apply our animator to our mesh
            _hero.animator = animator;
            
            // add weapon container
            _heroWeapon = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0xff0000));
            
            _view.scene.addChild(_hero);
            _hero.addChild(_heroWeapon);
            
            _hero.y = 0// Terrain.getHeightAt();
            
            // Optional dynamic eyes ball
            addHeroEye();
        }
        
        //-------------------------------------------------------KEYBOARD FUNCTION
        
        /**
         * Weapons collection
         */
        private function switchWeapon():void
		{
            currentWeapon++;
            if (currentWeapon > 5) currentWeapon = 0;
            for (var i:int; i < _heroWeapon.numChildren; i++ ) {
                _heroWeapon.removeChild(_heroWeapon.getChildAt(i));
                }
            _heroWeapon.addChild(_weapons[currentWeapon]);
            // Play idle animation
            stop();
        }
        
        /**
         * Test some Clones
         */
        private function makeClone(n:int=20):void {
            if (!_cloneActif) {
                _cloneActif = true;
                var g:Mesh;
                var decal:int = -(n * 100) / 2;
                for (var j:int = 1; j < n; j++) {
                    for (var i:int = 1; i < n; i++) {
                        g = Mesh(_hero.clone());
                        g.x = decal + (100 * i);
                        g.z = (decal + (100 * j));
                        if (g.x != 0 || g.z != 0)
                            _view.scene.addChild(g);
                    }
                }
            }
        }
        
        //-------------------------------------------------------CHARACTER ANIMATION
        
        /**
         * Character breath animation
         */
        private function stop():void
		{
            isMoving = false;
            animator.playbackSpeed = BREATHE_SPEED;
            if (isCrouch) currentAnim = WEAPON[currentWeapon] + ANIMATION[5];
            else currentAnim = WEAPON[currentWeapon] + ANIMATION[0];
            animator.play(currentAnim, transition);
        }
        
        /**
         * Character Mouvement
         */
        private function updateMovement(dir:Number):void
		{
            isMoving = true;

            //update animator sequence
            var anim:String = isRunning ? ANIM_RUN : ANIM_WALK;

            if (currentAnim == anim)
                return;

            animator.playbackSpeed = dir * (isRunning ? RUN_SPEED : WALK_SPEED);
            if (isCrouch) currentAnim = WEAPON[currentWeapon] + ANIMATION[6];
            else currentAnim = WEAPON[currentWeapon] + anim;
            animator.play(currentAnim, transition);
        }
        
        /**
         * Character Mouvement side
         */
        private function updateMovementSide(dir:Number):void
		{
            isMoving = true;
            var anim:String;
            
            if (dir > 0) anim = 'WalkL';
            else anim = 'WalkR';
            
            if (isCrouch) return
            else currentAnim = WEAPON[currentWeapon] + anim;
            animator.play(currentAnim, transition);
        }
        
        
        /**
         * Character reload animation
         */
        private function reload():void
		{
            var anim:String;
            if (isCrouch) anim = WEAPON[currentWeapon] + 'CrouchReload';
            else anim = WEAPON[currentWeapon] + 'Reload';
            
            if (currentAnim == anim)  return;
            
            currentAnim = anim;
            animator.playbackSpeed = RELOAD_SPEED;
            animator.play(currentAnim, transition);
            //animator.
           // animator.phase(1);
           // animator.skeleton.addEventListener(
           //animator.addEventListener(AnimatorEvent.STOP, animationTest)
         //   animator.skeleton.l
          //  this.addEventListener(Event.ENTER_FRAME, animationTest);
        }
       
        /**
         * only one animation
         */
        private function animationTest(e:Event):void
		{
          //  log('grr'+animator.getAnimationState(animator.activeAnimation))
           // if (animator.time > 7000) { 
          //      this.removeEventListener(Event.ENTER_FRAME, animationTest);
                stop();
         //   }
        }
        
        
        //--------------------------------------------------------------------- KEYBORD
        
        /**
         * Key down listener for animation
         */
        private function onKeyDown(event:KeyboardEvent):void
		{
            switch (event.keyCode) {
                case Keyboard.SHIFT: 
                    isRunning = true;
                    if (isMoving)
                        updateMovement(movementDirection);
                    break;
                case Keyboard.UP: 
                case Keyboard.W: 
                case Keyboard.Z: //fr
                    updateMovement(movementDirection = 1);
                    break;
                case Keyboard.DOWN: 
                case Keyboard.S: 
                    updateMovement(movementDirection = -1);
                    break;
                case Keyboard.LEFT: 
                case Keyboard.A: 
                case Keyboard.Q: //fr
                    //currentRotationInc = -ROTATION_SPEED;
                    updateMovementSide(1);
                    break;
                case Keyboard.RIGHT: 
                case Keyboard.D: 
                   // currentRotationInc = ROTATION_SPEED;
                    updateMovementSide(-1);
                    break;
                case Keyboard.R: 
                    reload();
                    break;
                case Keyboard.B: 
                    makeClone();
                    break;
                case Keyboard.N: 
                    randomSky();
                    break;
                case Keyboard.P: 
                    xRay();
                    break;
                case Keyboard.O: 
                   switchWeapon();
                    break;
                case Keyboard.I: 
                   fullScreen();
                    break;
                case Keyboard.C: 
                    if (isCrouch) { isCrouch = false; _cameraHeight = 50; }
                    else {isCrouch = true; _cameraHeight = 25;}
                     stop();
                    break;
            }
        }
        
        /**
         * Key up listener
         */
        private function onKeyUp(event:KeyboardEvent):void
		{
            switch (event.keyCode) {
                case Keyboard.SHIFT: 
                    isRunning = false;
                    if (isMoving)
                        updateMovement(movementDirection);
                    break;
                case Keyboard.UP: 
                case Keyboard.W: 
                case Keyboard.Z: //fr
                case Keyboard.DOWN: 
                case Keyboard.S:
                    stop();
                    break;
                case Keyboard.LEFT: 
                case Keyboard.A: 
                case Keyboard.Q: //fr
                case Keyboard.RIGHT: 
                case Keyboard.D: 
                    currentRotationInc = 0;
                    stop();
                    break;
            }
        }
        
        //--------------------------------------------------------------------- OTHER
        
        /**
         * stage full screen
         */
        private function fullScreen(e:Event=null):void {
            if (stage.displayState == StageDisplayState.NORMAL) {
                if(stage.allowsFullScreenInteractive)
                stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
                else stage.displayState = StageDisplayState.FULL_SCREEN;
            } else {
                stage.displayState = StageDisplayState.NORMAL;
            }
        }
        
        /**
         * stage listener and mouse control
         */
        private function onResize(event:Event=null):void
		{
            _isResize = true;
        }
        
        private function onStageMouseDown(e:MouseEvent):void
		{
            _prevMouseX = e.stageX;
            _prevMouseY = e.stageY;
            _mouseMove = true;
        }
        
        private function onStageMouseLeave(e:Event):void
		{
            _mouseMove = false;
        }
        
        private function onStageMouseMove(e:MouseEvent):void
		{
            if (_mouseMove) {
                _cameraController.panAngle += (e.stageX - _prevMouseX);
                _cameraController.tiltAngle += (e.stageY - _prevMouseY);
            }
            _prevMouseX = e.stageX;
            _prevMouseY = e.stageY;
        }
        
        /**
         * mouseWheel listener
         */
        private function onStageMouseWheel(e:MouseEvent):void
		{
            _cameraController.distance -= e.delta * 5;

			//_cameraHeight = (_cameraController.distance < 50)? (50 - _cameraController.distance)/2 : 0;

            if (_cameraController.distance < 50)
                _cameraController.distance = 50;
            else if (_cameraController.distance > 2000)
                _cameraController.distance = 2000;
        }
        
        /**
         * mesh listener for mouse over interaction
         */
        private function onMeshMouseOver(e:MouseEvent3D):void
		{
            e.target.showBounds = true;
            _eyeLook.visible = true;
            onMeshMouseMove(e);
        }
        
        /**
         * mesh listener for mouse out interaction
         */
        private function onMeshMouseOut(e:MouseEvent3D):void
		{
            e.target.showBounds = false;
            _eyeLook.visible = false;
            _eyeLook.position = _eyePosition;
        }
        
        /**
         * mesh listener for mouse move interaction
         */
        private function onMeshMouseMove(e:MouseEvent3D):void
		{
            _eyeLook.position = new Vector3D(e.localPosition.z + 6, e.localPosition.x, e.localPosition.y + 10);
        }

        /**
         * log for display info
         */
        private function log(t:String):void
		{
            _text.htmlText = t;
        }
        
        
        //--------------------------------------------------------------------- DYNAMIC EYES BALL
        
        public function addHeroEye():void
		{
            var eyeGeometry:Geometry = new SphereGeometry(1, 32, 24);
			eyeGeometry.scaleUV(2, 1);
            
			_heroPieces = new ObjectContainer3D();
			_view.scene.addChild(_heroPieces);
            
			_eyes = new ObjectContainer3D();
            _eyeR = new Mesh(eyeGeometry, _eyesOpenMaterial);
            _eyeR.castsShadows = false;
            _eyes.addChild(_eyeR);
            _eyeL = new Mesh(eyeGeometry, _eyesOpenMaterial);
			_eyeL.castsShadows = false;
            _eyes.addChild(_eyeL);
            _eyeR.z = _eyeL.z = 3.9;
            _eyeR.x = _eyeL.x = 5.6;
            _eyeR.y = 1.75;
            _eyeL.y = -1.75;
            _heroPieces.addChild(_eyes);
            _eyeLook = new Mesh(new PlaneGeometry(0.3, 0.3, 1, 1), new ColorMaterial(0xFFFFFF, 1));
            _eyeLook.rotationX = 90;
            _eyeLook.visible = false;
            var h:ColorMaterial = new ColorMaterial(0xFFFFFF, 1);
            var zone:Mesh = new Mesh(new PlaneGeometry(12, 6, 1, 1), h);
            zone.castsShadows = false;
            zone.material.blendMode = BlendMode.MULTIPLY;
            zone.addEventListener(MouseEvent3D.MOUSE_MOVE, onMeshMouseMove);
            zone.addEventListener(MouseEvent3D.MOUSE_OVER, onMeshMouseOver);
            zone.addEventListener(MouseEvent3D.MOUSE_OUT, onMeshMouseOut);
            zone.mouseEnabled = true;
            zone.rotationX = 90;
            zone.rotationZ = 90;
            zone.z = 10;
            zone.x = 6;
            zone.y = 0.22;
            _eyeLook.z = 10.2;
            _eyeLook.x = 6;
            _eyeLook.y = 0.22;
            _eyePosition = _eyeLook.position;
            _eyes.addChild(zone);
            _eyes.addChild(_eyeLook);
            
            _dynamicsEyes = true;
        }
        
        private function updateEyes():void
		{
            _heroPieces.transform = _hero.transform;
            // get the head bone
            if (animator.globalPose.numJointPoses >= 11) {
                _eyes.transform = animator.globalPose.jointPoses[11].toMatrix3D();
            }
            // look 
            _eyeR.lookAt(_eyeLook.position.add(new Vector3D(0, 1.4, 0)), new Vector3D(0, 1, 1));
            _eyeL.lookAt(_eyeLook.position.add(new Vector3D(0, -1.4, 0)), new Vector3D(0, 1, 1));
                
            // open close eye	
            _eyeCount++;
            if (_eyeCount > 300) {
		        _eyeR.material = _eyesClosedMaterial;
		        _eyeL.material = _eyesClosedMaterial;
            }
            if (_eyeCount > 309) {
		        _eyeR.material = _eyesOpenMaterial;
		        _eyeL.material = _eyesOpenMaterial;
		        _eyeCount = 0;
            }
        }
        
        
        //-------------------------------------------------------SEE BONES
        
        private function xRay():void 
        {
            var m:Mesh;
            var j:Sprite3D;
            if (!_debugRay) {
                _debugRay = true;
                _heroMaterial.alpha = 0.5;
                var material:ColorMaterial =  new ColorMaterial(0x00ff00);
                material.lightPicker = _lightPicker;
                _bonesVector = new Vector.<Mesh>(animator.globalPose.numJointPoses);
                var mref0:Mesh = new Mesh(new CubeGeometry(3, 0.3, 0.3), material);
                var mref:Mesh = new Mesh(new CubeGeometry(0.7,0.7,0.7), material);
                mref.addChild(mref0); mref0.x = 1.5;
                for (var i:int = 0; i <animator.globalPose.numJointPoses; i++) {
                    m = Mesh(mref.clone());
                    j =  new Sprite3D(materialBones( "bone " + i ), 4, 4);
                    _hero.addChild(m);
                    m.addChild(j);
                    _bonesVector[i] = m;
                }
            } else { 
                _debugRay = false;
                _heroMaterial.alpha = 1;
                for ( i = 0; i <_bonesVector.length; i++) {
                    m = _bonesVector[i];
                    _hero.removeChild(m);
                    m.dispose();
                    _bonesVector[i] = null;
                }
            }
        }
        
        private function materialBones(name:String = 'bone'):TextureMaterial 
        {
            var material:TextureMaterial;
            var g:BitmapData = new BitmapData(128, 128, true, 0x00000000);
            var d:Sprite = new Sprite();
            var txt:TextField = new TextField();
            txt.defaultTextFormat = new TextFormat("Verdana", 30, 0x00FF00);
            txt.width = 128;
            txt.height = 128;
            txt.selectable = false;
            txt.mouseEnabled = false;
            txt.wordWrap = true;
            txt.filters = [new DropShadowFilter(1, 45, 0x000000, 1, 4, 4,2,2)];
            d.addChild(txt);
            txt.htmlText = name;
            g.draw(d);
            material = new TextureMaterial(Cast.bitmapTexture(g));
            material.alphaBlending = true;
            return material;
        }
        
        private function updateBones():void
        {
            for (var i:int = 0; i <animator.globalPose.numJointPoses; i++) {
                _bonesVector[i].transform = animator.globalPose.jointPoses[i].toMatrix3D();
            }
        }
        
        
    }
}