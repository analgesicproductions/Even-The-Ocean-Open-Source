package help;

import autom.SNDC;
import entity.ui.DialogueBox;
import entity.ui.NineSliceBox;
import flixel.text.FlxBitmapText;
import flixel.FlxG;
import flixel.group.FlxGroup;
import global.C;
import global.Registry;
import haxe.Log;
import openfl.Assets;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class JoyModule extends FlxGroup
{

	private var dialogue_box:DialogueBox;
	private var bg:NineSliceBox;
	public function new(MaxSize:Int=0, _name:String="") 
	{
		super(MaxSize, "JoyModule");

		
	}
	
	private var mode:Int = 0;
	
	private var idx:Int = 0;
	private var recent:Int = 0;
	private var confirming:Bool = false;
	private var new_vals:Array<Int>;
	private var did_init:Bool = false;
	
	private var cur_button_text:FlxBitmapText;
	private var error_text:FlxBitmapText;
	
	override public function update(elapsed: Float):Void 
	{
		if (mode < 0) {
			mode++;
		}
		
		if (mode == 0) {
			
		} else if (mode == 1) {
			// jump/cancel , lock shield / confirm , sit, pause
		
			
			recent = -1;
			for (i in 0...32) {
				
				// TODO JOYPAD (broken)
				//if (FlxG.gamepads.lastActive.getButton(i).current > 0) {
					//recent = i;
					//break;
				//}
			}
			
			// If a button was pressed
			if (recent != -1) {
				// Double checking
				if (confirming) {
					// If confirmed, move on to the next button to check (or exit)
					if (new_vals[idx] == recent) {
						confirming = false;
						//Log.trace("confirm passed");
						idx++;
						if (idx == 4) {
							mode = 10;
							cur_button_text.text = " ";
							error_text.text = Registry.R.dialogue_manager.lookup_sentence("ui", "joy_config", 7);
							Registry.R.sound_manager.play(SNDC.menu_confirm);
							
						} else {
							//Log.trace("checking for idx " + Std.string(idx));
							
							Registry.R.sound_manager.play(SNDC.menu_confirm);
							cur_button_text.text = Registry.R.dialogue_manager.lookup_sentence("ui", "joy_config", idx);
							error_text.text = " ";
							mode = 10;
						}
					} else {
						// error: not the same 
						// have to start over
						error_text.text = Registry.R.dialogue_manager.lookup_sentence("ui", "joy_config", 5);
						
						Registry.R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
						//Log.trace("confirm failed. try again");
						new_vals.splice(idx, 1);
						confirming = false;
						mode = 10;
					}
				} else {
					if (new_vals.indexOf(recent) != -1) {
						// Error for duplicate
						Registry.R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
						error_text.text = Registry.R.dialogue_manager.lookup_sentence("ui", "joy_config", 4);
						//Log.trace("duplicate");
					} else {
						
						Registry.R.sound_manager.play(SNDC.menu_confirm);
						error_text.text = Registry.R.dialogue_manager.lookup_sentence("ui", "joy_config", 6);
						//Log.trace("new key " + Std.string(idx) + " is now " + Std.string(recent)+" press again");
						new_vals.push(recent);
						confirming = true;
					}
					mode = 10;
				}
			}
		} else if (mode == 2) {
			if ((FlxG.gamepads.lastActive.anyButton())) {
				mode = -5;
				//Log.trace("new buttons confirmed.");
				Registry.R.input.joy_a1_id = new_vals[0];
				Registry.R.input.joy_a2_id = new_vals[1];
				Registry.R.input.joy_pause_id = new_vals[2];
				Registry.R.input.joy_sit_id = new_vals[3];
				Log.trace(new_vals);
			}
		} else if (mode == 10) {
			// Wait for no buttons to be held
			for (i in 0...32) {
				// TODO JOYPAD (broken)
				//if (FlxG.gamepads.lastActive.getButton(i).current > 0) {
					//break;
				//}
				if (i == 31) {
					if (idx == 4) {
						
						// Text: "Config complete! press any button to exit"
						//Log.trace("Done press anything to leave");
						mode = 2;
					} else if (confirming) {
						mode = 1;
					} else {
						mode = 1;
					}
					// Display the correct message here
				}
			}
		} else if (mode == 100) {
			dialogue_box.start_dialogue("ui", "joy_config", 8);
			mode = 101;
		} else if (mode == 101) {
			if (dialogue_box.last_yn == 1) {
				Registry.R.input.is_xbox = true;
				mode = 10;
			} else if (dialogue_box.last_yn == 2) {
				Registry.R.input.is_xbox = false;
				mode = 10;
			} else if (dialogue_box.last_yn == 0) {
				mode = 0;
			}
			if (mode == 10) {
				bg.visible = cur_button_text.visible = error_text.visible = true;
			}
		}
		super.update(elapsed);
	}
	
	public function activate(db:DialogueBox):Void {
		dialogue_box = db;
		mode = 100;
		idx = 0;
		new_vals = [];
		Log.trace("activated, checking for idx 0");
		
		if (!did_init) {
			do_init();
			did_init = true;
		}
		
		bg.visible = cur_button_text.visible = error_text.visible = false;
		
		bg.x = (FlxG.width - 300) / 2;
		bg.y = 32;
		bg.resize(300, 100);
		DialogueBox.MOST_RECENT_CALLED_BOX = dialogue_box;
		dialogue_box.MAX_CHARS_PER_LINE = Std.int(Std.int(bg.width - 16) / cur_button_text.font.spaceWidth);
		cur_button_text.text = Registry.R.dialogue_manager.lookup_sentence("ui", "joy_config", 0);
		cur_button_text.move(bg.x + 8, bg.y + 8);
		error_text.text = " ";
		error_text.move(cur_button_text.x, cur_button_text.y + 48);
	}
	public function is_done():Bool {
		if (mode == 0) {
			Registry.R.dialogue_manager.FORCE_LINE_SIZE = -1;
		}
		return mode == 0;
	}
	
	function do_init():Void 
	{
		bg = new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH, false, "assets/sprites/ui/9slice_dialogue.png");
		bg.scrollFactor.set(0, 0);
		bg.resize(40, 40);
		add(bg);
		cur_button_text = HF.init_bitmap_font(" ", "left");
		error_text = HF.init_bitmap_font(" ", "left");
		cur_button_text.double_draw = error_text.double_draw = true;
		add(cur_button_text);
		add(error_text);
		//Registry.R.dialogue_manager.FORCE_LINE_SIZE = 40;
	}
	public function update_font():Void {
		if (!did_init) return;
		var bm:FlxBitmapText;
		var i:Int = 0;
		bm = HF.init_bitmap_font(cur_button_text.text, "left", Std.int(cur_button_text.x), Std.int(cur_button_text.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.visible = cur_button_text.visible;  i = members.indexOf(cur_button_text); members[i] = bm; cur_button_text.destroy(); cur_button_text = cast members[i];
		bm = HF.init_bitmap_font(error_text.text, "left", Std.int(error_text.x), Std.int(error_text.y), null, C.FONT_TYPE_APPLE_WHITE); bm.double_draw = true; bm.visible = error_text.visible;  i = members.indexOf(error_text); members[i] = bm; error_text.destroy(); error_text = cast members[i];
		
	}
	
}