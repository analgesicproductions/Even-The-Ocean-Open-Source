package help;
import global.Registry;
import haxe.Log;

/**
 * EventHelper - sets event states in the game
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class EventHelper
{
	private static var R:Registry;
	
	public static function init():Void {
		R = Registry.R;
	}
	
	
	public static function set_ss(map:String, scene:String, pos:Int, val:Int):Void {
		R.dialogue_manager.change_scene_state_var(map, scene, pos, val);
	}
	public static function set_event(id:Int, value:Int):Void {
		R.set_flag(id, value);
	}
	
	
	// done
	/* High level finishing functions */
	public static function finish_game():Void {
		finish_introAll();
		finish_s1();
		finish_i1();
		finish_s2();
		finish_i2();
		finish_s3();
		finish_endingAll();
	}
	
	// done
	public static function finish_introAll():Void {
		finish_rouge();
		finish_intro();
	}
	
	
	// done
	public static function finish_s1():Void {
		
		finish_shore(1);
		finish_debrief_g1_1();
		finish_canyon(2);
		finish_debrief_g1_2();
		finish_hill(3);
	}
	
	
	// done
	public static function finish_s2():Void {
		finish_river(1);
		finish_debrief_g2_1();
		finish_woods(2);
		finish_debrief_g2_2();
		finish_basin(3);
		
	}
	
	
	/* Area or intermission finshing */
	// Done
	public static function finish_rouge():Void {
		Log.trace("Finish rouge");
		
		set_ss("intro", "message", 1, 1);
		set_ss("intro", "pad", 1, 1);
		set_ss("intro", "thunder", 1, 2);
		set_ss("intro", "earthquake", 1, 1);
		set_event(6, 1);
		set_ss("intro", "cave", 1, 3);
		set_ss("intro", "exit_cave", 1, 1);
		set_ss("intro", "control_room_enter", 1, 1);
		set_ss("city", "aliph_map", 1, 1);
		set_ss("intro", "map", 1, 1);
		set_event(23, 1);
		
		//Log.trace("debuggg");
		//finish_intro();
	}
	
	
	// Done
	public static function finish_intro():Void {
		set_ss("city", "aliph_fades", 1, 1);
		set_ss("city", "funeral_speech", 1, 1);
		set_ss("city", "funeral_casket", 1, 1);
		set_ss("city", "mayor_intro", 1, 1);
		set_ss("city", "city_aliph_after_mayor_intro", 1, 1);
		//R.inventory.set_item_found(0, 8, true); // Pamphlet
		set_ss("city", "wf_j_intro", 1, 1);
		set_ss("city", "intro_aliph_home", 1, 1);
		set_ss("city", "intro_aliph_home", 2, 2);
		set_ss("city", "intro_armor", 1, 1);
		set_ss("city", "intro_yara", 1, 1);
		set_ss("city", "map_tut", 1, 1);
		R.inventory.set_item_found(0, 18, true); // world map 
		
		Log.trace("Finish intro");
	}
	
	/* 
	 * public static inline var g1_lopez_ID:Int = 32; // auto assigned after #1 (Lopez)
	public static inline var g1_paxton_ID:Int = 33; // auto assigned after g1_1 picked
	 9 12 13 = shore canyon hill
	 29 30 31 = first set DONE
	 26 27 28 = first set IDs
	 Item 45 gotten in 2nd place - the tissue sample
	 */
	
	
	
	// done
	public static function g1_1_help(gauntletidx:Int):Void {
		set_event(29, 1);
		set_event(26, gauntletidx); 
		set_ss("nature", "g1_1_call_mayor", 1, 1);
		set_ss("nature", "g1_1_pile", 1, 1);
	}
	// done
	public static function g1_2_help(gauntletidx:Int):Void {
		set_event(30, 1); 
		set_event(27, gauntletidx); 
		R.inventory.set_item_found(0, 45, true); // tissue sample
		set_ss("nature_g1_2", "checkin", 1, 1);
		set_ss("nature_g1_2", "g1_2_pile", 1, 1);
		if (R.event_state[32] == gauntletidx) set_ss("nature_g1_2", "lopez", 1, 2);
		if (R.event_state[33] == gauntletidx) set_ss("nature_g1_2", "paxton_1", 1, 2);
		
		/* Simulate setting the 3rd ID in the checkin cutscene*/
		if (gauntletidx == 1) {
		if (R.event_state[26] == 2) set_event(28, 3); 
		if (R.event_state[26] == 3) set_event(28, 2); }
		if (gauntletidx == 2) {
		if (R.event_state[26] == 3) set_event(28, 1); 
		if (R.event_state[26] == 1) set_event(28, 3); }
		if (gauntletidx == 3) {
		if (R.event_state[26] == 1) set_event(28, 2); 
		if (R.event_state[26] == 2) set_event(28, 1); }
	}
	
	// done
	public static function g1_3_help(gauntletidx:Int):Void {
		set_event(31, 1);
		if (R.event_state[32] == gauntletidx) set_ss("nature_g1_2", "lopez", 1, 2);
		if (R.event_state[33] == gauntletidx) set_ss("nature_g1_2", "paxton_1", 1, 2);
		
	}
	
	// done
	public static function finish_shore(idx:Int):Void {
		set_event(9, 1);
		if (idx == 1) {  set_event(32, 3); set_event(33, 2); g1_1_help(1); }
		if (idx == 2) { g1_2_help(1); }
		if (idx == 3) { g1_3_help(1); }
		set_ss("city", "dm1shore", 1, 1);
		
		R.set_flag_bitwise(49, 1 << 1); // Enter area 
		set_ss("shore", "fisher_1", 1, 1);
		set_ss("shore", "starfish_center", 1, 1);
		R.inventory.set_item_found(0, 10, true); // clariseed
		// dnt worry bt other npcs or starfish
		
		Log.trace("Finish shore");
	}

	// Done
	public static function finish_canyon(idx:Int):Void {
		
		set_event(12, 1);
		if (idx == 1) { set_event(32, 1); set_event(33, 3); g1_1_help(2); }
		if (idx == 2) { g1_2_help(2);  }
		if (idx == 3) { g1_3_help(2); }
		
		set_ss("city", "dm1canyon", 1, 1); // world map opened
		set_ss("canyon", "moonderful_first", 1, 1); 
		set_ss("canyon", "moonderful_second", 1, 1); 
		set_ss("canyon", "marble", 1, 1); 
		set_ss("canyon", "didney", 1, 1); 
		set_ss("canyon", "aliph_alone", 1, 1);  //	broken wire thing
		set_ss("canyon", "aliph_alone", 2, 1); // bridge 
		
		
		
		R.inventory.set_item_found(0, 12, true);
		R.set_flag_bitwise(49, 1 << 2); // Enter area 
		
		Log.trace("Finish canyon");
	}

	// done
	public static function finish_hill(idx:Int):Void {
		set_event(13, 1);
		if (idx == 1) {  set_event(32, 1); set_event(33, 2); g1_1_help(3);}
		if (idx == 2) { g1_2_help(3); }
		if (idx == 3) { g1_3_help(3); }
		set_ss("city", "dm1hill", 1, 1);
		set_ss("hill", "wilbert", 1, 1);
		set_ss("hill", "room_bay", 1, 1);
		set_ss("hill", "bay_in_vera_room", 1, 1);
		set_ss("hill", "room_vera_after_bay", 1, 1);
		set_ss("hill", "soup_memory", 1, 2);
		set_ss("hill", "bay_outside", 1, 1);
		set_ss("hill", "paint_memory", 1, 1);
		set_ss("hill", "trent_outside", 1, 1);
		set_ss("hill", "storeroom_outside", 1, 1);
		set_ss("hill", "storeroom_inside", 1, 1);
		set_ss("hill", "storeroom_talked", 1, 1);
		set_ss("hill", "storeroom_vera", 1, 1);
		R.inventory.set_item_found(0, 49, true); // vera key
		R.set_flag_bitwise(49, 1 << 3); // Enter area 
		Log.trace("Finish hill");
	}
	
	// done
	public static function finish_debrief_g1_1():Void {
		set_ss("city_i1", "debrief", 1, 1);
		set_ss("city_i1", "yara", 1, 1);
		set_ss("city_i1", "after_yara_1", 1, 1);
		set_ss("city", "lib_talk_g1_1_first", 1, 1);
		set_ss("city", "map_paxlop", 1, 1);
		Log.trace("Finish g1_1 deb");
	}
	
	// done
	public static function finish_debrief_g1_2():Void {
		set_ss("city_g1_2", "debrief", 1, 1);
		set_ss("city_g1_2", "yara", 1, 1);
		Log.trace("Finish g1_2 deb");
	}
	
	// done
	public static function finish_i1():Void {
		set_ss("i_1", "debrief", 1, 1);
		set_ss("i_1", "humus", 1, 1);
		set_ss("i_1", "only_humus", 1, 1);
		set_ss("i_1", "humus", 2, 1);
		set_ss("i_1", "yara", 1, 1);
		set_ss("i_1", "aliph_home_i1", 1, 1);
		set_ss("i_1", "gate_exit", 1, 1);
		R.inventory.set_item_found(0, 50, true); // world map 2
		Log.trace("Finish i1");
	}
	
	// ddone
	public static function finish_g2_1(idx:Int):Void {
		set_event(37, 1);
		set_event(34, idx);
		R.inventory.set_item_found(0, 48, true); // kv map
		set_ss("g2_1", "checkin", 1, 1);
		set_ss("g2_1", "paxton", 1, 1);
	}
	// done
	public static function finish_g2_2(idx:Int):Void {
		set_event(38, 1);
		set_event(35, idx);
		set_ss("g2_2", "checkin", 1, 1);
	}
	// done
	public static function finish_g2_3(idx:Int):Void {
		set_event(39, 1);
		set_event(36, idx);
		set_ss("g2_3", "checkin", 1, 1);
	}
	// done
	public static function finish_river(idx:Int):Void {
		// 34 35 36 - g2 IDs
		// 37 38 39 - g2 DONE
		// 14 15 16 WOODS, River, Basin
		set_event(15, 1);
		if (idx == 1) { finish_g2_1(4);  }
		if (idx == 2) { finish_g2_2(4); }
		if (idx == 3) { finish_g2_3(4); }
		
		
		R.set_flag_bitwise(49, 1 << 4); // Enter area 
		set_ss("city", "dm1river", 1, 1);
		set_ss("river", "jr_1", 1, 1);
		set_ss("river", "post_office", 1, 1);
		set_ss("river", "jr_2", 1, 1);
		
		Log.trace("Finish river");
	}
	
	// done
	public static function finish_woods(idx:Int):Void {
		set_event(14, 1);
		if (idx == 1) { finish_g2_1(5);  }
		if (idx == 2) { finish_g2_2(5); }
		if (idx == 3) { finish_g2_3(5); }
		set_ss("city", "dm1woods", 1, 1);
		set_ss("woods", "wes", 1, 1);
		R.set_flag_bitwise(49, 1 << 5);
		Log.trace("Finish woods");
	}
	
	// mostly done minus the last dolly lift thing
	public static function finish_basin(idx:Int):Void {
		set_event(16, 1);
		if (idx == 1) { finish_g2_1(6);  }
		if (idx == 2) { finish_g2_2(6); }
		if (idx == 3) { finish_g2_3(6); }
		set_ss("city", "dm1basin", 1, 1);
		
		set_ss("forest", "dolly_gate", 1, 1);
		set_ss("forest", "enter_town", 1, 1);
		set_ss("forest", "aliph_lift", 1, 1);
		set_ss("forest", "vale_3", 1, 1);
		set_ss("forest", "tracy", 1, 1);
		R.set_flag_bitwise(49, 1 << 6);
		R.inventory.set_item_found(0, 47, true);
		
		Log.trace("Finish basin");
	}
	
	// done
	public static function finish_debrief_g2_1():Void {
		
		set_ss("g2_1", "debrief", 1, 1);
		set_ss("g2_1", "hi_res", 1, 1);
		set_ss("g2_1", "aliph_apt", 1, 1);
		set_ss("g2_1", "yara", 1, 2);
		Log.trace("Finish g2_1 deb");
	}
	// done
	public static function finish_debrief_g2_2():Void {
		
		set_ss("g2_2", "debrief", 1, 1);
		set_ss("g2_2", "bed", 1, 1);
		Log.trace("Finish g2_2 deb");
	}
	
	
	// done
	public static function finish_i2():Void {
			
		set_ss("i2", "cart_init", 1, 1);
		set_ss("i2", "mayor_init", 1, 1);
		set_ss("i2", "core_enter", 1, 2);
		set_event(48, 1); // radio depths
		
		R.inventory.set_item_found(0, 26, true); // kv map
		set_ss("i2", "crowd_hastings", 1, 1);
		set_ss("i2", "mayor_sad", 1, 1);
		
		set_ss("i2", "aliph_out", 1, 1);
		set_ss("i2", "crowd", 1, 1);
		set_ss("i2", "humus_jail", 1, 1);
		set_ss("i2", "yara", 1, 1);
		
		set_ss("s3", "post_i2_map", 1, 1);
		
		set_ss("s3", "tunnel_block", 1, 1);
		set_ss("s3", "map1_tunnel_vis", 1, 1);
		set_ss("s3", "tunnel_kvside", 1, 1);
		set_ss("s3", "tower_view", 1, 1);
		set_ss("s3", "kv_maps", 1, 1);
		set_ss("s3", "kv_console", 1, 1);
		set_ss("s3", "kv_contact_wf", 1, 1);
		set_ss("s3", "kv_gotmaps_wf", 1, 1);
		set_ss("s3", "first_sleep", 1, 1);
		R.inventory.set_item_found(0, 19, true);
		R.inventory.set_item_found(0, 20, true);
		R.inventory.set_item_found(0, 21, true);
		R.inventory.set_item_found(0, 51, true);
		R.inventory.set_item_found(0, 52, true);
		Log.trace("Finish i2");
	}
	
	// done
	public static function finish_s3():Void {
		finish_silo_earth();
		finish_silo_air();
		finish_silo_sea();
		finish_pass(1);
		finish_debrief_g3_1();
		finish_cliff(2);
		finish_debrief_g3_2();
		finish_falls(3);
	}
	
	
	// done
	public static function finish_silo_sea():Void {
		R.inventory.set_item_found(0, 25, true);
		set_ss("s3", "sea_silo_vis", 1, 1);
		Log.trace("Finish silo sea");
	}
	
	// done
	public static function finish_silo_earth():Void {
		R.inventory.set_item_found(0, 23, true);
		set_ss("s3", "earth_silo_vis", 1, 1);
		Log.trace("Finish silo earth");
	}
	// done
	public static function finish_silo_air():Void {
		R.inventory.set_item_found(0, 24, true);
		set_ss("s3", "air_silo_vis", 1, 1);
		Log.trace("Finish silo air");
	}
	// done
	public static function finish_pass(idx:Int):Void {
		// 40 41 42  G3 ID
		// 43 44 45 g3 DONE
		// 789 = pass cliff falls (IDs)
		// 17 18 19 = earth air sea done
		set_event(17, 1);
		if (idx == 1) { set_event(43, 1); set_event(40, 7); }
		if (idx == 2) { set_event(44, 1); set_event(41, 7); set_ss("s3", "s3_g2", 1, 1); }
		if (idx == 3) { set_event(45, 1); set_event(42, 7); set_ss("s3", "s3_g3", 1, 1); }
		
		R.inventory.set_item_found(0, 22, true); // crowbar
		R.inventory.set_item_found(0, 46, true); // datacard
		set_event(46, 0x111); // boulders
		set_ss("pass", "boulder", 1, 1);
		set_ss("pass", "jane_init", 1, 1);
		set_ss("s3", "s3_boss_enter", 1, 1);
		R.set_flag_bitwise(49, 1 << 7);
		
		
		Log.trace("Finish pass");
	}
	
	// done
	public static function finish_cliff(idx:Int):Void {
		set_event(18, 1);
		if (idx == 1) { set_event(43, 1); set_event(40, 8); }
		if (idx == 2) { set_event(44, 1); set_event(41, 8); set_ss("s3", "s3_g2", 1, 1);  }
		if (idx == 3) { set_event(45, 1); set_event(42, 8); set_ss("s3", "s3_g3", 1, 1); }
		
		
		//R.inventory.set_item_found(0, 27, true); // perfume
		set_ss("cliff", "cliff_scene", 1, 1);
		set_ss("cliff", "last_sign", 1, 1);
		set_ss("cliff", "dying_person_init", 1, 1);
		set_ss("cliff", "incense", 1, 1);
		set_ss("cliff", "signs", 1, 255); // 8 signs
		set_ss("cliff", "aliph_alone", 1, 1);  // entrance 
		set_ss("cliff", "aliph_alone", 2, 1);  // cactus bottom
		
		
		
		R.set_flag_bitwise(49, 1 << 8);
		set_ss("s3", "s3_boss_enter", 1, 1);
		Log.trace("Finish cliff");
	}
	
	// done
	public static function finish_falls(idx:Int):Void {
		set_event(19, 1);
		if (idx == 1) { set_event(43, 1); set_event(40, 9); }
		if (idx == 2) { set_event(44, 1); set_event(41, 9); set_ss("s3", "s3_g2", 1, 1); }
		if (idx == 3) { set_event(45, 1); set_event(42, 9); set_ss("s3", "s3_g3", 1, 1); }
		
		set_ss("falls", "npc", 1,0x1111);
		set_ss("falls", "npc", 2,0x1111);
		set_ss("falls", "falls_state", 2,1);
		set_ss("falls", "sharon", 1,1);
		set_ss("falls", "falls_state", 1,1);
		
		R.set_flag_bitwise(49, 1 << 9);
		set_ss("s3", "s3_boss_enter", 1, 1);
		Log.trace("Finish falls");
	}
	
	// done
	public static function finish_debrief_g3_1():Void {
		
		set_ss("s3", "yara", 1, 1);
		set_ss("s3", "debrief", 1, 1);
		Log.trace("Finish deb g3_1");
	}
	
	// done
	public static function finish_debrief_g3_2():Void {
		
		set_ss("s3", "yara_2", 1, 1);
		set_ss("s3", "debrief_2", 1, 1);
		Log.trace("Finish deb g3_2");
	}
	
	// done
	public static function finish_endingAll():Void {
		finish_debrief_g3_3();
		finish_radio();
		finish_ending();
	}
	// done
	public static function finish_debrief_g3_3():Void {
		set_ss("s3", "last_debrief", 1, 1);
		set_ss("ending", "outside_wf", 1, 1);
		Log.trace("Finish deb g3_3");
	}
	
	// done
	public static function finish_radio():Void {
		set_ss("ending", "city_enter", 1, 1);
		set_ss("ending", "mayor", 1, 1);
		
		set_event(47, 1);
		set_ss("ending","radio_end",1,1);
		Log.trace("Finish radio");
	}
	// done?
	public static function finish_ending():Void {
		
		R.inventory.set_item_found(0, 30, true); //postgame debug reader
		set_ss("ending","init_yara",1,1);
		set_ss("ending","flood",1,1);
		set_ss("ending", "final", 1, 1);
		set_event(50, 1);
		Log.trace("Finish ending");
	}
	
}