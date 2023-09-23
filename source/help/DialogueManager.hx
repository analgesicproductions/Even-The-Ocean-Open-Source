package help;
import autom.EMBED_TILEMAP;
import entity.ui.DialogueBox;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import global.C;
import global.Registry;
import haxe.Log;
import haxe.Utf8;
import openfl.Assets;
import flixel.group.FlxGroup;
#if cpp
import sys.io.File;
#end

/**
 * Manages localization, which dialogue object to use, I/O, constants
 * @author Melos Han-Tani
 */

class DialogueManager 
{

	public var DIALOGUE_LINE_HEIGHT:Int = 8;
	public var DIALOGUE_CHAR_WIDTH:Int = 8;
	
	public static var CUR_LANGTYPE:Int = 0;
	public static inline var LANGTYPE_EN:Int = 0;
	//public static inline var LANGTYPE_FAKE:Int = 1;
	public static inline var LANGTYPE_ZH_SIMP:Int = 1;
	public static inline var LANGTYPE_ZH_TRAD:Int = 2;
	public static inline var LANGTYPE_JP:Int = 3;
	public static inline var LANGTYPE_DE:Int = 4;
	public static inline var LANGTYPE_RU:Int = 5;
	public static inline var LANGTYPE_ES:Int = 6;
	public static var arrayLANGTYPEcaps:Array<String>;
	
	private static inline var SCENEPROP_TEXT:String = "text";
	private static inline var SCENEPROP_POS:String = "pos";
	private static inline var SCENEPROP_NR_PLAYS:String = "nr_plays";
	private static inline var SCENEPROP_state_1:String = "x";
	private static inline var SCENEPROP_state_2:String = "y";
	
	public static var save_state_string:String = "";
	
	private var dialogue_object:Map<String,Dynamic>;
	
	public static inline var M_UI:String = "ui";
	
	public function new()
	{
		arrayLANGTYPEcaps = ["EN","ZH_SIMP","ZH_TRAD","JP","DE","RU","ES"];
		set_language(CUR_LANGTYPE);
	}
	private var load_dialogue_data_from_dev_directory:Bool = false;
	
	public function reload(from_dev:Bool = false):Void {
		load_dialogue_data_from_dev_directory = from_dev;
		set_language(CUR_LANGTYPE);
		load_dialogue_data_from_dev_directory = false;

	}
	public function get_langtype():Int {
		return CUR_LANGTYPE;
	}
	public function is_chinese():Bool {
		return CUR_LANGTYPE == LANGTYPE_ZH_SIMP || CUR_LANGTYPE == LANGTYPE_ZH_TRAD;
	}
	public function is_other():Bool {
		return CUR_LANGTYPE == LANGTYPE_DE || CUR_LANGTYPE == LANGTYPE_RU || CUR_LANGTYPE == LANGTYPE_ES;
	}
	
	public function word_count():Int {
		var count:Int = 0;
		var a:Array<String> = [];
		var d:Map<String,Dynamic> = Registry.R.dialogue_manager.dialogue_object;
		var m:Map<String,Dynamic> = null;
		var _m:String;
		var ad:Array<Dynamic> = [];
		for (_m in d.keys()) {
			m = d.get(_m);
			var mc:Int = 0;
			for (_s in m.keys()) {
				a = d.get(_m).get(_s).get("text");
				var c:Int = 0;
				for (t in a) {
					c += t.split(" ").length;
				}
				count += c;
				mc += c;
				Log.trace([_m, _s, c]);
			}
			ad.push(_m+" "+Std.string(mc));
			
		}
		Log.trace("Total count: "+Std.string(count));
		ad.sort(function(a:String, b:String):Int { 
			
			var _a:Int = Std.parseInt(a.split(" ")[1]);
			var _b:Int = Std.parseInt(b.split(" ")[1]);
			if (_a > _b) return 1;
			if (_a == _b) return 0;
			return -1;
			} );
		
		for (entry in ad) {
			Log.trace(entry);
		}
		return count;
	}
	public var first_time:Bool = true;
	public function set_language(LANGTYPE:Int,external:Bool=false):Void {
		//Log.trace(LANGTYPE);
		// todo also set font
		var same_lang:Bool = CUR_LANGTYPE == LANGTYPE;
		CUR_LANGTYPE = LANGTYPE;
		
		C.CURRENT_FONT_TYPE = C.FONT_TYPE_ALIPH_WHITE;
		switch (LANGTYPE) {
			case LANGTYPE_EN:
				//C.CURRENT_FONT_TYPE = C.C_FONT_APPLE_WHITE_STRING;
				DIALOGUE_LINE_HEIGHT = C.ALIPH_FONT_h + 6;
				Registry.R.PLAYER_NAME = "Player";
			case LANGTYPE_JP:
				DIALOGUE_LINE_HEIGHT = C.JP_FONT_h + 3;
				Registry.R.PLAYER_NAME = "プレーヤー";
			case LANGTYPE_ZH_SIMP:
				Registry.R.PLAYER_NAME = "玩家";
				DIALOGUE_LINE_HEIGHT = C.ZH_SIMP_FONT_h + 4;
			case LANGTYPE_DE:
				Registry.R.PLAYER_NAME = "Spieler";
				DIALOGUE_LINE_HEIGHT = C.OTHER_FONT_h + 2;
			case LANGTYPE_RU:
				Registry.R.PLAYER_NAME = "игрок";
				DIALOGUE_LINE_HEIGHT = C.OTHER_FONT_h + 2;
			case LANGTYPE_ES:
				Registry.R.PLAYER_NAME = "Jugador";
				DIALOGUE_LINE_HEIGHT = C.OTHER_FONT_h + 2;
				
			default:
				Log.trace("No such language ID " + Std.string(LANGTYPE) + ", defaulting to English");
				CUR_LANGTYPE = LANGTYPE_EN;
				DIALOGUE_LINE_HEIGHT = C.ALIPH_FONT_h;
				C.CURRENT_FONT_TYPE = C.FONT_TYPE_ALIPH_WHITE;
		}
		
		make_dialogue_object();
		var map_labels:Array<String> = lookup_scene("ui", "maplabels");
		if (map_labels != null) {
			for (label in map_labels) {
				label = label.split("\r")[0].split("\n")[0];
				var mapname:String = label.split(":")[0];
				label = label.split(":")[1];
				EMBED_TILEMAP.actualname_hash.set(mapname, label);
			}
		} else {
			Log.trace("Warning: No map labels for language type: " + Std.string(CUR_LANGTYPE));
		}
		
		// note the slow thing is the new allocation for each bitmap font for whatever damn reason
		// Need to re-init all labels here!!
		// CAlls new on all the texts in wherever, which uupdates their fonts.
		if (!first_time  && !same_lang) {
			if (external) {
				NEED_TO_UPDATE_FONT = true;
			} else {
				Log.trace("Updating fonts...");
				for (i in 0...NEEDED_FONT_UPDATES) {
					update_update_font(i);
				}
			}
		}
		first_time = false;
		
	}
	
