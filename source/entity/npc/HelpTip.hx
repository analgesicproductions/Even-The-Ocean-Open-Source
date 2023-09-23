package entity.npc;
import entity.MySprite;
import entity.ui.NineSliceBox;
import global.C;
import help.DialogueManager;
import help.HF;
import help.InputHandler;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.math.FlxPoint;
import openfl.Assets;
import openfl.geom.Rectangle;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class HelpTip extends MySprite
{
	
	private var detector_zone:FlxSprite;
	private var text:FlxBitmapText;
	
	private var text_bg:NineSliceBox;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{

		
		text_bg= new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH, false, "assets/sprites/ui/9slice_dialogue.png");
		text_bg.scrollFactor.set(0, 0);
		text_bg.x = 100;
		text_bg.y = 120;
		text_bg.resize(280, 70);
		text_bg.alpha = 0;
		
		detector_zone = new FlxSprite(0, 0);
		detector_zone.makeGraphic(64, 64, 0xff00ff00);
		detector_zone.alpha = 0.5;
		
		text = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_ALIPH_WHITE);
		
		
		super(_x, _y, _parent, "HelpTip");
		
	}
	
	private var reszied:Bool = false;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				makeGraphic(32,32, 0xfa241222); visible = false;
				
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("id", 0);
		p.set("on_bottom", 1);
		return p;
	}

	
	private var my_id:Int = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		
		HF.copy_props(p, props);
		my_id = props.get("id");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [detector_zone, text_bg, text]);
		detector_zone.destroy(); text.destroy();
		super.destroy();
	}
	private var mode:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		
		
		if (stoppp) {
			text.alpha -= 0.02;
			text_bg.alpha -= 0.02;
			detector_zone.alpha = 0;
			alpha = 0;
			super.update(elapsed);
			return;
		}
		
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [detector_zone, text_bg,text]);
		}
		
		detector_zone.x = x;
		detector_zone.y = y;
		if (R.editor.editor_active) {
			detector_zone.visible = true;
			text.text = Std.string(my_id);
			//text.x = x; text.y = y;
			text.alpha = 1;
			super.update(elapsed);
			return;
		} else {
			detector_zone.visible = false; //false
			//text.x = (x + width / 2) - (text.width / 2);
			//text.y = y - text.height;
		}
		
		
		super.update(elapsed);
		
		if (mode == 0) {
			text.alpha -= 0.025;
			text_bg.alpha -= 0.025;
			if (R.player.overlaps(detector_zone)) {
				
				mode = 1;
				if (my_id >= 0) {
					//R.dialogue_manager.FORCE_LINE_SIZE = 99;
					//var as:Array<String> = R.dialogue_manager.get_dialogue("helptip", "intro", my_id);
					//text.text = "";
					//for (i in 0...as.length) {
						//text.text += as[i];
						//if (i == as.length - 1) break;
					//}
					
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", my_id, true, true);
					text.text = DialogueManager.justify(text.text, 32);
					//R.dialogue_manager.FORCE_LINE_SIZE = -1;
					if (!reszied) {
						reszied = true;
						text_bg.resize(text.width + 16, text.height + 16);
						text_bg.x = (C.GAME_WIDTH - text_bg.width) / 2;
						text_bg.y = C.GAME_HEIGHT -  32 - text_bg.height;
						if (0 == props.get("on_bottom")) {
							text_bg.y = 32;
						}
						text.double_draw = true;
					}
				
					text.x = text_bg.x + 8;
					text.y = text_bg.y + 8;
				} else if (my_id == 1) {
					text.text =R.dialogue_manager.lookup_sentence("helptip", "intro", 1)+ R.input.keybindings[InputHandler.KDX_A2];
				} else if (my_id == 2) {
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", 2) + R.input.keybindings[InputHandler.KDX_A1];
					text.text = DialogueManager.justify(text.text, 32);
				} else if (my_id == 3) {
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", 3) + R.input.keybindings[InputHandler.KDX_PAUSE];
				} else if (my_id == 4) {
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", 4) + R.input.keybindings[InputHandler.KDX_UP] + ", " + R.input.keybindings[InputHandler.KDX_DOWN];
				} else if (my_id == 5) {
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", 5);
				} else if (my_id == 6) {
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", 6) + R.input.keybindings[InputHandler.KDX_A2];
				} else if (my_id == 7) {
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", 7);
				} else if (my_id == 8) {
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", 8);
				} else if (my_id  == 9) {
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", 9);
				} else if (my_id  == 10) {
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", 10);
				} else if (my_id == 11) {
					text.text = R.dialogue_manager.lookup_sentence("helptip", "intro", 11);
				} else {
					text.text = R.dialogue_manager.lookup_sentence("helptip","intro",my_id);
				}
			}
		}  else if (mode == 1) {
			text.alpha += 0.025;
			text_bg.alpha += 0.025;
			if (!R.player.overlaps(detector_zone)) {
				mode = 0;
			}
		}
		
		
					//text_bg.x = text.x - 2;
					//text_bg.y = text.y - 2;
		
		
		if (R.there_is_a_cutscene_running) {
			text.alpha = 0;
			text_bg.alpha = 0;
		}
		
		
	}
	
	private var stoppp:Bool = false;
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == "off") {
			stoppp = true;
		}
		return -1;
	}
}