package entity.ui;

import autom.SNDC;
import flash.display.BitmapData;
import flixel.text.FlxBitmapText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
 
import global.C;
import global.Registry;
import haxe.Log;
import help.DialogueManager;
import help.HF;
import help.InputHandler;
import openfl.Assets;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class TutorialGroup extends FlxGroup
{

	private var bbg:FlxSprite;
	private var bg:FlxSprite;
	private var gif:FlxSprite;
	private var title_text:FlxBitmapText;
	private var text_descriptions:FlxTypedGroup<FlxBitmapText>;
	private var u_icon:FlxSprite;
	private var r_icon:FlxSprite;
	private var d_icon:FlxSprite;
	private var l_icon:FlxSprite;
	private var jump_icon:FlxSprite;
	private var shield_icon:FlxSprite;
	private var pause_icon:FlxSprite;
	
	private var left_l_icon:FlxSprite;
	private var left_jump_icon:FlxSprite;
	private var left_shield_icon:FlxSprite;
	private var left_pause_icon:FlxSprite;
	
	public function new(MaxSize:Int=0, _name:String="") 
	{
		super(MaxSize, _name);
		bg = new FlxSprite();
		bbg = new FlxSprite();
		bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/bg.png"), false, false, FlxG.width, FlxG.height);
		bbg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/bg.png"), false, false,416,256);
		bg.scrollFactor.set(0, 0);
		bbg.scrollFactor.set(0, 0);
		u_icon = new FlxSprite();
		r_icon = new FlxSprite();
		d_icon = new FlxSprite();
		l_icon = new FlxSprite();
		jump_icon= new FlxSprite();
		shield_icon= new FlxSprite();
		pause_icon = new FlxSprite();
		left_jump_icon = new FlxSprite();
		left_shield_icon = new FlxSprite();
		left_pause_icon = new FlxSprite();
		left_l_icon = new FlxSprite();
		youcan_text = HF.init_bitmap_font(" ", "left", 5, 203, null, C.FONT_TYPE_ALIPH_SMALL_WHITE, true);
		var i:Int = 0;
		add(bbg);
		add(bg);
		for (s in [u_icon, r_icon, d_icon, l_icon, shield_icon, jump_icon, pause_icon]) {
			s.scrollFactor.set(0, 0);
			s.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/icons.png"), true, false, 16, 16);
			s.animation.add("a", [i]);
			s.animation.play("a");
			s.visible = false;
			//add(s);
			i++;
		}
		for (s in [left_jump_icon, left_l_icon, left_pause_icon, left_shield_icon]) {
			s.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/icons.png"), true, false, 16, 16);
			s.scrollFactor.set(0, 0);
			
			s.x = 7;
			if (s == left_jump_icon) {
				s.animation.add("a", [5]);
				s.y = 119;
			} else if (s == left_l_icon) {
				s.animation.add("a", [3]);
				s.y = 33;
			} else if (s == left_pause_icon) {
				s.animation.add("a", [6]);
				s.y = 155;
			} else if (s == left_shield_icon) {
				s.animation.add("a", [4]);
				s.y = 77;
			}
			s.animation.play("a");
			s.visible = true;
			//add(s);
		}
		
		text_descriptions = new FlxTypedGroup<FlxBitmapText>();
		title_text = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_ALIPH_WHITE, true);
		add(text_descriptions);
		
		setAll("alpha", 0);
		R = Registry.R;
	}
	
	private function init_text():Void {
		
		for (i in 0...6) {
			var b:FlxBitmapText = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_ALIPH_WHITE, true);
			//b.x = 27;
			//switch (i) {
				//case 0:
					//var ss:String =	R.input.keybindings[InputHandler.KDX_LEFT] + " " + R.input.keybindings[InputHandler.KDX_RIGHT] + "\n" + R.input.keybindings[InputHandler.KDX_UP] + " " + R.input.keybindings[InputHandler.KDX_DOWN];
					//b.text = c(2) + ":\n"+ss+" " + c(1);
					//b.y = 31;
				//case 1:
					//b.text = c(3) + ":\n"+R.input.keybindings[InputHandler.KDX_A2]+" " + c(0);
					//b.y = 73;
				//case 2:
					//b.text = c(4)+":\n"+R.input.keybindings[InputHandler.KDX_A1]+" " + c(0);
					//b.y = 115;
				//case 3:
					//b.text = c(5) + ":\n" + c(6) + "\n"+R.input.keybindings[InputHandler.KDX_PAUSE]+" "+c(0);
					//b.y = 157;
			//}
			b.alpha = 0;
			text_descriptions.add(b);
		}
		text_descriptions.members[4].lineSpacing = 2;
		
		//add(title_text);
		//add(youcan_text);
		//youcan_text.text = c(8);
	}
	private var R:Registry;
	
	private var youcan_text:FlxBitmapText;
	private var done:Bool = false;
	private var did_init:Bool = false;
	public function is_done():Bool {
		if (mode == 3) {
			exists = false;
			return true;
		} 
		return false;
	}
	
	
	private var curpage:Int = 0;
	private var mode:Int = 0;
	public var requested_id:Int = -1;
	public var recent_langtype:Int = -1;
	public function start(d:DialogueBox, tut_id:Int = 0):Void {
		
		mode = 0;
		exists = true;
		dialogue_box = d;
		
		bbg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/bg.png"), false, false,416,256);
		
		tut_id++;
		if (requested_id != -1) {
			cur_tut = requested_id;
			requested_id = -1;
		} else {	
			cur_tut = tut_id;
		}
		
		if (cur_tut > 7) {
			cur_tut = 0;
		}
		title_text.text = R.dialogue_manager.lookup_sentence("intro", "tutorial_titles", cur_tut);
		//add_gif(cur_tut);
		title_text.y = 7;
		title_text.x = 40;
		title_text.alignment = "left";
		if (!did_init) {
			init_text();
			recent_langtype = DialogueManager.CUR_LANGTYPE;
			did_init = true;
		}
		if (recent_langtype != DialogueManager.CUR_LANGTYPE) {
			recent_langtype = DialogueManager.CUR_LANGTYPE;
			text_descriptions.clear();
			init_text();
		}
		//Log.trace(cur_tut);
		if (cur_tut == TUT_ENERGY) {
			//Log.trace(1);
			bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_en_1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
			set_texts("energy", 0);
		} else if (cur_tut == TUT_SHIELD) {
			
			bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_shield_1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
			set_texts("shield", 0);
		} else if (cur_tut == TUT_WALL_CLIMB) {
			
			bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_climb_1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
			set_texts("wallclimb", 0);
		} else if (cur_tut == TUT_WALL_JUMP) {
			
			bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_walljump_1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
			set_texts("walljump", 0);
		} else if (cur_tut == TUT_WORLDMAP) {
			
			bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_map1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
			set_texts("worldmap", 0);
		}else if (cur_tut == TUT_USEMAP) {
			
			bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_usemap1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
			set_texts("usemap", 0);
		}
	}
	private var alpha:Float = 0;
	private var dialogue_box:DialogueBox;
	public var TUT_TEST:Int = 0;
	public var TUT_BASICS:Int = 1;
	public var TUT_SHIELD:Int = 2;
	public var TUT_ENERGY:Int = 3;
	public var TUT_WALL_CLIMB:Int = 4;
	public var TUT_WALL_JUMP:Int = 5;
	public var TUT_WORLDMAP:Int = 6;
	public var TUT_USEMAP:Int = 7;
	private var cur_tut:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		//if (!did_init) {
			//did_init = true;
			//init_text();
		//}
		
		//bbg.visible = true;
		//bbg.exists = true;
		//bbg.alpha = 1;
		//Log.trace([bbg.width, bbg.height, this.members.indexOf(bbg), bbg.scrollFactor]);
		
		if (mode == 0) {
			alpha += 0.03;
			alpha *= 1.1;
			setAll("alpha", alpha);
			if (alpha >= 1) {
				alpha = 1;
				mode = 1;
				curpage = 0;
			}
		} else if (mode == 1) {
			if (cur_tut == TUT_TEST) {
				update_tutorial_TEST();
			} else if (cur_tut == TUT_BASICS) {
				update_tutorial_BASICS();
			} else if (cur_tut == TUT_ENERGY) {
				update_tutorial_ENERGY();
			} else if (cur_tut == TUT_SHIELD) {
				update_tutorial_twopg("shield");
			} else if (cur_tut == TUT_WALL_CLIMB) {
				update_tutorial_twopg("wallclimb");
			} else if (cur_tut == TUT_WALL_JUMP) {
				update_tutorial_twopg("walljump");
			} else if (cur_tut == TUT_WORLDMAP) {
				update_tutorial_twopg("worldmap");
			} else if (cur_tut == TUT_USEMAP) {
				update_tutorial_twopg("usemap");
			} else {
				mode = 2;
			}
		} else if (mode == 2) {
			tut_state = 0;
			alpha -= 0.03;
			alpha *= 0.95;
			setAll("alpha", alpha);
			if (alpha <= 0) {
				alpha = 0;
				mode = 3;
				//remove_gif();
			}
		} else if (mode == 3) {
			
		}
		super.update(elapsed);
	}
	
	private function c(i:Int):String {
		return Registry.R.dialogue_manager.lookup_sentence("intro", "tutorial", i);
	}
	private var tut_state:Int = 0;
	
	private function set_texts(n:String, pg:Int):Void {
		
		text_descriptions.members[2].text = " ";
		text_descriptions.members[1].text = " ";
		text_descriptions.members[3].text = " ";
		text_descriptions.members[5].text = " ";
		// the title
		text_descriptions.members[4].move(34, 228);
		if (n == "energy") {
			text_descriptions.members[4].text = R.dialogue_manager.lookup_sentence("intro", "tut_en", 4, false, true) +" " + "(" + Std.string(pg+1) + "/3)";
			if (pg == 0) {
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_en", 0, false, true);
				text_descriptions.members[1].text = R.dialogue_manager.lookup_sentence("intro", "tut_en", 1, false, true);
				text_descriptions.members[2].text = R.dialogue_manager.lookup_sentence("intro", "tut_en", 2, false, true);
				text_descriptions.members[3].text = R.dialogue_manager.lookup_sentence("intro", "tut_en", 3, false, true);
				center_text_around(0, 188, 38);
				center_text_around(1, 188, 136);
				center_text_around(2,122, 195);
				center_text_around(3, 319, 195);	
				
			} else if (pg == 1) {
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_en", 5, false, true);
				text_descriptions.members[1].text = R.dialogue_manager.lookup_sentence("intro", "tut_en", 6, false, true);
				text_descriptions.members[2].text = R.dialogue_manager.lookup_sentence("intro", "tut_en", 7, false, true);
				center_text_around(0, 197, 44);
				center_text_around(1, 114, 207);
				center_text_around(2, 314, 207);
			} else if (pg == 2) {
				
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_en", 8, false, true);
				text_descriptions.members[1].text = R.dialogue_manager.lookup_sentence("intro", "tut_en", 9, false, true);
				center_text_around(0, 194, 45);
				center_text_around(1, 167, 192);
			}
		} else if (n == "shield") {
			text_descriptions.members[4].text = R.dialogue_manager.lookup_sentence("intro", "tut_shield", 2, false, true) +" " + "(" + Std.string(pg+1) + "/2)";
			if (pg == 0) {
				
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_shield", 0, false, true);
				text_descriptions.members[1].text = R.dialogue_manager.lookup_sentence("intro", "tut_shield", 1, false, true);
				center_text_around(0, 196, 48);
				center_text_around(1, 196, 193);
			} else if (pg == 1) {
				
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_shield", 3, false, true);
				text_descriptions.members[1].text = R.dialogue_manager.lookup_sentence("intro", "tut_shield", 4, false, true);
				text_descriptions.members[2].text = R.dialogue_manager.lookup_sentence("intro", "tut_shield", 5, false, true);
				text_descriptions.members[3].text = R.dialogue_manager.lookup_sentence("intro", "tut_shield", 6, false, true);
				text_descriptions.members[5].text = R.dialogue_manager.lookup_sentence("intro", "tut_shield", 7, false, true);
				center_text_around(0, 202, 45);
				center_text_around(1, 74, 139);
				center_text_around(2, 172, 139);
				center_text_around(3, 302, 139);
				center_text_around(5, 190, 193);
			}
		}else if (n == "wallclimb") {
			text_descriptions.members[4].text = R.dialogue_manager.lookup_sentence("intro", "tut_wallclimb", 2, false, true) +" " + "(" + Std.string(pg+1) + "/2)";
			if (pg == 0) {
				
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_wallclimb", 0, false, true);
				text_descriptions.members[1].text = R.dialogue_manager.lookup_sentence("intro", "tut_wallclimb", 1, false, true);
				center_text_around(0, 133, 62);
				center_text_around(1, 160, 189);
			} else if (pg == 1) {
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_wallclimb", 3, false, true);
				center_text_around(0, 144, 95);
			}
		}else if (n == "walljump") {
			text_descriptions.members[4].text = R.dialogue_manager.lookup_sentence("intro", "tut_walljump", 2, false, true) +" " + "(" + Std.string(pg+1) + "/2)";
			if (pg == 0) {
				
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_walljump", 0, false, true);
				text_descriptions.members[1].text = R.dialogue_manager.lookup_sentence("intro", "tut_walljump", 1, false, true);
				center_text_around(0, 160, 38);
				center_text_around(1, 94, 170);
			} else if (pg == 1) {
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_walljump", 3, false, true);
				center_text_around(0, 124, 85);
			}
		} else if (n == "worldmap") {
			
			text_descriptions.members[4].text = R.dialogue_manager.lookup_sentence("intro", "tut_worldmap", 1, false, true) +" " + "(" + Std.string(pg + 1) + "/2)";
			
			if (pg == 0) {
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_worldmap", 0, false, true);
				center_text_around(0, 132,100);
			} else if (pg == 1) {
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_worldmap", 2, false, true);
				center_text_around(0, 208,80);
			}
		}else if (n == "usemap") {
			
			text_descriptions.members[4].text = R.dialogue_manager.lookup_sentence("intro", "tut_usemap", 1, false, true) +" " + "(" + Std.string(pg + 1) + "/2)";
			
			if (pg == 0) {
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_usemap", 0, false, true);
				center_text_around(0, 200,60);
			} else if (pg == 1) {
				text_descriptions.members[0].text = R.dialogue_manager.lookup_sentence("intro", "tut_usemap", 2, false, true);
				center_text_around(0, 200,60);
			}
		}
		text_descriptions.members[4].text += "\n"+R.dialogue_manager.lookup_sentence("intro", "tut_usemap", 4, false, true);
	}
	private function center_text_around(i:Int, x:Float, y:Float):Void {
		var b:FlxBitmapText = text_descriptions.members[i];
		b.x = x - b.width / 2;
		b.y = y - b.height / 2;
	}
	
	private function pressed_pageturn():Bool {
		return R.input.jpCONFIRM || R.input.jpRight || R.input.jpLeft || R.input.jpCANCEL;
	}
	private function pageturnhelp():Void {
		if (R.input.jpCONFIRM || R.input.jpRight) {
			curpage++;
		} else {
			curpage--;
			if (curpage < 0) curpage = 0;
		}
		R.sound_manager.play(SNDC.menu_move);
	}
	
	private function update_tutorial_ENERGY():Void {
		if (tut_state == 0) {
			if (pressed_pageturn()) {
				pageturnhelp();
				tut_state = 1;
				if (curpage == 3) {
					tut_state = 2;
					mode = 2;
				} else {
					if (curpage == 0) {
						bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_en_1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						set_texts("energy", 0);
					} else if (curpage == 1) {
						bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_en_2.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						set_texts("energy", 1);
					} else if (curpage == 2) {
						bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_en_3.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						set_texts("energy", 2);
					}
				}
			}
		} else if (tut_state == 2) {
				mode = 2;
		} else {
			if (!R.input.CONFIRM) {
				tut_state = 0;
				
			}
		}
	}
	private function update_tutorial_twopg(s:String):Void {
		
		//Log.trace(curpage);
		if (tut_state == 0) {
			if (pressed_pageturn()) {
				pageturnhelp();
				tut_state = 1;
				if (curpage == 2) {
					mode = 2;
				} else {
					if (curpage == 1) {
						if (s == "shield") {
							bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_shield_2.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						} else if (s == "wallclimb") {
							bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_climb_2.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						} else if (s == "walljump") {
							bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_walljump_2.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						} else if (s == "worldmap") {
							bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_map2.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						} else if (s == "usemap") {
							bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_usemap2.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						}
						set_texts(s, 1);
					} else {
						tut_state = 0;
						if (s == "shield") {
							bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_shield_1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						} else if (s == "wallclimb") {
							bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_climb_1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						} else if (s == "walljump") {
							bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_walljump_1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						} else if (s == "worldmap") {
							bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_map1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						}else if (s == "usemap") {
							bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tutorial/tut_usemap1.png"), false, false, C.GAME_WIDTH, C.GAME_HEIGHT);
						}
						curpage = 0;
						set_texts(s, 0);
					}
				}
			}
		} else {
			if (!R.input.CONFIRM) {
				tut_state = 0;
				
			}
		}
	}
	private function update_tutorial_TEST():Void {
		switch (tut_state) {
			case 0:
				tut_state = 1;
			case 1:
				if (fade_in_gif()) {
					dialogue_box.force_next_main_display_position(111, 164);
					dialogue_box.start_dialogue("intro", "tutorial", 7);
					tut_state = 2;
				}
			case 2:
				if (dialogue_box.is_active() == false) {
					tut_state = -1;
				}
			case -1:
				clean_tutorial_sub();
		}
	}
	
	private function update_tutorial_BASICS():Void {
		//switch (tut_state) {
			mode = 2;
		//}
	}
	private function fade_in_gif():Bool {
		if (gif == null) return false;

		gif.alpha *= 1.02;
		if (gif.alpha > 0.97) {
			gif.alpha = 1;
			return true;
		}
		return false;
	}
	private function fade_out_gif():Bool {
		if (gif == null) return false;
		gif.alpha *= 0.97;
		if (gif.alpha < 0.05) {
			gif.alpha = 0;
			return true;
		}
		return false;
	}
	private function clean_tutorial_sub():Void {
		mode = 2;
	}
	
	private static var GIF_ID_TEST:Int = 0;
	private static var GIF_ID_WALK:Int = 1; // Basics
	private static var GIF_ID_TALK:Int = 2; // Basics
	private static var GIF_ID_JUMP:Int = 3; // Basics
	private static var GIF_ID_DARK:Int = 4; // Energy
	private static var GIF_ID_LIGHT:Int = 5; //  Energy
	private static var GIF_ID_DYING:Int = 6; // Energy
	private static var GIF_ID_WALL_SLIDE:Int = 7; // Wall
	private static var GIF_ID_WALL_CLIMB:Int = 8; // Wall
	private static var GIF_ID_WALL_JUMP:Int = 9; // Wall
	private static var GIF_ID_MOVE_SHIELD:Int = 10; // Shield
	private static var GIF_ID_LOCK_SHIELD:Int = 11; // Shield
	
	private static var gif_path_suffixes:Array<String> = ["TUTORIAL_RUN", "TUTORIAL_RUN", "TUTORIAL_RUN", "TUTORIAL_RUN", "TUTORIAL_RUN", "TUTORIAL_RUN", "TUTORIAL_RUN", "TUTORIAL_RUN", "TUTORIAL_RUN", "TUTORIAL_RUN", "TUTORIAL_RUN", "TUTORIAL_RUN"];
	private static var gif_frame_counts:Array<Int> = [60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60];
	private static var gif_frame_sizes:Array<String> = ["128,128", "128,128", "128,128", "128,128", "128,128", "128,128", "128,128", "128,128", "128,128", "128,128", "128,128", "128,128"];
	private var CUR_GIF_PATH:String = "";
	private function add_gif(GIF_ID:Int = 0):Void {
		if (gif != null) {
			Log.trace("tried to add a 2nd gif");
			return;
		}
		gif = new FlxSprite();
		CUR_GIF_PATH = "assets/sprites/ui/tutorial/"+gif_path_suffixes[GIF_ID]+".png";
		gif.myLoadGraphic(Assets.getBitmapData(CUR_GIF_PATH), true, false, Std.parseInt(gif_frame_sizes[GIF_ID].split(",")[0]),Std.parseInt(gif_frame_sizes[GIF_ID].split(",")[1]));
		var nr_frames:Int = gif_frame_counts[GIF_ID];
		gif.scrollFactor.set(0, 0);
		var a:Array<Int> = [];
		for (i in 0...nr_frames) {
			a.push(i);
		}
		gif.animation.add("a", a, 20);
		gif.animation.play("a");
		add(gif);
		gif.x = 98 + ((FlxG.width - 98) - (gif.width) ) / 2;
		gif.y = 24 + (((164 - 24) - (gif.height)) / 2);
		gif.alpha = 0.05;
	}
	private function remove_gif():Void {
		if (gif == null) {
			Log.trace("tried to remove null gif");
			return;
		}
		remove(gif, true);
		gif.destroy();
		gif = null;
		var b:BitmapData = Assets.cache.getBitmapData(CUR_GIF_PATH);
		b.dispose();
		b = null;
		Assets.cache.removeBitmapData(CUR_GIF_PATH);
	}
}