	public var NEED_TO_UPDATE_FONT = false;
	public var NEEDED_FONT_UPDATES:Int = 7;
	public function update_update_font(i:Int):Void {

		if (i == 0) Registry.R.TITLE_STATE.update_font();
		if (i == 5) Registry.R.TEST_STATE.dialogue_box.update_font();
		if (i == 1) {
			Registry.R.TITLE_STATE.dialogue_box.update_font();
			Registry.R.TEST_STATE.eae.update_font();
		}
		if (i == 2) Registry.R.journal.update_font();
		if (i == 3) Registry.R.save_module.update_font();
		if (i == 4) {
			Registry.R.joy_module.update_font();
			Registry.R.name_entry.update_font();
		}
		if (i == 6) Registry.R.TEST_STATE.pause_menu.update_font();
		NEED_TO_UPDATE_FONT = false;
	}
	
	public var skip_updating_with_sss:Bool = false;
	private function make_dialogue_object():Void {
		// Resets memory dialogue
		dialogue_object = get_dialogue_object(CUR_LANGTYPE);
		if (!skip_updating_with_sss) {
			// Update state of the on-disk object with save file if relevant
			updateDialogueHashWithSaveStateString(dialogue_object); 
		} else {
			skip_updating_with_sss = false;
			Log.trace("Not updating dialogue state with on-disk string. Because of starting a new game.");
		}
	}
	
