package entity.ui;

import flixel.text.FlxBitmapText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import global.C;
import global.Registry;
import help.HF;
import openfl.geom.Point;
import openfl.Assets;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class EnterAreaEffect extends FlxGroup
{

	private var gradient:FlxSprite;
	private var big_text:FlxBitmapText;
	private var small_text:FlxBitmapText;
	private var flare:FlxSprite;
	private var mode:Int = 0;
	private var t:Float = 0;
	private var tm:Float = 0;
	private var big_x_start_stop:Point;
	private var small_x_start_stop:Point;
	public function new()
	{
		super();
		flare = new FlxSprite();
		gradient = new FlxSprite();
		big_text = HF.init_bitmap_font(" ","left",0,0,null,C.FONT_TYPE_ALIPH_WHITE);
		small_text = HF.init_bitmap_font(" ","left",0,0,null,C.FONT_TYPE_ALIPH_SMALL_WHITE);
		big_x_start_stop = new Point();
		small_x_start_stop = new Point();
		add(gradient);
		add(big_text);
		add(small_text);
		add(flare);
		flare.scrollFactor.set(0, 0);
		big_text.scrollFactor.set(0, 0);
		small_text.scrollFactor.set(0, 0);
		gradient.scrollFactor.set(0, 0);
		flare.alpha = gradient.alpha = small_text.alpha = big_text.alpha = 0;
		small_text.double_draw = big_text.double_draw = true;
	}
	
	public function is_off():Bool {
		if (mode == 0) return true;
		return false;
	}
	public function turn_on(string_id:String="INTRO"):Void {
		mode = 1;
		t = 0;
		flare.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/eae/INTRO_flare.png"), true, false, 256, 256);
		if (Assets.getBitmapData("assets/sprites/ui/eae/" + string_id+"_gradient.png") != null) {
			gradient.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/eae/"+string_id+"_gradient.png"), true, false,416,101);
		} else {
			gradient.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/eae/INTRO_gradient.png"), true, false,416,101);
		}
		flare.alpha = 0;
		gradient.origin.set(0, 0);
		big_text.alpha = 0;
		small_text.alpha = 0;
		gradient.alpha = 0.01;
		gradient.scale.x = 0.3;
		flare.move( -120, -62);
		flare.scale.set(2, 2);
		gradient.y = 45;
		if (string_id == "CITY") {
			gradient.y = 148;
		} else if (string_id == "PASS") {
			gradient.y = 20;
		} else if (string_id == "CLIFF") {
			gradient.y = 138;
		} else if (string_id == "FALLS") {
			gradient.y = 148;
		}
		var big_idx:Int = Registry.R.gnpc.get("enterarea_desc").get(string_id + "_" + "BIG");
		var small_idx:Int = Registry.R.gnpc.get("enterarea_desc").get(string_id + "_" + "SMALL");
		big_text.text = Registry.R.dialogue_manager.lookup_sentence("ui","enterarea_desc",big_idx);
		small_text.text = Registry.R.dialogue_manager.lookup_sentence("ui","enterarea_desc",small_idx);
		big_text.y = gradient.y+20;
		small_text.y = gradient.y+56;
		big_x_start_stop.setTo(14, 46);
		small_x_start_stop.setTo(40, 73);
		this.exists = true;
	}
	public function update_font():Void {
		
		var bm:FlxBitmapText = null;
		var i:Int = 0;
		bm = HF.init_bitmap_font(big_text.text, "left", Std.int(big_text.x), Std.int(big_text.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.alpha = big_text.alpha;  bm.visible = big_text.visible;  i = members.indexOf(big_text); members[i] = bm; big_text.destroy(); big_text = cast members[i];
		
		bm = HF.init_bitmap_font(small_text.text, "left", Std.int(small_text.x), Std.int(small_text.y), null, C.FONT_TYPE_ALIPH_SMALL_WHITE); bm.double_draw = true; bm.alpha = small_text.alpha;  bm.visible = small_text.visible;  i = members.indexOf(small_text); members[i] = bm; small_text.destroy(); small_text = cast members[i];
	}
	override public function update(elapsed: Float):Void 
	{
		flare.exists = false;
		if (mode == 0) {
		} else if (mode == 1) {
			gradient.alpha *= 1.14;
			
			if (Registry.R.speed_opts[0]) {
				gradient.alpha = 0.5;
			}
			
			if (gradient.alpha >= 0.5) {
				mode = 2;
			}
			gradient.scale.x = 0.3 + 0.7 * gradient.alpha;
		} else if (mode == 2) {
			gradient.alpha *= 1.0234;
			
			if (Registry.R.speed_opts[0]) {
				gradient.alpha = 1;
			}
			
			if (gradient.alpha >= 1) {
				gradient.alpha = 1;
				mode = 3;
				big_text.alpha = 0.01;
				big_text.x = big_x_start_stop.x;
				big_text.velocity.x = 30;
				big_text.drag.x = 14;
				flare.angularVelocity = 5;
			}
			gradient.scale.x = 0.3 + 0.7 * gradient.alpha;
		} else if (mode == 3) {
			big_text.alpha *= 1.1;
			
			if (Registry.R.speed_opts[0]) {
				big_text.x = big_x_start_stop.y + 1;
				big_text.alpha = 0.51;
			}
			
			if (big_text.x > big_x_start_stop.y) {
				big_text.x = big_x_start_stop.y;
				big_text.velocity.x = big_text.drag.x = 0;
			}
			flare.alpha = big_text.alpha * 0.25;
			if (big_text.alpha > 0.5) {
				small_text.alpha = 0.01; small_text.x = small_x_start_stop.x; small_text.velocity.x = 30; small_text.drag.x = 14;
				mode = 4;
			}
		} else if (mode == 4) {
			
			if (Registry.R.speed_opts[0]) {
				big_text.alpha = 0.6;
				small_text.alpha = 0.5;
				big_text.velocity.x = 0;
				small_text.velocity.x = 0;
			}
			
			big_text.alpha *= 1.0061;
			small_text.alpha *= 1.09;
			flare.alpha = big_text.alpha * 0.25;
			if (big_text.alpha >= 0.6 && small_text.alpha >= 0.5 && big_text.velocity.x == 0) {
				mode = 5;
			}
		} else if (mode == 5) {
			
			if (Registry.R.speed_opts[0]) {
				small_text.alpha = 0.6;
			}
			small_text.alpha *= 1.0061; // 0.5 sec for 0.5 -> 0.6 alpha
			if (small_text.alpha >= 0.6) {
				mode = 6;
			}
		} else if (mode == 6) {
			
			if (Registry.R.speed_opts[0]) {
				t = 4.5;
			}
			
			if (flare.ID == -1) {
				flare.alpha += .1 / 60;
				if (flare.alpha > 0.35) {
					flare.ID = 1;
				}
			} else if (flare.ID == 1) {
				flare.alpha -= .1 / 60;
				if (flare.alpha < 0.15) {
					flare.ID = -1;
				}
			}
			t += FlxG.elapsed;
			if (t > 4.4 || Registry.R.input.jp_any()) {
				t = 0;
				mode = 7;
			}
		} else if (mode == 7) { // 1.5 sec
			
			
			if (Registry.R.speed_opts[0]) {
				gradient.alpha = 0;
			}
			
			gradient.alpha *= 0.95;
			flare.alpha *= 0.95;
			small_text.alpha *= 0.95;
			big_text.alpha *= 0.95;
			if (gradient.alpha < 0.01) {
				small_text.alpha = big_text.alpha = gradient.alpha = flare.alpha = 0;
				mode = 0;
				this.exists = false;
			}
		}
		if (mode >= 3 || mode <= 6) {
			if (big_text.x > big_x_start_stop.y) {
				big_text.x = big_x_start_stop.y;
				big_text.velocity.x = big_text.drag.x = 0;
			}
			if (small_text.x > small_x_start_stop.y) {
				small_text.x = small_x_start_stop.y;
				small_text.velocity.x = small_text.drag.x = 0;
			}
		}
		super.update(elapsed);
	}
	
}