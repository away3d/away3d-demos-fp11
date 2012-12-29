package games {
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import away3d.tools.helpers.data.ParticleGeometryTransform;
	import away3d.materials.TextureMaterial;
	import away3d.core.base.Object3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.ParticleGeometry;
	import away3d.containers.Scene3D;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.animators.nodes.ParticleBillboardNode;
	// import away3d.animators.nodes.ParticleColorNode;
	import away3d.animators.nodes.ParticleFollowNode;
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.data.ParticleProperties;

	// import flash.geom.ColorTransform;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Vector3D;
	import flash.display.BlendMode;
	import flash.geom.Matrix;

	/**
	 * @author lo-th
	 */
	public class Particules {
		private static var Singleton : Particules;
		private static var _scale : Number;
		private static var _scene : Scene3D;
		private static var _position : Vector3D;
		// particle variables
		private static var _particleAnimationSet : ParticleAnimationSet;
		private static var _particleGeometry : ParticleGeometry;
		private static var _particleFollowNode : ParticleFollowNode;
		private static var _particleMesh : Mesh;
		private static var _particleAnimator : ParticleAnimator;
		private static var _particleMesh1 : Mesh;
		private static var _particleMesh2 : Mesh;
		private static var _animator1 : ParticleAnimator;
		private static var _animator2 : ParticleAnimator;
		private static var _followTarget1 : Object3D;
		private static var _followTarget2 : Object3D;

		/**
		 * Singleton enforcer
		 */
		public static function getInstance() : Particules {
			if (Singleton == null) {
				Singleton = new Particules();
			}
			return Singleton;
		}

		/**
		 * Get player position
		 */
		public static function get position() : Vector3D {
			return _position;
		}

		public static function get followTarget1() : Object3D {
			return _followTarget1;
		}

		public static function get followTarget2() : Object3D {
			return _followTarget2;
		}

		/**
		 * Set the player position
		 */
		static public function set position(v : Vector3D) : void {
			_position = v;
			// _player.position = _position;
		}

		/**
		 * Set the away3d scene
		 */
		static public function set scene(Scene : Scene3D) : void {
			_scene = Scene;
		}

		/**
		 * Set the player scale
		 */
		static public function set scale(s : Number) : void {
			_scale = s;
			// _player.scale(_scale);
		}

		/**
		 * Initialise Player content
		 */
		public static function initParticulesBase(n : uint = 2000) : void {
			// setup the particle geometry
			var plane : Geometry = new PlaneGeometry(10, 10, 1, 1, false);
			var geometrySet : Vector.<Geometry> = new Vector.<Geometry>();
			for (var i : int = 0; i < n; i++) geometrySet.push(plane);

			// setup the particle animation set
			_particleAnimationSet = new ParticleAnimationSet(true, true);
			_particleAnimationSet.addAnimation(new ParticleBillboardNode());
			_particleAnimationSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));
			_particleAnimationSet.initParticleFunc = initParticleFunc;

			// setup the particle material
			var material : TextureMaterial = new TextureMaterial(Cast.bitmapTexture(createSpote()));
			material.blendMode = BlendMode.ADD;

			// setup the particle animator and mesh
			_particleAnimator = new ParticleAnimator(_particleAnimationSet);
			_particleMesh = new Mesh(ParticleGeometryHelper.generateGeometry(geometrySet), material);
			_particleMesh.animator = _particleAnimator;
			_scene.addChild(_particleMesh);

			// start the animation
			_particleAnimator.start();
		}

		/**
		 * Initialise the particles
		 */
		public static function initParticlesTrail(c1 : uint = 0xff0000, c2 : uint = 0xff9000) : void {
			// setup the base geometry for one particle
			var plane : Geometry = new PlaneGeometry(25, 25, 1, 1, false);

			// create the particle geometry
			var geometrySet : Vector.<Geometry> = new Vector.<Geometry>();
			var setTransforms : Vector.<ParticleGeometryTransform> = new Vector.<ParticleGeometryTransform>();
			var particleTransform : ParticleGeometryTransform;
			// var uvTransform : Matrix;
			for (var i : int = 0; i < 300; i++) {
				geometrySet.push(plane);
				particleTransform = new ParticleGeometryTransform();
				/*uvTransform = new Matrix();
				uvTransform.scale(0.5, 0.5);
				uvTransform.translate(int(Math.random() * 2) / 2, int(Math.random() * 2) / 2);
				particleTransform.UVTransform = uvTransform;*/
				setTransforms.push(particleTransform);
			}

			_particleGeometry = ParticleGeometryHelper.generateGeometry(geometrySet, setTransforms);

			// create the particle animation set
			_particleAnimationSet = new ParticleAnimationSet(true, true, true);

			// define the particle animations and init function
			_particleAnimationSet.addAnimation(new ParticleBillboardNode());
			_particleAnimationSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));
			// _particleAnimationSet.addAnimation(new ParticleColorNode(ParticlePropertiesMode.GLOBAL, true, false, false, false, new ColorTransform(), new ColorTransform(1, 1, 1, 0)));
			// _particleAnimationSet.addAnimation(_particleFollowNode = new ParticleFollowNode(true, false));
			_particleAnimationSet.addAnimation(_particleFollowNode = new ParticleFollowNode(true, false));
			_particleAnimationSet.initParticleFunc = initParticleFollowFunc;

			// setup the particle material
			var material01 : TextureMaterial = new TextureMaterial(Cast.bitmapTexture(createSpote(c1)));
			material01.alphaBlending = true;
			// material01.blendMode = BlendMode.ADD;
			// material01.blendMode = BlendMode.;
			var material02 : TextureMaterial = new TextureMaterial(Cast.bitmapTexture(createSpote(c2)));
			material02.alphaBlending = true;
			// material02.blendMode = BlendMode.ADD;
			// material02.blendMode = BlendMode.OVERLAY;
			// create follow targets
			_followTarget1 = new Object3D();
			_followTarget2 = new Object3D();

			// create the particle meshes
			_particleMesh1 = new Mesh(_particleGeometry, material01);
			_particleMesh1.x = 100;
			_scene.addChild(_particleMesh1);

			// _particleMesh2 = _particleMesh1.clone() as Mesh;
			_particleMesh2 = new Mesh(_particleGeometry, material02);
			// _particleMesh2.material = material02;
			_particleMesh2.x = 100;
			// _particleMesh2.y = 100;
			_scene.addChild(_particleMesh2);

			// create and start the particle animators
			_animator1 = new ParticleAnimator(_particleAnimationSet);
			_particleMesh1.animator = _animator1;
			_animator1.start();
			_particleFollowNode.getAnimationState(_animator1).followTarget = _followTarget1;

			_animator2 = new ParticleAnimator(_particleAnimationSet);
			_particleMesh2.animator = _animator2;
			_animator2.start();
			_particleFollowNode.getAnimationState(_animator2).followTarget = _followTarget2;
		}

		/**
		 * Initialiser function for particle properties
		 */
		private static function initParticleFollowFunc(properties : ParticleProperties) : void {
			properties.startTime = Math.random() * 10 - 10;
			properties.duration = 0.5;
			// properties[ParticleVelocityNode.VELOCITY_VECTOR3D] = new Vector3D(Math.random() * 100 - 50, Math.random() * 100 - 200, Math.random() * 100 - 50);
			properties[ParticleVelocityNode.VELOCITY_VECTOR3D] = new Vector3D(Math.random() * 200 + 100, Math.random() * 100 - 50, Math.random() * 100 - 50);
		}

		/**
		 * Initialiser function for particle properties for basic test
		 */
		private static function initParticleFunc(prop : ParticleProperties) : void {
			prop.startTime = Math.random() * 5 - 5;
			prop.duration = 5;
			var degree1 : Number = Math.random() * Math.PI ;
			var degree2 : Number = Math.random() * Math.PI * 2;
			var r : Number = Math.random() * 50 + 400;
			prop[ParticleVelocityNode.VELOCITY_VECTOR3D] = new Vector3D(r * Math.sin(degree1) * Math.cos(degree2), r * Math.cos(degree1) * Math.cos(degree2), r * Math.sin(degree2));
		}

		/**
		 * Add extra mesh to player
		 */
		public static function add(m : Mesh) : void {
			// _player.addChild(m);
		}

		/**
		 * Remove extra mesh to player
		 */
		public static function remove(m : Mesh) : void {
			// _player.removeChild(m);
		}

		/**
		 * Create sprite3d to control direction
		 */
		private static function createSpote(color : uint = 0x3366FF) : BitmapData {
			var b : BitmapData = new BitmapData(64, 64, true, 0x00000000);
			var c : Shape = new Shape();
			var m : Matrix = new Matrix();
			m.createGradientBox(64, 64, 0, 0, 0);
			c.graphics.beginGradientFill("radial", [color, color], [0x11, 0x00], [0x00, 0xff], m);
			c.graphics.drawRect(0, 0, 64, 64);
			c.graphics.endFill();
			b.draw(c);
			return b;
		}
	}
}