	public function add_mod_dialogue(mod_name:String, language:Int,_dialogue_ob:Map<String,Dynamic>):Void {
		// Aint do nothing yet - get data
		//create_dialogue_hash(,_dialogue_ob);
		//set_ language(language); //zomggomgogmo
	}
	
	
	public function key_replace(s:String):String {
		
		if (Registry.R.input.keybindings[2] == "DOWN") {
			s = StringTools.replace(s, "{DOWN_KEY}", lookup_sentence("ui","control_desc", 2, true, true, true));	
		} else {
			s = StringTools.replace(s, "{DOWN_KEY}", Registry.R.input.keybindings[2]);	
		}
		
		if (Registry.R.input.keybindings[3] == "LEFT") {
			s = StringTools.replace(s, "{LEFT_KEY}", lookup_sentence("ui","control_desc", 3, true, true, true));
		} else {
			s = StringTools.replace(s, "{LEFT_KEY}", Registry.R.input.keybindings[3]);
		}
		
		if (Registry.R.input.keybindings[1] == "RIGHT") {
			s = StringTools.replace(s, "{RIGHT_KEY}", lookup_sentence("ui","control_desc", 1, true, true, true));
		} else {
			s = StringTools.replace(s, "{RIGHT_KEY}", Registry.R.input.keybindings[1]);
		}
		if (Registry.R.input.keybindings[0] == "UP") {
			s = StringTools.replace(s, "{UP_KEY}", lookup_sentence("ui","control_desc", 0, true, true, true));
		} else {
			s = StringTools.replace(s, "{UP_KEY}", Registry.R.input.keybindings[0]);
		}
		
		if (FlxG.gamepads.lastActive != null) {
			// ps4 button replaces
			if (FlxG.gamepads.lastActive.detectedModel == FlxGamepadModel.PS4) {
				if (Registry.R.input.joy_reverse) {
					s = StringTools.replace(s , "{CONFIRM_KEY}", lookup_sentence("helptip", "btnkey", 5, true, true, true));
					s = StringTools.replace(s , "{JUMP_KEY}", lookup_sentence("helptip", "btnkey", 6, true, true, true));
				} else {
					s = StringTools.replace(s , "{CONFIRM_KEY}", lookup_sentence("helptip", "btnkey", 7, true, true, true));
					s = StringTools.replace(s , "{JUMP_KEY}", "✖ "+lookup_sentence("helptip", "btnkey", 1, true, true, true));
				}
				s = StringTools.replace(s , "{PAUSE_KEY}", "OPTIONS "+lookup_sentence("helptip", "btnkey", 1, true, true, true));
				s = StringTools.replace(s , "{SIT_KEY}", "▲ "+lookup_sentence("helptip", "btnkey", 1, true, true, true));
			} else {
				// xbox/etc buttno replaces
				if (Registry.R.input.joy_reverse) {
					s = StringTools.replace(s , "{CONFIRM_KEY}", lookup_sentence("helptip", "btnkey", 10, true, true, true));
					s = StringTools.replace(s , "{JUMP_KEY}", lookup_sentence("helptip", "btnkey", 9, true, true, true));
				} else {
					s = StringTools.replace(s , "{CONFIRM_KEY}", lookup_sentence("helptip", "btnkey", 8, true, true, true));
					s = StringTools.replace(s , "{JUMP_KEY}", "A "+lookup_sentence("helptip", "btnkey", 1, true, true, true));
				}
				s = StringTools.replace(s , "{PAUSE_KEY}", "START "+lookup_sentence("helptip", "btnkey", 1, true, true, true));
				s = StringTools.replace(s , "{SIT_KEY}", "Y "+lookup_sentence("helptip", "btnkey", 1, true, true, true));
			}
			s = StringTools.replace(s, "{BTNKEY}", lookup_sentence("helptip", "btnkey", 1, true, true, true));
		} else {
			
			if (Registry.R.dialogue_manager.is_chinese()) {
				s = StringTools.replace(s , "{CONFIRM_KEY}", Registry.R.input.keybindings[5]+""+lookup_sentence("helptip", "btnkey", 0, true, true, true));
				s = StringTools.replace(s , "{JUMP_KEY}", Registry.R.input.keybindings[4] + ""+lookup_sentence("helptip", "btnkey", 0, true, true, true));
				s = StringTools.replace(s, "{PAUSE_KEY}", Registry.R.input.keybindings[6]+""+lookup_sentence("helptip", "btnkey", 0, true, true, true));
				s = StringTools.replace(s, "{SIT_KEY}", Registry.R.input.keybindings[7] + "" + lookup_sentence("helptip", "btnkey", 0, true, true, true));
			} else {
				s = StringTools.replace(s , "{CONFIRM_KEY}", Registry.R.input.keybindings[5]+" "+lookup_sentence("helptip", "btnkey", 0, true, true, true));
				s = StringTools.replace(s , "{JUMP_KEY}", Registry.R.input.keybindings[4] + " "+lookup_sentence("helptip", "btnkey", 0, true, true, true));
				s = StringTools.replace(s, "{PAUSE_KEY}", Registry.R.input.keybindings[6]+" "+lookup_sentence("helptip", "btnkey", 0, true, true, true));
				s = StringTools.replace(s, "{SIT_KEY}", Registry.R.input.keybindings[7] + " " + lookup_sentence("helptip", "btnkey", 0, true, true, true));
			}
			s = StringTools.replace(s, "{BTNKEY}", lookup_sentence("helptip", "btnkey", 0, true, true,true));
		}
		return s;
	}
	/**
	 * Lookup a single piece of dialogue - mostly for multilnigual string labels
	 * @return
	 */
	public function lookup_sentence(map:String, scene:String, pos:Int,nosplit:Bool=false,raw:Bool=false,noreplace:Bool=false):String {
		if (dialogue_object.exists(map)) {
			if (dialogue_object.get(map).exists(scene)) {
				var nsentences:Array<String> = dialogue_object.get(map).get(scene).get(SCENEPROP_TEXT);
				var sentences:Array<String> = [];
				for (i in 0...nsentences.length) {
					sentences.push(nsentences[i]);
				}
				if (raw) {
					if (noreplace) return sentences[pos];
					sentences[pos] = key_replace(sentences[pos]);
					sentences[pos] = StringTools.replace(sentences[pos], "\\n", "\n");
					return sentences[pos];
				}
				var s_pieces:Array<String> = [];
				
				if (pos > sentences.length - 1) {
					s_pieces = get_chunks(sentences[0]);
				} else {
					s_pieces = get_chunks(sentences[pos]);
				}
				var s:String = "";
				for (i in 0...s_pieces.length) {
					s += s_pieces[i];
					if (i != s_pieces.length - 1) {
						if (!nosplit) {
							s += "\n";
						} else {
							s += " ";
						}
					}
				}
				return s;
			}
		}
		Log.trace("No such sentence from " + map + " " + scene + "at pos "+Std.string(pos));
		return " ";
	}
	private function get_dialogue_object(LANGTYPE:Int):Map<String,Dynamic> {
		var s:String = "";
		var path_prefix:String = "assets/dialogue/";
		#if cpp
		if (load_dialogue_data_from_dev_directory) {
			path_prefix = C.EXT_ASSETS + "dialogue/";
		}
		#end
		
		switch (LANGTYPE) {
			case LANGTYPE_EN:
				path_prefix += "EN.txt";
			case LANGTYPE_JP:
				path_prefix += "JP.txt";
			case LANGTYPE_ZH_SIMP:
				path_prefix += "ZH_SIMP.txt";
			case LANGTYPE_DE:
				path_prefix += "DE.txt";
			case LANGTYPE_RU:
				path_prefix += "RU.txt";
			case LANGTYPE_ES:
				path_prefix += "ES.txt";
			default:
				path_prefix += "EN.txt";
		}
		
		var loaded:Bool = false;
		#if cpp
		loaded = true;
		s = File.getContent(path_prefix);
		#end
		if (!loaded) {
			s = Assets.getText(path_prefix);
		}
		return create_dialogue_hash(s);
	}
	/**
	 * AADDS the dialogue hash stuff in 's' to the hash 'd' if specified, otherwise
	 * just makes a new hash
	 * @param	s
	 * @param	d
	 * @return d, modified if specified
	 */
	private function create_dialogue_hash(s:String,d:Map<String,Dynamic>=null):Map<String,Dynamic> {
		/**
		 * Map -> NPC name -> SCENE name -> "text", "position", "loopstart", "timesplayed"
		 * 
		 * 
		 */
		if (d == null) {
			d = new Map<String,Dynamic> ();
		}
		var lines:Array<String> = s.split("\n");
		
		var mode_map:Int = 0;
		var mode_scene:Int = 2;
		var mode_outer:Int = 3;
		var cur_mode:Int = 3;
		
		var map_hash:Map<String,Dynamic> = null;
		var scene_hash:Map<String,Dynamic> = null;
		var scene_lines:Array<String> = [];
		var parse_pos:Int = 0;
		var script_lines:Array<Array<String>> = [];
		for (i in 0...lines.length) {
			var line:String = StringTools.trim(lines[i]);
			if (line == "" || line.charAt(0) == "#" || line.charAt(0) == "/") {
				continue;
			}
			var words:Array<String> = line.split(" ");
			switch (cur_mode) {
				case _ if (cur_mode == mode_map):
					if (words[0] == "ENDMAP") {
						cur_mode = mode_outer;
					}
					if (words[0] == "SCENE") {
						//Log.trace("\tSCENE " + words[1] + ".");
						if (map_hash.exists(words[1])) {
							Log.trace("WARNING: DUPLICATE SCENE " + words[1]);
						}
						map_hash.set(words[1], new Map<String,Dynamic>());
						scene_hash = map_hash.get(words[1]);
						cur_mode = mode_scene;
						scene_lines = [];
						script_lines = [];
						parse_pos = 0;
					}
				case _ if (cur_mode == mode_scene):
					if (words[0] == "ENDSCENE") {
						cur_mode = mode_map;
						//Log.trace("\t\t" + Std.string(scene_lines));
						scene_hash.set("text", scene_lines);
						scene_hash.set("pos", 0);
						if (!scene_hash.exists("loop")) scene_hash.set("loop", 0);
						scene_hash.set("nr_plays", 0);
						scene_hash.set(SCENEPROP_state_1, 0);
						scene_hash.set(SCENEPROP_state_2, 0);
					} else if (words[0] == "LOOPSTART") {
						scene_hash.set("loop", scene_lines.length);
					} else {
						script_lines = extract_scripts(line); // Get scripts
						var t:Array<String> = script_lines.pop();
						if (t == null) {
							t = [line];
							Log.trace("Mistyped dialogue script: " + line);
							Log.trace(i);
						}
						scene_lines.push(t[0]); // Last element is the text
						if (script_lines.length > 0) { // If any scripts, set them to this elt
							scene_hash.set("script"+Std.string(parse_pos), script_lines);
						}
						parse_pos++;
					}
					
				case _ if (cur_mode == mode_outer):
					if (words[0] == "MAP") {
						//Log.trace("MAP " + words[1] + ".");
						d.set(words[1], new Map<String,Dynamic>());
						map_hash = d.get(words[1]);
						cur_mode = mode_map;
					}
			}
		}
		return d;
	}
	
