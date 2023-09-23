package help;
import autom.EMBED_TILEMAP;
#if cpp
import cpp.vm.Thread;
#end
import autom.SNDC;
import entity.ui.NineSliceBox;
import entity.util.Checkpoint;
import global.C;
import global.EF;
import global.Registry;
import haxe.Log;
import flash.geom.Point;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import openfl.Assets;
import openfl.geom.Rectangle;

/**
 * ... * @author Melos Han-Tani
 */

class SaveModule extends FlxGroup
{

	public var save_texts:Array<FlxBitmapText>;
	private var save_text_vspacing:Int = 32;
	private var BG:NineSliceBox;
	/**
	 * The last used save file or loaded file (makes saving the wrong file less likely)
	 */
	public var last_used_file_index:Int;
	private var mode:Int = 0;
	private var last_mode:Int = 0;
	public static inline var MODE_IDLE:Int = 0;
	public static inline var MODE_SAVE:Int = 1;
	public static inline var MODE_LOAD:Int = 2;
	public static inline var MODE_DELETE:Int = 3;
	public static inline var MODE_ARE_YOU_SURE:Int = 4;
	public static inline var MODE_NEW:Int = 5;
	public static inline var MODE_DELETE_CONFIRM:Int = 6;
	
	private var AFTER_DELETE_RETURN_MODE:Int = 0;
	private var do_fade_in:Bool = false;
	private var max_bg_alpha:Float = 0.9;
	
	private var title_text:FlxBitmapText;
	
	public var file_selector:FlxSprite;
	public var last_file_selector_coords:Point;
	public var last_file_selector_idx:Int = 0;
	public var idx_file_selector:Int = 0;
	private var R:Registry;
	private var cur_page:Int = 0;
	
	private var are_you_sure_box:NineSliceBox;
	private var are_you_sure_text:FlxBitmapText;
	
	private var loading_box:FlxSprite;
	private var loading_progress_Text:FlxBitmapText;
	
	
	private var JUSTLOADED:Bool = false;
	
