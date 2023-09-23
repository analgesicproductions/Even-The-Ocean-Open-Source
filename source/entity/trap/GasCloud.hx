package entity.trap;
import entity.MySprite;
import haxe.Log;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxObject;
import state.MyState;

/**
 * ...
 * @author Melos Han-Tani
 */

class GasCloud extends MySprite
{

	private var default_velocity:Float = 0;
	public function new(_x:Int,_y:Int,_p:MyState)
	{
		super(_x, _y, _p, "GasCloud");
		
	}
	
	private var T_LIGHT:Int = 0;
	private var T_DARK:Int = 1;
	
	private var x_mode:Int = 0;
	private var y_mode:Int = 0;
	
	override public function change_visuals():Void {
		if (vistype == T_LIGHT) {
			makeGraphic(80, 80, 0xaaffffff);
		} else if (vistype == T_DARK) { 
			makeGraphic(80, 80, 0xaaff00ff);
		}
	}
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		
		var d:Map<String,Dynamic> = new Map<String,Dynamic> ();
		d.set("type", T_LIGHT);
		d.set("vel", 50);
		return d;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		vistype = p.get("type");
		velocity.x = p.get("vel");
		velocity.y = p.get("vel");
		default_velocity = velocity.y;
		change_visuals();
		
	}
	
	override public function preUpdate():Void 
	{
		FlxObject.separate(this, parent_state.tm_bg);
		FlxObject.separate(this, parent_state.tm_bg2);
	
		super.preUpdate();
	}
	override public function update(elapsed: Float):Void 
	{
		if (overlaps(R.player)) {
			if (vistype == T_LIGHT) {
				R.player.RESET_status_gassed++;
			} else if (vistype == T_DARK) {
				R.player.RESET_status_gassed--;
			}
		} 
		
		if (x_mode == 0) {
			velocity.x = default_velocity;
			if (touching & FlxObject.RIGHT != 0) {
				x_mode = 1;
			}
		} else {
			velocity.x = -default_velocity;
			if (touching & FlxObject.LEFT != 0) {
				x_mode = 0;
			}
		}
		if (y_mode == 0) { 
			velocity.y = default_velocity;
			if (touching & FlxObject.DOWN != 0) {
				y_mode = 1;
			}
		} else {
			velocity.y = -default_velocity;
			if (touching & FlxObject.UP != 0) {
				y_mode = 0;
			}
		}
	}
	
	//private function do_midpoints_touch_tm(tm:FlxTilemapExt):Int {
		//if (0 != tm.getTileCollisionFlags(x + width / 2, y)) return FlxObject.UP;
		//if (0 != tm.getTileCollisionFlags(x + width / 2, y + height)) return FlxObject.DOWN;
		//if (0 != tm.getTileCollisionFlags(x, y + height / 2)) return FlxObject.LEFT;
		//if (0 != tm.getTileCollisionFlags(x + width, y + height / 2))  return FlxObject.RIGHT;
		//return FlxObject.NONE;
	//}
}