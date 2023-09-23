package entity.ui;

import autom.SNDC;
import global.C;
import global.Registry;
import help.AnimImporter;
import help.DialogueManager;
import help.HF;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class DecisionBox extends FlxTypedGroup<FlxSprite>
{

	private var box:FlxSprite;
	private var choices:FlxBitmapText;
	private var selector:FlxSprite;
	private var selector_idx:Int = 0;
	private var num_decisions:Int = 0;
	private var skip:Bool = false;
	private var R:Registry;
	public function new() 
	{
		super(0);
		box = new FlxSprite(100, 100);
		box.makeGraphic(150, 35, 0xaa000000);
		box.scrollFactor.set(0, 0);
		add(box);
		
		choices = HF.init_bitmap_font(" ", "left", Std.int(box.x + 8), Std.int(box.y + 4), null, C.FONT_TYPE_APPLE_WHITE);
		add(choices);
		
		selector = new FlxSprite(0, 0);
		AnimImporter.loadGraphic_from_data_with_id(selector, 8, 8, "MenuSelector");
		selector.animation.play("glow");
		selector.scrollFactor.set(0, 0);
		add(selector);
		
		R = Registry.R;
		
	}
	public function get_response_index():Int {
		return selector_idx;
	}
	public function create_prompt(decisions:Array<String>):Void {
		choices.text = decisions.join("\n");
		num_decisions = decisions.length;
		exists = true;
		selector_idx = 0;
		selector.x = choices.x - 10;
		selector.y = choices.y;
		skip = true;
	}
	override public function update(elapsed: Float):Void {
		super.update(elapsed);
		
		if (skip) {
			skip = false;
			return;
		}
		if (R.input.jpUp) {
			R.sound_manager.play(SNDC.menu_move);
			if (selector_idx > 0) {
				selector_idx --;
				selector.y -= R.dialogue_manager.DIALOGUE_LINE_HEIGHT;
			}
		} else if (R.input.jpDown) {
			R.sound_manager.play(SNDC.menu_move);
			if (selector_idx <  num_decisions - 1) {
				selector_idx ++;
				selector.y += R.dialogue_manager.DIALOGUE_LINE_HEIGHT;
			}
			
		} else if (R.input.jpCANCEL|| R.input.jpPause) {
			R.sound_manager.play(SNDC.menu_close);
			exists = false;
			selector_idx = -1;
		} else if (R.input.jpCONFIRM) {
			R.sound_manager.play(SNDC.menu_confirm);
			exists = false;
		}
	}
	
}