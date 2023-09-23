package entity.enemy;

import autom.SNDC;
import entity.MySprite;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import openfl.geom.Point;
import state.MyState;

class WalkPod extends MySprite
{

	public static var ACTIVE_WalkPods:List<WalkPod>;
	public var hitbox:FlxSprite;
	private var climbs_corners:Bool = false;
	private var dmg:Int;
	private var tm_dead:Float = 0;
	private var mode:Int;
	private var vel:Float = 0;
	private var t_dead:Float = 0;
	// Used by corner climbing logic to determine what animation to play
	private var current_anim_suffix:String = "";
	private var dir_prefix:String = "";
	private var pre_collide_vel:Point;
	private var feet:FlxSprite;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		pre_collide_vel = new Point();
		hitbox = new FlxSprite();
		hitbox.makeGraphic(10, 10, 0x70ff0000);
		hitbox.visible = false;
		ID = 0;
		feet = new FlxSprite();
		super(_x, _y, _parent, "WalkPod");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", "0");
				AnimImporter.loadGraphic_from_data_with_id(feet, 16, 32, "WalkPod", "feet_l");
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", "1");
				AnimImporter.loadGraphic_from_data_with_id(feet, 16, 32, "WalkPod", "feet_d");
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "WalkPod", vistype);
				AnimImporter.loadGraphic_from_data_with_id(feet, 16, 32, "WalkPod", "feet_l");
		}
		
		feet.height = 16;
		feet.offset.y = 16;
		set_dir_prefix();
		animation.play("full", true,false,-1);
		current_anim_suffix = "full";
		feet.animation.play("walk");
	}
	
	/** Variables Needed for smoothed turn arounds */
	private var found_hard:Bool = false;
	private var found_gap:Bool = false;
	private var ease_decel:Float = 0;
	private var ease_frames_max:Int = 0;
	private var ease_frames:Int = 0;
	private var ease_out_frames_max:Int = 0;
	private var ease_out_frames:Int = 0;
	private var frames_left_to_round_max:Int = 0;
	private var frames_left_to_round:Int = 0;
	private var computed_max_vel:Float = 0;
	private var moving_mode:Int = 0;
	private var dir:Int = 0;
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("dir", 0);
		p.set("starts_moving_left_or_down", 0);
		p.set("climbs_corners", 0);
		p.set("dmg", 24);
		p.set("tm_dead", 1.0);
		p.set("AUTO_ORIENT", 1);
		//p.set("vel",64);
		p.set("f_speed",16);
		p.set("decel-frames", "120,20,30");
		p.set("FISH_RADIUS", 0);
		return p;
	}
	
	private var is_fish:Bool = false;
	private var fish_radius:Float= 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		
		if (props.exists("vel")) props.remove("vel");
		
		if (props.get("f_speed") == 8 && props.get("decel-frames") == "120,20,30") {
			props.set("decel-frames", "400,25,20");
		}
		
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		tm_dead = props.get("tm_dead");
		dir = props.get("dir");
		dmg = props.get("dmg");
		//vel = props.get("vel");
		frames_left_to_round_max = props.get("f_speed");
		frames_left_to_round = 0;
		computed_max_vel = 960.0 / props.get("f_speed"); // Change later for frame stuff
		vel = computed_max_vel;
		
		climbs_corners = 1 == props.get("climbs_corners");
		
		if (Std.is(props.get("decel-frames"), String) == false) {
			props.set("decel-frames", "120,20,30");
		} else if (props.get("decel-frames").indexOf(",") == -1) {
			props.set("decel-frames", "120,20,30");
		}	
		moving_mode = 0;
		ease_frames = 0;
		ease_out_frames = 0;
		ease_frames_max = Std.parseInt(props.get("decel-frames").split(",")[1]);
		ease_decel = Std.parseFloat(props.get("decel-frames").split(",")[0]);
		ease_out_frames_max = Std.parseInt(props.get("decel-frames").split(",")[2]);
		
		mode = 0;
		t_dead = 0;
		velocity.set(0, 0);
		
		is_fish = props.get("FISH_RADIUS") > 0;
		fish_radius = 16 * props.get("FISH_RADIUS");
		
		change_visuals();
		
		set_initial_velocity();
		hitbox.move(x, y);
	}
	
	private var fish_angle:Int = 0;
	override public function draw():Void 
	{
		if (is_fish) {
			fish_angle += 2;
			var oy:Float = y;
			if (fish_angle > 360) {
				fish_angle = 0;
			}
			y += 3 * FlxX.sin_table[fish_angle];
			
			super.draw();
			y = oy;
		} else {
			
			var pref:String = "";
			if (dir == 0 && velocity.x < 0) pref = "reverse";
			if (dir == 2 && velocity.x > 0) pref = "reverse";
			if (dir == 1 && velocity.y < 0) pref = "reverse";
			if (dir == 3 && velocity.y > 0) pref = "reverse";
			feet.animation.play(pref + "walk");
			switch (dir) {
				case 3: feet.move(x + 8, y+8); feet.angle = 270;
				case 0: feet.move(x, y + 16); feet.angle = 0;
				case 1: feet.move(x - 8, y+8); feet.angle = 90;
				case 2: feet.move(x, y); feet.angle = 180;
			} 
			
			super.draw();
			//switch (dir) {
				//case 3: feet.move(x + 8, y+8); feet.angle = 270;
				//case 0: feet.move(x, y + 16); feet.angle = 0;
				//case 1: feet.move(x - 8, y+8); feet.angle = 90;
				//case 2: feet.move(x, y); feet.angle = 180;
			//} 
		}
	}
	

	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [hitbox,feet]);
			ACTIVE_WalkPods.add(this);
		}
		
		
		ID++;
		if (ID> 30) {
			ID= Std.int( -10 + 10 * Math.random());
			R.sound_manager.set_pan_for_next_play(-1 + 2*((x - FlxG.camera.scroll.x) / (416)));
			R.sound_manager.play(SNDC.walkblock, 0.5 + 0.5 * Math.random(), true, this);
		}
		
		if (R.editor.editor_active) {
			if (FlxG.keys.justPressed.SPACE) {
				moving_off = !moving_off;
			}
			if (moving_off) return;
		}
		
		update_damage_animation();
		
		if (climbs_corners) {
			if (did_slopes != 0) {
				if (velocity.x != 0) {
					velocity.x *= -1;
				}
				if (velocity.y != 0) {
					velocity.y *= -1;
				}
				x = last.x = pre_collide_x;
				y = last.y = pre_collide_y;
				did_slopes = 0;
				touching = 0;
			}
			update_climb_corner();
		} else {
			update_smooth_turnaround();
		}
		
		super.update(elapsed);
	}
	
	private function update_climb_corner():Void {
		var old_dir:Int = dir;
		// Interior climbing
		if (dir == 0) { // Touching floor
			if (touching == FlxObject.LEFT) {
				dir = 1;
				velocity.set(0, velocity.x);
			} else if (touching == FlxObject.RIGHT) {
				dir = 3;
				velocity.set(0, -velocity.x);
			}
			
		} else if (dir == 1) {
			if (touching == FlxObject.UP) {
				dir = 2;
				velocity.set( -velocity.y, 0);
			} else if (touching == FlxObject.DOWN) {
				dir = 0;
				velocity.set(velocity.y, 0);
			}
		} else if (dir == 2) {
			if (touching == FlxObject.RIGHT) {
				dir = 3;
				velocity.set(0, velocity.x);
			} else if (touching == FlxObject.LEFT) {
				dir = 1;
				velocity.set(0, -velocity.x);
			}
		} else if (dir == 3) {
			if (touching == FlxObject.DOWN) {
				dir = 0;
				velocity.set( -velocity.y, 0);
			} else if (touching == FlxObject.UP) {
				dir = 2;
				velocity.set(velocity.y, 0);
			}
		}
		
		
		
		// Logic for climbing around exteriors of shapes.
		// Don't do it if we switched dir already
		if (dir == old_dir) {
			
			// If walking off of a ledge, checks two frame past the bottom right of the graphic. 
			// If it will be off of the edge, snap the x position to the grid and change to moving down
			
			// Also need to check that other end is not on the the tilemap (2nd tilemap query per conditional) because of afer turning corners
			/* TODO Handle cloud tiles */ 
			var tm:FlxTilemapExt = parent_state.tm_bg;
			if (dir == 0 || dir == 2) {
				var y_check:Float = dir == 0 ? y + height + 1.5 : y - 1;
				if (velocity.x < 0) {
					if (tm.getTileCollisionFlags(x + width + 2*FlxG.elapsed * velocity.x, y_check) == 0 && tm.getTileCollisionFlags(x,y_check) == 0) {
						dir = 3;
					}
				} else if (velocity.x > 0) {
					if (tm.getTileCollisionFlags(x + 2 * FlxG.elapsed * velocity.x, y_check) == 0 && tm.getTileCollisionFlags(x + width, y_check) == 0) {
						x += 2 * FlxG.elapsed * velocity.x; // Hack
						dir = 1;
					}
				}
			} else if (dir == 1 || dir == 3) {
				var x_check:Float = dir == 1 ? x - 1 : x + width + 1;
				if (velocity.y < 0) {
					if (tm.getTileCollisionFlags(x_check, y + height + 2 * FlxG.elapsed * velocity.y) == 0 && tm.getTileCollisionFlags(x_check, y) == 0) {	
						dir = 0;
					}
				} else if (velocity.y > 0) {
					if (tm.getTileCollisionFlags(x_check, y + 2 * FlxG.elapsed * velocity.y) == 0 && tm.getTileCollisionFlags(x_check, y + height) == 0) {
						y += 2 * FlxG.elapsed * velocity.y;
						dir = 2;
					}
				}
			}
			
			// Snap X or Y, set new velocity
			// Original attachment direction always determines new velocity
			if (dir != old_dir) {
				
				if (old_dir == 0 || old_dir == 2) { // Need to snap x. X is in the correct position already to be snapped.
					x = Std.int(x) - (Std.int(x) % 16);
					HF.round_to_16(this, false);
				} else {
					y = Std.int(y) - (Std.int(y) % 16);
					HF.round_to_16(this, true);
				}
				
				// Adding elapsed*vel to the directions makes sure that after turning the corner, 
				// the pod is read as being on a tile (vs actually being snapped to a grid, so not 'standing' on anything)
				// last.x = x etc is so that we don't get a false collision with the tilemap
				if (old_dir == 0) {
					velocity.set(0, vel);
					y = last.y + FlxG.elapsed * vel;
					frames_left_to_round = 1;
				} else if (old_dir == 1) {
					velocity.set( -vel, 0);
					x = last.x - 3 * FlxG.elapsed * vel;
					last.y = y; last.x = x;
					frames_left_to_round = 3;
				} else if (old_dir == 2) {
					velocity.set(0, -vel);
					y = last.y - FlxG.elapsed * vel;
					frames_left_to_round = 1;
				} else if (old_dir == 3) {
					velocity.set(vel, 0);
					x = last.x + 3 * FlxG.elapsed * vel;
					last.x = x;
					last.y = y;
					frames_left_to_round = 3;
				}
			}
		} else {
			// Round x and y to 16 b/c we climbed a corner
			HF.round_to_16(this,true);
			HF.round_to_16(this,false);
		}
		
		
		if (old_dir != dir) {
			set_dir_prefix(true);
		}
	}
	
	private var moving_off:Bool = true;
	override public function postUpdate(elapsed):Void 
	{
		if (R.editor.editor_active) {
			if (moving_off == false) {
				super.postUpdate(elapsed);
			} else {
				return;
			}
		} else {
			super.postUpdate(elapsed);
		}
		
		// When WALKING NORMALLY, every so many framess nap to grid so THINGS SYNC
		if (climbs_corners == false && (dir == 2 || dir == 0) && !is_fish) {
			if (moving_mode == 0) {
				frames_left_to_round ++;
				if (frames_left_to_round_max == frames_left_to_round) {
					frames_left_to_round = 0;
					HF.round_to_16(this, true);
					HF.round_to_16(this, false);
				}
			} else {
				frames_left_to_round = 0;
			}
		} else if (climbs_corners) {
			frames_left_to_round ++;
			if (frames_left_to_round_max == frames_left_to_round) {
				frames_left_to_round = 0;
				HF.round_to_16(this, true);
				HF.round_to_16(this, false);
			}
		}
		
		switch (dir) { // URDL
			case 0:
				hitbox.move(x + 3, y + 6);
			case 1:
				hitbox.move(x,y+3);
			case 2:
				hitbox.move(x+3,y+4);
			case 3:
				hitbox.move(x+6,y+3);
		}
	}
	
	
	override public function recv_message(message_type:String):Int 
	{
		//Log.trace(message_type);
		if (message_type == C.MSGTYPE_MOVED_BY_EDITOR) {
			if (props.get("AUTO_ORIENT") == 1) {
				if (parent_state.tm_bg.getTileCollisionFlags(x, y + 17) != FlxObject.NONE) {
					props.set("dir", 0);
				} else if (parent_state.tm_bg.getTileCollisionFlags(x, y -14) != FlxObject.NONE) {
					props.set("dir", 2);
				} else if (parent_state.tm_bg.getTileCollisionFlags(x-10, y) != FlxObject.NONE) {
					props.set("dir", 1);
				} else if (parent_state.tm_bg.getTileCollisionFlags(x+17, y) != FlxObject.NONE) {
					props.set("dir", 3);
				}
				dir = props.get("dir");
				set_dir_prefix();
				animation.play("full", true,false,-1);
				velocity.set(0, 0);
				set_initial_velocity();
			}
		}
		return 0;
	}
	
	
	function set_dir_prefix(play_anim_with_cur_suffix:Bool=false):Void 
	{
		switch (dir) {
			case 0:
				angle = 0;
				dir_prefix = "u_";
			case 1:
				angle = 90;
				dir_prefix = "r_";
			case 2:
				angle = 180;
				dir_prefix = "d_";
			case 3:
				angle = 270;
				dir_prefix = "l_";
		}
		if (play_anim_with_cur_suffix) {
			if (current_anim_suffix == "full") {
				animation.play(current_anim_suffix,false,false,-1);	
			} else {
				animation.play(current_anim_suffix);
			}
		}
	}
	
	
	
	private function hurt_player():Void {
		R.sound_manager.play(SNDC.pod_hit);
		switch (dmgtype) {
			case 0:
				if (R.player.add_dark(dmg) > 0) {
					R.player.skip_motion_ticks = 3;
				}
			case 1:
				if (R.player.add_light(dmg) > 0) {
					R.player.skip_motion_ticks = 3;
				}
		}
	}
	
	function set_initial_velocity():Void 
	{
		if (1 == props.get("starts_moving_left_or_down")) {
			if (dir == 0 || dir == 2) { // Attached to top or bottom
				velocity.x = -vel;
			} else {
				velocity.y = vel;
			}
		} else {
			if (dir == 0 || dir == 2) { // Attached to top or bottom
				velocity.x = vel;
			} else {
				velocity.y = -vel;
			}
		}
	}
	
	function update_damage_animation():Void 
	{
		if (t_dead <= 0 && R.player.overlaps(hitbox)) {
			t_dead = tm_dead;
			animation.play("empty");
			current_anim_suffix = "empty";
			hurt_player();
		}
		if (t_dead > 0) {
			if (t_dead >= 0.5 && t_dead - FlxG.elapsed < 0.5) {
				current_anim_suffix = "recover";
				animation.play("recover");
			}
			t_dead -= FlxG.elapsed;
			if (t_dead <= 0) {
				current_anim_suffix = "full";
				animation.play("full",false,false,-1);
			}
		}
	}
	
	function update_smooth_turnaround():Void 
	{
		if (moving_mode == 0) {
			if (velocity.x != 0 || velocity.y != 0) {
				found_hard = found_gap = false;
				
				if (!is_fish){
					if (HF.there_is_a_hard_tile(true,dir,this,parent_state.tm_bg)) found_hard = true;
					if (HF.there_is_a_gap(true, dir, this, parent_state.tm_bg)) found_gap = true;
				} else {
					if ((x - ix) > fish_radius || (ix - x) > fish_radius) {
						found_hard = true;
					}
				}
				if (found_gap || found_hard) {
					
					if (dir % 2 == 0) {
						HF.round_to_16(this,true);
					} else {
						HF.round_to_16(this,false);
					}
					if (is_fish) {
						found_hard = false;
					}
					moving_mode = 1;
					if (velocity.x > 0) {
						facing = FlxObject.RIGHT;
					} else if (velocity.x < 0) {
						facing = FlxObject.LEFT;
					} else if (velocity.y > 0) {
						facing = FlxObject.DOWN;
					} else if (velocity.y < 0) {
						facing = FlxObject.UP;
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
			} else if (facing == FlxObject.UP) {
				velocity.y += ease_decel * FlxG.elapsed;
				if (velocity.y > 0) velocity.y = 0;
				if (parent_state.tm_bg.getTileCollisionFlags(x + width / 2, y + FlxG.elapsed * velocity.y) != 0) {
					velocity.y = 0;
				}
			} else if (facing == FlxObject.DOWN) {
				velocity.y -= ease_decel * FlxG.elapsed;
				if (velocity.y < 0) velocity.y = 0;
				if (parent_state.tm_bg.getTileCollisionFlags(x + width / 2, y + height + FlxG.elapsed * velocity.y) != 0) {
					velocity.y = 0;
				}
			}
			if (ease_frames == ease_frames_max) {
				if (facing == FlxObject.DOWN) velocity.y = -1;
				if (facing == FlxObject.UP) velocity.y = 1;
				if (facing == FlxObject.LEFT) velocity.x = 1;
				if (facing == FlxObject.RIGHT) velocity.x = -1;
				ease_frames = 0;
				moving_mode = 2;
			}
		} else if (moving_mode == 2) {
			// Moving away from the wall, if you move too far before the number of 
			// allotted frames are over, then round to the nearest tileand go into normal moving
			if ((found_hard && !HF.there_is_a_hard_tile(false,dir,this,parent_state.tm_bg)) || (found_gap && !HF.there_is_a_gap(false,dir,this,parent_state.tm_bg))) {
				if (dir % 2 == 0) {
					HF.round_to_16(this,true);
					velocity.x = (velocity.x < 0 ? -1 : 1) * computed_max_vel;
				} else {
					HF.round_to_16(this, false);
					velocity.y = (velocity.y < 0 ? -1 : 1) * computed_max_vel;
				}
				ease_out_frames = 0;
				moving_mode = 0;
			} else {
				// Otherwise if you reach the max ease frames, floor to 16 and move normally
				if (velocity.x < 0) {
					velocity.x -= ease_decel * FlxG.elapsed;
				} else if (velocity.x > 0) {
					velocity.x += ease_decel * FlxG.elapsed;
				}
				if (velocity.y < 0) {
					velocity.y -= ease_decel * FlxG.elapsed;
				} else if (velocity.y > 0) {
					velocity.y += ease_decel * FlxG.elapsed;
				}
				if (velocity.x < -computed_max_vel) velocity.x = -computed_max_vel;
				if (velocity.x > computed_max_vel) velocity.x = computed_max_vel;
				if (velocity.y < -computed_max_vel) velocity.y = -computed_max_vel;
				if (velocity.y > computed_max_vel) velocity.y = computed_max_vel;
				
				ease_out_frames++;
				if (ease_out_frames == ease_out_frames_max) {
					ease_out_frames = 0;
					moving_mode = 0;
					if (velocity.x < 0) {
						velocity.x = -computed_max_vel;
						if (!is_fish) x = Std.int(x) - (Std.int(x) % 16);
					}
					if (velocity.x > 0) {
						velocity.x = computed_max_vel;
						if (!is_fish) x = Std.int(x) + (16 - (Std.int(x) % 16));
					}
					if (velocity.y < 0) {
						velocity.y = -computed_max_vel;
						y = Std.int(y) - (Std.int(y) % 16);
					}
					if (velocity.y > 0) {
						velocity.y = computed_max_vel;
						y = Std.int(y) + (16 - (Std.int(y) % 16));
					}
				}
			}
		}
	}
	
	override public function destroy():Void 
	{
		
		ACTIVE_WalkPods.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [hitbox,feet]);
		super.destroy();
	}
	
	private var pre_collide_x:Float = 0;
	private var pre_collide_y:Float = 0;
	override public function preUpdate():Void 
	{
		//if (!climbs_corners) {
			pre_collide_x = x;
			pre_collide_y = y;
			pre_collide_vel.setTo(velocity.x, velocity.y);
			FlxObject.separate(this, parent_state.tm_bg);
			velocity.set(pre_collide_vel.x, pre_collide_vel.y);
		//}
		super.preUpdate();
	}
	
}