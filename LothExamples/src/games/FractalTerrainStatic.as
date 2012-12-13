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
	public class FractalTerrainStatic {
		private static var Singleton : FractalTerrainStatic;
		private static var _zoneDimension : uint = 12800;
		private static var _zoneHeight : int = 1000;
		private static var _zoneResolution : uint = 128;
		private static var _terrainMethod : TerrainDiffuseMethod;
		private static var _terrainMaterial : TextureMaterial;
		private static var _subGeometry : SubGeometry;
		private static var _scene : Scene3D;
		private static var _plane : Mesh;
		private static var _planeGrid : WireframePlane;
		private static var _zoneSubdivision : uint;
		private static var _tiles : Array = [1, 40, 80, 40];
		private static var _ground00 : BitmapScrolling;
		private static var _ground01 : BitmapScrolling;
		private static var _ground02 : BitmapScrolling;
		private static var _ground : BitmapData;
		private static var _ease : Vector3D;
		private static var _fractal : Boolean = true;
		private static var _numOctaves : uint = 1;
		private static var _offsets : Array = [];
		private static var _complex : Number = 0.12;
		private static var _maxSpeed : Number = 0.2;
		private static var _bitmaps : Vector.<BitmapData>;
		private static var _layerBitmap : Vector.<BitmapData>;
		private static var _seed : int;
		private static var _isMove : Boolean;
		private static var _multy : Vector3D;
		private static var _rec : Rectangle;
		private static var _p : Point;
		private static var _cubePoints : Vector.<Vector3D>;
		private static var _groundVertex : Vector.<uint>;
		// Debug option to see only perlin noize and grid
		private static var _isMapTesting : Boolean = false;
		// Optional cube position follow terrain mesh
		private static var _isCubicReference : Boolean = false;
		
		/**
		 * Singleton enforcer
		 */
		public static function getInstance() : FractalTerrainStatic {
			if (Singleton == null) {
				Singleton = new FractalTerrainStatic();
				//FractalTerrainStatic.init();
			}
			return Singleton;
		}
		
		/**
		 * Set the away3d scene
		 */
		static public function set scene(Scene : Scene3D) : void {
			_scene = Scene;
		}

		/**
		 * Globale initialiser
		 */
		public static function initGround( Bitmaps : Vector.<BitmapData>, Material : TextureMaterial, Dimension : uint = 12800, Height : int = 1000, Resolution : uint = 128) : void {
			_zoneHeight = Height;
			_zoneDimension = Dimension;
			_terrainMaterial = Material;
			_zoneResolution = Resolution;
			_bitmaps = Bitmaps;
			_ease = new Vector3D();
			_seed = int(Math.random() * 12345);
			for (var i : uint = 0; i < _numOctaves; ++i) {
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
		private static function initTerrainMesh() : void {
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
		 * Get the current vector cubic position
		 */
		public static function get cubePoints() : Vector.<Vector3D> {
			return _cubePoints;
		}

		/**
		 * Optional physics cube reference point follow terrain 6 * 6
		 */
		public static function addCubicReference() : void {
			_cubePoints = new Vector.<Vector3D>(36);

			for (var i : uint = 0; i < 36; ++i) {
				_cubePoints[i] = new Vector3D();
			}
			defineGroundVertex();
			_isCubicReference = true;
		}

		/**
		 * Define the central vertex on ground mesh
		 */
		private static function defineGroundVertex() : void {
			_groundVertex = new Vector.<uint>(36);
			var i : uint;
			var j : uint;
			var n : uint;
			if (_zoneResolution == 128) {
				for (j = 0; j < 6; ++j) {
					for (i = 0; i < 6; ++i) {
						_groundVertex[n] = uint(7869 + i + (j * 128));
						n++;
					}
				}
			} else if (_zoneResolution == 64) {
				for (j = 0; j < 6; ++j) {
					for (i = 0; i < 6; ++i) {
						_groundVertex[n] = uint(1885 + i + (j * 64));
						n++;
					}
				}
			} else if (_zoneResolution == 256) {
				for (j = 0; j < 6; ++j) {
					for (i = 0; i < 6; ++i) {
						_groundVertex[n] = uint(30745 + i + (j * 251));
						n++;
					}
				}
			}
		}

		/**
		 * Optional grid debug
		 */
		private static function initTerrainGrid() : void {
			_planeGrid = new WireframePlane(_zoneDimension, _zoneDimension, _zoneSubdivision, _zoneSubdivision, 0x22333333, 1, "xz");
			_scene.addChild(_planeGrid);
			_planeGrid.y = 1;
		}

		/**
		 * Update function on enterFrame
		 */
		public static function update() : void {
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
		private static function updateMaterial() : void {
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
		private static function draw() : void {
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
		public static function getHeightAt(x : Number, z : Number) : int {
			var col : int = _ground.getPixel((x / _zoneDimension + .5) * (_zoneSubdivision + 1), (-z / _zoneDimension + .5) * (_zoneSubdivision + 1)) & 0xffffff;
			return _zoneHeight * col / 0xffffff - (_zoneHeight >> 1);
		}

		public static function stop() : void {
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
		public static function changeResolution(Resolution : uint = 128) : void {
			if (Resolution == _zoneResolution) return;
			_isMove = false;
			_zoneResolution = Resolution;
			_scene.removeChild(_plane);
			_plane.dispose();
			_subGeometry = null;

			findMultyplicator();
			if (_isCubicReference) defineGroundVertex();
			_ground = new BitmapData(_zoneResolution, _zoneResolution, true);
			_layerBitmap[0] = new BitmapData(_zoneResolution, _zoneResolution, false);
			_rec = _ground.rect;

			draw();
			initTerrainMesh();
		}

		private static function basicUpdate() : void {
			draw();
			updateTerrain();
			updateMaterial();
		}

		public static function changeFractal() : void {
			if (_fractal) _fractal = false;
			else _fractal = true;
			basicUpdate();
		}

		public static function changeHeight(v : int) : void {
			_zoneHeight = v;
			basicUpdate();
		}

		public static function changeComplex(v : Number) : void {
			_complex = v;
			basicUpdate();
		}

		public static function get zoneHeight() : int {
			return _zoneHeight;
		}

		/**
		 * Move noize perlin bitmap
		 */
		public static function move(x : Number, y : Number) : void {
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
		private static function updateTerrain() : void {
			// get plane vertex data
			var i : uint;
			var j : uint;
			var v : Vector.<Number> = _subGeometry.vertexData;
			var l : uint = v.length;
			var c : uint, px : uint, size : uint;
			var vertex : uint = 0;
			// Counter vertex
			if (_zoneResolution == 256) size = _zoneResolution - 5;// 250 is max
			else size = _zoneResolution;
			for ( i = 1; i < l; i += 3, ++c) {
				// Get pixel at x and y position
				px = _ground.getPixel(c % size, size - (c / size));
				// Displace y position by the range
				v[i] = int(_zoneHeight * px / 0xffffff - (_zoneHeight >> 1));
				// update cubic reference
				if (_isCubicReference) {
					for (j = 0; j < 36; ++j) {
						if (vertex == _groundVertex[j] ) _cubePoints[j] = new Vector3D(v[i - 1], v[i], v[i + 1]);
					}
				}
				vertex++;
			}
			_subGeometry.updateVertexData(v);
		}

		/**
		 * Define Multyplicator for each map scroll
		 */
		private static function findMultyplicator() : void {
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
		public static function setContrast(value : Number) : ColorMatrixFilter {
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
