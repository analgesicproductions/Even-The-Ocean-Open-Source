package help;
import state.TestState;


class InitShortcut 
{
	
	public static function map1(ts:TestState):Void {
		ts.MAP_NAME = "MAP1";
		ts.next_world_mode = TestState.WORLD_MODE_MAP;
	}
	public static function map2(ts:TestState):Void {
		ts.MAP_NAME = "MAP2";
		ts.next_world_mode = TestState.WORLD_MODE_MAP;
	}

	public static function npcriver2(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_REAL;
		ts.MAP_NAME = "NPC_RIVER";
		ts.next_player_x = 600;
		ts.next_player_y = 534;
	}
	public static function npccity(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_REAL;
		ts.MAP_NAME = "NPC_CITY";
		ts.next_player_x = 0;
		ts.next_player_y = 0;
	}
	public static function rouge1(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_REAL;
		ts.MAP_NAME = "ROUGE_1";
		ts.next_player_x = 500;
		ts.next_player_y = 500;
	}
	public static function intro_bridge(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_REAL;
		ts.MAP_NAME = "INTRO";
		ts.next_player_x = 1234;
		ts.next_player_y = 250;
	}

	public static function test_rivertest(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_REAL;
		ts.MAP_NAME = "RIVERTEST";
		ts.next_player_x = 128;
		ts.next_player_y = 1064;
	}

	public static function test_earth_silo_1(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_REAL;
		ts.MAP_NAME = "EARTH_SILO_1";
	}
	public static function test_demo_1_1(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "DEMO_1_1";
	}
	public static function basin1(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "BASIN_1";
	}
	public static function npcpass(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "NPC_PASS";
	}
	public static function npchill(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "NPC_HILL";
	}
	public static function npcforest(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "NPC_FOREST";
		ts.next_player_x = 208;
		ts.next_player_y = 425;
	}
	public static function npcriver(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "NPC_RIVER";
		ts.next_player_x = 138;
		ts.next_player_y = 0;
	}
	public static function test3(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "TEST3";
	}
	public static function NPC_SHORE(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "NPC_SHORE";
	}
	public static function motiondemo1(ts:TestState):Void {
		ts.MAP_NAME = "MOTION_DEMO_1";
		ts.next_player_x = 692;
		ts.next_player_y = 582;
	}
		public static function twitch(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "TWITCH";
	}
		
	public static function test_river_g1_1(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "RIVER_G1_1";
		ts.next_player_x = 50;
		ts.next_player_y = 50;
	}				
	public static function test_river_g1_5(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "RIVER_G1_5";
		ts.next_player_x = 345;
		ts.next_player_y = 1500;
	}				
	public static function test_river_g1_2(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "RIVER_G1_2";
		ts.next_player_x = 50;
		ts.next_player_y = 50;
	}			
	public static function test_river_r(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "RIVER_R";
		ts.next_player_x = 880;
		ts.next_player_y = 860;
	}		
	public static function test_mle(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "TESTTWO";
		ts.next_player_x = 880;
		ts.next_player_y = 860;
	}		
	public static function river_g1_1(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "RIVER_G1_1";
		ts.next_player_x = 400;
		ts.next_player_y = 300;
	}
	public static function testtwo_right(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "TESTTWO";
		ts.next_player_x = 700;
		ts.next_player_y = 300;
	}
	
	public static function woods_courtyard(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "WOODS_COURTYARD";
		ts.next_player_x = 138;
		ts.next_player_y = 50;
	}

	public static function woods_up2(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "WOODS_UP2";
		ts.next_player_x = 138;
		ts.next_player_y = 50;
	}
	
	public static function woods_top(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "WOODS_TOP";
		ts.next_player_x = 138;
		ts.next_player_y = 50;
	}
	
	
		public static function woods_g1_2(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "WOODS_G1_2";
		ts.next_player_x = 138;
		ts.next_player_y = 50;
	}
	
	public static function riverpass(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "RIVERPASS";
		ts.next_player_x = 1397;
		ts.next_player_y = 387;
	}
	
	public static function woods_g1_1(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "WOODS_G1_1";
		ts.next_player_x = 138;
		ts.next_player_y = 50;
	}
	
	public static function woods_enter(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "WOODS_ENTER";
		ts.next_player_x = 138;
		ts.next_player_y = 668;
	}
	
	
	public static function greenhouse(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "GREENHOUSE1";
		ts.next_player_x = 450;
		ts.next_player_y = 630;
	}
	
	public static function testtwo_bubble(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "TESTTWO";
		ts.next_player_x = 448;
		ts.next_player_y = 52;
	}
	public static function Shoreplace_end(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "SHOREPLACE_END";
		ts.next_player_x = 300;
		ts.next_player_y = 40;
	}
	public static function Shoreplace_Down(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "SHOREPLACE_DOWN";
		ts.next_player_x = 30;
		ts.next_player_y = 40;
	}
	public static function Shoreplace_Tunnel(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "SHOREPLACE_TUNNEL";
		ts.next_player_x = 430;
		ts.next_player_y = 280;
	}
	public static function SET_INTRO(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "INTRO";
		ts.next_player_x = 50;
		ts.next_player_y = 50;
	}
	
	public static function SET_MELOSLET(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "INTRO_DEMO";
		ts.next_player_x = 422;
		ts.next_player_y = 180;
	}

	public static function SET_INTRO_DEMO(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "INTRO_DEMO";
		ts.next_player_x = 422;
		ts.next_player_y = 180;
	}
	public static function SET_TEST_EVENMAP(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_MAP;
		ts.MAP_NAME = "MAPONE";
	}
	public static function SET_TEST_DREAM(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "TEST";
	}
	public static function bosstest(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "BOSSTEST";
		ts.next_player_x = 50;
		ts.next_player_y = 50;
	}
	public static function SET_TEST_REAL(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_REAL;
		ts.MAP_NAME = "REALHOME";
	}
	public static function SET_SHOREPLACE(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "SHOREPLACE";
		ts.next_player_x = 50;
	}
	public static function SET_SHOREPLACEB(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "SHOREPLACEB";
	}
	public static function SET_CANYONPLACE(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "CANYONPLACE";
	}
	public static function starfish(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "STARFISH";
		ts.next_player_x = 235;
		ts.next_player_y = 448;
	}
	public static function SET_CANYON_G1(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "CANYON_G1";
		ts.next_player_x = 16;
		ts.next_player_y = 1204;
	}
	public static function windhill(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "WINDHILL";
	}
	public static function SET_WINDHILLG1(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "WINDHILLG1";
		ts.next_player_x = 32;
		ts.next_player_y = 100;
	}
	
	public static function biglake(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "BIGLAKE";
	}
	public static function SET_EM_TEST(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_MAP;
		ts.MAP_NAME = "EM_TEST";
		ts.next_player_x = 210;
		ts.next_player_y = 209;
	}
	
	public static function SET_TESTTWO(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "TESTTWO";
	}
	
	public static function SET_TESTTWO_2(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "TESTTWO";
		ts.next_player_x = 400;
		ts.next_player_y = 600;
	}
	
	public static function SET_JONTEST(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "JONTEST02";
	}
	
	public static function SET_JONLET(ts:TestState):Void {
		ts.next_world_mode = TestState.WORLD_MODE_DREAM;
		ts.MAP_NAME = "JONLET";
		ts.next_player_x = 920;
		ts.next_player_y = 320;
	}
}