	/**
	 * Returns the scripts for this line of dialogue
	 * @param	map
	 * @param	scene
	 * @param	pos
	 * @return
	 */
	public function get_scripts(map:String, scene:String, pos:Int=-1):Array<Array<String>> {
		if (check_if_map_and_scene_exist(map.toLowerCase(), scene.toLowerCase())) {
			if (pos == -1) {
				pos = dialogue_object.get(map).get(scene).get("pos");
			}
			if (dialogue_object.get(map).get(scene).exists("script" + Std.string(pos))) {
				return dialogue_object.get(map).get(scene).get("script" + Std.string(pos));
			}
		}
		return [];
	}
	private function extract_scripts(s:String):Array<Array<String>> {
		var inside:Bool = false;
		var scripts:Array<Array<String>> = [];
		var script:Array<String> = [];
		var start:Int = -1;
		var end:Int = -2;
		if (s.charAt(0) == "!" && s.charAt(1) == "i" && s.charAt(2) == " ") {
			scripts.push(["im"]);
		}
		var len:Int = Utf8.length(s);
		//Log.trace(Utf8.charCodeAt("%", 0));
		var yn_exists:Bool = -1 != s.indexOf("%%yn");
		for (i in 0...len) {
			if (yn_exists) {
				for (j in (end + 2)...len - 1) {
					if (j == len - 2) {
						start = -1;
						break;
					}
					if (Utf8.charCodeAt(s, j) == 37 && Utf8.charCodeAt(s, j+1) == 37) { // % 
						start = j;
						break;
					}
				}
			} else {
				start = -1;
				for (j in end + 2...len - 2) {
					if (Utf8.charCodeAt(s, j) == 37 && Utf8.charCodeAt(s, j+1) == 37) { // % 
						start = j;
						break;
					}
				}
				
			}
			if (start == -1) { 
				scripts.push([Utf8.sub(s, end + 2, Utf8.length(s))]);
				//scripts.push([s.substring(end + 2)]);
				return scripts;
			}
			
			if (yn_exists) {
				for (j in (start + 2)...len - 1) {
					if (j == len - 2) {
						end = -1;
						break;
					}
					if (Utf8.charCodeAt(s, j) == 37 && Utf8.charCodeAt(s, j+1) == 37) { // % 
						end = j;
						break;
					}
				}	
			} else {
				end = -1;
				for (j in start + 2...len - 2) {
					if (Utf8.charCodeAt(s, j) == 37 && Utf8.charCodeAt(s, j+1) == 37) { // % 
						end = j;
						break;
					}
				}
			}
			if (end == -1) return scripts;
			script = Utf8.sub(s, start + 2, end - start - 2).split("%");
			scripts.push(script);
			
		}
		return scripts;
	}
	
