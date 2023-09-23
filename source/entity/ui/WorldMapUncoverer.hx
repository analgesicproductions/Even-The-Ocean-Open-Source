package entity.ui;
import autom.EMBED_TILEMAP;
import entity.MySprite;
import flash.display.BitmapData;
import flash.geom.Point;
import flixel.util.FlxStringUtil;
import global.C;
import global.Registry;
import haxe.Log;
import help.FlxX;
import help.HF;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import state.MyState;
#if cpp

#end

/**
 * A layer that goes over an AreaMap (for a World Map, usually) and uncovers based on some
 * "uncoverer" object (the player)
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class WorldMapUncoverer extends FlxTilemap
{

	public static var tileset:BitmapData;
	public var cover:FlxTilemap;
	public var uncoverer:FlxObject;
	public var coords_to_flip:Array<Int>;
	
	public var rect_cover:FlxSprite;
	public var player_rep:FlxSprite;
	public var cursor:FlxSprite;
	private var the_width:Int = 0;
	private var the_height:Int = 0;
	private var parent:MyState;
	private var opaque_color:Int = 0xccffff28;
	private var revealed_walkable_color:Int = 0xaaff0000;
	private var revealed_solid_color:Int = 0xaa00ff00;
	
	public var doors:FlxGroup;
	
	private var MAP_TYPE_HIDDEN:Int = 2;
	private var MAP_TYPE_REVEALED_SOLID:Int = 1;
	private var MAP_TYPE_REVEALED_WALKABLE:Int = 0;
	
	private var R:Registry;
	
	public function new(w:Int,h:Int,_uncoverer:FlxObject,_parent:MyState) 
	{
		R = Registry.R;
		if (tileset == null) {
			tileset = Assets.getBitmapData("assets/tileset/WorldMapUncoverer_1px.png");
			//tileset = Assets.getBitmapData("assets/tileset/DEBUG_anims.png");
		}
		
		doors = new FlxGroup();
		player_rep = new FlxSprite(0, 0);
		player_rep.makeGraphic(3, 3, 0xffff0000); 
		player_rep.scrollFactor.set(0, 0);
	
		parent = _parent;
		coords_to_flip = [];
		uncoverer = _uncoverer;
		the_width = w;
		the_height = h;
		super();
		
		loadMapFromCSV(FlxX.createEmptyCSV(w,h,MAP_TYPE_HIDDEN), tileset, 1,1);
		scrollFactor.set(0, 0);
		x = y = 0;
		
		rect_cover = new FlxSprite(0, 0);
		rect_cover.makeGraphic(w, h, opaque_color,true);
		rect_cover.scrollFactor.set(0, 0);
		for (_y in 0...h) {
			for (_x in 0...w) {
				rect_cover.pixels.setPixel32(_x, _y, opaque_color);
			}
		}
		
		
		cursor = new FlxSprite(0, 0);
		cursor.scrollFactor.set(0, 0);
		cursor.makeGraphic(4, 4, 0xff00ff00);
		cursor.visible = false;
	}
	
	public function change_exists(b:Bool):Void {
		rect_cover.exists = b;
		exists = b;
		player_rep.exists = b;
		doors.exists = b;
	}
	
	public function move_to_top_of_draw_group(ms:MyState):Void {
		ms.remove(this, true);
		ms.remove(rect_cover, true);
		ms.remove(player_rep, true);
		ms.remove(doors, true);
		ms.remove(cursor, true);
		add(ms);
	}
	public function add(ms:MyState):Void {
		ms.add(this);
		ms.add(rect_cover);
		ms.add(player_rep);
		ms.add(doors);
		ms.add(cursor);
	}
	
	/**
	 * Called from the pause menu, this is because the pause menu never actually contains the worl dmap uncoverer.
	 * this allows it to update within the pause menu so yuo move cursor around/etc
	 */
	public function update_others():Void {
		rect_cover.postUpdate(FlxG.elapsed);
		player_rep.postUpdate(FlxG.elapsed);
		//doors.postUpdate(elapsed);
		cursor.postUpdate(FlxG.elapsed);
	}
	override public function update(elapsed: Float):Void {
		
		player_rep.x = rect_cover.x + Std.int(R.activePlayer.x / 16) - 1;
		player_rep.y = rect_cover.y + Std.int(R.activePlayer.y / 16) - 1;
		super.update(elapsed);
	}
	
	
	public function make_invisible():Void {
		rect_cover.visible = false;
		player_rep.visible = false;
		doors.visible = false;
		cursor.visible = false;
		
	}
	public function make_visible():Void {
		// cursor set visible in pausemenu
		rect_cover.visible = true;
		player_rep.visible = true;
		doors.visible = true;
	}
	private var ticks:Int = 0;
	override public function draw():Void 
	{
		ticks++;
		if (ticks < 30) return;
		ticks = 0;
		var tx:Int = Std.int(uncoverer.x / 16);
		var ty:Int = Std.int(uncoverer.y / 16);
		for (i in -10...10) {
			if (ty + i < 0 || ty + i >= the_height) {
				continue;
			}
			for (j in -8...8) {
				if (tx + j < 0 || tx + j >= the_width) {
					continue;
				}
				if (parent.tm_bg.getTileCollisionFlags(16 * (tx + j), 16 * (ty + i)) != 0) {
					rect_cover.pixels.setPixel32(tx + j, ty + i, revealed_solid_color);
					setTileByIndex((ty + i)*widthInTiles + tx + j, MAP_TYPE_REVEALED_SOLID, true);
				} else {
					rect_cover.pixels.setPixel32(tx + j, ty + i, revealed_walkable_color);
					setTileByIndex((ty + i)*widthInTiles + tx + j, MAP_TYPE_REVEALED_WALKABLE, true);
				}
			}
		}
		
		//super.draw();
	}
	public var save_string:String = "";
	
	public static var mapone_string:String = "";
	public function load_data_from_save(save_csv:String,map_name:String,w:Int,h:Int):Void {
		loadMapFromCSV(HF.decompress_csv(save_csv), tileset, 16, 16);
		rect_cover.makeGraphic(w,h, opaque_color); // Allow for map expanding/contracting in future
		for (i in 0...h) {
			for (j in 0...w) {
				if (getTile(j, i) == MAP_TYPE_REVEALED_SOLID) {
					rect_cover.pixels.setPixel32(j,i, revealed_solid_color);
				} else  if (getTile(j,i) == MAP_TYPE_REVEALED_WALKABLE) {
					rect_cover.pixels.setPixel32(j,i, revealed_walkable_color);
				} else {
					rect_cover.pixels.setPixel32(j,i, opaque_color);
				}
			}
		}
		
	
		refresh_doors(map_name);	
	}
	
	public function temp_save_save_string(map:String):Void {
		if (map == "MAPONE") {
			mapone_string = get_save_string();
		}
	}
	private function get_save_string():String {
		return HF.compress_csv(FlxStringUtil.arrayToCSV(getData(), widthInTiles));
	}
	
	public function refresh_doors(name:String):Void 
	{
		//var other_map_dim:Point = HF.get_csv_dimensions(EMBED_TILEMAP.csv_hash.get(other_map_name.toUpperCase() + "_BG"));
		doors.callAll("destroy");
		doors.clear();
		var door_rows:Array<Array<String>> = HF.get_entity_query(name, ["Door", "x", "y", "s_visited", "dest_map"]);
		var door_row:Array<String> = [];
		for (door_row in door_rows) {
			if (door_row[2] == "1") {
				var door_sprite:MySprite = new MySprite();
				door_sprite.scrollFactor.set(0, 0);
				door_sprite.makeGraphic(3, 3, 0xff000000);
				door_sprite.x = rect_cover.x + Std.parseInt(door_row[0]) / 16;
				door_sprite.y = rect_cover.y + Std.parseInt(door_row[1]) / 16;
				door_sprite.name = EMBED_TILEMAP.actualname_hash.get(door_row[3].split("\"")[1]);
				doors.add(door_sprite);
			}
		}
	
	}
	
	public function move_to(x:Float, y:Float, center:Bool = false):Void {
		if (center) {
			rect_cover.x = (C.GAME_WIDTH - rect_cover.width) / 2;
			rect_cover.y = (C.GAME_HEIGHT - rect_cover.height) / 2;
		} else {
			rect_cover.x = x;
			rect_cover.y = y;
		}
		
		
		player_rep.x = rect_cover.x + Std.int(R.activePlayer.x / 16) - 1;
		player_rep.y = rect_cover.y + Std.int(R.activePlayer.y / 16) - 1;
		
		refresh_doors(parent.MAP_NAME);
	}
	
	public function maybe_load_save_string(map:String,w:Int,h:Int):Void {
		if (map == "MAPONE" && mapone_string != "") {
			load_data_from_save(mapone_string,map,w,h);
		}
	}
	
	public static function reset_strings():Void {
		mapone_string = "";
	}
	
}