package entity.ui;
import autom.SNDC;
import entity.MySprite;
import entity.npc.GenericNPC;
import entity.util.NewCamTrig;
import flash.geom.Rectangle;
import global.C;
import global.EF;
import global.Registry;
import haxe.Log;
import haxe.Timer;
import haxe.Utf8;
import help.AnimImporter;
import help.HF;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import openfl.Assets;
import state.TestState;

/**
 * @author Melos Han-Tani
 */

class DialogueBox extends FlxGroup
{
	
	public var IS_SCREEN_AREA:Bool = false; //reset on change map in teststate
	public static var MOST_RECENT_CALLED_BOX:DialogueBox;

	private var mode:Int = 0;
	private var MODE_IDLE:Int = 0;
	private var MODE_PLAYING:Int = 1;
	private var MODE_CLEANUP:Int = 2;
	private var MODE_WAIT_FOR_INPUT:Int = 3;
	private var MODE_BUMP_UP:Int = 4;
	private var MODE_WAIT_FOR_INPUT_TO_BUMP:Int = 5;
	private var MODE_YES_NO:Int = 6;
	private var MODE_WAIT_FOR_INPUT_ON_FORCED_PAUSE:Int = 7;
	private var MODE_TRANSITION_IN:Int = 8;
	private var MODE_TRANSITION_OUT:Int = 9;
	private var MODE_INFOPAGE:Int = 10;
	private var R:Registry;
	private var lines:Array<String>;
	
	private var skip_to_yesno:Bool = false;
	private var yesno_no_leave:Int = -1;
	public var MAIN_DISPLAY_MAX_ALPHA:Float = 0.9;
	private var do_yes_no:Bool = false;
	private var yes_no_choices:Array<String>;
	private var yes_no_next_positions:Array<Dynamic>;
	/**
	 * If set to true via a GNPC script (often during an EasyCutscene) then always play speaker=none.
	 * Turned off at the end of an easycutscene
	 */
	public var speaker_always_none:Bool = false;
	
	//private var box:FlxSprite;
	private var item_image:FlxSprite;
	private var text:FlxBitmapText;
	private var speaker_text:FlxBitmapText;
	private var box_highlight:FlxSprite;
	private var portrait:FlxSprite;
	private var has_name:Bool = false;
	private var has_sound:Bool = false;
	private var next_sound:String = "";
	private var has_highlight:Bool = false;
	private var speaker_next_name:String = "";
	private var voice_name:String = "";
	private var arrow:FlxSprite;
	
	private var yesno_box:NineSliceBox;
	private var yesno_text:FlxBitmapText;
	private var yesno_selector:FlxSprite;
	private var yesno_index:Int;
	private var yesno_map:String;
	private var yesno_scene:String;
	private var forced_next_pos:Int = -1;
	public var unpause_player_after_cleanup:Bool = true;
	
	private var transition_ctr:Int = 0;
	private var main_display:NineSliceBox;
	public var last_yn:Int = -1;
	private var DEFAULT_BOX_HEIGHT:Float = 82;
	private var DEFAULT_NO_NAME_BOX_HEIGHT:Float = 62;
	public var MAX_CHARS_PER_LINE:Int = 40;
	private var VISTYPE_DEBUG:Int = 0;
	
	public function update_font():Void {
		var bm:FlxBitmapText = null;
		var i:Int = 0;
		bm = HF.init_bitmap_font(" ", "left", 32, C.GAME_HEIGHT - 72, null, C.FONT_TYPE_ALIPH_WHITE); bm.double_draw = true; i = members.indexOf(text); members[i] = bm; text.destroy(); text = cast members[i];
		bm = HF.init_bitmap_font(" ", "left", 12, C.GAME_HEIGHT - 78, null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; i = members.indexOf(yesno_text); members[i] = bm; yesno_text.destroy(); yesno_text = cast members[i];
		bm = HF.init_bitmap_font("The Game's Programmer", "left", 32, 69, null, C.FONT_TYPE_ALIPH_SMALL_WHITE); bm.double_draw = true; i = members.indexOf(speaker_text); members[i] = bm; speaker_text.destroy(); speaker_text = cast members[i];
	}
	public function new() 
	{
		super(0, "DialogueBox");
		R = Registry.R;
		
		exists = false;
		
		//box = new FlxSprite(10, C.GAME_HEIGHT - 80);
		//box.scrollFactor.set(0, 0);
		//change_visuals(VISTYPE_DEBUG);
		text = HF.init_bitmap_font(" ", "left", 32, C.GAME_HEIGHT - 72, null, C.FONT_TYPE_ALIPH_WHITE);
		text.double_draw = true;
		
		speaker_text = HF.init_bitmap_font("The Game's Programmer", "left", 32, 69, null, C.FONT_TYPE_ALIPH_SMALL_WHITE);
		speaker_text.double_draw = true;
		
		portrait = new FlxSprite();
		AnimImporter.loadGraphic_from_data_with_id(portrait, 48, 64, "DialogueBox", "portrait");
		
		//yesno_box = new FlxSprite(100, 120 );
		yesno_box = new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH, false, "assets/sprites/ui/9slice_dialogue.png");
		yesno_box.x = 100;
		yesno_box.y = 120;
		yesno_box.resize(280, 70);
		//yesno_box.makeGraphic(280, 70, 0xdd000000);
		yesno_text = HF.init_bitmap_font(" ", "left", 12, C.GAME_HEIGHT - 78, null, C.FONT_TYPE_APPLE_WHITE);
		yesno_text.double_draw = true;
		yesno_selector = new FlxSprite(0, 0);
		AnimImporter.loadGraphic_from_data_with_id(yesno_selector, 0, 0, "MenuSelector");
		yesno_selector.animation.play("empty");
		
		yesno_text.visible = yesno_box.visible = yesno_selector.visible = false;
		yesno_box.scrollFactor.set(0, 0);
		yesno_text.scrollFactor.set(0, 0);
		yesno_selector.scrollFactor.set(0, 0);
		
		arrow = new FlxSprite();
		arrow.scrollFactor.set(0, 0);
		AnimImporter.loadGraphic_from_data_with_id(arrow, 12, 12, "DialogueBox", "arrow");
		
		blinky_box = new FlxSprite();
		blinky_box.scrollFactor.set(0, 0);
		AnimImporter.loadGraphic_from_data_with_id(blinky_box, 8, 8, "DialogueBox", "blinker");
		blinky_box.animation.play("on");
		
		
		// The height has to be even or else you get half-pixel errors at a 2x scale...
		main_display = new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH,false, "assets/sprites/ui/9slice_dialogue.png");
		main_display.alpha = MAIN_DISPLAY_MAX_ALPHA;
		main_display.scrollFactor.set(0, 0);
		portrait.scrollFactor.set(0, 0);
		
