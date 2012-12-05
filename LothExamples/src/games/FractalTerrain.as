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
	import flash.geom.ColorTransform;
	import flash.filters.BlurFilter;
	import flash.geom.Vector3D;
	import flash.geom.Rectangle;
	import flash.geom.Point;

	import utils.BitmapScrolling;
	import utils.BitmapFilterEffects;

	/**
	 * oo FractalTerrain
	 * Away3d plane and Perlin noize
	 * TerrainDiffuseMethod and flash bitmap filters
	 * Author : Loth
	 */
	public class FractalTerrain {
		private var _zoneDimension : uint = 12800;
		private var _zoneHeight : int = 1000;
		private var _zoneResolution : uint = 128;
		private var _terrainMethod : TerrainDiffuseMethod;
		private var _terrainMaterial : TextureMaterial;
		private var _subGeometry : SubGeometry;
		private var _scene : Scene3D;
		private var _plane : Mesh;
		private var _planeGrid : WireframePlane;
		private var _zoneSubdivision : uint;
		private var _tiles : Array = [1, 40, 80, 40];
		private var _ground00 : BitmapScrolling;
		private var _ground01 : BitmapScrolling;
		private var _ground02 : BitmapScrolling;
		private var _ground : BitmapData;
		private var _ease : Vector3D;
		private var _fractal : Boolean = true;
		private var _numOctaves : uint = 1;
		private var _offsets : Array = [];
		private var _complex : Number = 0.12;
		private var _maxSpeed : Number = 0.2;
		private var _bitmaps : Vector.<BitmapData>;
		private var _layerBitmap : Vector.<BitmapData>;
		private var _seed : int;
		private var _isMove : Boolean;
		private var _multy : Vector3D;
		private var _rec : Rectangle;
		private var _p : Point;
		// Debug option to see only perlin noize and grid
		private var _isMapTesting : Boolean = false;

		/**
		 * Globale initialiser
		 */
		public function initGround(Scene : Scene3D, Bitmaps : Vector.<BitmapData>, Material : TextureMaterial, Dimension : uint = 12800, Height : int = 1000, Resolution : uint = 128) : void {
			_zoneHeight = Height;
			_zoneDimension = Dimension;
			_terrainMaterial = Material;
			_zoneResolution = Resolution;
			_bitmaps = Bitmaps;
			_scene = Scene;
			_ease = new Vector3D();
			_seed = int(Math.random() * 123);
			for (var i : uint = 0; i < _numOctaves; i++) {
				_offsets[i] = new Point(0, 0);
			}
			// draw the height map
			_ground = new BitmapData(_zoneResolution, _zoneResolution, true);
			_layerBitmap = new Vector.<BitmapData>(3);
			_layerBitmap[0] = new BitmapData(_zoneResolution, _zoneResolution, false);
			_rec = _ground.rect;
			_p = new Point();
			draw();
			// ground bitmap scrolling
			_ground00 = new BitmapScrolling(_bitmaps[6]);
			_ground01 = new BitmapScrolling(_bitmaps[7]);
			_ground02 = new BitmapScrolling(_bitmaps[8]);
			// find the map multyplicator for scrolling
			findMultyplicator();
			// create terrain mesh
			initTerrainMesh();
		}

		/**
		 * Initialise terrain mesh
		 */
		private function initTerrainMesh() : void {
			if (_zoneResolution == 256) _zoneSubdivision = _zoneResolution - 6;
			else _zoneSubdivision = _zoneResolution - 1;
			_plane = new Mesh(new PlaneGeometry(_zoneDimension, _zoneDimension, _zoneSubdivision, _zoneSubdivision, true, false), _terrainMaterial);
			_plane.geometry.convertToSeparateBuffers();
			_plane.mouseEnabled = false;
			_plane.mouseChildren = false;
			_plane.castsShadows = false;
			_scene.addChild(_plane);
			_subGeometry = SubGeometry(_plane.geometry.subGeometries[0]);
			_subGeometry.autoDeriveVertexNormals = false;
			_subGeometry.autoDeriveVertexTangents = false;
			if (_isMapTesting) initTerrainGrid();
			updateMaterial();
			updateTerrain();
		}

		/**
		 * Optional grid debug
		 */
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
		 * Update function for material
		 */
		private function updateMaterial() : void {
			_ground00.move(-_ease.x * _multy.x, -_ease.y * _multy.x);
			_ground01.move(-_ease.x * _multy.y, -_ease.y * _multy.y);
			_ground02.move(-_ease.x * _multy.z, -_ease.y * _multy.z);
			_terrainMethod = new TerrainDiffuseMethod([Cast.bitmapTexture(_ground02.getMap()), Cast.bitmapTexture(_ground01.getMap()), Cast.bitmapTexture(_ground00.getMap())], Cast.bitmapTexture(_layerBitmap[0]), _tiles);
			_terrainMaterial.normalMap = Cast.bitmapTexture(BitmapFilterEffects.normalMap(_ground, 5, 0.5, -1, -1));
			if (_isMapTesting) _terrainMaterial.texture = Cast.bitmapTexture(_layerBitmap[0]);
			else _terrainMaterial.diffuseMethod = _terrainMethod;
		}

		/**
		 * Draw bitmap perlin noize and add filter
		 */
		private function draw() : void {
			_ground.unlock();
			_ground.perlinNoise(_zoneResolution * _complex, _zoneResolution * _complex, _numOctaves, _seed, false, _fractal, 7, true, _offsets);
			_ground.lock();
			// create two temp layer
			_layerBitmap[1] = new BitmapData(_zoneResolution, _zoneResolution, true);
			_layerBitmap[2] = new BitmapData(_zoneResolution, _zoneResolution, true);
			// red _ top
			_layerBitmap[0].unlock();
			_layerBitmap[0] = _ground.clone();
			_layerBitmap[0].colorTransform(_rec, new ColorTransform(1, 0, 0, 1, 255, 0, 0, 0));
			// green _ mid
			_layerBitmap[1].threshold(_ground, _rec, _p, ">", 0xFF888888, 0x0000000, 0xFFFFFFFF, true);
			_layerBitmap[1].colorTransform(_rec, new ColorTransform(0, 1, 0, 1, 0, 255, 0, 0));
			_layerBitmap[1].applyFilter(_layerBitmap[1], _rec, _p, new BlurFilter(12, 12, 3));
			// blue _ bottom
			_layerBitmap[2].threshold(_ground, _rec, _p, ">", 0xFF707070, 0x0000000, 0xFFFFFFFF, true);
			_layerBitmap[2].colorTransform(_rec, new ColorTransform(0, 0, 1, 1, 0, 0, 255, 0));
			_layerBitmap[2].applyFilter(_layerBitmap[2], _rec, _p, new BlurFilter(6, 6, 3));
			// copy chanel from other layer to base layer
			_layerBitmap[0].draw(_layerBitmap[1]);
			_layerBitmap[0].draw(_layerBitmap[2]);
			_layerBitmap[0].lock();
			_layerBitmap[1].dispose();
			_layerBitmap[2].dispose();
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

			_isMove = false;
			_zoneResolution = Resolution;
			_scene.removeChild(_plane);
			_plane.dispose();
			_subGeometry = null;

			findMultyplicator();
			_ground = new BitmapData(_zoneResolution, _zoneResolution, true);
			_layerBitmap[0] = new BitmapData(_zoneResolution, _zoneResolution, false);
			_rec = _ground.rect;
			draw();
			initTerrainMesh();
		}

		public function changeFractal() : void {
			if (_fractal) _fractal = false;
			else _fractal = true;
			draw();
			updateTerrain();
			updateMaterial();
		}

		public function changeHeight(v : int) : void {
			_zoneHeight = v;
			draw();
			updateTerrain();
			updateMaterial();
		}

		public function get zoneHeight() : int {
			return _zoneHeight;
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
			var l : uint = v.length;
			var c : uint, px : uint, size : uint;
			if (_zoneResolution == 256) size = _zoneResolution - 5;// 250 is max
			else size = _zoneResolution;
			for (var i : uint = 1; i < l; i += 3, ++c) {
				// Get pixel at x and y position
				px = _ground.getPixel(c % size, size - (c / size));
				// Displace y position by the range
				v[i] = int(_zoneHeight * px / 0xffffff - (_zoneHeight >> 1));
			}
			_subGeometry.updateVertexData(v);
		}

		/**
		 * Define Multyplicator for each map scroll
		 */
		private function findMultyplicator() : void {
			_multy = new Vector3D(0, 0, 0);
			_multy.x = _tiles[1] * (_ground00.getMap().width / _zoneResolution);
			_multy.y = _tiles[2] * (_ground01.getMap().width / _zoneResolution);
			_multy.z = _tiles[3] * (_ground02.getMap().width / _zoneResolution);
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
