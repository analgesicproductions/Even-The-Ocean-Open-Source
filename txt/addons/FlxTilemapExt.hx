package flixel.addons.tile;

import flash.display.BitmapData;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxTilemapBuffer;
import flixel.util.FlxDestroyUtil;
import help.FlxX;

// TODO: add support for tilemap scaling
// TODO: try to make it cleaner (i mean rendering and animated tiles)

/**
 * Extended FlxTilemap class that provides collision detection against slopes
 * Based on the original by Dirk Bunk.
 * ---
 * Also add support to flipped / rotated tiles.
 * @author Peter Christiansen
 * @author MrCdK
 * @author adrianulima
 * @link https://github.com/TheTurnipMaster/SlopeDemo
 */
class FlxTilemapExt extends FlxTilemap
{
	// Slope related variables
	private var _snapping:Int = 2;
	private var _slopePoint:FlxPoint = FlxPoint.get();
	private var _objPoint:FlxPoint = FlxPoint.get();
	
	
	//
//-	public var _slopeFloorLeft:Array<Int>;
//-	public var _slopeFloorRight:Array<Int>;
//-	public var _slopeCeilLeft:Array<Int>;
//-	public var _slopeCeilRight:Array<Int>;
	public var gentleSlopeFloorLeft:Array<Int>;
	public var gentleSlopeFloorRight:Array<Int>;
	
	public var _slopeNorthwest:Array<Int> = [];
	public var _slopeNortheast:Array<Int> = [];
	public var _slopeSouthwest:Array<Int> = [];
	public var _slopeSoutheast:Array<Int> = [];

	// 23 deg or so
	public var _slopeThickGentle:Array<Int> = [];
	public var _slopeThinGentle:Array<Int> = [];
	
// Don't care don't care	
	private var _slopeThickSteep:Array<Int> = [];
	private var _slopeThinSteep:Array<Int> = [];
	
	// Animated and flipped tiles related variables
	private var _specialTiles:Array<FlxTileSpecial>;
	
	override public function destroy():Void 
	{
		_slopePoint = FlxDestroyUtil.put(_slopePoint);
		_objPoint = FlxDestroyUtil.put(_objPoint);
		
		_slopeNorthwest = null;
		_slopeNortheast = null;
		_slopeSouthwest = null;
		_slopeSoutheast = null;
		
		_slopeThickGentle = null;
		_slopeThinGentle = null;
		_slopeThickSteep = null;
		_slopeThinSteep = null;
		
		super.destroy();
		
		_specialTiles = FlxDestroyUtil.destroyArray(_specialTiles);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (_specialTiles != null && _specialTiles.length > 0) 
		{
			for (tile in _specialTiles) 
			{
				if (tile != null && tile.hasAnimation()) 
				{
					tile.update(elapsed);
				}
			}
		}
	}
	