		box_highlight = new FlxSprite();
		box_highlight.scrollFactor.set(0, 0);
		AnimImporter.loadGraphic_from_data_with_id(box_highlight, -1, -1, "DialogueBox", "highlight");
		
		item_image = new FlxSprite();
		item_image.exists = false;
		item_image.scrollFactor.set(0, 0);
		
		//add(box);
		add(item_image);
		add(main_display);
		add(arrow);
		add(box_highlight);
		add(portrait);
		add(speaker_text);
		add(text);
		add(blinky_box);
		add(yesno_box);
		add(yesno_selector);
		add(yesno_text);
		
	}
	public function align_text_box_elements(left:Bool = true,top:Bool=true, custom_box_x:Float = -1, custom_box_y:Float = -1,no_portrait:Bool=false):Void {
		
		// Align dialogue box
		if (custom_box_x == -1) {
			if (!left) {
				custom_box_x = FlxG.width - main_display.width - 16;
			} else {
				custom_box_x = 16;
			}
		}
		if (custom_box_y == -1) {
			if (top) {
				custom_box_y = 16;
			} else {
				custom_box_y = FlxG.height - 16 - main_display.height;
			}
		}
		main_display.x = custom_box_x;
		main_display.y = custom_box_y;
		
		//  if forced x or y position, then dont run this code segment
		if (speaker_none && !is_forced_main_display_coords) {
			main_display.y = 32;
			main_display.x = (FlxG.width - main_display.width) / 2;
		}
		
		if (IS_SCREEN_AREA && !is_forced_main_display_coords) {
			main_display.y = 256 - main_display.height - 16;
		}
		
		
		// Move dialogue box visual elements
		//if (left) {
			portrait.scale.x = 1;
			box_highlight.animation.play("long");
			portrait.x = main_display.x + 11;
			if (no_portrait) {
				text.x = main_display.x + 9;
			} else {
				text.x = portrait.x + portrait.width + 9;
			}
		//} else {
			//portrait.scale.x = -1;
			//box_highlight.animation.play("short");
			//portrait.x = main_display.x + main_display.width - 11 - portrait.width;
			//text.x = main_display.x + 14;
		//}
		
		box_highlight.x = main_display.x + 1;
		box_highlight.y = main_display.y + 8;
		portrait.y = main_display.y + 11 -4;	
		text.y = main_display.y + 24;
		speaker_text.x = text.x;
		if (R.dialogue_manager.get_langtype() == 1 || R.dialogue_manager.get_langtype() == 2) {
			speaker_text.y = box_highlight.y + box_highlight.height - speaker_text.height;
			text.y = main_display.y + 20;
		} else if (R.dialogue_manager.is_other()) {
			speaker_text.y = main_display.y + 6;
		} else {
			speaker_text.y = main_display.y + 10;
		}
		if (!has_name) {
			text.y = speaker_text.y;
		}
	}
	
	public function set_arrow(speaker_x:Float, speaker_y:Float, box_left:Bool = true, box_top:Bool = true, no_arrow:Bool = false,speaker_precedence:Int=0):Void {
		if (no_arrow) {
			if (box_top) {
				main_display.paste_bottom_chunk();
			} else {
				main_display.paste_bottom_chunk(false);
			}
			return;
		} else {
			arrow.alpha = main_display.alpha;
		}
		if (box_top) {
			if (box_left) {
				arrow.animation.play("dr");
			} else {
				arrow.animation.play("dl");
			}
			arrow.y = main_display.y + main_display.height - 2;
		}  else {
			if (box_left) {
				arrow.animation.play("ur");
			} else {
				arrow.animation.play("ul");
			}
			arrow.y = main_display.y - arrow.height + 2;
		}
		
		speaker_x = speaker_x - FlxG.camera.scroll.x;
		speaker_y = speaker_y - FlxG.camera.scroll.y;
		
		var arrow_x:Float = speaker_x;
		if (is_left) arrow_x -= arrow.width;
		if (arrow_x > main_display.x + main_display.width - arrow.width - 2) {
			arrow_x = main_display.x + main_display.width - arrow.width - 2;
		} else if (arrow_x < main_display.x + 6) { 
			arrow_x = main_display.x + 6;
			if (box_top) {
				box_left ? arrow.animation.play("dl") : arrow.animation.play("dr");
			} else {
				box_left ? arrow.animation.play("ul") : arrow.animation.play("ur");
			}
		}
		
		arrow.x = Std.int(arrow_x);
		
		
		if (is_top) {
			main_display.paste_bottom_chunk();
			main_display.cut_bottom_chunk(Std.int(arrow_x - main_display.x) , Std.int(arrow.width), 2);
		} else {
			main_display.paste_bottom_chunk(true);
			main_display.cut_bottom_chunk(Std.int(arrow_x - main_display.x) , Std.int(arrow.width), 2,false);
		}
	}
	
	public function change_visuals(VISTYPE:Int):Void {
		switch (VISTYPE) {
			case _ if (VISTYPE == VISTYPE_DEBUG):
				//box.makeGraphic(C.GAME_WIDTH - 20, 60, 0xbb000000);
		}
	}
	
	private var cur_line_idx:Int = 0;
	private var cur_char_idx:Int = 0;
	private var nr_lines_visible:Int = 0;
	private var nr_chars_per_iter:Int = 1;
	public var max_visible_lines:Int = 3;
	private var fast_transition_out:Bool = false;
	
	private var tm_bump_up:Float = 0.20;
	private var t_bump_up:Float = 0;
	private var px_bump_up:Int = 4;
	
	private var t_append_next_char:Float = 0;
	private var tm_append_next_char:Float = 0.03;
	private var tick_next_char:Int = 0;
	
	
	private var start_new_dialogue_after_current_one_ends:Bool = false;
	private var start_new_dialogue_msp:String;
	private var cur_map:String = "";
	private var cur_scene:String = "";
	
	private var blinky_box:FlxSprite;
	private var t_blink:Float;
	private var tm_blink:Float;
	
	private var auto_bump:Bool = false;
	private var lines_to_bump:Int = 0;
	
	private var item_image_mode:Int = 0;
	private var item_image_out_at_end:Bool = false;
	override public function update(elapsed: Float):Void {
		super.update(elapsed);
		
		
		if (move_cam_up && is_active()) {
			if (FlxG.camera.scroll.y <= 0) {
				move_cam_up = false;
			}
			if (NewCamTrig.active_cam != null && FlxG.camera.scroll.y <= NewCamTrig.active_cam.y) { 
				move_cam_up = false;
				speaker_none = true; // So arrow doesnt show weirdly
			} else if (FlxG.camera.y + 256 - (R.player.y + R.player.height - FlxG.camera.scroll.y) >= 84) {

				FlxG.camera.scroll.y -= 2;
				FlxG.camera._scrollTarget.y -= 2;
				//Log.trace(2);
				
				
				main_display.y = speaker_y - FlxG.camera.scroll.y - main_display.height - arrow.height - 7;
				if (main_display.y < 16) main_display.y = 16;
				
				box_highlight.y = main_display.y + 8;
				portrait.y = main_display.y + 11 -4;	
				text.y = main_display.y + 24;
				if (R.dialogue_manager.get_langtype() == 1 || R.dialogue_manager.get_langtype() == 2) {
					text.y = main_display.y + 20;
					speaker_text.y = box_highlight.y + box_highlight.height - speaker_text.height;
				} else {
					speaker_text.y = main_display.y + 10;
				}
				if (speaker_text.text.length <= 2) {
					text.y = speaker_text.y;
				}
				
			} else {
				move_cam_up = false;
				//Log.trace(1);
			}
		} else {
			move_cam_up = false;
		}
		
		switch (item_image_mode) {
			case 0:
			case 1: // in
				item_image.exists = true;
				//item_image.velocity.x = (2 * (FlxG.width / 2 + item_image.width / 2)) / 0.4;
				//item_image.acceleration.x = -item_image.velocity.x / 0.5;
				//item_image.x = -item_image.width;
				item_image.alpha = 0;
				item_image.x = (FlxG.width / 2 - item_image.width / 2);
				//if (speaker_none) {
					//item_image.y = main_display.y + main_display.height + 16;
				//} else {
					item_image.y = (FlxG.height / 2 - item_image.height / 2);
				//}
				item_image_mode = 3;
			case 2: // out
				//var vx:Float = (2 * (FlxG.width / 2 + item_image.width / 2)) / 0.4;
				//item_image.acceleration.x = vx / 0.45;
				item_image_mode = 4;
			case 3:	
				//if (item_image.x > (FlxG.width / 2 - item_image.width / 2)) {
				item_image.alpha += 0.02;
				if (item_image.alpha >= 1) {
					//item_image.velocity.x = item_image.acceleration.x = 0;
					item_image_mode = 0;
				}
				//}
			case 4:
				//if (item_image.x > FlxG.width) {
					//item_image.acceleration.x = item_image.velocity.x = 0;
				item_image.alpha -= 0.04;
				if (item_image.alpha <= 0) {
					item_image.exists = false;
					item_image_mode = 0;
				}
				//}
		}
		
		switch (mode) {
			case _ if (mode == MODE_TRANSITION_IN):
				
				if (skip_to_yesno) {
					mode = MODE_WAIT_FOR_INPUT;
					return;
				}
				
				if (move_cam_up) { 
				
				} else if (transition_ctr == 0) {
					main_display.scale.set(0.05, 0.05);
					main_display.alpha = 0.1;
					set_alpha_zero();
					transition_ctr = 1;
					main_display.paste_bottom_chunk();
				} else if (transition_ctr == 1) {
					
					if (R.speed_opts[0]) {
						main_display.scale.x = 1;
						main_display.scale.y = 1;
					}
					
					main_display.scale.x *= 1.25;
					if (main_display.scale.x > 1) {
						main_display.scale.set(1, 1);
						portrait.alpha = text.alpha = speaker_text.alpha = box_highlight.alpha = arrow.alpha = blinky_box.alpha = 1;
						if (!has_highlight) {
							box_highlight.alpha = 0;
						}
						has_highlight = false;
						arrow.alpha = MAIN_DISPLAY_MAX_ALPHA;
						transition_ctr = 0;
						
						mode = MODE_PLAYING;
					} else {
						main_display.scale.y = main_display.scale.x;
					}
					main_display.alpha = MAIN_DISPLAY_MAX_ALPHA * main_display.scale.x;
				} 
			case _ if (mode == MODE_TRANSITION_OUT):
				if (transition_ctr == 0) {
					if (item_image_out_at_end) {
						item_image_out_at_end = false;
						item_image_mode = 2;
					}
					main_display.paste_bottom_chunk();
					portrait.alpha = text.alpha = speaker_text.alpha = box_highlight.alpha = arrow.alpha = blinky_box.alpha =  0;
					transition_ctr = 1;
				} else if (transition_ctr == 1) {
					if (fast_transition_out) {
						fast_transition_out = false;
						main_display.scale.x = main_display.scale.y = main_display.alpha = 0.04;
					}
					main_display.scale.x *= 0.65;
					if (R.speed_opts[0]) {
						main_display.scale.x = 0.04;
						main_display.scale.y = 0.04;
						main_display.alpha = MAIN_DISPLAY_MAX_ALPHA * main_display.scale.x;
					}
					
					if (main_display.scale.x < 0.05 && item_image_mode == 0) {
						main_display.alpha = 0;
						transition_ctr = 0;
						mode = MODE_CLEANUP;
					} else {
						main_display.scale.y = main_display.scale.x;
						main_display.alpha = MAIN_DISPLAY_MAX_ALPHA * main_display.scale.x;
					}
				}
			case _ if (mode == MODE_IDLE):
			case _ if (mode == MODE_WAIT_FOR_INPUT_ON_FORCED_PAUSE):
				if (R.input.jpCONFIRM || R.speed_opts[0] || FlxG.keys.pressed.TAB) {
					mode = MODE_PLAYING;
				}
			case _ if (mode == MODE_PLAYING):
				
			case _ if (mode == MODE_WAIT_FOR_INPUT_TO_BUMP):
				if (R.input.CONFIRM || R.speed_opts[0] || FlxG.keys.pressed.TAB || auto_bump) {
					if (!auto_bump) {
						lines_to_bump = max_visible_lines;
						auto_bump = true;
					}
					var newline_index:Int = text.text.indexOf("\n");
					text.text = text.text.substr(newline_index + 1);
					text.y += px_bump_up;
					mode = MODE_BUMP_UP;
					if (lines_to_bump > 0) {
						lines_to_bump --;
						if (lines_to_bump == 0) {
							auto_bump = false;
						}
					}
				}
			case _ if (mode == MODE_BUMP_UP):
				t_bump_up += FlxG.elapsed;
				if (t_bump_up > tm_bump_up || R.speed_opts[0] || FlxG.keys.pressed.TAB) {
					text.y -= px_bump_up;
					t_bump_up = 0;
					mode = MODE_PLAYING;
				}
			case _ if (mode == MODE_CLEANUP):
				lines = [];
				auto_bump = false;
				text.text = " ";
				exists = false;
				mode = MODE_IDLE;
				if (!start_new_dialogue_after_current_one_ends) {
					external_speaker_entity = null;
				}
				
				if (R.there_is_a_cutscene_running == false && unpause_player_after_cleanup) {
					if (R.player.exists) {
						R.player.no_shielding_till_release = true;
						R.player.pause_toggle(false);
					} else if (R.worldmapplayer.exists) {
						R.worldmapplayer.pause_toggle(false);
						R.TEST_STATE.train.pause_toggle(false);
					} else if (R.realplayer.exists) {
						R.realplayer.pause_toggle(true);
					}
				}
				
				if (start_new_dialogue_after_current_one_ends) {
					start_new_dialogue_after_current_one_ends = false;
					
					
					reset_script_effects(true);
					if (start_new_dialogue_msp != "") {
						var args:Array<String> = start_new_dialogue_msp.split(",");
						if (args.length > 2) {
							start_dialogue(args[0], args[1], Std.parseInt(args[2]));
						} else {
							start_dialogue(args[0], args[1]);
						}
					} else {
						start_dialogue(cur_map, cur_scene);
					}
				} else {
					unpause_player_after_cleanup = true;
					reset_script_effects(true);
				}
			case _ if (mode == MODE_WAIT_FOR_INPUT):
				if (R.input.jpCONFIRM || R.speed_opts[0] || skip_to_yesno) {
					if (do_yes_no) {
						mode = MODE_YES_NO;
						yesno_text.text = yes_no_choices.join("\n");
						
						yesno_box.resize(16 + yesno_text.width, (yesno_text.lineHeight + yesno_text.lineSpacing) * yes_no_choices.length + 8);
						yesno_box.x = (C.GAME_WIDTH - yesno_box.width) / 2;
						
						yesno_box.visible = yesno_text.visible =  yesno_selector.visible = true;
						yesno_box.alpha = yesno_text.alpha = yesno_selector.alpha = 0;
						
						if (IS_SCREEN_AREA) {
							yesno_box.y = main_display.y - yesno_box.height - 8;
							yesno_box.x = C.GAME_WIDTH - yesno_box.width - 16;
						} else {
							yesno_box.y = 120;
						}
						yesno_text.x = yesno_box.x + 8;
						yesno_text.y = yesno_box.y + 8;
						if (fontIsBig) yesno_text.y -= 3;
						if (R.dialogue_manager.is_other()) yesno_text.y -= 2;
						yesno_selector.x = yesno_text.x - yesno_selector.width - 2;
						yesno_selector.y = yesno_text.y + 4 - yesno_selector.height / 2;
						if (fontIsBig) {
							yesno_selector.y += 3;
						}
						yesno_selector.animation.play("empty");
						yesno_index = 0;
						yesno_selector.ID = 0;
					} else {
						if (start_new_dialogue_after_current_one_ends) {
							fast_transition_out = true;
						}
						mode = MODE_TRANSITION_OUT;
					}
				}
			case _ if (mode == MODE_INFOPAGE) :
				if (yesno_no_leave == -1) {
					mode = MODE_YES_NO;
				}
			case _ if (mode == MODE_YES_NO) :
				
				
				if (yesno_selector.alpha < main_display.alpha) {
					yesno_selector.alpha += 0.06;
					yesno_selector.alpha *= 1.05;
				} else {
					yesno_selector.alpha = main_display.alpha;
				}
				if (skip_to_yesno) {
					yesno_selector.alpha = 1;
				}
				yesno_box.alpha = yesno_text.alpha = yesno_selector.alpha;
				
				if (R.input.jpUp) {
					R.sound_manager.play(SNDC.menu_move);
					if (yesno_index > 0) {
						yesno_index -- ;
						yesno_selector.y -= yesno_text.lineHeight + yesno_text.lineSpacing;
					}
				} else if (R.input.jpDown) {
					R.sound_manager.play(SNDC.menu_move);
					if (yesno_index < yes_no_choices.length -1) {
						yesno_index ++;
						yesno_selector.y += yesno_text.lineHeight + yesno_text.lineSpacing;
					}
				} else if (R.input.CONFIRM) {
					if (yesno_selector.ID == 0) {
						if (R.input.jpCONFIRM) {
							R.sound_manager.play(SNDC.menu_move);
							if (yesno_selector.animation.curAnim != null && yesno_selector.animation.curAnim.name == "empty") {
								yesno_selector.animation.play("fill");
								yesno_selector.ID = 1;
							} 
						}
					} else if (yesno_selector.ID == 1) {
						
						
						if (yesno_selector.animation.finished) {
						
						R.sound_manager.play(SNDC.menu_confirm);	
						// If set to > -1, this value is what choice you need to leave.
						// Otherwise an info box spawns
						if (yesno_no_leave != -1) {
							if (yesno_index == yesno_no_leave) {
								yesno_no_leave = -1;
							} else {
								mode = MODE_INFOPAGE;
								last_yn = yesno_index;
								yesno_selector.animation.play("empty");
								yesno_selector.ID = 0;
								return;
							}
						}
					yesno_box.visible = yesno_text.visible = yesno_selector.visible = false;
					
					
					// If the vlaue is a "later:n" directive, then we still exit the box
					// but we modify what the next line of dialogue will be, via overriding
					// the default of pos+1 
					if (Std.is(yes_no_next_positions[yesno_index], String)) {
						R.dialogue_manager.set_position(yesno_map, yesno_scene, Std.parseInt(yes_no_next_positions[yesno_index].split(":")[1]));
						yes_no_next_positions[yesno_index] = -1;
					}
					
					skip_to_yesno = false;
					// If the next position is set to -1 by any means, exit the dialogue.
					if (yes_no_next_positions[yesno_index] == -1) {
						mode = MODE_TRANSITION_OUT;
						last_yn = yesno_index;
						return;
					}
					
					// Otherwise load up the next chunk of dialogue
					do_yes_no = false;
					lines = [];
					text.text = " ";
					mode = MODE_TRANSITION_IN;
					
					run_scripts_and_get_next_dialogue(yesno_map, yesno_scene, yes_no_next_positions[yesno_index]);
					
					main_display.alpha = 0;
					portrait.alpha = text.alpha = speaker_text.alpha = box_highlight.alpha = arrow.alpha = 0;
					
					// run_scripts...() resets last_yn, so restore it here b/c we might use it in an NPC script
					last_yn = yesno_index;
					}
					}
				} else {
					yesno_selector.animation.play("empty");
					yesno_selector.ID = 0;
				}
				
		}
		
		if (mode == MODE_PLAYING || mode == MODE_WAIT_FOR_INPUT_ON_FORCED_PAUSE || mode == MODE_WAIT_FOR_INPUT_ON_FORCED_PAUSE || mode == MODE_WAIT_FOR_INPUT_TO_BUMP || mode == MODE_WAIT_FOR_INPUT || mode == MODE_BUMP_UP || mode == MODE_YES_NO) {
			set_arrow_based_on_speaker();
		}
		
		blinky_box.x = main_display.x + main_display.width - 16;
		blinky_box.y = main_display.y + main_display.height - 16;
		if (mode == MODE_WAIT_FOR_INPUT || mode == MODE_WAIT_FOR_INPUT_ON_FORCED_PAUSE || mode == MODE_WAIT_FOR_INPUT_TO_BUMP) {
			t_blink += FlxG.elapsed;
			if (t_blink > 0.5) {
				t_blink = 0;
				blinky_box.visible = !blinky_box.visible;
			}
		} else {
			blinky_box.visible = false;
			t_blink = 0;
		}
		/* Till get sprite */
		blinky_box.visible = false;
	}
	
	private var do_wait:Bool = false;
	private var t_wait:Float = 0;
	private var do_play:Bool = false;
	override public function draw():Void 
	{
		do_play = !do_play;
		if (FlxG.drawFramerate == 30) {
			do_play = true;
		}
		
		if (do_wait) {
			t_wait -= FlxG.elapsed;
			if (t_wait < 0) {
				do_wait = false;
			}
		}
		if (!do_wait && mode == MODE_PLAYING && do_play) {
			tick_mode_playing();
		}
		super.draw();
		
	}
	
	/**
	 * Make a dialogue box pop up with the given map and scene. Pauses the player/train
	 * @param	map
	 * @param	scene
	 */
	public function start_dialogue(map:String, scene:String, pos:Int = -1):Void {
		if (mode != MODE_IDLE) {
			// Ignore ??
			return;
		}
		
		MOST_RECENT_CALLED_BOX = this;
		cur_map = map;
		cur_scene = scene;
		exists = true;
		R.player.pause_toggle(true);
		if (R.activePlayer == R.worldmapplayer) {
			R.worldmapplayer.pause_toggle(true);
		}
		R.TEST_STATE.train.pause_toggle(true);
		if (R.activePlayer == R.realplayer){
			R.realplayer.pause_toggle(true);
		}
		mode = MODE_TRANSITION_IN;
		
		run_scripts_and_get_next_dialogue(map, scene, pos);
		main_display.alpha = box_highlight.alpha = speaker_text.alpha = text.alpha = portrait.alpha = arrow.alpha = blinky_box.alpha = 0;
	}
	public function is_active():Bool {
		if (mode == MODE_IDLE) {
			return false;
		}
		return true;
		
	}
	
	private function get_lines(map:String,scene:String,pos:Int=-1):Array<String> 
	{
		var _lines:Array<String> = R.dialogue_manager.get_dialogue(map.toLowerCase(), scene.toLowerCase(),pos);
		if (_lines == null) {
			_lines = ["No scene "+scene+" in map "+map];
		} else if (_lines == []) {
			_lines = ["??? " + scene + " " + map];
		}
		return _lines;
	}
	
	public var next_additional_scripts:Array<Array<String>>;
	private function get_scripts(map:String,scene:String,pos:Int=-1):Void 
	{
		var scripts:Array<Array<String>> = R.dialogue_manager.get_scripts(map.toLowerCase(), scene.toLowerCase(), pos);
		var script:Array<String> = [];
		// If a GNPC sets this then ignore old scripts on the gnpc..
		if (R.dialogue_manager.in_game_force_dialogue != "") {
			scripts = [];
			R.dialogue_manager.in_game_force_dialogue = StringTools.replace(R.dialogue_manager.in_game_force_dialogue, "_", " ");
		}
		if (next_additional_scripts != null) {
			for (s in next_additional_scripts) {
				scripts.push(s);
			}
		}
		next_additional_scripts = null;
		
		if (speaker_always_none) {
			speaker_none = true;
		}
		
		for (script in scripts) {
			var script_type:String = script[0];
			
			
			if (script_type == "yn") {
				do_yes_no = true;
				yesno_map = map.toLowerCase();
				yesno_scene = scene.toLowerCase();
				yes_no_choices = []; // "yn" 
				yes_no_next_positions = [];
				for (i in 1...script.length) {
					if (i % 2 == 1) {
						yes_no_choices.push(script[i]);
					} else {
						if (script[i].indexOf("later") != -1) {
							yes_no_next_positions.push(script[i]);
						} else {
							if (script[i].indexOf(":") != -1) {
								var show_args:Array<String> = script[i].split(":");
								var push_it:Bool = true;
								for (i in 1...show_args.length) {
									if (show_args[i].indexOf("i") != -1) { // Item condition
										if (R.inventory.is_item_found(Std.parseInt(show_args[i].substr(1)))) {
											if (show_args.length > 2 && show_args[2] == "0") {
												push_it = false;
											}
										} else { // ITem is not found
											// show the choice if we want it not found
											if (show_args.length > 2 && show_args[2] == "0") {
											} else {
												push_it = false;
											}
										}
										break;
									} else if (show_args[i].indexOf("e") != -1) { // Event condition
										if (show_args.length > 2 && show_args[2] == "0") {
												if (R.event_state[(Std.parseInt(show_args[i].substr(1)))] == 0) {

												} else {
													push_it = false;
												}
													 
										} else {
											if (R.event_state[(Std.parseInt(show_args[i].substr(1)))] != 0) {
												
											} else {
												push_it = false;
											}
										}
									} else if (show_args[i].indexOf("s") != -1) {
										// (N):s(n):m,S
										var which_one:Int = Std.parseInt(show_args[i].substr(1));
										var __map:String = show_args[i + 1].split(",")[0];
										var __scene:String = show_args[i + 1].split(",")[1];
										
										// Require the scene state to be 0
										if (show_args.length > i + 2 && show_args[i + 2] == "0") {
											if (R.dialogue_manager.get_scene_state_var(__map, __scene, which_one) == 0) {
											} else {
												push_it = false;
											}
										// require the scene state to be nonzero
										} else if (R.dialogue_manager.get_scene_state_var(__map, __scene, which_one) != 0) {
										} else {
											push_it = false;
										}
										break; // so we dn't run this loop again on the map,scene arg -_-
									}
									
								}
								if (push_it) {
									yes_no_next_positions.push(Std.parseInt(show_args[0]));
								} else {
									yes_no_choices.pop();
								}
							} else {
								yes_no_next_positions.push(Std.parseInt(script[i]));
							}
						}
					}
				}
			} else if (script_type == "after") {
				forced_next_pos = Std.parseInt(script[1]);
			} else if (script_type == "item") {
				var item_id:Int = Std.parseInt(script[1]);
				var new_value:Int = Std.parseInt(script[2]);
				R.inventory.set_item_found(0, item_id, new_value == 1);
			} else if (script_type == "inc_plays") {
				R.dialogue_manager.change_plays(map, scene, 1);
			} else if (script_type == "im") {
				start_new_dialogue_after_current_one_ends = true;
				if (script.length > 1) {
					start_new_dialogue_msp = script[1];
				} else {
					start_new_dialogue_msp = "";
				}
			} else if (script_type == "set_state") {
				if (script.length > 4) {
					R.dialogue_manager.change_scene_state_var(script[3], script[4], Std.parseInt(script[1]), Std.parseInt(script[2]));
				} else {
					if (script[1] == "1") {
						R.dialogue_manager.change_scene_state_var(map, scene, 1, Std.parseInt(script[2]));
					} else {
						R.dialogue_manager.change_scene_state_var(map, scene, 2, Std.parseInt(script[2]));
					}
				}
			//  %%skip_if%i%4%true%map%scene%pos%%
			} else if (script_type == "skip_if" || script_type == "skipif") {
				var do_skip_if:Bool = false;
				if (script[1] == "i") {
					if (R.inventory.is_item_found(Std.parseInt(script[2])) && script[3] == "true") {
						do_skip_if = true;
					} else if (!R.inventory.is_item_found(Std.parseInt(script[2])) && script[3] == "false") {
						do_skip_if = true;
					}
				} else if (script[1] == "e") {
					if (R.event_state[Std.parseInt(script[2])] == Std.parseInt(script[3])) {
						do_skip_if = true;
					}
				} else if (script[1] == "dirty") {
					if (R.dialogue_manager.get_times_a_scene_is_played(map, scene) > 0) {
						do_skip_if = true;
					}
				} else if (script[1] == "s") {
					if (script.length > 8) {
						if (R.dialogue_manager.get_scene_state_var(script[7], script[8], Std.parseInt(script[2])) == Std.parseInt(script[3])) {
							do_skip_if = true;
						}
					} else {
						if (R.dialogue_manager.get_scene_state_var(map, scene, Std.parseInt(script[2])) == Std.parseInt(script[3])) {
							do_skip_if = true;
						}
					}
				} else if (script[1] == "r") { 
					var choices:Array<Int> = script[2].split(",").map(Std.parseInt);
					var idx:Int = Std.int(Math.random() * choices.length);
					if (script.length < 4) {
						skip_if_map = map; skip_if_scene = scene;
						skip_if_pos = choices[idx];
					} else {
						
					}
				}
				if (do_skip_if) {
					if (script[4] != "*") {
						skip_if_map = script[4];
					} else {
						skip_if_map = map;
					}
					if (script[5] != "*") {
						skip_if_scene = script[5];
					} else {
						skip_if_scene = scene;
					}
					skip_if_pos = Std.parseInt(script[6]);
				}
			} else if (script_type == "aliph") {
				speaker_is_player = has_portrait = has_name =  true;
				if (external_speaker_entity == null) {
					external_speaker_entity = cast R.activePlayer;
				}
				portrait.animation.play("Aliph");
				voice_name = "Aliph";
				speaker_next_name = speaker_text.text = R.dialogue_manager.lookup_sentence("portrait_names", "names", 1);
			} else if (script_type == "speaker") {
				if (speaker_always_none) {
					continue;
				}
				if (script[1] == "p") {
					speaker_is_player = true;
				} else if (script[1] == "c") {
					speaker_is_child = Std.parseInt(script[2]);
				} else if (script[1] == "g") {
					speaker_is_gnpc_created_sprite = Std.parseInt(script[2]);
				} else if (script[1] == "none") {
					speaker_none = true;
				}
					
			} else if (script_type == "pic") {
				has_portrait = true;
				portrait.animation.play(script[1]);
				var nam:String = "";
				if (GenericNPC.generic_npc_data.get("portrait_table").exists(script[1])) {
					voice_name = script[1];
					var idx:Int = GenericNPC.generic_npc_data.get("portrait_table").get(script[1]);	
					nam = R.dialogue_manager.lookup_sentence("portrait_names", "names", idx);
				} else {
					nam = "???";
					Log.trace("pic title " + script[1] + " has no corresponding name");
				}
				speaker_text.text = nam;
				if (has_name == false) { // let the name script override the auto-name from a pic
					has_name = true;
					speaker_next_name = speaker_text.text;
				}
			} else if (script_type == "name") {
				has_name = true;
				speaker_next_name = script[1];
				voice_name = script[1];
			} else if (script_type == "sound") {
				has_sound = true;
				next_sound = script[1];
			} else if (script_type == "center_down") {
				force_next_main_display_position((C.GAME_WIDTH - main_display.width) / 2, C.GAME_HEIGHT - main_display.height - 16);
			} else if (script_type == "center") {
				force_next_main_display_position((C.GAME_WIDTH - main_display.width) / 2, (C.GAME_HEIGHT - main_display.height)/2);
			} else if (script_type == "box_pos") {
				force_next_main_display_position(Std.parseFloat(script[1]), Std.parseFloat(script[2]));
			} else {
				Log.trace("No script " + script_type);
			}
		}
	}
	
	public function force_next_main_display_position(_x:Float, _y:Float):Void {
		is_forced_main_display_coords = true;
		forced_x = _x;
		forced_y = _y;
	}
	private function reset_script_effects(skip_forced_next_pos:Bool = false):Void {
		if (!skip_forced_next_pos) {
			forced_next_pos = -1;
		}
		start_new_dialogue_after_current_one_ends = false;
		is_forced_main_display_coords = false;
		do_yes_no = false;
		speaker_is_player = false;
		speaker_none = false;
		has_name = false;
		speaker_is_child = -1;
		speaker_is_gnpc_created_sprite = -1;
		voice_name = "";
	}
	
	private var skip_if_map:String = "";
	private var skip_if_scene:String = "";
	private var skip_if_pos:Int = -1;
	public var speaker_x:Float = 0;
	public var speaker_y:Float = 0;
	public var speaker_is_player:Bool = false;
	public var has_portrait:Bool = false;
	public var speaker_is_child:Int = -1;
	public var speaker_is_gnpc_created_sprite:Int = -1;
	public var speaker_none:Bool = false;
	public var is_left:Bool = false;
	public var is_top:Bool = false;
	public var forced_x:Float = -1;
	public var forced_y:Float = -1;
	public var is_forced_main_display_coords:Bool = false;
	public var fontIsBig:Bool = false; // True for chinese/jp
	/**
	 * The GenericNPC that called this
	 */
	public var external_speaker_entity:MySprite = null;
	private function run_scripts_and_get_next_dialogue(map:String,scene:String,pos:Int=-1):Void 
	{
		voice_name = "";
		last_yn = -1;
		forced_next_pos = -1;
		var loops:Int = 0;
		map = map.toLowerCase();
		scene = scene.toLowerCase();
		// Get scripts. Among other things, this can affect the speaker position and portraits.
		while (true) {
			if (loops > 100) {
				Log.trace("Too many loops in scripts!!!" + map + ":" + scene + ":" + Std.string(pos));
				break;
			}
			skip_if_map = skip_if_scene = "";
			skip_if_pos = -1;
			//Log.trace(3);
			get_scripts(map, scene, pos);
			
			if (skip_if_map != "") {
				reset_script_effects();
				cur_map = map = skip_if_map;
				cur_scene = scene = skip_if_scene;
				pos = skip_if_pos;
				loops++;
				continue;
			}
			break;
		}
		
		// voice_name is set via NAME, or via PIC. NAME takes precedence
		voice_name = GenericNPC.generic_npc_data.get("voice_table").get(voice_name);
		if (voice_name == null) {
			voice_name = "dialogue_blip_normal.wav";
		}
		
		if (speaker_none && true && main_display.height != DEFAULT_NO_NAME_BOX_HEIGHT) {// TODO: Ignore this code block if a forced box size is specified
			main_display.resize(main_display.width, DEFAULT_BOX_HEIGHT);
			
			//main_display.resize(104, DEFAULT_NO_NAME_BOX_HEIGHT*3+6);
		} else if (!speaker_none && main_display.height != DEFAULT_BOX_HEIGHT) {
			main_display.resize(main_display.width, DEFAULT_BOX_HEIGHT);
		}
		
		set_speaker_x_y();
		set_box_alignment();
		
		
		// Only allow map pos override if I didn't assign the box_pos already
		if (!is_forced_main_display_coords) {
			if (R.TEST_STATE.MAP_NAME == "MAP1" || R.TEST_STATE.MAP_NAME == "MAP2"  || R.TEST_STATE.MAP_NAME == "MAP3") {
				is_forced_main_display_coords = true;
				forced_y = 170;
				forced_x = 57;
			}
		}
		
		// if no forced y/x:
		main_display.x = -1;
		//Log.trace([speaker_none, is_forced_main_display_coords, forced_x, forced_y]);
		if (!speaker_none && !is_forced_main_display_coords) {
			if (is_top) {
				main_display.y = speaker_y - FlxG.camera.scroll.y - main_display.height - arrow.height - 7;
				if (main_display.y < 16) main_display.y = 16;
			} else {
				main_display.y = speaker_y - FlxG.camera.scroll.y + arrow.height + 7 + 24;
				if (main_display.y + main_display.height > FlxG.height - 16) main_display.y = FlxG.height - main_display.height - 16;
			}
			
			// fuckkk 
				if (main_display.y + main_display.height > FlxG.height - 16) main_display.y = FlxG.height - main_display.height - 16;
		} else  if (is_forced_main_display_coords) {
			main_display.y = forced_y;
			main_display.x = forced_x;
		} else {
			main_display.y = -1;
		}
		
		//is_left = true;
		align_text_box_elements(is_left, is_top,main_display.x,main_display.y,!has_portrait);
		is_left = true;
		
		var portrait_extra_spacing:Int = 0;
		if (has_portrait) {
			portrait_extra_spacing = 40 + 12;
		}
		
		if (!has_portrait) {
			portrait.animation.play("blank");
			speaker_text.text = " ";
		} 
		
		// %%name%name...%% script overrides animation name
		if (has_name) {
			has_highlight = true;
			has_name = false;
			speaker_text.text = speaker_next_name;
		}
		
		has_portrait = false;

		set_arrow_based_on_speaker();
		
		MAX_CHARS_PER_LINE = Std.int((main_display.width - 11 - portrait_extra_spacing - 14) / text.font.spaceWidth);
		//Log.trace(["before_get_lines",MAX_CHARS_PER_LINE,portrait_extra_spacing]);
		if (MAX_CHARS_PER_LINE < 10) MAX_CHARS_PER_LINE = 10;
		max_visible_lines = Std.int(((main_display.y + main_display.height + text.lineSpacing) - (text.y) - 9) / R.dialogue_manager.DIALOGUE_LINE_HEIGHT);
		if (max_visible_lines < 1) max_visible_lines = 1;
		// hack for chinese/jp to show up right 
		fontIsBig = false;
		var langType:Int = R.dialogue_manager.get_langtype();
		if (langType == 1 || langType == 2 || R.dialogue_manager.is_other()) {
			fontIsBig = true;
			if (max_visible_lines == 2) max_visible_lines = 3;
		}
		if (fontIsBig) {
			if (MAX_CHARS_PER_LINE < 14) MAX_CHARS_PER_LINE = 14;
		}
		
		
		/* Get the lines */
		lines = get_lines(map, scene, pos);
		if (forced_next_pos != -1) {
			R.dialogue_manager.set_position(map,scene,forced_next_pos);
		}
		
		if (has_sound) {
			R.sound_manager.play(next_sound);
			has_sound = false;
		}
	
	}
	
	function tick_mode_playing():Void 
	{
		
		if (R.editor.editor_active) {
			start_new_dialogue_after_current_one_ends = false;
			mode = MODE_CLEANUP;
			return;
		} 
		// Don't advance when dialogue panning, but advacne if waiting for return signal
		//if (R.TEST_STATE.is_dialogue_panning && !TestState.di_pan_waiting_for_return_signal) {
			//return;
		//}
		//Log.trace([main_display.exists, main_display.visible, main_display.x, main_display.y, main_display.scrollFactor]);
		if (R.input.CONFIRM) {
			nr_chars_per_iter = 3;
		} else {
			nr_chars_per_iter = 1;
		}
		
		if (R.speed_opts[0] || FlxG.keys.pressed.TAB) {
			nr_chars_per_iter = 500;
		}
		
		var skip_chars:Int = 0;
		var end_brace:Int = -1;
		//for (i in 0...nr_chars_per_iter) {
		var i:Int = 0;
		while (i < nr_chars_per_iter) {
			
			if (Utf8.charCodeAt(lines[cur_line_idx],cur_char_idx) == 94) {
				cur_char_idx++;
				mode = MODE_WAIT_FOR_INPUT_ON_FORCED_PAUSE;
				return;
			}
			
			if (cur_char_idx > end_brace && Utf8.charCodeAt(lines[cur_line_idx], cur_char_idx) == Utf8.charCodeAt("{", 0)) {
				var a:Array<Dynamic> = R.dialogue_manager.get_brace_script(lines[cur_line_idx], cur_char_idx);
				if (a[0] != 0) {
					var script:String = a[2];
					end_brace = a[1];
					skip_chars = a[0];
					
					//Log.trace(script);
					
					var script_args:Array<String> = script.split(",");
					switch (script_args[0]) {
						case "SOUND":
							R.sound_manager.play(script_args[1]);
						case "MUSIC":
							R.song_helper.fade_to_this_song(script_args[1], true);
						case "WAIT":
							if (R.speed_opts[0] == false && !FlxG.keys.pressed.TAB) {
								do_wait = true;
								t_wait = Std.parseFloat(script_args[1]);
							}
						case "PIC":
							portrait.animation.play(script_args[1]);
						case "PAN":
							R.TEST_STATE.set_panning(Std.parseInt(script_args[1]), Std.parseFloat(script_args[2]), Std.parseFloat(script_args[3]), Std.parseFloat(script_args[4]));
							// PAN,ID,T,VEL_IN,VEL_OUT
						case "IMAGE_IN":
							var iw:Int = 0;
							var ih:Int = 0;
							var a:Array<Int> = [];
							var fr:Int = 0;
							//Log.trace(script_args);
							if (script_args.length > 2) {
								var parts:Array<String> = script_args[2].split(" ");
								switch (parts[0]) {
									case "ANIM":
										iw = Std.parseInt(parts[1]);
										ih = Std.parseInt(parts[2]);
										fr = Std.parseInt(parts[3]);
										for (i in 4...parts.length) {
											a.push(Std.parseInt(parts[i]));
										}
								}
							}
							
							item_image.myLoadGraphic(Assets.getBitmapData("assets/sprites/" + script_args[1]), true, false, iw, ih);
							if (a.length > 2) {
								item_image.animation.add("a", a, fr);
								item_image.animation.play("a");
							}
							item_image_mode = 1;
						case "IMAGE_OUT":
							item_image_mode = 2;
						case "IMAGE_OUT_AT_END":
							//Log.trace("hi");
							item_image_out_at_end = true;
							
					}
				}
			}
			
			// Note even if a brace-script makes us skip chars we still increment the character count
			if (skip_chars > 0) {
				skip_chars --;
				i--;
				// exit the adding text loop after skipping the thing in case it's ap an script and 
				// 3 char at a time are being added so ast o not add junk
				if (skip_chars == 0) {
					i = 1; nr_chars_per_iter = 1;
				}
			} else {
				if (do_wait) {
					break;
				}
				if (text.text == " ") {
					var utf:Utf8 = new Utf8();
					utf.addChar(Utf8.charCodeAt(lines[cur_line_idx], cur_char_idx));
					text.text = utf.toString();
					//text.text = lines[cur_line_idx].charAt(cur_char_idx);
				} else {
					var utf:Utf8 = new Utf8();
					utf.addChar(Utf8.charCodeAt(lines[cur_line_idx], cur_char_idx));
					text.text += utf.toString();
					//text.text += lines[cur_line_idx].charAt(cur_char_idx);
				}
				if (blip_wait > 0) {
					blip_wait --;
 				} else {
					//Log.trace(voice_name);
					if (!FlxG.keys.pressed.TAB && !R.speed_opts[0] && !R.access_opts[17]) {
						R.sound_manager.play(voice_name);
					}
					blip_wait = Std.int(3.0  + Std.int(1 * Math.random()));
					if (nr_chars_per_iter > 1) {
						blip_wait += 8;
					}
				}
			}
			cur_char_idx ++;
			if (cur_char_idx >=  Utf8.length(lines[cur_line_idx])) {
				cur_char_idx = 0;
				cur_line_idx ++;
				text.text += "\n";
				nr_lines_visible ++;
			}
			if (cur_line_idx == lines.length) {
				cur_line_idx = 0;
				nr_lines_visible = 0;
				mode = MODE_WAIT_FOR_INPUT;
				auto_bump = false;
				break;
				
			}	else if (nr_lines_visible == max_visible_lines) {
				nr_lines_visible--;
				mode = MODE_WAIT_FOR_INPUT_TO_BUMP;
				break;
			}
			i++;
		}
	}
	private var blip_wait:Int = 0;
	
	// to-do
	// boxes need to flip sides
	// custom y offset from top
	// boxes on bottom?
	
	private function set_speaker_x_y():Void {
		if (external_speaker_entity != null && !speaker_none) {
			// Then the player, or a child is speaking
			if (speaker_is_player) {
				speaker_x = R.activePlayer.x + R.activePlayer.width / 2;
				speaker_y = R.activePlayer.y;
			} else if (speaker_is_child > -1 && external_speaker_entity.children[speaker_is_child] != null) {
				speaker_x = external_speaker_entity.children[speaker_is_child].x + external_speaker_entity.children[speaker_is_child].width / 2;
				speaker_y = external_speaker_entity.children[speaker_is_child].y  + 8;
			} else if (speaker_is_gnpc_created_sprite > -1) {
				var g:GenericNPC = cast external_speaker_entity;
				if (g.sprites.members[speaker_is_gnpc_created_sprite] != null) {
					speaker_x = g.sprites.members[speaker_is_gnpc_created_sprite].x + g.sprites.members[speaker_is_gnpc_created_sprite].width / 2;
					speaker_y = g.sprites.members[speaker_is_gnpc_created_sprite].y  + 8;
				}
			} else {
				speaker_x = external_speaker_entity.x + external_speaker_entity.width / 2;
				speaker_y = external_speaker_entity.y + 8;
			}
		} else {
			speaker_x = speaker_y = 0;
		}
	}
	
	private var move_cam_up:Bool = false;
	private function set_box_alignment():Void {
		if ((speaker_x - FlxG.camera.scroll.x) < FlxG.width / 2) {
			is_left = true;
		} else {
			is_left = false;
			
		}
		
		if ((speaker_y - FlxG.camera.scroll.y) < 96) {
			if (speaker_y > 96) {
				is_top = true;
				move_cam_up = true;
				TestState.truly_set_default_cam(R.TEST_STATE.tm_bg.width, R.TEST_STATE.tm_bg.height);
			} else {
				is_top = false;
			}
		} else {
			is_top = true;
		}
	}
	private function set_arrow_based_on_speaker():Void 
	{
		set_speaker_x_y();
		if (external_speaker_entity != null && !speaker_none) {
			set_arrow(speaker_x, speaker_y, is_left, is_top, false, 0);
		} else {
			arrow.alpha = 0;
			set_arrow(0, 0, is_left, is_top, true);
		}
	}
	
	function set_alpha_zero():Void 
	{
		portrait.alpha = text.alpha = speaker_text.alpha = box_highlight.alpha = arrow.alpha = 0;
	}

}