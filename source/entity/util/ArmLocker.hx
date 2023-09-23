package entity.util;

import autom.SNDC;
import entity.MySprite;
import flixel.FlxSprite;
import help.AnimImporter;
import help.HF;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class ArmLocker extends MySprite
{
	
	private var debugin:FlxSprite;

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		debugin = new FlxSprite();
		super(_x, _y, _parent, "ArmLocker");
	}
	
	override public function change_visuals():Void 
	{
		debugin.makeGraphic(4, 4, 0xff0000ff);
		debugin.visible = false;
		switch (vistype) {
			case 0:
				if (1 == props.get("hor_passage")) {
					AnimImporter.loadGraphic_from_data_with_id(this, 64, 64, "ArmLocker", "horPassage");
				} else {
					AnimImporter.loadGraphic_from_data_with_id(this, 64, 64, "ArmLocker", "vertPassage");
				}
				width = height = 32;
				offset.set(16, 16);
				if (1 == props.get("is_exit")) {
					animation.play("unlock");
				} else {
					animation.play(Std.string(props.get("dir")));
				}
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("is_exit", 0);
		p.set("dir", 0);
		p.set("hor_passage", 1);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);

		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		if (has_card) {
			ON_CARD = false;
			TURN_OFF_CARDS = false;
			R.player.FORCE_SHIELD_DIR = -1;
		}
		HF.remove_list_from_mysprite_layer(this, parent_state, [debugin]);
		super.destroy();
	}
	
	public static var ON_CARD:Bool = false;
	public var has_card:Bool = false;
	public static var TURN_OFF_CARDS:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		
		switch (props.get("dir")) {
			case 0:
				debugin.x = x + 12;
				debugin.y = y;
			case 1:
				debugin.x = x + 24;
				debugin.y = y + 12;
			case 2:
				debugin.x = x + 12;
				debugin.y = y + 26;
			case 3:
				debugin.x = x;
				debugin.y = y + 12;
		}
		
		if (has_card) {
			if (TURN_OFF_CARDS) {
				TURN_OFF_CARDS = false;
				has_card = false;
				ON_CARD = false;
				R.player.FORCE_SHIELD_DIR = -1;
			} else {
				R.input.force_shield = 0;
			}
		} else {
			if (R.player.overlaps(this)) {
				if (props.get("is_exit") == 1) {
					TURN_OFF_CARDS = true;
					if (!has_overlapped_and_not_gotten_off && R.player.FORCE_SHIELD_DIR != -1) {
						animation.play("unlock_flash");
						R.sound_manager.play(SNDC.raisewall_fall);
						has_overlapped_and_not_gotten_off = true;
					}
				} else {
					if (!ON_CARD) {
						ON_CARD = true;
						has_card = true;
						if (!has_overlapped_and_not_gotten_off) {
							animation.play(Std.string(props.get("dir")) + "_flash");
							has_overlapped_and_not_gotten_off = true;
						}
						R.input.force_shield = 0;
						R.player.shield_fixed = false;
						R.player.FORCE_SHIELD_DIR = props.get("dir");
						R.sound_manager.play(SNDC.raisewall);
					} else {
						TURN_OFF_CARDS = true;
					}
				}
			} else {
				has_overlapped_and_not_gotten_off = false;
			}
		}
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [debugin]);
		}
		super.update(elapsed);
	}
	private var has_overlapped_and_not_gotten_off:Bool = false;
}