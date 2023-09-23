package state;
import autom.EMBED_TILEMAP;
import autom.SNDC;
import entity.ui.PauseMenu;
import entity.ui.TutorialGroup;
import flash.system.System;
import flixel.FlxCamera;
import flixel.system.frontEnds.CameraFrontEnd;
import global.C;
import global.EF;
import global.Registry;
import haxe.Log;
import help.AnimImporter;
import help.DialogueManager;
import help.FlxX;
import help.HF;
import help.InputHandler;
import help.JankSave;
import help.SaveModule;
import help.SongHelper;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;

class TitleState extends MyState
{
	public var version_text:FlxBitmapText;
	public var instructions_text:FlxBitmapText;
	public var controls_text:FlxBitmapText;
	public var R:Registry;
	public var mode:Int;
	private static inline var mode_intro:Int = 0;
	
	private static inline var mode_press_start:Int = 1;
	private static inline var mode_file_select:Int = 2;
	private static inline var mode_enter_game:Int = 3;
	private static inline var mode_wait_for_savemodule:Int = 4;
	private static inline var mode_loadquicksave:Int = 5;
	private static inline var mode_even_or_ocean:Int = 6;
	private static inline var mode_newgametext:Int = 7;
	public static var version:String = "v. 1.024";
	
	private var newgametext_state:Int = 0;
	private var tutorial_group:TutorialGroup;
	private var is_newgame:Bool = false;
	private var ctr:Int = 0;
	private var ctr2:Int = 0;
	private var ctr3:Int = 0;
	
	private var selector:FlxSprite;
	private var selector_idx:Int;
	private var fg_fade_sprite:FlxSprite;
	private var title_Card:FlxSprite;
	private var title_text_sprite:FlxSprite;
	private var title_bg:FlxSprite;
	
	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		R = Registry.R;
		
		version_text = HF.init_bitmap_font(version, "left", 0, FlxG.height - 12, null, C.FONT_TYPE_APPLE_WHITE);
		version_text.visible = false;
		
		instructions_text = HF.init_bitmap_font("Press "+R.input.keybindings[InputHandler.KDX_PAUSE], "center", 50, 50, null, C.FONT_TYPE_APPLE_WHITE);
		instructions_text.visible = false;
		
		controls_text = HF.init_bitmap_font("", "left", 50, 50, null, C.FONT_TYPE_APPLE_WHITE);
		
		instructions_text.double_draw = version_text.double_draw = controls_text.double_draw = true;
		
		selector = new FlxSprite(instructions_text.x - 8, instructions_text.y);
		selector.visible = false;
		AnimImporter.loadGraphic_from_data_with_id(selector, 0, 0, "MenuSelector"); 
		selector.animation.play("full");
		selector.scrollFactor.set(0, 0);
		
		title_Card = new FlxSprite();
		//title_Card.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/title/titlecard.png"));
		title_Card.makeGraphic(416, 256, 0xff000000);
		title_Card.scrollFactor.set(0, 0);
		title_text_sprite = new FlxSprite();
		title_text_sprite.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/title/bg_titletext.png"));
		title_text_sprite.scrollFactor.set(0, 0);
		title_bg = new FlxSprite();
		title_bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/title/bg_title.png"));
		title_bg.scrollFactor.set(0, 0);
		