	public function lookup_scene(map:String, scene:String):Array<String> {
		if (!dialogue_object.exists(map)) {
			Log.trace("No such dialogue map: " + map);
			return null;
		}
		if (!dialogue_object.get(map).exists(scene)) {
			Log.trace("No such scene " + scene + " in map " + map);
			return null;
		}
		return dialogue_object.get(map).get(scene).get("text");
	}
	/**
	 * Gets The current line of dialogue in the scene, and updates its position and if relevant, number of plays
	 * @param	map
	 * @param	scene
	 * @return
	 */
	/**
	 * overrides any dialogue
	 */
	public var in_game_force_dialogue:String = "";
	public function get_dialogue(map:String, scene:String,_pos:Int=-1):Array<String> {
		if (!check_if_map_and_scene_exist(map, scene)) {
			return null;
		}
		var scene_hash:Map<String,Dynamic> = dialogue_object.get(map).get(scene);
		var pos:Int = scene_hash.get("pos");
		if (_pos != -1) pos = _pos;
		var d:String = scene_hash.get("text")[pos];
		// Replace the found dialogue if GNPC sets in_game_force_dialogue
		if (in_game_force_dialogue != "") {
			d = in_game_force_dialogue;
			in_game_force_dialogue = "";
		}
		scene_hash.set("pos", pos + 1);
		
		// Replace any replacement thingies here
		// {NAME|}etc
		d = StringTools.replace(d, "{N0}", Registry.R.PLAYER_NAME);
		d = StringTools.replace(d, "{OB}", Std.string(Registry.R.x_______1__55));
	
		
		d = key_replace(d);
		
		if (d.indexOf("{G") != -1) {
			d = StringTools.replace(d, "{G1_1}", lookup_sentence("ui", "main_areas", Registry.R.event_state[26]));
			d = StringTools.replace(d, "{G1_2}", lookup_sentence("ui", "main_areas", Registry.R.event_state[27]));
			d = StringTools.replace(d, "{G1_3}", lookup_sentence("ui", "main_areas", Registry.R.event_state[28]));
			
			d = StringTools.replace(d, "{G1_L}", lookup_sentence("ui", "main_areas", Registry.R.event_state[32]));
			d = StringTools.replace(d, "{G1_P}", lookup_sentence("ui", "main_areas", Registry.R.event_state[33]));
			
			d = StringTools.replace(d, "{G2_1}", lookup_sentence("ui", "main_areas", Registry.R.event_state[34]));
			d = StringTools.replace(d, "{G2_2}", lookup_sentence("ui", "main_areas", Registry.R.event_state[35]));
			d = StringTools.replace(d, "{G2_3}", lookup_sentence("ui", "main_areas", Registry.R.event_state[36]));
			if (d.indexOf("{G1_2_T}") != -1) {
				//public static inline var g1_2_ID:Int = 27; // either = g1_lopez or g1_paxton 
				//public static inline var g1_lopez_ID:Int = 32; // auto assigned after #1 (Lopez)
				if (Registry.R.event_state[27] == Registry.R.event_state[32]) {
					d = StringTools.replace(d, "{G1_2_T}", lookup_sentence("portrait_names", "names", 24)); // Lopez
				} else {
					d = StringTools.replace(d, "{G1_2_T}", lookup_sentence("portrait_names", "names", 25));
				}
			} else if (d.indexOf("{G1_3_T}") != -1) {
				if (Registry.R.event_state[28] == Registry.R.event_state[32]) {
					d = StringTools.replace(d, "{G1_3_T}", lookup_sentence("portrait_names", "names", 24));
				} else {
					d = StringTools.replace(d, "{G1_3_T}", lookup_sentence("portrait_names", "names", 25));
				}
			} else if (d.indexOf("{G3_GOLEM") != -1) {
				// EF.40 to EF.42 are  IDs of finsihed final areas with values 7,8,9 (pass/cliff/falls)
				if (d.indexOf("_1") != -1) {
					d = StringTools.replace(d, "{G3_GOLEM_1}", lookup_sentence("s3", "golem_names", Registry.R.event_state[40] - 7));
				} else if (d.indexOf("_2") != -1) {
					d = StringTools.replace(d, "{G3_GOLEM_2}", lookup_sentence("s3", "golem_names", Registry.R.event_state[41] - 7));
				} else if (d.indexOf("_3") != -1) {
					d = StringTools.replace(d, "{G3_GOLEM_3}", lookup_sentence("s3", "golem_names", Registry.R.event_state[42] - 7));
				} 
			}
		}
		
		
		// Check if we loop after this
		if (pos + 1 >= scene_hash.get("text").length) {
			pos = scene_hash.get("loop");
			scene_hash.set("pos", pos);
			scene_hash.set("nr_plays", scene_hash.get("nr_plays") + 1);
		}
		return get_chunks(d);
	}
	
	public function get_times_a_scene_is_played(map:String, scene:String):Int {
		if (!check_if_map_and_scene_exist(map, scene)) {
			Log.trace(map + " " + scene + " invalid map/scene");
			return -1;
		}
		return dialogue_object.get(map).get(scene).get("nr_plays");
	}
	
