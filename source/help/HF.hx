package help;
import autom.EMBED_TILEMAP;
import entity.MySprite;
import entity.player.BubbleSpawner;
import entity.tool.Door;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.Lib;
import flash.utils.ByteArray;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.util.FlxStringUtil;
import global.C;
import global.Registry;
import haxe.Log;
import haxe.CallStack;
import hscript.Expr;
import hscript.Parser;
import openfl.Assets;
import flash.display.BitmapData;
import flash.geom.Point;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.text.FlxBitmapText;
import state.MyState;
import state.TestState;

#if cpp
import sys.FileSystem;
import sys.io.FileInput;
import sys.io.FileOutput;
import sys.io.File;
#end

/**
 * Helper Functions
 * @author Melos Han-Tani
 */

class HF 
{

	public function new() 
	{
		
	}
	/**
	 * takes any string separated by tabs or spaces and returns the stuffin between as an array of strins
	 * @param	s
	 * @return
	 */
	public static function extract_whitespace_delim_arg(s:String):Array<String> {
		var mode:Int = 0;
		var next_s:String = "";
		var a:Array<String> = new Array<String>();
		// aa  bb c
		for (i in 0...s.length) {
			var c = s.charAt(i);
			if (c == " " || c == "\t" || c == "\r" || c == "\n") {
				mode = 0;
				if (next_s != "") {
					a.push(next_s);
				}
				next_s = "";
			} else {
				mode = 1;
			}
			if (mode == 1) {
				next_s += c;
			}
		}
		if (next_s != "") {
			a.push(next_s);
		}
		return a;
	}
	public static function uncache_bitmap(bitmap:BitmapData):Bool {
		
		//if (bitmap == null) return false;
		//
		//var bitmapDataCache:Map<String, BitmapData> = Assets.cache.bitmapData;
		//
		//if (bitmapDataCache != null)
		//{
			//for (k in bitmapDataCache.keys())
			//{
				//if (bitmapDataCache.get(k) == bitmap)
				//{
					//var bd:BitmapData = bitmapDataCache.get(k);
					//bd.dispose();
					//bd = null;
					//bitmapDataCache.remove(k);
					////Log.trace(k);
					//return true;
				//}
			//}
		//}
		Log.trace("deprecated");
		return false;
	}
	
	/**
	 * Checks if this ray intersects a box. Handles degenerate cases by treating ray as a horizontal or vertical line if
	 * the paramaterization constant for x or y (whose norm is 1) is less than eps.
	 * @param	ray_x	Beginning
	 * @param	ray_y
	 * @param	kx
	 * @param	ky
	 * @param	box
	 * @param	eps
	 * @return
	 */
	public static function ray_intersects_box(ray_x:Float, ray_y:Float, kx:Float, ky:Float, box:FlxObject, t_max:Float,eps:Float = 0.01,out_pt:Point=null):Bool {
		
		if (box == null) {
			return false;
		}
		
		// Doesn't work in a crazy weird case where a crazy large object's edges are in solid tiles and a laser is firing from inside..
		// but who
		
		/* If the division in the 2nd part of this would cause precision errors, just assume our lines
		 * are axis-aligned and solve that way. Also make sure that the "hit" area is correct */
		if (Math.abs(ky) < eps) {
			if (ray_y >= box.y && ray_y <= box.y + box.height ) { // Horizontal Line
				if (kx < 0) {
					if (ray_x >= box.x && ((box.x + box.width) - ray_x) / kx <= t_max) {
						if (out_pt != null) {
							out_pt.x = box.x + box.width;
							out_pt.y = ray_y;
						}
						return true; 
					}
				} else {
					if (ray_x <= box.x + box.width && (box.x - ray_x) / kx <= t_max) {
						if (out_pt != null) {
							out_pt.x = box.x;
							out_pt.y = ray_y;
						}
						return true;
					}
				}
			}
			return false;
		} else if (Math.abs(kx) < eps) {
			if (ray_x >= box.x && ray_x <= box.x + box.width) { // Vertical line
				if (ky < 0) { // Pointing up
					if (ray_y >= box.y && ((box.y + box.height) - ray_y) / ky <= t_max) {
						if (out_pt != null) {
							out_pt.x = ray_x;
							out_pt.y = box.y + box.height;
						}
						return true;
					}
				} else {
					if (ray_y <= box.y + box.height && (box.y - ray_y) / ky <= t_max) {
						if (out_pt != null) {
							out_pt.x = ray_x;
							out_pt.y = box.y;
						}
						return true;
					}
				}
			}
			return false;
		}
		
		
		/* Find the times at which the ray would intersect the edges of the box.
		 * If this time is valid - between 0 and the time that the actual ray has stopped travelling in the case of
		 * a laser, then report a hit */
		var t:Float = (box.x - ray_x) / kx; // Time when ray crosses left face of box
		var t1:Float = ((box.x + box.width) - ray_x) / kx; // Time when ray crosses right face of box
		
		if (t > 0 && t <= t_max && (t * ky + ray_y) >= box.y && (t * ky + ray_y) <= box.y + box.height) {
			if (out_pt != null) {
				out_pt.x = box.x;
				out_pt.y = t * ky + ray_y;
			}
			return true; 
		} 
		if (t1 > 0 &&  t1 <= t_max && (t1 * ky + ray_y) >= box.y && (t1 * ky + ray_y) <= box.y + box.height) {
			if (out_pt != null) {
				out_pt.x = box.x + box.width;
				out_pt.y = t1 * ky + ray_y;
			}
			return true;
		}
		
		t = (box.y - ray_y) / ky;
		t1 = ((box.y + box.height) - ray_y) / ky;
		
		if (t > 0 &&  t <= t_max &&  (t * kx + ray_x) >= box.x && (t * kx + ray_x) <= box.x + box.width) {
			if (out_pt != null) {
				out_pt.x = t * kx + ray_x;
				out_pt.y = box.y;
			}
			 return true;
		}
		if (t1 > 0 &&  t1 <= t_max && (t1 * kx + ray_x) >= box.x && (t1 * kx + ray_x) <= box.x + box.width) {
			if (out_pt != null) {
				out_pt.x = t1 * kx + ray_x;
				out_pt.y = box.y + box.height;
			}
			 return true;
		}
		
		
		return false;
	}
	
	public static function get_bitmap_as_text(b:BitmapData, r:Rectangle):String {
		var s:String = "";
		for (y in Std.int(r.y)...Std.int(r.y + r.height)) {
			for (x in Std.int(r.x)...Std.int(r.x + r.width)) {
				s += StringTools.hex(b.getPixel(x, y), 6);
			}
			if (y != Std.int(r.y + r.height) - 1) {
				s += "\n";
			}
		}
		return s;
	}
	
	public static function set_bitmap_with_text(b:BitmapData, w:Int, h:Int, s:String):BitmapData {
		var rows:Array<String> = s.split("\n");
		for (y in 0...h) {
			for (x in 0...w) {
				b.setPixel(x, y, Std.parseInt("0x" + rows[y].substr(x * 6, 6)));
			}
		}
		return b;
	}
	
	private static var parser:Parser;
	
