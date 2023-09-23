package entity.ui;
import autom.EMBED_TILEMAP;
import flash.geom.Point;
import flash.geom.Vector3D;
import global.C;
import global.Registry;
import haxe.Log;
import help.HF;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.math.FlxRect;
import flixel.group.FlxGroup;
import state.MyState;
#if cpp
import sys.io.File;
#end

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class MenuMap extends FlxGroup
{

	
	private static var m:Map<String,Dynamic>;
	private var rects:FlxTypedGroup<FlxSprite>;
	private var rect_area_names:Array<String>;
	private var active_rect:FlxSprite;
	private var player_marker:FlxSprite;
	private var door_markers:FlxGroup; 
	private var menu_map_top_left:Point;
	private var cursor:FlxSprite;
	private var R:Registry;
	private var area_name:String;
	private var area_title:FlxBitmapText;
	private var door_icons:FlxTypedGroup<FlxSprite>;
	private var lineinfos:Array<Array<Dynamic>>;
	
	private var cur_map_width:Int = 1;
	private var cur_map_height:Int = 1;
	
	
	public function new() 
	{
		super(0, "MenuMap");
		load_maprects_son(false);
		menu_map_top_left = new Point(30, 48);
		rects = new FlxTypedGroup<FlxSprite>();
	}
	
	public static function load_maprects_son(from_dev:Bool=false):Void {
		var p:String = "";
		if (from_dev) {
			p = C.EXT_ASSETS + "misc/maprects.son";
		} else {
			p = "assets/misc/maprects.son";
		}
		
		var s:String = "";
		#if cpp
		s = File.getContent(p);
		#end
		#if flash
		s = Assets.getText("assets/misc/maprects.son");
		#end
		
		m = HF.parse_SON(s);
		
	}
	
	private var did_init:Bool = false;
	private function do_init():Void {
		if (did_init) return;
		did_init = true;
		
		R = Registry.R;
		
		player_marker = new FlxSprite();
		player_marker.scrollFactor.set(0, 0);
		player_marker.makeGraphic(3, 3, 0xffff0000);
		
		cursor = new FlxSprite();
		cursor.scrollFactor.set(0, 0);
		cursor.makeGraphic(4, 4, 0xff00ff00);
		cursor.maxVelocity.y = cursor_maxvel;
		cursor.maxVelocity.x = cursor_maxvel;
		
		area_title = HF.init_bitmap_font(" ", "center", 0, 8, null, C.FONT_TYPE_APPLE_WHITE);
		door_icons = new FlxTypedGroup<FlxSprite>();
		add(rects);
		add(door_icons);
		add(player_marker);
		add(cursor);
		add(area_title);
	}
	/**
	 * Load the next map's menu map - remove all current sprites,
	 * and then look it up in the SON object
	 * @param	area_name
	 * @return whether or not we managed to load a new map
	 */
	public function load_map(map_name:String, cur_state:MyState):Bool {
		// allocate and add groups
		do_init();

		// Clear old stuff
		rects.callAll("destroy");
		rects.clear();
		rect_area_names = [];
		
		door_icons.callAll("destroy");
		door_icons.clear();
		
		lineinfos = [];
		area_title.visible = player_marker.visible = cursor.visible = false;
		
		map_name = map_name.toLowerCase();
		
		
		
		// Find rect info
		var map_info:Map<String,Dynamic> = null;
		var a:Array<String> = [];
		var found:Bool = false;
		for (k in m.keys()) {
			map_info = m.get(k);
			var s:String = map_info.get("maps");
			a = s.split(",");
			for (i in 0...a.length) {
				if (map_name == a[i]) {
					area_name = k;
					found = true;
					break;
				}
			}
			if (found) break;
		}
		if (!found) {
			//Log.trace("No menu map found for " + map_name);
			return false;
		}
		
		// Create rectangles
		var other_map_name:String = "";
		for (other_map_name in a) {
			var ia:Array<Int> = map_info.get(other_map_name);
			var r:FlxSprite = new FlxSprite(0, 0);
			r.scrollFactor.set(0, 0);
			r.makeGraphic(ia[2], ia[3], 0xffffffff);
			r.alpha = 0.6;
			r.x = ia[0];
			r.y = ia[1];
			rects.add(r);
			r.visible = false; // Don't show the rectangle unless we visited the place
			rect_area_names.push(other_map_name);
			if (other_map_name == map_name) {
				active_rect = r;
			}
			
			// Add door markers
			var other_map_dim:Point = HF.get_csv_dimensions(EMBED_TILEMAP.csv_hash.get(other_map_name.toUpperCase() + "_BG"));
			var door_rows:Array<Array<String>> = HF.get_entity_query(other_map_name.toUpperCase(), ["Door", "x", "y", "s_visited", "dest_map","dest_x","dest_y"]);
			var door_row:Array<String> = [];
			for (door_row in door_rows) {
				if (door_row[2] == "1") { // Make sure the door was visited
					var door_marker:FlxSprite = new FlxSprite(0, 0);
					door_marker.makeGraphic(2, 3, 0xff222222);
					door_marker.scrollFactor.set(0, 0);
					door_marker.x = Std.parseInt(door_row[0]);
					door_marker.y = Std.parseInt(door_row[1]);
					door_marker.x = r.x + r.width * (door_marker.x / (16 * other_map_dim.x));
					door_marker.y = r.y + r.height * (door_marker.y / ( 16 * other_map_dim.y));
					door_icons.add(door_marker);
					
					var dest_door_marker_coords:Point = new Point(Std.parseInt(door_row[4]), Std.parseInt(door_row[5]));
					door_row[3] = door_row[3].split("\"")[1];
					if (HF.array_contains(a, door_row[3].toLowerCase())) {
						lineinfos.push([door_marker.x, door_marker.y, dest_door_marker_coords.x, dest_door_marker_coords.y, door_row[3]]);
					} else {
						door_marker.makeGraphic(2, 3, 0xff220022);
					}
				}
			}
		}
		
		// Add info for line connections of doors
		var lineinfos_entry:Array<Dynamic> = [];
		for (lineinfos_entry in lineinfos) {
			var dest_map_rect:FlxSprite = null;
			for (i in 0...rect_area_names.length) {
				if (rect_area_names[i].toUpperCase() == lineinfos_entry[4]) {
					dest_map_rect = rects.members[i];
					break;
				}
			}
			if (dest_map_rect != null) {
				var dest_map_dims:Point = HF.get_csv_dimensions(EMBED_TILEMAP.csv_hash.get(lineinfos_entry[4]+"_BG"));
				lineinfos_entry[2] = dest_map_rect.x + dest_map_rect.width * (lineinfos_entry[2] / (16 * dest_map_dims.x));
				lineinfos_entry[3] = dest_map_rect.y + dest_map_rect.height * (lineinfos_entry[3] / (16 * dest_map_dims.y));
			}
		}
		
		
		
		cur_map_height = Std.int(cur_state.tm_bg.height);
		cur_map_width = Std.int(cur_state.tm_bg.width);
		
		cursor.y = active_rect.y + active_rect.height * 0.5;
		cursor.x = active_rect.x + active_rect.width * 0.5;
		
		area_title.visible = player_marker.visible = cursor.visible = true;
		
		
		return true;
	}
	
	private function set_player_marker_pos(_player_marker:FlxSprite):Void {
		if (active_rect != null) {
			_player_marker.x = active_rect.x + active_rect.width * (R.activePlayer.x / cur_map_width);
			_player_marker.y = active_rect.y + active_rect.height * (R.activePlayer.y / cur_map_height);
		}
	}
	
	private static inline var cursor_accel:Int = 200;
	private static inline var cursor_maxvel:Int = 200;
	private static inline var cursor_initvel:Int = 50;
	
	private var mode:Int = 0;
	private static inline var MODE_AREA_MAP:Int = 0;
	private static inline var MODE_WORLD_MAP:Int = 1;
	override public function update(elapsed: Float):Void {
		super.update(elapsed);
		
		if (R.input.up) {
			if (cursor.velocity.y >= 0) cursor.velocity.y = -cursor_initvel;
			cursor.acceleration.y = -cursor_accel;
		} else if (R.input.down) {
			if (cursor.velocity.y <= 0) cursor.velocity.y = cursor_initvel;
			cursor.acceleration.y = cursor_accel;
		} else {
			cursor.velocity.y = 0;
			cursor.acceleration.y = 0;
		}
		
		if (R.input.left) {
			if (cursor.velocity.x >= 0) cursor.velocity.x = -cursor_initvel;
			cursor.acceleration.x = -cursor_accel;
		} else if (R.input.right) {
			if (cursor.velocity.x <= 0) cursor.velocity.x = cursor_initvel;
			cursor.acceleration.x = cursor_accel;
		} else {
			cursor.velocity.x = 0;
			cursor.acceleration.x = 0;
		}
		
		if (mode == MODE_AREA_MAP) {
			set_player_marker_pos(player_marker);
			area_title.text = EMBED_TILEMAP.actualname_hash.get(area_name) + "\n";
			for (i in 0...rects.length) {
				if (rects.members[i].visible == true) {
					if (cursor.overlaps(rects.members[i])) {
						rects.members[i].alpha = 1;
						area_title.text += EMBED_TILEMAP.actualname_hash.get(rect_area_names[i].toUpperCase());
					} else {
						rects.members[i].alpha = 0.6;
					}
				}
			}
			area_title.x = (C.GAME_WIDTH - area_title.width) / 2;
		} else if (mode == MODE_WORLD_MAP) {
			
		}
	}
	override public function draw():Void {
		
		for (i in 0...rects.length) {
			rects.members[i].x += menu_map_top_left.x;
			rects.members[i].y += menu_map_top_left.y;
		}
		for (i in 0...door_icons.length) {
			door_icons.members[i].x += menu_map_top_left.x;
			door_icons.members[i].y += menu_map_top_left.y;
		}
		player_marker.x += menu_map_top_left.x;
		player_marker.y += menu_map_top_left.y;
		cursor.x += menu_map_top_left.x;
		cursor.y += menu_map_top_left.y;
		super.draw();
		for (i in 0...rects.length) {
			rects.members[i].x -= menu_map_top_left.x;
			rects.members[i].y -= menu_map_top_left.y;
		}
		for (i in 0...door_icons.length) {
			door_icons.members[i].x -= menu_map_top_left.x;
			door_icons.members[i].y -= menu_map_top_left.y;
		}
		player_marker.x -= menu_map_top_left.x;
		player_marker.y -= menu_map_top_left.y;
		
		cursor.x -= menu_map_top_left.x;
		cursor.y -= menu_map_top_left.y;
		
		for (lineinfo in lineinfos) {
			#if cpp
			FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
			FlxG.camera.debugLayer.graphics.moveTo(lineinfo[0] + menu_map_top_left.x,lineinfo[1]+ menu_map_top_left.y);
			FlxG.camera.debugLayer.graphics.lineTo(lineinfo[2] + menu_map_top_left.x, lineinfo[3] + menu_map_top_left.y);
			#end
		}
	}
	
}