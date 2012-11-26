package games {
	import away3d.containers.Scene3D;
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.materials.TextureMaterial;
	import away3d.utils.Cast;
	import away3d.primitives.PlaneGeometry;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;

	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	// import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import utils.BitmapScrolling;
	import utils.BitmapFilterEffects;

	public class Lander extends Sprite {
		private  var _zoneDimension : Number = 12800;
		private  var _zoneHeight : uint = 1000;
		private  var _zoneResolution : uint = 128;
		private  var _terrainMethod : TerrainDiffuseMethod;
		private  var _scene : Scene3D;
		private  var plane : Mesh;
		private var _subGeometry : SubGeometry;
		private var _zoneSubdivision : uint;
		private  var tiles : Array = [1, 10, 20, 25];
		private  var _ground00 : BitmapScrolling;
		private  var _ground01 : BitmapScrolling;
		private  var _ground02 : BitmapScrolling;
		private  var _ground : BitmapData;
		private  var _ease : Vector3D;
		private  var _seed : uint = 1973;
		private  var _fractal : Boolean = false;
		private  var _numOctaves : uint = 2;
		private  var _offsets : Array = [];
		private  var _complex : Number = 0.2;
		private  var _maxSpeed : Number = 10;
		// private  var _matrix : Matrix;
		private var _bitmaps : Array;
		private var _isMove : Boolean;

		public function Lander() {
		}

		public function set isMove(b : Boolean) : void {
			_isMove = b;
		}

		public function set scene(s : Scene3D) : void {
			_scene = s;
		}

		public function set bitmaps(s : Array) : void {
			_bitmaps = s;
		}

		public function initObjects(Material : TextureMaterial, Dimension : Number = 12800, Height : Number = 1000, Resolution : uint = 128) : void {
			_zoneDimension = Dimension;
			_zoneHeight = Height;
			_zoneResolution = Resolution;

			_ease = new Vector3D();

			for (var i : uint = 0; i < _numOctaves; i++) {
				_offsets[i] = new Point(0, 0);
			}
			// _matrix = new Matrix();
			_ground = new BitmapData(_zoneResolution, _zoneResolution, false);
			draw();

			// ground scrolling
			_ground00 = new BitmapScrolling(_bitmaps[0]);
			_ground01 = new BitmapScrolling(_bitmaps[1]);
			_ground02 = new BitmapScrolling(_bitmaps[2]);

			if (Resolution == 256) _zoneSubdivision = 250;
			else _zoneSubdivision = Resolution - 1;

			plane = new Mesh(new PlaneGeometry(_zoneDimension, _zoneDimension, _zoneSubdivision, _zoneSubdivision), Material);

			// plane.mouseEnabled = true;
			// plane.pickingCollider = PickingColliderType.BOUNDS_ONLY;
			plane.geometry.convertToSeparateBuffers();
			plane.geometry.subGeometries[0].autoDeriveVertexNormals = false;
			plane.geometry.subGeometries[0].autoDeriveVertexTangents = false;
			plane.castsShadows = false;
			_subGeometry = SubGeometry(plane.geometry.subGeometries[0]);

			updateMaterial();
			updateTerrain();
			_scene.addChild(plane);
		}

		public function update() : void {
			if (_isMove) {
				move(0, 0.1);
				_ground00.move(0, -(0.1 * 10));
				_ground01.move(0, -(0.1 * 20));
				_ground02.move(0, -(0.1 * 25));

				updateMaterial();
				updateTerrain();
			}
		}

		private function updateMaterial() : void {
			_terrainMethod = new TerrainDiffuseMethod([Cast.bitmapTexture(_ground00.getMap()), Cast.bitmapTexture(_ground01.getMap()), Cast.bitmapTexture(_ground02.getMap())], Cast.bitmapTexture(_ground), tiles);
			TextureMaterial(plane.material).diffuseMethod = _terrainMethod;
			TextureMaterial(plane.material).normalMap = Cast.bitmapTexture(BitmapFilterEffects.normalMap(_ground));
		}

		private  function draw() : void {
			_ground.perlinNoise(_zoneResolution * _complex, _zoneResolution * _complex, _numOctaves, _seed, false, _fractal, 7, true, _offsets);
			
			_ground.applyFilter(_ground, _ground.rect, new Point(), setContrast(40));
		    _ground.applyFilter(_ground, _ground.rect, new Point(), new BlurFilter(5,5));
		}

		public function getHeightAt(x : Number, z : Number) : Number {
			var col : uint = _ground.getPixel((x / _zoneDimension + .5) * (_zoneResolution - 1), (-z / _zoneDimension + .5) * (_zoneResolution - 1)) & 0xffffff;
			return _zoneHeight * (col / 0xffffff);
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

		/**
		 * Update Terrain
		 */
		private function updateTerrain() : void {
			// get plane vertex data
			var v : Vector.<Number> = _subGeometry.vertexData;
			var l : uint = v.length;
			var c : uint, px : uint, size : uint;
			if (_zoneResolution == 256) size = _zoneResolution - 6;
			else size = _zoneResolution;
			for (var i : uint = 1; i < l; i += 3, c++) {
				// Get pixel at x and y position
				px = _ground.getPixel(c % size, size - (c / size));
				// Displace y position by the range
				v[i] = ((_zoneHeight * (px / 0xffffff)));
			}
			_subGeometry.updateVertexData(v);
		}

		/**
		 * sets contrast value available are -100 ~ 100 @default is 0
		 * @param       value:int   contrast value
		 * @return      ColorMatrixFilter
		 */
		public  function setContrast(value : Number) : ColorMatrixFilter {
			value /= 100;
			var s : Number = value + 1;
			var o : Number = 128 * (1 - s);
			var m : Array = new Array();
			m = m.concat([s, 0, 0, 0, o]);
			m = m.concat([0, s, 0, 0, o]);
			m = m.concat([0, 0, s, 0, o]);
			m = m.concat([0, 0, 0, 1, 0]);
			return new ColorMatrixFilter(m);
		}

		/**
		 * sets Brightneww value available are -100 ~ 100 @default is 0
		 * @param       value:int   contrast value
		 * @return      ColorMatrixFilter
		 */
		public static function setBrightness(value : Number) : ColorMatrixFilter {
			value = value * (255 / 250);
			var m : Array = new Array();
			m = m.concat([1, 0, 0, 0, value]);
			m = m.concat([0, 1, 0, 0, value]);
			m = m.concat([0, 0, 1, 0, value]);
			m = m.concat([0, 0, 0, 1, 0]);
			return new ColorMatrixFilter(m);
		}

		/**
		 * sets saturation value available are -100 ~ 100 @default is 0
		 * @param       value:int   saturation value
		 * @return      ColorMatrixFilter
		 */
		public static function setSaturation(value : Number) : ColorMatrixFilter {
			const lumaR : Number = 0.212671;
			const lumaG : Number = 0.71516;
			const lumaB : Number = 0.072169;
			var v : Number = (value / 100) + 1;
			var i : Number = (1 - v);
			var r : Number = (i * lumaR);
			var g : Number = (i * lumaG);
			var b : Number = (i * lumaB);
			var m : Array = new Array();
			m = m.concat([(r + v), g, b, 0, 0]);
			m = m.concat([r, (g + v), b, 0, 0]);
			m = m.concat([r, g, (b + v), 0, 0]);
			m = m.concat([0, 0, 0, 1, 0]);
			return new ColorMatrixFilter(m);
		}
	}
}
