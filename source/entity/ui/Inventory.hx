package entity.ui;
import global.C;
import haxe.Log;
import haxe.Utf8;
import help.HF;
import help.Track;
import openfl.Assets;
import state.TestState;
#if cpp
import sys.io.File;
#end

/**
 * 
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class Inventory 
{

	private var table:Map<String,Dynamic>;
	private var sorted_entry_list:Array<String>;
	private var save_array:Array<Int>;
	private var planted_array:Array<Int>;
	
	public var cached_save_array:Array<Int>;
	public var cached_plante_array:Array<Int>;
	public var is_cached:Bool = false;
	public static var INV_EVEN:Int = 1; /* DEPRECATED */
	
	public static var ITEM_ID_FILLER:Int = 9;
	public static var ITEM_DREAMAMINE:Int = 12;
	public static var ITEM_FUNGUS_MEDS:Int = 13;
	public static var ITEM_CROWBAR:Int = 22;
	public function new() 
	{
		init_inventory();
	}
	
	public function get_item_pic_info(id:Int):Array<Dynamic> {
		var a:Array<Dynamic> = [];
		if (table.get(Std.string(id)) != null && table.get(Std.string(id)).exists("path")) {
			var t:Map<String,Dynamic> = table.get(Std.string(id));
			a.push("assets/"+t.get("path"));
			a.push(t.get("w"));
			a.push(t.get("h"));
			return a;
		}
		return [];
	}
	private var area_ordering:String = "";  // Does not reload
	public function get_area_listing():Array<String> {
		if (TestState.mod_name != "") { // ???
			
		}
		var m:Map<String,Int> = new Map<String,Int>();
		for (i in 0...save_array.length) {
			if (save_array[i] == 1) {
				var name:String = table.get(Std.string(i)).get("area");
				if (!m.exists(name)) {
					m.set(name, 1);
				} else {
					m.set(name, m.get(name) + 1);
				}
			}
		}
		var a:Array<String> = [];
		var ordered_names:Array<String> = [];
		if (area_ordering == "") {
			area_ordering= Assets.getText("assets/misc/AreaOrder.txt");
		}
		ordered_names = area_ordering.split("\n").map(StringTools.rtrim);
		
		for (name in ordered_names) {
			if (m.exists(name)) {
				a.push(name + ":" + Std.string(m.get(name)));
			}
		}
		
		return a;
	}
	
	/**
	 * If we gain an item after a hard save, then checkpoint, and die, then we should still
	 * have that item, but that item's state should not be in the hard save. Thus, 
	 * 
	 */
	public function cache_state():Void {
		//Log.trace("cached");
		cached_save_array = [];
		cached_plante_array = [];
		for (i in 0...save_array.length) {
			cached_save_array[i] = save_array[i];
		}
		for (i in 0...planted_array.length) {
			cached_plante_array[i] = planted_array[i];
		}
		is_cached = true;
		
	}
	/**
	 * If cache_state() has been called before this, then the cached state is
	 * copied over into the live state for inventory stuff
	 */
	public function uncache_state():Void {
		//Log.trace("uncached");
		if (is_cached) {
			is_cached = false;
			for (i in 0...cached_save_array.length) {
				save_array[i] = cached_save_array[i];
			}
			for (i in 0...cached_plante_array.length) {
				planted_array[i] = cached_plante_array[i];
			}
		} 
		return;
	}
	
	public function reset():Void {
		Log.trace("Resetting inventory...");
		save_array = [];
		planted_array = [];
		init_inventory();
	}
	public function get_entries(inv_type:Int, nr:Int, start_idx:Int):Array<String> {
		var a:Array<String> = [];
		var l:Array<String> = [];
		l = sorted_entry_list;
		for (i in start_idx...start_idx + nr) {
			if (i < 0 || i > l.length - 1) {
				a.push("");
			} else {
				if (is_item_found(i)) {
					a.push(l[i]);
				} else {
					a.push("");
				}
			}
		}
		return a;
	}
	private function init_inventory():Void {
		reload_item_metadata(false);
	}
	
	private function extend_or_init_save_array():Void {
		if (save_array == null) save_array = [];
		if (planted_array == null) planted_array = [];
		var max:Int = 0;
		for (key in table.keys()) {
				var i:Int = Std.parseInt(key);
			if (i > max) max = i;
		}
		
		for (i in 0...max+1) {	
			if (max+1 > save_array.length) {
				save_array.push(0);
				planted_array.push(0);
			}
		}
		//Log.trace(["State of save array: ", save_array]);
	}
	public function reload_item_metadata(from_dev:Bool=false):Void {
		
		// note, length of item array deteremined by # of keys in table..?
		if (from_dev) {
			#if cpp
			table = HF.parse_SON(File.getContent(C.EXT_ASSETS + "misc/items.son"));
			#else
			table = HF.parse_SON(Assets.getText("assets/misc/items.son"));
			#end
		} else {
			table = HF.parse_SON(Assets.getText("assets/misc/items.son"));
		}
		
		for (key in table.keys()) {
			if (table.get(key).exists("type") == false) {
				table.get(key).set("type", "plant");
			}
			if (table.get(key).exists("area") == false) {
				table.get(key).set("area", "RIVER");
			}
		}
		extend_or_init_save_array();
	}
	
	public function load_from_save_string(s:String):Void {
		for (i in 0...s.length) {
			if (s.charAt(i) == "0") {
				save_array[i] = 0;
			} else {
				save_array[i] = 1;
			}
		}
		//sorted_entry_list.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
		//Log.trace("Loaded inventory: "+save_array.toString());
	}
	
	public function load_from_plant_string(s:String):Void {
		for (i in 0...s.length) {
			if (s.charAt(i) == "0") {
				planted_array[i] = 0;
			} else {
				planted_array[i] = 1;
			}
		}
	}
	
	public function get_save_string():String {
		var out_s:String = "";
		
		for (i in 0...save_array.length) {
			if (save_array[i] == 1) {
				out_s += "1";
			} else {
				out_s += "0";
			}
		}
		return out_s;
	}
	
	public var last_saved_save_string:String;
	public var last_saved_planted_string:String;
	
	public function cache_last_saved_strings():Void {
		last_saved_planted_string = get_planted_string();
		last_saved_save_string = get_save_string();
	}
	
	public function get_planted_string():String {
		var out_s:String = "";
		
		for (i in 0...planted_array.length) {
			if (planted_array[i] == 1) {
				out_s += "1";
			} else {
				out_s += "0";
			}
		}
		return out_s;
	}
	
	public function get_item_type(index:Int):String {
		var d:Map<String,Dynamic> = table.get(Std.string(index));
		if (d != null && d.exists(Std.string("type"))) {
			if (d.exists("type")) {
				return d.get("type");
			} else {
				return "";
			}
		} else { 
			if (index != -1)  Log.trace("get_item_type - no index " + Std.string(index));
		}
		return "";
	}
	public function is_item_found(index:Int):Bool
	{
		if (save_array[index] == 1) return true;
		return false;
	}
	
	public function is_planted(index:Int):Bool {
		if (planted_array[index] == 1) return true;
		return false;
	}
	
	/**
	 * Used for gettig animaton data for the item-in-area-animation
	 * @param	index
	 * @return
	 */
	public function get_item_data(index:Int):Map < String, Dynamic > {
		var s:String = Std.string(index);
		var d:Map<String,Dynamic> = table.get(s);
		if (d != null) {
			if (d.exists("item_path") && d.exists("item_w") && d.exists("item_h") && d.exists("item_anim") && d.exists("item_fr")) {
				return table.get(s);
			} else {
				//Log.trace("Item-anim data index " + s + " is missing a property.");
				return null;
			}
		}
		if (s != "-1") Log.trace("Item-anim  data index " + s + " doesn't exist?");
		return null;
	}
	
	/**
	 * Used for getting animation data for the plant or trivia icon
	 * @param	index
	 * @return
	 */
	public function get_plant_data(index:Int):Map < String, Dynamic > {
		var s:String = Std.string(index);
		var d:Map<String,Dynamic> = table.get(s);
		if (d != null && d.get("type") == "plant") {
			if (d.exists("path") && d.exists("w") && d.exists("h") && d.exists("anim") && d.exists("fr")) {
				return table.get(s);
			} else {
				Log.trace("Plant data index " + s + " is missing a property.");
				return null;
			}
		}
		Log.trace("Plant data index " + s + " doesn't exist?");
		return null;
	}
	public function get_number_found(inv_type:Int):Int {
		var ct:Int = 0;
		return ct;
	}
	public function set_all_planted():Void {
		for (i in 0...planted_array.length) {
			var d:Map<String,Dynamic> = table.get(Std.string(i));
			if (d != null && d.get("type") == "plant") {
				set_planted(i, 1);
			}
		}
	}
	public function set_planted(index:Int,state:Int=1):Bool {
		if (index >= 0 && index < planted_array.length) {
			if (state == 1) {
				planted_array[index] = 1;
				Log.trace(["Set plant ", index, " to planted."]);
			} else {
				planted_array[index] = 0;
				Log.trace(["Set plant ", index, " to NOT planted."]);
			}
			return true;
		}
		return false;
		
	}
	public function set_item_found(inv_type:Int, index:Int,found:Bool=true):Void {	
		if (index < save_array.length && index > -1) {
			var _oldval:Int = save_array[index];
			if (found) {
				Log.trace("set item #" + Std.string(index) + " to found");
				save_array[index] = 1;
			} else {
				Log.trace("set item #" + Std.string(index) + " to NOT FOUND");
				save_array[index] = 0;
			}
			Track.add_item(index, _oldval, save_array[index]);
		} else {
			Log.trace("Invalid or too-high index: " + Std.string(index));
		}
		return;
	}
}