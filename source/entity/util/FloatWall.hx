package entity.util;

import autom.SNDC;
import entity.MySprite;
import entity.trap.Pew;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import openfl.geom.Point;
import state.MyState;

class FloatWall extends MySprite
{

	public static var playerClimbing:Bool = false;
	//public static var ACTIVE_WalkBlocks:List<WalkBlock>;
	private var tiling_sprite:FlxSprite;
	
	private var mode:Int;
	private var vel:Float = 0;
	// Used by corner climbing logic to determine what animation to play
	private var current_anim_suffix:String = "";
	private var dir_prefix:String = "";
	private var pre_collide_vel:Point;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		pre_collide_vel = new Point();
		tiling_sprite = new FlxSprite();
		super(_x, _y, _parent, "FloatWall");
		ID = 0;
	}
	
	private var pt:Point;
	override public function change_visuals():Void 
	{
		pt = HF.string_to_point_array(props.get("w,h"))[0];
		//makeGraphic(Std.int(pt.x * 16), Std.int(pt.y * 16), 0x88ffffff);
		offset.set(0, 0);
		if (Std.int(pt.x*16) == 32) {
			AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "FloatWall", "hor");
			height = 16;
			offset.y = 8;
		} else {
			AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "FloatWall", "vert");
			width = 16;
			offset.x = 8;
		}
		animation.play("idle");
		//tiling_sprite.makeGraphic(16, 16, 0x5500ff00);
		
		switch (vistype) {
			case 0:
				//AnimImporter.loadGraphic_from_data_with_id(crab_sprite, 16, 16, "Pod", "1");
			default:
				//AnimImporter.loadGraphic_from_data_with_id(crab_sprite, 16, 16, "Pod", vistype);
		}
		
		set_dir_prefix();
		current_anim_suffix = "full";
		tiling_sprite.visible = false;
		//visible = false;
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
		p.set("use_defaults", 1);
		p.set("w,h", "1,2");
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		dir = props.get("dir");
		if (props.get("use_defaults") == 1) {
			if (dir == 0 || dir == 2) {
				
			} else {
				props.set("w,h", "2,1");
			}
		}
		mode = 0;
		velocity.set(0, 0);
		change_visuals();
	}
	

	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [tiling_sprite]);
			//ACTIVE_WalkBlocks.add(this);
		}
		
		if (R.editor.editor_active) {
			if (FlxG.keys.justPressed.SPACE) {
				moving_off = !moving_off;
			}
			if (moving_off) return;
		}
		
		
		for (i in 0...Pew.ACTIVE_Pews.length) {
			var p:Pew = Pew.ACTIVE_Pews.members[i];
			if (p != null && p.generic_overlap(this,-1)) {
				//break;
			}
		}
		
		if (dir == 0 || dir == 2) {
			if (y + height / 2 < R.player.y + R.player.height / 2) {
				velocity.y = 200;
				if (Math.abs(R.player.velocity.y) > 200) {
					velocity.y = R.player.velocity.y;
				}
			} else {
				velocity.y = -200;
			}
		} else {
			if (x + width/2 < R.player.x + R.player.width/2) {
				velocity.x = 180;
			} else {
				velocity.x = -180;
			}
		}
		
		
		if (Math.abs(R.player.y + R.player.height / 2 - (y + height / 2)) < 8) {
			velocity.y = 0;
		}
		if (Math.abs(R.player.x + R.player.width/ 2 - (x + width/ 2)) < 8) {
			velocity.x = 0;
		}
		
		immovable = true;
		last.y = y;
		
		if (dir == 1 || dir == 3) {
			var bb:Bool = FlxObject.separateY(this, R.player);
			if (touching == FlxObject.UP && bb) {
				if (ID == 0) {
					animation.play("open");
					ID = 1;
				}
				
				if (velocity.y < 0) {
					R.player.velocity.y = 15;
					
				} else if (velocity.y > 0) {
					R.player.velocity.y = velocity.y;
				}
			} else {
				
				
				if (ID == 1) {
					animation.play("close");
					ID = 0;
				}
				
				if (R.player.is_in_wall_mode() && !R.player.overlaps(this)) {
					R.player.y += FlxG.elapsed * R.player.velocity.y;
					if (R.player.overlaps(this)) {
						R.player.touching = FlxObject.DOWN;
					}
					R.player.y -= FlxG.elapsed * R.player.velocity.y;
				}
			}
		}
		
		if (wall_mode == 0) {
			var b:Bool = FlxObject.separateX(this, R.player);
			if (b) {
				if (R.player.touching & FlxObject.RIGHT > 0 && R.input.right) {
					wall_mode = 1;
					R.player.activate_wall_hang();
				} else if (R.player.touching & FlxObject.LEFT > 0 && R.input.left) {
					wall_mode = 2;
					R.player.activate_wall_hang();
				}
				
				if (ID == 0) {
					playerClimbing = true;
					animation.play("open");
					ID = 1;
				}
			}
		} else {
			playerClimbing = true;
			if (wall_mode == 1) {
				if (!R.input.right) {
					f_ctr ++;
				} else  {
					f_ctr = 0;
				}
				
				if (f_ctr < 10) {
					R.player.x = x - R.player.width + 1;
					R.player.activate_wall_hang();
				}
			} else if (wall_mode == 2) {	
				if (!R.input.left) {
					f_ctr ++;
				} else {
					f_ctr = 0;
				}
				if (f_ctr < 10) {
					R.player.x = x + width - 1;
					R.player.activate_wall_hang();
				}
			}
			if (R.input.jpA1 || !R.player.is_wall_hang_points_in_object(this)) {
				if (wall_mode == 1) {
					R.player.x --; R.player.last.x--;
				} else {
					R.player.x ++; R.player.last.x++;
				}
				wall_mode = 0;
				
				if (ID == 1) {
					animation.play("close");
					ID = 0;
				}
			}
		}
		immovable = false;
		
		super.update(elapsed);
	}
	private var f_ctr:Int = 0;
	private var wall_mode:Int = 0;
	
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
		//if (climbs_corners == false && (dir == 2 || dir == 0)) {
			//if (moving_mode == 0) {
				//frames_left_to_round ++;
				//if (frames_left_to_round_max == frames_left_to_round) {
					//frames_left_to_round = 0;
					//HF.round_to_16(this, true);
					//HF.round_to_16(this, false);
				//}
			//} else {
				//frames_left_to_round = 0;
			//}
		//} 
		
	}
	
	
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == C.MSGTYPE_MOVED_BY_EDITOR) {
			if (props.get("AUTO_ORIENT") == 1) {
				if (parent_state.tm_bg.getTileCollisionFlags(x+width/2, y + height+1) != FlxObject.NONE) {
					props.set("dir", 0);
				} else if (parent_state.tm_bg.getTileCollisionFlags(x+width/2, y -1) != FlxObject.NONE) {
					props.set("dir", 2);
				} else if (parent_state.tm_bg.getTileCollisionFlags(x-5, y+height/2) != FlxObject.NONE) {
					props.set("dir", 1);
				} else if (parent_state.tm_bg.getTileCollisionFlags(x+width+1, y+height/2) != FlxObject.NONE) {
					props.set("dir", 3);
				}
				dir = props.get("dir");
				set_dir_prefix();
				velocity.set(0, 0);
				//set_initial_velocity();
			}
		}
		return 0;
	}
	
	
	function set_dir_prefix(play_anim_with_cur_suffix:Bool=false):Void 
	{
		switch (dir) {
			case 0:
				dir_prefix = "u_";
			case 1:
				dir_prefix = "r_";
			case 2:
				dir_prefix = "d_";
			case 3:
				dir_prefix = "l_";
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
	
	function update_smooth_turnaround():Void 
	{
		if (moving_mode == 0) {
			if (velocity.x != 0 || velocity.y != 0) {
				found_hard = found_gap = false;
				//if (HF.there_is_a_hard_tile(true,dir,this,parent_state.tm_bg)) found_hard = true;
				if (HF.there_is_a_gap(true,dir,this,parent_state.tm_bg)) found_gap = true;
				if (found_gap || found_hard) {
					
					if (dir % 2 == 0) {
						HF.round_to_16(this,true);
					} else {
						HF.round_to_16(this,false);
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
						x = Std.int(x) - (Std.int(x) % 16);
					}
					if (velocity.x > 0) {
						velocity.x = computed_max_vel;
						x = Std.int(x) + (16 - (Std.int(x) % 16));
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
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [tiling_sprite]);
		//ACTIVE_WalkBlocks.remove(this);
		super.destroy();
	}
	
	private var pre_collide_x:Float = 0;
	private var pre_collide_y:Float = 0;
	override public function preUpdate():Void 
	{
		//if (!climbs_corners) {
			//pre_collide_x = x;
			//pre_collide_y = y;
			//pre_collide_vel.setTo(velocity.x, velocity.y);
			if (FlxObject.separate(this, parent_state.tm_bg)) {
				x = last.x;
				y = last.y;
			}
			//velocity.set(pre_collide_vel.x, pre_collide_vel.y);
		//}
		super.preUpdate();
	}
	
	override public function draw():Void 
	{
		
		tiling_sprite.visible = true;
		for (i in 0...Std.int(pt.y)) {
			for (j in 0...Std.int(pt.x)) {
				tiling_sprite.x = x + j * 16;
				tiling_sprite.y = y + i * 16;
				//tiling_sprite.draw();
			}
		}
		tiling_sprite.visible = false;
		
		super.draw();
	}
}