	public function change_scene_state_var(map:String, scene:String, which_one:Int = 0, new_val:Int = 0):Void {
		if (!check_if_map_and_scene_exist(map, scene)) {
			return;
		}
		var s:String;
		if (which_one == 1) {
			s = map + "," + scene + " " + "S1 set to: " + Std.string(new_val);
			dialogue_object.get(map).get(scene).set(SCENEPROP_state_1, new_val);
		} else {
			s = map + "," + scene + " " + "S2 set to: " + Std.string(new_val);
			dialogue_object.get(map).get(scene).set(SCENEPROP_state_2, new_val);
		}
		Log.trace(s);
		Track.add_dialogue_state(s);
	}
	public function get_scene_state_var(map:String, scene:String, which_one:Int):Int {
		if (!check_if_map_and_scene_exist(map, scene)) {
			return -1;
		}
		if (which_one == 1) {
			return dialogue_object.get(map).get(scene).get(SCENEPROP_state_1);
		} else {
			return dialogue_object.get(map).get(scene).get(SCENEPROP_state_2);
		}
		return -1;
	}
	public function change_plays(map:String, scene:String, amt:Int = 1):Void {
		if (!check_if_map_and_scene_exist(map, scene)) {
			return;
		}
		var p:Int = dialogue_object.get(map).get(scene).get("nr_plays");
		dialogue_object.get(map).get(scene).set("nr_plays", p + amt);
		Log.trace("Plays of scene "+map + "-" + scene + " changed " + Std.string(p) +"+" + Std.string(amt));
	}
	/**
	 * Sets the next line of dialogue to be played in this scene
	 * @param	map
	 * @param	scene
	 * @param	next_pos
	 */
	public function set_position(map:String, scene:String, next_pos:Int):Bool {
		if (!check_if_map_and_scene_exist(map, scene)) {
			return false;
		}
		dialogue_object.get(map).get(scene).set("pos", next_pos);
		return true;	
	}
	/**
	 * Breaks up a string into lines that will fit the text box, and by punctuation
	 * @param	dialogue
	 * @return
	 */
	public var FORCE_LINE_SIZE:Int = -1;
	public function get_chunks(dialogue:String):Array<String> {
		
		var MAX_CHARS_PER_LINE:Int = 40;
		if (DialogueBox.MOST_RECENT_CALLED_BOX == null) {
		} else {
			MAX_CHARS_PER_LINE = DialogueBox.MOST_RECENT_CALLED_BOX.MAX_CHARS_PER_LINE;
		}
		if (FORCE_LINE_SIZE > 0) {
			MAX_CHARS_PER_LINE = FORCE_LINE_SIZE;
		}
		var has_brace:Bool = false;
		if (dialogue.indexOf("{") != -1) {
			has_brace = true;
		}

		// The lines that appear in the dialog box. line holds the current line
		var lines:Array<String> = [];
		var line:Utf8 = new Utf8();

		// Split the dialog into lines based on punctuation: [\n!?.] 
		var punc:String = ".!?。";
		var punc_chunks:Array<String> = [];
		var pos:Int;
		var doskip:Bool = false;
		var dialogue_len:Int = Utf8.length(dialogue);
		var dont_extend:Array<Int> = [];
		for (pos in 0...dialogue_len) {
			if (doskip) {
				doskip = false;
				continue;
			}
			line.addChar(Utf8.charCodeAt(dialogue, pos));
			
			// Stop adding to the line when running into a \n
			if (Utf8.charCodeAt(dialogue,pos) == Utf8.charCodeAt("\\",0)) {
				if (pos < dialogue_len - 1) {
					if (Utf8.charCodeAt(dialogue,pos+1) == Utf8.charCodeAt("n",0)) {
						var temp:String = Utf8.sub(line.toString(), 0, Utf8.length(line.toString()) - 1);
						
						line = new Utf8();
						for (i in 0...Utf8.length(temp)) {
							line.addChar(Utf8.charCodeAt(temp, i));
						}
						doskip = true;
						punc_chunks.push(line.toString());
						dont_extend.push(punc_chunks.length - 1);
						line = new Utf8();
					}
				}
			}
			
			var u:Utf8 = new Utf8();
			u.addChar(Utf8.charCodeAt(dialogue, pos));
			if (punc.indexOf(u.toString()) != -1) {
				// Ignore "Mr."
				if (dialogue.charAt(pos - 1) == "r" && dialogue.charAt(pos - 2) == "M") {
					continue;
				}
				if (dialogue_len - 1 > pos) {
					u = new Utf8();
					u.addChar(Utf8.charCodeAt(dialogue, pos + 1));
					var next_char:String = u.toString();
					
					// Don't push this sentence chunk if the next character is in {.!?} , or 
					// if the next character is not whittespace.
					if (punc.indexOf(next_char) != -1 || next_char != " ") { 
						continue; //skips the pushing of current sentence
					// Double space = line break 
					} else if (next_char == " ") {
						doskip = true;
					}
				}
				punc_chunks.push(line.toString());
				line = new Utf8();
			}
		}
		
		if (line.toString() != "") { 
			punc_chunks.push(line.toString());
		}
		
		// Dialog has been broken by punctuation,
		line = new Utf8();
		var cc:Array<String> = []; 
		var chunk:String = "";
		
		/* START OF REALLY BIG FOR LOOP */
		for (i in 0...punc_chunks.length) {
			chunk = punc_chunks[i];

			
			// Up to the continue, this code attempts to combine short PCs.
			// Note if a PC is >= MAX_CHARS_PER_LINE this part doesn't handle that!
			var in_sentence_script_len:Int = 0;
			if (has_brace) {
				in_sentence_script_len = get_len_sum_of_brace_scripts(chunk, 0);
			}
			// If this chunk fits, just push it into the list.
			var chunk_len:Int = Utf8.length(chunk);
			if (chunk_len - in_sentence_script_len <= MAX_CHARS_PER_LINE) {
				//Remove trailing whitespace if not a single character
				var nr_forced_breaks:Int = 0;
				for (pos in 0...Utf8.length(chunk)) {
					if (Utf8.charCodeAt(chunk,pos) == Utf8.charCodeAt("^",0)) {
						nr_forced_breaks++;
					}
				}
				// Prevent bitmap font error w/ empty str
				if (Utf8.charCodeAt(chunk,0) == Utf8.charCodeAt(" ",0) && ( chunk_len - nr_forced_breaks) > 1) {
					chunk = Utf8.sub(chunk, 1, Utf8.length(chunk));
				}
				var prev_chunk:String = lines[lines.length - 1];
				if (lines.length > 0 && Utf8.length(prev_chunk) - get_len_sum_of_brace_scripts(prev_chunk, 0) + chunk_len - in_sentence_script_len < MAX_CHARS_PER_LINE) {
					if (dont_extend.indexOf(i-1) != -1) { // If this punc. chunk had a \n then don't try to extend it
						lines.push(chunk);
					} else {
						lines[lines.length - 1] =  lines[lines.length - 1] + " " + chunk;
					}
				} else {
					lines.push(chunk);
				}
				continue;
			}
			
			
			// Being here means the chunk was bigger than a line. So we need to split it up.
			
			// ASSUME NO BRACE SCRIPTS HAVE SPACES
			cc = chunk.split(" ");
				
			var cur_len:Int = 0;
			var c:String = "";
			var newarray:Array<String> = []; // cc will be set to newarray after this for loop, thus newarray is a 'fixed' version of cc's chunks
			// For each 'word' (delimited by " ") in the chunk...
			// BANANAS APPLE.
			
			var inBrace:Bool = false;
			var braceCount:Int = 0;
			for (j in 0...cc.length) {
				line = new Utf8();
				var chunk_word_too_big:Bool = false;
				braceCount = 0;
				for (i in 0...Utf8.length(cc[j])) {
					
					if (inBrace) {
						braceCount++;
						if (Utf8.charCodeAt("}", 0) == Utf8.charCodeAt(cc[j], i)) {
							inBrace = false;
						}
					}
					if (Utf8.charCodeAt("{", 0) == Utf8.charCodeAt(cc[j], i)) {
						inBrace = true;
						braceCount++;
					}
					// To do: count brace scripts
					if (i >= MAX_CHARS_PER_LINE + braceCount) {
						braceCount = 0;
						newarray.push(line.toString());
						var n_idx:Int = newarray.length -1;
						chunk_word_too_big = true;
						line = new Utf8();
						// Pushes the remainder of the chunk into the next line
						var lineLen:Int = 0;
						for (jj in i...Utf8.length(cc[j])) {
							line.addChar(Utf8.charCodeAt(cc[j], jj));
							lineLen++;
							
							
							if (inBrace) {
								braceCount++;
								if (Utf8.charCodeAt("}", 0) == Utf8.charCodeAt(cc[j], jj)) {
									inBrace = false;
								}
							}
							if (Utf8.charCodeAt("{", 0) == Utf8.charCodeAt(cc[j], jj)) {
								inBrace = true;
								braceCount++;
							}
							
							// Add this snippet to ensure if a chunk is super big it breaks up
							// into multiple lines
							if (lineLen >= MAX_CHARS_PER_LINE + braceCount) {
								braceCount = 0;
								newarray.push(line.toString());
								lineLen = 0;
								line = new Utf8();
							}
						}
						if (lineLen > 0) {
							newarray.push(line.toString());
							braceCount = 0;
						}
					}
					if (chunk_word_too_big) {
						break;
					}
					line.addChar(Utf8.charCodeAt(cc[j], i));
				}
				if (!chunk_word_too_big) {
					newarray.push(cc[j]);
				}
			}
			
			/* **************** */
			// APPLE / BANANA
			// Because the above code doesn't account for brace scripts,
			// This code will do so and combine any lines as needed.
			cc = newarray;
			line = new Utf8();
			for (jj in 0...Utf8.length(cc[0])) {
				line.addChar(Utf8.charCodeAt(cc[0], jj));
			}
			for (i in 1...cc.length) { 
				c = cc[i];
				//make a new line if the current word doesnt fit
				
				var lensum:Int = 0;
				if (has_brace) {
					lensum = get_len_sum_of_brace_scripts(line.toString() + c);
				}
				if (Utf8.length(line.toString()) + Utf8.length(c) + 1 - lensum > MAX_CHARS_PER_LINE) {
					lines.push(line.toString());
					line = new Utf8();
					for (j in 0...Utf8.length(c)) {
						line.addChar(Utf8.charCodeAt(c, j));
					}
				} else {
					
					// Is this whitespace a problem in chinese etc?
					if (Utf8.length(line.toString()) > 0) {
						line.addChar(Utf8.charCodeAt(" ", 0));
					}
				
					for (j in 0...Utf8.length(c)) {
						line.addChar(Utf8.charCodeAt(c, j));
					}
				}
			}
			lines.push(line.toString());
			line = new Utf8();
		} 
		/* END OF REALLY BIG FOR LOOP */
		return lines;
	}	
	