		fg_fade_sprite = new FlxSprite();
		fg_fade_sprite.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		fg_fade_sprite.scrollFactor.set(0, 0);
		tutorial_group = R.tutorial_group;
		tutorial_group.exists = false;
	}
	
	public function update_font():Void {
		var bm:FlxBitmapText;
		var i:Int = 0;
		
		var noInstructions:Bool = false;
		var noControls:Bool = false;
		// Because title state texts arent added by default
		if (members.indexOf(instructions_text) == -1) {
			add(instructions_text);
			noInstructions = true;
		}
		
		if (members.indexOf(controls_text) == -1) {
			add(controls_text);
			noControls = true;
		}
		bm = HF.init_bitmap_font(instructions_text.text, "center", Std.int(instructions_text.x), Std.int(instructions_text.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.visible = instructions_text.visible;  i = members.indexOf(instructions_text); members[i] = bm; instructions_text.destroy(); instructions_text = cast members[i];
		
		bm = HF.init_bitmap_font(controls_text.text, "left", Std.int(controls_text.x), Std.int(controls_text.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.visible = controls_text.visible;  i = members.indexOf(controls_text); members[i] = bm; controls_text.destroy(); controls_text = cast members[i];
		
		if (noInstructions) remove(instructions_text, true);
		if (noControls) remove(controls_text, true);
	}
	
	override public function update(elapsed: Float):Void {
		super.update(elapsed);
		
		switch (mode) {
			case mode_intro:
				if (ctr == -1) {
					ctr = 0;
				} else if (ctr == 0) { 
					remove(title_Card,true);
					add(title_Card);
					
					remove(title_bg,true);
					remove(title_text_sprite,true);
					remove(instructions_text, true);
					remove(version_text, true);
					remove(controls_text, true);
					remove(selector, true);
					remove(tutorial_group, true);
					remove(R.easycutscene, true);
					remove(dialogue_box, true);
					
					add(title_bg);
					add(title_text_sprite);
					add(instructions_text);
					add(version_text);
					R.actscreen.activate(0, cast this);
					add(controls_text);
					add(selector);
					add(tutorial_group);
					add(R.easycutscene);
					add(dialogue_box);
					
					controls_text.text = R.dialogue_manager.lookup_sentence("ui", "title_text", 4,true,true);
					controls_text.alignment = "center";
					controls_text.lineSpacing = 6;
					controls_text.x = 208 - controls_text.width / 2;
					controls_text.y = 180;
					controls_text.alpha = 0;
					
					title_bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/title/bg_title.png"));
					title_bg.scrollFactor.set(0, 0);
					
					version_text.alpha = selector.alpha = instructions_text.alpha = title_bg.alpha = title_text_sprite.alpha = 0;
					title_bg.alpha = title_text_sprite.alpha = 0;
					
					remove(fg_fade_sprite, true);
					add(fg_fade_sprite);
					fg_fade_sprite.alpha = 0;
					
					title_Card.alpha = 1;
					
					ctr = 1;
					R.song_helper.fade_to_this_song("pre_title");
				} else if (ctr == 1) {
					// Title card showing. wait for 2 seconds (or skip)
					ctr2 ++;
					if (R.input.jpA1 || R.input.jpA2 || R.input.jpPause) {
						ctr2 = 361;
					}
					if (ctr2 > 290) {
						controls_text.alpha += 1.0 / 40.0;
						controls_text.alpha *= 1.02;
					}
					// Time for song to fade while act screen playing
					if (ctr2 > 320) {
						controls_text.alpha = 1;
						ctr2 = 0;
						ctr = 2;
					}
				} else if (ctr == 2) {
					// fade in black fg, turn on title BG underneath.
					// Press hre = skip straight to end
					if (R.input.jp_any()) {
						R.actscreen.deactivate();
						fg_fade_sprite.alpha = 0;
						controls_text.alpha = 0;
						controls_text.text = "";
						title_bg.alpha = 1;
						title_text_sprite.alpha = 1;
						mode = mode_file_select;
						instructions_text.lineSpacing = 6;
						instructions_text.text = R.dialogue_manager.lookup_sentence("ui", "title_text", 0,false,true);
						instructions_text.y = C.GAME_HEIGHT - 16 - instructions_text.height;
						instructions_text.x = (C.GAME_WIDTH - instructions_text.width) / 2;
						selector.y = instructions_text.y - 5;
						if (R.dialogue_manager.is_chinese() == true) {
							selector.y = instructions_text.y;
						}
						selector.x = instructions_text.x - selector.width - 4;
						selector_idx = 0;
						selector.alpha = 1;
						version_text.alpha = 1;
						instructions_text.alpha = 1;
						ctr = 0;
						selector.visible = true;
						version_text.visible = true;
						instructions_text.visible = true;
						instructions_text.alignment = "left";
						instructions_text.lineSpacing = 6;
						ctr2 = 0;
						ctr3 = 90;
						
						// Start on load
						if (JankSave.any_save_exists()) {
							selector_idx = 1;
							selector.y += instructions_text.lineSpacing + instructions_text.lineHeight;
						}
						
						return;
					}
					if (R.actscreen.mode == 3) {
						controls_text.alpha -= 0.03;
					}
					if (R.actscreen.is_off()) {
						fg_fade_sprite.alpha += 1.0 / 20;
						if (fg_fade_sprite.alpha >= 1) {
							controls_text.text = "";
							controls_text.alpha = 0;
							title_bg.alpha = 1;
							ctr = 3;
						}
					}
				} else if (ctr == 3) {
					// Fading out black FG to zero. 
					ctr2++;
					if (R.input.jp_any()) {
						ctr2 = 61;
						fg_fade_sprite.alpha = 0;
					}
					if (ctr2 > 20) {
						fg_fade_sprite.alpha -= 1.0 / 40;
						if (fg_fade_sprite.alpha <= 0) {
							ctr = 4;
							ctr2 = 0;
						}
					}
				} else if (ctr == 4) {
					ctr2++;
					
					if (R.input.jp_any()) {
						ctr2 = 61;
						title_text_sprite.alpha = 1;
					}
					if (ctr2 > 60) {
						title_text_sprite.alpha += 1.0 / 120;
						if (title_text_sprite.alpha >= 1) {
							ctr2 = 0;
							ctr = 5;
						}
					}
				} else if (ctr == 5) {
					ctr2++;
					if (R.input.jp_any()) {
						ctr2 = 61;
					}
					// set text to "press confirm key".
					if (ctr2 > 60) {
						instructions_text.text = R.dialogue_manager.lookup_sentence("ui", "title_text", 1,false,true);
						instructions_text.x = (C.GAME_WIDTH - instructions_text.width) / 2;
						instructions_text.y = 192;
						instructions_text.alpha = 0;
						instructions_text.alignment = "left";
						instructions_text.lineSpacing = 6;
						version_text.alpha = 0;
						ctr = 200;
						ctr2 = 0;
						instructions_text.visible = true;
						version_text.visible = true;
					}
				} else if (ctr == 200) {
					// After 3 seconds, show that above text
					ctr2++;
					if (R.input.jp_any() && !R.input.jpCONFIRM) {
						ctr2 = 181;
					}
					if (ctr2 > 180) {
						instructions_text.alpha += 0.015;
						instructions_text.alpha *= 1.08;
					}
					
					
					
					if (R.input.jpCONFIRM) {
						mode = mode_press_start;
						ctr = 1;
						ctr2 = 0;
						ctr3 = 90;
					}
				}
				
			case mode_press_start:
				fade_titletext();
				if (ctr == 1) {
					// another press = show "new game etc"
					if (R.input.jp_any()) {
						instructions_text.alpha = 0;
					}
					
					instructions_text.alpha -= 0.02;
					instructions_text.alpha *= 0.95;
					if (instructions_text.alpha <= 0) {
						instructions_text.text = R.dialogue_manager.lookup_sentence("ui", "title_text", 0,false,true);
						instructions_text.y = C.GAME_HEIGHT - 16 - instructions_text.height;
						instructions_text.x = (C.GAME_WIDTH - instructions_text.width) / 2;
						ctr = 2;
						selector.y = instructions_text.y - 5;
						if (R.dialogue_manager.is_chinese() == true) {
							selector.y = instructions_text.y ;
						}
						
						selector.visible = true;
						selector.x = instructions_text.x - selector.width - 4;
						selector_idx = 0;
						selector.alpha = 0;
						
						// Start on load
						if (JankSave.any_save_exists()) {
							selector_idx = 1;
							selector.y += instructions_text.lineSpacing + instructions_text.lineHeight;
						}
						
						if (R.input.jp_any()) {
							selector.alpha = 1;
							instructions_text.alpha = 1;
						}
					}
				} else if (ctr == 2) {
					
					
					instructions_text.alpha += 0.02;
					instructions_text.alpha *= 1.05;
					version_text.alpha = instructions_text.alpha;
					selector.alpha = instructions_text.alpha;
					if (selector.alpha >= 1) {
						mode = mode_file_select;
						ctr = 0;
					}
				}
			case mode_file_select:
				
				if (ctr == -2) {
					// Handle unpausing the title screen pause menu
					if (R.TEST_STATE.pause_menu.is_idle() == false) {
						if (R.TEST_STATE.pause_menu.is_ready_to_exit()) {
							R.TEST_STATE.pause_menu.deactivate(this);
							
							// In case language changed, re-load the "NEW GAME, CONTINUE..." etc texts
							instructions_text.text = R.dialogue_manager.lookup_sentence("ui", "title_text", 0, false, true);
							instructions_text.y = C.GAME_HEIGHT - 16 - instructions_text.height;
							instructions_text.x = (C.GAME_WIDTH - instructions_text.width) / 2;
							if (R.dialogue_manager.is_chinese() == false) {
								selector.y = instructions_text.y - 5;
							} else {
								selector.y = instructions_text.y ;
							}
							selector.y += selector_idx * (instructions_text.lineSpacing + instructions_text.lineHeight);
							ctr = 0;
						}
					}
				} else if (ctr == -1) {
					if (dialogue_box.is_active() == false) {
						ctr = 0;
					}
				} else if (ctr == 0) {
					fade_titletext();
					
					if (R.input.jpDown && selector_idx < 3) {
						
						R.sound_manager.play(SNDC.menu_move);
						selector_idx ++;
						selector.y += instructions_text.lineSpacing + instructions_text.lineHeight;
					} else if (R.input.jpUp && selector_idx > 0) {
						selector_idx --;
						R.sound_manager.play(SNDC.menu_move);
						selector.y -= instructions_text.lineSpacing + instructions_text.lineHeight;
					}
					if (R.input.jpCONFIRM) {
						R.sound_manager.play(SNDC.menu_confirm);
						if (selector_idx == 0) { //start a new game
							ctr = 1;
						} else if (selector_idx == 1) { //load
							if (JankSave.any_save_exists() == false) {
								ctr = -1;
								dialogue_box.start_dialogue("ui", "title_text", 3);
							} else {
								ctr = 1;
								ctr2 = 61;
							}
						} else if (selector_idx == 2) { 
							// pause game
							R.TEST_STATE.pause_menu.FROM_TITLE = true;
							R.TEST_STATE.pause_menu.FROM_TITLE_AND_MAINMENU = true;
							R.TEST_STATE.pause_menu.activate(this);
							ctr = -2;
						} else if (selector_idx == 3) { //exit game
							System.exit(0);
							//R.save_module.activate(SaveModule.MODE_DELETE);
							//add(R.save_module);
							//mode = mode_wait_for_savemodule;
						}
					}
				} else if (ctr == 1) { // new game fadestuff - fade text, focus on cabin for a second
					title_text_sprite.alpha -= 0.01;
					instructions_text.alpha -= 0.01;
					if (selector_idx == 1) {
						title_text_sprite.alpha -= 0.02;
						instructions_text.alpha -= 0.02;
					}
					version_text.alpha = selector.alpha = instructions_text.alpha;
					if (selector.alpha <= 0) {
						ctr2++;
						if (ctr2 > 60) {
							ctr2 = 0;
							ctr = 2;
						}
					}
					
					if (R.input.jp_any()) {
						ctr = 2;
						ctr2 = 0;
						fg_fade_sprite.alpha = 1;
						title_text_sprite.alpha = version_text.alpha = selector.alpha = instructions_text.alpha = 0;
						
					}
					
					
				} else if (ctr == 2) {
					fg_fade_sprite.alpha += 0.008;
					fg_fade_sprite.alpha *= 1.01;
					if (selector_idx == 1) {
						fg_fade_sprite.alpha += 0.018;
					}
					
					if (fg_fade_sprite.alpha >= 1) {
						if (selector_idx == 0){
							title_bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/title/bg_titlenew.png"));
						} else {
							title_bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/title/bg_titleload.png"));
						}
						title_bg.scrollFactor.set(0, 0);
						ctr = 3;
					}
				} else if (ctr == 3) {
					if (R.input.jp_any()) {
						ctr2 = 46;
						fg_fade_sprite.alpha = 0;
					}
					ctr2++;
					if (ctr2 > 45) {
						fg_fade_sprite.alpha -= 0.008;
						if (selector_idx == 1) {
							fg_fade_sprite.alpha -= 0.018;
						}
						fg_fade_sprite.alpha *= 0.97;
						if (fg_fade_sprite.alpha <= 0) {
							
							
							if (JankSave.any_save_exists() == false) {
								Log.trace("Skipping new game menu bc no existing saves.");
								fg_fade_sprite.alpha = 0;
								R.save_module.doNewgameSave();
								mode = mode_wait_for_savemodule;
								ctr = 0;
								ctr2 = 0;
								return;
							}
							
							ctr = 0;
							ctr2 = 0;
							if (selector_idx == 0 ){
								R.save_module.activate(SaveModule.MODE_NEW, -1, -1, true);
								//controls_text.text = R.dialogue_manager.lookup_sentence("ui", "title_text", 2, true, true);
								controls_text.text = " ";
								controls_text.alignment = "left";
								controls_text.alpha = 0;
								controls_text.x = 4;
								controls_text.lineSpacing = 3;
								controls_text.y = C.GAME_HEIGHT - 4 - controls_text.height;
							} else {
								R.save_module.activate(SaveModule.MODE_LOAD, -1, -1, true);
							}
							add(R.save_module);
							remove(dialogue_box,true);
							add(dialogue_box);
							mode = mode_wait_for_savemodule;
							
						}
					}
					
				}
				if (ctr == 4) { // fade back to title text - fade in black first, change bg
					fg_fade_sprite.alpha += 0.015;
					fg_fade_sprite.alpha *= 1.05;
					controls_text.alpha = 1 - fg_fade_sprite.alpha;
					if (fg_fade_sprite.alpha >= 1) {
						controls_text.text = "";
						title_bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/title/bg_title.png"));
						title_bg.scrollFactor.set(0, 0);
						instructions_text.alpha = 1;
						selector.alpha = 1;
						version_text.alpha = 1;
						ctr = 5;
					}
				} else if (ctr == 5) { // fade out fg fade
					fade_titletext();
					fg_fade_sprite.alpha -= 0.015;
					fg_fade_sprite.alpha *= 0.95;
					if (fg_fade_sprite.alpha <= 0) {
						ctr = 0;
					}
				}
			case mode_wait_for_savemodule:
				controls_text.alpha += 0.02;
				if (R.save_module.is_idle()) {
					
					remove(R.save_module, true);
					if (R.save_module.just_loaded()) {
						R.sound_manager.play(SNDC.menu_cancel);
						R.TEST_STATE.next_map_name = R.savepoint_mapName;
						R.TEST_STATE.next_player_x = R.savepoint_X;
						R.TEST_STATE.next_player_y = R.savepoint_Y;
						mode = mode_even_or_ocean; 
						R.player.reset_motion_state();
					// Initial coordinates were set in the save module previously
					} else if (R.save_module.just_newed) {
						R.save_module.just_newed = false;
						mode = mode_even_or_ocean; 
						R.player.energy_bar.balance_energy();
						R.player.reset_motion_state();
						is_newgame = true;
					} else {
						R.sound_manager.play(SNDC.menu_cancel);
						mode = mode_file_select;
						ctr = 4;
					}
					
					if (mode == mode_even_or_ocean) {
						selector_idx = 1;
					}
					
				}
			case mode_even_or_ocean:
					if (is_newgame) {
						is_newgame = false;
						if (selector_idx == 1) {
							newgametext_state = 0;
							mode = mode_newgametext;
							is_newgame = true;
						}
					} else {
						mode = mode_enter_game;
					}
			case mode_enter_game:
				if (is_newgame == false) {
					fg_fade_sprite.alpha += 0.0065;
				}
				fg_fade_sprite.alpha += 0.0065;
				if (fg_fade_sprite.alpha == 1) {
					is_newgame = false;
					R.TEST_STATE.mode_change_DO_INSTANT = true;
					R.TEST_STATE.DO_CHANGE_MAP = true;
					R.TEST_STATE.update(elapsed);
					
					GameState.do_change_state = true;
					GameState.next_state = GameState.STATE_TEST;
					mode = mode_intro;
					ctr = -1;
				}
			case mode_newgametext:
				if (newgametext_state == 0) {
					newgametext_state = 690;
				} else if (newgametext_state == 690) {
					if (!dialogue_box.is_active()) {
						dialogue_box.start_dialogue("intro", "cloak", 3); 
						newgametext_state = 20;
					}
				} else if (newgametext_state == 691) {
					if (!dialogue_box.is_active()) {
						newgametext_state = 692;
						add(R.joy_module);
						R.joy_module.activate(dialogue_box);
					}
				} else if (newgametext_state == 692) {
					if (R.joy_module.is_done()) {
						remove(R.joy_module, true);
						dialogue_box.start_dialogue("intro", "cloak", 3); 
						newgametext_state = 20;
					}
				// Start of humus things
				} else if (newgametext_state == 10) {
						newgametext_state = 11;
				} else if (newgametext_state == 11) {
						R.PLAYER_NAME = "Player";
						if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_EN) {
							R.PLAYER_NAME = "Player";
						} else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_JP) {
							R.PLAYER_NAME = "プレーヤー";
						} else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_ZH_SIMP) {
							R.PLAYER_NAME = "玩家";
						} else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_DE) {
							R.PLAYER_NAME = "Spieler";
						}else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_RU) {
							R.PLAYER_NAME = "игрок";
						}else if (DialogueManager.CUR_LANGTYPE == DialogueManager.LANGTYPE_ES) {
							R.PLAYER_NAME = "Jugador";
						}
						newgametext_state = 1;
				} else if (newgametext_state == 1) { // Wait for "yes" or "no" on whether name is okay
					
					// ez cutscene blcoks till  fg faded in
					if (R.easycutscene.ping_1) {
						fg_fade_sprite.alpha += 0.0095;
						if (fg_fade_sprite.alpha >= 1) {
							R.easycutscene.ping_1 = false;
							newgametext_state = 22; 
						}
					}
					
				// pause menu
				} else if (newgametext_state == 20) { // 
					
					controls_text.alpha -= 0.05;
					if (dialogue_box.is_active() == false) {
						
						//update_submode_modepick - in PauseMenu - is the difficulty picking
						R.TEST_STATE.pause_menu.FROM_TITLE = true;
						R.TEST_STATE.pause_menu.activate(this);
						newgametext_state = 21;
					}
				} else if (newgametext_state == 21) {
					// If pause menu done
					
					if (R.TEST_STATE.pause_menu.is_idle() == false) {
						if (R.TEST_STATE.pause_menu.is_ready_to_exit()) {
							R.TEST_STATE.pause_menu.deactivate(this);
							
							if (R.gauntlet_mode == true) {
								R.TEST_STATE.next_map_name = "GM_1";
								R.TEST_STATE.next_player_x = 2 * 16;
								R.TEST_STATE.next_player_y = Std.int(13 * 16 - R.player.height + 1);
								R.event_state[EF.player_intro_cave] = 1; // turn off armor
								R.savepoint_mapName = R.TEST_STATE.next_map_name; // Make sure game saves an init loading pos within gauntlet mode. This is also done below for warp mode.
								R.savepoint_X = R.TEST_STATE.next_player_x;
								R.savepoint_Y = R.TEST_STATE.next_player_y;
							}
							
							if (R.TEST_STATE.next_map_name != "ROUGE_0") {
								R.player.move(R.TEST_STATE.next_player_x, R.TEST_STATE.next_player_y);
								R.player.last.set(R.TEST_STATE.next_player_x, R.TEST_STATE.next_player_y);
								newgametext_state = 22;
								R.savepoint_mapName = R.TEST_STATE.next_map_name;
								R.savepoint_X = R.TEST_STATE.next_player_x;
								R.savepoint_Y = R.TEST_STATE.next_player_y;
							} else {
								R.easycutscene.activate("0a_intro", this);
								newgametext_state = 10;
							}
							
							JankSave.save_recent();
						}
					}
				} else if (newgametext_state == 22) {
					if (R.easycutscene.is_off()) {
						mode = mode_enter_game;
					}
				} else if (newgametext_state == 12) {
				} else if (newgametext_state == 2) {
				} else if (newgametext_state == 3) {
					if (dialogue_box.is_active() == false) {
					}
				}
				
		}
		
		
	}
	
	function fade_titletext():Void 
	{
		ctr3 += 2;
		if (ctr3 >= 360) ctr3 -= 360;
		title_text_sprite.alpha = 0.85 + 0.15 * FlxX.sin_table[ctr3];
	}
}	