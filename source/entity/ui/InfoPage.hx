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
import state.TestState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class InfoPage extends FlxGroup
{

	public var text:FlxBitmapText;
	public var sprites:FlxTypedGroup<FlxSprite>;
	public var bg:FlxSprite;
	private var R:Registry;
	public function new() 
	{
		super();
		curlang = DialogueManager.CUR_LANGTYPE;
		sprites = new FlxTypedGroup<FlxSprite>();
		R = Registry.R;
	}
	
	private var sta:TestState;
	private var curlang:Int = 0;
	private var gap_tops:Array<Float>;
	private var gap_heights:Array<Float>;
	public function activate(m:String, s:String, p:Int, st:TestState):Void {
		
		
		if (bg == null) {
			bg = new FlxSprite();
			bg.makeGraphic(432, 256, 0xff303238);
			bg.alpha = 0.8;
			bg.scrollFactor.set(0, 0);
			add(bg);
		}
		bg.exists = bg.visible = true;
		
		if (text == null) {
			text = HF.init_bitmap_font(" ","center",0,0,null,C.FONT_TYPE_ALIPH_WHITE);	
			add(text);
		} 
		add(sprites);
		
		if (curlang != DialogueManager.CUR_LANGTYPE) {
			var idx:Int = members.indexOf(text);
			if (idx != -1 && members[idx] != null) {
				//Log.trace("hi");
				members[idx] = null;
				text.destroy();
				text = HF.init_bitmap_font(" ","center",0,0,null,C.FONT_TYPE_ALIPH_WHITE);
				members[idx] = text;
			}
		}
		curlang = DialogueManager.CUR_LANGTYPE;
		var s:String = R.dialogue_manager.lookup_sentence(m, s, p, true, true);
		s = DialogueManager.justify(s, Std.int((432-48) / text.font.spaceWidth) - 1);
		
		
		text.lineSpacing = 1;
		//text.double_draw = true;
		text.alignment = "left";
		text.text = s;
		text.x = 24;
		text.y = 24;
		text.alpha = 0;
		text.scrollFactor.set(0, 0);
		text.double_draw = true;
		text.visible = text.exists = true;
		//Log.trace(members.indexOf(text));
		//Log.trace(length);
		//Log.trace(text.text);
		mode = 1;
		exists = true;
		st.add(this);
		this.sta = st;
		
		
		gap_tops = [];
		gap_heights = [];
		
		var gap_idx:Int = 0;
		var gap_lh:Int = 0;
		var mm:Int = 0;
		var ss:Array<String> = s.split("\n");
		// hi\n\n\n = 2
		// hi\n\nhi = 3, finds i=1 , gap starts at ch+ls * i

		for (i in 0...ss.length) {
			if (mm == 0) {
				if (ss[i] == "") {
					mm = 1;
					//Log.trace(i);
					gap_idx = i;
					gap_lh = 1;
				}
			} else {
				if (i == ss.length - 1) {
					gap_lh++;
				}
				if (ss[i] != "" || i == ss.length-1) {
					gap_heights.push((text.lineHeight + text.lineSpacing) * gap_lh);
					gap_tops.push((text.lineHeight + text.lineSpacing) * gap_idx);
					//Log.trace(gap_heights[gap_heights.length - 1]);
					//Log.trace(gap_tops[gap_tops.length - 1]);
					mm = 0;
				} else {
					gap_lh++;
				}
			}
		}
		//Log.trace(gap_heights);
		//Log.trace(gap_tops);
		
		// 22 11
		// 22 88
		// 22 220
		// 22 286
		
	}
	public function deactivate():Void {
		this.sta.remove(this, true);
	}
	// x is offset from x=64
	// y is offset from text.y
	public function add_sprite(filename:String, w:Int, h:Int, fidx:Int, gap_idx:Int,x:Float, y:Float):Void {
		var s:FlxSprite = null;
		for (i in 0...sprites.length) {
			s = sprites.members[i];
			if (s != null && !s.exists) {
				break;
			}
			if (i == sprites.length - 1) {
				s = null;
			}
		}
		
		if (s == null) {
			s = new FlxSprite();
			sprites.add(s);
		}
		s.exists = true;
		s.myLoadGraphic(Assets.getBitmapData(filename), true, false, w, h);
		s.animation.add("a", [fidx]);
		s.animation.play("a");
		if (gap_heights == []) {
			s.move(text.x + text.width / 2 - s.width / 2 + x, text.y + text.height + 16 + y + s.height);
		} else {
			s.move(text.x + text.width / 2 - s.width / 2 + x, text.y + gap_heights[gap_idx] / 2 + gap_tops[gap_idx] - s.height / 2 + y);
		}
		//s.move(x + (64 - w / 2), text.y + y);
		s.ID = Std.int(s.y - text.y);
		s.alpha = 0;
		s.scrollFactor.set(0, 0);
		
		return;
	}
	private function is_off():Bool {
		if (mode == 0) return true;
		return false;
	}
	private var mode:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (mode == 0) {
			
		} else if (mode == 1) {
			//Log.trace(text.visible);
			//Log.trace(text.exists);
			//Log.trace(text.x);
			//Log.trace(text.y);
			//Log.trace(members.indexOf(text));
			text.alpha += 0.03;
			for (i in 0...sprites.length) {
				sprites.members[i].alpha = text.alpha;
			}
			bg.alpha = text.alpha;
			if (R.input.jpCANCEL) {
				mode = 2;
				R.sound_manager.play(SNDC.menu_cancel);
			} else if (R.input.down) {
				if (text.y + text.height > 256-8) {
					text.y -= 2;
				}
				
			} else if (R.input.up) {
				if (text.y < 24) {
					text.y += 2;
				}
			}
			for (i in 0...sprites.length) {
				sprites.members[i].y = text.y + sprites.members[i].ID;
			}
			
		} else if (mode == 2) {
			
			text.alpha -= 0.04;
			sprites.setAll("alpha", text.alpha);
			bg.alpha = text.alpha;
			if (text.alpha == 0) {
				mode = 0;
				sprites.setAll("exists", false);
				exists = false;
				deactivate();
			}
		}
		super.update(elapsed);
	}
	
}