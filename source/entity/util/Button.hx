package entity.util;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import autom.SNDC;
import entity.MySprite;
import flixel.FlxObject;
import global.C;
import help.AnimImporter;
import help.HF;
import flixel.FlxG;
import state.MyState;

class Button extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		hitbox = new FlxObject(x, y, 8, 8);
		super(_x, _y, _parent, "Button");
	}
	
	private var hitbox:FlxObject;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 48, 32, name, "light");
				animation.play("up",true);
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 48, 32, name, "dark");
				animation.play("up",true);
				
		}
		width = 16;
		offset.x = 16;
		height = 19;
		offset.y = 32 - 19;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", 1);
		p.set("children", "");
		p.set("damage", 24);
		p.set("t_wait", 0);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		vistype = props.get("vistype");
		change_visuals();
		tm_wait = props.get("t_wait");
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	private var mode:Int = 0;
	
	private var t_wait:Float = 0;
	private var tm_wait:Float = 0;
	override public function update(elapsed: Float):Void 
	{
		y = iy + offset.y;
		
		
		if (!did_init) {
			did_init = true;
			populate_parent_child_from_props();
			broadcast_to_children("button_off");
		}
		
		
		hitbox.move(x + 4, y + 3 - 8);
		
		if (mode == 0) {
			if (R.player.overlaps(hitbox)) {
				animation.play("down");
				R.sound_manager.play(SNDC.pod_hit);
				if (props.get("vistype") == 0) { // Dark
					R.player.add_light(props.get("damage"));
					
					var b:Bool = false;
					for (i in 0...children.length) {
						if (69 == children[i].recv_message("button_on")) {
							b = true;
						}
					}
					if (!b) broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
				} else { // light
					R.player.add_dark(props.get("damage"));
					var b:Bool = false;
					for (i in 0...children.length) {
						if (69 == children[i].recv_message("button_on")) {
							b = true;
						}
					}
					if (!b)	broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
				}
				mode = 1;
			}
		} else if (mode == 1) {
			if (tm_wait == 0) {
				
			} else {
				if (tm_wait == -1 || !R.player.overlaps(hitbox)) {
					animation.play("recover");
					t_wait += FlxG.elapsed;
					if (t_wait > tm_wait) {
						t_wait = 0;
						mode = 0;
						animation.play("up");
					}
				}
			}
		}
		
		
		if (R.player.overlaps(this) && !R.player.is_jump_state_air()) {
			R.player.y = R.player.last.y = y + 1 - R.player.height;
			R.player.velocity.y = 0;
			R.player.touching |= 0x1000;
		}
		
		super.update(elapsed);
	}
}