	public function get_len_sum_of_brace_scripts(s:String, start:Int=0):Int {
		var in_sentence_script_len:Int = 0;
		// hard limit on # of scripts
		//Log.trace([s, start]);
		var start_idx:Int = start;
		for (j in 0...10) {
			// give [start idx,string]
			// return [len,end idx,script body]
			// if len = -1 none left, or error in script;
			var a:Array<Dynamic> = get_brace_script(s,start_idx);
			if (a[0] == 0) {
				break;
			} else {
				in_sentence_script_len += Std.int(a[0]);
				start_idx = Std.int(a[1]);
				//Log.trace(a);
			}
		}
		return in_sentence_script_len;
	}
	
	public function get_brace_script(s:String, start:Int):Array<Dynamic> {
		var retval:Array<Dynamic> = [0,0,""];
		// len, next start, str
		/* Note: this maybe gets called too much */
		var notfound:Bool = true;
		var found_close_bracket:Bool = false;
		var len:Int = 0;
		for (i in start...Utf8.length(s)) {
			if (notfound) {
				if (Utf8.charCodeAt(s, i) == Utf8.charCodeAt("{", 0)) {
					notfound = false;
					len++;
				}
			} else {
				len++;
				
				if (Utf8.charCodeAt(s, i) == Utf8.charCodeAt("}", 0)) {
					found_close_bracket = true;
				}
				
				if (found_close_bracket) {
					retval[0] = len;
					retval[1] = i;
					retval[2] = Utf8.sub(s, i - len + 1 + 1, len-2);
					break;
				}
			}
		}
		return retval;
	}
	// Generates a state stirng for saving from the in memory dialogue object
	public function getStateString():String {
		var s:String = "";
		var map:String = "";
		var scene:String = "";
		var map_hash:Map<String,Dynamic> = null;
		var scene_hash:Map<String,Dynamic> = null;
		for (map in dialogue_object.keys()) {
			// For each map, write out a listing of scenes and associate stated variables
			s += "MAP " + map + "\n";
			map_hash = dialogue_object.get(map);
			for (scene in map_hash.keys()) {
				scene_hash = map_hash.get(scene);
				s += scene + " " +  Std.string(scene_hash.get("pos")) + " " + Std.string(scene_hash.get("nr_plays")) + " " + Std.string(scene_hash.get(SCENEPROP_state_1)) + " " + Std.string(scene_hash.get(SCENEPROP_state_2)) + "\n";
			}
			s += "ENDMAP\n";
		}
		return s;
	}
	
