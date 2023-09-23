package entity.enemy;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import autom.SNDC;
import entity.MySprite;
import entity.trap.Pew;
import entity.util.RaiseWall;
import entity.util.VanishBlock;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import state.MyState;
import flixel.FlxG;

class SpikeExtend extends MySprite
{

	private var chain:FlxSprite;
	private var wall_collider:FlxSprite;
	public static var ACTIVE_SpikeExtends:List<SpikeExtend>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		chain = new FlxSprite();
		wall_collider = new FlxSprite();
		//wall_collider.makeGraphic(16, 16, 0xffffffff);
		wall_collider.makeGraphic(32,32, 0xffffffff);
		wall_collider.visible = false;
		super(_x, _y, _parent, "SpikeExtend");
		ID = 0;
	}
	
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 64, 64, name, "dark");
				AnimImporter.loadGraphic_from_data_with_id(chain, 64, 64, name, "dark");
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 64, 64, name, "light");
				AnimImporter.loadGraphic_from_data_with_id(chain, 64, 64, name, "light");
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 64, 64, name, vistype);
				AnimImporter.loadGraphic_from_data_with_id(chain, 64, 64, name, vistype);
		}
		width = height = chain.width = chain.height = 32;
		offset.set(16, 16);
		chain.offset.set(16, 16);
		this.animation.play("idle",true);
		chain.animation.play("base", true);
		switch (dir) {
			case 1:
				angle = 0;
			case 2:
				angle = 90;
			case 3:
				angle = 180;
			case 0:
				angle = 270;
		}
		chain.angle = angle;
	}
	
	private var dir:Int;
	private var vel_retract:Int;
	private var accel_extend:Int;
	private var vel_extend:Int;
	private var t_wait_at_ends:Float;
	private var tm_wait_at_ends:Float;
	private var dmg:Int;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("dmg", 48);
		p.set("tm_wait_at_ends", 0.7);
		p.set("vel_extend", 300);
		p.set("accel_extend", 1000);
		p.set("vel_retract", 120);
		p.set("dir", 1);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		this.immovable = true;
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		vel_retract = props.get("vel_retract");
		vel_extend = props.get("vel_extend");
		maxVelocity.set(vel_extend, vel_extend);
		accel_extend = props.get("accel_extend");
		tm_wait_at_ends = props.get("tm_wait_at_ends");
		
		if (vel_extend == 300) vel_extend = 240;
		if (accel_extend == 1000) accel_extend = 480;
		
		dmg = props.get("dmg");
		dir = props.get("dir");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		ACTIVE_SpikeExtends.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [chain,wall_collider]);
		super.destroy();
	}
	
	override public function recv_message(message_type:String):Int 
	{
		return super.recv_message(message_type);
	}
	public var mode:Int = 0;
	private var touched_wall:Bool = false;
	private var topwallignore:Bool = false;
	override public function preUpdate():Void 
	{
		touched_wall = FlxObject.separate(parent_state.tm_bg, wall_collider);
		
		super.preUpdate();
	}
	
	private var can_big_damage:Bool = false;
	private function big_damage(se:SpikeExtend = null):Void {
		
		if (se != null) {
			se.mode = 2;
			if (se.velocity.x > 0) {
				se.x -= 4;
				se.last.x -= 4;
			}
			se.velocity.set(0, 0);
			se.acceleration.set(0, 0);
			this.mode = 2;
			this.velocity.set(0, 0);
			this.acceleration.set(0, 0);
		}
		if (can_big_damage) {
			R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
			can_big_damage = false;
		} else {
			return;
		}
		R.player.skip_motion_ticks = 4;
		skip_motion_ticks = 8;
	}
	private var skip_motion_ticks:Int = 0;
	private var wall_mode:Int = 0;
	private var wht:Int = 0;
	override public function update(elapsed: Float):Void 
	{

		
		if (!did_init) {
			ACTIVE_SpikeExtends.add(this);
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [chain, wall_collider]);
			HF.remove_list_from_mysprite_layer(this, parent_state, [this]);
			HF.add_list_to_mysprite_layer(this, parent_state, [this]);
		}
		
		for (i in 0...Pew.ACTIVE_Pews.length) {
			var pw:Pew = Pew.ACTIVE_Pews.members[i];
			if (pw != null) {
				pw.generic_overlap(this);
			}
		}
		
		
		
		
		var ot:Int = R.player.wasTouching;
		var touched_y:Bool = false;
		var sepd_x:Bool = false;
		var dec_x:Bool = false;
		var dec_Y:Bool = false;
		var old_y:Float = 0;
		var old_last_y:Float = 0;
		var old_actual_x:Float = R.player.x;
		var old_x:Float = R.player.last.x;
		var old_vel:Float = R.player.velocity.x;
		var old_y_vel:Float = -4000;
		
		if (velocity.x > 0) {
			if (R.player.velocity.x > 0 && R.player.x < x) {
				
			} else {
				R.player.last.x += 3;
				R.player.velocity.x = -2;
			}
		} else if (velocity.x < 0) {
			if (R.player.velocity.x < 0 && R.player.x > x + width - 2) {
			} else {
				R.player.last.x -= 3;
				R.player.velocity.x = 2;
			}	
		}
		
		dec_x = true;
		
		
		if (velocity.y > 0 && dir == 2 && mode == 1 && FlxX.point_inside(R.player.x + R.player.width / 2, R.player.y,this)) {
			if (R.player.in_tm_bg(2, true, true) == false) {
				R.player.last.y = R.player.y = y + height;
			}
		}
		
		if (velocity.y > 0 && dir == 2 && (ot & FlxObject.DOWN != 0 || wall_mode != 0 || R.player.is_in_wall_mode())) {
			old_y_vel = R.player.velocity.y;
			R.player.velocity.y = -20;
			old_y = R.player.y;
			old_last_y = R.player.last.y;
		 	R.player.last.y += 2;
			dec_Y = true;
			if (R.player.is_in_wall_mode() && overlaps(R.player)) {
				if (R.player.facing == FlxObject.LEFT) {
					R.player.do_hor_push(40, false, false, 5); 
				}else {
					R.player.do_hor_push(-40, false, false, 5);
				}
				R.player.do_vert_push(velocity.y);
				old_vel = velocity.y;
			}
		} else {
			if (velocity.y > 0 && dir == 2 && R.player.overlaps(this)) {
				if (R.player.velocity.y >= 0 && R.player.y < y + height && R.player.y > y + height / 2) {
					if (R.player.in_tm_bg(2) == false) {
						R.player.y  = R.player.last.y = y + height;
					}
				}
			}
			
		}
		
		// If moving upwards always collide w player if needed
		if (dir == 0 && mode == 1 && velocity.y < 0 && R.player.velocity.y < 0) {
			if (R.player.overlaps(this)) {
				if (R.player.x < x + width - 2 && R.player.x + R.player.width > x + 2) {
					//old_y_vel = R.player.velocity.y;
					//old_y = R.player.y;
					//old_last_y = R.player.last.y;
					//dec_Y = true;
					R.player.y = y + 2 - R.player.height;
					R.player.last.y = R.player.y - 3;
					R.player.velocity.y = 20;
				}
			}
		}
		if (ID == 0) {
			if (R.player.allowCollisions & FlxObject.DOWN == 0) {
				R.player.allowCollisions |= FlxObject.DOWN;
				ID = 1;
			}
		}
		if (FlxObject.separate(this, R.player)) {
			
			if (dec_Y) {
				R.player.y = old_y;
				R.player.last.y  = old_last_y;
			}
			if (R.player.touching & (FlxObject.LEFT | FlxObject.RIGHT) != 0) {
				sepd_x = true;
				
			}
		
			if (R.player.touching & FlxObject.DOWN != 0 && velocity.y <= 0	) {
				R.player.velocity.y = 15;
				touched_y = true;
			}
			if (R.player.touching & FlxObject.DOWN != 0 && velocity.x != 0) {
				if (0x1111 != parent_state.tm_bg.getTileCollisionFlags(R.player.x+4,R.player.y+R.player.height+2)) {
					R.player.extra_x += FlxG.elapsed * velocity.x;
				}
				//R.player.do_hor_push(Std.int(0.66 * velocity.x), false, false, 3);
				//R.player.do_hor_push(Std.int(velocity.x), false, false, 3);
			}
			
			// crush moving right
			var whyyy:Float = R.player.x;
			R.player.x = old_actual_x;
			if (mode == 1 || mode == 3) {
				if (R.player.touching & FlxObject.LEFT != 0 && velocity.x > 0 ) {
					R.player.x += 6;
					for (se in SpikeExtend.ACTIVE_SpikeExtends) { if (se.velocity.x < 0 && se.overlaps(R.player)) big_damage(se); }
					R.player.x -= 6;
					R.player.x = x + width;
					R.player.x += 4;
					if (mode == 1 && R.player.in_tm_bg(1,true)) {
						big_damage();
					}
					R.player.x -= 4;
				} else if (R.player.touching & FlxObject.RIGHT != 0 && velocity.x < 0 ) {
					R.player.x -= 10;
					for (se in SpikeExtend.ACTIVE_SpikeExtends) { if (se.velocity.x > 0 && se.overlaps(R.player)) big_damage(se); }
					R.player.x += 10;
					R.player.x = x - R.player.width;
					R.player.x -= 4;
					if (mode == 1 && R.player.in_tm_bg(3,true)) {
						big_damage();
					}
					R.player.x += 4;
				} else if (R.player.touching & FlxObject.DOWN != 0 && velocity.y < 0 ) {
					for (se in SpikeExtend.ACTIVE_SpikeExtends) {if (se.velocity.y > 0 && se.overlaps(R.player)) big_damage(se);}
					//R.player.y = y - R.player.height;
					if (mode == 1 && parent_state.tm_bg.getTileCollisionFlags(x+width/2,y-R.player.height-3) != 0 && R.player.in_tm_bg(0,true)) {
						//touched_wall = true;
						y += 3;
						topwallignore = true;
						big_damage();
					}
				} else if (FlxX.point_inside(R.player.x+R.player.width-2,R.player.y-1,this) || FlxX.point_inside(R.player.x+2	,R.player.y-1,this)) {
					for (se in SpikeExtend.ACTIVE_SpikeExtends) { if (se != this && se.velocity.y < 0 && se.overlaps(R.player)) big_damage(se); 
					}
					// Cloud tiles CAN hurt you here
					if (mode == 1 && wall_mode == 0 && R.player.in_tm_bg(2,false,true)) {
						big_damage();
						if (R.player.facing == FlxObject.LEFT) {
							R.player.do_hor_push(175, false, false, 6);
						} else {
							R.player.do_hor_push( -175, false, false, 6);
						}
					}
				} 
			}
			R.player.x = whyyy;
			
		} else {
			if (this.overlaps(R.player) && velocity.y < 0 && R.player.in_tm_bg(0)) {
				if (mode == 1) {
					big_damage();
				}
			// Sometimes you aren't oclliding but are beig pushed downwards, stil hurt u in that case
			} else if (velocity.y > 0 && dir == 2 && mode == 1 && FlxX.point_inside(R.player.x + R.player.width / 2, R.player.y - 2, this)) {
				R.player.y += 2;
				if (R.player.in_tm_bg(2, true, true)) {
					big_damage();
					if (R.player.facing == FlxObject.LEFT) {
						R.player.do_hor_push(175, false, false, 6);
					} else {
						R.player.do_hor_push( -175, false, false, 6);
					}
				}
				R.player.y -= 2;
				
			}
		}
		if (ID == 1) {
			R.player.allowCollisions ^= FlxObject.DOWN;
			ID = 0;
		}
		
		if (dec_Y) {
			R.player.y = old_y;
			R.player.last.y  = old_last_y;
		}
		if (old_y_vel != -4000) {
			R.player.velocity.y = old_y_vel;
		}
		
		// Wall hang logic
		if (wall_mode == 0) {
			if (false == R.player.is_in_wall_mode()) {
				if (sepd_x && (R.input.left || R.input.right) && 0 == parent_state.tm_bg.getTileCollisionFlags(R.player.x+4,R.player.y+R.player.height+1)) {
					if (R.player.touching & FlxObject.RIGHT > 0) {
						wall_mode = 1;
						R.player.activate_wall_hang();
					} else if (R.player.touching & FlxObject.LEFT > 0) {
						wall_mode = 2;
						R.player.activate_wall_hang();
					}
				}
			}
		} else  {
			
			
			if (wall_mode == 1) {
				
				if (R.input.left) {
					wht++;
					R.player.push_off_ctr = 0;
				} else {
					wht = 0;
				}
				if (R.player.wasTouching & FlxObject.DOWN > 0) {
					wall_mode = 0;
					
				} else if (wht == 15 && velocity.x >= 0) {
					wall_mode = 0;
					old_x = R.player.x = R.player.last.x = x - R.player.width - 3;
					old_vel = R.player.velocity.x = -80;
					R.player.wasTouching = 0;
					
					R.player.facing = FlxObject.LEFT;
					R.player.touching = 0;
					wht = 0;
				} else {
					R.player.x = x - R.player.width + 1;
					R.player.activate_wall_hang();
					if (R.input.jpA1) {
						R.player.velocity.x = -80;
						R.player.x--;
						wall_mode = 0;
					}
				}
			} else if (wall_mode == 2) {	
				if (R.input.right) {
					wht++;
					R.player.push_off_ctr = 0;
				} else {
					wht = 0;
				}
				if (R.player.wasTouching & FlxObject.DOWN > 0) {
					wall_mode = 0;
				} else if (wht == 15 && velocity.x <= 0) {
					wall_mode = 0;
					old_x = R.player.x = R.player.last.x = x +width + 3;
					old_vel = R.player.velocity.x = 80;
					R.player.wasTouching = 0;
					R.player.facing = FlxObject.RIGHT;
					R.player.touching = 0;
					wht = 0;
				} else {
					R.player.x = x + width - 1;
					R.player.activate_wall_hang();
					if (R.input.jpA1) {
						R.player.velocity.x = 80;
						R.player.x++;
						wall_mode = 0;
					}
				}
			}
			if (wall_mode == 1 || wall_mode == 2) {
				if (R.player.velocity.x < 0) {
				} else {
					if (R.player.velocity.y > 20) {
						R.player.velocity.y = 20;
					}
				}
			}
			
			if (!R.player.is_wall_hang_points_in_object(this)) {
				wall_mode = 0;
			}
		}
		
		
		if (dec_x) {
			R.player.last.x = old_x;
		}
		R.player.velocity.x = old_vel;
		
		
		// Mode 0: Wait to be triggered
		if (mode == 0) {
			t_wait_at_ends += FlxG.elapsed;
			if (t_wait_at_ends > tm_wait_at_ends) {
				switch (dir) {
					case 0:
						if (R.player.y <= y+ height-4) {
							if (R.player.x < x + width -2 && R.player.x + R.player.width > x + 2) {
								if (FlxX.path_is_clear_vert(x + width / 2, R.player.x + R.player.width / 2, R.player.y, y + height / 2, parent_state.tm_bg, 300)) {
									mode = 1;
								}
							}
						}
					case 1:
						if (R.player.x>= x) {
							if (R.player.y < y + height - 6 && R.player.y + R.player.height > y + 6) {
								if (FlxX.path_is_clear_hor(x+width/2,R.player.x+R.player.width-1,y+height/2,R.player.y+R.player.height/2,parent_state.tm_bg,300)) {
									mode = 1;
								}
							}
							
						}
					case 2:
						if (R.player.y > y) {
							if (R.player.x < x + width - 2 && R.player.x + R.player.width > x + 2) {
								if (FlxX.path_is_clear_vert(x + width / 2, R.player.x + R.player.width / 2, R.player.y, y + height / 2, parent_state.tm_bg, 300)) {
									mode = 1;
								}
							}
						}
					case 3:
						if (R.player.x <= x + width) {
							if (R.player.y < y + height - 6 && R.player.y + R.player.height > y + 6) {
								if (FlxX.path_is_clear_hor(x+width/2,R.player.x+R.player.width,y+height/2,R.player.y+R.player.height/2,parent_state.tm_bg,300)) {
									mode = 1;
								}
							}
						}
				}
			} else {
				
			}
			if (mode == 1) {
				t_wait_at_ends = 0;
				R.sound_manager.play(SNDC.se_extend,1,true,this);
				can_big_damage = true;
				animation.play("move");
			}
/* ************************************** */			
		} else if (mode == 1) { // Mode 1: Now it's moving
			switch (dir) {
				case 0:
					acceleration.y = -accel_extend;
				case 1:
					acceleration.x = accel_extend;
				case 2:
					acceleration.y = accel_extend;
				case 3:
					acceleration.x = -accel_extend;
			}
			
			for (i in 0...RaiseWall.ACTIVE_RaiseWalls.length) {
				var rw:RaiseWall = RaiseWall.ACTIVE_RaiseWalls.members[i];
				if (rw == null) continue;
				if (FlxX.l1_norm_from_mid(rw, wall_collider) < 57) { // 16 + 8 + 16 + 16
					if (FlxObject.separate(rw, wall_collider)) {
						mode = 2;
						break;
					}
				}
			}
			for (se in SpikeExtend.ACTIVE_SpikeExtends) {
				if (se != this) {
					if (se.overlaps(this)) {
						if (R.player.overlaps(se) && R.player.overlaps(this)) {
							big_damage();
						}
						mode = 2;
					}
				}
			}
			for (vb in VanishBlock.ACTIVE_VanishBlocks) {
				if (vb == null) continue;
				if  (FlxX.l1_norm_from_mid(vb, wall_collider) < 48) { // 16 + 16 + 8 + 8
					if (vb.props.get("s_open") == 0) {
						if (FlxObject.separate(vb, wall_collider)) {
							mode = 2;
							break;
						}
					}
				}
			}
			
			if (touched_wall) {
				if (topwallignore) {
					topwallignore = false;
				} else {
					HF.round_to_16(this, true);
					HF.round_to_16(this,false);
				}
				mode = 2;
			}
			
			//FlxObject.separate(R.player, this);
			if (mode == 2) {
				R.sound_manager.play(SNDC.se_hit,1,true,this);
				
				velocity.set(0, 0);
				acceleration.set(0, 0);
				animation.play("hit");
			}
		} else if (mode == 2) {
			t_wait_at_ends += FlxG.elapsed;
			if (t_wait_at_ends > tm_wait_at_ends) {
				t_wait_at_ends = 0;
				mode = 3;
				R.sound_manager.play(SNDC.se_retract,1,true,this);
				animation.play("retract");
			}
			// Mode 3: retract
		} else if (mode == 3) {
			switch (dir) {
				case 0:
					velocity.y = vel_retract;
					if (y + FlxG.elapsed*velocity.y >= iy) {
						y = iy;
						mode = 0;
					}		
				case 1:
					velocity.x = -vel_retract;
					if (x + FlxG.elapsed*velocity.x<= ix) {
						x = ix;
						mode = 0;
					}
				case 2:
					velocity.y = -vel_retract;
					if (y + FlxG.elapsed*velocity.y<= iy) {
						y = iy;
						mode = 0;
					}
				case 3:
					velocity.x = vel_retract;
					if (x + FlxG.elapsed*velocity.x>= ix) {
						x = ix;
						mode = 0;
					}
			}
			
			if (this.overlaps(R.player) && wall_mode == 0) {
				if (velocity.y > 0) {
					velocity.y = 10;
				}
			}
			if (mode == 0) {
				velocity.set(0, 0);
			}
		}
		
		super.update(elapsed);
	}
	
	override public function postUpdate(elapsed):Void 
	{
		if (skip_motion_ticks > 0) {
			skip_motion_ticks--;
			if (skip_motion_ticks == 0) {	
				if (dmgtype == 0) {
					R.player.add_dark(dmg);
					FlxG.cameras.shake(0.01, 0.05,null,true,FlxAxes.Y);
				} else {
					R.player.add_light(dmg);
					FlxG.cameras.shake(0.01, 0.05, null, true, FlxAxes.Y);
				}	
			}
			
			return;
		}
		wall_collider.acceleration.set(acceleration.x, acceleration.y);
		wall_collider.velocity.set(velocity.x, velocity.y);
		super.postUpdate(elapsed);
		wall_collider.x = x;
		wall_collider.y = y;
	}
	
	override public function draw():Void 
	{
		
		chain.animation.play("chain");
		
		var dx:Float = Math.abs(ix - x);
		var dy:Float = Math.abs(iy - y);
		
		var d:Float = HF.get_midpoint_distance(this, chain);
		var nrToDraw:Int = Std.int((d) / 16);
		HF.scale_velocity(chain.velocity, chain, this, 16);
		chain.move(x, y);
		for (i in 0...nrToDraw) {
			chain.x -= chain.velocity.x;
			chain.y -= chain.velocity.y;
			chain.draw();
		}
		chain.velocity.set(0, 0);
		
		chain.animation.play("base");
		
		chain.x = ix;
		chain.y = iy;
		chain.draw();
		super.draw();
	}
	
	public function generic_circle_overlap(cx:Float, cy:Float, cr:Float, _dmgtype:Int):Bool {
		if (FlxX.circle_flx_obj_overlap(cx, cy, cr, this)) {
			if (dmgtype == _dmgtype) {
				return true;
			}
		}
		return false;
	}
	
	public function generic_overlap(o:FlxObject, only_dmgtype:Int = -1):Bool {
		// only break lego when doing the hurt anim
		if (this.animation.curAnim == null || "hit" != this.animation.curAnim.name) {
			return false;
		}
		
		if (this.dmgtype != only_dmgtype && only_dmgtype != -1) { //1 only light breaks
			return false;
		} 
		
		if (this.overlaps(o)) {
			return true;
		}
		
		return false;
	}
	
	
	
}