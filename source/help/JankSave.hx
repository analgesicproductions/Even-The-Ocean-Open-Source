package help;

/**
 * ...
 * @author Melos Han-Tani
 */

import autom.EMBED_TILEMAP;
import entity.ui.WorldMapUncoverer;
import entity.util.Checkpoint;
import entity.util.PlantBlockAccepter;
import entity.util.RaiseWall;
import entity.util.VanishBlock;
import flash.geom.Rectangle;
import flash.Lib;
import global.C;
import global.Registry;
import haxe.Log;
import openfl.Assets;
import flixel.FlxG;
import flixel.text.FlxBitmapText;
 #if cpp
import sys.FileSystem;
import sys.io.FileInput;
import sys.io.FileOutput;
import sys.io.File;
#end
import openfl.display.StageDisplayState;
import openfl.net.SharedObject;



#if openfl_legacy
import openfl.utils.SystemPath;
#else
import lime.system.System;
#end

 
class JankSave 
{

	/**
	 * save states
	 * save the entity data to disk
	 */
	
	public static var dontdolang:Bool = false;
	public static  var SAVE_DIR:String = "";
	private static  var test_array_str:Array<String>;
	private static  var test_array_int:Array<Int>;
	public static var force_checkpoint_things:Bool = false;
	
	private static inline var SER_KEYCONTROLBINDINGS:String = "keycontrols";
	private static inline var SER_SFX_VOLUME:String = "sfxvolume";
	private static inline var SER_MUSIC_VOLUME:String = "musicvolume";
	//private static inline var SER_LETTERBOXING_IS_ON:String = "letterbox_on";
	private static inline var SER_FS_SCALE:String = "fs_scale";
	private static inline var SER_WINDOW_SCALE:String = "window_scale";
	private static inline var SER_IS_FS:String = "IS_FS";
	private static inline var SER_SPEEDRUN_OPTIONS:String = "speedrun";
	private static inline var SER_ACCESS_OPTS:String = "accessopts";
	private static inline var SER_LANGUAGE:String = "language";
	private static inline var SER_REVERSEJOY:String = "joyreverse";
	
