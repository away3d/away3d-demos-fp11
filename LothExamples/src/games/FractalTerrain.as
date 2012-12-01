package games {
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.WireframePlane;
	import away3d.core.base.SubGeometry;
	import away3d.containers.Scene3D;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;

	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	// import flash.filters.BlurFilter;
	import flash.geom.Vector3D;
	import flash.geom.Point;
	// import flash.geom.Matrix;
	import utils.BitmapScrolling;
	import utils.BitmapFilterEffects;

	/**
	 * FractalTerrain 3D creator
	 * Away3d plane and Perlin noize
	 * TerrainDiffuseMethod and flash bitmap filters
	 * @author Loth 2012
	 */
	public class FractalTerrain {
		private var _zoneDimension : Number = 12800;
		private var _zoneHeight : uint = 1000;
		private var _zoneResolution : uint = 128;
		private var _terrainMethod : TerrainDiffuseMethod;
		private var _terrainMaterial : TextureMaterial;
		private var _subGeometry : SubGeometry;
		private var _scene : Scene3D;
		private var _plane : Mesh;
		private var _planeGrid : WireframePlane;
		private var _zoneSubdivision : uint;
		private var _tiles : Array = [1, 40, 40, 40];
		private var _ground00 : BitmapScrolling;
		private var _ground01 : BitmapScrolling;
		private var _ground02 : BitmapScrolling;
		private var _ground : BitmapData;
		private var _groundRevers : BitmapData;
		private var _ease : Vector3D;
		private var _fractal : Boolean = true;
		private var _numOctaves : uint = 2;
		private var _offsets : Array = [];
		private var _complex : Number = 0.12;
		private var _maxSpeed : Number = 0.2;
		private var _bitmaps : Vector.<BitmapData>;
		private var _seed : uint;
		private var _isMove : Boolean;
		private var _multy : Vector3D = new Vector3D(160, 160, 160);
		private var _isMapTesting : Boolean = false;

		/**
		 * Globale initialiser
		 */
		public function initGround(Scene : Scene3D, Bitmaps : Vector.<BitmapData>, Material : TextureMaterial, Dimension : Number = 12800, Height : Number = 1000, Resolution : uint = 128) : void {
			_zoneHeight = Height;
			_zoneDimension = Dimension;
			_zoneResolution = Resolution;
			_terrainMaterial = Material;
			_bitmaps = Bitmaps;
			_scene = Scene;
			_ease = new Vector3D();
			_seed = Math.random() * 123456;
			for (var i : uint = 0; i < _numOctaves; i++) {
				_offsets[i] = new Point(0, 0);
			}
			_ground = new BitmapData(_zoneResolution, _zoneResolution, false);
			_groundRevers = new BitmapData(_zoneResolution, _zoneResolution, false);
			draw();

			// ground scrolling
			_ground00 = new BitmapScrolling(_bitmaps[6]);
			_ground01 = new BitmapScrolling(_bitmaps[7]);
			_ground02 = new BitmapScrolling(_bitmaps[8]);

			// find the map multyplicator for scrolling
			findMultyplicator();

			if (Resolution == 256) _zoneSubdivision = Resolution - 6;
			else _zoneSubdivision = Resolution - 1;

			initTerrainMesh();
			if (_isMapTesting) initTerrainGrid();
		}

		/**
		 * Initialise terrain mesh
		 */
		private function initTerrainMesh() : void {
			_plane = new Mesh(new PlaneGeometry(_zoneDimension, _zoneDimension, _zoneSubdivision, _zoneSubdivision, true, false), _terrainMaterial);
			_plane.geometry.convertToSeparateBuffers();
			_plane.mouseEnabled = false;
			_plane.mouseChildren = false;
			_plane.castsShadows = false;
			_scene.addChild(_plane);
			_subGeometry = SubGeometry(_plane.geometry.subGeometries[0]);
			_subGeometry.autoDeriveVertexNormals = false;
			_subGeometry.autoDeriveVertexTangents = false;

			updateMaterial();
			updateTerrain();
		}

		private function initTerrainGrid() : void {
			_planeGrid = new WireframePlane(_zoneDimension, _zoneDimension, _zoneSubdivision, _zoneSubdivision, 0x22333333, 1, "xz");
			_scene.addChild(_planeGrid);
			_planeGrid.y = 1;
		}

		/**
		 * Update function on enterFrame
		 */
		public function update() : void {
			if (_isMove) {
				for (var i : uint = 0; i < _numOctaves; i++) {
					Point(_offsets[i]).x += _ease.x;
					Point(_offsets[i]).y += _ease.y;
				}
				draw();
				updateTerrain();
				updateMaterial();
			}
		}

		/**
		 * Define Multyplicator for each map
		 */
		private function findMultyplicator() : void {
			// for 512px map
			if (_zoneResolution == 256) _multy = new Vector3D(80, 80, 80);
			else if (_zoneResolution == 128) _multy = new Vector3D(160, 160, 160);
			else _multy = new Vector3D(320, 320, 320);
		}

		/**
		 * Update function for material
		 */
		private function updateMaterial() : void {
			_ground00.move(-_ease.x * _multy.x, -_ease.y * _multy.x);
			_ground01.move(-_ease.x * _multy.y, -_ease.y * _multy.y);
			_ground02.move(-_ease.x * _multy.z, -_ease.y * _multy.z);
			_terrainMethod = new TerrainDiffuseMethod([Cast.bitmapTexture(_ground00.getMap()), Cast.bitmapTexture(_ground01.getMap()), Cast.bitmapTexture(_ground02.getMap())], Cast.bitmapTexture(_ground), _tiles);
			_terrainMaterial.normalMap = Cast.bitmapTexture(BitmapFilterEffects.normalMap(_ground, 5, 0.5, -1, -1));
			if (_isMapTesting) _terrainMaterial.texture = Cast.bitmapTexture(_ground);
			else _terrainMaterial.diffuseMethod = _terrainMethod;
		}

		/**
		 * Draw bitmap perlin noize and add filter
		 */
		private function draw() : void {
			_ground.unlock();
			_ground.perlinNoise(_zoneResolution * _complex, _zoneResolution * _complex, _numOctaves, _seed, false, _fractal, 7, true, _offsets);
			// _ground.applyFilter(_ground, _ground.rect, new Point(), setContrast(60));
			// if (_zoneResolution == 256) _ground.applyFilter(_ground, _ground.rect, new Point(), new BlurFilter(8, 8));
			// else _ground.applyFilter(_ground, _ground.rect, new Point(), new BlurFilter(10, 10));
			_ground.lock();
		}

		/**
		 * Get height from perlin noize bitmap
		 */
		public function getHeightAt(x : Number, z : Number) : int {
			var col : int = _ground.getPixel((x / _zoneDimension + .5) * (_zoneSubdivision + 1), (-z / _zoneDimension + .5) * (_zoneSubdivision + 1)) & 0xffffff;
			return _zoneHeight * col / 0xffffff - (_zoneHeight >> 1);
		}

		public function stop() : void {
			if (_ease.x != 0) {
				if (_ease.x < 0) _ease.x += 0.01;
				else _ease.x -= 0.01;
			}
			if (_ease.y != 0) {
				if (_ease.y < 0) _ease.y += 0.01;
				else _ease.y -= 0.01;
			}
			if (_ease.x < 0.01 && _ease.x > -0.01 && _ease.y < 0.01 && _ease.y > -0.01) {
				_ease = new Vector3D();
				_isMove = false;
			}
		}

		/**
		 * Change terrain and perlin bitmap resolution
		 */
		public function changeResolution(Resolution : uint = 128) : void {
			if (Resolution == _zoneResolution) return;
			else _zoneResolution = Resolution;
			_isMove = false;
			_scene.removeChild(_plane);
			_plane.dispose();
			_subGeometry = null;
			if (Resolution == 256) _zoneSubdivision = Resolution - 6;
			else _zoneSubdivision = Resolution - 1;
			findMultyplicator();
			_ground = new BitmapData(_zoneSubdivision, _zoneSubdivision, false);

			draw();
			initTerrainMesh();
		}

		/**
		 * Move noize perlin bitmap
		 */
		public function move(x : Number, y : Number) : void {
			_isMove = true;
			_ease.x = x;
			_ease.y = y;
			if (_ease.x > _maxSpeed) _ease.x = _maxSpeed;
			if (_ease.y > _maxSpeed) _ease.y = _maxSpeed;
			if (_ease.x < -_maxSpeed) _ease.x = -_maxSpeed;
			if (_ease.y < -_maxSpeed) _ease.y = -_maxSpeed;
		}

		/**
		 * Update plane subgeometry from bitmap
		 */
		private function updateTerrain() : void {
			// get plane vertex data
			var v : Vector.<Number> = _subGeometry.vertexData;
			// var indices:Vector.<uint> = _subGeometry.indexData;
			var l : uint = v.length;
			var c : uint, px : uint, size : uint;
			if (_zoneResolution == 256) size = _zoneResolution - 5;// 250 is max
			else size = _zoneResolution;
			for (var i : uint = 1; i < l; i += 3, c++) {
				// Get pixel at x and y position
				px = _ground.getPixel(c % size, size - (c / size));
				// px = _ground.getPixel(c % size, int(c / size));
				// Displace y position by the range
				// v[i] = ((_zoneHeight * (px / 0xffffff)));
				v[i] = int(_zoneHeight * px / 0xffffff - (_zoneHeight >> 1));
			}
			_subGeometry.updateVertexData(v);
		}

		/**
		 * sets contrast value available are -100 ~ 100 @default is 0
		 * @param       value:int   contrast value
		 * @return      ColorMatrixFilter
		 */
		public function setContrast(value : Number) : ColorMatrixFilter {
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
		public function setBrightness(value : Number) : ColorMatrixFilter {
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
		public function setSaturation(value : Number) : ColorMatrixFilter {
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