	public static function move_camera_to(dest_x:Float, dest_y:Float, rate:Float , eps:Int):Bool {
		//Log.trace(dest_x);
		//Log.trace(FlxG.camera.scroll.x);
		//Log.trace(dest_y);
		//Log.trace(FlxG.camera.scroll.y);
		
		if (Math.abs(FlxG.camera.scroll.x - dest_x) <= eps && Math.abs(FlxG.camera.scroll.y - dest_y) <= eps) {
			return true;
		}
		if (FlxG.camera.scroll.x > dest_x) {
			FlxG.camera.scroll.x -= rate;
		} else if (FlxG.camera.scroll.x < dest_x) {
			FlxG.camera.scroll.x += rate;
		}
		
		if (FlxG.camera.scroll.y > dest_y) {
			FlxG.camera.scroll.y -= rate;
		} else if (FlxG.camera.scroll.y < dest_y) {
			FlxG.camera.scroll.y += rate;
		}
		
		return false;
		
	}
	
	// Only copies text files...
	public static function copy(src:String, dst:String):Void {
		#if cpp
		var s:String = File.getContent(src);
		File.saveContent(dst, s);
		#end
	}
		
	
	public static function update_script_dev_to_assets(script_filename:String):Void {
		#if cpp
		if (FileSystem.exists(C.EXT_ASSETS + NPC_SCRIPTS_WITHIN_ASSETS_PATH+ script_filename)) {
			var script:String = File.getContent(C.EXT_ASSETS + NPC_SCRIPTS_WITHIN_ASSETS_PATH + script_filename);
			copy(C.EXT_ASSETS + NPC_SCRIPTS_WITHIN_ASSETS_PATH + script_filename, "assets/" + NPC_SCRIPTS_WITHIN_ASSETS_PATH + script_filename);
		} else {
			Log.trace("Tried to copy dev->build, No such script " + script_filename);
		}
		#end
		return;
	}
	
	/**
	 * Returns a parsed expression for the script at this filename. The script filename is turned to lowercase
	 * Will get the script from the DEV directory if the editor is open
	 * @param	script_filename
	 * @return
	 */
	public static var NPC_SCRIPTS_WITHIN_ASSETS_PATH:String = "script/";
	public static function get_program_from_script_wrapper(script_filename:String):Expr {
		if (parser == null) {
			parser = new Parser();
		}
		if (script_filename == "") {
			return parser.parseString("");
		}
		script_filename = script_filename.toLowerCase();
		if (script_filename.indexOf(".hx") == -1) {
			Log.trace("Need .hx extension on script: \"" + script_filename + "\"");
			return parser.parseString("");
		}
		var script:String = "";
		if (Registry.R.editor == null || false == Registry.R.editor.editor_active) {
			script = Assets.getText("assets/" + NPC_SCRIPTS_WITHIN_ASSETS_PATH + script_filename);
		} else if (ProjectClass.DEV_MODE_ON == false) {
			script = Assets.getText("assets/" + NPC_SCRIPTS_WITHIN_ASSETS_PATH + script_filename);
		} else { // If the editor is active, copy the dev-copy to the build-copy
			#if cpp
			if (FileSystem.exists(C.EXT_ASSETS + NPC_SCRIPTS_WITHIN_ASSETS_PATH+ script_filename)) {
				script = File.getContent(C.EXT_ASSETS + NPC_SCRIPTS_WITHIN_ASSETS_PATH + script_filename);
				copy(C.EXT_ASSETS + NPC_SCRIPTS_WITHIN_ASSETS_PATH + script_filename, "assets/" + NPC_SCRIPTS_WITHIN_ASSETS_PATH + script_filename);
				//Log.trace("Update " + script_filename);
			} else {
				Log.trace("Tried to copy dev->build, No such script " + script_filename);
				return parser.parseString("");
			}
			#end
		}
		if (script == null || script.length < 2) {
			Log.trace("Bad script: " + script_filename);
		}
		return parser.parseString(script);
	}
	public static function array_index_of<T>(a:Array<T>, value:T):Int {
		for (i in 0...a.length) {
			if (value == a[i]) {
				return i;
			}
		}
		return -1;
	}
	
	public static function array_contains<T>(a:Array<T>, value:T):Bool {
		for (val in a) {
			if (val == value) {
				return true;
			}
		}
		return false;
	}
	public static function array_init_with<T>(a:Array<T>, value:T, num:Int):Array<T> {
		a = [];
		for (i in 0...num) {
			a.push(value);
		}
		return a;
	}

		
	public static function test_compress_csv():Void {
		//File.saveContent(C.EXT_CSV + "_COMPRESSED", compress_csv(File.getContent(C.EXT_CSV + "CANYONIN1_BG.csv")));
		//File.saveContent(C.EXT_CSV + "_DECOMPRESD", decompress_csv(File.getContent(C.EXT_CSV + "_COMPRESSED")));
		
		Log.trace(decompress_csv("2,4,1,2\n2,4,5,4\n"));
	}
	public static function compress_csv(s:String):String { 
		var lines:Array<String> = s.split("\n");
		var out_s:String = "";
		var cur_val:String = "-1";
		var cur_nr:Int = 1;
		var line:String = "";
		var vals:Array<String> = [];
		var next_line:String = "";
		for (line in lines) {
			if (line.length <= 1) continue;
			line = line.split("\r")[0];
			vals = line.split(",");
			for (i in 0...vals.length) {
				if (cur_val == vals[i]) {
					cur_nr ++;
				} else {
					if (cur_nr != 1) {
						next_line += cur_val + ":" + Std.string(cur_nr) + ",";
					} else if (cur_val != "-1") {
						next_line += cur_val + ",";
					}
					cur_val = vals[i];
					cur_nr = 1;
				}
			}
			
			if (cur_nr != 1) {
				next_line += cur_val + ":" + Std.string(cur_nr) + "!";
			} else {
				next_line += cur_val + "!";
			}
			out_s += next_line;
			
			next_line = "";
			cur_val = "-1";
			cur_nr = 1;
		}
		
		return out_s;
	}
	public static function decompress_csv(s:String):String {
		var out_s:String = "";
		var next_val:String = "";
		var next_nr:String = "";
		var next_c:String = "";
		
		var mode_number_of:Bool = false;
		for (i in 0...s.length) {
			next_c = s.charAt(i);
			if (next_c == ":") {
				mode_number_of = true;
			} else if (next_c == "!") {
				mode_number_of = false;
				var nr:Int = next_nr == "" ? 1 : Std.parseInt(next_nr);
				for (j in 0...nr) {
					out_s += next_val;
					if (j != nr -1) {
						out_s += ",";
					}
				}
				next_nr = next_val = "";
				if (i != s.length - 1) {
					out_s += "\n";
				}
				
			} else if (next_c == ",") {
				mode_number_of = false;
				var nr:Int = next_nr == "" ? 1 : Std.parseInt(next_nr);
				for (j in 0...nr) {
					out_s += next_val + ",";
				}
				next_nr = next_val = "";
			} else {
				if (mode_number_of) {
					next_nr += next_c;
				} else {
					next_val += next_c;
				}
			}
		}
		return out_s;
	}
	