	private static inline var SER_SAVE_X:String = "savepoint_x";
	private static inline var SER_SAVE_Y:String = "savepoint_y";
	private static inline var SER_DEATHS:String = "donuts";
	private static inline var SER_GAUNTLETMODE:String = "gauntetmotdee";
	private static inline var SER_STORYMODE:String = "storymodee";
	private static inline var SER_NR_SAVES:String = "calendar";
	private static inline var SER_PLAYTIME:String = "playtime";
	private static inline var SER_EVEN_PLAYTIME:String = "ept";
	private static inline var SER_SAVEMAP:String = "savepoint_mapName";
	private static inline var SER_WORLDMAP_X:String = "mapx";
	private static inline var SER_WORLDMAP_Y:String = "mapy";
	private static inline var SER_WORLDMAP_NAME:String = "mapname";
	private static inline var SER_TRAIN_X:String = "trainx";
	private static inline var SER_TRAIN_Y:String = "trainy";
	private static inline var SER_TRAIN_MAP:String = "trainmap";
	private static inline var SER_ITEMS_STATE:String = "kikawaibmb";
	private static inline var SER_PLANT_STATE:String = "krerikawaibmb";
	private static inline var SER_ALIPH_SAVE_X:String = "aliphsavex";
	private static inline var SER_ALIPH_SAVE_Y:String = "aliphsavey";
	private static inline var SER_ALIPH_SAVE_MAP:String = "aliphsavemap";
	private static inline var SER_EVEN_SAVE_X:String = "evensavex";
	private static inline var SER_EVEN_SAVE_Y:String = "evensavey";
	private static inline var SER_EVEN_SAVE_MAP:String = "evensavemap";
	private static inline var SER_MAPONE_STRING:String = "maponestring";
	private static inline var SER_TEMP_X:String = "tempx";
	private static inline var SER_TEMP_Y:String = "tempy";
	private static inline var SER_TEMP_map:String = "tempmaps";
	private static inline var SER_chk_X:String = "temcpx";
	private static inline var SER_chk_Y:String = "tempcy";
	private static inline var SER_chk_map:String = "tempcmaps";
	private static inline var SER_TEMP_energy:String = "temperngy";
	private static inline var SER_EVENT_STATE:String = "sweetbabyrays";
	private static inline var SER_INV_CACHE:String = "invcache";
	private static inline var SER_PLNTCACHE:String = "plantcahce";
	private static inline var SER_QS_GAUNTLET:String = "qsgaun";
	private static inline var SER_GAUNTLETINFO:String = "afwefawef3";
	private static inline var SER_PLAYERNAME:String = "playername";
	private static inline var SER_SILO_PTS:String  = "silopts";
	private static inline var SER_PERMASONG:String  = "permasong";
	private static inline var SER_OCEANBUCKS_CODES:String = "obcode";
	private static inline var SER_JOY:String = "joyok";
	private static inline var SER_IS_XBOX_JOY:String = "xboxisjoy";
	private static inline var SER_EQUIPPEDMAP:String = "curmapid";
	private static inline var SER_FARTHESTACT:String = "farthestact";
	private static inline var SER_VISITEDLIBRARY:String = "visitedlibrary";
	private static inline var SER_VISITEDMUSEUM:String = "visitedmuseum";
	private static inline var SER_INWARPMODE:String = "inwarpmodea";
	// Note: Make sure the global state delete function is up to date
	public static function init():Void {
		
		#if openfl_legacy
		SAVE_DIR = SystemPath.applicationStorageDirectory + "/save/";
		#else
		SAVE_DIR = System.applicationStorageDirectory + "/save/";
		#end
		//if (FileSystem.exists(System.applicationStorageDirectory+"/save") == false) {
		if (FileSystem.exists(SAVE_DIR) == false) {
			var s:SharedObject = SharedObject.getLocal("INIT", "save");
			s.flush();
		}
	}
	public static function delete(save_id:Int):Void {
		#if cpp
		if (FileSystem.exists(SAVE_DIR + Std.string(save_id))) {
			File.saveContent(SAVE_DIR + Std.string(save_id) + "/deleted", " ");
		}
		#end
	}
	
	public static function quicksave_exists():Bool {
		#if cpp
		if (FileSystem.exists(SAVE_DIR + "42") && !FileSystem.exists(SAVE_DIR+"42/deleted")) {
			return true;
		}
		#end
		return false;
	}
	
	public static function delete_quicksave():Void{
		delete(42);
	}
	
	public static function load_recent(no_patch:Bool=false,dont_load_config:Bool=false):Bool {
		#if cpp
			if (FileSystem.exists(SAVE_DIR + "recent")) {
				var id:Int = Std.parseInt(File.getContent(SAVE_DIR + "recent"));
				if (load(id,false,no_patch,dont_load_config)) {
					Log.trace("Successfully loaded recent save data: " + Std.string(id));
					return true;
				} 
			} else {
				// New game, fullscreen it!
				Log.trace("defaulting to FS on brand new player");
				ProjectClass.FORCE_FULLSCREEN_FLIP = true;
			}
		#end
		return false;
	}
	public static function save_recent():Bool {
		#if cpp
			if (FileSystem.exists(SAVE_DIR + "recent")) {
				var id:Int = Std.parseInt(File.getContent(SAVE_DIR + "recent"));
				Log.trace("Saving recent file " + Std.string(id));
				save(id);
				return true;
			}
		#end
		return false;
	}
	
