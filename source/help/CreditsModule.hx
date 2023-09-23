package help;

import flixel.text.FlxBitmapText;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import global.C;
import global.Registry;
import haxe.Log;
import openfl.Assets;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class CreditsModule extends FlxGroup
{

	public function new(MaxSize:Int=0, _name:String="") 
	{
		super(MaxSize, "CreditsModule");
		
	}
	
	private var title_sprite:FlxSprite;
	private var text_array:Array<FlxBitmapText>;
	private var sa:Array<FlxSprite>;
	
	private var num_text:Int = 5;
	private var num_sprites:Int = 4;
	private var s_idx:Int = 0;
	private var curObjIsSprite:Bool = false;
	
	
	private var did_init:Bool = false;
	public function activate():Void {
		if (!did_init) {
			did_init = true;
			text_array = [];
			for (i in 0...num_text) {
				var t:FlxBitmapText = HF.init_bitmap_font();
				text_array.push(t);
				t.alignment = "center";
				t.lineSpacing = 3;
				t.ID = -1;
				add(t);
			}
			sa = [];
			for (i in 0...num_sprites) {
				var s:FlxSprite = new FlxSprite();
				s.scrollFactor.set(0, 0);
				add(s);
				s.exists = false;
				sa.push(s);
			}
			
			title_sprite = new FlxSprite();
			//title_sprite.makeGraphic(200, 100, 0xff0000ff);
			title_sprite.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/title/bg_titletext.png"));
			
			title_sprite.scrollFactor.set(0, 0);
			title_sprite.x = (432 - title_sprite.width) / 2;
			title_sprite.y = (256 - title_sprite.height) / 2;
			title_sprite.alpha = 0;
			add(title_sprite);
		}
		reset();
	}
	
	private function reset():Void {
		mode = 1;
		s_idx = 0;
		curObjIsSprite = false;
		
		for (i in 0...num_sprites) {
			sa[i].exists = false;
		}
		for (i in 0...num_text) {
			title_sprite.alpha = 0;
			text_array[i].text = " ";
			text_array[i].y = -10000;
			next_text_idx = 0;
			next_dialogue_idx = 0;
			text_array[i].ID = -1;
			text_array[i].alpha = 1;
		}
		Registry.R.song_helper.fade_to_this_song("rain");
	}
	
	private function is_done():Bool {
		if (mode == 0) {
			return true;
		}
		return false;
	}
		
	private var mode:Int = 0;
	private var next_text_idx:Int = 0;
	private var text_Spacing:Int = 64;
	private var text_vel:Float = 15;
	private var next_dialogue_idx:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (ProjectClass.DEV_MODE_ON && Registry.R.input.a1) {
			if (Registry.R.input.a2) {
				text_vel = 75;
			} else {
				text_vel = 1000;
			}
		} else {
			if (Registry.R.input.a1) {
				text_vel = 75;
			} else {
				text_vel = 25;
			}
		}
		if (mode == 1) {
			title_sprite.alpha += 0.01;
			title_sprite.alpha *= 1.02;
			if (title_sprite.alpha > 0.98) {
				Registry.R.song_helper.fade_to_this_song("credits", true,"null");
				title_sprite.alpha = 1;
				title_sprite.ID = 0;
				mode = 2;
			}
		} else if (mode == 2) {
			title_sprite.ID ++;
			if (title_sprite.ID > 180) {
				title_sprite.alpha -= 0.03;
				title_sprite.alpha *= 0.95;
				if (title_sprite.alpha < 0.03) {
					title_sprite.alpha = 0;
					mode = 3;
					
					Registry.R.dialogue_manager.FORCE_LINE_SIZE = 40;
					
					
					var s:String = Registry.R.dialogue_manager.lookup_sentence("ending", "credits_made_by", 0);
					
					text_array[next_text_idx].text = s;
					text_array[next_text_idx].x = (432 - text_array[next_text_idx].width) / 2;
					text_array[next_text_idx].y = 256;
					text_array[next_text_idx].velocity.y = -text_vel;
					
					next_dialogue_idx = 1;
				}
				
				
			}
		} else if (mode == 3) {
			for (i in 0...text_array.length) {
				text_array[i].velocity.y = -text_vel;
			}
			for (i in 0...sa.length) {
				sa[i].velocity.y = -text_vel;
			}
			
			var loadnext:Bool = false;
			if (curObjIsSprite) {
				if (sa[s_idx].y + sa[s_idx].height < 256 - text_Spacing) {
					loadnext = true;
				}
			} 
			
			if (Registry.R.dialogue_manager.lookup_sentence("ending", "credits", next_dialogue_idx).indexOf(":image") != -1) {
				if (text_array[next_text_idx].y + text_array[next_text_idx].height < (256 - 16)) {
					loadnext = true;
				}
			}
			
			// load next if sprite moved far enough,
			// or cur Object is NOT a sprite and is heigh enouh
		
			if (loadnext || (!curObjIsSprite && text_array[next_text_idx].y + text_array[next_text_idx].height < (256 - text_Spacing))) {
			// If bottom of current text is past a certain point, spawn next text.
				
				
				// if image load image
				var teststr:String = Registry.R.dialogue_manager.lookup_sentence("ending", "credits", next_dialogue_idx);
				if (teststr.indexOf(":image") != -1) {
					s_idx ++;
					if (s_idx == num_sprites) s_idx = 0;
					var sp:FlxSprite = sa[s_idx];
					var fname:String = teststr.split(":")[0];
					if (Assets.exists("assets/sprites/ui/credits/" + fname+".png")) {
						sp.loadGraphic(Assets.getBitmapData("assets/sprites/ui/credits/" + fname+".png"));
						sp.y = 256;
						//sp.y = 6;
						//sp.alpha = 0;
						sp.x = 208 - sp.width / 2;
						sp.velocity.y = -text_vel;
					}
					curObjIsSprite = true;
					sp.exists = true;
				} else {
					// Update text if this isn't the last one
					// Only use a pool of 5 texts.
					next_text_idx ++; 
					if (next_text_idx == text_array.length) next_text_idx = 0;
					text_array[next_text_idx].y = 256;
					
					var s:String = "";
					if (next_dialogue_idx == 0) {
					} else {
						s = Registry.R.dialogue_manager.lookup_sentence("ending", "credits", next_dialogue_idx);
						if (s == "end") {
							s = Registry.R.dialogue_manager.lookup_sentence("ending", "credits", next_dialogue_idx + 1);
							mode = 4;
							// Make it so "THE END" shows up alone
							text_array[next_text_idx].y += (280 - text_Spacing);
						}
					}
					
					
					text_array[next_text_idx].text = s;
					text_array[next_text_idx].x = (432 - text_array[next_text_idx].width) / 2;
					text_array[next_text_idx].velocity.y = -text_vel;
					curObjIsSprite = false;
				}
				
				if (mode != 4) {
					next_dialogue_idx++;
				}
			}
		} else if (mode == 4) {
			if (text_array[next_text_idx].y < (C.GAME_HEIGHT/2 - text_array[next_text_idx].height/2)) {
				text_array[next_text_idx].y = (C.GAME_HEIGHT/2 - text_array[next_text_idx].height/2);
				for (i in 0...text_array.length) {
					text_array[i].velocity.y = 0;	
				}
				mode = 5;
			}
		} else if (mode == 5) {
			if (Registry.R.input.jp_any()) {
				mode = 6;
				//Registry.R.song_helper.fade_to_this_song("null");
				Registry.R.dialogue_manager.FORCE_LINE_SIZE = -1;
			}
		} else if (mode == 6) {
			text_array[next_text_idx].alpha -= 0.03;
			if (text_array[next_text_idx].alpha <= 0) {
				if (Registry.R.story_mode) {
					Registry.R.achv.unlock(Registry.R.achv.story5);
				} else if (!Registry.R.gauntlet_mode) {
					Registry.R.achv.unlock(Registry.R.achv.act5);
				}
				mode = 0;
			}
		}
		super.update(elapsed);
	}
	
}