	/**
	 * Given a raw SON string, returns it as a dynamic hash~~~
	 * @param	raw_SON
	 * @return
	 */
	public static function parse_SON(raw_SON:String):Map<String,Dynamic> {
		var lines:Array<String> = raw_SON.split("\n");
		var line:String = "";
		var tokens:Array<String> = [];
		var hash_queue:Array<Map<String,Dynamic>> = [];
		//var key_to_cur_hash_queue:Array<String> = [];
		var cur_hash:Map<String,Dynamic> = new Map<String,Dynamic>();
		
		//var key_to_cur_hash:String = "_ROOT";
		var lineidx:Int = -1;
		for (line in lines) {
			lineidx++;
			line = StringTools.trim(line);
			if (line.charAt(0) == "#" || line.charAt(0) == "/") continue;
			tokens = line.split(" ");
			tokens[tokens.length - 1] = tokens[tokens.length - 1].split("\r")[0];
			
			if (tokens[0] == "{") {
				hash_queue.push(cur_hash);
				//key_to_cur_hash_queue.push(key_to_cur_hash);
				cur_hash.set(tokens[1], new Map<String,Dynamic>());
				//key_to_cur_hash = tokens[1];
				cur_hash = cur_hash.get(tokens[1]);
			} else if (tokens[0] == "}") {
				cur_hash = hash_queue.pop();
			} else {
				var key:String = tokens[0];
				var type:String = tokens[1];
				switch (type) {
					case "i":
						cur_hash.set(key, Std.parseInt(tokens[2]));
					case "f":
						cur_hash.set(key, Std.parseFloat(tokens[2]));
					case "s":
						cur_hash.set(key, extract_quote(line));
					case "sa": //arguments can't have whitespace because we use tokens[2]...fix?
						cur_hash.set(key, JankSave.read_savearraystr(tokens[2], true) );
					case "ia":
						cur_hash.set(key, string_to_int_array(tokens[2]));
					default:
						if (line.length > 1) {
							Log.trace("No type? " + type +" Line idx "+Std.string(lineidx)+" Line: " + line);
							Log.trace(CallStack.callStack()[1]);
							
						}
				}
			}
		}
		return cur_hash;
	}
	
	public static function copy_props(src:Map<String,Dynamic>, dst:Map<String,Dynamic>, skip_some:Bool = false):Void {
		if (src == null) {
			Log.trace("trying to copy with src null");
			Log.trace(CallStack.callStack()[1]);
			return;
		}if (dst == null) {
			Log.trace("trying to copy with dst null");
			Log.trace(CallStack.callStack()[1]);
			return;
		}
		for (key in src.keys()) {
			if (skip_some && key.charAt(0) == "_") {
				continue;
			}
			dst.set(key, src.get(key));
		}
	}

	public static function get_time_string(time:Int,in_frames:Bool=false):String {
		if (in_frames) time = Std.int(time / 60); // divide by FPS
		
		var hrs:Int = Math.floor(time / 3600);
		time -= hrs * 3600;
		var min:Int = Math.floor(time / 60);
		time -= min * 60;
		
		var hrss:String = Std.string(hrs);
		var mins:String = Std.string(min);
		var secs:String = Std.string(time);
		if (hrs < 10) {
			hrss = "0" + hrss;
		} 
		
		if (min < 10) {
			mins = "0" + mins;
		}
		
		if (time < 10) {
			secs = "0" + secs;
		}
		
		return hrs + ":" + mins + ":" + secs;
		
		
		
	}
	
	public static function get_midpoint_distance(a:FlxObject, b:FlxObject):Float {
		var dx:Float = (b.x + b.width / 2) - (a.x + a.width / 2);
		var dy:Float = (b.y + b.height / 2) - (a.y + a.height / 2);
		return Math.sqrt(dx * dx + dy * dy);
		
	}
	/**
	 * For help in storing coordinates of objects
	 * @param	p
	 * @return
	 */
	public static function point_array_to_string(p:Array<Point>):String {
		var s:String = "";
		for (i in 0...p.length) {
			s += Std.string(p[i].x) + ",";
			s += Std.string(p[i].y);
			if (i != p.length - 1) {
				s += ",";
			}
		}
		return s;
	}
	
	public static function string_to_point_array(s:String):Array<Point> {
		var a:Array<Point> = [];
		if (s.length <= 0 || s.indexOf(",") == -1) {
			Log.trace("error");
			Log.trace(s);
			return [new Point(0, 0)];
		}
		var sa:Array<String> = s.split(",");
		if (sa.length % 2 == 1) {
			Log.trace("error2");
			return [new Point(0, 0)];
		}
		var p:Point = null;
		for (i in 0...sa.length) {
			if (i % 2 == 0) {
				p = new Point();
				p.x = Std.parseInt(sa[i]);
			} else {
				p.y = Std.parseInt(sa[i]);
				a.push(p);
			}
		}
		return a;
	}
	public static function string_to_int_array(s:String,ignore_commas_if_none:Bool=false):Array<Int> {
		var a:Array<Int> = [];
		var nums:Array<String> = s.split(",");
		if (ignore_commas_if_none && s.indexOf(",") == -1) {
			nums = s.split("");
		}
		for (i in 0...nums.length) {
			a.push(Std.parseInt(nums[i]));
		}
		return a;
	}	
	public static function string_to_float_array(s:String):Array<Float> {
		var a:Array<Float> = [];
		var nums:Array<String> = s.split(",");
		for (i in 0...nums.length) {
			a.push(Std.parseFloat(nums[i]));
		}
		return a;
	}
	
	public static function double_int_array_to_tilemap_string(a:Array<Array<Int>>):String {
		var s:String = "";
		var last_Idx:Int = a.length - 1;
		for (_a in a) {
			s += int_array_to_string(_a);
			
			if (_a == a[last_Idx]) {
				
			} else {
				s += "\n";
			}
		}
		return s;
	}
	public static function int_array_to_string(a:Array<Int>):String {
		var s:String = "";
		for (i in 0...a.length) {
			s += Std.string(a[i]);
			
			if (i != a.length - 1) s += ",";
		}
		return s;
	}
	
