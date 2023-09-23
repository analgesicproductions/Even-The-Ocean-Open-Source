package entity.enemy;
import autom.SNDC;
import entity.MySprite;
import flixel.FlxSprite;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class WaterGlider extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		battery = new FlxSprite();
		super(_x, _y, _parent, "WaterGlider");
		immovable = true;
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(32, 16, 0xffff00ff);
				battery.makeGraphic(1, 8, 0xffff0000);
				battery.origin.set(0, 0);
			case 1:
				makeGraphic(32, 16, 0xffffffff);
				battery.makeGraphic(1, 8, 0xffff0000);
				battery.origin.set(0, 0);
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("drag", 70);
		p.set("vis-dmg", "0,0");
		p.set("dark_vel", "62,56");
		p.set("light_vel", "38,70");
		p.set("tm_hurt", 0.2);
		p.set("dmg", 48);
		p.set("tm_move", 4.0);
		return p;
	}
	
	private var t_hurt:Float = 0;
	private var tm_hurt:Float = 0;
	private var battery:FlxSprite;
	private var vel:Float = 0;
	private var vel_rise:Float = 0;
	private var t_move:Float = 0;
	private var tm_move:Float = 0;
	
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		
		if (dmgtype == 0) {
			vel = Std.parseInt(props.get("dark_vel").split(",")[0]);
			maxVelocity.y = vel_rise =  Std.parseInt(props.get("dark_vel").split(",")[1]);
		} else {
			vel = Std.parseInt(props.get("light_vel").split(",")[0]);
			maxVelocity.y = vel_rise = Std.parseInt(props.get("light_vel").split(",")[1]);
		}
		change_visuals();
		tm_hurt = props.get("tm_hurt");
		tm_move = props.get("tm_move");
		t_move = 0;
		battery.scale.x = 16 * (1 - (t_move / tm_move));
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [battery]);
		super.destroy();
	}
	
	override public function preUpdate():Void 
	{
	immovable = false;
	
	if (mode != 4) {
		FlxObject.separate(parent_state.tm_bg, this);
	}
		immovable = true;
		super.preUpdate();
	}
	private var mode:Int = 0;
	private var MODE_IDLE:Int = 0;
	private var MODE_MOVING:Int = 1;
	private var wall_mode:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [battery], true);
		}
		
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
		
		if (mode == MODE_IDLE) {
			if (FlxObject.separateY(this, R.player) && R.player.touching != FlxObject.UP) {
				mode = MODE_MOVING;
				R.sound_manager.play(SNDC.pop);
				
					facing = R.player.facing;
					if (facing == FlxObject.LEFT) {
						velocity.x = vel * -1;
					} else {
						velocity.x = vel;
					}
			}
		// faster h/ slow v for purple
		// accelerate to max with y speed
		} else if (mode == MODE_MOVING) {
			if (touching == FlxObject.DOWN) {
				mode = 3;
				return;
			}
			var sep:Bool = false;
			if (FlxObject.separateY(this, R.player)) {
				sep = true;
					facing = R.player.facing;
					if (facing == FlxObject.LEFT) {
						velocity.x = vel * -1;
					} else {
						velocity.x = vel;
					}
				drag.x = 0;
				acceleration.y = 200;
				R.player.velocity.y = velocity.y + FlxG.elapsed * acceleration.y;
				if (R.player.velocity.y < 0) R.player.velocity.y = 0;
				
				
				
				t_hurt += FlxG.elapsed;
				if (t_hurt > tm_hurt) {
					t_hurt -= tm_hurt;
					if (dmgtype == 0) {
						R.player.add_dark(2);
					} else if (dmgtype == 1) {
						R.player.add_light(2);
					}
				}
				
				if (!R.input.left && !R.input.right) {
					R.player.velocity.x = velocity.x;
				}
				drag.y = 0;
				
			} else {
				drag.x = props.get("drag");
				if (drag.y == 0) {
					drag.y = drag.x;
					velocity.y = -vel_rise;
					acceleration.y = 0;
				}
			}
			
			if (parent_state.tm_bg.getTileCollisionFlags(x+2, y - R.player.height - 3) != 0 || parent_state.tm_bg.getTileCollisionFlags(x+width-2, y - R.player.height - 3) != 0 ) {
				velocity.y = 0;
			}
			
			t_move += FlxG.elapsed;

			var before:Float =  tm_move - t_move - FlxG.elapsed;
			var after:Float = before + FlxG.elapsed;
			if (before < 0.5 * tm_move && after > 0.5 * tm_move) {
				R.sound_manager.play(SNDC.pop);
			}
			if (before < 0.75* tm_move && after > 0.75* tm_move) {
				R.sound_manager.play(SNDC.pop);
			}
			if (tm_move - t_move - FlxG.elapsed < 0.5 && tm_move - t_move > 0.5) {
				R.sound_manager.play(SNDC.player_jump_down);
			}
			battery.scale.x = 16 * (1 - (t_move / tm_move));
			if (t_move > tm_move) {
				R.sound_manager.play(SNDC.pop);
				mode = 2;
				if (sep) {
					R.player.skip_motion_ticks = 8;
					FlxG.camera.shake(0.01, 0.05);
					if (dmgtype == 0) {
						R.player.add_dark(props.get("dmg")); 
					} else {
						R.player.add_light(props.get("dmg"));
					}
				}
			}
			
		} else if (mode == 2) {
			acceleration.y = 0;
			drag.set(0, 0);
			HF.scale_velocity(this.velocity, this, new FlxObject(ix, iy, 1, 1), 100);
			mode = 4;
			FlxObject.separate(this, R.player);
		} else if (mode == 3) { // 
			velocity.x = velocity.y = 0;
			FlxObject.separate(this, R.player);
			mode = 2;
			
		} else if (mode == 4) {
			alpha = 0.5;
			drag.set(0, 0);
			FlxObject.separate(this, R.player);
			var b:Bool = false;
			if (velocity.x == 0 && velocity.y == 0) {
				b = true;
			}
			if ((velocity.x > 0 && x >= ix) || (velocity.x <= 0 && x <= ix)) {
				velocity.x = 0;
				x = ix;
				if ((velocity.y > 0 && y >= iy) || (velocity.y < 0 && y <= iy)) {
					b = true;
				}
			}
			if (b) {
				move(ix, iy);
				
				t_move = 0;
				velocity.set(0, 0);
				drag.y = drag.x = props.get("drag");
				alpha = 1;
				mode = 0;
				battery.scale.x = 16 * (1 - (t_move / tm_move));
			}
		}
		super.update(elapsed);
	}
	override public function postUpdate(elapsed):Void 
	{
		super.postUpdate(elapsed);
		battery.x = x + 4;
		battery.y = y + 4;
	}
}