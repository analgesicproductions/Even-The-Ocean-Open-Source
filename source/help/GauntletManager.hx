package help;
import autom.EMBED_TILEMAP;
import entity.ui.Inventory;
import global.C;
import global.Registry;
import haxe.Log;
import nme.external.ExternalInterface.Hash;
import openfl.Assets;
import flixel.FlxG;
#if cpp
import sys.io.File;
#end

/**
 * 2023 - I think this is unused
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class GauntletManager
{
	public var gauntlet_map:Map<String,Dynamic>;
	public function new() 
	{
		reload();
	}
	
	public var maps:Array<String>;
	public var active_gauntlet_id:String = "";
	public var active_leg_id:Int = -1;
	public var active_gauntlet_status:Array<Int>;
	public var current_leg_times:Array<Int>;
	public var last_chk_time:Int = 0;
	public var item_ids_to_animate:Array<Int>;
	public var do_animation:Bool = false;
	public var gauntlet_ticks:Int = 0;
	public var times:Map<String,Dynamic>;
	public var overall_times:Map<String,Dynamic>;
	public var gauntlet_IDs:Array<String>;
	public var cur_gauntlet_complete:Bool = false; // Status var, whehter the current gauntlet was complete (allows  reset)
	
	public static var GAUN_OVERALL_NOT_FINISHED:Int = -1;
	public static var GAUN_OVERALL_DELETED:Int = 0;
	
	/**
	 * Add new empty gid -> leg-times entries if they don't
	 * already exist in the 'times' hash
	 */
	public function init_times():Void {
		if (times == null) {
			times = new Map<String,Dynamic>();
			overall_times = new Map<String,Dynamic>();
			gauntlet_IDs = [];
		}
		for (key in gauntlet_map.keys()) {
			if (!times.exists(key)) {
				times.set(key, new Array<Int>());
				overall_times.set(key, GAUN_OVERALL_NOT_FINISHED);
				gauntlet_IDs.push(key);
			}
		}
		gauntlet_IDs.sort( function(a:String, b:String):Int
			{
				a = a.toLowerCase();
				b = b.toLowerCase();
				if (a < b) return -1;
				if (a > b) return 1;
				return 0;
			}
		);
	}
	
	public function reload(from_dev:Bool = false):Void {
		if (from_dev) {
			#if cpp
			gauntlet_map = HF.parse_SON(File.getContent(C.EXT_ASSETS + "/misc/gauntlet.son"));
			#else
			gauntlet_map = HF.parse_SON(Assets.getText("assets/misc/gauntlet.son"));
			#end
		} else {
			gauntlet_map = HF.parse_SON(Assets.getText("assets/misc/gauntlet.son"));
		}
		
		init_times();
	}
	
	public function get_save_string():String {
		// gid:overall:legtime:gid2:overall2:legtime2:...
		var is_first:Bool = false;
		var s:String = "";
		for (key in times.keys()) {
			
			if (overall_times.get(key) == GAUN_OVERALL_NOT_FINISHED) {
				continue;
			}
			
			if (!is_first) {
				is_first = true;
				
			} else {
				s += ":";
			}
			
			s += key;
			s += ":";
			s += HF.int_array_to_string(times.get(key));
			s += ":";
			s += Std.string(overall_times.get(key));
		}
		return s;
	}
	public function read_save_string(s:String):Void {
		var data:Array<String> = s.split(":");
		var entries:Int = Math.floor(data.length / 3);
		for (i in 0...entries) {
			times.set(data[i * 3], HF.string_to_int_array(data[i * 3 + 1]));
			overall_times.set(data[i * 3], Std.string(data[i * 3 + 2]));
		}
	}
	
	public function get_in_gauntlet_string():String {
		var s:String = "";
		//   Best    Current
		//1 -00:1405 00:1432
		//2  01:2324 00:1414
		//...
		//N
		//O  --:---- 
		
		s += "   Best    Current\n";
		for (i in 0...current_leg_times.length) {
			s += Std.string(i + 1) + " ";
			if (current_leg_times[i] != 0) { // finishe dleg
				var diff:Int = Std.int(times.get(active_gauntlet_id)[i] -  current_leg_times[i]);
				
				if (times.get(active_gauntlet_id)[i] == 0) {
					diff *= -1;
					s += "-";
				} else if (diff < 0) {
					diff *= -1;
					s += "+";
				} else {
					s += "-";
				}
				s += get_time_text(diff);
			} else { // show best time
				var t:Int = times.get(active_gauntlet_id)[i];
				if (t == 0) { // never yet finished
					s += " --:----";
				} else {
					s += " "+get_time_text(t);
				}
			}
			s += " ";
			if (current_leg_times[i] == 0) {
				if (i == active_leg_id) {
					s += get_time_text(gauntlet_ticks - last_chk_time);
				} else {
					s += "--:----";
				}
			} else {
				s += get_time_text(current_leg_times[i]);
			}
			s += "\n";
		}
		s += "O  ";
		var t:Int = overall_times.get(active_gauntlet_id);
		if (t == GAUN_OVERALL_DELETED || t == GAUN_OVERALL_NOT_FINISHED) {
			s += "--:----";
		} else {
			s += get_time_text(overall_times.get(active_gauntlet_id));
		}
		return s;
		
	}
	
	public function get_quicksave_string():String {
		// Active ID
		// Active LEG
		// Gauntlet ticks
		// Active status
		// Current times
		return active_gauntlet_id + ":" +Std.string(active_leg_id) + ":" + Std.string(gauntlet_ticks) + ":" + HF.int_array_to_string(active_gauntlet_status) + ":" + HF.int_array_to_string(current_leg_times);
	}
	
	public function read_quicksave_string(s:String):Void {
		var parts:Array<String> = s.split(":");
		active_gauntlet_id = parts[0];
		active_leg_id = Std.parseInt(parts[1]);
		gauntlet_ticks = Std.parseInt(parts[2]);
		active_gauntlet_status = HF.string_to_int_array(parts[3]);
		current_leg_times = HF.string_to_int_array(parts[4]);
		cache_gauntlet_entity_data(); 
		//uncache_gauntlet_entity_data();
	}

	
	
	public function is_valid_gauntlet(gauntlet_id:String,leg_id:Int):Bool {
		if (gauntlet_map.exists(gauntlet_id))  {
			
			var g_hash:Map<String,Dynamic> = gauntlet_map.get(gauntlet_id);
			
			// Sometimes teh gauntlets don't have items so generate the items array
			var a:Array<Int> = g_hash.get("items");
			if (a == null) {
				if (g_hash.exists("length")) {
					a = [];
					for (i in 0...g_hash.get("length")) {
						a.push(Inventory.ITEM_ID_FILLER);
					}
				}
			}
			g_hash.set("length", a.length);
			if (g_hash.exists("items") == false) {
				g_hash.set("items", a);
			}
			if (leg_id > a.length || leg_id < 0) { 
				return false;
			}
			
			if (!g_hash.exists("maps")) {
				Log.trace("No maps entry in gauntlet '" + gauntlet_id + "'");
				return false;
			}
			maps = g_hash.get("maps").split(",");
			for (map in maps) {
				if (EMBED_TILEMAP.entity_hash.exists(map) == false) {
					Log.trace("Warning: Gauntlet '" + gauntlet_id + "' has non-existent map '" + map + "'.");
				} else {
					
				}
			}
			return true;
		}
		return false;
	}
	public function cur_gauntlet_has_map(name:String):Bool {
		Log.trace([maps, name]);
		if (active_gauntlet_id != "") {
			if (HF.array_contains(maps, name)) return true;
		}
		return false;
	}
	public function register_death():Void {
		if (active_gauntlet_status != null) {
			if (active_gauntlet_status[active_leg_id] != 1) {
				active_gauntlet_status[active_leg_id] = -1;
				Log.trace(["Status: ", active_gauntlet_status.toString()]);
			}
		}
	}
	
	public function is_end_of_leg(gid:String, lid:Int):Bool {
		if (lid == gauntlet_map.get(gid).get("length")) return true;
		return false;
	}
	
	public function get_status_string():String {
		if (active_gauntlet_status != null) {
			var out_s:String = "";
			for (i in 0...active_gauntlet_status.length) {
				if (active_gauntlet_status[i] == -1) {
					out_s += "-";
				} else if (active_gauntlet_status[i] == 0) {
					out_s += "0";
				} else {
					out_s += "+";
				}
			}
			return out_s;
		}
		return " ";
	}
	
	public function tick():Bool {
		if (active_gauntlet_id != "") {
			if (cur_gauntlet_complete || Registry.R.TEST_STATE.dialogue_box.is_active() || Registry.R.player.is_dying() || Registry.R.TEST_STATE.decision_box.exists) {
				
			} else {
				//if (FlxG.keys.myPressed.R) {
					//gauntlet_ticks += 60;
				//}
				gauntlet_ticks++;
			}
			return true;
		}
		return false;
	}
	public function get_time_text(sometime:Int = -1):String {
		var ticks_to_convert:Int = gauntlet_ticks;
		if (sometime != -1 && sometime >= 0) {
			ticks_to_convert = sometime;
		}
		var ticks:Int = ticks_to_convert % 60;
		var total_seconds:Int = Std.int((ticks_to_convert - ticks) / 60);
		var secs:Int = total_seconds % 60;
		var mins:String = Std.string(Std.int((total_seconds - secs) / 60));
		var sec_str:String = Std.string(secs);
		if (secs < 10) sec_str = "0" + sec_str;
		if (mins.length < 2) mins = "0" + mins;
		var tick_str:String = Std.string(ticks);
		if (ticks < 10) tick_str = "0" + tick_str;
		
		return mins+":"+sec_str+tick_str;
	}
	
	// called by saving in save module
	public function delete_gauntlet_entity_data():Void {
		gauntlet_entity_cache = null;
	}
	
	public function restore_quicksave_cache():Void {
		
	}
	public function uncache_gauntlet_entity_data():Void {
		if (gauntlet_entity_cache != null) {
			var c:Array<String> = [];
			for (key in gauntlet_entity_cache.keys()) {
				EMBED_TILEMAP.entity_hash.set(key, gauntlet_entity_cache.get(key));
				c.push(key);
			}
			Log.trace(["Uncached: ", c]);
		} 
	}
	/**
	 * If you go into a gauntlet while editing and save, then you want your saved progress to appear
	 * if you die, ntot he cached one. so overwrite in the cache if it exists
	 * @param	map
	 */
	public function maybe_overwrite_cache_with_cur_editor_map(map:String):Void {
		if (gauntlet_entity_cache != null) {
			if (gauntlet_entity_cache.exists(map)) {
				gauntlet_entity_cache.set(map, EMBED_TILEMAP.entity_hash.get(map));
			}
		}
	}
	private var gauntlet_entity_cache:Map<String,Dynamic>;
	
	/**
	 * Saves the current entity data for the maps int he active gauntlet,
	 * so if you die or quicksave, the state is the same upon respawn/reload.
	 * Called by: Checkpoint (first time hitting them)
	 * 			PlantblockAccepter (when you activate one)
	 * 			more??
	 */
	public function cache_gauntlet_entity_data():Void {
		if (active_gauntlet_id == "") return;
		
		HF.save_map_entities(Registry.R.TEST_STATE.MAP_NAME, Registry.R.TEST_STATE, true);
		gauntlet_entity_cache = new Map<String,Dynamic>();
		var maps:Array<String> = gauntlet_map.get(active_gauntlet_id).get("maps").split(",");
		var maps_cached:Array<String> = [];
		for (map in maps) {
			if (EMBED_TILEMAP.entity_hash.exists(map)) {
				gauntlet_entity_cache.set(map, EMBED_TILEMAP.entity_hash.get(map));
				maps_cached.push(map);
			}
		}
		Log.trace(["Maps Cached in Gauntlet: ", maps_cached]);
	}
	
		
	public function reset_status():Void {
		
		if (current_leg_times != null && cur_gauntlet_complete) {
			
			var last_best_leg_times:Array<Int> = times.get(active_gauntlet_id);
			for (i in 0...last_best_leg_times.length) {
				if (last_best_leg_times[i] != 0 && last_best_leg_times[i] < current_leg_times[i]) {
					current_leg_times[i] = last_best_leg_times[i];
				}
			}
			times.set(active_gauntlet_id, current_leg_times);
		}
		active_gauntlet_id = "";
		active_leg_id = -1;
		gauntlet_ticks = 0;
		active_gauntlet_status = null;
		current_leg_times = null;
		cur_gauntlet_complete = false;
	}
	
	private var did_init:Bool = false;
	
	public var cur_gaun_init_map:String = "";
	public var cur_gaun_init_x:Int = 0;
	public var cur_gaun_init_y:Int = 0;
	
	public function set_init_chk_coords(map:String, x:Int, y:Int):Void {
		cur_gaun_init_map = map;
		cur_gaun_init_x = x;
		cur_gaun_init_y = y;
	}
	
	/**
	 * Used at the end of gauntlets where you can't really place a final checkpoint. 
	 * Called in the scripts for the consoles that end the level.
	 */
	public function end_gauntlet_from_GNPC():Void {
		if (active_gauntlet_id == "") {
			return;
		}
		update(active_gauntlet_id, gauntlet_map.get(active_gauntlet_id).get("items").length);
	}
	
	public function update(gid:String, lid:Int):Void {
		
		Log.trace(["update gid/lid: ", gid, lid]);
		
		
		// Touched same checkpoint, don't do anything else 
		if (lid == active_leg_id) return;
		
		if (lid == 0) {
			// If you reach the first checkpoint of a non-active gauntlet,
			// initialize the status array and set blah blah
			if (active_gauntlet_id != gid || cur_gauntlet_complete) {
				reset_status();
				active_gauntlet_id = gid;
				active_leg_id = 0;
				Log.trace(["started gauntlet gid: ",active_gauntlet_id]);
				active_gauntlet_status = HF.array_init_with(active_gauntlet_status, 0, gauntlet_map.get(gid).get("items").length);
				current_leg_times = HF.array_init_with(current_leg_times, 0, active_gauntlet_status.length);
				last_chk_time = 0;
				// Set all VanishBLocks / RaiseWalls/ Etc to initial statess
				JankSave.gauntlet_re_init_map(gauntlet_map.get(active_gauntlet_id).get("maps").split(","));
			}
		} else {
			if (cur_gauntlet_complete) return;	
			if (active_gauntlet_id == gid) {
				
				// Only register leg time if you go between successive checkpoints
				if (lid - active_leg_id == 1) {
					current_leg_times[active_leg_id] = gauntlet_ticks - last_chk_time;
					Log.trace(["Leg "+Std.string(lid)+" time:", current_leg_times[active_leg_id]]);
				} else {
					for (i in active_leg_id...lid) { 
						current_leg_times[i] = 0;
					}
				}
				last_chk_time = gauntlet_ticks;
				// If you didn't die on the previous leg, award a point
				active_leg_id = lid;
				if (active_gauntlet_status[lid - 1] != -1) {
					active_gauntlet_status[lid - 1] = 1;
				}
				
				var items:Array<Int> = gauntlet_map.get(gid).get("items");
				if (items != null && lid == items.length) {
						
					// Update leg times
					 //now in reset_status();
					
					if (overall_times.get(gid) == GAUN_OVERALL_NOT_FINISHED || gauntlet_ticks < overall_times.get(gid)) {
						overall_times.set(gid, gauntlet_ticks);
					}
					Log.trace(["Gauntlet "+gid + " times:", current_leg_times]);
					
					
					// Update inventory with new prizes
					var c:Int = 0;
					for (i in 0...active_gauntlet_status.length) {
						if (active_gauntlet_status[i] == 1) c++;
					}
					item_ids_to_animate = [];
					for (i in 0...c) {
						if (!Registry.R.inventory.is_item_found(items[i])) {
							Registry.R.inventory.set_item_found(0, items[i]);
							item_ids_to_animate.push(items[i]);
						}
					}
					// Cache and uncache in order to have the hard-save inventory correct after finished gauntlet
					Registry.R.inventory.cache_state();
					Registry.R.inventory.uncache_state();
					Log.trace([items, "# earned/ IDs: ", c, item_ids_to_animate, Registry.R.inventory.get_save_string()]);
					Log.trace(Registry.R.inventory.get_save_string());
					do_animation = true;
					cur_gauntlet_complete = true;
					// Do animation...?
					//reset_status();
				} 
			} 
			if (active_gauntlet_status != null) {
				Log.trace(["Gid: ", gid, "Lid: ", lid, "Status: ", active_gauntlet_status.toString()]);
			}
		}
	}
}