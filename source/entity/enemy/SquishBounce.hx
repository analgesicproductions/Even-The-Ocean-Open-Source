package entity.enemy;
/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import autom.SNDC;
import entity.MySprite;
import entity.npc.GenericNPC;
import entity.util.VanishBlock;
import flixel.FlxG;
import flixel.FlxObject;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import openfl.geom.Point;
import state.MyState;

	class SquishBounce extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "SquishBounce");
	}
	
	
	override public function recv_message(message_type:String):Int 
	{
		
		if (message_type == C.MSGTYPE_ENERGIZE_TICK_DARK) {
			if (jumpctr == 5) {
				broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
			}
			jumpctr = 0;
		}
		return 1;
		
	}
	
	
	
	override public function change_visuals():Void 
	{
		
		if (props.get("GNPC_ID") != "") {
			GenericNPC.load_visuals(this, props.get("GNPC_ID").toLowerCase());
		} else {
			if (moves_horizontally) {
				switch (vistype) {
					case 0:
						AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, name+"Mover");
					case 1:
						AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, name+"Mover");
					default:
						AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, Std.string(vistype));
				}
				
				animation.play("idle");
				
			} else {
			switch (vistype) {
				case 0:
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, name);
				case 1:
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, name);
				default:
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, Std.string(vistype));
			}
			
			
			if (R.TEST_STATE.MAP_NAME == "WOODS_2") {
				animation.play("fakeidle");
			} else {
				animation.play("idle");
			}
			}
		}
		
	}
	
	private var max_mul:Float = 0;
	private var x_slow:Float = 1;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("max_jump_multiplier", 1.4);
		p.set("initintovel", 53); // to 80
		p.set("outaccel", -280);
		p.set("is_cloud", 1);
		p.set("x_slow", -1);
		p.set("GNPC_ID", "");
		p.set("f_speed",0);
		p.set("decel-frames", "120,20,30");
		p.set("hitbox_w", 32);
		p.set("no_bounce", 0);
		p.set("children", "");
		//p.set("tile_speed", 20); // Nr of frames to move 16 px
		return p;
	}
	
	private var jumpctr:Int = 0;
	private var t_jumpctr:Int = 0;
	/** Variables Needed for smoothed turn arounds */
	private var found_hard:Bool = false;
	private var found_gap:Bool = false;
	private var ease_decel:Float = 0;
	private var ease_frames_max:Int = 0;
	private var ease_frames:Int = 0;
	private var ease_out_frames_max:Int = 0;
	private var ease_out_frames:Int = 0;
	private var dir:Int = 0;
	//private var frames_left_to_round_max:Int = 0;
	//private var frames_left_to_round:Int = 0;
	private var computed_max_vel:Float = 0;
	private var moving_mode:Int = 0;
	private var moves_horizontally:Bool = false;
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		if (props.exists("t_wait")) props.remove("t_wait");
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		max_mul = props.get("max_jump_multiplier");
		init_into_vel = props.get("initintovel");
		out_accel = props.get("outaccel");
		x_slow = props.get("x_slow");
		if (props.get("is_cloud") == 1) {
			allowCollisions = FlxObject.UP;
		} else {
			allowCollisions = FlxObject.ANY ^ FlxObject.DOWN;
		}
		
		moves_horizontally = props.get("f_speed") > 0;
		
		if (moves_horizontally) {
			dir = 0;
			// Smoothing turn things
			if (props.get("f_speed") == 8 && props.get("decel-frames") == "120,20,30") {
				props.set("decel-frames", "400,25,20");
			}
			computed_max_vel = 960.0 / props.get("f_speed"); 
			velocity.x = computed_max_vel;
		}
		
		moving_mode = 0;
		ease_frames = 0;
		ease_out_frames = 0;
		ease_frames_max = Std.parseInt(props.get("decel-frames").split(",")[1]);
		ease_decel = Std.parseFloat(props.get("decel-frames").split(",")[0]);
		ease_out_frames_max = Std.parseInt(props.get("decel-frames").split(",")[2]);
		noubounce = props.get("no_bounce") == 1;
		
		change_visuals();
		
		//offset.x = (width - props.get("hitbox_w")) / 2;
		//width = props.get("hitbox_w"); 
		
		immovable = true;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	private var noubounce:Bool = false;
	private var mode:Int = 0;
	private var maxheight:Float = 0;
	private var init_into_vel:Float = 250;
	private var out_accel:Float = -200;
	private var jumpedonce:Bool = false;
	private var wallmode:Int = 0;
	private var didntfallfastenough:Bool = false;
	private var actual_entrance_vel:Float = 0;
	private var no_bounce_till_jump:Bool = false;
	private var last_p_vel_y:Float = 0;
	override public function update(elapsed: Float):Void 
	{
		var slow_player:Bool = false;
		immovable = true;
		if (!did_init) {
			did_init = true;
			
			populate_parent_child_from_props();
		}
		if (mode != 0) {
			
			if (R.input.jpA1 && cur_layer == MyState.ENT_LAYER_IDX_FG2) {
				R.player.velocity.y = last_p_vel_y;
				R.player.y = R.player.last.y + FlxG.elapsed * R.player.velocity.y;
				//Log.trace(last_p_vel_y);
			}
			
			slow_player = FlxObject.separate(this, R.player);
			if (R.input.jpA1) {
				//Log.trace(slow_player);
			}
		}
		
		//if (t_jumpctr < 120) {
			//t_jumpctr++;
			//if (t_jumpctr == 120) {
				//jumpctr = 0;
			//}
		//}
		
		if (R.player.x > x + width + 64) {
			jumpctr = 0;
		}
		
		if (mode == 0) {
			var colliding:Bool = false;
			var old_v:Float = R.player.velocity.y;
			
			// Check if we need to start bobbing downwards. Only if not wall jumping
			if (wallmode == 0) {
				if (!no_bounce_till_jump) {
					if (cur_layer == MyState.ENT_LAYER_IDX_FG2) {
						//R.player.velocity.y = last_p_vel_y;
					}
				}
				
				if (moves_horizontally == false && !noubounce) {
					if (R.player.overlaps(this)) {
						
						
						
						//R.player.skip_motion_ticks = 2;
						//R.player.do_vert_push( R.player.get_base_jump_vel() * props.get("max_jump_multiplier"),false,true);
						var lp_:Float = R.player.energy_bar.get_LIGHT_percentage();
						if (lp_ >= 0.6) {
							lp_ = 1 + 0.75*(lp_ - 0.6);
						} else {
							lp_ = 1;
							
						}
						
							if (R.TEST_STATE.MAP_NAME == "WOODS_2") {
								if (R.player.velocity.y > R.player.get_base_jump_vel() * 1) {
									R.sound_manager.play(SNDC.squishbounce);
								}
								R.player.do_vert_push( -200 * lp_ * props.get("max_jump_multiplier"), false, true);
							} else {
								if (animation.curAnim == null || animation.curAnim.finished) {
									
									if (R.player.velocity.y > R.player.get_base_jump_vel() * 1) {
										R.sound_manager.play(SNDC.squishbounce);
										//if (jumpctr < 5) {
											jumpctr++;
											//t_jumpctr = 0;
										//}
									}
									
									R.player.do_vert_push( -200 * lp_ * props.get("max_jump_multiplier"), false, true);
									R.player.skip_motion_ticks = 5;
								}
							}	
						
						if (R.TEST_STATE.MAP_NAME == "WOODS_2") {
							//animation.play("fakeidle");
						} else {
							animation.play("grow");
						}
					}
					super.update(elapsed);
					return;
				}
				
				colliding = FlxObject.separate(this, R.player);
				if (R.player.velocity.y < 0) colliding = false;
				if (colliding && R.player.touching & FlxObject.DOWN != 0) {
					//Log.trace(no_bounce_till_jump);
					if (R.player.velocity.y > 0) {
						R.player.y = y - R.player.height;
						//R.player.last.y = R.player.y;
						R.player.velocity.y = 0;
					}
				}
				if (!no_bounce_till_jump  && colliding && R.player.touching & FlxObject.DOWN != 0 && old_v > 40) {
					//Log.trace(22);
					slow_player = true;
					mode = 1; 
					if (moves_horizontally) old_v = 2;
					if (old_v > 140) { // Fast enough to not need to slow player
						jumpedonce = false;
						// old_v from 140 to max 500 - fall faster = move down more
						var init_scale:Float = 1 - (Math.max(0, 500 - old_v) / (500 - 140));
						velocity.y = init_into_vel * (1 + init_scale * 0.6); // scael to 1.6
						actual_entrance_vel = velocity.y;
						if (!moves_horizontally) {
							animation.play("move");
						}
					} else if (old_v > 0) {
						didntfallfastenough = true;
						velocity.y = init_into_vel * 0.8;
						actual_entrance_vel = velocity.y;
					}
					
					if (props.get("no_bounce") == 1) {
						velocity.y = init_into_vel * 0.85;
						actual_entrance_vel = velocity.y;
						didntfallfastenough = true;
					}
					
					acceleration.y = out_accel;
				} else {
					
					
					if (!colliding) R.player.velocity.y = old_v;
				}
				
				if (no_bounce_till_jump) {
					if (R.input.jpA1) {
						no_bounce_till_jump = false;
					}
				}
				
				
				if (R.player.y + R.player.height - 2 * FlxG.elapsed * R.player.velocity.y > y) { 
					slow_player = false;
					//Log.trace("hi");
				}
				if (R.player.velocity.y < 0) {
					//Log.trace("hi2");
					slow_player = false;
				}
				
				// Check for wall jumping
				if (allowCollisions == FlxObject.ANY ^ FlxObject.DOWN) {
					if (wallmode == 0) { 
						
						var alloww_r:Bool = false;
						var alloww_l:Bool = false;
						if (R.player.is_in_wall_mode()) {
							if (R.player.facing == FlxObject.LEFT) {
								R.player.x -= 1;
								if (R.player.overlaps(this)) alloww_l = true;
								R.player.x += 1;
							} else {
								R.player.x += 1;
								if (R.player.overlaps(this)) alloww_r = true;
								R.player.x -= 1;
							}
						}
						
						FlxObject.separateX(this, R.player);
						if ((colliding && R.player.touching & FlxObject.RIGHT > 0) || alloww_r) {
							R.player.activate_wall_hang();
							wallmode = 1;
						}
						if ((colliding && R.player.touching & FlxObject.LEFT > 0) || alloww_l) {
							R.player.activate_wall_hang();
							wallmode = 2;
						}
					}
				}
				
			} else {
				
				if (wallmode == 1 && R.input.right) {
					R.player.x = x - R.player.width;
					R.player.activate_wall_hang();
				} else if (wallmode == 2 && R.input.left) {	
					R.player.x = x + width;
					R.player.activate_wall_hang();
				}

				if (wallmode == 1 || wallmode == 2) {
					if (wallmode == 1) {
						R.player.x += 1;
					} else {
						R.player.x -= 1;
					}
					if (!R.player.is_wall_hang_points_in_object(this)) {
						wallmode = 0;
					}
					if (wallmode == 1) {
						R.player.x -= 1;
					} else {
						R.player.x += 1;
					}
				}
			}
			
		} else if (mode == 1) {
			
			if (velocity.y <= 0 && y < iy) {
				y = iy;
				velocity.y = 0;
				mode = 0;	
				acceleration.y = 0;
				if (didntfallfastenough) {
					if (moves_horizontally) jumpedonce = false;
					if (jumpedonce == false) {
						no_bounce_till_jump = true;
						if (moves_horizontally && !slow_player) {
							no_bounce_till_jump = false;
						} else {
							
							
							if (R.player.x < x+width && R.player.x+R.player.width > x){
								R.player.velocity.y = 0;
								R.player.y = y - R.player.height;
							}
						}
					} else {
						//no_bounce_till_jump = false;
						
						// if u jump on and the SB goes slow,
						// then if u jump, be able to bounce again later

						// only keep the player level with the SquishBounce if 
						// the player overlaps in the X
						if (R.player.touching != FlxObject.NONE) {
							if (R.player.x < x+width && R.player.x+R.player.width > x){
								R.player.velocity.y = 0;
								R.player.y = y - R.player.height;
							}
						}
						//Log.trace("hi");
					}
				}
				if (jumpedonce == false && !didntfallfastenough && slow_player) {
					if (props.get("no_bounce") == 0) R.player.do_vert_push(0.9*R.player.get_base_jump_vel());
				}
				didntfallfastenough = false;
			}
			if (R.input.jpA1 && slow_player) {
				
				if (no_bounce_till_jump) {
					if (R.input.jpA1) {
						no_bounce_till_jump = false;
					}
				}
				
				//Log.trace(1);
				if (didntfallfastenough) {
				//Log.trace(2);
					if (props.get("no_bounce") == 0) R.player.do_vert_push(R.player.get_base_jump_vel());
					jumpedonce = true;
				} else {
				//Log.trace(3);
					var c:Float = 1;
					c =	Math.abs(velocity.y) / actual_entrance_vel; // range 0 to 1: 0 = max height for player
					//var bonus:Float = (actual_entrance_vel - init_into_vel) / (1.6 * init_into_vel - init_into_vel);
					//bonus /= 2;
					if (velocity.y > -85 && !jumpedonce) { // only alow bonus on first jump
						//var d:Float = max_mul * (1 -c);
						//if (velocity.y < 0) d = max_mul;
						//if (d < 0.6) d = 0.6;
						//d += 0.4;
						//if (d > max_mul) d = max_mul;
						//d += bonus;
						if (props.get("no_bounce") == 0) R.player.do_vert_push(R.player.get_base_jump_vel() *1.5 );
						//Log.trace([velocity.y, R.player.get_base_jump_vel() * d]);
					} else {
						if (props.get("no_bounce") == 0) R.player.do_vert_push(R.player.get_base_jump_vel());
					}
					jumpedonce = true;
				}
			}
			
			
			if (cur_layer == MyState.ENT_LAYER_IDX_FG2) {
				last_p_vel_y = R.player.velocity.y;
			}
			
			if (!slow_player) {
				if (velocity.y > 0) velocity.y = 0;
			}
		}
		
		if (slow_player) {
			if (!R.input.jpA1) {
				R.player.y = (y - R.player.height) + 1;
				if (mode != 0) R.player.velocity.y = 20;
			}
			if (x_slow != -1) {
				if (R.input.left) {
					R.player.velocity.x = -x_slow;
				} else if (R.input.right) {
					R.player.velocity.x = x_slow;
				}
			}
		}
		
		if (moves_horizontally) {
			update_smooth_turnaround();
			if (touching == FlxObject.UP && !R.input.left && !R.input.right && R.player.push_xvel == 0) {
				R.player.extra_x += velocity.x * FlxG.elapsed;
				if (VanishBlock.playerinone) {
					R.player.extra_x = 0;
					VanishBlock.playerinone = false;
				}
				if (!stored_x) {
					stored_x = true;
					//stored_x_offset = R.player.x - x;
					
					if (R.player.wasTouching & (FlxObject.LEFT | FlxObject.RIGHT) == 0) {
						//R.player.x = x + stored_x_offset;
					} else {
							R.player.extra_x = 0;
					}
					
				} else {
					if (R.player.wasTouching & (FlxObject.LEFT | FlxObject.RIGHT) == 0) {
						//R.player.x = x + stored_x_offset;
					} else {
						
						R.player.extra_x = 0;
					}
				}
			} else {
				stored_x = false;
				stored_x_offset = 0;
			}
		}
		super.update(elapsed);
	}
	private var stored_x:Bool = false;
	private var stored_x_offset:Float = 0;
	function update_smooth_turnaround():Void 
	{
		if (moving_mode == 0) {
			if (velocity.x != 0 || velocity.y != 0) {
				found_hard = found_gap = false;
				if (HF.there_is_a_hard_tile(true,dir,this,parent_state.tm_bg)) found_hard = true;
				//if (HF.there_is_a_gap(true,dir,this,parent_state.tm_bg)) found_gap = true;
				if (found_gap || found_hard) {
					HF.round_to_16(this,true);
					moving_mode = 1;
					if (velocity.x > 0) {
						facing = FlxObject.RIGHT;
					} else if (velocity.x < 0) {
						facing = FlxObject.LEFT;
					} 
				}
			}
		} else if (moving_mode == 1) {
			ease_frames++;
			if (facing == FlxObject.RIGHT) {
				velocity.x -= ease_decel * FlxG.elapsed;
				if (velocity.x < 0) velocity.x = 0;
				if (parent_state.tm_bg.getTileCollisionFlags(x + width + FlxG.elapsed * velocity.x, y + height / 2) != 0) {
					velocity.x = 0;
				}
			} else if (facing == FlxObject.LEFT) {
				velocity.x += ease_decel * FlxG.elapsed;
				if (velocity.x > 0) velocity.x = 0;
				if (parent_state.tm_bg.getTileCollisionFlags(x + FlxG.elapsed * velocity.x, y + height / 2) != 0) {
					velocity.x = 0;
				}
			} 
			if (ease_frames == ease_frames_max) {
				if (facing == FlxObject.LEFT) velocity.x = 1;
				if (facing == FlxObject.RIGHT) velocity.x = -1;
				ease_frames = 0;
				moving_mode = 2;
			}
		} else if (moving_mode == 2) {
			// Moving away from the wall, if you move too far before the number of 
			// allotted frames are over, then round to the nearest tileand go into normal moving
			if ((found_hard && !HF.there_is_a_hard_tile(false,dir,this,parent_state.tm_bg)) || (found_gap && !HF.there_is_a_gap(false,dir,this,parent_state.tm_bg))) {
				HF.round_to_16(this,true);
				velocity.x = (velocity.x < 0 ? -1 : 1) * computed_max_vel;
				ease_out_frames = 0;
				moving_mode = 0;
			} else {
				// Otherwise if you reach the max ease frames, floor to 16 and move normally
				if (velocity.x < 0) {
					velocity.x -= ease_decel * FlxG.elapsed;
				} else if (velocity.x > 0) {
					velocity.x += ease_decel * FlxG.elapsed;
				}
				if (velocity.x < -computed_max_vel) velocity.x = -computed_max_vel;
				if (velocity.x > computed_max_vel) velocity.x = computed_max_vel;
				
				ease_out_frames++;
				if (ease_out_frames == ease_out_frames_max) {
					ease_out_frames = 0;
					moving_mode = 0;
					if (velocity.x < 0) {
						velocity.x = -computed_max_vel;
						x = Std.int(x) - (Std.int(x) % 16);
					}
					if (velocity.x > 0) {
						velocity.x = computed_max_vel;
						x = Std.int(x) + (16 - (Std.int(x) % 16));
					}
				}
			}
		}
	}
	
	
}




