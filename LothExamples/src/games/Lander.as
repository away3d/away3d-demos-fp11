package games {
	import away3d.containers.Scene3D;
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.materials.TextureMaterial;
	import away3d.utils.Cast;
	import away3d.primitives.PlaneGeometry;
	import away3d.entities.Mesh;

	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.display.Sprite;

	import utils.BitmapScrolling;

	public class Lander extends Sprite {
		// private  var _maxHeight:Number = 100;
		private  var _minElevation : uint = 0;
		private  var _maxElevation : uint = 2000;
		private  var _terrainMethod : TerrainDiffuseMethod;
		private  var _scene : Scene3D;
		private  var plane : Mesh;
		// fluid simulation variables
		private  var planeSizeTop : Number = 128 * 100;
		private  var gridDimension : uint = 128;
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

		public function set bitmaps(s : Array) : void {
			_bitmaps = s;
		}

		public function initObjects(Material : TextureMaterial, HeightTop : Number = 700, Height : Number = 700) : void {
			planeSizeTop = HeightTop;
			_height = Height;
			_maxElevation = Height;
			initBitmapMapper(1);

			// ground scrolling
			_ground00 = new BitmapScrolling(_bitmaps[0]);
			_ground01 = new BitmapScrolling(_bitmaps[1]);
			_ground02 = new BitmapScrolling(_bitmaps[2]);

			plane = new Mesh(new PlaneGeometry(planeSizeTop, planeSizeTop, gridDimension - 1, gridDimension - 1), Material);

			// plane.mouseEnabled = true;
			// plane.pickingCollider = PickingColliderType.BOUNDS_ONLY;
			plane.geometry.convertToSeparateBuffers();
			plane.geometry.subGeometries[0].autoDeriveVertexNormals = false;
			plane.geometry.subGeometries[0].autoDeriveVertexTangents = false;
			plane.castsShadows = false;
			_scene.addChild(plane);
		}

		public function update() : void {
			move(0, 0.2);
			_ground00.move(0, -(0.2 * 10));
			_ground01.move(0, -(0.2 * 20));
			_ground02.move(0, -(0.2 * 25));

			_terrainMethod = new TerrainDiffuseMethod([Cast.bitmapTexture(_ground00.getMap()), Cast.bitmapTexture(_ground01.getMap()), Cast.bitmapTexture(_ground02.getMap())], Cast.bitmapTexture(_ground), tiles);
			TextureMaterial(plane.material).diffuseMethod = _terrainMethod;

			updateTerrain();
		}

		public function initBitmapMapper(quality : uint = 1) : void {
			_size = 128 * quality;
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
			// _ground.applyFilter(_ground, _ground.rect, new Point(), setContrast(40));
		}

		public function getHeightAt(x : Number, z : Number) : Number {
			var col : uint = _ground.getPixel((-x / planeSizeTop + .5) * (128 - 1), (-z / planeSizeTop + .5) * (128 - 1)) & 0xff;
			return (col > _maxElevation) ? (_maxElevation / 0xff) * _height : ((col < _minElevation) ? (_minElevation / 0xff) * _height : (col / 0xff) * _height);
		}

		/*public function getHeightAt(x : Number, z : Number) : Number {
		px = _ground.getPixel(c % size, size - (c / size));
		// Displace y position by the range
		v[i] = 0 + ((_height * (px / 0xffffff)));
		}*/
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

		/**
		 * Update Terrain
		 */
		private function updateTerrain() : void {
			// get plane vertex data
			var v : Vector.<Number> = plane.geometry.subGeometries[0].vertexData;
			var l : int = v.length;
			;
			var vertex : int = 0;
			// Counter vertex
			var c : int;
			// Counter integer to get row and coulumn of a pixel
			var px : uint;
			var size : int = _size;
			// if (_size == 256) size = _size - 6;
			for (var i : uint = 1; i < l; i += 3, c++) {
				// Get pixel at x and y position
				px = _ground.getPixel(c % size, size - (c / size));
				// Displace y position by the range
				v[i] = 0 + ((_height * (px / 0xffffff)));
				// - (_height >> 1));

				// v[i] = getHeightAt(c % size, size - (c / size));
				vertex++;
			}
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
