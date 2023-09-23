package entity.ui;

import autom.SNDC;
import flixel.text.FlxBitmapText;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import global.C;
import global.Registry;
import haxe.Log;
import haxe.Utf8;
import help.AnimImporter;
import help.HF;
import openfl.Assets;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class NameEntry extends FlxGroup
{
	
	public var chars:FlxBitmapText;
	public var cursor:FlxSprite;
	public var row:Int = 0;
	public var column:Int = 0;
	public var cur_name:FlxBitmapText;
	public var random_text:FlxBitmapText;
	public var OKAY_text:FlxBitmapText;
	public var lang_mode:Int = 0;
	public var bg:NineSliceBox;
	public var R:Registry;
	public var w:Int;
	public var h:Int;
	public var cursor_set:Int = 0;
	public var pos_marker:FlxSprite;
	private var random_names:Array<String>;
	private var random_names_index:Int = 0;
	private var name_bg:NineSliceBox;
	private var info_bg:NineSliceBox;
	private var info_text:FlxBitmapText;
	public function new(MaxSize:Int=0, _name:String="") 
	{
		super(MaxSize, _name);
		cur_name = HF.init_bitmap_font();
		random_text = HF.init_bitmap_font();
		OKAY_text = HF.init_bitmap_font();
		cursor = new FlxSprite();
		chars = HF.init_bitmap_font();
		
		pos_marker = new FlxSprite();
		pos_marker.makeGraphic(8, 1);
		pos_marker.scrollFactor.set(0, 0);
		//pos_marker.alpha = 0;
		bg = new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH,false, "assets/sprites/ui/9slice_dialogue.png");
		name_bg = new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH,false, "assets/sprites/ui/9slice_dialogue.png");
		info_bg = new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH,false, "assets/sprites/ui/9slice_dialogue.png");

		R = Registry.R;
		bg.makeGraphic(200, 200, 0xff0000ff);
		bg.move(50, 50);
		AnimImporter.loadGraphic_from_data_with_id(cursor, 7, 7, "MenuSelector", "arrow");
		cursor.animation.play("r_on");
		for (d in [cur_name, random_text, OKAY_text, cursor, chars,bg, name_bg,info_bg]) {
			d.scrollFactor.set(0, 0);
		}
		cur_name.text = "";
		// change later
		random_names = ["Donald", "Lauren", "Nakata", "Yasujiro", "Sandy", "John", "Teresa"];
		random_text.text = "Don't Care";
		OKAY_text.text = "Done";
		random_text.x = chars.x;
		random_text.y = chars.y + chars.height;
		name_bg.scrollFactor.set(0, 0); OKAY_text.scrollFactor.set(0, 0);
		info_text = HF.init_bitmap_font();
		
		add(bg);
		add(info_bg);
		add(info_text);
		add(random_text); 
		add(chars);
		add(name_bg);
		add(pos_marker);
		add(cur_name);
		add(OKAY_text);
		add(cursor); 
		
		cur_name.double_draw = true;
		random_text.double_draw = true;
		chars.double_draw = true;
		OKAY_text.double_draw = true;
		info_text.double_draw = true;
		
		bg.alpha = name_bg.alpha = 0.85;
		
	}
	
	private var mode:Int = 0;
	
	public function turn_on(s:String=""):Void {
		mode = 10;
		chars.alpha = bg.alpha = name_bg.alpha = random_text.alpha = cursor.alpha = OKAY_text.alpha = cur_name.alpha = pos_marker.alpha = 0;

		set_lang(0);
		bg.x = (C.GAME_WIDTH - bg.width) / 2;
		bg.y = C.GAME_HEIGHT - bg.height - 20;
		
		chars.x = bg.x + 8; 
		chars.y = bg.y + 8;
		name_bg.x = chars.x;
		name_bg.y = chars.y - name_bg.height - 10;
		
		cur_name.x = name_bg.x + 8;
		cur_name.y = name_bg.y + 4;
		cur_name.text = "";
		random_text.x = chars.x;
		random_text.y = chars.y + chars.height+2;
		
		textset(s);
		
		info_bg.scale.set(0.01, 0.01);
		
		OKAY_text.x = random_text.x + random_text.width + 10;
		OKAY_text.y = random_text.y;
		
		cursor_set = 0;	
		cursor.visible = true;
		
		cursor.animation.play("r_on");
		row = column = 0;
		set_cursor(column, row);
		
		pos_marker.x = cur_name.x + (cur_name.font.spaceWidth + cur_name.letterSpacing) * (Utf8.length(cur_name.text));
		pos_marker.y = cur_name.y + cur_name.height + 1;
		
	}
	private var MAX_NAME_SIZE:Int = 12;
	//tested that stuff works with kanji
	private function set_lang(i:Int):Void {
		chars.alignment = "left";
		if (i == 0) {
			chars.text = "abcde ABCDE 12345\nfghij FGHIJ 67890\nklmno KLMNO !@#$%\npqrst PQRST &*() \nuvwxy UVWXY -_=+~\nz     Z   .,;:\"'?";
			lang_mode = i;
			w = 17;
			h = 6;
			MAX_NAME_SIZE = 12;
			bg.resize(16 + chars.width, 16 + chars.height + 12);
			name_bg.resize(16 + MAX_NAME_SIZE * (chars.font.spaceWidth + chars.letterSpacing), 8 + chars.lineHeight);
			
		}
	}
	
	private function set_cursor(column:Int, row:Int):Void {
		cursor.x = chars.x - cursor.width + column * (chars.font.spaceWidth + chars.letterSpacing);
		cursor.y = chars.y + row * (chars.lineHeight + chars.lineSpacing);
		
	}
	
	public function textset(s:String=""):Void 
	{
		R.dialogue_manager.FORCE_LINE_SIZE = 40;
		if (s == "") {
			s = R.dialogue_manager.lookup_sentence("ui", "name_entry_box", 0);
		}
		random_text.text = R.dialogue_manager.lookup_sentence("ui", "name_entry_box", 1);
		OKAY_text.text = R.dialogue_manager.lookup_sentence("ui", "name_entry_box",2);
		info_text.alignment = "left";
		info_text.text = s;
		R.dialogue_manager.FORCE_LINE_SIZE = -1;
		info_bg.resize(info_text.width + 8, info_text.height + 8);
		info_bg.x = (C.GAME_WIDTH - info_bg.width) / 2;
		info_bg.y = name_bg.y - info_bg.height - 8;
		info_text.x = info_bg.x + 4;
		info_text.y = info_bg.y + 4;
		info_bg.alpha = 0.9;
		info_text.visible = false;
	}
	public var returnword:String = "";
	public function is_done():Bool {
		return mode == 0;
	}
	public function update_font():Void {
		
	//private var info_text:FlxBitmapText;
	//public var chars:FlxBitmapText;
	//public var cur_name:FlxBitmapText;
	//public var random_text:FlxBitmapText;
	//public var OKAY_text:FlxBitmapText;
		var bm:FlxBitmapText = null;
		var i:Int = 0;
		bm = HF.init_bitmap_font(info_text.text, "left", Std.int(info_text.x), Std.int(info_text.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.alpha = info_text.alpha;  bm.visible = info_text.visible;  i = members.indexOf(info_text); members[i] = bm; info_text.destroy(); info_text = cast members[i];
		
		bm = HF.init_bitmap_font(chars.text, "left", Std.int(chars.x), Std.int(chars.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.alpha = chars.alpha;  bm.visible = chars.visible;  i = members.indexOf(chars); members[i] = bm; chars.destroy(); chars = cast members[i];
		
		bm = HF.init_bitmap_font(cur_name.text, "left", Std.int(cur_name.x), Std.int(cur_name.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.alpha = cur_name.alpha;  bm.visible = cur_name.visible;  i = members.indexOf(cur_name); members[i] = bm; cur_name.destroy(); cur_name = cast members[i];
		
		bm = HF.init_bitmap_font(random_text.text, "left", Std.int(random_text.x), Std.int(random_text.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.alpha = random_text.alpha;  bm.visible = random_text.visible;  i = members.indexOf(random_text); members[i] = bm; random_text.destroy(); random_text = cast members[i];
		
		bm = HF.init_bitmap_font(OKAY_text.text, "left", Std.int(OKAY_text.x), Std.int(OKAY_text.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.alpha = OKAY_text.alpha;  bm.visible = OKAY_text.visible;  i = members.indexOf(OKAY_text); members[i] = bm; OKAY_text.destroy(); OKAY_text = cast members[i];
		
		
		textset();
	
	}
	override public function update(elapsed: Float):Void 
	{
		super.update(elapsed);
		if (mode == 0) {
			
		} else if (mode == 10) {
			info_bg.scale.x += 0.05;
			info_bg.scale.y += 0.05;
			if (info_bg.scale.x >= 1) {
				info_bg.scale.set(1, 1);
				info_text.visible = true;
				mode = 1;
			}
		} else if (mode == 1) {
			
			cur_name.alpha += 0.02;
			chars.alpha = bg.alpha = name_bg.alpha = random_text.alpha = cursor.alpha = OKAY_text.alpha = pos_marker.alpha = cur_name.alpha;

			if (bg.alpha > 0.85) {
				bg.alpha = name_bg.alpha = 0.85;
			}
			if (cur_name.alpha >= 1) {
				mode = 2;
			}
		} else if (mode == 2) {
			if (R.input.jpPause) {
				cursor.x = OKAY_text.x - cursor.width - 2;
				cursor.y = OKAY_text.y;
				cursor_set = 1;
			}
			//// RANDOM / DONE
			if (cursor_set == 1) {
				if (R.input.jpUp) {
					cursor_set = 0;
					row = h - 1;
					set_cursor(column, row);
					R.sound_manager.play(SNDC.menu_move);
				} else if (R.input.jpDown) {
					cursor_set = 0;
					row = 0;
					set_cursor(column, row);
				} else if (R.input.jpRight) {
					if (cursor.x != OKAY_text.x - cursor.width - 2) {
						cursor.x = OKAY_text.x - cursor.width - 2;
						R.sound_manager.play(SNDC.menu_move);
					}
				} else if (R.input.jpLeft) {
					if (cursor.x != random_text.x - cursor.width - 2) {
						cursor.x = random_text.x - cursor.width - 2;
						R.sound_manager.play(SNDC.menu_move);
					}
				} else if (R.input.jpCONFIRM) {
					if (cursor.x == random_text.x - cursor.width - 2) {
						R.sound_manager.play(SNDC.menu_confirm);
						cur_name.text = random_names[random_names_index];
						random_names_index++;
						if (random_names_index == random_names.length) { 
							random_names_index = 0;
						}
					} else {
						if (Utf8.length(cur_name.text) > 0) {
							returnword = cur_name.text;
							mode = 0;
						} else {
							R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
						}
					}
				}
				
				pos_marker.x = cur_name.x + (cur_name.font.spaceWidth + cur_name.letterSpacing) * (Utf8.length(cur_name.text));
				pos_marker.y = cur_name.y + cur_name.height + 1;
			//// LETTERS
			} else {
			if (R.input.jpLeft) {
				R.sound_manager.play(SNDC.menu_move);
				if (column > 0) {
					column--;
				} else {
					column = w - 1;
				}
			} else if (R.input.jpRight) {
				R.sound_manager.play(SNDC.menu_move);
				if (column < w - 1) {
					column++;
				} else {
					column = 0;
				}
			}
			if (R.input.jpDown) {
				R.sound_manager.play(SNDC.menu_move);
				if (row < h - 1) {
					row++;
				} else {
					cursor_set = 1;
					cursor.x = random_text.x - cursor.width - 2;
					cursor.y = random_text.y;
					if (column > 10) cursor.x = OKAY_text.x - cursor.width - 2;
					return;
				}
			} else if (R.input.jpUp) {
				R.sound_manager.play(SNDC.menu_move);
				if (row > 0) {
					row--;
				} else {
					cursor_set = 1;
					cursor.x = random_text.x - cursor.width - 2;
					cursor.y = random_text.y;
					if (column > 10) cursor.x = OKAY_text.x - cursor.width - 2;
					return;
				}
			}
			set_cursor(column, row);
			
			if (R.input.jpCONFIRM) {
				if (Utf8.length(cur_name.text) == MAX_NAME_SIZE) {
					R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
				} else {
					R.sound_manager.play(SNDC.menu_confirm);
					var u:Utf8 = new Utf8();
					u.addChar(Utf8.charCodeAt(chars.text, (w + 1) * row + column));
					cur_name.text += u.toString();
				}
			} else if (R.input.jpCANCEL) {
				if (Utf8.length(cur_name.text) > 0) {
					cur_name.text = Utf8.sub(cur_name.text, 0, Utf8.length(cur_name.text) - 1);
					R.sound_manager.play(SNDC.menu_cancel);
				}
			}
			
			if (Utf8.length(cur_name.text) == MAX_NAME_SIZE) {
				pos_marker.visible = false;
			} else {
				pos_marker.visible = true;
			}
			pos_marker.x = cur_name.x + (cur_name.font.spaceWidth + cur_name.letterSpacing) * (Utf8.length(cur_name.text));
			pos_marker.y = cur_name.y + cur_name.height + 1;
			
		}
		
	}
	}
	
}