	public static inline var S_SAVE:String = "save";
	public static inline var P_YOUSURE:Int = 0;
	public static inline var P_NEWGAME:Int = 1;
	
	
	public function update_font():Void {
		var bm:FlxBitmapText;
		var i:Int = 0;
		for (j in 0...5 ) {
			
			bm = HF.init_bitmap_font(save_texts[j].text, "left", Std.int(save_texts[j].x), Std.int(save_texts[j].y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.visible = save_texts[j].visible;  i = members.indexOf(save_texts[j]); members[i] = bm; save_texts[j].destroy(); save_texts[j] = cast members[i];
		}
		
			bm = HF.init_bitmap_font(title_text.text, "left", Std.int(title_text.x), Std.int(title_text.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.visible = title_text.visible;  i = members.indexOf(title_text); members[i] = bm; title_text.destroy(); title_text= cast members[i];
		
			bm = HF.init_bitmap_font(are_you_sure_text.text, "left", Std.int(are_you_sure_text.x), Std.int(are_you_sure_text.y), null, C.FONT_TYPE_APPLE_WHITE); bm.text = get_label_string(P_YOUSURE); bm.double_draw = true; bm.visible = are_you_sure_text.visible;  i = members.indexOf(are_you_sure_text); members[i] = bm; are_you_sure_text.destroy(); are_you_sure_text = cast members[i];
			are_you_sure_text.lineSpacing = 4;
			
			are_you_sure_box.resize(38+are_you_sure_text.width,16+are_you_sure_text.height);
	}
	
	public function save_external(recent:Bool = true):Void {
		presave_update_routine();
		Track.add_saved_game(last_used_file_index, R.TEST_STATE.MAP_NAME, R.player.x, R.player.y);
		JankSave.save(last_used_file_index);
		Log.trace("Instant saved to slot " + Std.string(last_used_file_index));
	}
	
	public function new() 
	{
		super();
		
		
		// The height has to be even or else you get half-pixel errors at a 2x scale...
		BG= new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH, false, "assets/sprites/ui/9slice_dialogue.png");
		
		R = Registry.R;
		
		BG.resize(C.GAME_WIDTH - 160, 8 + 16 + 17 + save_text_vspacing * 5);
		BG.x = C.GAME_WIDTH - BG.width - 8;
		BG.y = 16;
		BG.alpha = max_bg_alpha;
		add(BG);
		//add(BG);
		save_texts = [];
		for (i in 0...5) {
			var savetext:FlxBitmapText = HF.init_bitmap_font(get_label_string(P_NEWGAME), "left", Std.int(BG.x+8), Std.int(BG.y) + 20 + save_text_vspacing * i, null, C.CURRENT_FONT_TYPE); 
			//savetext.lineSpacing = 0;
			if (R.dialogue_manager.is_chinese()) {
				savetext.lineSpacing = 0;
			} else {
				savetext.lineSpacing = 3;
			}
			save_texts.push(savetext);
			add(savetext);
			savetext.double_draw = true;
			savetext.scrollFactor.set(0, 0);
		}
		
		title_text = HF.init_bitmap_font(" ","center",0,0,null,C.FONT_TYPE_APPLE_WHITE);
		add(title_text);
		title_text.double_draw = true;
		
		are_you_sure_box = new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH, false, "assets/sprites/ui/9slice_dialogue.png");
		are_you_sure_box.scrollFactor.set(0, 0);

		are_you_sure_text = HF.init_bitmap_font(get_label_string(P_YOUSURE), "left", 2, 2, null, C.CURRENT_FONT_TYPE);
		are_you_sure_text.x = (C.GAME_WIDTH - are_you_sure_text.width)  / 2;
		are_you_sure_text.y = 16;
		are_you_sure_text.lineSpacing = 4;
		are_you_sure_box.x = are_you_sure_text.x - 8;
		are_you_sure_box.y = are_you_sure_text.y - 8;
		are_you_sure_text.double_draw = true;
		add(are_you_sure_box);
		add(are_you_sure_text);
		are_you_sure_box.resize(38+are_you_sure_text.width,16+are_you_sure_text.height);
		are_you_sure_box.visible = are_you_sure_text.visible = false;
		
		file_selector = new FlxSprite();
		AnimImporter.loadGraphic_from_data_with_id(file_selector, 0, 0, "MenuSelector");
		file_selector.animation.play("full");
		file_selector.height -= 8;
		file_selector.offset.y = 8;
		
		add(file_selector);
		last_file_selector_coords = new Point();
		
		loading_box = new FlxSprite();
		loading_progress_Text = HF.init_bitmap_font("0.0%", "center", 0, 0, null, C.CURRENT_FONT_TYPE);
		loading_progress_Text.visible = false;
		loading_progress_Text.x = 10;
		loading_progress_Text.y = 10;
		add(loading_progress_Text);
		
		BG.scrollFactor.set(0, 0);
		file_selector.scrollFactor.set(0, 0);
	}
	
	public var can_cancel:Bool = true;
	// sanity wrapper
	private function get_label_string(pos:Int):String {
		return R.dialogue_manager.lookup_sentence(DialogueManager.M_UI, S_SAVE, pos);
	}
	public var just_saved:Bool = false;
	public var just_newed:Bool = false;
	private static var loading_locked:Bool = false;
	private  var loading_done:Bool = false;
	public var timeout:Int = 0;
	// TODO status text? 
	override public function update(elapsed: Float):Void {
		
		
		if (mode == MODE_DELETE_CONFIRM) {
			if ( -1 != R.TITLE_STATE.dialogue_box.last_yn) {
				mode = last_mode = AFTER_DELETE_RETURN_MODE;
				if (1 == R.TITLE_STATE.dialogue_box.last_yn) {
					JankSave.delete(cur_page * 5 + idx_file_selector);
					Track.add_deleted(cur_page * 5 + idx_file_selector);
					reload_save_text(cur_page * 5 + idx_file_selector, idx_file_selector);
					if (idx_file_selector == 4 && (AFTER_DELETE_RETURN_MODE == MODE_NEW || AFTER_DELETE_RETURN_MODE == MODE_LOAD)) append_text_to_save();
				}
			}
			super.update(elapsed);
			return;
		} else if (R.TITLE_STATE.dialogue_box.is_active()) {
			return;
		}
		if (timeout > 0) timeout--;

		
		if (do_fade_in) {
			
			title_text.alpha += 0.008;
			title_text.alpha *= 1.05;
			for (i in 0...save_texts.length) {
				save_texts[i].alpha = title_text.alpha;
			}
			file_selector.alpha = title_text.alpha;
			BG.alpha = file_selector.alpha;
			if (BG.alpha >= max_bg_alpha) BG.alpha = max_bg_alpha;
			if (file_selector.alpha >= 1) {
				do_fade_in = false;
			} else {
				super.update(elapsed);
				return;
			}
		}
		if (mode != MODE_IDLE) {
			
			
			if (mode == MODE_ARE_YOU_SURE) {
				if (idx_file_selector == 0) {
					if (R.input.jpRight) {
						idx_file_selector ++;
						file_selector.x += 7 * 6;
						if (R.dialogue_manager.is_chinese()) file_selector.x += 19;
						R.sound_manager.play(SNDC.menu_move);
					} else if (R.input.jpCONFIRM) {
						mode = last_mode;
						// If we hit 'enter' to delete, go back to load mode after
						if (mode == MODE_DELETE) {
							mode = last_mode = AFTER_DELETE_RETURN_MODE;
						}
						R.sound_manager.play(SNDC.menu_cancel);
					}
				} else {
					if (R.input.jpLeft) {
						idx_file_selector--;
						file_selector.x -= 7 * 6;
						if (R.dialogue_manager.is_chinese()) file_selector.x -= 19;
						R.sound_manager.play(SNDC.menu_move);
					} else if (R.input.jpCONFIRM) {
						R.sound_manager.play(SNDC.menu_confirm);
						mode = last_mode;
						are_you_sure_box.visible = are_you_sure_text.visible = false;
						pop_file_select(); // return cursor
						switch (mode) {
							case MODE_NEW:
								doNewgameSave();
							case MODE_SAVE:
								R.sound_manager.play(SNDC.savesound);
								can_cancel = true;
								presave_update_routine();
								Track.add_saved_game(cur_page * 5 + idx_file_selector, R.TEST_STATE.MAP_NAME, R.player.x, R.player.y);
								JankSave.save(cur_page * 5 + idx_file_selector);
								last_used_file_index = cur_page * 5 + idx_file_selector;
								reload_save_text(cur_page * 5 + idx_file_selector, idx_file_selector);
								just_saved = true;
							case MODE_LOAD:
								//JankSave.patch_text = loading_progress_Text;
								if (loading_locked == false) {
									Log.trace("begin load...");
									loading_locked = true;
									#if cpp
									Thread.create(function () {
										if (JankSave.load(cur_page * 5 + idx_file_selector)) {
											loading_done = true;
											Track.add_loaded(cur_page * 5 + idx_file_selector);
										}
										loading_locked = false;
										loading_progress_Text.text = "100%";
									});
									#end
									#if !cpp
									if (JankSave.load(cur_page * 5 + idx_file_selector)) {
										loading_done = true;
									}
									loading_locked = false;
									loading_progress_Text.text = "100%";
									#end
									
								}
								
								
								
							case MODE_DELETE:
								
								R.TITLE_STATE.dialogue_box.start_dialogue("ui","save",4);
								R.TITLE_STATE.dialogue_box.MAIN_DISPLAY_MAX_ALPHA = 1;
								last_mode = mode = MODE_DELETE_CONFIRM;
								
						}
					}
				}
				
				
				if (R.input.jpCANCEL) {
					mode = last_mode = AFTER_DELETE_RETURN_MODE;
					R.sound_manager.play(SNDC.menu_cancel);
				}
				
				if (mode == last_mode) {
					pop_file_select();
					are_you_sure_box.visible = are_you_sure_text.visible = false;
				}
				
				super.update(elapsed);
				
				return;
			}
			
			
			if (loading_locked) {
				loading_progress_Text.text = Std.string(Std.int(JankSave.patch_percent * 100)) + "%";
				return;
			}
			
			if (loading_done) {
				Log.trace("...done");
				loading_done = false;
				last_used_file_index = cur_page * 5 + idx_file_selector;
				JUSTLOADED = true;
				mode = MODE_IDLE;
				
				// Hard-load should remove any checkpoint
				if (R.player == R.activePlayer) {
					JankSave.force_checkpoint_things  = false;
				}
			}
			
			if (JUSTLOADED) {
				super.update(elapsed);
				return;
			}
			
			if (R.input.jpDown && idx_file_selector < 4) {
				idx_file_selector++; 
				file_selector.y += save_text_vspacing;
				R.sound_manager.play(SNDC.menu_move);
			} else if (R.input.jpUp && idx_file_selector > 0) {
				idx_file_selector--;
				file_selector.y -= save_text_vspacing;
				R.sound_manager.play(SNDC.menu_move);
			} else if ((R.input.jpLeft || (R.input.jpUp && idx_file_selector == 0)) && cur_page > 0) {
				cur_page--;
				if (R.input.jpUp && idx_file_selector == 0) {
					idx_file_selector = 4;
					file_selector.y += 4 * save_text_vspacing;
				}
				
				set_title_text();
				reload_save_texts(cur_page, 5);
				R.sound_manager.play(SNDC.menu_move);
			} else if ((R.input.jpRight || (R.input.jpDown && idx_file_selector == 4)) && cur_page < 2) {
				cur_page++;
				if (R.input.jpDown && idx_file_selector == 4) {
					idx_file_selector = 0;
					file_selector.y -= 4 * save_text_vspacing;
				}
				set_title_text();
				reload_save_texts(cur_page, 5);
				R.sound_manager.play(SNDC.menu_move);
			}
			
			
			// If we select a file, double check~!!
			if ((R.input.jpCONFIRM && !loading_locked) || (mode == MODE_LOAD && !loading_locked && R.input.jpPause) || (mode == MODE_NEW && R.input.jpPause)) {
				R.sound_manager.play(SNDC.menu_confirm);
				if (mode == MODE_NEW) {
					if (R.input.jpPause) {
						are_you_sure_text.text = get_label_string(3); // really delete?
						mode = MODE_DELETE;
						AFTER_DELETE_RETURN_MODE = MODE_NEW;
					}  else {
						AFTER_DELETE_RETURN_MODE = MODE_NEW;
						are_you_sure_text.text = get_label_string(P_YOUSURE);
						if (JankSave.save_exists(cur_page*5 + idx_file_selector)) {
							R.TITLE_STATE.dialogue_box.start_dialogue("ui","save",2);
							return;
						}
					}
				}
				if (mode == MODE_LOAD) {
					if (R.input.jpPause) {
						are_you_sure_text.text = get_label_string(3); // really delete?
						mode = MODE_DELETE;
						AFTER_DELETE_RETURN_MODE = MODE_LOAD;
					} else {
						AFTER_DELETE_RETURN_MODE = MODE_LOAD; // prevent backing out entirely of load menu with cancel
						are_you_sure_text.text = get_label_string(P_YOUSURE);
						if (JankSave.save_exists(cur_page * 5 + idx_file_selector) == false) {
							return;
						}
					}
				}
				if (mode == MODE_SAVE) {
					AFTER_DELETE_RETURN_MODE = MODE_SAVE;
					are_you_sure_text.text = get_label_string(5);
				}
				last_mode = mode;
				mode = MODE_ARE_YOU_SURE;
				last_file_selector_coords.x = file_selector.x;
				last_file_selector_coords.y = file_selector.y;
				last_file_selector_idx = idx_file_selector;
				idx_file_selector = 0;
				
				are_you_sure_text.x = are_you_sure_box.x + are_you_sure_box.width / 2 - are_you_sure_text.width / 2;
				
				file_selector.y = are_you_sure_text.y + R.dialogue_manager.DIALOGUE_LINE_HEIGHT + 3;
				if (R.dialogue_manager.is_chinese()) file_selector.y += 4;
				if (R.dialogue_manager.is_other()) file_selector.y += 4;
				file_selector.x = are_you_sure_text.x - 16;
				
				are_you_sure_box.visible = are_you_sure_text.visible = true;
				

			} else if (can_cancel && timeout <= 0 && (R.input.jpCANCEL || R.input.jpPause)) {
				if ((mode == MODE_LOAD || mode == MODE_NEW) && R.input.jpPause) {
					// ignore  bc it's confusing to exit with this
				} else {
					mode = MODE_IDLE;
				}	
			}
			#if !FLX_NO_KEYBOARD
			else if (FlxG.keys.myJustPressed("ESCAPE")) {
				mode = MODE_IDLE;
			}
			#end
		}
		
		super.update(elapsed);
	}
	
	private function pop_file_select():Void {
		file_selector.x = last_file_selector_coords.x;
		file_selector.y = last_file_selector_coords.y;
		idx_file_selector = last_file_selector_idx;
	}
	public var caller_x:Int;
	public var caller_y:Int;
	public function activate(_mode:Int, x:Float= -1, y:Float= -1,fade:Bool=false ) {
		mode = _mode;
		if (R.dialogue_manager.is_chinese()) {
			save_text_vspacing = 34;
		} else if (R.dialogue_manager.is_other()) {
			save_text_vspacing = 30;
		} else {
			save_text_vspacing = 32;
		}
		caller_x = Std.int(x);
		caller_y = Std.int(y);
		if (last_used_file_index > 15 || last_used_file_index < 0) {
			last_used_file_index = 0;
		}
		cur_page = Std.int(last_used_file_index / 5);
		
		idx_file_selector = last_used_file_index % 5;
		
		
		if (fade && (mode == MODE_NEW || mode == MODE_LOAD)) {
			BG.resize(C.GAME_WIDTH - 160, 8 + 16 + 24 + save_text_vspacing * 5);
			if (R.dialogue_manager.is_other()) {
				BG.resize(C.GAME_WIDTH - 142, 8 + 16 + 24 + 8 + save_text_vspacing * 5);
			}
			if (mode == MODE_LOAD) {
				BG.x = C.GAME_WIDTH - BG.width - 8;
			} else {
				BG.x = C.GAME_WIDTH / 2 - BG.width / 2;
			}
		} else {
			if (BG.height != 8 + 16 + 8 + save_text_vspacing * 5) {
				BG.resize(C.GAME_WIDTH - 160, 8 + 16 + 8 + save_text_vspacing * 5);
				
				if (R.dialogue_manager.is_other()) {
					BG.resize(C.GAME_WIDTH - 142, 8 + 16 + 24 + 8 + save_text_vspacing * 5);
				}
			}
			BG.x = C.GAME_WIDTH / 2 - BG.width / 2;
		}
		
		set_title_text();
		reload_save_texts(cur_page, 5);
		just_saved = false;
		
		file_selector.x = save_texts[0].x - file_selector.width - 2;
		file_selector.y = save_texts[0].y + 3;
		if (R.dialogue_manager.is_chinese()) {
			file_selector.y += 5;
		} else if (R.dialogue_manager.is_other()) {
			file_selector.y += 2;
		}
		file_selector.ID = 0;
		file_selector.y += save_text_vspacing * (idx_file_selector % 5);
		
		do_fade_in = fade;
		max_bg_alpha = 0.95;
		if (do_fade_in) {
			BG.alpha = 0;
			for (i in 0...save_texts.length) {
				save_texts[i].alpha = 0;
			}
			file_selector.alpha = 0;
			title_text.alpha = 0;
			max_bg_alpha = 0.95;
		}
		
		
	}
	
	public function just_loaded():Bool {
		if (JUSTLOADED) {
			JUSTLOADED = false;
			return true;
		}
		return false;
	}
	public function is_idle():Bool {
		if (mode == MODE_IDLE) {
			return true;
		}
		return false;
	}
	
	private function reload_save_texts(page:Int, nrPerPage:Int):Void {
		var offset:Int = page * nrPerPage;
		for (i in 0...nrPerPage) {
			reload_save_text(page * 5 + i,i);
		}
		if (mode == MODE_LOAD || mode == MODE_NEW) {
			append_text_to_save();
		}
		
	}
	
	private function append_text_to_save():Void {
		if (R.dialogue_manager.is_chinese()) {
			save_texts[4].text += "\n" + R.dialogue_manager.lookup_sentence("ui", "savemoduletitles", 5, true, true);
			BG.resize(C.GAME_WIDTH - 160, 8 + 16 + 24 + save_text_vspacing * 5);
		} else {
			save_texts[4].text += "\n\n" + R.dialogue_manager.lookup_sentence("ui", "savemoduletitles", 5, true, true);
		}
	}
	
	private function reload_save_text(id:Int, idx:Int):Void {
		// Store the current map and playtimes since they're modified in the load function
		var curmap:String = R.savepoint_mapName;
		var curtime:Int = R.playtime;
		var isstory:Bool = R.story_mode;
		var isgaunt:Bool = R.gauntlet_mode;
		//var curplayername:String = R.PLAYER_NAME;
		if (JankSave.load_quick(id)) {
			var mode_str:String = "(";
			if (R.dialogue_manager.is_chinese()) {
				mode_str = "";
			}
			if (R.story_mode) {
				mode_str += R.dialogue_manager.lookup_sentence("ui", "game_modes", 1, true, true);
			} else if (R.gauntlet_mode) {
				mode_str += R.dialogue_manager.lookup_sentence("ui", "game_modes", 2, true, true);
			} else {
				mode_str += R.dialogue_manager.lookup_sentence("ui", "game_modes", 0, true, true);
			}
			// add "Mode"
			if (!R.dialogue_manager.is_chinese()) {
				mode_str += " " + R.dialogue_manager.lookup_sentence("ui", "game_modes", 4, true, true) + ")";
			}
			
			// Shorten some metadata for large font
			if (R.dialogue_manager.is_chinese()) {
				save_texts[idx].text = Std.string(id) + "." + HF.get_time_string(R.playtime, true) + " " + mode_str + "\n   " + EMBED_TILEMAP.actualname_hash.get(R.savepoint_mapName);
			} else {
				save_texts[idx].text = Std.string(id) + ". " + HF.get_time_string(R.playtime, true) + "  " + mode_str + "\n   " + EMBED_TILEMAP.actualname_hash.get(R.savepoint_mapName);
			}
		} else {
			save_texts[idx].text = Std.string(id) + ". ";
			save_texts[idx].text += R.dialogue_manager.lookup_sentence("ui", "savemoduletitles", 3, true, true);
		}
		save_texts[idx].x = BG.x + 8;
		save_texts[idx].y = title_text.y + title_text.height + 10 + save_text_vspacing * (id % 5);
		// Space texts more for large font
		if (R.dialogue_manager.is_chinese()) {
			save_texts[idx].y += 1;
		} else if (R.dialogue_manager.is_other()) {
			save_texts[idx].y -= 2;
		}
		//R.PLAYER_NAME = curplayername;
		R.playtime = curtime;
		R.savepoint_mapName = curmap;
		R.story_mode = isstory;
		R.gauntlet_mode = isgaunt;
	}
	
	function set_title_text():Void 
	{
		if (mode == MODE_SAVE) {
			title_text.text = R.dialogue_manager.lookup_sentence("ui", "savemoduletitles", 0);
		} else if (mode == MODE_LOAD) {
			title_text.text = R.dialogue_manager.lookup_sentence("ui", "savemoduletitles", 1);
		} else if (mode == MODE_DELETE) {
			title_text.text = R.dialogue_manager.lookup_sentence("ui", "savemoduletitles", 2);
		} else if (mode == MODE_NEW) {
			title_text.text = R.dialogue_manager.lookup_sentence("ui", "savemoduletitles", 3);
		}
		
		title_text.text += " (" + R.dialogue_manager.lookup_sentence("ui", "savemoduletitles", 4) +" "+Std.string(cur_page+1) + "/3)";
		title_text.y = BG.y + 6;
		title_text.x = BG.x + BG.width / 2 - title_text.width / 2;
	}
	
	// Update data before writing data..
	function presave_update_routine():Void 
	{
		R.savepoint_mapName = R.TEST_STATE.MAP_NAME;
		R.savepoint_X = caller_x;
		R.savepoint_Y = caller_y;
		R.nr_saves++;
		HF.save_map_entities(R.TEST_STATE.MAP_NAME, R.TEST_STATE, true);
		// Over-write cache and uncache then save to dsk
		R.inventory.cache_state();
		R.inventory.uncache_state();
		R.inventory.cache_last_saved_strings();
		//R.gauntlet_mana ger.delete_gauntlet_entity_data();
		
		// Hard sv should remove checkpoint
		if (R.player == R.activePlayer) {
			JankSave.force_checkpoint_things  = false;
		}
	}
	
	public function doNewgameSave():Void 
	{
		// SET INITIAL COORDINATES
		var ad:Array<Dynamic> = R.NEW_GAME_COORDS.split(",");
		ad[1] = Std.parseInt(ad[1]);
		ad[2] = Std.parseInt(ad[2]);
		R.savepoint_mapName = R.TEST_STATE.next_map_name = ad[0];
		R.savepoint_X = R.TEST_STATE.next_player_x = ad[1];
		R.savepoint_Y = R.TEST_STATE.next_player_y = ad[2];
		R.reset_global_state();
		JankSave.reset_data_on_new(cur_page * 5 + idx_file_selector);
		JankSave.save(cur_page * 5 + idx_file_selector);
		Track.add_new_game(cur_page * 5 + idx_file_selector);
		last_used_file_index = cur_page * 5 + idx_file_selector;
		just_newed = true;
		mode = MODE_IDLE;
	}
	
}