	/**
	 * THIS IS A COPY FROM FlxTilemap BUT IT DEALS WITH FLIPPED AND ROTATED TILES
	 * Internal function that actually renders the tilemap to the tilemap buffer.  Called by draw().
	 * @param	Buffer		The FlxTilemapBuffer you are rendering to.
	 * @param	Camera		The related FlxCamera, mainly for scroll values.
	 */
	override private function drawTilemap(Buffer:FlxTilemapBuffer, Camera:FlxCamera):Void 
	{
		if (FlxG.renderBlit)
		{
			Buffer.fill();
		}
		else
		{
			getScreenPosition(_point, Camera).copyToFlash(_helperPoint);
			
			_helperPoint.x = isPixelPerfectRender(Camera) ? Math.floor(_helperPoint.x) : _helperPoint.x;
			_helperPoint.y = isPixelPerfectRender(Camera) ? Math.floor(_helperPoint.y) : _helperPoint.y;
		}
		
		var scaledWidth:Float = _tileWidth;
		var scaledHeight:Float = _tileHeight;
		
		var drawX:Float;
		var drawY:Float;
		
		var _tileTransformMatrix:FlxMatrix = null;
		var matrixToUse:FlxMatrix;
		
		var isColored:Bool = ((alpha != 1) || (color != 0xffffff));
		
		// Copy tile images into the tile buffer
		_point.x = (Camera.scroll.x * scrollFactor.x) - x; //modified from getScreenXY()
		_point.y = (Camera.scroll.y * scrollFactor.y) - y;
		var screenXInTiles:Int = Math.floor(_point.x / _tileWidth);
		var screenYInTiles:Int = Math.floor(_point.y / _tileHeight);
		var screenRows:Int = Buffer.rows;
		var screenColumns:Int = Buffer.columns;
		
		// Bound the upper left corner
		screenXInTiles = Std.int(FlxMath.bound(screenXInTiles, 0, widthInTiles - screenColumns));
		screenYInTiles =  Std.int(FlxMath.bound(screenYInTiles, 0, heightInTiles - screenRows));
		
		var rowIndex:Int = screenYInTiles * widthInTiles + screenXInTiles;
		_flashPoint.y = 0;
		var columnIndex:Int;
		var tile:FlxTile;
		var frame:FlxFrame;
		var special:FlxTileSpecial;

		#if !FLX_NO_DEBUG
		var debugTile:BitmapData;
		#end 
		
		var isSpecial = false;
		
		for (row in 0...screenRows)
		{
			columnIndex = rowIndex;
			_flashPoint.x = 0;
			
			for (column in 0...screenColumns)
			{
				isSpecial = false;
				special = null;
				tile = _tileObjects[_data[columnIndex]];
				
				if (_specialTiles != null && _specialTiles[columnIndex] != null) 
				{
					special = _specialTiles[columnIndex];
					isSpecial = special.isSpecial();
				}
				
				if (FlxG.renderBlit)
				{
					if (isSpecial) 
					{
						special.paint(Buffer.pixels, _flashPoint);
						Buffer.dirty = (special.dirty || Buffer.dirty);
					}
					else if (tile != null && tile.visible && tile.frame.type != FlxFrameType.EMPTY)
					{
						tile.frame.paint(Buffer.pixels, _flashPoint, true);
					}
				
			#if !FLX_NO_DEBUG
				if (FlxG.debugger.drawDebug && !ignoreDrawDebug) 
				{
					if (tile != null)
					{
						if (tile.allowCollisions <= FlxObject.NONE)
						{
							debugTile = _debugTileNotSolid; 
						}
						else if (tile.allowCollisions != FlxObject.ANY)
						{
							debugTile = _debugTilePartial; 
						}
						else
						{
							debugTile = _debugTileSolid; 
						}
						
						Buffer.pixels.copyPixels(debugTile, _debugRect, _flashPoint, null, null, true);
					}
				}
			#end
			
				}
				else
				{
					frame = (isSpecial) ? special.currFrame : tile.frame;
					if (tile.visible == false) {
						frame = null;
					}
					if (frame != null)
					{
						drawX = _helperPoint.x + (columnIndex % widthInTiles) * scaledWidth;
						drawY = _helperPoint.y + Math.floor(columnIndex / widthInTiles) * scaledHeight;
						
						if (isSpecial)
						{
							_tileTransformMatrix = special.getMatrix();
							matrixToUse = _tileTransformMatrix;
						}
						else
						{
							frame.prepareMatrix(_matrix);
							matrixToUse = _matrix;
						}
						
						matrixToUse.translate(drawX, drawY);
						Camera.drawPixels(frame, matrixToUse, colorTransform, tile.blend);
					}
				}
				
				if (FlxG.renderBlit)
				{
					_flashPoint.x += _tileWidth;
				}
				columnIndex++;
			}
			
			rowIndex += widthInTiles;
			if (FlxG.renderBlit)
			{
				_flashPoint.y += _tileHeight;
			}
		}
		
		Buffer.x = screenXInTiles * _tileWidth;
		Buffer.y = screenYInTiles * _tileHeight;
		
		if (FlxG.renderBlit)
		{
			if (isColored)
			{
				Buffer.colorTransform(colorTransform);
			}
			Buffer.blend = blend;
		}
	}
	
	/**
	 * Set the special tiles (rotated or flipped)
	 * @param	tiles	An Array with all the FlxTileSpecial
	 */
	public function setSpecialTiles(tiles:Array<FlxTileSpecial>):Void 
	{
		_specialTiles = new Array<FlxTileSpecial>();
		
		var tile:FlxTileSpecial;
		for (i in 0...tiles.length) 
		{
			tile = tiles[i];
			if (tile != null && tile.isSpecial())
			{
				_specialTiles[i] = tile;
				
				tile.currTileId -= _startingIndex;
				tile.frames = this.frames;
				
				if (tile.hasAnimation()) 
				{
					var animFrames:Array<Int> = tile.animation.frames;
					var preparedFrames:Array<Int> = [];
					
					for (j in 0...animFrames.length)
					{
						preparedFrames[j] = animFrames[j] - _startingIndex;
					}
					
					tile.animation.frames = preparedFrames;
				}
			} 
			else 
			{
				_specialTiles[i] = null;
			}
		}
	}
	
