package entity.util;
/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import autom.SNDC;
import entity.MySprite;
import help.HF;
import flixel.FlxObject;
import state.MyState;

class Bouncer extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "Bouncer");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				if (is_hor) {
					makeGraphic(32,16);
				} else {
					makeGraphic(16, 32);
				}
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("is_hor", 1);
		p.set("u_or_r", 1); // up or right
		return p;
	}
	private var is_hor:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		immovable = true;
		HF.copy_props(p, props);
		if (props.get("is_hor") == 1) {
			is_hor = true;
		} else {
			is_hor = false;
		}
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		//HF.remove_list_from_mysprite_layer(this, parent_state, []);
		super.destroy();
	}
	
	private var touchin_player:Bool = false;
	override public function preUpdate():Void 
	{
		super.preUpdate();
	}
	override public function update(elapsed: Float):Void 
	{
		//if (!did_init) {
			//did_init = true;
			//HF.add_list_to_mysprite_layer(this, parent_state, []);
		//}
		
		if (R.player.overlaps(this)) {
			//if (!touchin_player) {
				if (is_hor) {
					if (props.get("u_or_r") == 1) {
						R.player.velocity.y = -Math.abs(R.player.velocity.y);
						if (R.player.velocity.y < 0 && R.player.velocity.y > -100) {
							R.player.velocity.y = -100;
						}
						if (R.player.velocity.y > -180) {
							R.player.velocity.y = -180;
						}
						R.player.y = y - R.player.height - 1;
					} else {
						R.player.velocity.y = Math.abs(R.player.velocity.y);
						
					}
				} else {
					if (props.get("u_or_r") == 1) {
						R.player.velocity.x = Math.abs(R.player.velocity.x);
						R.player.do_hor_push(Std.int(R.player.velocity.x + Math.abs(R.player.velocity.y)), false, true, 10);
					} else {
						R.player.velocity.x = -Math.abs(R.player.velocity.x);
						R.player.do_hor_push(Std.int(R.player.velocity.x - Math.abs(R.player.velocity.y)), false, true, 10);
					}
					R.player.velocity.y = -50;
				}
				//touchin_player = true;
				R.sound_manager.play(SNDC.pop);
			//}
		} else {
			
			touchin_player = false;
		}
		super.update(elapsed);
	}
}