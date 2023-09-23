package entity.util;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import entity.MySprite;
import entity.trap.MirrorLaser;
import entity.trap.Pew;
import flixel.FlxObject;
import help.HF;
import state.MyState;
import flixel.FlxG;

class LaserBlock extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "LaserBlock");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(16, 16, 0xffff85ff);
			case 1:
				makeGraphic(16, 16, 0xff888583);
			default:
				makeGraphic(16, 16, 0xff858583);
		}
	}
	
	private var reforms:Bool = false;
	private var t_reform:Float = -1;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("tm_reform", -1);
		return p;
	}
	
	private var tm_reform:Float;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		tm_reform = props.get("tm_reform");
		if (tm_reform >= 0) {
			reforms = true;
		}
		t_reform = 0;
		state = 0;
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		immovable = true;
		if (state == 0) {
			
			for (p in Pew.ACTIVE_Pews.members) {
				if (p != null) {
					if (p.generic_overlap(this,-1,vistype)) {
						state = 1;
					}
				}
			}
			for (m in MirrorLaser.ACTIVE_MirrorLasers) {
				if (m.generic_overlap(this,true,-1,vistype)) {
					state = 1;
				}
			}
			if (state == 1) {
				alpha = 0.5;
			}
		} else if (state == 1) {
			if (reforms) {
				state = 2;
			} else {
				
			}
		} else if (state == 2) {
			t_reform += FlxG.elapsed;
			if (t_reform > tm_reform) {
				t_reform = 0;
				alpha = 1;
				state = 0;
				if (R.player.overlaps(this)) {
					if (R.player.width/2 + R.player.x < x + width / 2) {
						R.player.do_hor_push( -100);
					} else {
						R.player.do_hor_push(100);
					}
					R.player.do_vert_push( -200);
				}
			}
		}
		
		if (state == 0) {
			FlxObject.separateY(this, R.player);
			if (wall_mode == 0) {
				var b:Bool = FlxObject.separateX(this, R.player);
				if (b) {
					if (R.player.touching & FlxObject.RIGHT > 0) {
						wall_mode = 1;
						R.player.activate_wall_hang();
					} else if (R.player.touching & FlxObject.LEFT > 0) {
						wall_mode = 2;
						R.player.activate_wall_hang();
					}
				}
			} else {
				if (wall_mode == 1 && R.input.right) {
					R.player.x = x - R.player.width + 1;
					R.player.activate_wall_hang();
				} else if (wall_mode == 2 && R.input.left) {	
					R.player.x = x + width - 1;
					R.player.activate_wall_hang();
				}
				if (!R.player.is_wall_hang_points_in_object(this)) {
					wall_mode = 0;
				}
			}
		} else {
			wall_mode = 0;
		}
		
		super.update(elapsed);
	}
	private var wall_mode:Int = 0;
}