	/**
	 * THIS IS A COPY FROM FlxTilemap
	 * I've changed draw() to give a chance to set the buffer dirty
	 * ---
	 * Draws the tilemap buffers to the cameras.
	 */
	override public function draw():Void
	{
		var cameras = cameras;
		var camera:FlxCamera;
		var buffer:FlxTilemapBuffer;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		while (i < l)
		{
			camera = cameras[i];
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			if (_buffers[i] == null)
			{
				_buffers[i] = new FlxTilemapBuffer(_tileWidth, _tileHeight, widthInTiles, heightInTiles, camera);
				_buffers[i].pixelPerfectRender = pixelPerfectRender;
			}
			
			buffer = _buffers[i++];
			
			if (FlxG.renderBlit)
			{
				if (!buffer.dirty)
				{
					// Copied from getScreenXY()
					_point.x = x - (camera.scroll.x * scrollFactor.x) + buffer.x; 
					_point.y = y - (camera.scroll.y * scrollFactor.y) + buffer.y;
					buffer.dirty = (_point.x > 0) || (_point.y > 0) || (_point.x + buffer.width < camera.width) || (_point.y + buffer.height < camera.height);
				}
				
				if (buffer.dirty)
				{
					buffer.dirty = false;
					drawTilemap(buffer, camera);
				}
				
				// Copied from getScreenXY()
				_flashPoint.x = x - (camera.scroll.x * scrollFactor.x) + buffer.x; 
				_flashPoint.y = y - (camera.scroll.y * scrollFactor.y) + buffer.y;
				buffer.draw(camera, _flashPoint);
				
			}
			else
			{
				drawTilemap(buffer, camera);
			}
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
	}

	/**
	 * THIS IS A COPY FROM FlxTilemap BUT IT SOLVES SLOPE COLLISION TOO
	 * Checks if the Object overlaps any tiles with any collision flags set,
	 * and calls the specified callback function (if there is one).
	 * Also calls the tile's registered callback if the filter matches.
	 *
	 * @param 	Object 				The FlxObject you are checking for overlaps against.
	 * @param 	Callback 			An optional function that takes the form "myCallback(Object1:FlxObject,Object2:FlxObject)", where Object1 is a FlxTile object, and Object2 is the object passed in in the first parameter of this method.
	 * @param 	FlipCallbackParams 	Used to preserve A-B list ordering from FlxObject.separate() - returns the FlxTile object as the second parameter instead.
	 * @param 	Position 			Optional, specify a custom position for the tilemap (useful for overlapsAt()-type funcitonality).
	 *
	 * @return Whether there were overlaps, or if a callback was specified, whatever the return value of the callback was.
	 */
	override public function overlapsWithCallback(Object:FlxObject, ?Callback:FlxObject->FlxObject->Bool, FlipCallbackParams:Bool = false, ?Position:FlxPoint):Bool
	{
		var results:Bool = false;
		
		var X:Float = x;
		var Y:Float = y;
		
		if (Position != null)
		{
			X = Position.x;
			Y = Position.y;
		}
		
		//Figure out what tiles we need to check against
		var selectionX:Int = Math.floor((Object.x - X) / _tileWidth);
		var selectionY:Int = Math.floor((Object.y - Y) / _tileHeight);
		var selectionWidth:Int = selectionX + (Math.ceil(Object.width / _tileWidth)) + 1;
		var selectionHeight:Int = selectionY + Math.ceil(Object.height / _tileHeight) + 1;
		
		//Then bound these coordinates by the map edges
		selectionX = FlxMath.maxInt(selectionX, 0);
		selectionY = FlxMath.maxInt(selectionY, 0);
		selectionWidth = FlxMath.minInt(selectionWidth, widthInTiles);
		selectionHeight = FlxMath.minInt(selectionHeight, heightInTiles);
		
		// Then loop through this selection of tiles and call FlxObject.separate() accordingly
		var rowStart:Int = selectionY * widthInTiles;
		var row:Int = selectionY;
		var column:Int;
		var tile:FlxTile;
		var overlapFound:Bool;
		var deltaX:Float = X - last.x;
		var deltaY:Float = Y - last.y;
		
		while (row < selectionHeight)
		{
			column = selectionX;
			
			while (column < selectionWidth)
			{
				overlapFound = false;
				tile = _tileObjects[_data[rowStart + column]];
				
				if (tile.allowCollisions != 0)
				{
					tile.x = X + column * _tileWidth;
					tile.y = Y + row * _tileHeight;
					tile.last.x = tile.x - deltaX;
					tile.last.y = tile.y - deltaY;
					
					if (Callback != null && !tile.isLowSlope)
					{
						if (FlipCallbackParams)
						{
							overlapFound = Callback(Object, tile);
						}
						else
						{
							overlapFound = Callback(tile, Object);
						}
					}
					else
					{
						overlapFound = (Object.x + Object.width > tile.x) && (Object.x < tile.x + tile.width) && (Object.y + Object.height > tile.y) && (Object.y < tile.y + tile.height);
					}
					
					// New generalized slope collisions
					if (overlapFound || (!overlapFound && checkArrays(tile.index)))
					{
						if ((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
						{
							tile.mapIndex = rowStart + column;
							tile.callbackFunction(tile, Object);
						}
						results = true;
					}
				}
				else if ((tile.callbackFunction != null) && ((tile.filter == null) || Std.is(Object, tile.filter)))
				{
					tile.mapIndex = rowStart + column;
					tile.callbackFunction(tile, Object);
				}
				column++;
			}
			
			rowStart += widthInTiles;
			row++;
		}
		
		return results;
	}
	
	/**
	 * Sets the slope arrays, which define which tiles are treated as slopes.
	 * 
	 * @param 	Northwest 	An array containing the numbers of the tiles facing Northwest to be treated as floor tiles with a slope on the left.
	 * @param 	Northeast	An array containing the numbers of the tiles facing Northeast to be treated as floor tiles with a slope on the right.
	 * @param 	Southwest	An array containing the numbers of the tiles facing Southwest to be treated as ceiling tiles with a slope on the left.
	 * @param 	Southeast	An array containing the numbers of the tiles facing Southeast to be treated as ceiling tiles with a slope on the right.
	 */
	public function setSlopes(?Northwest:Array<Int>, ?Northeast:Array<Int>, ?Southwest:Array<Int>, ?Southeast:Array<Int>):Void
	{
		if (Northwest != null)
		{
			_slopeNorthwest = Northwest;
		}
		if (Northeast != null)
		{
			_slopeNortheast = Northeast;
		}
		if (Southwest != null)
		{
			_slopeSouthwest = Southwest;
		}
		if (Southeast != null)
		{
			_slopeSoutheast = Southeast;
		}
		
		setSlopeProperties();
	}
	
	/**
	 * Sets the gentle slopes. About 26.5 degrees.
	 * 
	 * @param 	ThickTiles 	An array containing the numbers of the tiles to be treated as thick slope.
	 * @param 	ThinTiles	An array containing the numbers of the tiles to be treated as thin slope.
	 */
	public function setGentle(ThickTiles:Array<Int>, ThinTiles:Array<Int>) 
	{
		if (ThickTiles != null)
		{
			_slopeThickGentle = ThickTiles;
		}
		
		if (ThinTiles != null)
		{
			_slopeThinGentle = ThinTiles;
			for (tile in _slopeThinGentle)
			{
				_tileObjects[tile].allowCollisions = (_slopeSouthwest.indexOf(tile) >= 0 || _slopeSoutheast.indexOf(tile) >= 0 )? FlxObject.CEILING : FlxObject.FLOOR;
			}
		}
	}
	
	/**
	 * Sets the steep slopes. About 63.5 degrees.
	 * 
	 * @param 	ThickTiles 	An array containing the numbers of the tiles to be treated as thick slope.
	 * @param 	ThinTiles	An array containing the numbers of the tiles to be treated as thin slope.
	 */
	public function setSteep(ThickTiles:Array<Int>, ThinTiles:Array<Int>) 
	{
		if (ThickTiles != null)
		{
			_slopeThickSteep = ThickTiles;
		}
		
		if (ThinTiles != null)
		{
			_slopeThinSteep = ThinTiles;
			for (tile in _slopeThinSteep)
			{
				_tileObjects[tile].allowCollisions = (_slopeSouthwest.indexOf(tile) >= 0 || _slopeNorthwest.indexOf(tile) >= 0 )? FlxObject.RIGHT : FlxObject.LEFT;
			}
		}
	}
	
		/**
	 * Sets the tiles that are treated as "clouds" or blocks that are only solid from the top.
	 * 
	 * @param 	Clouds	An array containing the numbers of the tiles to be treated as clouds.
	 */
	public function setClouds(?Clouds:Array<Int>):Void
	{
		if (Clouds != null)
		{
			for (i in 0...(Clouds.length))
			{
				setTileProperties(Clouds[i], FlxObject.CEILING);			
			}
		}
	}
	
	public function setGentleSlopeProperties(left:Array<Int>,right:Array<Int>):Void
	{
		gentleSlopeFloorLeft = left;
		gentleSlopeFloorRight = right;
		var i:Int;
		for (i in 0...(left.length)) {
			if (left[i] < 0) {
				_tileObjects[Math.floor(Math.abs(left[i]))].isLowSlope = true;
			}
		}
		for (i in 0... (right.length)) {
			if (right[i] < 0) {
				_tileObjects[Math.floor(Math.abs(right[i]))].isLowSlope = true;
			}
		}
	}
	
	/**
	 * Internal helper functions for comparing a tile to the slope arrays to see if a tile should be treated as STEEP or GENTLE slope.
	 * 
	 * @param 	TileIndex	The Tile Index number of the Tile you want to check.
	 * @return	Returns true if the tile is listed in one of the slope arrays. Otherwise returns false.
	 */
	private function checkThickGentle(TileIndex:Int):Bool
	{
		return _slopeThickGentle.indexOf(TileIndex) >= 0;
	}
	
	private function checkThinGentle(TileIndex:Int):Bool
	{
		return _slopeThinGentle.indexOf(TileIndex) >= 0;
	}
	
	private function checkThickSteep(TileIndex:Int):Bool
	{
		return _slopeThickSteep.indexOf(TileIndex) >= 0;
	}
	
	private function checkThinSteep(TileIndex:Int):Bool
	{
		return _slopeThinSteep.indexOf(TileIndex) >= 0;
	}
	
	/**
	 * Bounds the slope point to the slope
	 * 
	 * @param 	Slope 	The slope to fix the slopePoint for
	 */
	private function fixSlopePoint(Slope:FlxTile):Void
	{
		_slopePoint.x = FlxMath.bound(_slopePoint.x, Slope.x, Slope.x + _tileWidth);
		_slopePoint.y = FlxMath.bound(_slopePoint.y, Slope.y, Slope.y + _tileHeight);
	}
	
	/**
	 * Ss called if an object collides with a floor slope
	 * 
	 * @param 	Slope	The floor slope
	 * @param	Object 	The object that collides with that slope
	 */
	//private function onCollideFloorSlope(Slope:FlxObject, Object:FlxObject):Void
	//{
		//// Set the object's touching flag
		//Object.touching = FlxObject.FLOOR;
		//
		//// Adjust the object's velocity
		//Object.velocity.y = Math.min(Object.velocity.y, 0);
		//
		//// Reposition the object
		//Object.y = _slopePoint.y - Object.height;
		//
		//if (Object.y < Slope.y - Object.height) 
		//{ 
			//Object.y = Slope.y - Object.height; 
		//}
	//}
	
	private function onCollideFloorSlope(slope:FlxObject, obj:FlxObject,is_lo_22:Bool,flag:Int	):Void
	{
		if (obj.no_collide_floor_slopes) {
			
			return;
		}

		//set the object's touching flag
		obj.touching |= FlxObject.FLOOR;
		obj.touching |= flag;
		obj.touching_floor_slope = true;
		
		//adjust the object's velocity
		obj.velocity.y = 0;
		
		//reposition the object
		obj.y = _slopePoint.y - obj.height;
		if (obj.y < slope.y - obj.height) { obj.y = slope.y - obj.height; };
		// TODO what if walking down big slope ugh
		if (is_lo_22 && _slopePoint.y <= slope.y + 8) {
			obj.y = slope.y - obj.height + 8;
		}
	}	
	
	
	/**
	 * Is called if an object collides with a ceiling slope
	 * 
	 * @param 	Slope 	The ceiling slope
	 * @param 	Object 	The object that collides with that slope
	 */
	//private function onCollideCeilSlope(Slope:FlxObject, Object:FlxObject):Void
	//{
		//// Set the object's touching flag
		//Object.touching = FlxObject.CEILING;
		//
		//// Adjust the object's velocity
		//Object.velocity.y = Math.max(Object.velocity.y, 0);
		//
		//// Reposition the object
		//Object.y = _slopePoint.y;
		//
		//if (Object.y > Slope.y + _tileHeight) 
		//{ 
			//Object.y = Slope.y + _tileHeight; 
		//}
	//}
	private function onCollideCeilSlope(slope:FlxObject,  obj:FlxObject,left:Bool):Void
	{
			
		//set the object's touching flag
		if (left) {
			obj.touching |= FlxObject.CEILING | FlxX.SLOPE_LEFT;
		} else {
			obj.touching |= FlxObject.CEILING | FlxX.SLOPE_RIGHT;
		}


		//adjust the object's velocity
		//obj.velocity.y = 0;

		//reposition the object
		obj.y = _slopePoint.y;
		if (obj.y > slope.y + _tileHeight) { obj.y = slope.y + _tileHeight; };
	}
	
	
	/**
	 * Solves collision against a left-sided floor slope
	 * 
	 * @param 	Slope 	The slope to check against
	 * @param 	Object 	The object that collides with the slope
	 */
	/*
	private function solveCollisionSlopeNorthwest(Slope:FlxObject, Object:FlxObject):Void
	{
		// Calculate the corner point of the object
		_objPoint.x = Math.floor(Object.x + Object.width + _snapping);
		_objPoint.y = Math.floor(Object.y + Object.height);
		
		// Calculate position of the point on the slope that the object might overlap
		// this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (Slope.y + _tileHeight) - (_slopePoint.x - Slope.x);
		
		var tileId:Int = cast(Slope, FlxTile).index;
		if (checkThinSteep(tileId))
		{
			if (_slopePoint.x - Slope.x <= _tileWidth / 2)
			{
				return;
			}
			else
			{
				_slopePoint.y = Slope.y + _tileHeight * (2 - (2 * (_slopePoint.x - Slope.x) / _tileWidth)) + _snapping;
			}
		}
		else if (checkThickSteep(tileId))
		{
			_slopePoint.y = Slope.y + _tileHeight * (1 - (2 * ((_slopePoint.x - Slope.x) / _tileWidth))) + _snapping;
		}
		else if (checkThickGentle(tileId))
		{
			_slopePoint.y = Slope.y + (_tileHeight - _slopePoint.x + Slope.x) / 2;
		}
		else if (checkThinGentle(tileId))
		{
			_slopePoint.y = Slope.y + _tileHeight - (_slopePoint.x - Slope.x) / 2;
		}
		
		// Fix the slope point to the slope tile
		fixSlopePoint(cast(Slope, FlxTile));
		
		// Check if the object is inside the slope
		if (_objPoint.x > Slope.x + _snapping && _objPoint.x < Slope.x + _tileWidth + Object.width + _snapping && _objPoint.y >= _slopePoint.y && _objPoint.y <= Slope.y + _tileHeight)
		{
			// Call the collide function for the floor slope
			onCollideFloorSlope(Slope, Object);
		}
	}
	
	*/
		/**
	 * Solves collision against a left-sided floor slope
	 * 
	 * @param 	Slope 	The slope to check against
	 * @param 	Object 	The object that collides with the slope
	 */
	private function solveCollisionSlopeNorthwest(slope:FlxObject, obj:FlxObject):Void
	{
		//calculate the corner point of the object
		//_objPoint.x = FlxU.floor(obj.x + obj.width + _snapping);
		_objPoint.x = Math.floor(obj.x + obj.width );
		_objPoint.y = Math.floor(obj.y + obj.height);
		obj.did_slopes |= 0x0100;
		
		//calculate position of the point on the slope that the object might overlap
		//this would be one side of the object projected onto the slope's surface
		
		// _SLOPEPOINT will be the new position of the obj's corner
		_slopePoint.x = _objPoint.x;
		var i:Int;
		var found:Bool = false;
		var is_22_lo:Bool = false;
		var ft:FlxTile = cast(slope, FlxTile);
		for (i in 0...(gentleSlopeFloorLeft.length)) {
			if (Math.abs(gentleSlopeFloorLeft[i]) == ft.index) {
				if (gentleSlopeFloorLeft[i] > 0) { // high 
					_slopePoint.y = (slope.y + _tileHeight) - (_slopePoint.x - slope.x) / 2 - _tileHeight / 2 + 1;
					_slopePoint.y = Math.floor(_slopePoint.y);
					
					found  = true;
					obj._minslopebump = 8;
					break;
				} else {// low
					// Hack, if player velocity is < 0 don't collide 
					if (obj.velocity.y < 0) return;
					_slopePoint.y = (slope.y + _tileHeight) - (_slopePoint.x - slope.x) / 2; //change
					_slopePoint.y = Math.floor(_slopePoint.y);
					is_22_lo = true;
					found = true;
					break;
				}
			}
		}
		if (!found)
		_slopePoint.y = (slope.y + _tileHeight) - (_slopePoint.x - slope.x); //change
		
		//fix the slope point to the slope tile
		fixSlopePoint(cast(slope, FlxTile));
		
		// Only snap if we are moving down it and not jumping
		
		var ysnap:Int = (obj.velocity.x < 0 && obj.velocity.y > 0) ? 4 : 0;
		_snapping = 0;
		if (_objPoint.y < slope.y) {
			return;
		}
		if (_slopePoint.y - slope.y >= 1) _slopePoint.y -- ;
		//check if the object is inside the slope
		if (_objPoint.x > slope.x  && _objPoint.x < slope.x + _tileWidth + obj.width + _snapping && _objPoint.y >= _slopePoint.y - ysnap && _objPoint.y <= slope.y + _tileHeight)
		{
			//FlxG.log.clear();
			//FlxG.log.add(obj.wasTouching);
			//FlxG.log.add(obj.no_collide_floor_slopes);
			//FlxG.log.add([obj.last.x+obj.width, obj.x+obj.width, slope.x]);
			//don't collide if the collision pt is below the slope (so we can jump through)
			if (obj.last.y + obj.height - 2  > _slopePoint.y) {
				if (obj.last.x  + obj.width - 1 <= slope.x && obj.x + obj.width >= slope.x && obj.wasTouching == FlxObject.DOWN) {
				} else if (obj.wasTouching & FlxObject.RIGHT == 0) {
					return;
				}
			}
			if (obj.velocity.y < -20) {
				return;
			}
			
			//call the collide function for the floor slope
			if (is_22_lo && obj._minslopebump == 0) {
				onCollideFloorSlope(slope, obj, is_22_lo,FlxObject.RIGHT);
			} else if (!is_22_lo){ 
				onCollideFloorSlope(slope, obj, is_22_lo,FlxObject.RIGHT);
			}
		}
		_snapping = 2;
		
		
	}
	
	
	
	/**
	 * Solves collision against a right-sided floor slope
	 * 
	 * @param 	Slope 	The slope to check against
	 * @param 	Object 	The object that collides with the slope
	 */
	/*private function solveCollisionSlopeNortheast(Slope:FlxObject, Object:FlxObject):Void
	{
		// Calculate the corner point of the object
		_objPoint.x = Math.floor(Object.x - _snapping);
		_objPoint.y = Math.floor(Object.y + Object.height);
		
		// Calculate position of the point on the slope that the object might overlap
		// this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (Slope.y + _tileHeight) - (Slope.x - _slopePoint.x + _tileWidth);
		
		var tileId:Int = cast(Slope, FlxTile).index;
		if (checkThinSteep(tileId))
		{
			if (_slopePoint.x - Slope.x >= _tileWidth / 2)
			{
				return;
			}
			else
			{
				_slopePoint.y = Slope.y + _tileHeight * 2 * ((_slopePoint.x - Slope.x) / _tileWidth) + _snapping;
			}
		}
		else if (checkThickSteep(tileId))
		{
			_slopePoint.y = Slope.y - _tileHeight * (1 + (2 * ((Slope.x - _slopePoint.x) / _tileWidth))) + _snapping;
		}
		else if (checkThickGentle(tileId))
		{
			_slopePoint.y = Slope.y + (_tileHeight - Slope.x + _slopePoint.x - _tileWidth) / 2;
		}
		else if (checkThinGentle(tileId))
		{
			_slopePoint.y = Slope.y + _tileHeight - (Slope.x - _slopePoint.x + _tileWidth) / 2;
		}
		
		// Fix the slope point to the slope tile
		fixSlopePoint(cast(Slope, FlxTile));
		
		// Check if the object is inside the slope
		if (_objPoint.x > Slope.x - Object.width - _snapping && _objPoint.x < Slope.x + _tileWidth + _snapping && _objPoint.y >= _slopePoint.y && _objPoint.y <= Slope.y + _tileHeight)
		{
			// Call the collide function for the floor slope
			onCollideFloorSlope(Slope, Object);
		}
	}
	*/
	
	/**
	 * Solves collision against a right-sided floor slope
	 * 
	 * @param 	Slope 	The slope to check against
	 * @param 	Object 	The object that collides with the slope
	 */
	private function solveCollisionSlopeNortheast(slope:FlxObject, obj:FlxObject):Void
	{
		//calculate the corner point of the object
		_objPoint.x = Math.floor(obj.x);
		_objPoint.y = Math.floor(obj.y + obj.height);
		
		obj.did_slopes |= 0x01;
		
		//calculate position of the point on the slope that the object might overlap
		//this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		
		var i:Int;
		var is_22_low:Bool = false;
		var found:Bool = false;
		var ft:FlxTile = cast(slope, FlxTile);
		for (i in 0...(gentleSlopeFloorRight.length)) {
			if (Math.abs(gentleSlopeFloorRight[i]) == ft.index) {
				if (gentleSlopeFloorRight[i] > 0) { // high 
					//_slopePoint.y = (slope.y + _tileHeight) - (_slopePoint.x - slope.x) / 2 - _tileHeight / 2 + 1;
					_slopePoint.y = (slope.y) + (_slopePoint.x - slope.x) / 2;
					_slopePoint.y = Math.floor(_slopePoint.y);
					obj._minslopebump = 8;
					found  = true;
					break;
				} else {// low
					// same hack as slopeleft
					if (obj.velocity.y < 0) return;
					_slopePoint.y = (slope.y) + (_slopePoint.x - slope.x) / 2 + _tileHeight / 2;
					_slopePoint.y = Math.floor(_slopePoint.y);
					is_22_low = true;
					found = true;
					break;
				}
			}
		}
		if (!found) // then it's a 45 deg slope
		//_slopePoint.y = (slope.y + _tileHeight) - (slope.x - _slopePoint.x + _tileWidth);
		_slopePoint.y = (slope.y) + (_slopePoint.x - slope.x);
		
		//fix the slope point to the slope tile
		fixSlopePoint(cast(slope, FlxTile));
		
		// Expand snap-space of the tile if we're walking down it to allow jumping/prevent awkward bumping
		var ysnap:Int = (obj.velocity.x > 0 && obj.velocity.y > 0) ? 4 : 0;
		_snapping = 0;
		//check if the object is inside the slope
		if (_objPoint.x > slope.x - obj.width  && _objPoint.x < slope.x + _tileWidth + _snapping && _objPoint.y >= _slopePoint.y - ysnap && _objPoint.y <= slope.y + _tileHeight)
		{
			
			
			// If the collide point is in within the solid pat of the slope but not close enough to the diagonal edge, don't collide if the object hasn't been on the slope already.
			// This also rpevents the object from clipping up through the tile (the first if block), which lets you walk from the left onto the slope
			if (obj.last.y + obj.height - 2  > _slopePoint.y) {
				if (obj.last.x +1 >= slope.x && obj.x <= slope.x && obj.wasTouching == FlxObject.DOWN) {
				} else if (obj.wasTouching & FlxObject.LEFT== 0) {
					return;
				}
			}
			
			//call the collide function for the floor slope		
			if (is_22_low && obj._minslopebump == 0) {
				onCollideFloorSlope(slope, obj, is_22_low,FlxObject.LEFT);
			} else if (!is_22_low){
				onCollideFloorSlope(slope, obj, is_22_low,FlxObject.LEFT);
			}
		}
		_snapping = 2;
	}

	
	/**
	 * Solves collision against a left-sided ceiling slope
	 * 
	 * @param 	Slope 	The slope to check against
	 * @param 	Object 	The object that collides with the slope
	 */
	private function solveCollisionSlopeSouthwest(Slope:FlxObject, Object:FlxObject):Void
	{
		// Calculate the corner point of the object
		_objPoint.x = Math.floor(Object.x + Object.width + _snapping);
		_objPoint.y = Math.ceil(Object.y);
		
		Object.did_slopes |= 0x1000;
		// Calculate position of the point on the slope that the object might overlap
		// this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = Slope.y + (_slopePoint.x - Slope.x);
		
		var tileId:Int = cast(Slope, FlxTile).index;
		if (checkThinSteep(tileId))
		{
			if (_slopePoint.x - Slope.x <= _tileWidth / 2)
			{
				return;
			}
			else
			{
				_slopePoint.y = Slope.y - _tileHeight * (1 + (2 * ((Slope.x - _slopePoint.x) / _tileWidth))) - _snapping;
			}
		}
		else if (checkThickSteep(tileId))
		{
			_slopePoint.y = Slope.y + _tileHeight * 2 * ((_slopePoint.x - Slope.x) / _tileWidth) - _snapping;
		}
		else if (checkThickGentle(tileId))
		{
			_slopePoint.y = Slope.y + _tileHeight - (Slope.x - _slopePoint.x + _tileWidth) / 2;
		}
		else if (checkThinGentle(tileId))
		{
			_slopePoint.y = Slope.y + (_tileHeight - Slope.x + _slopePoint.x - _tileWidth) / 2;
		}
		
		// Fix the slope point to the slope tile
		fixSlopePoint(cast(Slope, FlxTile));
		
		// Check if the object is inside the slope
		if (_objPoint.x > Slope.x + _snapping && _objPoint.x < Slope.x + _tileWidth + Object.width + _snapping && _objPoint.y <= _slopePoint.y && _objPoint.y >= Slope.y)
		{
			// Call the collide function for the floor slope
			//onCollideCeilSlope(Slope, Object);
			onCollideCeilSlope(Slope, Object,true);
		}
	}
	
	/**
	 * Solves collision against a right-sided ceiling slope
	 * 
	 * @param 	Slope 	The slope to check against
	 * @param 	Object 	The object that collides with the slope
	 */
	private function solveCollisionSlopeSoutheast(Slope:FlxObject, Object:FlxObject):Void
	{
		// Calculate the corner point of the object
		_objPoint.x = Math.floor(Object.x - _snapping);
		_objPoint.y = Math.ceil(Object.y);
		Object.did_slopes |= 0x10;
		
		// Calculate position of the point on the slope that the object might overlap
		// this would be one side of the object projected onto the slope's surface
		_slopePoint.x = _objPoint.x;
		_slopePoint.y = (Slope.y) + (Slope.x - _slopePoint.x + _tileWidth);
		
		var tileId:Int = cast(Slope, FlxTile).index;
		if (checkThinSteep(tileId))
		{
			if (_slopePoint.x - Slope.x >= _tileWidth / 2)
			{
				return;
			}
			else
			{
				_slopePoint.y = Slope.y + _tileHeight * (1 - (2 * ((_slopePoint.x - Slope.x) / _tileWidth))) - _snapping;
			}
		}
		else if (checkThickSteep(tileId))
		{
			_slopePoint.y = Slope.y + _tileHeight * (2 - (2 * (_slopePoint.x - Slope.x) / _tileWidth)) - _snapping;
		}
		else if (checkThickGentle(tileId))
		{
			_slopePoint.y = Slope.y + _tileHeight - (_slopePoint.x - Slope.x) / 2;
		}
		else if (checkThinGentle(tileId))
		{
			_slopePoint.y = Slope.y + (_tileHeight - _slopePoint.x + Slope.x) / 2;
		}
		
		// Fix the slope point to the slope tile
		fixSlopePoint(cast(Slope, FlxTile));
		
		// Check if the object is inside the slope
		if (_objPoint.x > Slope.x - Object.width - _snapping && _objPoint.x < Slope.x + _tileWidth + _snapping && _objPoint.y <= _slopePoint.y && _objPoint.y >= Slope.y)
		{
			// Call the collide function for the floor slope
			//onCollideCeilSlope(Slope, Object);
			onCollideCeilSlope(Slope, Object,false);
		}
	}
	
	/**
	 * Internal helper function for setting the tiles currently held in the slope arrays to use slope collision.
	 * Note that if you remove items from a slope, this function will not unset the slope property.
	 */
	private function setSlopeProperties():Void
	{
		for (tile in _slopeNorthwest)
		{
			setTileProperties(tile, 0x10000, solveCollisionSlopeNorthwest);
		}
		for (tile in _slopeNortheast)
		{
			setTileProperties(tile, 0x10000, solveCollisionSlopeNortheast);
		}
		for (tile in _slopeSouthwest)
		{
			setTileProperties(tile, FlxObject.RIGHT | FlxObject.CEILING, solveCollisionSlopeSouthwest);
		}
		for (tile in _slopeSoutheast)
		{
			setTileProperties(tile, FlxObject.LEFT | FlxObject.CEILING, solveCollisionSlopeSoutheast);
		}
	}
	
	/**
	 * Internal helper function for comparing a tile to the slope arrays to see if a tile should be treated as a slope.
	 * 
	 * @param 	TileIndex	The Tile Index number of the Tile you want to check.
	 * @return	Returns true if the tile is listed in one of the slope arrays. Otherwise returns false.
	 */
	private function checkArrays(TileIndex:Int):Bool
	{
		return _slopeNorthwest.indexOf(TileIndex) >= 0 || _slopeNortheast.indexOf(TileIndex) >= 0 || _slopeSouthwest.indexOf(TileIndex) >= 0 || _slopeSoutheast.indexOf(TileIndex) >= 0;
	}
	
	override private function set_frames(value:FlxFramesCollection):FlxFramesCollection
	{
		super.set_frames(value);
		
		if (value != null && _specialTiles != null && _specialTiles.length > 0)
		{
			for (tile in _specialTiles) 
			{
				if (tile != null) 
				{
					tile.frames = frames;
				}
			}
		}
		
		return value;
	}
}