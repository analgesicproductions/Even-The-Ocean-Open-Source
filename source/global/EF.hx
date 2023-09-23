package global;
import haxe.Log;
import help.Track;

/**
 * Event states
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class EF
{

	public static inline var number_of_event_flags:Int = 70;
	
	public static inline var test1:Int = 0;
	public static inline var even_world_test:Int = 1;
	public static inline var test2:Int = 3;	
	public static inline var played_intro_wakeup:Int = 4;
	public static inline var played_intro_earthquake:Int = 5;
	public static inline var player_intro_cave:Int = 6;
	public static inline var woods_core_left:Int = 7;
	public static inline var woods_core_right:Int = 8;
	public static inline var shore_done:Int = 9;
	//public static inline var nr_starfish_cleared:Int = 10; deprecated
	public static inline var bitwise_starfish_clearage_state:Int = 11;
	public static inline var canyon_done:Int = 12;
	public static inline var hill_done:Int = 13;
	public static inline var woods_done:Int = 14;
	public static inline var river_done:Int = 15;
	public static inline var forest_done:Int = 16;
	public static inline var earth_done:Int = 17;
	public static inline var air_done:Int = 18;
	public static inline var sea_done:Int = 19;
	public static inline var river_gave_meds_to_fungus:Int = 20;
	public static inline var river_left_storage_open:Int = 21;
	public static inline var THE_OCEAN_FINISHED:Int = 22;
	public static inline var INTRO_console_scene_done:Int = 23;
	public static inline var INTRO_plantblock_tut_done:Int = 24;
	public static inline var INTRO_savepoint_tut_done:Int = 25;
	// Order of gauntlets visited: 1 =  shoer, 2= anyon, 3= hill
	// Lopez at Shore, Paxton at Canyon, or , alternatively at Hill.
	public static inline var g1_1_ID:Int = 26;
	public static inline var g1_2_ID:Int = 27; // either = g1_lopez or g1_paxton 
	public static inline var g1_3_ID:Int = 28; // either = g1_lopez or g1_paxton 
	public static inline var g1_1_DONE:Int = 29;
	public static inline var g1_2_DONE:Int = 30;
	public static inline var g1_3_DONE:Int = 31;
	public static inline var g1_lopez_ID:Int = 32; // auto assigned after #1 (Lopez)
	public static inline var g1_paxton_ID:Int = 33; // auto assigned after g1_1 picked
	
	public static inline var ID_SHORE:Int = 1;
	public static inline var ID_CANYON:Int = 2;
	public static inline var ID_HILL:Int = 3;
	
	public static inline var g2_1_ID:Int = 34;
	public static inline var g2_2_ID:Int = 35;
	public static inline var g2_3_ID:Int = 36;
	public static inline var g2_1_DONE:Int = 37;
	public static inline var g2_2_DONE:Int = 38;
	public static inline var g2_3_DONE:Int = 39;
	
	public static inline var ID_RIVER:Int = 4;
	public static inline var ID_WOODS:Int = 5;
	public static inline var ID_FOREST:Int = 6;
	
	public static inline var g3_1_ID:Int = 40; // has 7 through 9 - PASS / CLIFF / FALLS
	public static inline var g3_2_ID:Int = 41;
	public static inline var g3_3_ID:Int = 42;
	public static inline var g3_1_DONE:Int = 43;
	public static inline var g3_2_DONE:Int = 44;
	public static inline var g3_3_DONE:Int = 45;
	
	public static inline var ID_PASS:Int = 7;
	public static inline var ID_CLIFF:Int = 8;
	public static inline var ID_FALLS:Int = 9;

	
	public static inline var pass_geysers:Int = 46;
	public static inline var radio_tower_done:Int = 47;
	public static inline var radio_depths_done:Int = 48;
	
	public static inline var area_enter_states:Int = 49; // bitwise fr the 9 areas
	
	public static inline var credits_watched:Int = 50; // for activating ending stuff
	
	// END FLAGS
	public static function set_flag(index:Int, array:Array<Int>, value:Dynamic,silent:Bool=false):Void {
		
		var old:Int = array[index];
		if (value == true) {
			array[index] = 1;
		} else if (value == false) {
			array[index] = 0;
		} else {
			array[index] = value;
		}
		if (!silent) {
			Track.add_event_flag(index, old, array[index]);
		}
		
		if (Registry.R.dialogue_manager != null) {
			if (!silent) Log.trace("Event flag " + Std.string(index) + "[" + Registry.R.dialogue_manager.lookup_sentence("ui", "event_labels", index) + "] was set to " + Std.string(array[index]));
		}
	}
	
}