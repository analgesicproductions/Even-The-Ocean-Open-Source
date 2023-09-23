package entity.enemy;
import autom.SNDC;
import entity.MySprite;
import global.C;
import haxe.Log;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import state.MyState;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class LaunchBug extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		bullets = new FlxTypedGroup<FlxSprite>();
		super(_x, _y, _parent, "LaunchBug");
	}
	
	private var dmg_type:Int = 0;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				dmg_type = 0;
				makeGraphic(16, 16, 0xff000000);
			case 1:
				dmg_type = 1;
				makeGraphic(16, 16, 0xffffffff);
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("is_up", 0);
		p.set("x_vel", 150);
		p.set("y_vel", 50);
		p.set("launch_vel", 200);
		p.set("is_left", 0);
		p.set("ishor", 0);
		p.set("vistype", 0);
		p.set("bul_nVelFreq", "0,100,0.2");
		p.set("bul_dmg", 20);
		p.set("tm_hurt", 0.02);
		return p;
	}
	
	private var xvel:Int = 0;
	private var yvel:Int = 0;
	private var launchvel:Int = 0;
	private var t_hurt:Float = 0;
	private var tm_hurt:Float = 0.02;
	private var bul_dmg:Int;
	
	private var num_bullets:Int = 0;
	private var bul_vel:Int = 0;
	private var bul_freq:Float = 0;
	private var bullets:FlxTypedGroup<FlxSprite>;
	private var t_bul_freq:Float = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		xvel = props.get("x_vel");
		yvel = props.get("y_vel");
		launchvel = props.get("launch_vel");
		is_up = props.get("is_up") == 1 ? true : false;
		is_left = props.get("is_left") == 1 ? true : false;
		vistype = props.get("vistype");
		bul_dmg = props.get("bul_dmg");
		tm_hurt = props.get("tm_hurt");
		
		var info:Array<Float> = HF.string_to_float_array(props.get("bul_nVelFreq"));
		num_bullets = Std.int(info[0]);
		bul_vel = Std.int(info[1]);
		bul_freq = info[2];
		
		bullets.clear();
		if (num_bullets > 0) {
			for (i in 0...num_bullets) {
				var b:FlxSprite = new FlxSprite();
				b.makeGraphic(8, 8, 0xff123123);
				bullets.add(b);
				b.visible = false;
			}
		}
		
		mode = MODE_TRACK_HOR;
		if (props.get("ishor") == 1) {
			mode = MODE_TRACK_VERT;
		}
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [bullets]);
		super.destroy();
	}
	
	private var mode:Int = 0;
	private var MODE_TRACK_HOR:Int = 0;
	private var MODE_TRACK_VERT:Int = 2;
	private var MODE_FIRE:Int  = 1;
	private var is_up:Bool = false;
	private var is_left:Bool = false;
	
	override public function preUpdate():Void 
	{
		FlxObject.separate(this, parent_state.tm_bg);
		super.preUpdate();
	}
	
	private var trying_to_fire:Bool = false;
	private var shooting_on:Bool = false;
	private var nr_shot:Int = 0;
	private var lastok:Float = 0;
	override public function update(elapsed: Float):Void 
	{
		
		if (!did_init) {
			did_init = true;
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [bullets]);
		}
		
		
			
			for (i in 0...bullets.length) {
				var b:FlxSprite = bullets.members[i];
				if (b.visible == true) {
					if (parent_state.tm_bg.getTileCollisionFlags(b.x + 4, b.y + 4) != FlxObject.NONE) {
						b.visible = false;
						b.velocity.set(0, 0);
					}
					if (R.player.shield_overlaps(b)) {
						b.visible = false;
					} else if (b.overlaps(R.player)) {
						if (dmg_type == 0) {
							R.player.add_dark(bul_dmg);
						} else if (dmg_type == 1) {
							R.player.add_light(bul_dmg);
						}
						b.visible = false;
					}
					continue;
				}
				
			}
			
			
		if (FlxX.l1_norm_from_mid(this, R.player) > C.GAME_WIDTH + C.GAME_HEIGHT) {
			if (mode != MODE_FIRE) {
				velocity.x = velocity.y = 0;
				return;
			}
		}
			
		if (num_bullets > 0 && shooting_on) {
			if (t_bul_freq > bul_freq) {

				for (i in 0...bullets.length) {
					var b:FlxSprite = bullets.members[i];
					
					if (b.visible == true) continue;
					b.visible = true;
					nr_shot++;
					b.x = x + 2;
					b.y = y + 2;
					if (mode == MODE_TRACK_HOR) {
						if (is_up) {
							b.velocity.set(0, bul_vel);
						} else {
							b.velocity.set(0, -bul_vel);
						}
					} else if (mode == MODE_TRACK_VERT) {
						if (is_left) {
							b.velocity.set(bul_vel, 0);
						} else {
							b.velocity.set(-bul_vel, 0);
						}	
					}
					t_bul_freq -= bul_freq;
					break;
				}
			} else {
				t_bul_freq += FlxG.elapsed;
			}
			
			if (nr_shot >= num_bullets) {
				nr_shot = 0;
				t_bul_freq = 0;
				shooting_on = false;
			}
		}
		
		
		if (mode == MODE_TRACK_HOR) {
			// tell for firing
			if (trying_to_fire) {
				
				angularVelocity = 400;
				ID++;
				if (ID > 24) {
					ID = 0;
					trying_to_fire = false;
					if (is_up) {
						velocity.y = launchvel;
					} else  {
						velocity.y = -launchvel;
					}
					mode = MODE_FIRE;
					shooting_on = true;
					angularVelocity = 0;
					angle = 0;
				}
			} else {
				if (R.player.x > x + width / 2) {
					velocity.x += 4;
					if (velocity.x > xvel) velocity.x = xvel;
				} else {
					velocity.x -= 4;
					if (velocity.x < -xvel) velocity.x = -xvel;
				}
				
				// if overlap, damage
				if (Math.abs(R.player.x - (x + width / 2)) < 5) {
					if (R.player.overlaps(this)) {
						velocity.x /= 2;
						ID++;
						if (ID == 5) {
							ID = 0;
							R.sound_manager.play(SNDC.touch_weed);
							if (dmgtype == 0) {
								R.player.add_dark(1);
							} else {
								R.player.add_light(1);
							}
						}
					} else {
						trying_to_fire = true;
						velocity.x = 0;
						ID = 0;
					}
				}
				
				var flag:Int = 0;
				
				var wc:Float = 0;
				if (is_up) {
					wc = y - 2;
				} else {
					wc = y + height + 2;
				}

				if (velocity.x > 0) {
					flag = parent_state.tm_bg.getTileCollisionFlags(x + width + 1,wc);
				} else {
					flag = parent_state.tm_bg.getTileCollisionFlags(x - 1, wc);
				}
				
				if (flag == FlxObject.NONE) {
					velocity.x = 0;
				} else {
				}
			}
			
		} else if (mode == MODE_TRACK_VERT) {
			
			if (R.player.y + R.player.height/2 > y + height / 2) {
				velocity.y = yvel;
			} else {
				velocity.y = -yvel;
			}
			
			if (Math.abs((R.player.y + R.player.height/2) - (y + height / 2)) < 4) {
				if (is_left) {
					velocity.x = launchvel;
				} else {
					velocity.x = -launchvel;
				}
				velocity.y = 0;
				if (velocity.x != 0) {
					mode = MODE_FIRE;
				}
				shooting_on = true;
			}
			
			var flag:Int = 0;
			var wc:Float = 0;
			
			if (is_left) {
				wc = x - 2;
			} else {
				wc = x + width+ 2;
			}
			
			if (velocity.y > 0) {
				flag = parent_state.tm_bg.getTileCollisionFlags(wc, y + height + 1);
			} else {
				flag = parent_state.tm_bg.getTileCollisionFlags(wc,y - 1);
			}
			if (flag == FlxObject.NONE) {
				velocity.y = 0;
			} else {
			}
		
			
			
		} else if (mode == MODE_FIRE) {
			
			
			if (overlaps(R.player)) {
				if (ID == 0) {
					R.player.skip_motion_ticks = 5;
					skip_motion_ticks = 4;
					R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
					if (R.player.facing == FlxObject.RIGHT) {
						R.player.do_hor_push( -50, true, true, 5);
					} else {
						R.player.do_hor_push( 50, true, true, 5);
					}
					if (dmg_type == 0) { // dark
						R.player.add_dark(32);
					} else { 
						R.player.add_light(32);
					}
					ID = 1;
				} else {
					
				}
			}
			
			if (touching & FlxObject.DOWN != 0) {
				mode = MODE_TRACK_HOR;
				velocity.y = 0;
				is_up = false;
			} else if (touching & FlxObject.UP != 0) {
				mode = MODE_TRACK_HOR;
				velocity.y = 0;
				is_up = true;
			}
			
			if (touching & FlxObject.RIGHT != 0) {
				mode = MODE_TRACK_VERT;
				velocity.x = 0;
				is_left = false;
			} else if (touching & FlxObject.LEFT != 0) {
				mode = MODE_TRACK_VERT;
				velocity.x = 0;
				is_left = true;
				
			}
		}
		super.update(elapsed);
	}
	
	private var skip_motion_ticks:Int;
	override public function postUpdate(elapsed):Void 
	{
		if (skip_motion_ticks > 0) {
			skip_motion_ticks--;
			return;
		}
		super.postUpdate(elapsed);
	}
	
}