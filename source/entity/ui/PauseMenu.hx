	package entity.ui;
import autom.EMBED_TILEMAP;
import autom.SNDC;
import entity.MySprite;
import entity.npc.GenericNPC;
import flash.system.System;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import openfl.display.StageDisplayState;
import openfl.Lib;
 
//import flixel.input.keyboard.FlxKey;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.math.FlxPoint;
import global.C;
import global.EF;
import global.Registry;
import haxe.Log;
import haxe.Utf8;
import help.AnimImporter;
import help.DialogueManager;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import help.InputHandler;
import help.JankSave;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import openfl.display.BitmapData;
import openfl.Assets;
import state.GameState;
import state.MyState;
import state.TestState;

/**
 * END ME
 * @author Melos Han-Tani 2013
 */

 /**
  * Status:
	  * Playtime. Location.
  * Map
  * Settings - SFX volume, Music volume, Resolution Scaling, FS or window
  * Return to Title Screen
  * Quit Game
  */
class PauseMenu extends FlxGroup
{
	
	private var PURPLE:Int = 0xddeeff;
	private var BLUE:Int = 0xd8d8d8;
	public static var NO_EXIT_TO_TITLE:Bool = false;

	private var bg_dark:FlxSprite;
	private var text_playtime:FlxBitmapText;
	private var text_area:FlxBitmapText;
	private var text_choices:FlxBitmapText;
	private var text_extra:FlxBitmapText;
	private var cursor_sprite:FlxSprite; // CUrsor for selecting things on some submenu
	private var text_map:FlxBitmapText;
	private var text_gauntlet_info:FlxBitmapText;
	private var text_submenu_title:FlxBitmapText;
	private var header_strip:FlxSprite;
	private var move_submenu_title:Bool = false;
	private var choices_for_text_choices:Array<String>;
	private var choices_for_text_settings:Array<String>;
	private var choices_for_inventory:Array<String>;
	private var choices_for_tutorial:Array<String>;
	private var R:Registry;
	private var reset_cursor_on_return_from_submenu:Bool = false;
	
	private var text_humus:FlxBitmapText;
	private var sprite_humus:FlxSprite;
	
	private var mode:Int;
	private var MODE_CHOICES:Int = 0;
	private var MODE_CHOICES_idx:Int = 0;
	
	private var MODE_MAP:Int = 1;
	private var MODE_SETTINGS:Int = 2;
	private var MODE_EXIT_TO_TITLE:Int = 3;
	private var MODE_EXIT_GAME:Int = 4;
	private var MODE_ALIPH_INVENTORY:Int = 5;
	private var MODE_ALIPH_MAP:Int = 6;
	private var MODE_QUICKSAVE:Int = 7;
	private var MODE_GAUNTLET_STATS:Int = 8;
	private var MODE_RESET_GAUNTLET:Int = 9;
	private var MODE_HELP:Int = 10;
	private var MODE_REPLAY_GAUNTLET:Int = 11;
	private var MODE_JOURNAL:Int = 12;
	private var ready_to_exit:Bool = false;
	private var idle:Bool = true;
	private var did_init:Bool = false;
	private var begin_to_exit:Bool = false;
	private var confirm_is_on_yes:Bool = false;
	private var prevent_exit_ticks:Int = 5;
	private var ready_to_exit_to_title:Bool = false;
	private var main_choices:Array<Int>;
	
	public function new() 
	{
		super(0, "PauseMenu");
		
		sprite_humus = new FlxSprite();
		sprite_humus.makeGraphic(32, 32);
		sprite_humus.alpha = 0.2;
		sprite_humus.scrollFactor.set(0, 0);
		
		text_humus =  HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_ALIPH_WHITE);
		sprite_humus.x = C.GAME_WIDTH - sprite_humus.width - 8;
		sprite_humus.y = C.GAME_HEIGHT - sprite_humus.height - 20;
		
		header_strip = new FlxSprite();
		header_strip.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/menubar.png"));
		header_strip.height = 20;
		header_strip.offset.y = 8;
		//header_strip.makeGraphic(C.GAME_WIDTH, 20, 0xff44ccff);	
		header_strip.scrollFactor.set(0, 0);
		header_strip.y = 8;
		
		dialogue_box = new DialogueBox();
		dialogue_box.MAIN_DISPLAY_MAX_ALPHA = 1;
		bg_dark = new FlxSprite(0,0);
		bg_dark.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		bg_dark.alpha = 0;
		bg_dark.scrollFactor.set(0, 0);
		
		add(bg_dark);
		
