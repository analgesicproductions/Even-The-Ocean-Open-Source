package entity.enemy;
import entity.MySprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import help.FlxX;
import help.HF;
import state.MyState;

class BatThing extends MySprite
{

	private var aggro_zone:FlxSprite;
	private var t_wind_up:Float = 0;
	private var tm_wind_up:Float = 0;
	private var vel_wind_up:Float = 0;
	private var vel_track:Float = 0;
	private var anti_windup_accel:Float = 0;
	private var vel_dash:Float = 0;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "BatThing");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(32, 32, 0xffff00ff);
			case 1:
				makeGraphic(32, 32, 0xffffffff);
			default:
				makeGraphic(32, 32, 0xffffffff);
		}
		width = height = 20;
		offset.set(6, 6);
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("aggro_zone_offset", "-125,-125");
		p.set("dash_vel", 250);
		p.set("tm_wait", 0.5);
		p.set("vel_wind_up", 30);
		p.set("vel_track", 100);
		p.set("aggro_zone_size", "250,250");
		p.set("windup_accel", 196);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		var s:String = props.get("aggro_zone_offset");
		aggro_zone = new FlxSprite(ix+Std.parseInt(s.split(",")[0]),iy+Std.parseInt(s.split(",")[1]));
		s= props.get("aggro_zone_size");
		aggro_zone.makeGraphic(Std.parseInt(s.split(",")[0]), Std.parseInt(s.split(",")[1]), 0x55ff0000);
		
		vel_dash = props.get("dash_vel");
		vel_track = props.get("vel_track");
		vel_wind_up = props.get("vel_wind_up");
		tm_wind_up = props.get("tm_wait");
		anti_windup_accel = props.get("windup_accel");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [aggro_zone]);
		super.destroy();
	}
	
	private var mode:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [aggro_zone]);
		}
		if (R.editor.editor_active) {
			aggro_zone.visible = true;
		} else {
			aggro_zone.visible = false;
		}
		if (mode == 0) {
			if (x < ix && velocity.x < 0) {
				x = ix;
			} else if (x > ix && velocity.x > 0) {
				x = ix;
			}
			if (y < iy && velocity.y < 0) {
				y = iy;
			} else if (y > iy && velocity.y > 0) {
				y = iy;
			}
			if (R.player.overlaps(aggro_zone) &&  FlxX.is_on_screen(this)) {
				mode = 1;
			}
		} else if (mode == 1) {
			var tx:Float = R.player.x - 32;
			var ty:Float = R.player.y + 4;
			
			var c:Int = 0;
			if (Math.abs(tx - x) < 2) {
				velocity.x = 0;
				c++;
			} else if (x < tx) {
				velocity.x = vel_track;
			} else {
				velocity.x = -vel_track;
			}
			if (Math.abs(ty - y) < 2) {
				velocity.y = 0;
				c++;
			} else if (y < ty) {
				velocity.y = vel_track;
			} else {
				velocity.y = -vel_track;
			}
			if (c == 2) {
				mode = 2;
				velocity.y = 0;
				velocity.x = -vel_wind_up;
				acceleration.x = anti_windup_accel;
			}
		} else if (mode == 2) {
			if (velocity.x >= 0) {
				velocity.x = vel_dash;
				acceleration.x = 0;
				mode = 3;
			}
		} else if (mode == 3) {
			if (R.player.overlaps(this)) {
				mode = 4;
			} else if (x + width > FlxG.camera.scroll.x + FlxG.camera.width) {
				mode = 0;
				HF.scale_velocity(velocity, this, new FlxObject(ix, iy, 0, 0), vel_track);
				
			}
		} else if (mode == 4) {
			R.player.velocity.set(velocity.x, 0);
			if (R.player.x < x) {
				R.player.x ++;
				if (R.player.x >= x) {
					R.player.x = x;
				}
			}
			
			R.player.y = y - 4;
			
			if (R.input.up) {
				velocity.y = -50;
			} else if (R.input.down) {
				velocity.y = 50;
			} else {
				velocity.y = 0;
			}
			
			if (R.player.wasTouching & FlxObject.RIGHT != 0) {
				mode = 5;
				if (dmgtype == 0) {
					R.player.add_dark(44);
				} else {
					R.player.add_light(44);
				}
			}
		} else if (mode == 5) {
			t_wind_up += FlxG.elapsed;
			if (t_wind_up > tm_wind_up) {
				t_wind_up = 0;
				mode = 0;
				HF.scale_velocity(velocity, this, new FlxObject(ix, iy, 0, 0), vel_track);
			}
		}
		super.update(elapsed);
	}
}