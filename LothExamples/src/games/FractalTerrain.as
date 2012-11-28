package games {
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.core.base.SubGeometry;
	import away3d.containers.Scene3D;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;

	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.BlurFilter;
	import flash.geom.Vector3D;
	import flash.geom.Point;

	import utils.BitmapScrolling;
	import utils.BitmapFilterEffects;

	/**
	 * FractalTerrain 3D creator
	 * Away3d plane and Perlin noize
	 * TerrainDiffuseMethod and flash bitmap filters
	 * @author Loth 2012
	 */
	public class FractalTerrain {
		static private var _zoneDimension : Number = 12800;
		static private var _zoneHeight : uint = 1000;
		static private var _zoneResolution : uint = 128;
		static private var _terrainMethod : TerrainDiffuseMethod;
		static private var _terrainMaterial : TextureMaterial;
		static private var _subGeometry : SubGeometry;
		static private var _scene : Scene3D;
		static private var _plane : Mesh;
		static private var _zoneSubdivision : uint;
		static private var _tiles : Array = [1, 40, 40, 40];
		static private var _ground00 : BitmapScrolling;
		static private var _ground01 : BitmapScrolling;
		static private var _ground02 : BitmapScrolling;
		static private var _ground : BitmapData;
		static private var _ease : Vector3D;
		static private var _fractal : Boolean = true;
		static private var _numOctaves : uint = 2;
		static private var _offsets : Array = [];
		static private var _complex : Number = 0.12;
		static private var _maxSpeed : Number = 0.2;
		static private var _bitmaps : Vector.<BitmapData>;
		static private var _seed : uint;
		static private var _isMove : Boolean;

		/**
		 * Globale initialiser
		 */
		static public function initGround(Scene : Scene3D, Bitmaps : Vector.<BitmapData>, Material : TextureMaterial, Dimension : Number = 12800, Height : Number = 1000, Resolution : uint = 128) : void {
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
			draw();

			// ground scrolling
			_ground00 = new BitmapScrolling(_bitmaps[6]);
			_ground01 = new BitmapScrolling(_bitmaps[7]);
			_ground02 = new BitmapScrolling(_bitmaps[8]);

			if (Resolution == 256) _zoneSubdivision = Resolution - 6;
			else _zoneSubdivision = Resolution - 1;

			initTerrainMesh();
		}

		/**
		 * Initialise terrain mesh
		 */
		static public function initTerrainMesh() : void {
			_plane = new Mesh(new PlaneGeometry(_zoneDimension, _zoneDimension, _zoneSubdivision, _zoneSubdivision), _terrainMaterial);
			_plane.geometry.convertToSeparateBuffers();

			_plane.mouseEnabled = false;
			_plane.mouseChildren = false;
			_plane.castsShadows = false;
			_scene.addChild(_plane);
			_subGeometry = SubGeometry(_plane.geometry.subGeometries[0]);

			// _subGeometry.useFaceWeights = true;

			updateMaterial();
			updateTerrain();
			_subGeometry.autoDeriveVertexNormals = false;
			_subGeometry.autoDeriveVertexTangents = false;
		}

		/**
		 * Update function on enterFrame
		 */
		static public function update() : void {
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
		static private function updateMaterial() : void {
			var multy : Number;
			if (_zoneResolution == 256) multy = 80;
			else if (_zoneResolution == 128) multy = 160;
			else multy = 320;
			_ground00.move(-_ease.x * multy, -_ease.y * multy);
			_ground01.move(-_ease.x * multy, -_ease.y * multy);
			_ground02.move(-_ease.x * multy, -_ease.y * multy);
			_terrainMethod = new TerrainDiffuseMethod([Cast.bitmapTexture(_ground00.getMap()), Cast.bitmapTexture(_ground01.getMap()), Cast.bitmapTexture(_ground02.getMap())], Cast.bitmapTexture(_ground), _tiles);
			_terrainMaterial.diffuseMethod = _terrainMethod;
			_terrainMaterial.normalMap = Cast.bitmapTexture(BitmapFilterEffects.normalMap(_ground, 30, 2, -1, -1));
		}

		/**
		 * Draw bitmap perlin noize and add filter
		 */
		static private  function draw() : void {
			_ground.unlock();
			_ground.perlinNoise(_zoneResolution * _complex, _zoneResolution * _complex, _numOctaves, _seed, false, _fractal, 7, true, _offsets);
			_ground.applyFilter(_ground, _ground.rect, new Point(), setContrast(60));
			if (_zoneResolution == 256) _ground.applyFilter(_ground, _ground.rect, new Point(), new BlurFilter(8, 8));
			else _ground.applyFilter(_ground, _ground.rect, new Point(), new BlurFilter(4, 4));
			_ground.lock();
		}

		/**
		 * Get height from perlin noize bitmap
		 */
		static public function getHeightAt(x : Number, z : Number) : Number {
			// var col : uint = _ground.getPixel((x / _zoneDimension + .5) * (_zoneSubdivision + 1), (-z / _zoneDimension + .5) * (_zoneSubdivision + 1)) & 0xffffff;
			var col : uint = _ground.getPixel((x / _zoneDimension + .5) * (_zoneSubdivision + 1), (-z / _zoneDimension + .5) * (_zoneSubdivision + 1)) & 0xffffff;

			return _zoneHeight * (col / 0xffffff);
		}

		static public function stop() : void {
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
		static public function changeResolution(Resolution : uint = 128) : void {
			if (Resolution == _zoneResolution) return;
			else _zoneResolution = Resolution;
			_isMove = false;
			_scene.removeChild(_plane);
			_plane.dispose();
			_subGeometry = null;
			_ground = new BitmapData(_zoneResolution, _zoneResolution, false);
			draw();
			if (Resolution == 256) _zoneSubdivision = Resolution - 6;
			else _zoneSubdivision = Resolution - 1;
			initTerrainMesh();
		}

		/**
		 * Move noize perlin bitmap
		 */
		static public function move(x : Number, y : Number) : void {
			_isMove = true;
			_ease.x = x;
			_ease.y = y;

			if (_ease.x > _maxSpeed)
				_ease.x = _maxSpeed;
			if (_ease.y > _maxSpeed)
				_ease.y = _maxSpeed;
			if (_ease.x < -_maxSpeed)
				_ease.x = -_maxSpeed;
			if (_ease.y < -_maxSpeed)
				_ease.y = -_maxSpeed;
		}

		/**
		 * Update plane subgeometry from bitmap
		 */
		static private function updateTerrain() : void {
			// get plane vertex data
			var v : Vector.<Number> = _subGeometry.vertexData;
			// var indices:Vector.<uint> = _subGeometry.indexData;
			var l : uint = v.length;
			var c : uint, px : uint, size : uint;
			if (_zoneResolution == 256) size = _zoneResolution - 5;
			else size = _zoneResolution;
			for (var i : uint = 1; i < l; i += 3, c++) {
				// Get pixel at x and y position
				px = _ground.getPixel(c % size, size - (c / size));
				// Displace y position by the range
				v[i] = ((_zoneHeight * (px / 0xffffff)));
			}

			_subGeometry.updateVertexData(v);
			// _subGeometry.updateIndexData(indices);
		}

		/**
		 * sets contrast value available are -100 ~ 100 @default is 0
		 * @param       value:int   contrast value
		 * @return      ColorMatrixFilter
		 */
		static public function setContrast(value : Number) : ColorMatrixFilter {
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
		static public function setBrightness(value : Number) : ColorMatrixFilter {
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
		static public function setSaturation(value : Number) : ColorMatrixFilter {
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
