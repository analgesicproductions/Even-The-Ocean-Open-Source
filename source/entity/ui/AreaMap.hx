package entity.ui;
import global.C;
import global.Registry;
import haxe.Log;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.geom.Point;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.MyState;

/**
 * An area map based on the tilemap 
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class AreaMap extends FlxGroup
{

	private var mode:Int;
	private var MODE_IDLE:Int = 0;
	private var MODE_AREA:Int = 1;
	private var R:Registry;
	private var map:FlxSprite;
	private var player_rep:FlxSprite;
	
	private var map_cover:FlxSprite;
	private var map_cover_eraser:FlxSprite;
	
	private var COLOR_SOLID:Int = 0xccffffff;
	private var COLOR_CLOUD:Int = 0xffff0000;
	private var COLOR_BG:Int = 0x66ff00ff;
	private var COLOR_NONSOLID:Int = 0xcc111111;
	private var COLOR_UNVISITED:Int = 0xcc888888;
	
	
	public function new() 
	{
		super(0, "AreaMap");
		
		mode = MODE_IDLE;
		map = new FlxSprite(0, 0);
		map.scrollFactor.set(0, 0);
		map.makeGraphic(250,250, 0x00000000,false,"areamap");
		add(map);
		
		player_rep = new FlxSprite(0, 0);
		player_rep.scrollFactor.set(0, 0);
		player_rep.makeGraphic(2, 2, 0xffff0000);
		add(player_rep);	
		
		map_cover_eraser = new FlxSprite(0, 0);
		map_cover_eraser.makeGraphic(Std.int(C.GAME_WIDTH / 16), Std.int(C.GAME_HEIGHT / 16), 0xffffffff);
		map_cover_eraser.scrollFactor.set(0, 0);
		map_cover = new FlxSprite(0, 0);
		map_cover.scrollFactor.set(0, 0);
		
		//add(map_cover);
		
		R = Registry.R;
	}
		
	
	override public function update(elapsed: Float):Void {
		super.update(elapsed);
		
		player_rep.x = Std.int(R.activePlayer.x / 16);
		player_rep.y = Std.int(R.activePlayer.y / 16);
		
	}
	
	override public function draw():Void {
		super.draw();
	}
	
	public function is_idle():Bool {
		if (mode == MODE_IDLE) {
			return true;
		}
		return false;
	}
	
	public function is_visible():Bool {
		return map.visible;
	}
	public function turn_on(container_state:MyState):Void {
		map.visible = true;
		player_rep.visible = true;
		change_mode(MODE_AREA,container_state);
	}
	public function turn_off():Void {
		player_rep.visible = false;
		map.visible = false;
	}
	
	private function change_mode(_mode:Int,container_state:MyState):Void {
		switch (_mode) {
			case _ if (_mode == MODE_AREA):
				mode = MODE_AREA;
				clear_map(map);
				var dim:Point = container_state.get_map_dimensions();
				init_map_cover(map_cover,container_state.MAP_NAME,dim);
				var solid_layers:Array<FlxTilemapExt> = [container_state.tm_bg, container_state.tm_bg2];
				var solid_layer:FlxTilemapExt;
				var is_solid:Bool = false;
				var is_cloud:Bool = false;
				var is_bg_decoration:Bool = false;
				map.pixels.lock();
				var i:Int = 0;
				for (y in 0...Std.int(dim.y)) {
					for (x in 0...Std.int(dim.x)) {
						
						//for (solid_layer in solid_layers) {
						switch (solid_layers[0].getTileCollisionFlags(x * 16, y * 16)) {
							case FlxObject.CEILING:
								is_cloud = true;
							case FlxObject.ANY:
								is_solid = true;
							case FlxObject.NONE:
								if (solid_layers[0].getTileID(x * 16, y * 16) != 0) {
									is_bg_decoration = true;
								}
								
						}
						//}
						if (is_solid) {
							map.pixels.setPixel32(x, y, COLOR_SOLID);
						} else if (is_cloud) {
							map.pixels.setPixel32(x, y, COLOR_CLOUD);
						} else if (is_bg_decoration) {
							map.pixels.setPixel32(x, y, COLOR_BG);
						} else {
							i++;
							map.pixels.setPixel32(x, y, COLOR_NONSOLID);
						}
						is_solid = false;
						is_bg_decoration = false;
						is_cloud = false;
					}
				}
				map.pixels.unlock();
				map.dirty = true;
				// Do stuff
		}
	}
	
	private function init_map_cover(_map_cover:FlxSprite, map_name:String, dim:Point):Void {
		_map_cover.blend = BlendMode.MULTIPLY;
		_map_cover.makeGraphic(Std.int(dim.x), Std.int(dim.y), 0xff000000);
		_map_cover.fill(0x00000000);
	}
	private function clear_map(_map:FlxSprite):Void {
		_map.pixels.lock();
		for (y in 0...Std.int(_map.height)) {
			for (x in 0...Std.int(_map.width)) {
				_map.pixels.setPixel32(x, y, 0x00000000);
			}
		}
		_map.pixels.unlock();
	}
}