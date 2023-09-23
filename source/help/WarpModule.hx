package help;

import autom.SNDC;
import entity.ui.DialogueBox;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import global.EF;
import global.Registry;
import haxe.Log;
import openfl.Assets;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class WarpModule extends FlxGroup
{

	
	// title
	
	private var bg:FlxSprite;
	private var txt_left:FlxBitmapText;
	private var txt_mid:FlxBitmapText;
	private var txt_right:FlxBitmapText;
	private var checkboxes:FlxTypedGroup<FlxSprite>;
	private var chkbA:Array<Array<FlxSprite>>;
	private var cursor:FlxSprite;
	private var R:Registry;
	
	public function new() 
	{
		super();
	}
	
	public function init():Void {
		if (bg == null) {
			bg = new FlxSprite();
			bg.makeGraphic(416, 256, 0xff000000);
			bg.alpha = 0;
			bg.scrollFactor.set(0, 0);
			add(bg);
		}
		// re-init txt each time b/c of languagse
		if (txt_left != null) {
			remove(txt_left, true);
			remove(txt_mid, true);
			remove(txt_right, true);
			txt_left.destroy();
			txt_mid.destroy();
			txt_right.destroy();
			txt_left = null;
			txt_mid = null;
			txt_right  = null;
		}
		
		R = Registry.R;
		txt_left = HF.init_bitmap_font("", "left");
		txt_mid = HF.init_bitmap_font("", "left");
		txt_right = HF.init_bitmap_font("", "left");
		txt_left.text = R.dialogue_manager.lookup_sentence("ui", "warp_left", 0, true, true);
		txt_mid.text = R.dialogue_manager.lookup_sentence("ui", "warp_mid", 0, true, true);
		txt_right.text = R.dialogue_manager.lookup_sentence("ui", "warp_right", 0, true, true);
		add(txt_left);
		add(txt_mid);
		add(txt_right);
		
		txt_right.lineSpacing = txt_mid.lineSpacing = txt_left.lineSpacing = 8;
		
		txt_left.move(24, 256-txt_left.height-24);
		txt_mid.move(txt_left.x+txt_left.width+1+1+24, txt_left.y);
		txt_right.move(txt_mid.x + txt_mid.width + 1 + 1 + 24, txt_left.y);
		
		if (R.dialogue_manager.get_langtype() == DialogueManager.LANGTYPE_RU) {
			txt_right.lineSpacing = txt_mid.lineSpacing = txt_left.lineSpacing = 1;
			//txt_left.text = StringTools.replace(txt_left.text, " ", "\n");
			//txt_mid.text = StringTools.replace(txt_mid.text, " ", "\n");
			//txt_right.text = StringTools.replace(txt_right.text, " ", "\n");
			txt_left.move(24, 256-txt_left.height-24);
			txt_mid.move(txt_left.x+txt_left.width+1+1+16, txt_left.y);
			txt_right.move(txt_mid.x + txt_mid.width + 1 + 1 + 16, txt_left.y);
		}
		
		
		
				
		
		if (cursor == null ) {
			cursor = new FlxSprite(0, 0);
			cursor.scrollFactor.set(0, 0);
			cursor.visible = true;
			AnimImporter.loadGraphic_from_data_with_id(cursor, 7, 7, "MenuSelector", "arrow");
			cursor.animation.play("r_on");
		} 
		
		
		// Init the checkboxes once. Position them. Make an array for easy access to them.
		// Row 0 - intro, DONE
		// row 1 - set 1, row 2 - set 2, row 3 - silos, row 4 - s3, row 5 - radio
		if (checkboxes == null) {
			chkbA = [[], [], [null]];
			checkboxes = new FlxTypedGroup<FlxSprite>();
			for (i in 0...16) {
				var s:FlxSprite = new FlxSprite();
				s.loadGraphic(Assets.getBitmapData("assets/sprites/ui/checkbox.png"), true, 8, 8);
				s.animation.add("off", [0]);
				s.animation.add("on", [1]);
				s.scrollFactor.set(0, 0);
				s.ID = 0;
				checkboxes.add(s);
			}
			add(checkboxes);
			var j:Int = 0;
			
			// lay out russian with two newlines to fit everything
			for (i in [0, 1, 4, 7, 10, 13]) {
				chkbA[0].push(checkboxes.members[i]);
				

				checkboxes.members[i].move(txt_left.x - 1 - 8, txt_left.y + j * (txt_mid.lineHeight + txt_mid.lineSpacing));
				if (R.dialogue_manager.get_langtype() == DialogueManager.LANGTYPE_RU) {
				checkboxes.members[i].move(txt_left.x - 1 - 8, txt_left.y + j * 2* (txt_mid.lineHeight + txt_mid.lineSpacing));
				} 
				j++;
			}
			j = 0;
			for (i in [14,2, 5, 8, 11,15]) {
				chkbA[1].push(checkboxes.members[i]);
				checkboxes.members[i].move(txt_mid.x - 1 - 8, txt_left.y + j * (txt_mid.lineHeight + txt_mid.lineSpacing));
				if (R.dialogue_manager.get_langtype() == DialogueManager.LANGTYPE_RU) {
					checkboxes.members[i].move(txt_mid.x - 1 - 8, txt_left.y + j * 2*(txt_mid.lineHeight + txt_mid.lineSpacing));
				}

				j++;
			}
			j = 1;
			for (i in [3,6,9,12]) {
				chkbA[2].push(checkboxes.members[i]);
				checkboxes.members[i].move(txt_right.x - 1 - 8, txt_left.y + j * (txt_mid.lineHeight + txt_mid.lineSpacing));
				if (R.dialogue_manager.get_langtype() == DialogueManager.LANGTYPE_RU) {
					checkboxes.members[i].move(txt_right.x - 1 - 8, txt_left.y + j * 2*(txt_mid.lineHeight + txt_mid.lineSpacing));

				}

				j++;
			}
			chkbA[2].push(null);
		}
		
		
			remove(cursor, true);
			add(cursor);
		
		cursor.alpha = 0;
		checkboxes.setAll("alpha", 0);
			txt_left.alpha = txt_right.alpha = txt_mid.alpha = 0;
		
	}
	
	private var t_test:Float;
	private var idx_col:Int = 0;
	private var idx_row:Int = 0;
	private var mode:Int = 0;
	private var dbox:DialogueBox;
	private var warpStr:String = "";
	override public function update(elapsed:Float):Void 
	{
		
		if (bg.alpha < 1 && mode != 4) {
			bg.alpha += 0.01;
		}
		
		if (mode == 0) {
			
		} else if (mode == 1) {
			
			cursor.alpha += 0.03;
			txt_left.alpha = txt_right.alpha = txt_mid.alpha = cursor.alpha;
			for (i in 0...checkboxes.members.length) {
				if (checkboxes.members[i] != null) {
					checkboxes.members[i].alpha = cursor.alpha;
				}
			}
			
			if (R.input.jpDown) {
				R.sound_manager.play(SNDC.menu_move);
				if (idx_row == 4 && idx_col > 1) {
					
				} else {
					if (idx_row < 5) idx_row++;
				}
			} else if (R.input.jpUp) {
				R.sound_manager.play(SNDC.menu_move);
				if (idx_row == 1 && idx_col > 1) {
				
				} else {
					if (idx_row > 0) idx_row--;
				}
				
			}
			if (R.input.jpLeft) {
				R.sound_manager.play(SNDC.menu_move);
				if (idx_col > 0) idx_col--;
			} else if (R.input.jpRight) {
				R.sound_manager.play(SNDC.menu_move);
				if (idx_row == 0 && idx_col == 1) { }
				else if (idx_row == 5 && idx_col == 1) { }
				else {
					if (idx_col < 2) idx_col++;
				}
			}

			if (idx_col == 0) {
				cursor.move(chkbA[idx_col][idx_row].x - cursor.width - 1, chkbA[idx_col][idx_row].y + 2);
			} else if (idx_col == 1) {
				cursor.move(chkbA[idx_col][idx_row].x - cursor.width - 1, chkbA[idx_col][idx_row].y + 2);
			} else {
				cursor.move(chkbA[idx_col][idx_row].x - cursor.width - 1, chkbA[idx_col][idx_row].y + 2);
			}
			
			
			if (R.input.jpCONFIRM) {
				R.sound_manager.play(SNDC.menu_confirm);
				if (idx_col == 1 && idx_row == 0) {
					mode = 2;
					dbox.start_dialogue("ui", "warp_text", 0);
				} else {
					// Toggle whether palces are done, also account for areas that must be done for anothe rto be done.
					if (chkbA[idx_col][idx_row].ID == 0) {
						turn_on(idx_col, idx_row);
						if (idx_row == 5 || idx_row <= 3) {
							turn_on_all_rows_before(idx_row);
							if (idx_row == 5 && idx_col == 1) {
								turn_on(0, 5);
							}
						} else { // idx_row == 4, or set 3 areas
							turn_on_all_rows_before(3);
							turn_on(idx_col, idx_row - 1); // Turn on respective silo
						} 
							
					} else {
						turn_off(idx_col, idx_row);
						if (idx_row == 3) { // silos 
							turn_off(idx_col, idx_row + 1);// turn off corresponding S3 area
							turn_off_all_rows_after(4);
						} else {
							turn_off_all_rows_after(idx_row);
							if (idx_row == 5 && idx_col == 0) {
								turn_off(1, 5);
							}
						}
					}
				}
			}
			
		} else if (mode == 2) {
			if (dbox.last_yn != -1) {
				if (dbox.last_yn == 0) {
					mode = 1;
				} else {
					
					warpStr = do_events();
					//do_events();
					R.TEST_STATE.next_player_x = 16*Std.parseInt(warpStr.split(",")[1]);
					R.TEST_STATE.next_player_y = Std.int(16 * Std.parseInt(warpStr.split(",")[2]) - R.player.height + 1);
					R.TEST_STATE.next_map_name = warpStr.split(",")[0];
					
					// wait for outer state to remove this module
					mode = 3;
				}
			}
		} else if (mode == 3) {
			cursor.alpha -= 0.03;
			txt_left.alpha = txt_right.alpha = txt_mid.alpha = cursor.alpha;
			for (i in 0...checkboxes.members.length) {
				if (checkboxes.members[i] != null) {
					checkboxes.members[i].alpha = cursor.alpha;
				}
			}
			if (cursor.alpha <= 0) {
				bg.alpha -= 0.05;
				if (bg.alpha <= 0) {
					mode = 4;
				}
			}
		}
		super.update(elapsed);
	}
	
	private function on(ID:String):Bool {
		return chkbA[Std.parseInt(ID.split(",")[0])][Std.parseInt(ID.split(",")[1])].ID == 1;
	}
	public function set_checkbox_based_on_game_state():Void {
		chkbA[Std.parseInt(ROUGE.split(",")[0])][Std.parseInt(ROUGE.split(",")[1])].ID = R.event_state[EF.INTRO_console_scene_done];
		
		chkbA[Std.parseInt(SHORE.split(",")[0])][Std.parseInt(SHORE.split(",")[1])].ID = R.event_state[EF.shore_done];
		chkbA[Std.parseInt(CANYON.split(",")[0])][Std.parseInt(CANYON.split(",")[1])].ID = R.event_state[EF.canyon_done];
		chkbA[Std.parseInt(HILL.split(",")[0])][Std.parseInt(HILL.split(",")[1])].ID = R.event_state[EF.hill_done];
		
		chkbA[Std.parseInt(RIVER.split(",")[0])][Std.parseInt(RIVER.split(",")[1])].ID = R.event_state[EF.river_done];
		chkbA[Std.parseInt(WOODS.split(",")[0])][Std.parseInt(WOODS.split(",")[1])].ID = R.event_state[EF.woods_done];
		chkbA[Std.parseInt(BASIN.split(",")[0])][Std.parseInt(BASIN.split(",")[1])].ID = R.event_state[EF.forest_done];

		if (R.event_state[EF.radio_depths_done] == 1) {
			EventHelper.finish_i2();
		}
		
		chkbA[Std.parseInt(EARTHSILO.split(",")[0])][Std.parseInt(EARTHSILO.split(",")[1])].ID = R.inventory.is_item_found(23) ? 1 : 0;
		chkbA[Std.parseInt(AIRSILO.split(",")[0])][Std.parseInt(AIRSILO.split(",")[1])].ID = R.inventory.is_item_found(24) ? 1 : 0;
		chkbA[Std.parseInt(SEASILO.split(",")[0])][Std.parseInt(SEASILO.split(",")[1])].ID = R.inventory.is_item_found(25) ? 1 : 0;
		
		chkbA[Std.parseInt(PASS.split(",")[0])][Std.parseInt(PASS.split(",")[1])].ID = R.event_state[EF.earth_done];
		chkbA[Std.parseInt(CLIFF.split(",")[0])][Std.parseInt(CLIFF.split(",")[1])].ID = R.event_state[EF.air_done];
		chkbA[Std.parseInt(FALLS.split(",")[0])][Std.parseInt(FALLS.split(",")[1])].ID = R.event_state[EF.sea_done];
		
		chkbA[Std.parseInt(RADIO.split(",")[0])][Std.parseInt(RADIO.split(",")[1])].ID = R.event_state[EF.radio_tower_done];
		
		do_events();
	}
	
	private var ROUGE:String = "0,0";
	
	private var SHORE:String =  "0,1";
	private var CANYON:String = "1,1";
	private var HILL:String =   "2,1";
	
	private var RIVER:String = "0,2";
	private var WOODS:String = "1,2";
	private var BASIN:String = "2,2";
	
	private var EARTHSILO:String = "0,3";
	private var AIRSILO:String =   "1,3";
	private var SEASILO:String =   "2,3";
	
	private var PASS:String =  "0,4";
	private var CLIFF:String = "1,4";
	private var FALLS:String = "2,4";
	
	private var RADIO:String = "0,5";
	private var CREDITS:String = "1,5";
	
	
	private function turn_on(col:Int, row:Int):Void {
		if (col == 1 && row == 0) return; // DONE box
		chkbA[col][row].ID = 1;
		chkbA[col][row].animation.play("on");
	}
	private function turn_off(col:Int, row:Int):Void  {
		if (col == 1 && row == 0) return; // DONE box
		chkbA[col][row].ID = 0;
		chkbA[col][row].animation.play("off");
	}
	private function turn_on_all_rows_before(idx:Int):Void {
		for (i in 0...3) {
			for (j in 0...idx) {
				if (chkbA[i][j] != null) {
					turn_on(i, j);
				}
			}
		}
	}
	private function turn_off_all_rows_after(idx:Int):Void {
		for (i in 0...3) {
			for (j in idx+1...6) {
				if (chkbA[i][j] != null) {
					turn_off(i, j);
				}
			}
		}
	}
	
	/**
	 * Looks up the completion states of gauntlets
	 * @return
	 */
	public function do_events():String 
	{
		
		var out_s:String = "";
		if (on(ROUGE)) {
			EventHelper.finish_rouge();
			out_s = "WF_ALIPH,15,0";
		}
		var s1_done:Int = 0;
		if (on(SHORE)) {  s1_done++; EventHelper.finish_shore(s1_done); }
		if (on(CANYON)) { s1_done++; EventHelper.finish_canyon(s1_done); }
		if (on(HILL)) {	s1_done++; 	EventHelper.finish_hill(s1_done); }
		if (s1_done >= 1) { EventHelper.finish_intro(); out_s = "WF_GOV_MAYOR,0,0";	}
		if (s1_done >= 2) { EventHelper.finish_debrief_g1_1(); out_s = "WF_GOV_MAYOR,0,0";
		// Log.trace("debug"); EventHelper.finish_debrief_g1_2(); 
		}
		if (s1_done >= 3) {	EventHelper.finish_debrief_g1_2(); out_s = "WF_GOV_MAYOR,0,0";}
		
		s1_done = 0;
		if (on(RIVER)) {  s1_done++; EventHelper.finish_river(s1_done); }
		if (on(WOODS)) { s1_done++; EventHelper.finish_woods(s1_done); }
		if (on(BASIN)) {	s1_done++; 	EventHelper.finish_basin(s1_done); }
		
		if (s1_done >= 1) { EventHelper.finish_i1();	out_s = "WF_GOV_MAYOR,0,0";}
		if (s1_done >= 2) { EventHelper.finish_debrief_g2_1(); out_s = "WF_GOV_MAYOR,0,0";}
		if (s1_done >= 3) {	EventHelper.finish_debrief_g2_2(); out_s = "WF_LO_0,59,14"; }
		
		
		s1_done = 0;
		if (on(EARTHSILO)) {  s1_done++; EventHelper.finish_silo_earth(); }
		if (on(AIRSILO)) { s1_done++; EventHelper.finish_silo_air(); }
		if (on(SEASILO)) {	s1_done++; 	EventHelper.finish_silo_sea(); }
		
		if (s1_done >= 1) { EventHelper.finish_i2(); out_s = "KV_RADIO,16,60"; }
		
		s1_done = 0;
		
		if (on(PASS)) {  s1_done++; EventHelper.finish_pass(s1_done); }
		if (on(CLIFF)) { s1_done++; EventHelper.finish_cliff(s1_done); }
		if (on(FALLS)) { s1_done++; 	EventHelper.finish_falls(s1_done); }
		
		// FinishingI2 is done by checking silos.
		if (s1_done >= 1) { out_s = "KV_RADIO,16,60"; }
		if (s1_done >= 2) { EventHelper.finish_debrief_g3_1(); out_s = "KV_RADIO,16,60"; }
		if (s1_done >= 3) { EventHelper.finish_debrief_g3_2(); out_s = "KV_RADIO,16,60"; }
		
		if (on(RADIO)) { 
			EventHelper.finish_debrief_g3_3();
			EventHelper.finish_radio(); out_s = "WF_HI_1,34,22";
		}
		
		// Whether credits are seen i.e. postgame open
		if (on(CREDITS)) { EventHelper.finish_ending();	}
		return out_s;
	}
	
	
	public function activate(title:Bool = false,_dbox:DialogueBox=null):Void {
		bg.alpha = 0;
		//if (title) {
			//R.TEST_STATE.pause_menu
			//dbox = R.TITLE_STATE.dialogue_box;
			//R.TITLE_STATE.remove(R.TITLE_STATE.dialogue_box, true);
			//R.TITLE_STATE.add(R.TITLE_STATE.dialogue_box);
		//} else {
		if (_dbox != null) {
			dbox = _dbox;
		} else {
			dbox = R.TEST_STATE.dialogue_box;
			R.TEST_STATE.remove(R.TEST_STATE.dialogue_box, true);
			R.TEST_STATE.add(R.TEST_STATE.dialogue_box);
			
		}
		//}
		mode = 1;
	}
	public function deactivate():Void {
		mode = 0;
	}
	public function is_done():Bool {
		return mode == 4;
	}
	public function is_idle():Bool {
		return mode == 0;
	}
	
}