	/**
	 * 
	 * @param	save_id If not provided uses last saved file
	 */
	public static function save_config_only(save_id:Int = -1):Void {
		
	}
	public static function reset_data_on_new(save_id:Int):Void {
		Registry.R.dialogue_manager.reload(false);
		
		DialogueManager.save_state_string = Registry.R.dialogue_manager.getStateString(); //reset on new game.. because langauge change can get an old file's 
		
		Registry.R.player.energy_bar.set_energy(128);
	}
	public static function save(save_id:Int):Void {
		var s:String = "";
		var R:Registry = Registry.R;
		Track.flush();
		#if cpp
			
			
			var save_dir_id:String = SAVE_DIR + Std.string(save_id) +"/";
			if (FileSystem.exists(SAVE_DIR + Std.string(save_id) + "/deleted")) {
				FileSystem.deleteFile(SAVE_DIR + Std.string(save_id) + "/deleted");
			}
			if (FileSystem.exists(SAVE_DIR + Std.string(save_id)) == false) {
				FileSystem.createDirectory(SAVE_DIR + Std.string(save_id));
			}
			File.saveContent(SAVE_DIR + "recent", Std.string(save_id));
			
			//File.saveContent(save_dir_id+"save_snapshot", HF.get_bitmap_as_text(FlxG.camera._, new Rectangle(0, 0, 64, 64)));
			
			
			s = do_array_str(s, SER_KEYCONTROLBINDINGS, R.input.keybindings);
			s = do_float(s, SER_MUSIC_VOLUME, SongHelper.song_volume_modifier);
			s = do_float(s, SER_SFX_VOLUME, SoundManager.volume_modifier);
			s = do_int(s, SER_LANGUAGE, DialogueManager.CUR_LANGTYPE);
			s = do_string(s, SER_FS_SCALE, ProjectClass.scale_type);
			s = do_int(s, SER_WINDOW_SCALE, ProjectClass.window_scale_type);
			//Log.trace("Saving in fullscreen?");
			//Log.trace([Lib.current.stage.displayState != StageDisplayState.NORMAL]);
			s = do_array_bool(s, SER_IS_FS, [Lib.current.stage.displayState != StageDisplayState.NORMAL]);
			s = do_array_bool(s, SER_SPEEDRUN_OPTIONS, R.speed_opts);
			s = do_array_bool(s, SER_ACCESS_OPTS, R.access_opts);
			s = do_string(s, SER_JOY, R.input.get_joy_save_string());
			s = do_int(s, SER_IS_XBOX_JOY, R.input.is_xbox ? 1 : 0);
			s = do_int(s, SER_REVERSEJOY, R.input.joy_reverse ? 1 : 0);
			var CONFIG_STRING:String = s;
			
			s = "";
			s = do_int(s, SER_EQUIPPEDMAP, R.worldmapplayer.equipped_map_id);
			s = do_int(s, SER_STORYMODE, R.story_mode ? 1 : 0);
			s = do_int(s, SER_GAUNTLETMODE, R.gauntlet_mode ? 1 : 0);
			s = do_int(s, SER_SAVE_X, R.savepoint_X);
			s = do_int(s, SER_SAVE_Y, R.savepoint_Y);
			s = do_int(s, SER_PLAYTIME, R.playtime);
			s = do_int(s, SER_EVEN_PLAYTIME, R.even_playtime);
			s = do_string(s, SER_SAVEMAP, R.savepoint_mapName);
			s = do_int(s, SER_WORLDMAP_X, R.last_worldmap_X);
			s = do_int(s, SER_WORLDMAP_Y, R.last_worldmap_Y);
			s = do_string(s, SER_WORLDMAP_NAME, R.last_worldmap_name);
			s = do_int(s, SER_TRAIN_X, R.train_x);
			s = do_int(s, SER_TRAIN_Y, R.train_y);
			s = do_int(s, SER_ALIPH_SAVE_X, R.last_aliph_save_x);
			s = do_int(s, SER_ALIPH_SAVE_Y, R.last_aliph_save_y);
			s = do_string(s, SER_ALIPH_SAVE_MAP, R.last_aliph_save_map);
			//s = do_string(s, SER_MAPONE_STRING, WorldMapUncoverer.mapone_string);
			s = do_int(s, SER_TEMP_X, Std.int(R.player.x));
			s = do_int(s, SER_TEMP_Y, Std.int(R.player.y));
			s = do_int(s, SER_TEMP_energy, Std.int(R.player.energy_bar.get_energy()));
			s = do_string(s, SER_TEMP_map, R.TEST_STATE.MAP_NAME);
			s = do_string(s, SER_EVENT_STATE, R.get_event_state_save_string());
			s = do_int(s, SER_DEATHS, R.nr_deaths);
			s = do_int(s, SER_NR_SAVES, R.nr_saves);
			s = do_int(s, SER_INWARPMODE, R.inwarpmode);
			s = do_int(s, SER_FARTHESTACT, R.farthestact);
			s = do_int(s, SER_VISITEDLIBRARY, R.visitedlibrary);
			s = do_int(s, SER_VISITEDMUSEUM, R.visitedmuseum);
			//s = do_string(s, SER_GAUNTLETINFO, R.gauntlet_m anager.get_save_string());
			s = do_string(s, SER_PLAYERNAME, R.PLAYER_NAME);
			s = do_string(s, SER_PERMASONG, R.song_helper.permanent_song_name);
			if (R.used_codes != [] && R.used_codes != null) {
				s = do_array_str(s, SER_OCEANBUCKS_CODES, R.used_codes);
			}
			var silo_str:String = Std.string(Std.int(R.silo_coords.get("earth_save_pt").x)) + "," + Std.string(Std.int(R.silo_coords.get("earth_save_pt").y)) + "," + Std.string(Std.int(R.silo_coords.get("air_save_pt").x)) + "," + Std.string(Std.int(R.silo_coords.get("air_save_pt").y)) + ","+Std.string(Std.int(R.silo_coords.get("sea_save_pt").x)) + "," + Std.string(Std.int(R.silo_coords.get("sea_save_pt").y));
			s = do_string(s, SER_SILO_PTS, silo_str);
			
			
			if (force_checkpoint_things) {
				s = do_string(s, SER_chk_map, Checkpoint.tempmap);
				s = do_int(s, SER_chk_X, Checkpoint.tempx);
				s = do_int(s, SER_chk_Y, Checkpoint.tempy);
			}
			if (R.inventory.is_cached) { // Quicksave route - never called via save module route
				s  = do_array_int(s, SER_INV_CACHE, R.inventory.cached_save_array);
				s = do_array_int(s, SER_PLNTCACHE, R.inventory.cached_plante_array);
				R.inventory.uncache_state();
				s = do_string(s, SER_ITEMS_STATE, R.inventory.last_saved_save_string);
				s = do_string(s, SER_PLANT_STATE, R.inventory.last_saved_planted_string);
				
				//if (R.ga untlet_manager.active_gauntlet_id != "") {
					//s = do_string(
					//s, SER_QS_GAUNTLET, R.gauntlet_m anager.get_quicksave_string());
				//}
			} else { 
				s = do_string(s, SER_ITEMS_STATE, R.inventory.get_save_string());
				s = do_string(s, SER_PLANT_STATE, R.inventory.get_planted_string());
			}
			
			
			File.saveContent(SAVE_DIR + Std.string(save_id) + "/config", CONFIG_STRING);
			File.saveContent(SAVE_DIR + Std.string(save_id) + "/data", s);
			File.saveContent(SAVE_DIR + Std.string(save_id) + "/dialoguestate", R.dialogue_manager.getStateString());
			Log.trace("Saved game " + Std.string(save_id));
		#end
		// Save all registry variables
		// Save CSVs ONLY IF IN POST-GAME.!!!!
		// Save map_ent 
	}
	