		text_choices = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_APPLE_WHITE);
		add(text_choices);
		
		add(sprite_humus);
		add(text_humus);
		
		text_extra = HF.init_bitmap_font(" ", "center", 0, 0, null, C.FONT_TYPE_APPLE_WHITE);
		add(text_extra);
		
		text_playtime = HF.init_bitmap_font(" ", "left", 2, C.GAME_HEIGHT - 10, null, C.FONT_TYPE_APPLE_WHITE);
		text_playtime.double_draw = true;
		add(text_playtime);
		text_playtime.visible = false;
		text_area = HF.init_bitmap_font(" ", "left", 2, C.GAME_HEIGHT - 20, null, C.FONT_TYPE_APPLE_WHITE,true);
		add(text_area);
		
		text_map = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_APPLE_WHITE,true);
		add(text_map);
		
		text_gauntlet_info = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_APPLE_WHITE,true);
		add(text_gauntlet_info);
		
		add(header_strip);
		text_submenu_title = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_APPLE_WHITE, true);
		add(text_submenu_title);
		text_submenu_title.color = BLUE;
		
		R = Registry.R;
		
		add(R.menu_map);
		R.menu_map.exists = false;
		
		cursor_sprite = new FlxSprite(0, 0);
		cursor_sprite.scrollFactor.set(0, 0);
		cursor_sprite.visible = false;
		AnimImporter.loadGraphic_from_data_with_id(cursor_sprite, 7, 7, "MenuSelector", "arrow");
		cursor_sprite.animation.play("r_on");
		add(cursor_sprite);
		
		active_item_slots = new FlxTypedGroup<FlxSprite>(15);
		active_item_images = new FlxTypedGroup<FlxSprite>(15);
		add(active_item_slots);
		add(active_item_images);
		
		var item_slot:String = GenericNPC.entity_spritesheet_data.get("Inventory").get("names").get("item_slot");
		var item:String = GenericNPC.entity_spritesheet_data.get("Inventory").get("names").get("item");
		for (i in 0...active_item_images.maxSize) {
			var s:FlxSprite = new FlxSprite();
			AnimImporter.loadGraphic_from_data_with_id(s, 32, 32, "Inventory", item);
			s.width = 28;
			s.height = 28;
			s.offset.set(2, 2);
			active_item_images.add(s);
			s.exists = false;
		}
		for (i in 0...active_item_slots.maxSize) {
			var s:FlxSprite = new FlxSprite();
			AnimImporter.loadGraphic_from_data_with_id(s, 32, 32, "Inventory", item_slot);
			active_item_slots.add(s);
			s.exists = false;
			
		}
		active_item_images.setAll("scrollFactor", new FlxPoint(0,0));
		active_item_slots.setAll("scrollFactor", new FlxPoint(0,0));
		
		inv_row_indctrs = new FlxTypedGroup();
		
		inv_row_slctr = new FlxSprite();
		inv_row_slctr.makeGraphic(11, 11, 0xa4ff00ff);
		inv_row_slctr.scrollFactor.set(0, 0);
		inv_row_slctr.exists = inv_row_indctrs.exists = false;
		//add(inv_row_indctrs);
		//add(inv_row_slctr);
		
		map_pic_sprite = new FlxSprite();
		map_pic_sprite.visible = false;
		map_pic_sprite.alpha = 0;
		add(map_pic_sprite);
		
		add(dialogue_box);
		
	}
	
	public static function lookup_label(pos:Int,type:String="pause",raw:Bool=false):String {
		return Registry.R.dialogue_manager.lookup_sentence(DialogueManager.M_UI, type, pos,false,raw);
	}
	/**
	 * Determines what choices in the main menu show up.
	 */
	private function set_main_choices():Void {
		// Choices in The ocean
		if (R.player == R.activePlayer || R.worldmapplayer == R.activePlayer) {

			//main_choices = [1, 	0,2, 6, 8,5, 3, 4];
			//main_choices = [1, 	0,2, 8,5, 3, 4]; // remove gauntlet (2015 5 28)
			//Log.trace("Removing Inventory, Maps, Journal, because of TGS.");
			//main_choices = [2, 8, 3]; // remove quicksave and old exit game (return to title -> exit game)
			main_choices = [1, 	0,12,2, 8, 3]; // remove quicksave and old exit game (return to title -> exit game)
			//if (R.gauntlet_manager.active_gauntlet_id != "") { // Retry gauntlet (removed 2015 7 27)
				//main_choices.push(7);
			//} 
			if (R.event_state[EF.credits_watched] == 1 && R.dialogue_manager.get_scene_state_var("overworld","misc",2) == 1) { // Replay level
				main_choices.push(9);
			}
		// Choices in Even
		} else {
			main_choices = [0, 1, 2, 3, 4];
		}
	}
	
	public function is_exiting():Bool {
		if (begin_to_exit) {
			return true;
		}
		return false;
	}
	private var in_explanation:Bool = false;
	override public function update(elapsed: Float):Void {
		super.update(elapsed);
		
		if (!did_init) {
			did_init = true;
			set_main_choices();
			init_settings();
			set_choices_text();
			if (FROM_TITLE) {
				text_choices.text = "";
			}
		}
		
		if (in_explanation) {
			if (dialogue_box.is_active() == false) {
				in_explanation = false;
			}
			return;
		}
		// TestState will be fading out, so wait for TestState to call deactivate
		if (ready_to_exit_to_title) {
			return;
		}
		
		if (do_item_exit_anim) {
			update_inventory_enter_anim(true);
		}
		
		
		if (!begin_to_exit) {
			
			if (bg_dark.alpha < 0.84) {
				bg_dark.alpha += 0.04;
				text_area.alpha += 0.06;
				text_humus.alpha += 0.06;
				text_choices.alpha += 0.06;
				cursor_sprite.alpha += 0.06;
				header_strip.alpha += 0.06;
			}
			if (FROM_TITLE_AND_MAINMENU) { // fade title pause bg in darker 
				if (bg_dark.alpha >= 0.84 && bg_dark.alpha < 0.95) {
					bg_dark.alpha += 0.04;
				}
			}
			if (text_submenu_title.alpha < 1) {
				text_submenu_title.alpha += 0.03;
				text_submenu_title.alpha *= 1.09;
			}
			if (FROM_TITLE && R.dialogue_manager.is_chinese()) {
				text_submenu_title.alpha = header_strip.alpha = 0;
			}
		} else {
			
			if (bg_dark.alpha > 0) {
				bg_dark.alpha -= 0.04; 
				text_choices.alpha -= 0.06;
				cursor_sprite.alpha -= 0.06;
				text_submenu_title.alpha -= 0.06;
				header_strip.alpha -= 0.06;
				text_area.alpha -= 0.06;
				sprite_humus.alpha = text_humus.alpha = text_area.alpha;
				
				
			} else {
				text_extra.alpha = 0;
				text_area.alpha = 0;
				sprite_humus.alpha = text_humus.alpha = text_area.alpha;
				text_extra.text = " ";
				text_submenu_title.alpha = 0;
				ready_to_exit = true;
			}
			return;
		}
		
		//if (move_submenu_title) {
			//if (text_submenu_title.y < 32) {
				//text_submenu_title.y = 32; text_submenu_title.velocity.y = 0;
			//}
			//if (text_submenu_title.velocity.x == 0 && text_submenu_title.velocity.y == 0) {
				//move_submenu_title = false;
			//}
		//}
		
		if (prevent_exit_ticks > 0) {
			prevent_exit_ticks --;
		}
		
		if (reset_cursor_on_return_from_submenu) {
			if (cursor_sprite.alpha == 0) {
				cursor_sprite.alpha = 0.001;
			} else {
				reset_cursor_on_return_from_submenu = false;
				cursor_sprite.x = text_choices.x - cursor_sprite.width - 2;
				cursor_sprite.y = text_choices.y + MODE_CHOICES_idx * (text_choices.lineHeight + text_choices.lineSpacing);
				if (R.dialogue_manager.is_chinese()) cursor_sprite.y += 6;
				if (R.dialogue_manager.is_other()) cursor_sprite.y += 2;
							
				cursor_sprite.alpha = 1;
			}
		}
		if (MODE_CHOICES == mode || MODE_JOURNAL == mode || MODE_EXIT_TO_TITLE == mode) {
			text_area.alpha = text_choices.alpha;
		} else  {
			text_area.alpha = 0;
		}
		
		// Go from Main Menu to a specific submenu
		switch (mode) {
			case _ if (MODE_CHOICES == mode):
				
				if (FROM_TITLE) {
					mode = MODE_SETTINGS;
					in_mode_pick = true;
					sprite_humus.visible = false;
					text_humus.visible = false;
					settings_idx = 0;
					//set_settings_menu_text(settings_idx);
					cursor_sprite.y = text_choices.y;
					cursor_sprite.x = text_choices.x - cursor_sprite.width - 2;
					//center_text(text_choices);
					update_subtitle_text();	
					return;
				}
				
				if (false && R.input.jpSit) {
					in_explanation = true;
					var main_choice:Int = main_choices[MODE_CHOICES_idx];
					// 1 0 2 8 3
					if (main_choice == 1) {
						dialogue_box.start_dialogue("ui", "desktop_help", 0);
					} else if (main_choice == 0) {
						dialogue_box.start_dialogue("ui", "desktop_help", 1);
					} else if (main_choice == 12) {
						dialogue_box.start_dialogue("ui", "desktop_help", 2);
					} else if (main_choice == 2) {
						dialogue_box.start_dialogue("ui", "desktop_help", 3);
					} else if (main_choice == 8) {
						dialogue_box.start_dialogue("ui", "desktop_help", 4);
					} else if (main_choice == 3) {
						dialogue_box.start_dialogue("ui", "desktop_help", 5);
					}
					return;
				}
				
				// Fade back in the choices, move the cursor.
				if (text_choices.alpha < 1) {
					
					text_choices.alpha += 0.045;
					text_choices.alpha *= 1.06;
					if (text_choices.alpha >= 1) {
						text_choices.alpha = 1;
						dont_animate_subtitle_text = false;
					}
					text_extra.alpha = 1 - text_choices.alpha;
					//if (!dont_animate_subtitle_text) {
						//text_submenu_title.alpha = 1 - text_choices.alpha;
						//text_submenu_title.velocity.y = 200;
					//}
					//if (text_submenu_title.alpha == 0) {
						//text_submenu_title.velocity.y = 0;
					//}
				}
				if (R.input.jpDown) {
					R.sound_manager.play(SNDC.menu_move, 1);
					if (MODE_CHOICES_idx < choices_for_text_choices.length - 1) {
						MODE_CHOICES_idx ++;
					} else {
						MODE_CHOICES_idx = 0;
					}
					cursor_sprite.x = text_choices.x - cursor_sprite.width - 2;
					cursor_sprite.y = text_choices.y + MODE_CHOICES_idx * (text_choices.lineHeight + text_choices.lineSpacing);
					if (R.dialogue_manager.is_chinese()) cursor_sprite.y += 6;
					if (R.dialogue_manager.is_other()) cursor_sprite.y += 2;
				} else if (R.input.jpUp) {
					R.sound_manager.play(SNDC.menu_move, 1);
					if (MODE_CHOICES_idx > 0) {
						MODE_CHOICES_idx --;
					} else {
						MODE_CHOICES_idx = choices_for_text_choices.length - 1;
					}
					
					cursor_sprite.x = text_choices.x - cursor_sprite.width - 2;
					cursor_sprite.y = text_choices.y + MODE_CHOICES_idx * (text_choices.lineHeight + text_choices.lineSpacing);
					if (R.dialogue_manager.is_chinese()) cursor_sprite.y += 6;
					if (R.dialogue_manager.is_other()) cursor_sprite.y += 2;
				} else if (R.input.jpPause || R.input.jpCANCEL) {
					if (prevent_exit_ticks <= 0) {
						begin_to_exit = true;
						R.sound_manager.play(SNDC.menu_close);
					}
				} else if (R.input.jpCONFIRM) {
					R.sound_manager.play(SNDC.menu_confirm, 1);
					// get the actual list of IDs from the current list shown
					var main_choice:Int = main_choices[MODE_CHOICES_idx];
					//text_submenu_title.text = choices_for_text_choices[MODE_CHOICES_idx];
					//text_submenu_title.y = text_choices.y + MODE_CHOICES_idx * (text_choices.lineHeight + text_choices.lineSpacing);
					
					//var md:Float = C.GAME_WIDTH / 2 - text_submenu_title.width / 2;
					//text_submenu_title.x = md;
					//text_submenu_title.velocity.y = (text_submenu_title.y - 32) / -0.2;
					//text_submenu_title.alpha = 0;
					text_extra.alpha = 0;
					
					move_submenu_title = true;
					if (main_choice == 0) { // Show the map
						mode = MODE_MAP;
						cursor_sprite.alpha = 0;
						init_maps_on_select();
						//if (R.worldmapplayer.exists == false) {
							//mode = MODE_MAP;
							//R.menu_map.exists = true;
						//} else {
							//mode = MODE_ALIPH_MAP;
							//world_map_uncoverer_was_visible = R.TEST_STATE.worldmapuncoverer.rect_cover.visible;
							//aliph_map = R.TEST_STATE.worldmapuncoverer;
							//aliph_map.make_visible();
							//aliph_map.move_to_top_of_draw_group(cast(R.TEST_STATE, MyState));
							//aliph_map.move_to(0, 0, true);
							//aliph_map.cursor.visible = true;
							//aliph_map.cursor.x = aliph_map.player_rep.x - 5;
							//aliph_map.cursor.y = aliph_map.player_rep.y - 5;
						//}
						//return;
					}
					if (main_choice == 1 && !do_item_exit_anim) { // Show aliph invenotry
						mode = MODE_ALIPH_INVENTORY;
						cursor_sprite.alpha = 0;
						init_inventory_on_select();
						//return;
					}
					if (main_choice == 2) { // Show settings
						mode = MODE_SETTINGS;
						settings_idx = 0;
						set_settings_menu_text(settings_idx);
						cursor_sprite.y = text_choices.y;
						
						if (R.dialogue_manager.is_chinese()) cursor_sprite.y += 6;
						if (R.dialogue_manager.is_other()) cursor_sprite.y += 2;
						cursor_sprite.x = text_choices.x - cursor_sprite.width - 2;
					}
					
					if (main_choice == 3) { // Exit to title
						if (NO_EXIT_TO_TITLE == false) {
							mode = MODE_EXIT_TO_TITLE;
							//text_choices.text = HF.get_are_you_sure_string(R.dialogue_manager, false);
							//confirm_is_on_yes = false;
							dialogue_box.start_dialogue("ui", "exit_menu", 0);
						} else {
							FlxG.cameras.flash(0xffff0000, 0.5);
						}
					}
					if (main_choice == 4) { // Quit game
						if (R.PAX_PRIME_DEMO_ON == false) {
							mode = MODE_EXIT_GAME;
							text_choices.text = HF.get_are_you_sure_string(R.dialogue_manager, false);
							confirm_is_on_yes = false;
						} else {
							FlxG.cameras.flash(0xffff0000, 0.5);
						}
					}
					if (main_choice == 5) {
						mode = MODE_QUICKSAVE;
						cursor_sprite.visible = false;
					}
					if (main_choice == 6) {
						mode = MODE_GAUNTLET_STATS;
					}
					if (main_choice == 7) {
						mode = MODE_RESET_GAUNTLET;
						text_choices.text = HF.get_are_you_sure_string(R.dialogue_manager, false);
						confirm_is_on_yes = false;
					}
					
					if (main_choice == 8) {
						mode = MODE_HELP;
						set_choices_text();
						text_choices.text = choices_for_tutorial.join("\n");
						cursor_sprite.visible = true;
						center_text(text_choices);
						mode_aliph_inv_cursor_idx = 0;
						set_cursor_sprite(text_choices, mode_aliph_inv_cursor_idx);
						text_choices.alpha = 1;
						
						//set_submenu_title(text_submenu_title, text_choices, MODE_CHOICES_idx);
					}
					if (main_choice == 9) {
						mode = MODE_REPLAY_GAUNTLET;
						init_replay_gauntlet_on_select();
					}
					
					if (main_choice == 12) {
						mode = MODE_JOURNAL;
						R.achv.unlock(R.achv.readJournal);
						R.journal.activate();
						add(R.journal);
					}
					if (mode == MODE_MAP || mode == MODE_ALIPH_INVENTORY || mode == MODE_SETTINGS) {
						
					} else {
						center_text(text_choices);
					}
				}
			case _ if (MODE_EXIT_TO_TITLE == mode) :
				if (dialogue_box.last_yn != -1) {
					if (dialogue_box.last_yn == 0) {
						mode = MODE_CHOICES;
					} else if (dialogue_box.last_yn == 1) {
						ready_to_exit_to_title = true;
					} else {
						#if cpp
						System.exit(0);
						#else
						System.exit(0);
						#end
					}
				}
				//if (selected_yes_confirm()) {
					//ready_to_exit_to_title = true;
				//}
			//case _ if (MODE_EXIT_GAME == mode) :
				//if (selected_yes_confirm()) {
					//#if cpp
					//System.exit();
					//#else
					//System.exit(0);
					//#end
				//}
			case _ if (MODE_RESET_GAUNTLET == mode) :
				if (selected_yes_confirm()) {
					//R.gauntlet_mana ger.reset_status();
					R.TEST_STATE.DO_CHANGE_MAP = true;
					//R.TEST_STATE.next_map_name = R.g auntlet_manager.cur_gaun_init_map;
					//R.TEST_STATE.next_player_x = R. gauntlet_manager.cur_gaun_init_x;
					//R.TEST_STATE.next_player_y = R.ga untlet_manager.cur_gaun_init_y;
					JankSave.force_checkpoint_things = false;
					R.sound_manager.play(SNDC.menu_close);
					R.player.enter_door();
					begin_to_exit = true;
				}
			case _ if (MODE_SETTINGS == mode) :
				update_mode_settings();
			case _ if (MODE_MAP == mode):
				update_mode_map();
			case _ if (MODE_ALIPH_INVENTORY == mode):
				update_mode_aliph_inventory();
			case _ if (MODE_ALIPH_MAP == mode): 
				update_mode_aliph_map();
			case _ if (MODE_QUICKSAVE == mode) :
				update_mode_quicksave();
			case _ if (MODE_GAUNTLET_STATS == mode):
				//update_mode_gauntlet_stats();
			case _ if (MODE_HELP == mode):
				update_mode_help();
			case _ if (MODE_REPLAY_GAUNTLET == mode):
				update_gauntlet_replay();
			case _ if (MODE_JOURNAL == mode):
				if (R.journal.is_done()) {
					mode = MODE_CHOICES;
					remove(R.journal, true);
				}
				
		}
		
		// Update header text
		if (R.input.jpA1 || R.input.jpA2 || dialogue_box.last_yn == 0) {
			update_subtitle_text();
		}
		
	}
	
	private function update_subtitle_text():Void {
		text_submenu_title.alpha = 1;
		text_submenu_title.color = BLUE;
		var next_str:String = "";
			next_str = R.dialogue_manager.lookup_sentence("ui", "pause", 10) + " > ";
		if (mode == MODE_MAP) {
			next_str += R.dialogue_manager.lookup_sentence("ui", "pause", 0);
		} else if (mode == MODE_ALIPH_INVENTORY) {
			next_str += R.dialogue_manager.lookup_sentence("ui", "pause", 1);
		} else if (mode == MODE_SETTINGS || FROM_TITLE_AND_MAINMENU) {
			next_str += R.dialogue_manager.lookup_sentence("ui", "pause", 2);
			if (in_language_options) {
				next_str += " > "+R.dialogue_manager.lookup_sentence("ui", "pause", 11);
			} else if (in_access_opts) {
				next_str += " > "+R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 9);
			} else if (in_joy_config) {
				next_str += " > "+R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 6);
			} else if (in_keys) {
				next_str += " > " + R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 5);	
			} else if (in_speedrun_options) {
				next_str += " > " + R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 8);	
			}
				
		} else if (mode == MODE_HELP) {
			next_str += R.dialogue_manager.lookup_sentence("ui", "pause", 8);
			 
		} else if (mode == MODE_EXIT_TO_TITLE) {
			next_str += R.dialogue_manager.lookup_sentence("ui", "pause", 3);
			 
		} else if (mode == MODE_REPLAY_GAUNTLET) {
			
		} else {
			next_str = R.dialogue_manager.lookup_sentence("ui", "pause", 10);
		}
		
		if (next_str != text_submenu_title.text) {
			text_submenu_title.alpha = 0;
		}
		
		if (in_mode_pick && !FROM_TITLE_AND_MAINMENU) {
			next_str = R.dialogue_manager.lookup_sentence("ui", "game_mode_desc", 5, true, true);
			text_submenu_title.alpha = 1;
		}
		
		text_submenu_title.text = next_str;
		text_submenu_title.x = (FlxG.width - text_submenu_title.width) / 2;
		text_submenu_title.y = header_strip.y + header_strip.height / 2;
		text_submenu_title.y -= text_submenu_title.height / 2;
		
		if (FROM_TITLE && R.dialogue_manager.is_chinese()) {
			text_submenu_title.alpha = 0;
			header_strip.alpha = 0;
		}
	}
	
	private function set_submenu_title(b:FlxBitmapText, rel_bm:FlxBitmapText, _MODE_CHOICES_idx:Int):Void {
		
		b.text = choices_for_text_choices[_MODE_CHOICES_idx];
		b.y = rel_bm.y + _MODE_CHOICES_idx * (rel_bm.lineHeight + rel_bm.lineSpacing);
		
		var md:Float = C.GAME_WIDTH / 2 - b.width / 2;
		b.x = md;
		b.velocity.y = (b.y - 32) / -0.2;
		b.alpha = 0;
	}
	
	private var did_init_mode_help:Bool = false;
	private function update_mode_help():Void {
		
		if (R.tutorial_group.exists) {
			if (R.tutorial_group.is_done()) {
				R.tutorial_group.exists = false;
				remove(R.tutorial_group, true);
				remove(R.TEST_STATE.dialogue_box);
			}
			return;
		}
		//if (!did_init_mode_help) {
			//text_submenu_title.alpha += 0.06;
			//if (text_submenu_title.alpha >= 1) {
				//did_init_mode_help = true;
			//}
		//}
		if (R.input.jpCANCEL || R.input.jpPause) {
			did_init_mode_help = false;
			R.sound_manager.play(SNDC.menu_cancel);
			set_choices_text();
			mode = MODE_CHOICES;
			text_choices.alpha = 0;
			set_cursor_sprite(text_choices, MODE_CHOICES_idx);
			if (R.input.jpPause) {
				begin_to_exit = true;
			}
			return;
		}
		
		if (R.input.jpDown) {
			if (mode_aliph_inv_cursor_idx < choices_for_tutorial.length - 1) {
				mode_aliph_inv_cursor_idx ++;
				R.sound_manager.play(SNDC.menu_move);
				cursor_sprite.y += (text_choices.lineHeight + text_choices.lineSpacing);
			}
		} else if (R.input.jpUp) {
			if (mode_aliph_inv_cursor_idx > 0) {
				mode_aliph_inv_cursor_idx --;
				R.sound_manager.play(SNDC.menu_move);
				cursor_sprite.y -= (text_choices.lineHeight + text_choices.lineSpacing);
			}
		} else if (R.input.jpCONFIRM) {
			R.tutorial_group.exists = true;
				R.sound_manager.play(SNDC.menu_confirm);
			//R.tutorial_group.start(R.TEST_STATE.dialogue_box, mode_aliph_inv_cursor_idx);
			//Log.trace("Tutorial idx call change, TGS");
			R.tutorial_group.start(R.TEST_STATE.dialogue_box, mode_aliph_inv_cursor_idx+1);
			add(R.tutorial_group);
			add(R.TEST_STATE.dialogue_box);
		}
	}
	public function is_ready_to_exit_to_title():Bool {
		return ready_to_exit_to_title;
	}
	public function is_ready_to_exit():Bool {
		return ready_to_exit;
	}
	
	public var FROM_TITLE:Bool = false;
	public var FROM_TITLE_AND_MAINMENU:Bool = false; // Skips the game mode thing (used for main menu settings)
	private var dont_animate_subtitle_text:Bool = false;
	public function activate(s:FlxState):Void {
		if (R.there_is_a_cutscene_running) {
			Log.trace("Cutscene running, not pausing game.");
			return;
		}
		s.add(this);
		if (Std.is(s,TestState) && EMBED_TILEMAP.actualname_hash.exists(Reflect.getProperty(s,"MAP_NAME"))) {
			text_area.text = EMBED_TILEMAP.actualname_hash.get(Reflect.getProperty(s, "MAP_NAME"));
			text_area.color = PURPLE;
		} else {
			text_area.text = " ";
		}
		text_humus.color = PURPLE;
		text_humus.text = R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 10, false, true);
		
		if (R.dialogue_manager.is_chinese()) {
			text_humus.text = StringTools.replace(text_humus.text, "\n", " ");
		}
		text_area.x = C.GAME_WIDTH - text_area.width - 8;
		
		if (FlxG.keys.pressed.SHIFT && ProjectClass.DEV_MODE_ON) {
			FROM_TITLE = true;
			Log.trace("debug from title");
		}
		
		
		if (!FROM_TITLE) {
			//sprite_humus.visible = text_humus.visible = true;
			sprite_humus.visible = false;
			text_humus.visible = true;
		} else {
			sprite_humus.visible = text_humus.visible = false;
			cursor_sprite.alpha = 0;
		}
		text_humus.y = C.GAME_HEIGHT - text_humus.height - 4;
		text_humus.x = C.GAME_WIDTH - text_humus.width - 4;
		text_area.y = text_humus.y-24;
		
		set_main_choices();
		init_settings();
		set_choices_text();
		cursor_sprite.visible = cursor_sprite.exists = true;
		cursor_sprite.x = text_choices.x - 2 - cursor_sprite.width;
		cursor_sprite.y = text_choices.y;
		if (R.dialogue_manager.is_chinese()) cursor_sprite.y += 6;
		if (R.dialogue_manager.is_other()) cursor_sprite.y += 2;

		dont_animate_subtitle_text = true;
		//if (R.gauntlet_ manager.active_gauntlet_id != "" && R.speed_opts[3]) {
			//text_gauntlet_info.text = R.gauntlet_manager.get_in_gauntlet_string();
			//text_gauntlet_info.x = FlxG.width - text_gauntlet_info.width - 2;
			//text_gauntlet_info.y = FlxG.height - text_gauntlet_info.height - C.ALIPH_FONT_h - 2;
		//}
		idle = false;
		text_submenu_title.visible = true;
		text_submenu_title.alpha = 1;
		if (FROM_TITLE_AND_MAINMENU || FROM_TITLE) {
			
		} else {
			text_submenu_title.text = R.dialogue_manager.lookup_sentence("ui", "pause", 10);
		}
		text_submenu_title.x = (FlxG.width - text_submenu_title.width) / 2;
		text_submenu_title.y = header_strip.y + header_strip.height / 2;
		text_submenu_title.y -= text_submenu_title.height / 2;
		cursor_sprite.alpha = 1;
		if (FROM_TITLE || FROM_TITLE_AND_MAINMENU) {
			text_choices.text = "";
			cursor_sprite.alpha = 0;
		}
		prevent_exit_ticks = 5;
	}
	public function deactivate(s:FlxState):Void {
		s.remove(this, true);
		text_gauntlet_info.text = " ";
		idle = true;
		ready_to_exit = false; 
		begin_to_exit = false;
		ready_to_exit_to_title = false;
		prevent_exit_ticks = 5;
		cleanup();
	}
	public function is_idle():Bool {
		return idle;
	}
	private function cleanup():Void {
		mode = MODE_CHOICES;
		bg_dark.alpha = 0;
		cursor_sprite.visible = false;
		text_choices.visible = true;
		text_choices.alpha = 0;
		confirm_is_on_yes = false;
		MODE_CHOICES_idx = 0;
		set_choices_caps_label(MODE_CHOICES_idx,choices_for_text_choices);
	}
	
	/**
	 * Helper function for confirmation dialogues in the main menu - if you select no,
	 * returns back to main menu
	 * @return
	 */
	private var selectyesconfirm:Bool = false;
	private function selected_yes_confirm():Bool {
		
		if (selectyesconfirm == false) {
			confirm_is_on_yes = false;
			text_choices.text = HF.get_are_you_sure_string(R.dialogue_manager, confirm_is_on_yes);
			selectyesconfirm = true;
		}
		cursor_sprite.x = text_choices.x - cursor_sprite.width - 2;
		if (confirm_is_on_yes) {
			cursor_sprite.y = text_choices.y + (text_choices.lineHeight + text_choices.lineSpacing) * 2;
		} else {
			cursor_sprite.y = text_choices.y + (text_choices.lineHeight + text_choices.lineSpacing) * 3;
		}
		
		if (R.input.jpDown) { //yes no
			R.sound_manager.play(SNDC.menu_move);
			if (confirm_is_on_yes == true) {
				confirm_is_on_yes = false;
				text_choices.text = HF.get_are_you_sure_string(R.dialogue_manager, false);
			}
		} else if (R.input.jpUp) {
			R.sound_manager.play(SNDC.menu_move);
			if (confirm_is_on_yes == false) {
				confirm_is_on_yes = true;
				text_choices.text = HF.get_are_you_sure_string(R.dialogue_manager,true);
			}
		} else if (R.input.jpCONFIRM) {
			R.sound_manager.play(SNDC.menu_confirm);
			if (confirm_is_on_yes) {
				return true;
			} else {
				set_choices_text();
				mode = MODE_CHOICES;
				return_cursor_sprite_to_default();
				selectyesconfirm = false;
			}
		} else if (R.input.jpPause) {
			R.sound_manager.play(SNDC.menu_close);
			begin_to_exit = true;
			selectyesconfirm = false;
		} else if (R.input.jpCANCEL) {
			R.sound_manager.play(SNDC.menu_cancel);
			set_choices_text();
			mode = MODE_CHOICES;
			return_cursor_sprite_to_default();
			selectyesconfirm = false;
		}
		return false;
	}
	
	/**
	 * Based on the current language, initializes the array that holds each 
	 * choice's label for the settings and main menu select.
	 */
	private function set_choices_text():Void 
	{

		choices_for_text_choices = [];
		for (i in 0...main_choices.length) {
			choices_for_text_choices.push(lookup_label(main_choices[i],"pause",true));
		}

		choices_for_text_settings = [];
		for (i in 0...settings_choice_ids.length) {
			if (i == 6) { // joypad
				var s:String = lookup_label(settings_choice_ids[i], "desktop_settings", true);
				if (R.input.joy_reverse) {
					s += ": " + lookup_label(2, "controller_flip", true);
				} else {
					s += ": " + lookup_label(1, "controller_flip", true);
				}
				choices_for_text_settings.push(s);
			} else {
				choices_for_text_settings.push(lookup_label(settings_choice_ids[i], "desktop_settings", true));
			}
		}
		
		choices_for_inventory = [];
		for (i in 0...2) {
			choices_for_inventory.push(lookup_label(i, "inventory"));
		}
		
		choices_for_tutorial = [];
		//Log.trace("No basic movement tutorial, TGS?");
		if (R.event_state[EF.player_intro_cave] == 1) {
			for (i in 2...8) {
				choices_for_tutorial.push(R.dialogue_manager.lookup_sentence("intro", "tutorial_titles", i));
			}
		} else {
			for (i in 2...8) {
				choices_for_tutorial.push(R.dialogue_manager.lookup_sentence("intro", "tutorial_titles", i));
			}
		}
		
		text_choices.text = choices_for_text_choices.join("\n");
		
		center_text(text_choices);
		
		set_choices_caps_label(MODE_CHOICES_idx, choices_for_text_choices);
		
	}
	
	/**
	 * Capitalizes choice POS out of the strings in CHOICES and returns the concatenatoin
	 */
	private function set_choices_caps_label(pos:Int,choices:Array<String>):Void {
		text_choices.text = choices.join("\n");
		//text_choices.text = StringTools.replace(text_choices.text, choices[pos], "-" + choices[pos].toUpperCase() + "-");
		text_choices.text = StringTools.replace(text_choices.text, choices[pos], choices[pos]);
		center_text(text_choices);
		set_cursor_sprite(text_choices, settings_idx);
	
	}
	
	private function update_submode_gauntlet_leg():Void {
		if (R.input.jpCANCEL) {
			gauntlet_in_leg_stats = false;
			gauntlet_mode_did_reinit = false;
		}
	}
	
	private var gauntlet_in_leg_stats:Bool = false;
	private var gauntlet_mode_did_reinit:Bool = false;
	private var gauntlet_available_gids:Array<String>;
	private var gauntlet_available_names:Array<String>;
	private var gauntlet_selector_idx:Int = 0;
	private function update_mode_gauntlet_stats():Void {
		
		if (gauntlet_mode_did_reinit == false) {
			cursor_sprite.visible = true;
			gauntlet_selector_idx = 0;
			gauntlet_mode_did_reinit = true;
			text_choices.text = "";
			text_choices.alignment = "left";
			gauntlet_available_gids = [];
			gauntlet_available_names = [];
			var no_gauntlets_done:Bool = true;
			//for (gid in R. gauntlet_manager.gauntlet_IDs) {
			for (gid in []) {
				var name:String = "";
				//var m:Map<String,Dynamic> =R.gauntlet_ manager.gauntlet_map.get(gid);
				//if (m == null) {
					//R.gauntlet_ manager.gauntlet_IDs.remove(gid);
					//continue;
				//}
				
				//var time:Int = R.gauntlet_ manager.overall_times.get(gid);
				//var time_string:String = "";
				//if (time == GauntletManager.GAUN_OVERALL_DELETED || time == GauntletManager.GAUN_OVERALL_NOT_FINISHED) {
					//if (time == GauntletManager.GAUN_OVERALL_NOT_FINISHED) {
						//continue;
					//} else {
						//time_string = "--:-- --";
					//}
				//} else {
					//time_string = R.gauntlet_manager.get_time_text(time);
				//}
				//no_gauntlets_done = false;
				
				//name = m.get("name");
				//if (name == null) {
					//name = gid+" noname";
				//}
				//gauntlet_available_names.push(name);
				
				//var items:Array<Int> = R.gauntlet_manager .gauntlet_map.get(gid).get("items");
				//var item_status:String = "";
				//if (items == null) {
					//item_status = gid + " noitems";
				//} else {
					//item_status = "/" + items.length;
					//var nr_found:Int = 0;
					//for (item_index in items) {
						//if (R.inventory.is_item_found(item_index)) {
							//nr_found++;
						//}
					//}
					//item_status = Std.string(nr_found) + item_status;
				//}
				//
				//text_choices.text += name;	
				//text_choices.text += " " + time_string;
				//text_choices.text += " " + item_status;
				//text_choices.text += "\n";	
				
				gauntlet_available_gids.push(gid);
			}
			if (no_gauntlets_done) {
				cursor_sprite.visible = false;
				text_choices.text = lookup_label(2, "gauntlet_info");
			}
			center_text(text_choices);
			cursor_sprite.x = text_choices.x - cursor_sprite.width - 2;
			cursor_sprite.y = text_choices.y - 1;
		}
		
	
		if (gauntlet_in_leg_stats) {
			update_submode_gauntlet_leg();
			return;
		}
		if (R.input.jpCANCEL ) {
			gauntlet_mode_did_reinit = false;
			cursor_sprite.visible = true;
			//text_choices.alignment = FlxBitmapText.ALIGN_CENTER;
			set_choices_text();
			mode = MODE_CHOICES;
			return_cursor_sprite_to_default();
		} else if (R.input.jpPause) {
			cursor_sprite.visible = true;
			begin_to_exit = true;
			gauntlet_mode_did_reinit = false;
			//text_choices.alignment = FlxBitmapText.ALIGN_CENTER;
		} else if (R.input.jpCONFIRM) {
			if (gauntlet_available_names.length == 0) {
				return;
			}
			gauntlet_in_leg_stats = true;
			text_choices.text = "";
			text_choices.text += lookup_label(1, "gauntlet_info")+": "+gauntlet_available_names[gauntlet_selector_idx]+"\n";
			//var the_times:Array<Int> = R.gauntlet_manager.times.get(gauntlet_available_gids[gauntlet_selector_idx]);
			var the_times:Array<Int> = [];
			for (i in 0...the_times.length) {
				//text_choices.text += Std.string(i + 1) + ". " + R.gauntlet_manager.get_time_text(the_times[i]) + "\n";
			}
			if (the_times.length == 0) {
				
				text_choices.text += "\n" + lookup_label(0, "gauntlet_info");
			}
		} else if (R.input.jpDown) {
			if (gauntlet_selector_idx < gauntlet_available_gids.length - 1) {
				gauntlet_selector_idx ++;
				cursor_sprite.y += C.ALIPH_FONT_h;
			}
		} else if (R.input.jpUp) {
			if (gauntlet_selector_idx > 0) {
				gauntlet_selector_idx --;
				cursor_sprite.y -= C.ALIPH_FONT_h;
			}
		}
	}
	
	private var did_init_aliph_inventory:Bool = false;
	private var mode_aliph_inv_cursor_idx:Int = 0;
	private var in_submode_item_area:Bool = false;
	private var sm_item_area_max_per_page:Int = 3;
	private var sm_item_area_cur_page:Int = 0;
	private var sm_item_area_listings:Array<String>;
	
	private function update_submode_item_area_display():Void {
		if (R.input.jpCANCEL) {
			in_submode_item_area = false;
			set_choices_caps_label(0, choices_for_inventory);
			text_extra.text = " ";
		}
		
		if (R.input.jpLeft || R.input.jpUp) {
			if (sm_item_area_cur_page > 0) {
				sm_item_area_cur_page --;
				submode_item_area_change_text();
			}
		} else if (R.input.jpRight || R.input.jpDown) {
			if (sm_item_area_cur_page < Std.int(sm_item_area_listings.length / sm_item_area_max_per_page) ) {
				sm_item_area_cur_page ++ ;
				submode_item_area_change_text();
			}
		}
	}
	private function submode_item_area_change_text():Void {
		text_choices.text = "";
		text_extra.text = "";
		text_extra.alignment = "right";
		
		for (i in 0...sm_item_area_listings.length) {
			var word:String = sm_item_area_listings[i];
			if (i >= sm_item_area_max_per_page * sm_item_area_cur_page && i < sm_item_area_max_per_page * (1 + sm_item_area_cur_page)) {
				var parts:Array<String> = word.split(":");
				text_extra.text += parts[0] + ":\n";
				text_choices.text += parts[1] + "\n";
			}
			if (i == sm_item_area_listings.length - 1) {
				var j:Int = i + 1;
				for (k in j...sm_item_area_max_per_page*(1+sm_item_area_cur_page)) {
					text_extra.text += "\n";
					text_choices.text += "\n";
				}
			}
		}
		
		if (sm_item_area_listings.length == 0) {
			text_extra.text = "No Items!";
		}
		
		text_extra.x = 200 - text_extra.width;
		text_choices.x = 200;
		text_extra.y = (FlxG.height - text_extra.height) / 2;
		text_choices.y = text_extra.y;
		if (sm_item_area_listings.length == 0) {
			return;
		}
		text_choices.text += "\n" + lookup_label(0, "misc")+": "+Std.string(sm_item_area_cur_page+1)+"/"+Std.string(1+Std.int(sm_item_area_listings.length / sm_item_area_max_per_page)); // Page
	}
	
	private var cur_inventory_row:Int = 0;
	private var inv_row_indctrs:FlxTypedGroup<FlxSprite>;
	private var inv_row_slctr:FlxSprite;
	private function update_mode_aliph_inventory():Void {
		if (did_init_aliph_inventory == false) {
			did_init_aliph_inventory = true;
			//text_choices.visible = true;
			cursor_sprite.exists = true;
			text_extra.exists = true;
			text_extra.text = R.dialogue_manager.lookup_sentence("ui", "item_labels", items_You_have[cur_inventory_row * 5 + mode_aliph_inv_cursor_idx]);
			text_extra.y = 210;
			text_extra.x = (C.GAME_WIDTH - text_extra.width) / 2;
			
			cursor_sprite.alpha = 1;
			//set_choices_caps_label(0, choices_for_inventory);
		}
		
		if (text_choices.alpha > 0) {
			text_choices.alpha -= 0.045; text_choices.alpha *= 0.95;
			if (text_choices.alpha < 0.05) text_choices.alpha = 0;
			//text_extra.alpha = text_submenu_title.alpha = 1 - text_choices.alpha;
			text_extra.alpha = 1 - text_choices.alpha;
			inv_row_slctr.alpha = text_extra.alpha;
			inv_row_indctrs.setAll("alpha", inv_row_slctr.alpha);
		} 
		
		if (dialogue_box.is_active()) {
			return;
		}
		
		if (do_item_enter_anim) {
			update_inventory_enter_anim();
			cursor_sprite.x = active_item_images.members[mode_aliph_inv_cursor_idx].x - 2 - cursor_sprite.width;
			cursor_sprite.y = active_item_images.members[mode_aliph_inv_cursor_idx].y + 16 - cursor_sprite.height / 2;
			return;
		}
		
		// Exit
		if (R.input.jpPause || R.input.jpCANCEL) {
			did_init_aliph_inventory = false;
			mode_aliph_inv_cursor_idx = 0;
			cur_inventory_row = 0;
			do_item_exit_anim = true;
			reset_cursor_on_return_from_submenu = true;
			cursor_sprite.alpha = 0;
		}
		
		if (R.input.jpPause) {
			R.sound_manager.play(SNDC.menu_close);
			text_extra.text = " ";
			begin_to_exit = true;
			inv_row_indctrs.exists = inv_row_slctr.exists = false;
		} else if (R.input.jpCANCEL) {
			R.sound_manager.play(SNDC.menu_cancel);
			set_choices_text();
			mode = MODE_CHOICES;
		} else if (R.input.jpCONFIRM) {
			R.sound_manager.play(SNDC.menu_confirm);
			if (active_item_images.members[mode_aliph_inv_cursor_idx].exists) {
				//Log.trace(cur_inventory_row * 5 + mode_aliph_inv_cursor_idx);
				dialogue_box.next_additional_scripts = [];
				dialogue_box.next_additional_scripts.push(["center_down"]);
				dialogue_box.next_additional_scripts.push(["pic","Cloaked_Humus"]);
				dialogue_box.start_dialogue("ui", "items", items_You_have[cur_inventory_row * 5 + mode_aliph_inv_cursor_idx]);
			}
		} else if (R.input.jpUp) {
			R.sound_manager.play(SNDC.menu_move);
			if (mode_aliph_inv_cursor_idx < 5) {
				if (cur_inventory_row > 0) {
					cur_inventory_row--;
					set_items_view(cur_inventory_row);
				}
			} else {
				mode_aliph_inv_cursor_idx -= 5;
			}
		} else if (R.input.jpDown) {
			R.sound_manager.play(SNDC.menu_move);
			if (mode_aliph_inv_cursor_idx > 9) {
				// cur top row
				if (cur_inventory_row < max_item_rows - 3) {
					cur_inventory_row++;
					set_items_view(cur_inventory_row);
				}
			} else {
				mode_aliph_inv_cursor_idx += 5;
				
			}
		} else if (R.input.jpLeft) {
			R.sound_manager.play(SNDC.menu_move);
			if (mode_aliph_inv_cursor_idx % 5 != 0) {
				mode_aliph_inv_cursor_idx--;
			}
		} else if (R.input.jpRight) {
			R.sound_manager.play(SNDC.menu_move);
			if (mode_aliph_inv_cursor_idx % 5 != 4) {
				mode_aliph_inv_cursor_idx ++;
			}
		}

		var dest_y:Float = inv_row_indctrs.members[cur_inventory_row].y;
		//if (inv_row_slctr.ID == 0) {
			//if (inv_row_slctr.y < dest_y) {
				//inv_row_slctr.velocity.y = 20;
				//inv_row_slctr.ID = 1;
				//invdesty = dest_y;
			//} else if (inv_row_slctr.y > dest_y) {
				//inv_row_slctr.velocity.y = -20;
				//inv_row_slctr.ID = 2;
				//invdesty = dest_y;
			//} 
		//} else if (inv_row_slctr.ID == 1) {
			//if (inv_row_slctr.y > dest_y) {
				//if (dest_y == invdesty) {
					//inv_row_slctr.y = dest_y; inv_row_slctr.ID = 0;
					//inv_row_slctr.velocity.y = 0;
				//} else {
					//inv_row_slctr.velocity.y *= -1;
					//inv_row_slctr.ID = 2;
				//}
			//} else {
				//inv_row_slctr.velocity.y *= 1.2;
			//}
			//invdesty = dest_y;
		//} else if (inv_row_slctr.ID == 2) {
			//if (inv_row_slctr.y < dest_y) {
				//if (dest_y == invdesty) {
					//inv_row_slctr.y = dest_y; inv_row_slctr.ID = 0;
					//inv_row_slctr.velocity.y = 0;
				//} else {
					//inv_row_slctr.velocity.y *= -1;
					//inv_row_slctr.ID = 1;
				//}
			//} else {
				//inv_row_slctr.velocity.y *= 1.2;
			//}
			//invdesty = dest_y;
		//}
		//if (do_item_exit_anim) {
			//inv_row_slctr.velocity.y = 0;
		//}

		if (R.input.jpLeft || R.input.jpRight || R.input.jpUp || R.input.jpDown) {
			cursor_sprite.x = active_item_images.members[mode_aliph_inv_cursor_idx].x - 2 - cursor_sprite.width;
			cursor_sprite.y = active_item_images.members[mode_aliph_inv_cursor_idx].y + 16 - cursor_sprite.height / 2;
			if (active_item_images.members[mode_aliph_inv_cursor_idx].exists == true) {
				text_extra.text = R.dialogue_manager.lookup_sentence("ui", "item_labels", items_You_have[cur_inventory_row * 5 + mode_aliph_inv_cursor_idx]);
				text_extra.x = (C.GAME_WIDTH - text_extra.width) / 2;
			} else {
				text_extra.text = " ";
			}
		}
	}
	
	private var modepick_idx:Int = 0;
	private function update_submode_modepick():Void {
		
		if (FROM_TITLE_AND_MAINMENU) { // skip choosing game mode
			modepick_idx = 6;
		}
		
		if (modepick_idx == 1) {
			// make sure...
			dialogue_box.start_dialogue("ui", "game_mode_pick", 4);
			modepick_idx = 2;
		} else if (modepick_idx == 2) {
			if (dialogue_box.is_active() == false) {
				// you've chosen.. (yn)
				dialogue_box.start_dialogue("ui", "game_mode_pick", submode_speedrun_selector_idx);
				modepick_idx = 3;
			}
		} else if (modepick_idx == 3) {
			if (dialogue_box.last_yn != -1) {
				if (dialogue_box.last_yn == 0) { // no
					modepick_idx = 0;
				} else {
					modepick_idx = 4;
					R.story_mode = R.gauntlet_mode = false;
					switch (submode_speedrun_selector_idx) {
						case 0: // regular
						case 1: // story
							R.story_mode = true;
							R.gauntlet_mode = false;
						case 2:
							R.story_mode = false;
							R.gauntlet_mode = true;
						case 3: // warp
							// something else
					}
					Log.trace(["Chosen modes", "story/gauntlet", R.story_mode, R.gauntlet_mode]);
				}
			}
		} else if (modepick_idx == 4) {
			//
			if (dialogue_box.is_active() == false) {
				if (submode_speedrun_selector_idx == 3) { // warp mode, bring up warp ui
					modepick_idx = 10;
					R.warpModule.init();
					R.warpModule.activate(false,dialogue_box);
					add(R.warpModule);
					remove(dialogue_box, true);
					add(dialogue_box);
				} else {
					modepick_idx = 5;
				}
			}
		} else if (modepick_idx == 10) {
			if (R.warpModule.is_done()) {
				R.inwarpmode = 1;
				R.warpModule.deactivate();
				remove(R.warpModule, true);
				modepick_idx = 5;
			}
		} else if (modepick_idx == 5) { // now that you've,... please take a brief moment to look over..
			dialogue_box.start_dialogue("ui", "game_mode_pick", 5);
			modepick_idx = 6;
		} else if (modepick_idx == 6) {
			if (dialogue_box.is_active() == false) {
				in_mode_pick = false;
				modepick_idx = 0;
				set_settings_menu_text(settings_idx);
				submode_speedrun_did_init = false;
				submode_speedrun_selector_idx = 0;
				set_cursor_sprite(text_choices, settings_idx);
				update_subtitle_text();
				text_extra.text = " ";
				return;
			}
		}
		if (modepick_idx != 0) {
			return;
		}
		
		
		
		
		if (!submode_speedrun_did_init) {
			modepick_idx = 0;
			submode_speedrun_text_options = [];
			//full, story, gauntlet, warp
			submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "game_modes", 0));
			submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "game_modes", 1));
			submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "game_modes", 2));
			submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "game_modes", 3));
			text_choices.alignment = "left";
			text_choices.x = 16;
			text_choices.y = (FlxG.height - (header_strip.y + header_strip.height)) / 2;
			text_choices.y += header_strip.y + header_strip.height;
			submode_speedrun_selector_idx = 0;
			text_choices.text = submode_speedrun_text_options.join("\n");
			text_choices.y -= text_choices.height / 2;
			set_cursor_sprite(text_choices, submode_speedrun_selector_idx);
		}
		
		if (R.input.jpDown) {
			if (submode_speedrun_selector_idx < submode_speedrun_text_options.length - 1) {
				submode_speedrun_selector_idx++;
				set_cursor_sprite(text_choices, submode_speedrun_selector_idx);
				R.sound_manager.play(SNDC.menu_move);
			}
		} else if (R.input.jpUp) {
			if (submode_speedrun_selector_idx > 0) {
				submode_speedrun_selector_idx--;
				set_cursor_sprite(text_choices, submode_speedrun_selector_idx);
				R.sound_manager.play(SNDC.menu_move);
			}
		}
		if (R.input.jpDown || R.input.jpUp || !submode_speedrun_did_init) {
			R.dialogue_manager.FORCE_LINE_SIZE = Std.int((C.ALIPH_FONT_w * 34) / text_extra.font.spaceWidth);
			
			if (R.dialogue_manager.is_chinese()) R.dialogue_manager.FORCE_LINE_SIZE = 19;
			text_extra.text = R.dialogue_manager.lookup_sentence("ui", "game_mode_desc", 4) + "\n";
			text_extra.text += R.dialogue_manager.lookup_sentence("ui", "game_mode_desc", submode_speedrun_selector_idx);
			R.dialogue_manager.FORCE_LINE_SIZE = -1;
			text_extra.y = text_choices.y - 50;
			text_extra.x = text_choices.x + text_choices.width + 16;
			text_extra.alignment = "left";
			text_extra.lineSpacing = 2;
			if (R.dialogue_manager.get_langtype() == DialogueManager.LANGTYPE_DE || R.dialogue_manager.get_langtype() == DialogueManager.LANGTYPE_ES ) {
				text_extra.lineSpacing = 0;
				text_extra.y = text_choices.y - 80;
			}
			text_extra.visible = text_extra.exists = true;
			text_extra.alpha = 1;
			if (!submode_speedrun_did_init) {
				submode_speedrun_did_init = true;
			}
		}
		
		
		
		if (R.input.jpCONFIRM) {
			modepick_idx = 1;
			
		}
		return;
	}
	
	private var invdesty:Float = 0;
	private function return_cursor_sprite_to_default():Void {
		cursor_sprite.y = text_choices.y + MODE_CHOICES_idx * (text_choices.lineHeight + text_choices.lineSpacing);
		if (R.dialogue_manager.is_chinese()) cursor_sprite.y += 6;
		if (R.dialogue_manager.is_other()) cursor_sprite.y += 2;
		cursor_sprite.x = text_choices.x - cursor_sprite.width - 2;
	}
	private var settings_idx:Int = 0;
	private var settings_choice_ids:Array<Int>;
	private var in_volume:Bool = false;
	private var in_keys:Bool = false;
	private var in_sound:Bool = false;
	private var in_scaling:Bool = false;
	private var in_window_scaling:Bool = false;
	private var old_scaleval:String = "";
	private var in_speedrun_options:Bool = false;
	private var in_language_options:Bool = false;
	private var in_access_opts:Bool = false;
	private var in_joy_config:Bool = false;
	private var joy_config_state:Int = 0;
	private var in_mode_pick:Bool = false;
	private function init_settings():Void {
		// If desktop...
		settings_choice_ids = [0, 1, 3,12, 4, 5, 6, 7, 8, 9];
		if (FROM_TITLE) {
			settings_choice_ids.push(11);
		}
	}
	private function set_cursor_sprite(rel_tex:FlxBitmapText, index:Int):Void {
		cursor_sprite.x = rel_tex.x - cursor_sprite.width -2;
		cursor_sprite.y = rel_tex.y + index * (rel_tex.lineHeight + rel_tex.lineSpacing);
		if (R.dialogue_manager.is_chinese()) {
			cursor_sprite.y += 7;
		} else if (R.dialogue_manager.is_other()) {
			cursor_sprite.y += 2;
		}
	}
	private function update_mode_settings():Void {
		
		if (in_mode_pick) {
			update_submode_modepick();
			return;
		}
		
		if (in_confirm_settings) {
			if (FROM_TITLE_AND_MAINMENU) { // skip the confirmationd ialogue
				FROM_TITLE_AND_MAINMENU = false;
				dialogue_box.ID = 2;
			}
			if (dialogue_box.ID == 2) {
				if (!dialogue_box.is_active()) {
					R.input.jpPause = true;
					FROM_TITLE = false;
					in_confirm_settings = false;
					dialogue_box.ID = 0;
				} else {
					return;
				}
			} else if (dialogue_box.ID == 1) {
				if (dialogue_box.last_yn == 1) {
					dialogue_box.ID = 2;
				} else if (dialogue_box.last_yn == 0) {
					in_confirm_settings = false;
					dialogue_box.ID = 0;
				}
				return;
			} else {
				dialogue_box.ID = 1;
				dialogue_box.start_dialogue("intro", "cloak", 13);
				return;
			}
		}
		if (in_joy_config) {
			if (joy_config_state == 0) {
				dialogue_box.start_dialogue("ui", "controller_flip", 0);
				//add(R.joy_module);
				//R.joy_module.activate(dialogue_box);
				joy_config_state = 1;
			} else if (joy_config_state == 1) {
				if (dialogue_box.last_yn == 0) {
					R.input.joy_reverse = false;
					in_joy_config = false;
				} else if (dialogue_box.last_yn == 1) {
					R.input.joy_reverse = true;
					in_joy_config = false;
				}
				if (!in_joy_config) {
					if (R.input.joy_reverse) {
						R.input.a1_joy = true; // So we don't get an automatic jp_a1 and cancel out
					}
					joy_config_state = 0;
					set_choices_text(); // re-update the controller text
					set_settings_menu_text(0); // realign? 
					set_cursor_sprite(text_choices, settings_idx);
					text_humus.text = R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 10, false, true);
					if (R.dialogue_manager.is_chinese()) {
						text_humus.text = StringTools.replace(text_humus.text, "\n", " ");
					}
					text_humus.x = C.GAME_WIDTH - text_humus.width - 4;
				}
				//if (R.joy_module.is_done()) {
					//joy_config_state = 0;
					//in_joy_config = false;
					//remove(R.joy_module, true);
				//}
			}
			return;
		}
		if (in_language_options) {
			
			// ID here is being used to keep track of which phase of font updates has been done
			// This was really stupid in retrospect
			// NEEDED_FONT_UPDATES is the # of font updates needed (see update_update_font lol)
			if (cursor_sprite.ID > 690) {
				var i:Int = C.num_langs;
				text_choices.text = "";
				R.dialogue_manager.update_update_font(cursor_sprite.ID - 691);
				//Log.trace(cursor_sprite.ID);
				
				// Determines the visual order of the languages
				var langArray:Array<Int> = [0, 2,3];
				for (j in 0...i) {
					// Shows progress bc jp/etc langs are longer than english
					if (R.dialogue_manager.get_langtype() == 4) {
					
					} else if (R.dialogue_manager.get_langtype() > 0) {
						text_choices.text += R.dialogue_manager.lookup_sentence("ui", "languages", langArray[j] + 1) + (langArray[j] == R.dialogue_manager.get_langtype() ?  " " + Std.string(Std.int(100 * ((cursor_sprite.ID - 690 ) / R.dialogue_manager.NEEDED_FONT_UPDATES))) + "%" : "") +"\n";
					}
				}
				cursor_sprite.ID ++;
				if (cursor_sprite.ID - 691 == R.dialogue_manager.NEEDED_FONT_UPDATES) {
					cursor_sprite.ID = 690;
					update_subtitle_text();
					
					text_humus.text = R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 10, false, true);
					if (R.dialogue_manager.is_chinese()) {
						text_humus.text = StringTools.replace(text_humus.text, "\n", " ");
					}
					text_humus.y = C.GAME_HEIGHT - text_humus.height - 4;
					text_humus.x = C.GAME_WIDTH - text_humus.width - 4;
					text_area.text = " ";
				}
				return;
			}
			
			if (cursor_sprite.ID == -1) {
				cursor_sprite.ID = 0;
				
				var i:Int = C.num_langs;
				
				var langArray:Array<Int> = [0, 2, 3,4,5];
				text_choices.text = "";
				for (j in 0...i) {
					text_choices.text += R.dialogue_manager.lookup_sentence("ui", "languages", langArray[j] + 1) + "\n";
				}
			}
			/* This works, but need to update menu labels somehow */
			if (R.input.jpDown && cursor_sprite.ID < Std.int(text_choices.height/(text_choices.lineHeight+text_choices.lineSpacing)) - 1) {
				R.sound_manager.play(SNDC.menu_move);
				cursor_sprite.ID++;
				set_cursor_sprite(text_choices, cursor_sprite.ID);
			} else if (R.input.jpUp && cursor_sprite.ID > 0) {
				R.sound_manager.play(SNDC.menu_move);
				cursor_sprite.ID--;
				set_cursor_sprite(text_choices, cursor_sprite.ID);
			} else if (R.input.jpCONFIRM) {
				R.sound_manager.play(SNDC.menu_confirm);
				switch (cursor_sprite.ID) {
					case 0:
						R.dialogue_manager.set_language(DialogueManager.LANGTYPE_EN,true);
					case 1:
						R.dialogue_manager.set_language(DialogueManager.LANGTYPE_ZH_SIMP, true);
					case 2:
						R.dialogue_manager.set_language(DialogueManager.LANGTYPE_DE, true);
					case 3:
						R.dialogue_manager.set_language(DialogueManager.LANGTYPE_RU, true);
					case 4:
						R.dialogue_manager.set_language(DialogueManager.LANGTYPE_ES, true);
				}
				if (R.dialogue_manager.NEED_TO_UPDATE_FONT) {
					// Go to top of function and update stuff
					cursor_sprite.ID = 691;
				} else {
					// Exit the menu
					cursor_sprite.ID = 690;
				}
			}
			if (R.input.jpCANCEL || cursor_sprite.ID == 690) {
				in_language_options = false;
				R.sound_manager.play(SNDC.menu_cancel);
				set_settings_menu_text(settings_idx);
				set_cursor_sprite(text_choices, settings_idx);
			}
			return;
		}
		if (in_keys) {
			if (update_submode_set_keybindings()) {
				in_keys = false;
			}
			return;
		}
		if (in_speedrun_options) {
			if (update_submode_speedrun_options()) { 
				set_cursor_sprite(text_choices, settings_idx);
			}
			return;
		}
		if (in_access_opts) {
			if (update_submode_access_opts()) {
				set_cursor_sprite(text_choices, settings_idx);
			}
			return;
		}
		if (R.input.jpPause && !in_scaling && !in_window_scaling && !FROM_TITLE) {
			R.sound_manager.play(SNDC.menu_close);
			in_volume = false;
			in_sound = false;
			in_keys = false;
			begin_to_exit = true;
			settings_idx = 0;
		} 
		if (in_volume || in_sound) {
			var del:Float = 0;
			if (R.input.jpCANCEL) {
				R.sound_manager.play(SNDC.menu_cancel);
				in_volume = in_sound = false;
			} else if (R.input.jpLeft) {
				del = -0.1;
			} else if (R.input.jpRight) {
				del = 0.1;
			}
			if (del != 0) {
				R.sound_manager.play(SNDC.menu_move);
			if (in_volume) {
				R.song_helper.set_volume_modifier(R.song_helper.get_volume_modifier() + del);
			} else {
				R.sound_manager.set_volume_modifier(R.sound_manager.get_volume_modifier() +del);
			}
			set_settings_menu_text(settings_idx);
			}
			return;
		}
		
		if (in_scaling) {
			// Change text back to previous
			if (R.input.jpCANCEL) {
				R.sound_manager.play(SNDC.menu_cancel);
				ProjectClass.scale_type = old_scaleval;
				in_scaling = false;
				set_settings_menu_text(settings_idx);
			// Immediately change if in fullscreen
			} else if (R.input.jpCONFIRM) {
				R.sound_manager.play(SNDC.menu_confirm);
				in_scaling = false;
				if (StageDisplayState.FULL_SCREEN_INTERACTIVE == Lib.current.stage.displayState) {
					ProjectClass.TOGGLE_LETTERBOXING = true;
				}
			// change scale type from 0,1,...0,n 1,0 2,0
			} else if (R.input.jpLeft) {
				R.sound_manager.play(SNDC.menu_move);
				var st0:Int = Std.parseInt(ProjectClass.scale_type.split(",")[0]);
				var st1:Int = Std.parseInt(ProjectClass.scale_type.split(",")[1]);
				
				if (st0 == 0) {
					if (st1 > 1) {
						ProjectClass.scale_type = "0," + Std.string(st1-1);
					}
				} else if (st0 == 1) {
					ProjectClass.scale_type = "0," + Std.string(ProjectClass.max_int_scale);
				} else if (st0 == 2) {
					ProjectClass.scale_type = "1,0";
				}
				set_settings_menu_text(settings_idx);
			} else if (R.input.jpRight) {
				R.sound_manager.play(SNDC.menu_move);
				var st0:Int = Std.parseInt(ProjectClass.scale_type.split(",")[0]);
				var st1:Int = Std.parseInt(ProjectClass.scale_type.split(",")[1]);
				if (st0 == 0) {
					if (st1 < ProjectClass.max_int_scale) {
						ProjectClass.scale_type = "0," + Std.string(st1+1);
					} else {
						ProjectClass.scale_type = "1,0";
					}
				} else if (st0 == 1) {
					ProjectClass.scale_type = "2,0";
				}
				set_settings_menu_text(settings_idx);
			}
			
			return;
		}
		if (in_window_scaling) {
			if (R.input.jpCONFIRM) {
				if (StageDisplayState.NORMAL == Lib.current.stage.displayState) {
					FlxG.resizeWindow(416*ProjectClass.window_scale_type, 256*ProjectClass.window_scale_type);
					FlxG.resizeWindow(416 * ProjectClass.window_scale_type, 256 * ProjectClass.window_scale_type);
				}
				in_window_scaling = false;
			} else if (R.input.jpCANCEL) {
				in_window_scaling = false;
				ProjectClass.window_scale_type = Std.parseInt(old_scaleval);
				set_settings_menu_text(settings_idx);
			} else if (R.input.jpRight) {
				R.sound_manager.play(SNDC.menu_move);
				if (ProjectClass.window_scale_type < ProjectClass.max_int_scale) {
					ProjectClass.window_scale_type++;
				}
				set_settings_menu_text(settings_idx);
			} else if (R.input.jpLeft) {
				R.sound_manager.play(SNDC.menu_move);
				if (ProjectClass.window_scale_type > 1) {
					ProjectClass.window_scale_type--;
				}
				set_settings_menu_text(settings_idx);
			}
			return;
		}
		
		if (R.input.jpUp) {
			R.sound_manager.play(SNDC.menu_move);
			var max_idx:Int = choices_for_text_settings.length -1;
			if (settings_idx > 0) {
				settings_idx --;
			} else {
				settings_idx = max_idx;
			}
			set_cursor_sprite(text_choices, settings_idx);
			if (FROM_TITLE && settings_idx == max_idx && !R.dialogue_manager.is_chinese()) {
				settings_idx++;
				cursor_sprite.alpha = 1;
				set_cursor_sprite(text_choices, settings_idx);
				settings_idx--;
			}
		} else if (R.input.jpDown) {
			R.sound_manager.play(SNDC.menu_move);
			var max_idx:Int = choices_for_text_settings.length -1;
			if (settings_idx < max_idx) {
				settings_idx ++;
			} else {
				settings_idx = 0;
			}
			set_cursor_sprite(text_choices, settings_idx);
			if (FROM_TITLE && settings_idx == max_idx && !R.dialogue_manager.is_chinese()) {
				settings_idx++;
				set_cursor_sprite(text_choices, settings_idx);
				settings_idx--;
			}
		} else if (R.input.jpCANCEL && !R.input.jpPause && (FROM_TITLE_AND_MAINMENU || !FROM_TITLE)) {
			if (FROM_TITLE_AND_MAINMENU) {
				in_confirm_settings = true;
			} else {
				R.sound_manager.play(SNDC.menu_cancel);
				set_choices_text();
				mode = MODE_CHOICES;
				return_cursor_sprite_to_default();
			}
		} else if (R.input.jpCONFIRM && !R.input.jpPause) {
			var choice_id:Int = settings_choice_ids[settings_idx];
			
			if (choice_id == 11 && FROM_TITLE_AND_MAINMENU) { // skip extra sfx
				
			} else {
				R.sound_manager.play(SNDC.menu_confirm);
			}
			
			if (choice_id == 0) { // Music Volume
				in_volume = true;
			} else if (choice_id == 1) { // Sfx volum
				in_sound = true;
			} else if (choice_id  == 2) { // change res
				FlxG.cameras.flash(0xffff0000, 0.5); // Not done yet...
			} else if (choice_id  == 3) { // scaling toggle
				// Note: arrow selector code is in draw()
				in_scaling = true;
				old_scaleval = ProjectClass.scale_type;
			} else if (choice_id == 4) { // fullscreen on
				ProjectClass.FORCE_FULLSCREEN_FLIP = true;
			} else if (choice_id == 5) { // Keyboard bindings
				
				in_keys = true;
				cursor_sprite.visible = true;
				new_keybindings = [];
				for (keybind in R.input.keybindings) {
					new_keybindings.push(keybind);
				}
				submode_keybindings_idx = 100;
				
				submode_keybindings_help_string = lookup_label(3, "control_help",true);
				
			} else if (choice_id == 6) { // joypad bindings
				if (FlxG.gamepads.lastActive != null) {
					in_joy_config = true;
					Log.trace("Entering joypad config.");
				} else {
					R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
					Log.trace("No joypad connected.");
				}
				//FlxG.cameras.flash(0xffff0000, 0.5); // Not done yet
			} else if (choice_id == 7) { // language 
				in_language_options = true;
				
				cursor_sprite.ID = -1;
				set_cursor_sprite(text_choices, 0);
				
				
			} else if (choice_id == 8) { // Speedrun options
				in_speedrun_options = true;
			} else if (choice_id == 9) {
				in_access_opts = true;
			} else if (choice_id == 11) {
				in_confirm_settings = true;
			} else if (choice_id == 12) {
				in_window_scaling = true;
				old_scaleval = Std.string(ProjectClass.window_scale_type);
			}
		}
	}
	private var in_confirm_settings:Bool = false;
	private var a_indices:Array<Int>;
	
	private function update_submode_access_opts():Bool {
		var b:Bool = false;
		if (!submode_speedrun_did_init) {
			submode_speedrun_did_init = true;
			submode_speedrun_text_options = [];
			a_indices = [0, 1, 2, 3, 5, 7, 8, 9,  11, 13, 14,15,17];
			//a_indices = [0, 1, 2, 3, 4, 5, 8, 9, 11, 13, 14];
			
			// If hav eitem 30
			if (R.inventory.is_item_found(30)) {
				a_indices.push(12);
				a_indices.push(16);
				//submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "access_opts", 12));
			}
			for (i in a_indices) {
				submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "access_opts", i,true,true));
			}
			text_choices.alignment = "left";
			text_extra.alignment = "left";
			text_extra.exists = true; text_extra.alpha = 1;	
			
			text_choices.x = 24;
			text_choices.y = header_strip.y + header_strip.height + 4;
			text_extra.x = text_choices.x + text_choices.width + 8;
			text_extra.y = text_choices.y;
			b = true;
			if (R.dialogue_manager.is_chinese()) {
				text_humus.alpha = 0;
			}
		}
		if (R.input.jpDown) {
			
				R.sound_manager.play(SNDC.menu_move);
			if (submode_speedrun_selector_idx < a_indices.length - 1) {
				submode_speedrun_selector_idx++;
			} else {
				submode_speedrun_selector_idx = 0;
			}
		} else if (R.input.jpUp) {
				R.sound_manager.play(SNDC.menu_move);
			if (submode_speedrun_selector_idx > 0) {
				submode_speedrun_selector_idx--;
			} else {
				submode_speedrun_selector_idx = a_indices.length - 1;
			}
		}
		if (R.input.jpCANCEL) {
				R.sound_manager.play(SNDC.menu_cancel);
			set_settings_menu_text(settings_idx);
			submode_speedrun_did_init = false;
			submode_speedrun_selector_idx = 0;
			in_access_opts = false;
			text_extra.text = " ";
			if (R.dialogue_manager.is_chinese()) {
				text_humus.alpha = 1;
			}
			return true;
		}
		
		var idx_fps:Int = 7;
		if (R.input.jpCONFIRM || b || R.input.jpDown || R.input.jpUp) {
			text_choices.text = "";
//No Screen Flashes, No Screen Shakes, Float,3No Dying,Faint BG,"Puzzle" Skip,6No swear, FPS, SFX caption
//9 Helper tiles // 10 more helper tiles // 11 half-dmg  // 13 ass
			
			if (R.input.jpCONFIRM) {
				R.sound_manager.play(SNDC.menu_confirm);
				R.access_opts[a_indices[submode_speedrun_selector_idx]] = !R.access_opts[a_indices[submode_speedrun_selector_idx]];
				FlxCamera.no_shake = R.access_opts[1];
				CameraFrontEnd.no_flash = R.access_opts[0];
				if (a_indices[submode_speedrun_selector_idx] == 4) {
					R.TEST_STATE.load_bgs();
				}
				// Reset acceleration if quitting float mode and accel is zero
				if (a_indices[submode_speedrun_selector_idx] == 2 && R.access_opts[2] == false && R.player.acceleration.y == 0) {
					R.player.acceleration.y = 560;
				}
				if (a_indices[submode_speedrun_selector_idx] == 16) {
					if (R.access_opts[16] == false) {
						R.TEST_STATE.area_map.turn_off();
					} else {
						R.TEST_STATE.area_map.turn_on(R.TEST_STATE);
					}
				}
				if (R.access_opts[idx_fps]) {
					FlxG.drawFramerate = 30;
				} else {
					FlxG.drawFramerate = 60;
				}
				
				if (a_indices[submode_speedrun_selector_idx]== 9) {
					HelpTilemap.difficulty_tiles_on(Registry.R.TEST_STATE);
				}
			}
			
			for (i in 0...a_indices.length) {
				var okay:String = submode_speedrun_text_options[i];
				text_choices.lineSpacing = 1;
				text_choices.text += (R.access_opts[a_indices[i]] ? "[x] " : "[ ] ") + okay + "\n";
				
			}
			//text_choices.text += "\n" + R.dialogue_manager.lookup_sentence("ui", "speedrun_options", 4);
			//text_choices.text += "\n";
			
			text_choices.x = 24;
			text_choices.y = header_strip.y + header_strip.height + 8;
			if (R.dialogue_manager.is_chinese()) text_choices.y -= 5;
			text_extra.x = text_choices.x + text_choices.width + 8;
			text_extra.y = text_choices.y + 16;
			
			
			// Used to push up the text if needed
			if (R.dialogue_manager.is_chinese()) {
				if (submode_speedrun_selector_idx > 10) {
					//text_choices.y -= text_choices.lineHeight * (submode_speedrun_selector_idx - 10);
				}
			}
			
			set_cursor_sprite(text_choices, submode_speedrun_selector_idx);

		}
		
		if (R.input.jpDown || R.input.jpUp || b) {
			R.dialogue_manager.FORCE_LINE_SIZE = Std.int((C.ALIPH_FONT_w * 25) / text_extra.font.spaceWidth);
			text_extra.text = R.dialogue_manager.lookup_sentence("ui", "access_opts_desc", a_indices[submode_speedrun_selector_idx]);
			R.dialogue_manager.FORCE_LINE_SIZE = -1;
			//text_extra.y = text_choices.y + text_choices.height + 4;
			//text_extra.x = FlxG.width / 2 - text_extra.width / 2;
			//text_extra.alignment = "left";
		}
		
		return false;
		
	}
	
	private var submode_speedrun_idx:Int = 0;
	private var submode_speedrun_selector_idx:Int = 0;
	private var submode_speedrun_text_options:Array<String>;
	private var submode_speedrun_did_init:Bool = false;
	private var speedIndices:Array<Int>;
	
	private function update_submode_speedrun_options():Bool {
		
		if (!submode_speedrun_did_init) {
			submode_speedrun_did_init = true;
			submode_speedrun_text_options = [];
			// Fast Text, Screen Transitions, Death Anim, Gauntlet Splits
			submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "speedrun_options", 0,true,true,true));
			submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "speedrun_options", 1,true,true,true));
			submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "speedrun_options", 2,true,true,true));
			submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "speedrun_options", 3,true,true,true));
			submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "speedrun_options", 5,true,true,true));
			submode_speedrun_text_options.push(R.dialogue_manager.lookup_sentence("ui", "speedrun_options", 6,true,true,true));
			speedIndices = [0, 1, 2, 3, 5, 6];
			text_choices.alignment = "left";
			text_choices.y = (FlxG.height - (header_strip.y + header_strip.height)) / 2;
			text_choices.y += header_strip.y + header_strip.height;
			text_choices.y -= text_choices.height / 2;
			submode_speedrun_selector_idx = 0;
			set_cursor_sprite(text_choices, submode_speedrun_selector_idx);
		}
		if (R.input.jpDown) {
			if (submode_speedrun_selector_idx < submode_speedrun_text_options.length - 1) {
				submode_speedrun_selector_idx++;
				set_cursor_sprite(text_choices, submode_speedrun_selector_idx);
				R.sound_manager.play(SNDC.menu_move);
			}
		} else if (R.input.jpUp) {
			if (submode_speedrun_selector_idx > 0) {
				submode_speedrun_selector_idx--;
				set_cursor_sprite(text_choices, submode_speedrun_selector_idx);
				R.sound_manager.play(SNDC.menu_move);
			}
		}
		text_choices.text = "";
		for (i in 0...submode_speedrun_text_options.length) {
			//submode_speedrun_text_options[i] = submode_speedrun_text_options[i].split("-").join("");
			//var okay:String = i == submode_speedrun_selector_idx ? "-" + submode_speedrun_text_options[i].toUpperCase() + "-" : submode_speedrun_text_options[i];
			var okay:String = "";
			okay = submode_speedrun_text_options[i];
			okay = (R.speed_opts[speedIndices[i]] ? "[x] " : "[ ] ") + okay + "\n";
			text_choices.text += okay;
		}
		//text_choices.text += R.dialogue_manager.lookup_sentence("ui", "speedrun_options", 4);
		
		if (R.input.jpCANCEL || R.input.jpPause) {
			//text_choices.alignment = FlxBitmapText.ALIGN_CENTER;
			set_settings_menu_text(settings_idx);
			submode_speedrun_did_init = false;
			submode_speedrun_selector_idx = 0;
			in_speedrun_options = false;
			set_cursor_sprite(text_choices, settings_idx);
			R.sound_manager.play(SNDC.menu_cancel);
		} else if (R.input.jpCONFIRM) {
			R.speed_opts[speedIndices[submode_speedrun_selector_idx]] = !R.speed_opts[speedIndices[submode_speedrun_selector_idx]];
			
			if (R.speed_opts[submode_speedrun_selector_idx]) {
				R.sound_manager.play(SNDC.menu_confirm);
			} else {
				R.sound_manager.play(SNDC.menu_cancel);
			}
		}
		return false;
	}
	private var submode_keybindings_idx:Int = 0;
	private var submode_keybindings_selector_idx:Int = 0;
	private var submode_keybindings_help_string:String = "";
	private var new_keybindings:Array<String>;
	private function update_submode_set_keybindings():Bool {
		switch (submode_keybindings_idx) {
			case 100:
			case 101:
				if (dialogue_box.is_active()) {
					return false;	
				}
				if (R.input.jpUp) {
					if (submode_keybindings_selector_idx > 0) submode_keybindings_selector_idx--;
					R.sound_manager.play(SNDC.menu_move);
					set_cursor_sprite(text_choices, submode_keybindings_selector_idx);
				} else if (R.input.jpDown) {
					if (submode_keybindings_selector_idx < 3) submode_keybindings_selector_idx++;
					R.sound_manager.play(SNDC.menu_move);
					set_cursor_sprite(text_choices, submode_keybindings_selector_idx);
					
				} else if (R.input.jpCONFIRM) {
					switch (submode_keybindings_selector_idx) {
						case 0:
							submode_keybindings_idx = 0;
							submode_keybindings_selector_idx = 0;
							submode_keybindings_help_string = "";
							set_settings_menu_text(settings_idx);
							set_cursor_sprite(text_choices, settings_idx);
							R.sound_manager.play(SNDC.menu_cancel);
							return true;
						case 1:
							// Confirm using presets
							dialogue_box.start_dialogue("ui", "keyboarddefaultmsg", 0);
							submode_keybindings_idx = 102;
						case 2:
							dialogue_box.start_dialogue("ui", "keyboarddefaultmsg", 1);
							submode_keybindings_idx = 102;
						case 3:
							R.sound_manager.play(SNDC.menu_confirm);
							set_cursor_sprite(text_choices, submode_keybindings_selector_idx);
							submode_keybindings_selector_idx = 0;
							submode_keybindings_idx = 0;
					}
				}
				
				
			case 102:
				
				if (dialogue_box.is_active()) {
					return false;	
				}
				if (dialogue_box.last_yn == 1) {
					switch (submode_keybindings_selector_idx) {
						case 1:
							R.sound_manager.play(SNDC.menu_confirm);
							R.input.setKeyProfileDefault();
							text_humus.text = R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 10, false, true);
							
						if (R.dialogue_manager.is_chinese()) {
							text_humus.text = StringTools.replace(text_humus.text, "\n", " ");
						}
						case 2:
							R.sound_manager.play(SNDC.menu_confirm);
							R.input.setKeyProfileWASD();
							text_humus.text = R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 10, false, true);
							
							if (R.dialogue_manager.is_chinese()) {
								text_humus.text = StringTools.replace(text_humus.text, "\n", " ");
							}
					}
				}
				submode_keybindings_idx = 101;
			case 0:
				if (R.input.jpCANCEL || R.input.jpPause) {
					for (i in 0...8) {
						for (j in 0...8) {
							if (i != j) {
								if (new_keybindings[i] == new_keybindings[j]) {
									submode_keybindings_help_string = lookup_label(1, "control_help");
									//FlxG.cameras.shake(0.015, 0.3, null,true, FlxCamera.SHAKE_HORIZONTAL_ONLY);
									R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);

									return false;
								}
							}
						}
					}
					for (i in 0...8) {
						R.input.keybindings[i] = new_keybindings[i];
					}
					submode_keybindings_idx = 0;
					submode_keybindings_selector_idx = 0;
					submode_keybindings_help_string = "";
					set_settings_menu_text(settings_idx);
					set_cursor_sprite(text_choices, settings_idx);
					R.sound_manager.play(SNDC.menu_cancel);
					return true;
				} else if (R.input.jpCONFIRM) {
					R.sound_manager.play(SNDC.menu_confirm);
					submode_keybindings_idx = 1;
					//cursor_sprite.angularVelocity = 90;
					submode_keybindings_help_string = lookup_label( 0,"control_help") + " " + StringTools.rtrim(lookup_label(submode_keybindings_selector_idx,"control_desc"));
				} else if (R.input.jpDown && submode_keybindings_selector_idx < 7) {
					submode_keybindings_selector_idx ++;
					R.sound_manager.play(SNDC.menu_move);
				} else if (R.input.jpUp && submode_keybindings_selector_idx > 0) {
					submode_keybindings_selector_idx -- ;
					R.sound_manager.play(SNDC.menu_move);
				}
			case 1:
				//var d:Array<FlxKey> = FlxG.keys.getIsDown();
				var d:Array<Dynamic> = FlxG.keys.getIsDown();
				
				for (dd in d) {
					if (dd.current == 2) {
						submode_keybindings_idx = 0;
						
						new_keybindings[submode_keybindings_selector_idx] = FlxG.keys.keyCodeToString(dd.ID);
						
						submode_keybindings_help_string = lookup_label(3, "control_help",true);
						R.sound_manager.play(SNDC.menu_confirm);
					}
				}
		}
		
		if ((submode_keybindings_idx == 101 && (R.input.jpUp || R.input.jpDown)) || submode_keybindings_idx == 100) {
			if (submode_keybindings_idx == 100) {
				submode_keybindings_idx = 101;
				submode_keybindings_selector_idx = 0;
				set_cursor_sprite(text_choices, submode_keybindings_selector_idx);
			}
			
			text_choices.text = "";
			text_choices.text += lookup_label(1, "keymenu", true);
			text_choices.text += "\n"+ lookup_label(2, "keymenu", true);
			text_choices.text += "\n"+ lookup_label(3, "keymenu", true);
			text_choices.text += "\n"+ lookup_label(4, "keymenu", true);
			text_choices.text += "\n\n";
			text_choices.text += lookup_label(5 + submode_keybindings_selector_idx, "keymenu", true);
		}
		
		
		if (submode_keybindings_idx == 0 || submode_keybindings_idx == 1) {
		if (R.input.jp_any() || submode_keybindings_idx == 0) {
		text_choices.alignment = "left";
		text_choices.text =  lookup_label(0, "control_desc") + "    " + new_keybindings[InputHandler.KDX_UP]+ "\n";
		text_choices.text += lookup_label(1, "control_desc") + "    " + new_keybindings[InputHandler.KDX_RIGHT]+ "\n";
		text_choices.text += lookup_label(2, "control_desc") + "    " + new_keybindings[InputHandler.KDX_DOWN] + "\n";
		text_choices.text += lookup_label(3, "control_desc") + "    " + new_keybindings[InputHandler.KDX_LEFT]+ "\n";
		text_choices.text += lookup_label(4, "control_desc") + "    " + new_keybindings[InputHandler.KDX_A1]+ "\n";
		text_choices.text += lookup_label(5, "control_desc") + "    " + new_keybindings[InputHandler.KDX_A2]+ "\n";
		text_choices.text += lookup_label(6, "control_desc") + "    " + new_keybindings[InputHandler.KDX_PAUSE] + "\n";
		text_choices.text += lookup_label(7, "control_desc") + "    " + new_keybindings[InputHandler.KDX_SIT] + "\n";
		if (R.dialogue_manager.is_chinese()) {
			text_choices.text +=  submode_keybindings_help_string + "\n";
		} else {
			text_choices.text += "\n" + submode_keybindings_help_string + "\n";
		}
		text_choices.text += lookup_label(2, "control_help",true);
		cursor_sprite.x = text_choices.x - cursor_sprite.width - 4;
		cursor_sprite.y = text_choices.y + (text_choices.lineSpacing + text_choices.lineHeight) * submode_keybindings_selector_idx;
		if (R.dialogue_manager.is_chinese()) cursor_sprite.y += 6;
		if (R.dialogue_manager.is_other()) cursor_sprite.y += 2;
		
		text_humus.text = R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 10, false, true);
							
		if (R.dialogue_manager.is_chinese()) {
			text_humus.text = StringTools.replace(text_humus.text, "\n", " ");
		} 
		}
		}
		return false;
	}
	private function center_text(bitmap_text:FlxBitmapText):Void 
	{
		bitmap_text.x = (FlxG.width - bitmap_text.width) / 2;
		bitmap_text.y = (FlxG.height - bitmap_text.height) / 2;
	}
	
	private function set_settings_menu_text(idx:Int):Void 
	{
		if (R.dialogue_manager.get_langtype() == DialogueManager.LANGTYPE_JP) {
			text_choices.lineSpacing = 2;
		} else if (R.dialogue_manager.get_langtype() == DialogueManager.LANGTYPE_ZH_SIMP) {
			text_choices.lineSpacing = 1;
		} else if (R.dialogue_manager.is_other()) {
			text_choices.lineSpacing = 1;
		} else {
			text_choices.lineSpacing = 4;
		}
		var s0:String = choices_for_text_settings[0];
		var s1:String = choices_for_text_settings[1];
		var s3:String = choices_for_text_settings[2];
		var s4:String = choices_for_text_settings[3];
		choices_for_text_settings[0] += ": " + Std.string(Math.round(R.song_helper.get_volume_modifier() * 10));
		choices_for_text_settings[1] += ": " + Std.string(Math.round(R.sound_manager.get_volume_modifier() * 10));
		
		// If in FROM_TITLE mode, always update the "press x to confirm/etc" string in case keys change
		var iidx:Int = settings_choice_ids.indexOf(11);
		if (iidx != -1) {
			choices_for_text_settings[iidx] = R.dialogue_manager.lookup_sentence("ui", "desktop_settings", 11, true, true);
		}
		
		var st0:Int = Std.parseInt(ProjectClass.scale_type.split(",")[0]);
		var st1:Int = Std.parseInt(ProjectClass.scale_type.split(",")[1]);
		if (st0 == 0) {
			choices_for_text_settings[2] += ": " + Std.string(st1) + R.dialogue_manager.lookup_sentence("ui", "scaling_options", 0, true, true);
		} else if (st0 == 1) {
			choices_for_text_settings[2] += ": " + R.dialogue_manager.lookup_sentence("ui", "scaling_options", 1, true, true);
		} else if (st0 == 2) {
			choices_for_text_settings[2] += ": " + R.dialogue_manager.lookup_sentence("ui", "scaling_options", 2, true, true);
		}
		
		choices_for_text_settings[3] += ": " + Std.string(ProjectClass.window_scale_type) + R.dialogue_manager.lookup_sentence("ui", "scaling_options", 0, true, true);
		
		
		text_choices.text = choices_for_text_settings.join("\n");
		choices_for_text_settings[0] = s0;
		choices_for_text_settings[1] = s1;
		choices_for_text_settings[2] = s3;
		choices_for_text_settings[3] = s4;
		center_text(text_choices);
		text_choices.y = header_strip.y + header_strip.height + 14;
		if (R.dialogue_manager.is_chinese() && FROM_TITLE) text_choices.y -= 34;
		text_choices.x = 32;
		//set_choices_caps_label(idx, choices_for_text_settings);
	}
	
	private var world_map_uncoverer_was_visible:Bool = false;
	private var aliph_map:WorldMapUncoverer;
	
	private function update_mode_aliph_map():Void {
		if (R.input.jpCANCEL) {
			
			if (world_map_uncoverer_was_visible == false) {
				aliph_map.make_invisible();
			}
			aliph_map.cursor.visible = false;	
			aliph_map.move_to(0, 0);
			text_choices.visible = true;
			mode = MODE_CHOICES;
			return;
		} else if (R.input.jpPause) {
			R.sound_manager.play(SNDC.menu_close);
			if (world_map_uncoverer_was_visible == false) {
				aliph_map.make_invisible();
			}
			aliph_map.cursor.visible = false;
			aliph_map.move_to(0, 0);
			begin_to_exit = true;
			return;
		}
		
		aliph_map.update_others();
		if (R.input.right && !R.input.left) {
			aliph_map.cursor.velocity.x = 50;
		} else if (R.input.left && !R.input.right) {
			aliph_map.cursor.velocity.x = -50;
		} else  {
			aliph_map.cursor.velocity.x = 0;
		}
		if (R.input.up && !R.input.down) {
			aliph_map.cursor.velocity.y = -50;
		} else if (R.input.down && !R.input.up) {
			aliph_map.cursor.velocity.y = 50;
		} else  {
			aliph_map.cursor.velocity.y = 0;
		}
		
		for (i in 0...aliph_map.doors.length) {
			var door:MySprite = cast aliph_map.doors.members[i];
			if (door.overlaps(aliph_map.cursor)) {
				text_map.text = door.name;
				text_map.x = (C.GAME_WIDTH - text_map.width) / 2;
				text_map.y = 16;
				break;
			} else {
				text_map.text = " ";
			}
		}
	
	}
	
	private var maps_per_page:Int = 9;
	private var viewing_map:Bool = false;
	private var map_pic_sprite:FlxSprite;
	private function update_mode_map():Void {
		
		if (dialogue_box.is_active() && R.worldmapplayer.equipped_map_id != 48) {
			map_pic_sprite.alpha += 0.05;
			return;
		}
		if (map_pic_sprite.ID == 20) {
			map_pic_sprite.alpha -= 0.07;
			if (map_pic_sprite.alpha <= 0) {
				map_pic_sprite.ID = 1;
				map_pic_sprite.alpha = 0;
			} else {
				return;
			}
		}
		
		var do_pic_change:Bool = false;
		if (!did_init_aliph_inventory) {
			did_init_aliph_inventory = true;
			do_pic_change = true;
			cursor_sprite.exists = text_extra.exists = true;
			cursor_sprite.x = active_item_images.members[mode_aliph_inv_cursor_idx].x - 2 - cursor_sprite.width;
			cursor_sprite.y = active_item_images.members[mode_aliph_inv_cursor_idx].y + 16 - cursor_sprite.height / 2;
			if (R.dialogue_manager.is_chinese()) cursor_sprite.y += 6;
			cursor_sprite.alpha = 1;
			var s:String = "";
			for (i in 0...9) {
				if (cur_inventory_row * maps_per_page+ i + 1 > items_You_have.length) {
					s += "---\n";
 				} else {
					s += R.dialogue_manager.lookup_sentence("ui", "items", items_You_have[cur_inventory_row * maps_per_page + i],true,true) + "\n";
					
				}
				text_extra.alignment = "left";
				text_extra.text = s;
			}
			text_extra.text += R.dialogue_manager.lookup_sentence("ui", "map_equip", 1,true,true);
			text_extra.x = (C.GAME_WIDTH - text_extra.width) / 2;
			
		}
		
		
		text_extra.y = header_strip.y + header_strip.height + 12;
		
		
		if (text_choices.alpha > 0) {
			text_choices.alpha -= 0.045; text_choices.alpha *= 0.95;
			if (text_choices.alpha < 0.05) text_choices.alpha = 0;
			//text_extra.alpha = text_submenu_title.alpha = 1 - text_choices.alpha;
			text_extra.alpha = 1 - text_choices.alpha;
		} 
		
		
		if (dialogue_box.is_active()) {
			
		} else if (R.input.jpDown) {
			if (mode_aliph_inv_cursor_idx + 1 < maps_per_page) {
				mode_aliph_inv_cursor_idx++;
				R.sound_manager.play(SNDC.menu_move);
				do_pic_change = true;
			}
		} else if (R.input.jpUp) {
			if (mode_aliph_inv_cursor_idx > 0) {
				mode_aliph_inv_cursor_idx--;
				R.sound_manager.play(SNDC.menu_move);
				do_pic_change = true;
			}
		}

		if (do_pic_change) {
			if (cur_inventory_row * maps_per_page + mode_aliph_inv_cursor_idx + 1 > items_You_have.length) {
				map_pic_sprite.alpha = 0;
			} else {
				var item_id:Int = items_You_have[cur_inventory_row * maps_per_page + mode_aliph_inv_cursor_idx];
				var a:Array<Dynamic> = R.inventory.get_item_pic_info(item_id);
				var bm:BitmapData = Assets.getBitmapData(a[0]);
				// hardcode 19-21
				if (item_id >= 19 && item_id <= 21) {
					if (item_id == 19) {
						bm = R.get_silo_bitmap_in_menu(19);
					} else if (item_id == 20) {
						bm = R.get_silo_bitmap_in_menu(20);
					} else {
						bm = R.get_silo_bitmap_in_menu(21);
					}
				} else {
					if (item_id != 48) {
						// Change pathname to localized map
						if (R.dialogue_manager.is_chinese()) {
							var path:String = a[0];
							path = path.split(".")[0] + "zhs" + ".png";
							bm = Assets.getBitmapData(path);
						} else if (R.dialogue_manager.get_langtype() != DialogueManager.LANGTYPE_EN) {
							var path:String = a[0];
							
							path = path.split(".")[0] + DialogueManager.arrayLANGTYPEcaps[R.dialogue_manager.get_langtype()].toLowerCase() + ".png";
							bm = Assets.getBitmapData(path);
						}
						
					}
				}
				//Log.trace(item_id);
				map_pic_sprite.myLoadGraphic(bm,true, false,Std.int(a[1]),Std.int(a[2]));
				map_pic_sprite.x = (FlxG.width - map_pic_sprite.width) / 2;
				if (map_pic_sprite.height > 120) {
					map_pic_sprite.y = FlxG.height - map_pic_sprite.height + 10;
				} else {
					map_pic_sprite.y = 92;
				}
				map_pic_sprite.scrollFactor.set(0, 0);
				map_pic_sprite.exists = map_pic_sprite.visible = true;
				//map_pic_sprite.alpha = 1;
				return;
			}
		}
		if (R.input.jpCONFIRM && cur_inventory_row * maps_per_page + mode_aliph_inv_cursor_idx + 1 <= items_You_have.length) {
			map_pic_sprite.ID = 20;
			var item_id:Int = items_You_have[cur_inventory_row * maps_per_page + mode_aliph_inv_cursor_idx];
			R.worldmapplayer.equipped_map_id = item_id;
			if (item_id == 48) {
				dialogue_box.start_dialogue("ui", "map_equip", 2);
			} else {
				dialogue_box.start_dialogue("ui", "map_equip", 0);
			}
			return;
		}
		
		
		cursor_sprite.x = text_extra.x - cursor_sprite.width - 2;
		cursor_sprite.y = text_extra.y + mode_aliph_inv_cursor_idx * (text_extra.lineHeight + text_extra.lineSpacing);
		if (R.dialogue_manager.is_chinese()) cursor_sprite.y += 6;
		cursor_sprite.alpha = 1;
		
		
		// EXIT MAP
		if (R.input.jpCANCEL || R.input.jpPause) {
			// Can't leave while in dialogue
			if (dialogue_box.is_active()) {
				return;
			}
			map_pic_sprite.alpha = 0;
			mode_aliph_inv_cursor_idx = 0; cur_inventory_row = 0;
			text_extra.text = "";
			did_init_aliph_inventory = false;
		}
		if (R.input.jpCANCEL) {
			R.sound_manager.play(SNDC.menu_cancel, 1);
			reset_cursor_on_return_from_submenu = true;
			//R.menu_map.exists = false;
			cursor_sprite.alpha = 0;
			set_choices_text();
			mode = MODE_CHOICES;
			return;
		} else if (R.input.jpPause) {
			text_extra.text = " ";
			R.sound_manager.play(SNDC.menu_close);
			begin_to_exit = true;
			//R.menu_map.exists = false;
			return;
		}
		
	}
	
	private var quicksave_init:Bool = false;
	
	private var quicksave_ctr:Int = 0;
	private function update_mode_quicksave():Void {
		
		if (!quicksave_init) {
			quicksave_init = true;
			if (R.player.is_on_the_ground() && R.player.energy_bar.is_stable()) {
				quicksave_ctr = 0;
				text_choices.text = lookup_label(1, "quicksave");
			} else {
				quicksave_ctr = -1;
				text_choices.text = lookup_label(0, "quicksave");
			}
			center_text(text_choices);
		}
		if (R.input.jpCANCEL) {
			quicksave_init = false;
			R.sound_manager.play(SNDC.menu_cancel, 1);
			mode = MODE_CHOICES;
			set_choices_text();
			cursor_sprite.visible = true;
			return;
		} else if (R.input.jpPause) {
			R.sound_manager.play(SNDC.menu_close);
			quicksave_init = false;
			begin_to_exit = true;
			cursor_sprite.visible = true;
			return;
		}
		
		if (quicksave_ctr == -1) {
			if (R.input.jpCONFIRM) {
				quicksave_init = false;
				R.sound_manager.play(SNDC.menu_cancel, 1);
				mode = MODE_CHOICES;
				
			set_choices_text();
				return;
			}
		} else if (quicksave_ctr == 0) {
			if (R.input.jpCONFIRM) {
				quicksave_ctr = 1;
				text_choices.text = lookup_label(2, "quicksave");
				center_text(text_choices);
			}
		} else if (quicksave_ctr == 1) {
			if (R.input.jpCONFIRM) {
				HF.save_map_entities(R.TEST_STATE.MAP_NAME, R.TEST_STATE, true);
				JankSave.save(42);
				#if cpp
				
				#if openfl_legacy
				System.exit();
				#else
				System.exit(0);
				#end
				
				#else
				System.exit(0);
				#end
			} 
		}
	}
	
	private var active_item_images:FlxTypedGroup<FlxSprite>;
	private var active_item_slots:FlxTypedGroup<FlxSprite>;
	private var dialogue_box:DialogueBox;
	private var items_You_have:Array<Int>;
	private var max_item_rows:Int = 0;
	private var cur_item_top_row:Int = 0;
	private var do_item_enter_anim:Bool = false;
	private var do_item_exit_anim:Bool = false;
	private var do_item_enter_mode:Int = 0;
	private function update_inventory_enter_anim(exit:Bool = false):Void {
		
		var w:Float = 32 * 5 + 16 * 4;
		
		if (exit) {
			
			if (do_item_enter_mode == 0) {
				inv_row_slctr.acceleration.y = inv_row_slctr.velocity.y = 0;
				for (i in 0...active_item_slots.maxSize) {
					var s:FlxSprite = active_item_slots.members[i];
					var d:Float = (i % 5) * (32 + 16);
					s.velocity.x = -(2 * d) / (0.4 + 0.2 * (Std.int(i/5)));
					s.acceleration.x = (s.velocity.x) / (0.45 + 0.22*(Std.int(i/5)));
					s.ID = Std.int((C.GAME_WIDTH - w) / 2);
				}
				do_item_enter_mode = 1;
				text_extra.text = " ";
			} else if (do_item_enter_mode == 1) {
				var c:Int = 0;
				for (i in 0...active_item_slots.maxSize) {
					var s:FlxSprite = active_item_slots.members[i];
					s.alpha -= 0.015;
					s.alpha *= 0.91;
					if (s.x <= s.ID) {
						c++;
						s.x = s.ID; s.velocity.x = s.acceleration.x = 0;
					}
					active_item_images.members[i].alpha = s.alpha;
					active_item_images.members[i].x = s.x + 2;
				}
				if (c == 15) {
					do_item_exit_anim = false;
					do_item_enter_mode = 0;
					active_item_images.setAll("alpha", 0);
					active_item_slots.setAll("alpha", 0);
					active_item_images.setAll("exists", false);
					active_item_slots.setAll("exists", false);
					inv_row_indctrs.exists = false;
					inv_row_slctr.exists = false;
				}
				
				inv_row_slctr.alpha = active_item_images.members[0].alpha;
				inv_row_indctrs.setAll("alpha", inv_row_slctr.alpha); 
			} 
			return;
		}
		
		if (do_item_enter_mode == 0) { // set them visible
			for (i in 0...active_item_slots.maxSize) {
				var s:FlxSprite = active_item_slots.members[i];
				s.x = (C.GAME_WIDTH - w) / 2;
				s.alpha = 0;
				s.exists = true;
				var d:Float = (i % 5) * (32 + 16);
				s.velocity.x = (2 * d) / (0.5 + 0.1 * (Std.int(i/5)));
				s.acceleration.x = -(s.velocity.x) / (0.55 + 0.11*(Std.int(i/5)));
				s.ID = Std.int(s.x + d);
				active_item_images.members[i].exists = true;
				if (active_item_images.members[i].animation.name != null && active_item_images.members[i].animation.name == "0") {
					active_item_images.members[i].exists = false;
				}
			}
			do_item_enter_mode = 1;
		} else if (do_item_enter_mode == 1) {
			var c:Int = 0;
			for (i in 0...active_item_slots.maxSize) {
				var s:FlxSprite = active_item_slots.members[i];
				s.alpha += 0.015;
				s.alpha *= 1.09;
				if (s.x >= s.ID) {
					c++;
					s.x = s.ID; s.velocity.x = s.acceleration.x = 0;
				}
				active_item_images.members[i].alpha = s.alpha;
				active_item_images.members[i].x = s.x + 2;
			}
			if (c == 15) {
				do_item_enter_mode = 10;
				active_item_images.setAll("alpha", 1);
				active_item_slots.setAll("alpha", 1);
			}
		} else if (do_item_enter_mode == 10) {
			do_item_enter_mode = 0;
			do_item_enter_anim = false;
		}
	}
	
	
	private function init_maps_on_select():Void {
		cursor_sprite.exists = true; cursor_sprite.visible = true;
		cursor_sprite.animation.play("r_on");
		did_init_aliph_inventory = false;
		
		var ia:String= R.inventory.get_save_string();
		items_You_have = [];
		
		for (i in 0...ia.length) {
			if (ia.charAt(i) == "1" && R.inventory.get_item_type(i) == "MAP") {
			//if (true && R.inventory.get_item_type(i) == "MAP") {
				items_You_have.push(i);
			}
		}
		if (items_You_have.length == 0) {
			Log.trace("DEBUG init_maps_on_select() adding map");
			//items_You_have.push(19);
			//items_You_have.push(20);
			//items_You_have.push(26);
			//items_You_have.push(21);
		}
		
		cur_inventory_row = 0;
		max_item_rows = 1 + Std.int(items_You_have.length / 10);
		
	}
	private function init_inventory_on_select():Void {
		cursor_sprite.exists = true; cursor_sprite.visible = true;
		cursor_sprite.animation.play("r_on");
		do_item_enter_anim = true;
		
		for (i in 0...active_item_slots.maxSize) {
			var s:FlxSprite = active_item_slots.members[i];
			s.y = 62 + (Std.int(i / 5) * (32 + 16));
			s.exists = false;
		}
		
		if (ProjectClass.DEV_MODE_ON){
			//for (i in 0...17) {
				//R.inventory.set_item_found(0, i);
			//}
		}
		var ia:String= R.inventory.get_save_string();
		items_You_have = [];
		for (i in 0...ia.length) {
			if (ia.charAt(i) == "1" && R.inventory.get_item_type(i) != "MAP") {
				items_You_have.push(i);
			}
		}
		
		
		var a:Int = 15 - items_You_have.length;
		if (a > 0) {
			for (i in 0...a) {
				items_You_have.push( -1);
			}
		}
		
		a = 5 - (items_You_have.length % 5);
		if (a < 5) {
			for (i in 0...a) {
				items_You_have.push( -1);
			}
		}
		
		if (items_You_have.length < 15) {
			max_item_rows = 3;
		} else {
			if (items_You_have.length % 5 == 0) {
				max_item_rows = Std.int(items_You_have.length / 5);
			} else {
				max_item_rows = Std.int(items_You_have.length / 5) + 1;
			}
		}
		
		var size:Int = 11;
		if (inv_row_indctrs.length  < max_item_rows - 2) {
			for (i in inv_row_indctrs.length...max_item_rows - 2) {
				var s:FlxSprite = new FlxSprite();
				s.make_rect_outline(size,size, 0xffffffff, "invrowindct");
				inv_row_indctrs.add(s);
			}
		}
		var inv_h:Int = inv_row_indctrs.length * (size + 5);
		var m:Float = active_item_slots.members[5].y + active_item_slots.members[5].height / 2;
		for (i in 0...inv_row_indctrs.length) {
			inv_row_indctrs.members[i].y = m - inv_h / 2 + i * (size + 5);
			inv_row_indctrs.members[i].x = 50;
			inv_row_indctrs.members[i].scrollFactor.set(0, 0);
		}
		inv_row_slctr.x = inv_row_indctrs.members[0].x;
		inv_row_slctr.y = inv_row_indctrs.members[0].y;
		
		cur_inventory_row = 0;
		set_items_view(cur_inventory_row, true);
		inv_row_slctr.exists = inv_row_indctrs.exists = true;
		inv_row_slctr.ID = 0;
		inv_row_slctr.alpha = 0;
		inv_row_indctrs.setAll("alpha", 0);
		
	}
	private function set_items_view(row:Int,fade_in_pos:Bool=false):Void {
		for (i in 0...active_item_images.maxSize) {
			var s:FlxSprite = active_item_images.members[i];
			if (items_You_have[row * 5 + i] == -1) {
				s.animation.play("0", true);
				s.exists = false;
				active_item_slots.members[i].animation.play("off");
			} else {
				s.animation.play(Std.string(items_You_have[row * 5 + i]), true);
				s.exists = true;
				active_item_slots.members[i].animation.play("on");
			}
			if (fade_in_pos) {
				s.alpha = 0;
				s.x = active_item_slots.members[0].x + 2;
			} else {
				s.x = active_item_slots.members[i].x + 2;
			}
			s.y = active_item_slots.members[i].y + 2;
		}
	}
	
	private var nr_gauntlets_to_replay:Int = 7;
	private function init_replay_gauntlet_on_select():Void {
		var s:String = "";
		for (i in 0...nr_gauntlets_to_replay) {
			s += R.dialogue_manager.lookup_sentence("ui", "replay_gauntlet", i) + "\n";
		}
		text_extra.text = s;
		text_extra.x = (FlxG.width - text_extra.width) / 2;
		text_extra.y = 48;
		text_extra.exists = text_extra.visible = true;
		text_extra.alpha = 1;
		mode_aliph_inv_cursor_idx = 0;
		set_cursor_sprite(text_extra, mode_aliph_inv_cursor_idx);
		text_choices.text = " ";
	}
	
	private var gauntlet_replay_mode:Int = 0;
	private function update_gauntlet_replay():Void {
		
		if (gauntlet_replay_mode == 1) {
			if (dialogue_box.last_yn == 0) {
				begin_to_exit = true;
				var s:String = R.dialogue_manager.lookup_sentence("ui", "replay_gauntlet_info", mode_aliph_inv_cursor_idx);
				if (mode_aliph_inv_cursor_idx == 0) {
					// Last save
					R.TEST_STATE.next_map_name = R.savepoint_mapName;
					R.TEST_STATE.next_player_x = R.savepoint_X;
					R.TEST_STATE.next_player_y = R.savepoint_Y;
				} else {
					R.TEST_STATE.next_map_name = s.split(",")[0];
					R.TEST_STATE.next_player_x = Std.parseInt(s.split(",")[1]);
					R.TEST_STATE.next_player_y = Std.parseInt(s.split(",")[2]);
				}
				R.TEST_STATE.DO_CHANGE_MAP = true;
				text_extra.text = " ";
				gauntlet_replay_mode = 0;
			} else if (dialogue_box.last_yn == 1) {
				gauntlet_replay_mode = 0;
			}
			return;
		}
		if (R.input.jpCONFIRM) {
			//Log.trace(1);
			R.sound_manager.play(SNDC.menu_confirm);
			dialogue_box.start_dialogue("ui", "replay_gauntlet", 7);
			//Log.trace(2);
			gauntlet_replay_mode = 1;
			return;
		}
		if (R.input.jpDown) {
			if (mode_aliph_inv_cursor_idx < nr_gauntlets_to_replay-1) {
				mode_aliph_inv_cursor_idx++;
				R.sound_manager.play(SNDC.menu_move);
				cursor_sprite.y += text_extra.lineHeight + text_extra.lineSpacing;
			}
		} else if (R.input.jpUp) {
			if (mode_aliph_inv_cursor_idx > 0) {
				R.sound_manager.play(SNDC.menu_move);
				mode_aliph_inv_cursor_idx--;
				cursor_sprite.y -= text_extra.lineHeight + text_extra.lineSpacing;
			}
		}
		
		
		if (R.input.jpCANCEL) {
			mode = MODE_CHOICES;
			text_extra.text = " ";
		}
		if (R.input.jpCANCEL) {
			R.sound_manager.play(SNDC.menu_cancel);
			set_choices_text();
			set_cursor_sprite(text_choices, MODE_CHOICES_idx);
		}
	}
	
	public function update_font():Void {
		//if (!did_init) return; // For when this is called by a reload in the editor before opening the pause menu, so the game won't crash bya ccessing main_choices in set_choices_text
		
		if (!did_init) {
			set_main_choices();
			init_settings();
		}
		set_choices_text();
		
		dialogue_box.update_font();
		
		// 355
		
		var bm:FlxBitmapText = null;
		var i:Int = 0;
		bm = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_ALIPH_WHITE); bm.double_draw = true; i = members.indexOf(text_choices); members[i] = bm; text_choices.destroy(); text_choices = cast members[i];
		set_settings_menu_text(0);
		set_cursor_sprite(text_choices, settings_idx);
		
		bm = HF.init_bitmap_font(text_area.text, "left", Std.int(text_area.x), Std.int(text_area.y), null, C.FONT_TYPE_ALIPH_WHITE); bm.double_draw = true; bm.visible = text_area.visible;  i = members.indexOf(text_area); members[i] = bm; text_area.destroy(); text_area = cast members[i];
		bm = HF.init_bitmap_font(text_extra.text, "center", Std.int(text_extra.x), Std.int(text_extra.y), null, C.FONT_TYPE_ALIPH_WHITE); bm.double_draw = true; bm.visible = text_extra.visible;  i = members.indexOf(text_extra); members[i] = bm; text_extra.destroy(); text_extra= cast members[i];
		
		bm = HF.init_bitmap_font(text_playtime.text, "left", Std.int(text_playtime.x), Std.int(text_playtime.y), null, C.FONT_TYPE_ALIPH_WHITE); bm.double_draw = true; bm.alpha = text_playtime.alpha;  bm.visible = text_playtime.visible;  i = members.indexOf(text_playtime); members[i] = bm; text_playtime.destroy(); text_playtime = cast members[i];
		
		bm = HF.init_bitmap_font(text_submenu_title.text, "left", Std.int(text_submenu_title.x), Std.int(text_submenu_title.y), null, C.FONT_TYPE_ALIPH_WHITE); bm.double_draw = true; bm.alpha = text_submenu_title.alpha;  bm.visible = text_submenu_title.visible;  i = members.indexOf(text_submenu_title); members[i] = bm; text_submenu_title.destroy(); text_submenu_title = cast members[i];
		
		
		bm = HF.init_bitmap_font(text_humus.text, "left", Std.int(text_humus.x), Std.int(text_humus.y), null, C.FONT_TYPE_ALIPH_WHITE); bm.double_draw = true; bm.alpha = text_humus.alpha;  bm.visible = text_humus.visible;  i = members.indexOf(text_humus); members[i] = bm; text_humus.destroy(); text_humus = cast members[i];
		
		text_humus.y = C.GAME_HEIGHT - text_humus.height - 4;
		text_humus.x = C.GAME_WIDTH - text_humus.width - 4;

		text_submenu_title.color = BLUE;
	}
	
	override public function draw():Void 
	{
		if (in_sound || in_volume || in_scaling || in_window_scaling) {
			cursor_sprite.visible = false;
			
		}
		super.draw();
		if (in_sound || in_volume|| in_scaling || in_window_scaling) {
			var ox:Float = cursor_sprite.x;
			cursor_sprite.y ++;
			if (in_volume) {
				cursor_sprite.x = text_choices.x +(Utf8.length(choices_for_text_settings[0]) + 2) * (text_choices.font.spaceWidth) - cursor_sprite.width ;
			} else if (in_scaling) {
				cursor_sprite.x = text_choices.x +(Utf8.length(choices_for_text_settings[2]) + 2) * (text_choices.font.spaceWidth) - cursor_sprite.width ;
			} else if (in_window_scaling) {
				cursor_sprite.x = text_choices.x +(Utf8.length(choices_for_text_settings[3]) + 2) * (text_choices.font.spaceWidth) - cursor_sprite.width ;
			} else {
				cursor_sprite.x = text_choices.x +(Utf8.length(choices_for_text_settings[1]) + 2) * (text_choices.font.spaceWidth) - cursor_sprite.width ;
			}
			cursor_sprite.scale.x = -1;
			cursor_sprite.draw();
			cursor_sprite.scale.x = 1;
			if (in_scaling || in_window_scaling) {
				cursor_sprite.x = text_choices.x + text_choices.width + 8;
			} else {
				cursor_sprite.x += 3 * text_choices.font.spaceWidth;
			}
			cursor_sprite.draw();
			cursor_sprite.x = ox;
			cursor_sprite.visible = true;
			
			cursor_sprite.y --;
		}
	}
}