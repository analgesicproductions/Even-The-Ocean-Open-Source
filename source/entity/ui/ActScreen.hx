package entity.ui;
import autom.SNDC;
import flixel.text.FlxBitmapText;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import global.C;
import global.Registry;
import haxe.Log;
import haxe.Utf8;
import help.DialogueManager;
import help.HF;
import openfl.Assets;
import openfl.display.BlendMode;
import state.MyState;
import state.TestState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class ActScreen extends FlxGroup
{

	public var title:FlxBitmapText;
	public var subtitle:FlxBitmapText;
	public var bg:FlxSprite;
	public var bg2:FlxSprite;
	public var lights:FlxTypedGroup<FlxSprite>;
	public var mask:FlxSprite;
	
	private var R:Registry;
	public function new() 
	{
		super();
		curlang = DialogueManager.CUR_LANGTYPE;
		R = Registry.R;
	}
	
	private var sta:MyState;
	private var curlang:Int = 0;
	private var is_pretitle:Bool = false;
	
	public function activate(act:Int, st:MyState):Void {
		if (mode != 0) return;
		is_pretitle = false;
		if (act == 0) is_pretitle = true;
		if (bg == null) {
			bg = new FlxSprite();
			bg2 = new FlxSprite();
			mask = new FlxSprite();
			lights = new FlxTypedGroup<FlxSprite>();
			
			add(bg);
			add(bg2);
			add(lights);
			add(mask);
			
			for (i in 0...24) {
				var light:FlxSprite = new FlxSprite();
				lights.add(light);
			}
			
		}
		
		var prefix:String = "assets/sprites/ui/act/act" + Std.string(act);
		if (act == 0) {
			prefix = "assets/sprites/ui/act/pretitle";
		}
		
		bg.myLoadGraphic(Assets.getBitmapData(prefix+ "_bg.png"), true, false, 416, 256);
		bg2.myLoadGraphic(Assets.getBitmapData(prefix+ "_bg.png"), true, false, 416, 256);
		mask.myLoadGraphic(Assets.getBitmapData(prefix + "_mask.png"), true, false, 416, 256);
		
		for (i in 0...lights.length) {
			var light:FlxSprite = lights.members[i];
			light.myLoadGraphic(Assets.getBitmapData(prefix + "_lights.png"), true, false, 112, 112);
			for (j in 0...4) {
				light.animation.add(Std.string(j), [j], 1);
			}
			light.exists = light.visible = true;
			light.scrollFactor.set(0, 0);
			light.ID = 0;
			light.velocity.set(0, 0);
		}
		
		bg2.animation.add("1", [1]);
		bg2.animation.play("1");
		
		bg.scrollFactor.set(0, 0);
		
		bg2.scrollFactor.set(0, 0);
		
		mask.scrollFactor.set(0, 0);
		
		bg.exists = bg.visible = true;
		bg2.exists = bg2.visible = true;
		mask.exists = mask.visible = true;
		
		if (act > 1) {
			if (R.story_mode) {
				// e.g. act = 2, then act 1 is finished.
				R.achv.unlock(10 + act - 2);
			// main story
			} else if (!R.gauntlet_mode) {
				R.achv.unlock(act - 2);
			}
		}
		
		
		if (title == null) {
			title = HF.init_bitmap_font(" ", "center",0,0,null,C.FONT_TYPE_APPLE_WHITE);	
			subtitle = HF.init_bitmap_font(" ", "center",0,0,null,C.FONT_TYPE_APPLE_WHITE);	
			add(title);
			add(subtitle);
		}
		
		if (curlang != DialogueManager.CUR_LANGTYPE) {
			var idx:Int = members.indexOf(title);
			if (idx != -1 && members[idx] != null) {
				members[idx] = null;
				title.destroy();
				title = HF.init_bitmap_font(" ", "center",0,0,null,C.FONT_TYPE_APPLE_WHITE);
				members[idx] = title;
			}
			idx = members.indexOf(subtitle);
			if (idx != -1 && members[idx] != null) {
				members[idx] = null;
				subtitle.destroy();
				subtitle = HF.init_bitmap_font(" ", "center",0,0,null,C.FONT_TYPE_APPLE_WHITE);
				members[idx] = subtitle;
			}
		}
		curlang = DialogueManager.CUR_LANGTYPE;
		var s:String = R.dialogue_manager.lookup_sentence("ui","act_title",act, true,true);
		
		title.alignment = "left";
		title.text = s;
		title.scrollFactor.set(0, 0);
		title.y = 48;
		title.x = 208 - (title.width) / 2;
		title.alpha = 0;
		title.visible = title.exists = true;
		title.double_draw = true;
		
		
		s = R.dialogue_manager.lookup_sentence("ui","act_subtitle",act, true,true);
		subtitle.alignment = "left";
		subtitle.text = s;
		subtitle.scrollFactor.set(0, 0);
		subtitle.y = title.y + title.height + 16;
		subtitle.x = 208- (subtitle.width) / 2;
		subtitle.alpha = 0;
		subtitle.visible = subtitle.exists = true;
		subtitle.double_draw = true;
		
		bg.alpha = 0;
		bg2.alpha = 0;
		mask.alpha = 0;
		lights.setAll("alpha", 0);
		mode = 1;
		exists = true;
		st.add(this);
		this.sta = st;
		t_light = -1;
		
		if (is_pretitle) {
			subtitle.text = title.text = " ";
		}
		
		
	}
	public function deactivate():Void {
		mode = 0;
		exists = false;
		this.sta.remove(this, true);
	}
	
	public function is_off():Bool {
		if (mode == 0) return true;
		return false;
	}
	public var mode:Int = 0;
	private var t:Int = 0;
	private var t_light:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (mode != 0) {
			t_light++;
			if (t_light > 20) {
				t_light = 0;
			}
			for (i in 0...lights.length) {
				var light:FlxSprite = lights.members[i];
				if (mask.alpha == 1 && (mode == 1 || mode == 2)) {
					// only add a new one every 20 frames
					if (light.ID == 0 && t_light == 0) {
						t_light = 1;
						light.animation.play(Std.string(Std.int(4 * Math.random())), true);
						light.x = 70 + (416 - 70*2 - light.width) * Math.random();
						light.y = 190 + 10 * Math.random();
						light.velocity.y = -10 - 9 * Math.random();
						if (is_pretitle) {
							light.x = 90 + (416 - 90 - 90 - light.width) * Math.random();
							light.y = 126 + 10 * Math.random();
						}
						light.ID = 1;
						light.blend = BlendMode.ADD;
					} else if (light.ID == 1) {
						light.alpha += 0.008;
						light.alpha *= 1.02;
						if (is_pretitle) {
							light.alpha += 0.012;
							light.alpha *= 1.04;
						}
						if (light.alpha >= 1) {
							light.ID = 2;
						}
					} else if (light.ID == 2) {
						if (mode == 1) {
							light.alpha -= 1.0 / 360.0;
						} else {
							light.alpha -= 1.0 / 500.0;
						}
						if (light.alpha <= 0) {
							light.velocity.y = 0;
							light.ID = 0;
						}
					}
				} else if (mode == 3) {
					light.alpha -= 0.022;
					if (light.alpha <= 0) {
						light.velocity.y = 0;
					}
				}
			}
		}
		
		if (mode == 0) {
			
		} else if (mode == 1) {
			if (bg.alpha == 0) {
				t = 0;
				if (!is_pretitle) {
					R.song_helper.fade_to_this_song("intro_scene_short");
				}
			}
			
			if (is_pretitle) {
				bg.alpha = 1;
			}
			bg.alpha += 1 / 60;
			if (bg.alpha >= 1) {
				title.alpha += 1 / 120;
			}
			
			if (R.speed_opts[0] && !is_pretitle) {
				t = 540;
				bg.alpha = 1;
				title.alpha = 1;
			}
			
			if (is_pretitle && t >= 180) {
				mode = 2;
			}
			
			if (t == 540) {
				mode = 2;
				
			}
			mask.alpha = bg.alpha;
		} else if (mode == 2) {
			
			if (R.speed_opts[0] && !is_pretitle) {
				t = 1085;
				subtitle.alpha = 1;
			}
			
			subtitle.alpha += 1 / 200;
			bg2.alpha = subtitle.alpha;
			if (is_pretitle && t >= 560) {
				subtitle.alpha = 1;
				mode = 3;
			}
			if (t == 1085) {
				mode = 3;
				if (!is_pretitle) R.song_helper.fade_to_this_song("null",true);
			}
		} else if (mode == 3) {
			subtitle.alpha -= 1 / 50;
			title.alpha = subtitle.alpha;
			//lights.setAll("alpha", subtitle.alpha);
			if (subtitle.alpha <= 0) {
				mask.alpha = 0;
			}
			bg.alpha -= 1 / 100;
			bg2.alpha = subtitle.alpha;
			if (bg.alpha == 0) {
				deactivate();
				// switch to song in script
			}
		}
		super.update(elapsed);
		
		t++;
	}
	
}