package help;

import autom.SNDC;
import flixel.FlxG;
import flixel.text.FlxBitmapText;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import global.C;
import global.Registry;
import haxe.Log;
import haxe.Utf8;
import hscript.Expr;
import hscript.Interp;
import openfl.Assets;
import sys.io.File;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Journal extends FlxGroup
{
	private var R:Registry;
	private var ready_to_exit:Bool = false;

	private var dim:FlxSprite;
	private var mode:Int = 0;
	private var page_type:Int = 0;
	private var did_init:Bool = false;
	
	private var bg:FlxSprite;
	private var fieldguidecover:FlxSprite;
	private var titles:FlxTypedGroup<FlxSprite>;
	private var title_texts:FlxTypedGroup<FlxBitmapText>;
	private var	text_desc:FlxBitmapText;
	private var text_header:FlxBitmapText;
	private var screenshot:FlxSprite;
	
	private var idx_cursor:Int = 0;
	private var idx_title:Int = 0;
	private var title_strings:Map<String,String>;
	private var desc_strings:Map<String,String>;
	
	private var title_ent_strings:Array<String>;
	private var desc_ent_strings:Array<String>;
	
	private var viewable_ids:Array<String>;
	private var viewable_ent_ids:Array<Int>;
	
	private var down_held:Bool = false;
	private var t_down:Float = 0;
	private var up_held:Bool = false;
	private var t_up:Float = 0;
	private var down_mode:Int = 0;
	private var up_mode:Int = 0;
	public function new() 
	{
		super(0, "Journal");
		R = Registry.R;
	}
	
	private var cur_ids:Int;
	override public function update(elapsed: Float):Void 
	{
		
		if (page_type == 0) {
				screenshot.alpha = 0;
			text_desc.y = title_texts.members[0].y;
			if (R.dialogue_manager.is_chinese()) {
				text_desc.y -= 50;
			} else if (R.dialogue_manager.is_other()) {
				text_desc.y -= 50;
			}
		} else {
			text_desc.y = 89;
			screenshot.alpha = bg.alpha;
		}
		if (mode == 0) {
			// Fade in
			bg.alpha += 0.03;
			bg.alpha *= 1.1;
			
			titles.setAll("alpha", bg.alpha);
			title_texts.setAll("alpha", bg.alpha);
			screenshot.alpha = bg.alpha;
			text_desc.alpha = bg.alpha;
			text_header.alpha = bg.alpha;
			fieldguidecover.alpha = bg.alpha;
			dim.alpha = bg.alpha;
			
			if (page_type == 0) {
				screenshot.alpha = 0;
			}
			
			if (bg.alpha >= 1) {
				mode = 1;
			}
		} else if (mode == 1) {
			// Move and change display
			
			// this is bad bc i messed up but it works 
			if (down_mode == 0) {
				if (R.input.down) {
					t_down++;
					if (t_down > 14) {
						t_down = 0;
						down_mode = 1;
						down_held = true;
					}
				} else {
					t_down = 0;
					down_held = false;
				}
			} else {
				if (R.input.down) {
					t_down++;
					if (t_down > 4) {
						t_down = 0;
						R.input.jpDown = true;
					}
				} else {
					t_down = 0;
					down_mode = 0;
				}
			}
			 
			if (R.input.up && !R.input.jpUp) {
				up_held = true;
				t_up++;
				if (t_up> 4) {
					t_up= 0;
					R.input.jpUp= true;
				}
			} else {
				if (up_held) t_up = -14;
				up_held = false;
			}
			
			if (R.input.jpDown) {
				if (idx_title < cur_ids-1 ) {
					idx_title++;
					if (!down_held) R.sound_manager.play(SNDC.menu_move);
					if (idx_cursor < 4) {
						idx_cursor++;
						if (idx_title < cur_ids - 1 && idx_cursor == 4) idx_cursor = 3;
					}
					set_page_strings();
				}
			} else if (R.input.jpUp) {
				if (idx_title > 0) {
					idx_title--;		
					if (!up_held) R.sound_manager.play(SNDC.menu_move);	
					if (idx_cursor > 0) {
						idx_cursor--;
						if (idx_title > 0 && idx_cursor == 0) {
							idx_cursor = 1;
						}
					}
					set_page_strings();
				}
			}
			
			if (R.input.jpLeft || R.input.jpRight) {
				cache_pos[page_type][0] = idx_title;
				cache_pos[page_type][1] = idx_cursor;
			}
			if (R.input.jpRight) {
				if (page_type < 1) {
					page_type++;
					R.sound_manager.play(SNDC.menu_move);
					idx_title = cache_pos[page_type][0];
					idx_cursor = cache_pos[page_type][1];
					set_page_strings();
				}
			} else if (R.input.jpLeft) {
				if (page_type > 0) {
					page_type--;
					R.sound_manager.play(SNDC.menu_move);
					idx_title = cache_pos[page_type][0];
					idx_cursor = cache_pos[page_type][1];
					set_page_strings();
					screenshot.alpha = 0;
				}
			}
			
			if (page_type == 0) {
				screenshot.alpha = 0;
				text_desc.y = title_texts.members[0].y;
				
				text_desc.x = 215;
				if (R.dialogue_manager.is_chinese() || R.dialogue_manager.is_other()) {
					text_desc.y -= 50;
					text_desc.x = 213;
				}
			} else {
				text_desc.y = 89;
				screenshot.alpha = bg.alpha;
			}
			
			if (R.input.jpCANCEL || R.input.jpPause) {
				mode = 2;
				R.sound_manager.play(SNDC.menu_close);
			}
		} else if (mode == 2) {
			
			bg.alpha -= 0.03;
			bg.alpha *= 0.9;
			
			titles.setAll("alpha", bg.alpha);
			title_texts.setAll("alpha", bg.alpha);
			screenshot.alpha = bg.alpha;
			fieldguidecover.alpha = bg.alpha;
			dim.alpha = bg.alpha;
			if (page_type == 0) {
				screenshot.alpha = 0;
				fieldguidecover.alpha = 0;
			}
			text_desc.alpha = bg.alpha;
			text_header.alpha = bg.alpha;
			
			if (bg.alpha <= 0) {
				ready_to_exit = true;
			}
		}
		
		super.update(elapsed);
	}

	public function update_font():Void {
		if (!did_init) return;
		
		var i:Int = 0;
		var bm:FlxBitmapText;
		bm = HF.init_bitmap_font(text_desc.text, "left", Std.int(text_desc.x), Std.int(text_desc.y), null, C.FONT_TYPE_APPLE_WHITE,true); bm.alpha = text_desc.alpha;  bm.visible = text_desc.visible;  i = members.indexOf(text_desc); members[i] = bm; text_desc.destroy(); text_desc = cast members[i];
		bm = HF.init_bitmap_font(text_header.text, "left", Std.int(text_header.x), Std.int(text_header.y), null, C.FONT_TYPE_APPLE_WHITE,true); bm.alpha = text_header.alpha;  bm.visible = text_header.visible;  i = members.indexOf(text_header); members[i] = bm; text_header.destroy(); text_header = cast members[i];
		for (j in 0...5) {
			bm = HF.init_bitmap_font(title_texts.members[j].text, "left", Std.int(title_texts.members[j].x), Std.int(title_texts.members[j].y), null, C.FONT_TYPE_APPLE_WHITE, true); 
			bm.alpha = title_texts.members[j].alpha; 
			bm.visible = title_texts.members[j].visible; 
			title_texts.members[j].destroy(); 
			title_texts.members[j] = bm;
		}
	}
	public function init():Void {
		did_init = true;
		
		dim = new FlxSprite();
		dim.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/tabdimmer.png"), true, false, 208, 32);
		dim.animation.add("left", [1], 1, false);
		dim.animation.add("right", [0], 1, false);
		dim.scrollFactor.set(0, 0);
		dim.move(0, 0);
		
		fieldguidecover = new FlxSprite();
		fieldguidecover.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/fieldguidecover.png"), true, false, 64, 64);
		
		bg = new FlxSprite();
		//bg.makeGraphic(C.GAME_WIDTH, C.GAME_HEIGHT, 0xff220077);
		bg.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/journalbg.png"), true, false, 416, 256);
		bg.animation.add("1", [1], 1);
		bg.animation.add("0", [0], 1);
		bg.animation.play("0");
		add(bg);
		titles = new FlxTypedGroup<FlxSprite>();
		title_texts = new FlxTypedGroup<FlxBitmapText>();
		for (i in 0...5) {
			var title:FlxSprite = new FlxSprite();
			AnimImporter.loadGraphic_from_data_with_id(title, 176, 31, "Journal", "title_bg");
			title.move(31, 51);
			title.y += i * (title.height + titles_spacing);
			
			var title_text:FlxBitmapText = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_ALIPH_WHITE, true);
			title_text.move(title.x + title_text_x_margin, title.y + title_text_y_margin);
			titles.add(title);
			title_texts.add(title_text);
		}
		add(titles);
		add(title_texts);
		screenshot = new FlxSprite(267, 15);
		fieldguidecover.move(screenshot.x, screenshot.y);
		screenshot.makeGraphic(96, 64, 0xffff0000);
		add(screenshot);
		add(fieldguidecover);
		text_desc = HF.init_bitmap_font(" ", "left", 215, 89, null, C.FONT_TYPE_ALIPH_WHITE, true);
		add(text_desc);
		text_header = HF.init_bitmap_font(" ", "left", 38, 21, null, C.FONT_TYPE_ALIPH_WHITE, true);
		add(text_header);
		add(dim);
		setAll("scrollFactor", new FlxPoint(0, 0), true);
		
		for (i in 0...5) {
			Reflect.setProperty(titles.members[i], "scrollFactor", new FlxPoint(0, 0));
		}
		Reflect.setProperty(bg, "scrollFactor", new FlxPoint(0, 0));
		Reflect.setProperty(screenshot, "scrollFactor", new FlxPoint(0, 0));
		Reflect.setProperty(fieldguidecover, "scrollFactor", new FlxPoint(0, 0));
		Reflect.setProperty(dim, "scrollFactor", new FlxPoint(0, 0));
	}
	
	private var titles_top_left_y:Float = 50;
	private var titles_spacing:Float = 1;
	private var title_text_y_margin:Float = 3;
	private var title_text_x_margin:Float = 5;
	private var title_text_w:Float = 144;
	private var desc_w:Float = 180;
	
	
	public function activate():Void {
		if (!did_init) init();	
		// Figure out the viewable
		setAll("alpha", 0, true);
		
		cache_pos = [[0, 0], [0, 0]];
		viewable_ids = get_viewable_journal_ids();
		viewable_ent_ids = get_viewable_ent_ids();
		viewable_ids.reverse();
		
		// Get titles and desc (one tieme)
		title_strings = new Map<String,String>();
		desc_strings = new Map<String,String>();
		title_ent_strings = new Array<String>();
		desc_ent_strings = new Array<String>();
		R.dialogue_manager.FORCE_LINE_SIZE = Std.int(title_text_w / title_texts.members[0].font.spaceWidth);
		//var num_ents:Int = R.dialogue_manager.get_scene_length("ui", "fieldguide_titles");
		//Log.trace(["numents", num_ents]);
		
		// Get Title strings
		// fill in these
		var journaldata:String = "";
		if (ProjectClass.DEV_MODE_ON && FlxG.keys.pressed.L && FlxG.keys.pressed.SHIFT) {
			Log.trace("reload journal data");
			journaldata = File.getContent(C.EXT_ASSETS + "dialogue/journal.txt");
		} else {
			journaldata = Assets.getText("assets/dialogue/journal.txt");
		}
		var journallines:Array<String> = journaldata.split("\n");
		var jl:String = "";
		var jlparsemode:Int = 0;
		var key:String = "";
		for (jl in journallines) {
			jl = StringTools.trim(jl);
			if (jl.indexOf("#") != -1 || jl.indexOf("//") != -1) {
				continue;
			}
			// find ocrrect language to parse
			if (jlparsemode == 0) {
				if (jl.indexOf("START") == 0) {
					var lang:String = jl.split(",")[1];
					if (lang == DialogueManager.arrayLANGTYPEcaps[DialogueManager.CUR_LANGTYPE]) {
						jlparsemode = 1;
					}
				}
			// look for a "e intro,1,Tension,1" line, or END
			} else if (jlparsemode == 1) {
				if (jl.indexOf("e ") == 0) {
					var meta:Array<String> = jl.split(" ")[1].split(",");
					var color:String = "0";
					var title:String = "";
					
					// e intro,1,COLOR,ANIMFRAME,TITLE
					color = meta[2];
					key = meta[0] + "," + meta[1];
					// meta 3 is the frame # for animation
					// intro,1 -> Tension#0
					// bad hack to deal with commas
					var i:Int = jl.indexOf(",", 0);
					i = jl.indexOf(",", i+1);
					i = jl.indexOf(",", i+1);
					i = jl.indexOf(",", i+1);
					meta[4] = jl.substr(i + 1);
				
					
					title_strings.set(key, DialogueManager.justify(meta[4],Std.int(152 / title_texts.members[0].font.spaceWidth))+"#"+color+"#"+meta[3]);
					jlparsemode = 2;
				} else if (jl.indexOf("END") == 0) {
					break;
				}
			} else if (jlparsemode == 2) {
				desc_strings.set(key, DialogueManager.justify(jl,1+Std.int(desc_w / title_texts.members[0].font.spaceWidth)));
				jlparsemode = 1;
			}
		}
		
		for (i in 0...viewable_ent_ids.length) {
			title_ent_strings.push(R.dialogue_manager.lookup_sentence("ui", "fieldguide_titles", viewable_ent_ids[i], true));
			title_ent_strings[i] = DialogueManager.justify(title_ent_strings[i],R.dialogue_manager.FORCE_LINE_SIZE);
		}
		
		R.dialogue_manager.FORCE_LINE_SIZE = Std.int(desc_w / title_texts.members[0].font.spaceWidth);
		
		for (i in 0...viewable_ent_ids.length) {
			desc_ent_strings.push(R.dialogue_manager.lookup_sentence("ui", "fieldguide_desc", viewable_ent_ids[i], true));
			desc_ent_strings[i] = DialogueManager.justify(desc_ent_strings[i],1+R.dialogue_manager.FORCE_LINE_SIZE);
		}
		R.dialogue_manager.FORCE_LINE_SIZE = -1;
		
		title_texts.setAll("lineSpacing", 1);
		
		
		text_desc.lineSpacing = 2;
		if (R.dialogue_manager.is_chinese()) {
			text_desc.lineSpacing = 0;
		} else if (R.dialogue_manager.is_other()) {
			text_desc.lineSpacing = 1;
		}
		text_desc.double_draw = false;
		
		idx_cursor = 0;
		idx_title = 0;
		page_type = 0;
		mode = 0;
		set_page_strings();
		
		titles.setAll("alpha", 0);
		
		t_down = t_up = -14;
	}
	public function is_done():Bool {
		if (ready_to_exit) {
			ready_to_exit = false;
			// cleanup
			return true;
		}
		return false;
	}
	
	private var cache_pos:Array<Array<Int>>;
	private var journal_interp:Interp;
	private var journal_program:Expr;
	public function get_viewable_ent_ids():Array<Int> {
		var res_str:String = "";
		journal_program = HF.get_program_from_script_wrapper("tool/journal/fieldguide.hx");
		journal_interp = new Interp();
		journal_interp.variables.set("this", this);
		journal_interp.variables.set("R", R);
		res_str = journal_interp.execute(journal_program);
		if (res_str.charAt(res_str.length - 1) == ",") {
			res_str = res_str.substr(0, res_str.length - 1);
		}
		//Log.trace(res_str);
		//Log.trace(HF.string_to_int_array(res_str));
		return HF.string_to_int_array(res_str);
	}
	public function get_viewable_journal_ids():Array<String> {
		var res_str:String = "";
		journal_program = HF.get_program_from_script_wrapper("tool/journal/journal.hx");
		journal_interp = new Interp();
		journal_interp.variables.set("this", this);
		journal_interp.variables.set("R", R);
		res_str = journal_interp.execute(journal_program);
		if (res_str.charAt(res_str.length - 1) == "\n") {
			res_str = res_str.substr(0, res_str.length - 1);
		}
		var a:Array<String> = res_str.split("\n");
		return a;
	}
	
	
	public function get_ss(map:String, scene:String, state_id:Int):Int {
		return R.dialogue_manager.get_scene_state_var(map, scene, state_id);	
	}
	
	public function get_event_state(id:Int, exact:Bool = false):Dynamic {
		if (exact) {
			return R.event_state[id];
		}
		return (R.event_state[id] == 1);
	}
	
	function set_page_strings():Void 
	{
		var idx:Int = -1;
		var picanim:String = "0";
		for (i in idx_title-idx_cursor...idx_title+5 - idx_cursor) {
			idx++;
			// set titles for journal
			if (page_type == 0) {
				bg.animation.play("0");
				cur_ids = viewable_ids.length;
				// title strings contains format "Tension#0"
				var t_data:String = "";
				var suf:String = "0";
				
				// Load t_data if we know we'll need it
				if (i + 1 <= viewable_ids.length) {
					t_data = title_strings.get(viewable_ids[i]);
				}
				
				if (i + 1 > viewable_ids.length) {
					title_texts.members[idx].text = "-";
				} else {
					title_texts.members[idx].text = t_data.split("#")[0];
					// Hack to fit journal titles
					if (R.dialogue_manager.is_chinese()) {
						var a:Utf8 = new Utf8();
						var _s:String = t_data.split("#")[0];
						for (_i in 0...Utf8.length(_s)) {
							if (Utf8.charCodeAt(_s, _i) == Utf8.charCodeAt("(", 0)) {
							} else if (Utf8.charCodeAt(_s, _i) == Utf8.charCodeAt(")", 0)) {
							} else if (Utf8.charCodeAt(_s, _i) == Utf8.charCodeAt("（", 0)) {
							} else if (Utf8.charCodeAt(_s, _i) == Utf8.charCodeAt("）", 0)) {
							} else if (Utf8.charCodeAt(_s, _i) == Utf8.charCodeAt("\n", 0)) {
							} else if (Utf8.charCodeAt(_s, _i) == Utf8.charCodeAt(" ", 0)) {
							} else {
								a.addChar(Utf8.charCodeAt(_s, _i));
							}
						}
						title_texts.members[idx].text = a.toString();
					}
					suf = t_data.split("#")[1];
				}
					
				if (idx == idx_cursor) {
					suf += "_off";
					picanim = t_data.split("#")[2];
				}
				titles.members[idx].animation.play(suf);
			} else if (page_type == 1) {
				bg.animation.play("1");
				cur_ids = viewable_ent_ids.length;
				if (i + 1 > viewable_ent_ids.length) {
					title_texts.members[idx].text = "-";
				} else {
					title_texts.members[idx].text = title_ent_strings[i];
				}
				//var suf:String = Std.string(viewable_frame_ids[i]);
				var suf:String = "0";
				if (idx_cursor == idx) suf += "_off";
				titles.members[idx].animation.play(suf);
			}
		}
		if (page_type == 0) {
			text_desc.text = desc_strings.get(viewable_ids[idx_title]);
			AnimImporter.loadGraphic_from_data_with_id(screenshot, -1, -1, "Journal", "event_screenshot");
			screenshot.animation.play(picanim,true);
				fieldguidecover.visible = false;
				dim.animation.play("left");
		} else if (page_type == 1) {
			text_desc.text = desc_ent_strings[idx_title];
			AnimImporter.loadGraphic_from_data_with_id(screenshot, -1, -1, "Journal", "fieldguide_screenshot");
			screenshot.animation.play(Std.string(viewable_ent_ids[idx_title]), true);
			if (viewable_ent_ids[idx_title] == 45) {
				fieldguidecover.visible = false;
			} else {
				fieldguidecover.visible = true;
			}
				dim.animation.play("right");
		}
		
		text_header.text = R.dialogue_manager.lookup_sentence("ui", "journal_headers", 0) + "    " +  R.dialogue_manager.lookup_sentence("ui", "journal_headers", 1);
		text_header.y = 21;
		text_header.x = 40;
		if (R.dialogue_manager.is_chinese()) {
			text_header.y = 16;
			text_header.text = R.dialogue_manager.lookup_sentence("ui", "journal_headers", 0) + "   " +  R.dialogue_manager.lookup_sentence("ui", "journal_headers", 1);
		} else if (R.dialogue_manager.is_other()) {
			text_header.text = R.dialogue_manager.lookup_sentence("ui", "journal_headers", 0) + "   " +  R.dialogue_manager.lookup_sentence("ui", "journal_headers", 1);
			
			text_header.x = 32;
		text_header.y = 19;
		}
		titles.setAll("alpha", 1);
	}
}