	private static function do_int(s:String, name:String, i:Int):String {
		s += name + " " + Std.string(i) + "\n";
		return s;
	}
	private static function do_string(s:String, name:String,  outs:String):String {
		s += name + " " + Std.string(outs) + "\n";
		return s;
	}
	private static function do_float(s:String, name:String, f:Float):String {
		s += name + " " + Std.string(f) + "\n";
		return s;
	}
	private static function do_array_int(s:String, name:String, a:Array<Int>):String {
		var srep:String = Std.string(a);
		s += name + " " + srep.substring(1, srep.length - 1) + "\n";
		
		return s;
	}
	private static function do_array_bool(s:String, name:String, a:Array<Bool>):String {
		var outs:String = "";
		
		for (i in 0...a.length) {
			if (a[i] == false) {
				outs += "0";
			} else {
				outs += "1";
			}
		}
		return s + name + " " + outs + "\n";
	}
	
	
	private static function do_array_str(s:String, name:String, a:Array<String>):String {
		var outs:String = "";
		for (i in 0...a.length) {
			var next_s:String = a[i];
			outs += "\"";
			
			for (j in 0...next_s.length) {
				if (next_s.charAt(j) == "\"") {
					outs += "\\\"";
				} else {
					outs += next_s.charAt(j);
				}
			}
			
			outs += "\" ";
		}
		
		return s + name + " " + outs + "\n";
	}
	
