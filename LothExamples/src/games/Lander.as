package games {
	import away3d.containers.Scene3D;
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.materials.TextureMaterial;
	import away3d.utils.Cast;

	import flash.display.BitmapData;

	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;
	import away3d.primitives.PlaneGeometry;

	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	import shallowwater.*;

	import flash.display.Sprite;

	import utils.BitmapScrolling;

	public class Lander extends Sprite {
		// private  var _maxHeight:Number = 100;
		private  var _minElevation : uint = 0;
		private  var _maxElevation : uint = 2000;
		private  var _terrainMethod : TerrainDiffuseMethod;
		private  var _scene : Scene3D;
		public  var fluid : ShallowFluid;
		private  var fluidDisturb : FluidDisturb;
		private  var plane : Mesh;
		// fluid simulation variables
		private  var planeSizeTop : Number = 128 * 100;
		private  var gridDimension : uint = 128;
		private  var gridSpacing : uint = 1;
		private  var planeSize : Number;
		private  var tiles : Array = [1, 10, 20, 25];
		private  var _ground00 : BitmapScrolling;
		private  var _ground01 : BitmapScrolling;
		private  var _ground02 : BitmapScrolling;
		// private  var move:Boolean;
		private  var _ground : BitmapData;
		private  var _ease : Vector3D;
		private  var _size : uint = 128;
		private  var _height : uint = 1300;
		private  var _seed : uint = 1973;
		private  var _fractal : Boolean = true;
		private  var _numOctaves : uint = 2;
		private  var _offsets : Array = [];
		private  var _complex : Number = 0.2;
		private  var _maxSpeed : Number = 10;
		private  var _matrix : Matrix;
		private var _bitmaps : Array;

		public function Lander() {
		}

		public function set scene(s : Scene3D) : void {
			_scene = s;
		}

		public function set maxElevation(s : uint) : void {
			_maxElevation = s;
		}

		public function set bitmaps(s : Array) : void {
			_bitmaps = s;
		}
		
		public function initObjects(Material : TextureMaterial, S : Number = 100, Height : Number = 700, HeightTop : Number = 700) : void {
			planeSizeTop = HeightTop;
			initBitmapMapper(1, Height);
			

			// ground scrolling
			_ground00 = new BitmapScrolling(_bitmaps[0]);
			_ground01 = new BitmapScrolling(_bitmaps[1]);
			_ground02 = new BitmapScrolling(_bitmaps[2]);

			// gridSpacing = size/4;
			var planeSegments : uint = ( gridDimension - 1);
			planeSize = (planeSegments * gridSpacing);
			plane = new Mesh(new PlaneGeometry(planeSize, planeSize, planeSegments, planeSegments), Material);
			plane.rotationX = 90;
			plane.scale(S);
			plane.x -= (planeSize * S) / 2;
			plane.z -= (planeSize * S) / 2;
			// plane.mouseEnabled = true;
			// plane.pickingCollider = PickingColliderType.BOUNDS_ONLY;
			plane.geometry.convertToSeparateBuffers();
			plane.geometry.subGeometries[0].autoDeriveVertexNormals = false;
			plane.geometry.subGeometries[0].autoDeriveVertexTangents = false;
			plane.castsShadows = false;
			_scene.addChild(plane);

			initFluid();

			// imageBrush.fromSprite(disturb as Sprite );
			// fluidDisturb.disturbBitmapMemory(0.5, 0.5, -10, imageBrush.bitmapData, -1, 0.01);
			// fluidDisturb.disturbBitmapMemory(0, 0,1000, BitmapMapper.ground, 10, 0.2);
			// update();
		}

		/**
		 * Initialise the fluid
		 */
		public function initFluid() : void {
			// Fluid.
			var dt : Number = 1 / 60;
			// stage.frameRate;
			var viscosity : Number = 0.2;
			var waveVelocity : Number = 0.2;
			// < 1 or the sim will collapse.
			fluid = new ShallowFluid(gridDimension, gridDimension, gridSpacing, dt, waveVelocity, viscosity);

			// Disturbance util.
			fluidDisturb = new FluidDisturb(fluid);
		}

		// private  var count:uint = 0;
		public function update() : void {
			// count++
			// Update fluid.
			fluid.evaluate();

			// if (count == 2) {
			// count=0

			move(0, 0.2);
			_ground00.move(0, -(0.2 * 10));
			_ground01.move(0, -(0.2 * 20));
			_ground02.move(0, -(0.2 * 25));
			// _terrainMaterial.diffuseMethod.dispose();
			// _terrainMethod.dispose();
			_terrainMethod = new TerrainDiffuseMethod([Cast.bitmapTexture(_ground00.getMap()), Cast.bitmapTexture(_ground01.getMap()), Cast.bitmapTexture(_ground02.getMap())], Cast.bitmapTexture(_ground), tiles);
			TextureMaterial(plane.material).diffuseMethod = _terrainMethod;
			// _terrainMaterial.diffuseMethod = _terrainMethod;
			// _terrainMaterial.normalMap = Cast.bitmapTexture(PixelBlenderEffects.normal(_ground));
			// fluid.evaluate();
			// fluidDisturb.disturbBitmapInstant(0.5, 0.5, -1, BitmapMapper.ground);
			// fluidDisturb.disturbBitmapInstant(0.5, 0.5, -1, BitmapMapper.ground);
			fluidDisturb.disturbBitmapMemory(0.5, 0.5, -10, _ground, 100, 0.5);

			// Update memory disturbances.
			fluidDisturb.updateMemoryDisturbances();

			// Update plane to fluid.
			var subGeometry : SubGeometry = plane.geometry.subGeometries[0] as SubGeometry;
			subGeometry.updateVertexData(fluid.points);
			subGeometry.updateVertexNormalData(fluid.normals);
			subGeometry.updateVertexTangentData(fluid.tangents);

			// }
		}

		public function initBitmapMapper(quality : uint = 1, Height : Number = 1300) : void {
			_size = 128 * quality;
			_height = Height;
			_ease = new Vector3D();

			for (var i : uint = 0; i < _numOctaves; i++) {
				_offsets[i] = new Point(0, 0);
			}
			_matrix = new Matrix();
			_ground = new BitmapData(_size, _size, false);
			draw();
		}

		private  function draw() : void {
			_ground.perlinNoise(_size * _complex, _size * _complex, _numOctaves, _seed, false, _fractal, 7, true, _offsets);

			// _ground.applyFilter(_ground, _ground.rect, new Point(), new BlurFilter(5,5));
			_ground.applyFilter(_ground, _ground.rect, new Point(), setContrast(40));
		}

		public function getHeightAt(x : Number, z : Number) : Number {
			var col : uint = _ground.getPixel((x / planeSizeTop + .5) * (128 - 1), (-z / planeSizeTop + .5) * (128 - 1)) & 0xff;
			return (col > _maxElevation) ? (_maxElevation / 0xff) * _height : ((col < _minElevation) ? (_minElevation / 0xff) * _height : (col / 0xff) * _height);
		}

		public function move(x : Number, y : Number) : void {
			_ease.x = x;
			// -((stage.stageWidth >> 1) - mouseX ) / (stage.stageWidth >> 1);
			_ease.y = y;
			// -((stage.stageHeight >> 1) - mouseY) / (stage.stageHeight >> 1);

			if (_ease.x > _maxSpeed)
				_ease.x = _maxSpeed;
			if (_ease.y > _maxSpeed)
				_ease.y = _maxSpeed;
			if (_ease.x < -_maxSpeed)
				_ease.x = -_maxSpeed;
			if (_ease.y < -_maxSpeed)
				_ease.y = -_maxSpeed;

			for (var i : uint = 0; i < _numOctaves; i++) {
				Point(_offsets[i]).x += _ease.x;
				Point(_offsets[i]).y += _ease.y;
			}
			draw();
		}

		public  function setContrast(value : Number) : ColorMatrixFilter {
			value /= 100;
			var s : Number = value + 1;
			var o : Number = 128 * (1 - s);
			var m : Array = new Array();
			m = m.concat([s, 0, 0, 0, o]);
			// red
			m = m.concat([0, s, 0, 0, o]);
			// green
			m = m.concat([0, 0, s, 0, o]);
			// blue
			m = m.concat([0, 0, 0, 1, 0]);
			// alpha
			return new ColorMatrixFilter(m);
		}
	}
}