	// takes the dialogue state saved to this file
	// And updates the positions/nr of plays of each scene in memory
	private function updateDialogueHashWithSaveStateString(_d:Map<String,Dynamic>):Void {
		if (load_dialogue_data_from_dev_directory) {
			//Log.trace("Not updating dialogue state with current save string, should only see this with SHIFT+L in Editor Add mode.");
			return;
		} else {
			//Log.trace("Updating dialogue state");
		}
		var s:String = save_state_string;
		var line:String = "";
		var state:Int = 0;
		var words:Array<String> = [];
		
		var map_name:String = "";
		var scene_name:String = "";
		
		for (line in s.split("\n")) {
			words = line.split(" ");
			switch (state) {
				case 0:
					if (words[0] == "MAP") {
						state = 1;
						map_name = words[1];
					}
				case 1:
					if (words[0] == "ENDMAP") {
						state = 0;
					} else {
						scene_name = words[0];
						// then: pos, nr_plays
						if (_d.exists(map_name) && _d.get(map_name).exists(scene_name)) {
							_d.get(map_name).get(scene_name).set(SCENEPROP_POS, Std.parseInt(words[1]));
							_d.get(map_name).get(scene_name).set(SCENEPROP_NR_PLAYS, Std.parseInt(words[2]));
							_d.get(map_name).get(scene_name).set(SCENEPROP_state_1, Std.parseInt(words[3]));
							_d.get(map_name).get(scene_name).set(SCENEPROP_state_2, Std.parseInt(words[4]));
						}
						
					}
			}
		}
	}
	
	private function check_if_map_and_scene_exist(map:String,scene:String):Bool 
	{
		if (!dialogue_object.exists(map)) {
			Log.trace("No such dialogue map: " + map);
			return false;
		}
		if (!dialogue_object.get(map).exists(scene)) {
			Log.trace("No such scene " + scene + " in map " + map);
			return false;
		}
		return true;
	}
	
	public static function justify(s:String,max_len:Int):String {
		var out_str:String = "";
		var parts:Array<String> = s.split(" ");
		var cur_len:Int = 0;
		var i:Int = 0;
		while (true) {
		//for (i in 0...parts.length) {
			
			var part_len:Int = Utf8.length(parts[i]);
			var nl:Bool = false;
			if (Utf8.charCodeAt(parts[i], part_len - 1) == 10) {
				nl = true;
			}
			if (cur_len + part_len > max_len || nl) {
				if (part_len > max_len) {
					var newpart:String = Utf8.sub(parts[i], max_len,part_len - max_len);
					parts[i] = Utf8.sub(parts[i], 0, max_len);
					parts.insert(i + 1, newpart);
					part_len = Utf8.length(parts[i]);
				}
				// if not at beginning at line add newline
				if (cur_len != 0) {
					out_str += "\n";
				}
				cur_len = part_len + 1;
				
				// in every case add the nwe part
				if (nl) {
					out_str += parts[i];
				} else {
					out_str += parts[i] + " ";
				}
			} else {
				cur_len += part_len + 1;
				out_str += parts[i] + " ";
			}
			i++;
			if (i == parts.length) {
				break;
			}
		}
		return out_str;
	}
	
	//public function get_scene_length(m:String, s:String):Int {
		//if (check_if_map_and_scene_exist(m, s)) {
			//return dialogue_object.get(m).get(s).get("text").length;
		//}
	//}
}