	public static function read_savearraystr(s:String,string_only:Bool=false):Array<String> {
		var a:Array<String> = [];
		var begun:Bool = false;
		var next_s:String = "";
		var inside:Bool = false;
		var skip_once:Bool = false;
		for (i in 0...s.length) {
			
			if (skip_once) {
				skip_once = false;
				continue;
			}
			if (!begun || string_only) {
				if (s.charAt(i) == " ") {
					begun = true;
				}
			} else {
				if (inside) {
					if (s.charAt(i) == "\\") {
						if (s.charAt(i + 1) == "\"") {
							next_s += "\"";
							skip_once = true;
							continue;
						}
					} else if (s.charAt(i) == "\"") {
						inside = false;
						a.push(next_s);
						next_s = "";
						continue;
					}
					next_s +=  s.charAt(i);
				} else {
					if (s.charAt(i) == "\"") {
						inside = true;
					}
				}
			}
		}
		return a;
	}
	
	private static function read_saveint(s:String):Int {
		return Std.parseInt(s.split(" ")[1]);
	}
	private static function read_savefloat(s:String):Float {
		return Std.parseFloat(s.split(" ")[1]);
	}
	
	public static function read_savearrayint(s:String):Array<Int> {
		var a:Array<Int> = [];
		var nums:Array<String> = s.split(" ")[1].split(",");
		for (i in 0...nums.length) {
			a.push(Std.parseInt(nums[i]));
		}
		return a;
	}
	
	private static function read_savearraybool(s:String):Array<Bool> {
		var a:Array<Bool> = [];
		var ss:String = s.split(" ")[1];
		for (i in 0...ss.length) {
			if (ss.charAt(i) == "0") {
				a.push(false);
			} else if (ss.charAt(i) == "1") {
				a.push(true);
			}
		}
		return a;
	}
	
	
	private static function read_savestring(s:String):String {
		var outs:String = "";
		var inword:Bool = false;
		for (i in 0...s.length) {
			if (s.charAt(i) == "\r" || s.charAt(i) == "\n") {
				continue;
			}
			if (inword) {
				outs += s.charAt(i);
			}
			if (s.charAt(i) == " ") {
				inword = true;
			}
		}
		return outs;
	}
	
	/**
	 * Load, but only the metadata for the save screen
	 * @param	save_id
	 */
	public static function load_quick(save_id:Int):Bool {
		return load(save_id,true);
	}
	