	public static function init_bitmap_font(text:String = " ", alignment:String = "center", x:Int = 0, y:Int= 0, scrollFactor:FlxPoint = null, type:String="black",double_draw:Bool=false):FlxBitmapText {
		
		var b:FlxBitmapText;
		
		/* Normal Display text */
		if (type == C.FONT_TYPE_APPLE_WHITE || type == C.FONT_TYPE_ALIPH_WHITE) {
			
			if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_JP) {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_jp, C.C_FONT_JP_STRING, new FlxPoint(C.JP_FONT_w, C.JP_FONT_h), null, new FlxPoint(0, 0)));
				b.lineSpacing = 3;
				
			} else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_ZH_SIMP) {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_zh_simp, C.C_FONT_ZH_SIMP_STRING, new FlxPoint(C.ZH_SIMP_FONT_w, C.ZH_SIMP_FONT_h), null, new FlxPoint(0, 0)));
				b.lineSpacing = 1;
			} else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_DE || DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_RU || DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_ES) {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_other_white, C.C_FONT_OTHER_STRING, new FlxPoint(C.OTHER_FONT_w, C.OTHER_FONT_h), null, new FlxPoint(0, 0)));
				b.lineSpacing = 2;
					
			} else {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_aliph_script_white, C.C_FONT_ALIPH_STRING, new FlxPoint(C.ALIPH_FONT_w, C.ALIPH_FONT_h), null, new FlxPoint(0, 0)));
				b.lineSpacing = 6;
			}
		/* Editor */
		} else if (type == C.FONT_TYPE_EDITOR) {
			b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_apple_white, C.C_FONT_APPLE_WHITE_STRING, new FlxPoint(C.APPLE_FONT_w, C.APPLE_FONT_h), null, new FlxPoint(0, 0)));
			
			
			
		/* Dialogue names */
		} else if (type == C.FONT_TYPE_ALIPH_SMALL_WHITE) {
			
			if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_JP) {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_jp, C.C_FONT_JP_STRING, new FlxPoint(C.JP_FONT_w, C.JP_FONT_h), null, new FlxPoint(0, 0)));
				b.lineSpacing = 3;
				
			} else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_ZH_SIMP) {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_zh_simp, C.C_FONT_ZH_SIMP_STRING, new FlxPoint(C.ZH_SIMP_FONT_w, C.ZH_SIMP_FONT_h), null, new FlxPoint(0, 0)));
				b.lineSpacing = 1;
			} else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_DE || DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_RU || DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_ES) {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_other_white_small, C.C_FONT_OTHER_SMALL_STRING, new FlxPoint(C.OTHER_SMALL_FONT_w, C.OTHER_SMALL_FONT_h), null, new FlxPoint(0, 0)));
				b.lineSpacing = 1;
			} else {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_aliph_script_white_small, C.C_FONT_ALIPH_SMALL_STRING, new FlxPoint(C.ALIPH_FONT_SMALL_w, C.ALIPH_FONT_SMALL_h), null, new FlxPoint(0, 0)));
			}
		/* Anything else */
		} else if (type == "english") {
			
			b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_aliph_script_white, C.C_FONT_ALIPH_STRING, new FlxPoint(C.ALIPH_FONT_w, C.ALIPH_FONT_h), null, new FlxPoint(0, 0)));
			b.lineSpacing = 6;
		} else {
			if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_JP) {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_jp, C.C_FONT_JP_STRING, new FlxPoint(C.JP_FONT_w, C.JP_FONT_h), null, new FlxPoint(0, 3)));
				
			} else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_ZH_SIMP) {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_zh_simp, C.C_FONT_ZH_SIMP_STRING, new FlxPoint(C.ZH_SIMP_FONT_w, C.ZH_SIMP_FONT_h), null, new FlxPoint(0, 0)));
				b.lineSpacing = 1;
				
			} else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_DE || DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_RU || DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_ES) {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_other_white, C.C_FONT_OTHER_STRING, new FlxPoint(C.OTHER_FONT_w, C.OTHER_FONT_h), null, new FlxPoint(0, 0)));
				b.lineSpacing = 2;
					
			} else {
				b = new FlxBitmapText(FlxBitmapFont.fromMonospace(C.font_aliph_script_white, C.C_FONT_ALIPH_STRING, new FlxPoint(C.ALIPH_FONT_w, C.ALIPH_FONT_h), null, new FlxPoint(0, 0)));
				b.lineSpacing = 0;
			}
		}
		
		b.multiLine = true;
		b.alignment = alignment;
		b.autoUpperCase = false;
		b.text = text;
		//b.setText(text, true, 0, b.lineSpacing, alignment, true);
		b.x = x;
		b.y = y;
		if (scrollFactor == null) {
			b.scrollFactor.x = b.scrollFactor.y = 0;
		} else {
			b.scrollFactor.x = scrollFactor.x;
			b.scrollFactor.y = scrollFactor.y;
		}
		b.double_draw = double_draw;
		return b;
		
		
		
		}	
		
		public static function get_csv_dimensions(csv:String):Point {
			var a:Array<String> = csv.split("\n");
			var p:Point = new Point(0, 0);
			p.y = a.length;
			p.x = a[0].split(",").length;
			return p;
		}
		/**
		 * Given arguments [CLASSTYPE,arg1,arg2...], return an array of
		 * each occurence within MAPNAME's current in-memory entity data
		 * @param	args
		 * @return blahblahlbah
		 */
		public static function get_entity_query(mapname:String,args:Array<String>):Array<Array<String>> {
			var s:String = EMBED_TILEMAP.entity_hash.get(mapname);
			var lines:Array<String> = s.split("\n");
			var line:String = "";
			var words:Array<String> = [];
			var rows:Array<Array<String>> = [];
			for (line in lines) {
				words = line.split(" ");
				var word:String = "";
				var arg:String = "";
				var row:Array<String> = [];
				if (words[0] == args[0]) { // Match on class name
					
					for (i in 1...args.length) { // Find matches for arguments we want
						if (args[i] == "x") {
							row.push(words[1]);
						} else if (args[i] == "y") {
							row.push(words[2]);
						} else {
							var match_found:Bool = false;
							for (word in words) { // Look through properties of row
								if (word.split("=")[0] == args[i]) {
									row.push(word.split("=")[1]);
									match_found = true;
									break;
								}
							}
							if (match_found == false) {
								row.push("~NA");
							}
							match_found = false;
						}
					}
					rows.push(row);
				}
				
			}
			return rows;
		}
		
		public static function get_are_you_sure_string(dm:DialogueManager,yes:Bool = false):String {
			var s:String = "";
			s = dm.lookup_sentence("ui", "are_you_sure", 0);
			s += "\n" + dm.lookup_sentence("ui", "are_you_sure", 1) + "\n";
			s +=  dm.lookup_sentence("ui", "are_you_sure", 2) + " ";
			return s;
		}
		
		/**
		 * get the string for saving
		 * @param	sgs the entity groups
		 * @param	prefixes their prefixes. use "[] to change them to defaults
		 * @return
		 */
		public static function save_map_ent_construct_string(sgs:Array<FlxGroup>, prefixes:Array <String> =null):String {
			
			var i:Int;
			var j :Int;
			var key:String;
			var ag:FlxGroup; //active group
			var msp:MySprite;
			var s:String = "";
			if (prefixes ==null) {
				prefixes = ["BBG","BG1","BG2","null","FG2"];
			}
			
			for (j in 0...sgs.length) {
				if (sgs[j] == null) continue;
				ag = sgs[j];
				s += prefixes[j] + " START\n";
				for (i in 0...ag.members.length) {
					if (ag.members[i] != null) {
						if (Std.is(ag.members[i], MySprite)) { // Only save sprites
							msp = cast(ag.members[i], MySprite);
							// name and position and geid
							s += msp.name + " " + Std.string(msp.ix) + " " + Std.string(msp.iy) + " " + Std.string(msp.geid);
							// properites
							if (msp.props == null) {
								s += "\n";
								continue;
							}
							for (key in msp.props.keys()) {
								if (Std.is(msp.props.get(key), String)) {
									s += " " + key + "=\"" + Std.string(msp.props.get(key)) + "\"";
								} else {
									// TODO : Truncate floats at 2 decimal places
									s += " " + key + "=" + Std.string(msp.props.get(key)) ;
								}
							}
							s += "\n";
						} else {
							// group?
						}
					}
				}
			}
			return s;
		}
		/**
		 * Creates a name.ent file which contains data on the map's sprites,
		 * their container groups, guids, positions, properties
		 * ONLY SAVES MySprites , ONLY called in the editor
		 * @param	name Map name
		 * @param	ms Current state
		 */
		public static function save_map_entities(name:String, ms:MyState,only_in_mem:Bool=false,only_this:Map<String,Dynamic>=null):Void {

			var ext:String = C.EXT_MAP_ENT;
			var sgs:Array<FlxGroup> = [ms.below_bg_sprites,ms.bg1_sprites,ms.bg2_sprites, null,ms.fg2_sprites];
			var s:String = HF.save_map_ent_construct_string(sgs);
			
			#if cpp		
			
			if (only_this != null) {
				Log.trace("Saving " + name + " to custom hash");
				only_this.set(name, s);
				return;
			}
			// Save entity data as needed
			if (false == only_in_mem) {
				Log.trace("Saving " + name + " entity data to disk.");
				//File.saveContent(C.EXT_NONCRYPTASSETS + "map_ent/" + name + ".ent", s);
				File.saveContent(ext + name + ".ent", encrypt_string(s,c_norm_all,c_unnr_all));
			}
			
			#end
			Log.trace("Saving " + name + " entity data to memory.");
			EMBED_TILEMAP.entity_hash.set(name, encrypt_string(s,c_norm_all,c_unnr_all));
		}
		
		public static function scale_velocity(v:FlxPoint, src:FlxObject, dst:FlxObject, out_vel:Float):Void {
			var norm:Float = Math.sqrt((src.x - dst.x)  * (src.x - dst.x) + (src.y - dst.y) * (src.y - dst.y));
			if (Math.abs(norm)< 0.001) {
				v.x = v.y = 0;
				return;
			}
			var unit_x:Float = (dst.x - src.x) / norm;
			var unit_y:Float = (dst.y - src.y) / norm;
			v.x = unit_x * out_vel;
			v.y = unit_y * out_vel;
		}
		public static function set_vel_vector(vel:FlxPoint, angle_in_deg:Int,magnitude:Float):Void {
			vel.x = FlxX.cos_table[angle_in_deg] * magnitude;
			vel.y = FlxX.sin_table[angle_in_deg] * magnitude * -1;
		}
		public static function extract_quote(s:String):String {
			var outs:String = "";
			var inside:Bool = false;
			for (i in 0...s.length) {
				if (inside == false) {
					if (s.charAt(i) == "\"") {
						inside = true;
					}
				} else {
					if (s.charAt(i) == "\"") {
						break;
					}
					outs += s.charAt(i);
				}
			}
			return outs;
		}
		
		public static function has_number(s:String):Bool {
			var nrs:String = "0123456789";
			for (i in 0...nrs.length) {
				if (s.indexOf(nrs.charAt(i)) != -1) {
					return true;
				}
			}
			return false;
		}
		public static function has_letter(s:String):Bool {
			var letters:String = "abcdefghijklmnopqrstuvwxyz_";
			for (i in 0...letters.length) {
				s = s.toLowerCase();
				if (s.indexOf(letters.charAt(i)) != -1) {
					return true;
				}
			}
			return false;
		
		}
		
		public static function read_number(s:String):String {
			var i:Int;
			for (i in 0...C.NR_WORD_ARRAY.length) {
				if (FlxG.keys.myJustPressed(C.NR_WORD_ARRAY[i])) {
					if (i % 10 == 9) {
						s += "0";
						break;
					} else {
						var j:Int = (i + 1) % 10;
						s += Std.string(j);
						break;
					}
				} else if (!FlxG.keys.pressed.SHIFT && FlxG.keys.myJustPressed("MINUS")) {
					s += "-";
					break;
				}
			}
			return s;
		}
		public static function read_letter(s:String):String {
			var i:Int;
			for (i in 0...26) {
				if (FlxG.keys.myJustPressed(C.ALPHABET.charAt(i))) {
					s += C.ALPHABET.charAt(i);
					break;
				} else if (FlxG.keys.pressed.SHIFT && FlxG.keys.myJustPressed("MINUS")) {
					s += "_";
					break;
				} else if (FlxG.keys.myJustPressed("SLASH")) {
					s += "/";
					break;
				} 
			}
			return s;
		}
		
		public static function read_letter_number(s:String):String {
			var i:Int;
			for (i in 0...26) {
				if (FlxG.keys.myJustPressed(C.ALPHABET.charAt(i))) {
					s += C.ALPHABET.charAt(i);
					return s;
				}else if (FlxG.keys.pressed.SHIFT && FlxG.keys.myJustPressed("MINUS")) {
					s += "_";
					return s;
				}
			}
			return read_number(s);
		}
		//public static function TEST_ENCRYPT():Void {
		//var test:String = "the quick brown fox jumps over the lazy dog THE Q\nUICK BRO\rWN FOX JUM\n\rPS OVER THE LAZY DOG 12312345645!@##%^&*_=-=908{}}[;':./>,><.67897890\"\"\"..-.=.=.-.=.-.::::.......   . . !@#! !@# $@$ !";
			//
			//var out_test:String = encrypt_string(test);
			//out_test = decrypt_string(out_test);
			//
			//Log.trace(test);
			//Log.trace(out_test);
			//Log.trace(out_test == test);
			//
			//
		//}
		
		// shouldnt need to call this now..
		public static function DECRYPT_ENTITY():Void {
			return; // 4 safety
			#if cpp
			for (key in EMBED_TILEMAP.entity_hash.keys()) {
				var data:String = EMBED_TILEMAP.entity_hash.get(key);
				//var filename:String = key;
				//var newfilename:String = encrypt_string(filename, c_norm_alpha, c_unnr_alpha);
				var newdata:String = decrypt_string(data, c_norm_all, c_unnr_all);
				
				
				File.saveContent(C.EXT_MAP_ENT + key + ".ent", newdata);
			}
			#end
		}
		
		// stupid cipher
		// DONT TOUCH THESE
		public static function encrypt_alpha(s:String):String {
			return s;
			return encrypt_string(s, c_norm_alpha, c_unnr_alpha);
		}
		
		/* DO NOT MODIFY!!!!!!!!! */
		public static inline var c_norm_all:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\n1234567890!@#$%^&*()_+-=[]{};:,.<>? \"";
		public static inline var c_unnr_all:String = 
    "^TP&U;jCD<@-)s8yzNX1Y_F5k!R7vqLgfm>c9J3]%OxS\"+(d}=6ZVB[pQI{nE?0a l\n$i#bwWtAG2u4:M.*r,eHohK";
		public static inline var c_norm_alpha:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		public static inline var c_unnr_alpha:String = "feAWkMJVlhLRBtKvHuNYdbjcrCoaTQxigynqwIPZFGmOUSXzDpEs";
		/* ********************************* /
		/* DO NOT MODIFY!!!!!!!!!!!!!!!!!! */
		/* ********************************* */
		
		public static function encrypt_string(s:String, norm:String, unnr:String):String {
			return s;
			var out_s:String = "";
			var idx:Int = 0;
			for (i in 0...s.length) {
				idx = norm.indexOf(s.charAt(i));
				if (idx != -1) {
					out_s += unnr.charAt(idx);
				} else {
					out_s += s.charAt(i);
				}
			}
			return out_s;
		}
		public static function decrypt_string(s:String, norm:String, unnr:String):String {
			return s;
			var out_s:String = "";
			var idx:Int = 0;
			for (i in 0...s.length) {
				idx = unnr.indexOf(s.charAt(i));
				if (idx != -1) {
					out_s += norm.charAt(idx);
				} else {
					out_s += s.charAt(i);
				}
			}
			return out_s;
		}
		
		public static function get_entity_from_state_by_geid(ms:MyState, geid:Int):MySprite {
			for (grp in [ms.below_bg_sprites, ms.bg1_sprites, ms.bg2_sprites, ms.fg2_sprites]) {
				for (i in 0...grp.length) {
					if (grp.members[i] != null && Std.is(grp.members[i], MySprite)) {
						var ms:MySprite = cast grp.members[i];
						if (ms.geid == geid) {
							return ms;
						}
					}
				}
			}
			return null;
		}
		
		
		public static function get_entities_from_string(s:String,ms:MyState,prefixes:Array<String>=null):Array<Array<MySprite>> {
			var lines:Array<String> = s.split("\n");
			var mode:Int = 0;
			var a:Array<Array<MySprite>> = [[], [], [], [], []];
			// Add in each sprite
			if (prefixes == null) {
				prefixes = ["BBG", "BG1", "BG2", "null", "FG2"];
			}
			for (i in 0...lines.length) {
				//  Determine where to be adding these sprites
				
				var words:Array<String>  =  StringTools.rtrim(lines[i]).split(" ");
				if (words[0].length < 2) continue;
				
				if (words[1].indexOf("START") != -1) {
					if (lines[i].indexOf(prefixes[2]) != -1) {
						mode = 2;
					} else if (lines[i].indexOf(prefixes[4]) != -1) {
						mode = 4;
					} else if (lines[i].indexOf(prefixes[0]) != -1) {
						mode = 0;
					} else if (lines[i].indexOf(prefixes[1]) != -1) {
						mode = 1;
					}	
					continue;
				}
				
				var ix:Int  = Std.parseInt(words[1]);
				var iy:Int = Std.parseInt(words[2]);
				var geid:Int = Std.parseInt(words[3]);
				
				// Load the sprite
				//Log.trace(words[0]);
				var d:Dynamic = SpriteFactory.make(words[0], ix, iy, ms);
				
				//Log.trace(words[0]);
				if (d == null) {
					Log.trace("Bad sprite load");
					Log.trace(lines[i]);
					continue;
				}
				d.geid = geid;
				
				d.cur_layer = mode;
				a[mode].push(d);
				
				// Set the sprite's properties
				if (Std.is(d, MySprite)) {
					var props:Map<String,Dynamic> = d.getDefaultProps();
					for (j in 4...words.length) {
						var key:String = words[j].split("=")[0];
						var val:String = words[j].split("=")[1];
						
						//Log.trace("Setting property " + key + " as: ");
						if (val.indexOf("\"") != -1) {
							var s:String = val.substring(1, val.length - 1);
							props.set(key, s);
						} else if (val.indexOf(".") != -1) { // Float
							var f:Float = Std.parseFloat(val);
							props.set(key, f);
						} else {
							var integer:Int = Std.parseInt(val);
							props.set(key , integer);
						}
					}
					d.set_properties(props);
				}
			}
			return a;
			
		}
		 
		/**
		 * nukes everything in the current state to hell (That is in the editor-able groups)
		 * and then loads it all back from HASHES
		 * @param	name
		 * @param	ms
		 */
		
		public static function load_map_entities(name:String, ms:MyState):Void {
			// Get the data from the entity file
			if (EMBED_TILEMAP.entity_hash.get(name) == null) return;
			Door.NEXT_AUTO_INDEX = 0;
			var s:String = decrypt_string(EMBED_TILEMAP.entity_hash.get(name), c_norm_all, c_unnr_all);
			clear_entities_from_mystate(ms);
			var a:Array<Array<MySprite>> = get_entities_from_string(s,ms);
			
			// Add it to a layer in the state
			for (mode in 0...a.length) {
				for (i in 0...a[mode].length) {
					var d:MySprite = cast a[mode][i];
					if (mode == 2) {
						ms.bg2_sprites.add(d);
					} else if (mode == 4) {
						ms.fg2_sprites.add(d);
					} else if (mode == 0) {
						ms.below_bg_sprites.add(d);
					} else if (mode  == 1) {
						ms.bg1_sprites.add(d);
					}
				}
			}
		}
		
		public static function copy_props_to_mysprite(props:Map<String,Dynamic>, ms:MySprite):Void {
			for (key in props.keys()) {
				ms.props.set(key, props.get(key));
			}
			ms.set_properties(ms.props);
		}
		/**
		 * Updates the csv hash with th contents of the on-disk DEVELOPMENT
		 * specified CSV files. 
		 * Then, loads those CSV into the active tilemaps and 
		 * sets their bindings based on the corresponding tileset .tilemeta file
		 * @param	name
		 * @param	ms
		 * @param	tileset
		 */
		public static function load_map_csv(name:String, ms:MyState,tileset:BitmapData,draft:Bool=false,draft_id:Int=-1):Void {
			#if cpp
			var ext:String = C.EXT_CSV;
			var mext:String = C.EXT_TILE_META;
			var s:String;
			
			var tsn:String = "";
			if (draft) {
				tsn = StringTools.trim(File.getContent(C.EXT_NONCRYPTASSETS + "csv_drafts/" + name + "/" + Std.string(draft_id)));
			}
			
			
			if (!draft) {
				if (FileSystem.exists(ext + name+".bcsv")) {
					var a:Array<String> = HF.disk_bcsv_to_csv_array(File.getContent(ext + name+".bcsv"));
					for (i in 0...4) {
						//Log.trace(a[i]);
						if (i == 0) {
							EMBED_TILEMAP.csv_hash.set(name+"_" + "BG", a[i]);
						} else if (i == 1) {
							EMBED_TILEMAP.csv_hash.set(name+"_" + "BG2", a[i]);
						} else if (i == 2) {
							EMBED_TILEMAP.csv_hash.set(name+"_" + "FG", a[i]);
						} else if (i == 3) {
							EMBED_TILEMAP.csv_hash.set(name+"_" + "FG2", a[i]);
						}
					}
				} else {
					for (suf in ["BG", "BG2", "FG", "FG2"]) {
						if (FileSystem.exists(ext + name + "_"+suf+".csv")) {
							EMBED_TILEMAP.csv_hash.set(name + "_"+suf, File.getContent(ext + name + "_"+suf+".csv"));
						}	
					}
				}
				HelpTilemap.set_map_csv(name, [ms.tm_bg, ms.tm_bg2, ms.tm_fg, ms.tm_fg2]);
				Log.trace("Loading " + name + " tilemaps from dev-disk");
				tsn= EMBED_TILEMAP.tileset_name_hash.get(name);
				if (FileSystem.exists(mext + tsn + ".tilemeta")) {
					EMBED_TILEMAP.tilebind_hash.set(tsn, File.getContent(mext + tsn + ".tilemeta"));
				}
			} else {
				var a:Array<Dynamic> = [ms.tm_bg, ms.tm_bg2, ms.tm_fg, ms.tm_fg2];
				var as:Array<String> = ["BG", "BG2", "FG", "FG2"];
				var i:Int = 0;
				for (tm in a) {
					tm.loadMap(File.getContent(C.EXT_NONCRYPTASSETS + "csv_drafts/" + name + "/" +as[i] + "#" + Std.string(draft_id) + ".csv"), EMBED_TILEMAP.direct_tileset_hash.get(tsn), 16, 16);
					i++;
				}
			}
			
			HelpTilemap.set_map_props(tsn,ms);
			#end
		}
		public static function write_csv_draft(mapname:String, ms:MyState, id:Int, tilesetname:String):Void {
			var ext:String = C.EXT_NONCRYPTASSETS;
			
			if (FileSystem.exists(C.EXT_NONCRYPTASSETS + "csv_drafts") == false) FileSystem.createDirectory(C.EXT_NONCRYPTASSETS + "csv_drafts");
			if (FileSystem.exists(C.EXT_NONCRYPTASSETS + "csv_drafts/" + mapname) == false) FileSystem.createDirectory(C.EXT_NONCRYPTASSETS + "csv_drafts/" + mapname);
			
			for (i in 0...4) {
				var a:Array<String> = ["BG", "BG2", "FG", "FG2"];
				var af:Array<Dynamic> = [ms.tm_bg, ms.tm_bg2, ms.tm_fg, ms.tm_fg2];
				File.saveContent(ext + "csv_drafts/"+mapname+"/" + a[i]+"#" + Std.string(id) + ".csv", FlxStringUtil.arrayToCSV(af[i].getData(), af[i].widthInTiles));
			}
			File.saveContent(ext + "csv_drafts/" + mapname + "/" + Std.string(id), tilesetname);
		}
		
		/**
		 * Assumes a is [BG,BG2,FG,FG2]
		 * @param	a
		 * @return bcsv file contents (Big CSV)
		 */
		public static function csv_array_to_disk_bcsv(a:Array<String>):String {
			for (i in 0...a.length) {
				var csv:String = "";
				csv = a[i];
				var b:Bool = false;
				for (c in 0...csv.length) {
					var d:String = csv.charAt(c);
					if (d != "," && d != "0" && d != "\n") {	
						b = true;
						break;
					}
				}
				// Only true if everything is a zero
				if (!b) {
					a[i] = "0";
				}
			}
			var s:String = "";
			//var lines:Array<String> = a[0].split("\n");
			//var th:Int = lines.length;
			//var tw:Int = lines[0].length;
			//s = Std.string(tw) + "," + Std.string(th) + "\n";
			s = "BG\n";
			s += a[0];
			s += "\nBG2\n";
			s += a[1];
			s += "\nFG\n";
			s += a[2];
			s += "\nFG2\n";
			s += a[3];
			return s;
		}
		public static function disk_bcsv_to_csv_array(s:String):Array<String> {
			var a:Array<String> = [];
			var sl:Array<String> = s.split("\n");
			var line:String = "";
			var csv:String = "";
			var mode:Int = 0;
			var tw:Int = 0;
			var th:Int = 0;
			for (i in 0...sl.length) {
				line = StringTools.rtrim(sl[i]);
				if (mode == 0) {
					if (line == "BG") {
						mode = 1;
						continue;
					} else {
						tw = Std.parseInt(line.split(",")[0]);
						th = Std.parseInt(line.split(",")[1]);
						continue;
					}
				}
				if (line == "") continue;
				if (line == "BG") continue;
				if (line == "BG2") {
					
					if (tw == 0 || th == 0) {
						th = csv.split("\n").length;
						tw = csv.split("\n")[0].split(",").length;
					}
					if (csv == "0") csv = FlxX.createEmptyCSV(tw, th, 0);
					a.push(csv);
					csv = "";
				} else if (line == "FG") {
					if (csv == "0") csv = FlxX.createEmptyCSV(tw, th, 0);
					a.push(csv);
					csv = "";
				} else if (line == "FG2") {
					if (csv == "0") csv = FlxX.createEmptyCSV(tw, th, 0);
					a.push(csv);
					csv = "";
				} else {
					if (csv == "") {
						csv += line;
					} else {
						csv += "\n" + line;
					}
				}
			}
			if (csv == "0") csv = FlxX.createEmptyCSV(tw, th, 0);
			a.push(csv);
			return a;
		}
		/**
		 * If use_cached is true, then use editor-cached csvs to avoid
		 * second call to arraytocsv
		 * @param	name
		 * @param	ms
		 * @param	use_cached
		 */
		public static function write_map_csv(name:String, ms:MyState,use_cached:Bool=false):Void {
			#if cpp
			var ext:String = C.EXT_CSV;
			
			var header:String = Std.string(ms.tm_bg.widthInTiles) + "," + Std.string(ms.tm_bg.heightInTiles) + "\n";
			if (use_cached) {
				File.saveContent(ext+name+".bcsv",header+csv_array_to_disk_bcsv([Editor.cache_bg_csv, Editor.cache_bg2_csv, Editor.cache_fg_csv, Editor.cache_fg2_csv]));
				//File.saveContent(ext + name + "_FG2.csv", Editor.cache_fg2_csv);
				EMBED_TILEMAP.csv_hash.set(name + "_BG", Editor.cache_bg_csv);
				EMBED_TILEMAP.csv_hash.set(name + "_BG2", Editor.cache_bg2_csv);
				EMBED_TILEMAP.csv_hash.set(name + "_FG", Editor.cache_fg_csv);
				EMBED_TILEMAP.csv_hash.set(name + "_FG2", Editor.cache_fg2_csv);
			} else {
				var bg:String = FlxStringUtil.arrayToCSV(ms.tm_bg.getData(), ms.tm_bg.widthInTiles);
				var bg2:String = FlxStringUtil.arrayToCSV(ms.tm_bg2.getData(), ms.tm_bg2.widthInTiles);
				var fg:String = FlxStringUtil.arrayToCSV(ms.tm_fg.getData(), ms.tm_fg.widthInTiles);
				var fg2:String = FlxStringUtil.arrayToCSV(ms.tm_fg2.getData(), ms.tm_fg2.widthInTiles);
				File.saveContent(ext + name+".bcsv", header+csv_array_to_disk_bcsv([bg, bg2, fg, fg2]));
				EMBED_TILEMAP.csv_hash.set(name + "_BG", bg);
				EMBED_TILEMAP.csv_hash.set(name + "_BG2", bg2);
				EMBED_TILEMAP.csv_hash.set(name + "_FG", fg);
				EMBED_TILEMAP.csv_hash.set(name + "_FG2", fg2);
			}

			/**
			 * When we subsequently load this map in the editor we want to make sure the editor
			 * loads the most recent tilemaps (since tilemaps should be exclusively change in-editor)
			 */
			
			#end
			
		}
		
		public static function init_flxsprite_group(maxSize:Int, w:Int, h:Int, image:Dynamic = null,x_pos:Array<Int>=null,y_pos:Array<Int>=null,color:Int=0xff0000,alpha:Int=0xff):FlxGroup {
			
			var group:FlxGroup = new FlxGroup(maxSize);
			var e:FlxSprite;
			var i:Int;
			for (i in 0...group.maxSize) {
				e = new FlxSprite();
				e.exists = false;
				if (image == null) {
					e.makeGraphic(w, h, color | alpha << 24);
				} else {
					e.myLoadGraphic(image, true, false, w, h);
				}
				if (x_pos != null) {
					e.x = x_pos[i % x_pos.length];
				}
				if (y_pos != null) {
					e.y = y_pos[i & y_pos.length];
				}
				group.add(e);
			}
			return group;
		}
		
		/**
		 * Removes and frees the memory associated with the sprites in the below_bg, bg2, and fg2 sprite layers
		 * @param	ms
		 */
		public static  function clear_entities_from_mystate(ms:MyState):Void 
		{
			var a:Array<Dynamic> = [];
			for (i in 0...ms.bg2_sprites.members.length) {
				a.push(ms.bg2_sprites.members[i]);
			}
			for (i in 0...ms.fg2_sprites.members.length) {
				a.push(ms.fg2_sprites.members[i]);
			}
			for (i in 0...ms.bg1_sprites.members.length) {
				a.push(ms.bg1_sprites.members[i]);
			}
			for (i in 0...ms.below_bg_sprites.members.length) {
				a.push(ms.below_bg_sprites.members[i]);
			}
			for (i in 0...a.length) {
				if (a[i] != null) {
					a[i].destroy();
				}
			}
			a = [];
			ms.bg2_sprites.clear();
			ms.below_bg_sprites.clear();
			ms.bg1_sprites.clear(); 
			ms.fg2_sprites.clear();
			
			// This is done here, so AFTER entering the game from title, and the sprites from last time r deleted
			// It resets the state in case any spries were going to use that state... idk
			BubbleSpawner.reset_statics(); // In case player pauses/quits in middle of bubble spawn, reset these vars so bubbles can still spawn
			if (Registry.R != null && Registry.R.player != null) {
				Registry.R.player.has_bubble = false;
			}
			
		}
		
		public static function insert_list_before_object_in_mysprite_layer(m:MySprite, p:MyState, a:Array<Dynamic>,ahead:Bool=false):Void {
			var active_group:FlxGroup = null;
		
			if (m.cur_layer == MyState.ENT_LAYER_IDX_BG2) {
				active_group = p.bg2_sprites;
			} else if (m.cur_layer == MyState.ENT_LAYER_IDX_FG2) {
				active_group = p.fg2_sprites;
			} else if (m.cur_layer == MyState.ENT_LAYER_IDX_BELOW_BG) {
				active_group = p.below_bg_sprites;
			} else if (m.cur_layer == MyState.ENT_LAYER_IDX_BG1) {
				active_group = p.bg1_sprites;
			}
			if (active_group == null) {
				Log.trace("wat" + Std.string(m.cur_layer));
			}
				
			for (i in 0...a.length) {
				active_group.add(a[i]);
				var exist_idx:Int = FlxX.indexOf(active_group, m);
				var new_Idx:Int = FlxX.indexOf(active_group, a[i]);
				active_group.members.splice(new_Idx, 1);
				if (ahead) {
					active_group.members.insert(exist_idx+1, a[i]);
				} else {
					active_group.members.insert(exist_idx, a[i]);
				}
			}
		}
		public static function add_list_to_mysprite_layer(m:MySprite, p:MyState, a:Array<Dynamic>,force_layer_idx:Int=-1):Void {
			var old:Int = m.cur_layer;
			if (force_layer_idx != -1) {
				old = m.cur_layer;
				m.cur_layer = force_layer_idx;
			}
			for (i in 0...a.length) {
				if (m.cur_layer == MyState.ENT_LAYER_IDX_BG2) {
					p.bg2_sprites.add(a[i]);
				} else if (m.cur_layer == MyState.ENT_LAYER_IDX_FG2) {
					p.fg2_sprites.add(a[i]);
				} else if (m.cur_layer == MyState.ENT_LAYER_IDX_BELOW_BG) {
					p.below_bg_sprites.add(a[i]);
				} else if (m.cur_layer == MyState.ENT_LAYER_IDX_BG1) {
					p.bg1_sprites.add(a[i]);
				}
			}
			m.cur_layer = old;
		}
		
		public static function remove_list_from_mysprite_layer(m:MySprite, p:MyState, a:Array<Dynamic>, force_layer_idx:Int = -1):Void {
			var old:Int = m.cur_layer;
			if (force_layer_idx != -1) {
				old = m.cur_layer;
				m.cur_layer = force_layer_idx;
			}
			for (i in 0...a.length) {
				if (m.cur_layer == MyState.ENT_LAYER_IDX_BG2) {
					p.bg2_sprites.remove(a[i], true);
				} else if (m.cur_layer == MyState.ENT_LAYER_IDX_FG2) {
					p.fg2_sprites.remove(a[i],true);
				} else if (m.cur_layer == MyState.ENT_LAYER_IDX_BELOW_BG) {
					p.below_bg_sprites.remove(a[i],true);
				} else if (m.cur_layer == MyState.ENT_LAYER_IDX_BG1) {
					p.bg1_sprites.remove(a[i],true);
				}
			}
			m.cur_layer = old;
		}
		
		/**
		 * A wrapper, if running in dev-mode it will read from the dev stuff
		 * @param	id
		 */
		public static function getBitmapData(id:String) {
			if (ProjectClass.DEV_MODE_ON) {
				Assets.getBitmapData(C.EXT_DEV + id);
			} else {
				Assets.getBitmapData(id);
			}
		}
		
		public static function get_int_prop_in_ent_line(s:String,name:String):Int {
			for (part in s.split(" ")) {
				if (part.split("=")[0] == name) {
					return Std.parseInt(part.split("=")[1]);
				}
			}
			return -1;
		}
		public static function replace_prop_in_ent_line(s:String,value:Int,name:String):String {
			var parts:Array<String> = s.split(" ");
			var part:String = "";
			//Log.trace("old s " + s);
			for (part in parts) {
				if (part.split("=")[0] == name) {
					s = StringTools.replace(s, part, name + "=" + Std.string(value));
					//Log.trace("new s "+s);
					return s;
				}
			}
			return s;
		}
		
		public static function round_to_16(o:FlxObject, is_x:Bool = true):Void {
		var new_n:Float = 0;
		new_n = is_x ? o.x : o.y;
		var i:Int = Std.int(new_n) % 16;
		new_n = Std.int(new_n);
		if (i < 8) {
			new_n -= i;
		} else {
			new_n += (16 - i);
		}
		is_x ? o.x = new_n : o.y = new_n;
	}
	
	/**
	 * @param	ahead 
	 * @param	orient_Dir point up,right,down,left - 1,2,3,4
	 * @param	_obj
	 * @return
	 */
	public static function there_is_a_gap(ahead:Bool, orient_dir:Int = 0, _obj:FlxObject,tm:FlxTilemapExt):Bool {
		var yt:Float = 0;
		var xt:Float = 0;
		var vx:Float = _obj.velocity.x;
		var vy:Float = _obj.velocity.y;		
		if (vx != 0) {
			if (orient_dir == 0) {
				yt = _obj.y + _obj.height + 1.5;
			} else if (orient_dir == 2) {
				yt = _obj.y - 1.5;
			} else {
				return false;
			}
		} 
		if (vy!= 0) {
			if (orient_dir == 1) {
				xt = _obj.x  - 1.5;
			} else if (orient_dir == 3) {
				xt = _obj.x + _obj.width + 1.5;
			} else {
				return false;
			}
		}
		if (orient_dir == 0 || orient_dir == 2) {
			if ((vx > 0 && ahead) || (vx < 0 && !ahead)) {
				xt = _obj.x + _obj.width + 16;
			} else if ((vx < 0 && ahead) || (vx > 0 && !ahead)) {
				xt = _obj.x - 16;
			}
		}
		if (orient_dir == 1 || orient_dir == 3) {
			if ((vy > 0 && ahead) || (vy < 0 && !ahead)) {
				yt = _obj.y + _obj.height + 16;
			} else if ((vy < 0 && ahead) || (vy > 0 && !ahead)) {
				yt = _obj.y - 16;
			}
		}
		return tm.getTileCollisionFlags(xt, yt) == 0;
	}
	public static function there_is_a_hard_tile(ahead:Bool, orient_dir:Int = 0, _obj:FlxObject,tm:FlxTilemapExt):Bool {
		var vx:Float = _obj.velocity.x;
		var vy:Float = _obj.velocity.y;
		var yt:Float = 0;
		var xt:Float = 0;
		if (vx != 0 && (orient_dir % 2 == 0)) {
			yt = _obj.y + _obj.height / 2;
			if ((vx > 0 && ahead) || (vx < 0 && !ahead)) {
				xt = _obj.x + _obj.width + 16;
			} else if ((vx < 0 && ahead) || (vx > 0 && !ahead)) {
				xt = _obj.x - 16;
			}
		} else if (vy != 0 && (orient_dir % 2 == 1)) {
			xt = _obj.x + _obj.width / 2;
			if ((vy > 0 && ahead) || (vy < 0 && !ahead)) {
				yt = _obj.y + _obj.height + 16;
			} else if ((vy < 0 && ahead) || (vy > 0 && !ahead)) {
				yt = _obj.y - 16;
			}
		}
		return tm.getTileCollisionFlags(xt,yt) != 0;
	}
		
}