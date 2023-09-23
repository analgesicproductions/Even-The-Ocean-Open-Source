package entity.tool;
import autom.EMBED_TILEMAP;
import autom.SNDC;
import entity.MySprite;
import entity.ui.NineSliceBox;
import flixel.util.FlxArrayUtil;
import global.C;
import global.EF;
import global.Registry;
import haxe.Log;
import help.HF;
import hscript.Expr;
import hscript.Interp;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import openfl.Assets;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import state.MyState;
/**
 * ...
 * @author Melos Han-Tani
 */
class Door extends MySprite

{

	public static inline var TYPE_DEBUG:Int = 0;
	public static inline var TYPE_DEBUGWORLDMAP:Int = 1;
	public static inline var TYPE_INVISIBLE_MAP_HEIGHT:Int = 2;
	public static inline var TYPE_INVISIBLE_WIDE:Int = 3;
	public static inline var TYPE_32x16:Int = 4;
	public static inline var TYPE_32x32:Int = 5;
	public var visited_at_least_once:Bool = false;
	public var dest_map:String = "TEST";
	private var name_of_next_map_text:FlxBitmapText;
	private var next_title_Bg:NineSliceBox;
	
	private var fg_display:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState)
	{
		fg_display = new FlxSprite();
		R = Registry.R;
		name_of_next_map_text = HF.init_bitmap_font(" ", "center", 0, 40, null, C.FONT_TYPE_APPLE_WHITE);
		name_of_next_map_text.visible = false;
		name_of_next_map_text.alpha = 0;
		
		if (R.TEST_STATE.MAP_NAME.indexOf("MAP") == 0) {
			name_of_next_map_text.y -= 22;
		}
		name_of_next_map_text.double_draw = true;
		
		next_title_Bg = new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH, false, "assets/sprites/ui/9slice_dialogue.png");
		next_title_Bg.scrollFactor.set(0, 0);
			next_title_Bg.y = name_of_next_map_text.y - name_of_next_map_text.height / 2;
		next_title_Bg.alpha = 0;
		
		middle_sensor = new FlxObject(x + 4, y + (height / 2) - 4 / 2, 8, 4);
		
		super(_x, _y,  _parent,"Door");
	}
	public static inline var BEHAVIOR_AUTO:Int = 0;
	public static inline var BEHAVIOR_OPEN:Int = 1;
	public static inline var BEHAVIOR_CLOSED:Int = 2;
	public static inline var BEHAVIOR_ACTION_OPEN:Int = 3;
	public static inline var BEHAVIOR_EVEN_WORLDMAP:Int = 4; // Locked until a bar sends a signal
	public static inline var BEHAVIOR_SECRET:Int = 5; // opens with action key, but doesnt show black bar
	public static inline var BEHAVIOR_HIDDEN_WORLDMAP:Int = 6; // hidden on world map
	public static inline var BEHAVIOR_HIDDEN_WORLDMAP_KEEP_GO:Int = 7; // hidden on world map
	// BEHAVIOR 8: solid
	
	public static var overlapping_hidden_worldmap_door:Bool = false;
	public static var signal_to_enter_hidden_worldmap_door:Bool = false;
	
	public static var SIG_EVEN_WORLDMAP_ALLOW_ENTERING:Bool = false;
	public static var cur_even_worldmap_next_map:String = "";
	public static var player_Is_On_EVEN_worlddoor:Bool = false;
	
	public var behavior:Int = 0;
	
	override public function change_visuals():Void 
	{
		switch (props.get("type")) {
			case TYPE_DEBUG:
				makeGraphic(16, 32, 0xaadddd22);
			case TYPE_DEBUGWORLDMAP:
				makeGraphic(16, 16, 0xaadddd22);
				middle_sensor = new FlxObject(x+2, y+2, 12, 12);
			case TYPE_INVISIBLE_MAP_HEIGHT:
				makeGraphic(16, C.GAME_HEIGHT, 0xaadddd22);
			case TYPE_INVISIBLE_WIDE:
				makeGraphic(Std.int(C.GAME_HEIGHT / 2), 16, 0xaadddd22);
			case TYPE_32x16:
				makeGraphic(32, 16, 0xaadddd22);
				middle_sensor = new FlxObject(x + 4, y + (height / 2) - 4 / 2, 18, 4);
			case TYPE_32x32:
				makeGraphic(32, 32, 0xaadddd22);
				middle_sensor = new FlxObject(x + 4, y, 24, 32);
				
		}
		if (props.get("custom_size") != "0,0") {
			var pt:Point = HF.string_to_point_array(props.get("custom_size"))[0];
			makeGraphic(Std.int(pt.x), Std.int(pt.y), 0xaadddd22);
			middle_sensor.width = Std.int(pt.x) - 4;
			middle_sensor.height = Std.int(pt.y) - 4;
			middle_sensor.move(x + 2, y + 2);
		}
		
		fg_display.makeGraphic(Std.int(width), Std.int(height), 0xaadddd22);
	}
	// as they are initing: first set_properties pass: 
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic> ();
		//p.set("
		p.set("dest_x", 1);
		p.set("dest_y", 8);
		p.set("type", TYPE_DEBUG);
		p.set("dest_map", "TEST");
		p.set("behavior", BEHAVIOR_OPEN);
		p.set("s_visited", 0);
		p.set("script", "");
		p.set("next_cam_offset", "0,0");
		p.set("AUTO_INDEX", -1);
		p.set("index", 0);
		p.set("custom_size", "0,0");
		return p;
	}
	public static var NEXT_AUTO_INDEX:Int = 0;
	public static var USE_AUTO:Bool = false;
	public static var INDEX_FOR_USE_AUTO:Int = -1;
	public static var AUTO_X_OFF:Int = 0;
	public static var AUTO_Y_OFF:Int = 0;
	public static var NEXT_SNAP_TO_BOTTOM:Bool = false;
	
	private function run_script():Array<String> {
		var expr:Expr;
		var interp:Interp = new Interp();
		expr = HF.get_program_from_script_wrapper(props.get("script"));
		interp.variables.set("R", R);
		interp.variables.set("this", this);
		var a:Array<String> = interp.execute(expr);
		if (a == null) {
			return [""]; 
		} else {
			return a;
		}
	}
	
	public function behavior_to_open():Void {
		behavior = BEHAVIOR_OPEN;
		
	}
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		behavior = props.get("behavior");
		if (props.get("AUTO_INDEX") == -1) {
			//Log.trace(NEXT_AUTO_INDEX);
			props.set("AUTO_INDEX", NEXT_AUTO_INDEX);
			NEXT_AUTO_INDEX++;
		} else {
			//Log.trace([props.get("AUTO_INDEX"),NEXT_AUTO_INDEX]);
			if (props.get("AUTO_INDEX") >= NEXT_AUTO_INDEX) {
				NEXT_AUTO_INDEX = props.get("AUTO_INDEX") +1;
			}
		}
		if (Std.string(props.get("script")).length < 3) {
			props.set("script", "");
		}
		
		if (behavior == BEHAVIOR_AUTO) {
			visible = false;
		}
		visited_at_least_once = props.get("s_visited");
		dest_map = props.get("dest_map");
		change_visuals();
		
		if (behavior == BEHAVIOR_EVEN_WORLDMAP) {
			next_title_Bg.y = 64;
			name_of_next_map_text.y = (next_title_Bg.y + (next_title_Bg.height / 2)) - (name_of_next_map_text.height / 2);
		}
		
		if (R.editor != null && R.editor.editor_active && props.get("script") != "") {
			HF.get_program_from_script_wrapper(props.get("script"));
		}
		
		
		
		
		middle_sensor.ID= 0;

	}
	override public function destroy():Void 
	{
		parent_state.gui_sprites.remove(next_title_Bg);
		parent_state.gui_sprites.remove(name_of_next_map_text);
		parent_state.gui_sprites.remove(fg_display);
		cur_even_worldmap_next_map = "";
		R.ignore_door = false;
		R.attempted_door = "";
		super.destroy();
	}
	
	
	public static var overlapping_open_door:Bool = false;
	private var do_behave:Bool = false;
	private var middle_sensor:FlxObject;
	private var do_idle:Bool = false;
	private var not_active:Bool = false;
	private var non_active_collide:Bool = false;
	private var running_dialogue:Bool = false;
	private var executing_from_player:Bool = false;
	private var runEasyScene:String = "";
	override public function update(elapsed: Float):Void 
	{
		
		if (runEasyScene != "") {
			
			name_of_next_map_text.alpha -= 0.04;
			next_title_Bg.alpha -= 0.04;
			if (runEasyScene == "RUNNING") {
				if (R.easycutscene.is_off()) { 
					R.player.pause_toggle(false);
					runEasyScene = "";
				}
			} else {
				if (!parent_state.dialogue_box.is_active()) {
					R.player.pause_toggle(true);
					R.easycutscene.start(runEasyScene);
					runEasyScene = "RUNNING";
				}
			}
			return;
		}
		
		if (not_active) {
			if (non_active_collide) {
				immovable = true;
				FlxObject.separate(this, R.player);
			}
			return;
		}
		if (true) {
			if (R.editor.editor_active) {
				visible = true;
				fg_display.visible = true;
				fg_display.x = x;
				fg_display.y = y;
			} else {
				visible = false;
				fg_display.visible = false;
			}
		} else {
			visible = true;
		}
		if (!did_init) {
			if (R.activePlayer == R.worldmapplayer) {
				next_title_Bg.y = 180;
			}
			
			name_of_next_map_text.text = EMBED_TILEMAP.actualname_hash.get(props.get("dest_map"));
			if (name_of_next_map_text.text == "" || name_of_next_map_text.text == null) {
				name_of_next_map_text.text = "? ? ?";
				//next_title_Bg.exists = false;
			}
			
			next_title_Bg.resize(name_of_next_map_text.width + 14, 20);
			next_title_Bg.x = (C.GAME_WIDTH / 2) - next_title_Bg.width / 2;
			var ss:String = props.get("dest_map");
			//if (R.TEST_STATE.MAP_NAME == "MAP1" || R.TEST_STATE.MAP_NAME == "MAP2" ) {
				//var a:Array<String> = ["SHORE_1", "CANYON_1", "HILL_1", "RIVER_1", "WOODS_1", "BASIN_1", "PASS_1", "CLIFF_1", "FALLS_1"];
				//for (i in 1...10) {
					//if (ss == a[i - 1] && R.event_state[EF.area_enter_states] & (1 << i) == 0) {
						//name_of_next_map_text.text = "???";
					//}
				//}
			//}
			name_of_next_map_text.x = (C.GAME_WIDTH / 2) - (name_of_next_map_text.width / 2);
			name_of_next_map_text.y = (next_title_Bg.y + (next_title_Bg.height / 2)) - (name_of_next_map_text.height / 2);
			did_init = true;
			var res:Array<String> = run_script();
			if (res[0] == "none") {
				not_active = true;
			} else if (res[0] == "nonecollide") {
				not_active = true; non_active_collide = true;
			}
			parent_state.gui_sprites.add(fg_display);
		}
		
		if (R.activePlayer.overlaps(middle_sensor) && behavior != BEHAVIOR_AUTO && behavior != BEHAVIOR_SECRET && behavior != BEHAVIOR_HIDDEN_WORLDMAP && behavior != BEHAVIOR_HIDDEN_WORLDMAP_KEEP_GO && !parent_state.dialogue_box.is_active() && R.TEST_STATE.mode != 1)  {
			R.player.cant_lock_neutral = true;
			name_of_next_map_text.visible = true;
			name_of_next_map_text.alpha += 0.04;
			next_title_Bg.alpha += 0.04;
			
			
			// Turn on bubble hen overlap
			if (middle_sensor.ID == 0) {
				if (R.player == R.activePlayer) {
					R.player.activate_npc_bubble("speech_appear",true);
				} else if (R.activePlayer == R.worldmapplayer) {
					R.worldmapplayer.activate_npc_bubble("speech_appear");
				}
				middle_sensor.ID = 1;
			}
			
			if (parent_state.gui_sprites.members.indexOf(next_title_Bg) == -1) {
				
				parent_state.gui_sprites.add(next_title_Bg);
				parent_state.gui_sprites.add(name_of_next_map_text);
			}
			
		} else {
			
			
			// turn off when dialogue on, or not overlapping
			if (middle_sensor.ID == 1) {
				middle_sensor.ID = 0;
				if (R.player == R.activePlayer) {
					R.player.activate_npc_bubble("speech_disappear",true);
				} else if (R.activePlayer == R.worldmapplayer) {
					R.worldmapplayer.activate_npc_bubble("speech_disappear");
				}
			}
			
			name_of_next_map_text.alpha -= 0.04;
			next_title_Bg.alpha -= 0.04;
			if (next_title_Bg.alpha == 0) {
				
				parent_state.gui_sprites.remove(next_title_Bg,true);
				parent_state.gui_sprites.remove(name_of_next_map_text,true);
			}
		}
		if (do_idle) return;
		
		overlapping_open_door = false;
		switch (behavior) {
			case 8:
				immovable = true;
				FlxObject.separate(this, R.player);
		
			case BEHAVIOR_AUTO:
				
				if (R.activePlayer.overlaps(this) && R.editor.editor_active == false) {
					// Added so you can place a tile over a 1-tile-wide door and block player from getting in
					// Just checks that the player's left and right side center points are not in hard tiles before
					// allowing the door to move the player. also must be a tall door
					if (height > 128 && (0 != parent_state.tm_bg2.getTileCollisionFlags(R.activePlayer.x-1,R.activePlayer.y+R.activePlayer.height/2) || 0 != parent_state.tm_bg2.getTileCollisionFlags(R.activePlayer.x + R.activePlayer.width+1,R.activePlayer.y+R.activePlayer.height/2))) { 
					
					} else {
						do_behave = true;
						if (props.get("type") == TYPE_INVISIBLE_MAP_HEIGHT && (props.get("dest_y") == 8 || props.get("dest_y") == 0)) {
							NEXT_SNAP_TO_BOTTOM = true;
						}
					}
				}
			case BEHAVIOR_CLOSED:
			case BEHAVIOR_OPEN:
				// 2nd condition: dialogue box has to be off (for world map), or be other type of player.
				if (R.activePlayer.overlaps(middle_sensor) && (R.activePlayer != R.worldmapplayer || !R.TEST_STATE.dialogue_box.is_active())) {
					overlapping_open_door = true;
					if (R.input.jpCONFIRM && !R.input.up && !R.input.right && !R.input.down && !R.input.left) {
						if (R.ignore_door) {
							if (R.ok_doors.indexOf(",") != -1) {
								var a:Array<String> = R.ok_doors.split(",");
								if (a.indexOf(dest_map) != -1) {
									do_behave = true;
									R.ok_doors = " ";
								} else {
									R.attempted_door = dest_map;
								}
							} else {
								R.attempted_door = dest_map;
							}
						} else {
							do_behave = true;
						}
					}
				}
			case BEHAVIOR_SECRET:
				if (R.activePlayer.overlaps(middle_sensor)) {
					if (R.input.jpCONFIRM && !R.input.up && !R.input.right && !R.input.down && !R.input.left) {
						do_behave = true;
					}
				}
			case BEHAVIOR_ACTION_OPEN:
				if (R.activePlayer.overlaps(middle_sensor)) {
					if (R.input.jpCONFIRM && !R.input.up && !R.input.right && !R.input.down && !R.input.left) {
						do_behave = true;
					}
				}
			case BEHAVIOR_EVEN_WORLDMAP:
					if (R.activePlayer.overlaps(middle_sensor)) {
						player_Is_On_EVEN_worlddoor = true;
						cur_even_worldmap_next_map = dest_map;
						
						
						if (SIG_EVEN_WORLDMAP_ALLOW_ENTERING) {
							do_behave = true;
							SIG_EVEN_WORLDMAP_ALLOW_ENTERING = false;
						}
					} 
			case BEHAVIOR_HIDDEN_WORLDMAP:
				if (R.activePlayer.overlaps(middle_sensor)) {
					overlapping_hidden_worldmap_door = true;
					if (signal_to_enter_hidden_worldmap_door) {
						//do_behave = true;
						R.attempted_door = dest_map;
						signal_to_enter_hidden_worldmap_door = false;
					}
				}
				// same as above but allows running the door's script (for karavold tunnel only, where attempted_door must be reset each frame so the tunnel placer dodesn't activate)
			case BEHAVIOR_HIDDEN_WORLDMAP_KEEP_GO:
				if (R.activePlayer.overlaps(middle_sensor)) {
					overlapping_hidden_worldmap_door = true;
					if (signal_to_enter_hidden_worldmap_door) {
						do_behave = true;
						R.attempted_door = dest_map;
						signal_to_enter_hidden_worldmap_door = false;
					}
				}
				
		}
		
		if (running_dialogue) {
			if (parent_state.dialogue_box.is_active() == false) {
				//running_dialogue = false;
			} else {
				return;
			}
		}
		
		
		middle_sensor.x = x + (width/2) - (middle_sensor.width/2);
		middle_sensor.y = y + (height / 2) - (middle_sensor.height / 2);
		if (do_behave && !R.editor.editor_active) {
			// You can't enter a door when dying or in cutscene mode
			if (R.player.is_dying() || R.player.is_in_cutscene() || R.player.is_sitting()) {
				if (R.activePlayer == R.worldmapplayer) {
					
				} else {
					do_behave = false;
					return;
				}
			}
			
			
			
			var res:Array<String> = null;
			
			if (running_dialogue) {
				running_dialogue = false;
			} else if (props.get("script") != "") {
				executing_from_player = true;
				res = run_script();
				if (res.length > 0 && res[0] == "!DIALOGUE") {
					parent_state.dialogue_box.start_dialogue(res[1], res[2], Std.parseInt(res[3]));
					running_dialogue = true;
					return;
				// run the dialogue, but don't re-run this script after
				} else if (res.length > 0 && res[0] == "!DIALOGUESTOP") {
					parent_state.dialogue_box.start_dialogue(res[1], res[2], Std.parseInt(res[3]));
					do_behave = false;
					return;
				} else if (res.length > 0 && res[0] == "!EASYCUT") {
					parent_state.dialogue_box.start_dialogue(res[1], res[2], Std.parseInt(res[3]));
					runEasyScene = res[4];
					R.player.activate_npc_bubble("speech_disappear", true);
					middle_sensor.ID = 0;
					do_behave = false;
					return;
				} else if (res.length > 0 && res[0] == "!STOP") {
					do_behave = false;
					return;
				}
				
			}
			
			// When leaving, trun off bubble completely
			if (middle_sensor.ID == 1) {
				middle_sensor.ID = 2;
				if (R.player == R.activePlayer) {
					R.player.activate_npc_bubble("speech_disappear",true);
				} else if (R.activePlayer == R.worldmapplayer) {
					R.worldmapplayer.activate_npc_bubble("speech_disappear");
				}
			}
			
			R.sound_manager.play(SNDC.enter_door);
			R.TEST_STATE.next_cam_offset = HF.string_to_point_array(props.get("next_cam_offset"))[0];
			props.set("s_visited", 1);
			do_idle = true;
			parent_state.DO_CHANGE_MAP = true;
			if (R.TEST_STATE == parent_state) {
				R.TEST_STATE.mode_change_save_cur_map_ent = true;
			}
			
			if (R.player.exists) {
				R.player.enter_door();
			}
			
			
			if (props.get("dest_map").indexOf("MAP") != 0) {
				R.last_worldmap_name = parent_state.next_map_name;
				R.last_worldmap_X = Std.int(x);
				R.last_worldmap_Y = Std.int(y);
			}
			
			var no_auto:Bool = false;
			if (props.get("script") != "") {
				//Log.trace(res);
				if (res == null || res.length < 3 || (res.length >= 3 && (res[0] == "!DIALOGUE" || res[0] == "!DIALOGUESTOP"))) {
					parent_state.next_map_name = props.get("dest_map");
					parent_state.next_player_x = props.get("dest_x");
					parent_state.next_player_y = props.get("dest_y");
				} else {
					parent_state.next_map_name = res[0];
					parent_state.next_player_x = Std.parseInt(res[1]);
					parent_state.next_player_y = Std.parseInt(res[2]);
					if (res.length > 3) {
						if (res[3] == "INDEX") {
							//props.set("index")
						}
					}
					no_auto = true;
				}
			} else {
				parent_state.next_map_name = props.get("dest_map");
				parent_state.next_player_x = props.get("dest_x");
				parent_state.next_player_y = props.get("dest_y");
			}
			
			
			//if (R.gauntlet_ manager.active_gauntlet_id != "" && false == R.gauntlet_ manager.cur_gauntlet_has_map(parent_state.next_map_name)) {
				//R.gauntlet _manager.reset_status();
				//Log.trace("Gauntlet ended because " + parent_state.next_map_name + " is not in the current gauntlet.");
			//} else if (R.gauntlet_ manager.cur_gauntlet_complete) {
				//R.gauntlet_m anager.reset_status();
				//Log.trace("Gauntlet ended because gauntlet finished.");
			//}
			
			if (!no_auto && props.get("index") != -1) {
				USE_AUTO = true;
				INDEX_FOR_USE_AUTO = props.get("index");
				AUTO_X_OFF = Std.int(props.get("dest_x") * 16);
				if (AUTO_X_OFF  >= 0) AUTO_X_OFF++;
				if (AUTO_X_OFF < 0) AUTO_X_OFF--;
				
				
				// Dest_y is set via tile measurements unless using deprecated 8
				if (props.get("dest_y") == "8T") {
					AUTO_Y_OFF = 8 + 16 * 8;
				} else if (props.get("dest_y") == 8) {
					AUTO_Y_OFF = 11;
					if (R.TEST_STATE.MAP_NAME == "MAP1" || R.TEST_STATE.MAP_NAME == "MAP2") {
						Door.NEXT_SNAP_TO_BOTTOM = true; // HEH
					}
				} else {
					AUTO_Y_OFF = Std.int(props.get("dest_y") * 16 + 8);
					if (AUTO_Y_OFF == 8 && parent_state.next_map_name.indexOf("MAP") == 0) {
						AUTO_Y_OFF = 0;
						AUTO_Y_OFF += 4;
						AUTO_X_OFF += 4;
					}
				}
				//Log.trace([AUTO_X_OFF, AUTO_Y_OFF]);
			}
		}
		super.update(elapsed);
	}
	// Called from the editor
	public function door_offset_autoset():Void {
		if (x < 48) {
			props.set("dest_x", -1);
			props.set("behavior", 0);
			props.set("type", 2);
			iy = Std.int(y - C.GAME_HEIGHT + 32 );
			y = iy;
			change_visuals();
		} else if (x > parent_state.tm_bg.widthInTiles * 16 - 48) {
			props.set("dest_x", 1);
			props.set("behavior", 0);
			props.set("type", 2);
			iy =  Std.int(y - C.GAME_HEIGHT + 32);
			y = iy;
			change_visuals();
		} else if (y < 48) {
			props.set("dest_y", -3);
			props.set("dest_x", 0);
			props.set("type", 4);
			props.set("behavior", 0);
			change_visuals();
		} else if (y > parent_state.tm_bg.heightInTiles * 16 - 48) {
			props.set("dest_y", 1);
			props.set("dest_x", 0);
			props.set("type", 4);
			props.set("behavior", 0);
			change_visuals();
		}
		behavior = props.get("behavior");
	}
	
}