	public static function any_save_exists():Bool {
		for (i in 0...15) {
			if (save_exists(i)) {
				return true;
			}
		}
		return false;
	}
	public static function save_exists(save_id:Int):Bool {
		
		#if cpp
		
		if (true == FileSystem.exists(SAVE_DIR + Std.string(save_id) + "/deleted")) {
			return false;
		}
		if (false == FileSystem.exists(SAVE_DIR + Std.string(save_id))) {
			return false;
		}
		#end
		return true;
	}
	public static function load(save_id:Int,savemetaonly:Bool=false,no_patch=false,dont_load_config:Bool=false):Bool {
	 /**
	  * If you load, need to reset the entity hash to its original embedded state, 
	  * check for differences in the load file, and then use that in-game
	  */
		var R:Registry = Registry.R;
		#if cpp
		
		if (true == FileSystem.exists(SAVE_DIR + Std.string(save_id) + "/deleted")) {
			//Log.trace("Save file " + Std.string(save_id) + " is marked as deleted.");
			return false;
		}
		if (false == FileSystem.exists(SAVE_DIR + Std.string(save_id))) {
			//Log.trace("Save file " + Std.string(save_id) + " doesn't exist.");
			return false;
		}
		
		var s:String = File.getContent(SAVE_DIR + Std.string(save_id) + "/data");
		if (FileSystem.exists(SAVE_DIR + Std.string(save_id) + "/config")) {
			s = File.getContent(SAVE_DIR + Std.string(save_id) + "/config") + s;
		}
		
		if (!savemetaonly && FileSystem.exists(SAVE_DIR + Std.string(save_id) + "/dialoguestate")) {
			DialogueManager.save_state_string = File.getContent(SAVE_DIR + Std.string(save_id) + "/dialoguestate");
			if (R.dialogue_manager != null) {
				Log.trace("Update dialogue state from save folder...");
				R.dialogue_manager.reload(false);
			}
		}
		
		var lines:Array<String> = s.split("\n");
		
		// If we only want to read basic state about the save (for showing in the save screen)
		if (savemetaonly) {
			for (i in 0...lines.length) {
				var line:String = lines[i];
				switch (line.split(" ")[0]) {
					case SER_PLAYTIME:
						R.playtime = read_saveint(line);
					case SER_SAVEMAP:
						R.savepoint_mapName = read_savestring(line);
					case SER_PLAYERNAME:
						R.PLAYER_NAME = read_savestring(line);
					case SER_STORYMODE:
						R.story_mode = 1 == read_saveint(line);
					case SER_GAUNTLETMODE:
						R.gauntlet_mode = 1 == read_saveint(line);
				}
			}
			return true;
		} else {
			// We're doing a full load, either after dying or from
			// the load menu, so save this as the most recent
			File.saveContent(SAVE_DIR + "recent", Std.string(save_id));
		}
		
		// set this here in case any beta testers ahave some old file eh heh
		R.worldmapplayer.equipped_map_id = -1;
		R.farthestact = 0;
		R.visitedlibrary = 0;
		R.visitedmuseum = 0;
		R.inwarpmode = 0;
		for (i in 0...lines.length) {
			var line:String = lines[i];
			switch (line.split(" ")[0]) {
				// config
				case SER_KEYCONTROLBINDINGS:
					if (!dont_load_config) R.input.keybindings = read_savearraystr(line);
				case SER_REVERSEJOY:
					if (!dont_load_config) R.input.joy_reverse = read_saveint(line) == 1;
				case SER_MUSIC_VOLUME:
					if (!dont_load_config) SongHelper.song_volume_modifier = read_savefloat(line);
				case SER_SFX_VOLUME:
					if (!dont_load_config) SoundManager.volume_modifier = read_savefloat(line);
				case SER_LANGUAGE:
					if (!dont_load_config) { 
						var lang:Int = read_saveint(line);
						//Log.trace([lang, DialogueManager.CUR_LANGTYPE]);
						if (lang != DialogueManager.CUR_LANGTYPE && !JankSave.dontdolang) {
							R.dialogue_manager.set_language(lang);
						}
					}
				case SER_FS_SCALE:
					if (!dont_load_config) {
						ProjectClass.scale_type = read_savestring(line);
					}
				case SER_WINDOW_SCALE:
					if (!dont_load_config) {
						ProjectClass.window_scale_type = read_saveint(line);
					}
				case SER_IS_FS:
					if (!dont_load_config) {
						//Log.trace("Saved in fullscreen?");
						//Log.trace(read_savearraybool(line)[0]);
						if (true == read_savearraybool(line)[0]) {
							if (Lib.current.stage.displayState == StageDisplayState.NORMAL) {
								ProjectClass.FORCE_FULLSCREEN_FLIP = true; // Will also resize scaling
							} else {
								ProjectClass.TOGGLE_LETTERBOXING = true; // only change sclaing
							}
						} else {
							if (Lib.current.stage.displayState != StageDisplayState.NORMAL) {
								ProjectClass.FORCE_FULLSCREEN_FLIP = true; // Will also resize scaling
							} else {
								FlxG.resizeWindow(ProjectClass.window_scale_type * 416, ProjectClass.window_scale_type * 256);
								FlxG.resizeWindow(ProjectClass.window_scale_type * 416, ProjectClass.window_scale_type * 256);
							}
						}
			//s = do_int(s, SER_IS_FS, Lib.current.stage.displayState != StageDisplayState.NORMAL);
					}
				case SER_SPEEDRUN_OPTIONS:
					if (!dont_load_config) {
						var bb:Array<Bool> = read_savearraybool(line);
						for (pp in 0...bb.length) {
							R.speed_opts[pp] = bb[pp];
						}
					}
				case SER_ACCESS_OPTS:
					if (!dont_load_config) {
						var bb:Array<Bool> = read_savearraybool(line);
						for (pp in 0...bb.length) {
							if (pp + 1 > R.access_opts.length) { // in case an old version loads a new save
								R.access_opts.push(bb[pp]);
							} else {
								R.access_opts[pp] = bb[pp];
							}
						}
					}
				// Non-config
				case SER_EQUIPPEDMAP:
					R.worldmapplayer.equipped_map_id = read_saveint(line);
				case SER_STORYMODE:
					R.story_mode = 1 == read_saveint(line);
				case SER_GAUNTLETMODE:
					R.gauntlet_mode = 1 == read_saveint(line);
				case SER_VISITEDLIBRARY:
					R.visitedlibrary = read_saveint(line);
					if (R.visitedlibrary == 1) {
						R.achv.unlock(R.achv.library);
					}
				case SER_VISITEDMUSEUM:
					R.visitedmuseum = read_saveint(line);
					if (R.visitedmuseum == 1) {
						R.achv.unlock(R.achv.museum);
					}
				case SER_INWARPMODE:
					R.inwarpmode = read_saveint(line);
				case SER_FARTHESTACT:
					R.farthestact = read_saveint(line);
					if (R.farthestact > 0) {
						for (achvdx in 0...R.farthestact) {
							R.achv.unlock(achvdx);
						}
					}
				case SER_EVEN_PLAYTIME:
					R.even_playtime = read_saveint(line);
				case SER_PLAYTIME:
					R.playtime = read_saveint(line);
				case SER_DEATHS:
					R.nr_deaths = read_saveint(line);
				case SER_NR_SAVES:
					R.nr_saves = read_saveint(line);
				case SER_SAVE_X:
					R.savepoint_X = read_saveint(line);
				case SER_SAVE_Y:
					R.savepoint_Y = read_saveint(line);
				case SER_SAVEMAP:
					R.savepoint_mapName = read_savestring(line);
				case SER_WORLDMAP_X:
					R.last_worldmap_X = read_saveint(line);
				case SER_WORLDMAP_Y:
					R.last_worldmap_Y = read_saveint(line);
				case SER_WORLDMAP_NAME:
					R.last_worldmap_name = read_savestring(line);
				case SER_TRAIN_X:
					R.train_x = read_saveint(line);
				case SER_TRAIN_Y:
					R.train_y = read_saveint(line);
				case SER_ITEMS_STATE:
					R.inventory.load_from_save_string(read_savestring(line));
				case SER_PLANT_STATE:
					R.inventory.load_from_plant_string(read_savestring(line));
				case SER_ALIPH_SAVE_X:
					R.last_aliph_save_x = read_saveint(line);
				case SER_ALIPH_SAVE_Y:
					R.last_aliph_save_y = read_saveint(line);
				case SER_ALIPH_SAVE_MAP:
					R.last_aliph_save_map = read_savestring(line);
				case SER_MAPONE_STRING:
					//WorldMapUncoverer.mapone_string = read_savestring(line);
				case SER_TEMP_X:
					R.tempx = read_saveint(line);
				case SER_TEMP_Y:
					R.tempy = read_saveint(line);
				case SER_TEMP_map:
					R.tempmap = read_savestring(line);
				case SER_EVENT_STATE:
					R.load_event_state_save_string(read_savestring(line));
				case SER_TEMP_energy:
					R.temp_energy = read_saveint(line);
					R.player.energy_bar.set_energy(R.temp_energy);
					Log.trace("Set energy " + Std.string(R.temp_energy));
				case SER_chk_map:
					force_checkpoint_things = true;
					Checkpoint.tempmap = read_savestring(line);
				case SER_chk_X:
					Checkpoint.tempx = read_saveint(line);
				case SER_chk_Y:
					Checkpoint.tempy = read_saveint(line);
				case SER_INV_CACHE:
					R.inventory.is_cached = true;
					R.inventory.cached_save_array = read_savearrayint(line);
				case SER_PLNTCACHE:
					R.inventory.is_cached = true;
					R.inventory.cached_plante_array = read_savearrayint(line);
				case SER_QS_GAUNTLET:
					//R.gauntlet_ manager.read_quicksave_string(read_savestring(line));
				case SER_GAUNTLETINFO:
					//R.gauntlet_ma nager.read_save_string(read_savestring(line));
				case SER_PLAYERNAME:
					R.PLAYER_NAME = read_savestring(line);
				case SER_SILO_PTS:
					// ex,ey,ax,ay,sx,sy in INTS
					R.silo_coords = new Map<String,Dynamic>();
					var silostr:String = read_savestring(line);
					var str_a:Array<String> = silostr.split(",");
					var int_a:Array<Int> = [];
					for (i in 0...str_a.length) {
						int_a.push(Std.parseInt(str_a[i]));
					}
					R.get_silo_bitmap(int_a[0], int_a[1], 80, 80, "earth_");
					R.get_silo_bitmap(int_a[2], int_a[3], 80, 80, "air_");
					R.get_silo_bitmap(int_a[4], int_a[5], 80, 80, "sea_");
				case SER_PERMASONG:
					R.song_helper.permanent_song_name = read_savestring(line);
					if (R.song_helper.permanent_song_name != "") {
						Log.trace("permasong found: " + R.song_helper.permanent_song_name);
					}
				case SER_OCEANBUCKS_CODES:
					R.init_bucks();
					R.used_codes = read_savearraystr(line);
					for (code in R.used_codes) {
						R.add_bucks(code);
					}
				case SER_JOY:
					if (!dont_load_config) R.input.set_joykeys_from_save_string(read_savestring(line));
				case SER_IS_XBOX_JOY:
					if (!dont_load_config) R.input.is_xbox = (1 == read_saveint(line));
			}
		}
		#end
		
		if (R.inventory.is_cached) {
			R.inventory.uncache_state();
		}
		return true;
	  
	}
	
	
	public static var patch_percent:Float = 0;
	public static var patch_text:FlxBitmapText;
	// Deprecated 2015 8 11
	public static function patch_disk_entity_data(path:String,visited_array:Array<String>):Void {
	}
	
	public static function create_hard_save_in_memory_entity_hash():Void {
	}
	
	public static function replace_prop(disk_s:Array<String>,geid:String,_part:String):Array<String> {
		var disk_line:String = "";
		var parts:Array<String> = [];
		for (i in 0...disk_s.length) {
			disk_line = disk_s[i];
			parts = disk_line.split(" ");
			if (parts[3] == geid) {
				var part:String = "";
				for (part in parts) {
					if (part.split("=")[0] == _part.split("=")[0]) {
						if (part.split("=")[1] == _part.split("=")[1]) return disk_s;
						//Log.trace("-----\nReplace: " + disk_line);
						disk_line = StringTools.replace(disk_line, part, _part);
						disk_s[i] = disk_line;
						//Log.trace("with " + disk_lines[i]);
						return disk_s;
					}
				}
			}
		}
		//Log.trace("shouldnt be here");
		//Log.trace(geid);
		//Log.trace(_part);
		//Log.trace(disk_s);
		return disk_s;
	}

	// Deprecatd 2015 8 11
	public static function gauntlet_re_init_map(maps:Array<String>):Void {
	}
	
}