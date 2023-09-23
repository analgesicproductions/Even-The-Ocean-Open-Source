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

class WalkBlock extends MySprite
{

	public static var ACTIVE_WalkBlocks:List<WalkBlock>;
	private var tiling_sprite:FlxSprite;
	private var crab_sprite:FlxSprite;
	
	private var mode:Int;
	private var vel:Float = 0;
	// Used by corner climbing logic to determine what animation to play
	private var current_anim_suffix:String = "";
	private var dir_prefix:String = "";
	private var pre_collide_vel:Point;
	private var feet:FlxSprite;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		pre_collide_vel = new Point();
		crab_sprite = new FlxSprite();
		tiling_sprite = new FlxSprite();
		feet = new FlxSprite();
		super(_x, _y, _parent, "WalkBlock");
	}
	
	private var pt:Point;
	private var frame_array:Array<Array<String>>;
	override public function change_visuals():Void 
	{
		pt = HF.string_to_point_array(props.get("w,h"))[0];
		makeGraphic(Std.int(pt.x * 16), Std.int(pt.y * 16), 0x88ffffff);
		frame_array = [];
		var _w:Int = Std.int(pt.x);
		var _h:Int = Std.int(pt.y);
		
		
		for (i in 0...Std.int(pt.y)) {
			frame_array.push([]);
			for (j in 0...Std.int(pt.x)) {
				if (1 == Std.int(pt.x)) {
					if (i == 0) {
						frame_array[i].push("ulr");
					} else if (i == Std.int(pt.y) - 1) {
						frame_array[i].push("dlr");
					} else {
						frame_array[i].push("lr");
					}
				} else if (1 == Std.int(pt.y)) {
					if (j == 0) {
						frame_array[i].push("lud");
					} else if (j == Std.int(pt.x) - 1) {
						frame_array[i].push("rud");
					} else {
						frame_array[i].push("ud");
					}
				} else {
					if (j == 0 && i == 0) {
						frame_array[i].push("ul");
					} else if (j == _w - 1 && i == _h -1 ) {
						frame_array[i].push("dr");
					} else if (j == _w - 1 && i == 0 ) {
						frame_array[i].push("ur");
					}else if (j == 0 && i == _h -1 ) {
						frame_array[i].push("dl");
					} else if (i == 0) {
						frame_array[i].push("u");
					} else if (j == 0)  {
						frame_array[i].push("l");
					} else if (i == _h - 1) {
						frame_array[i].push("d");
					} else if (j == _w - 1) {
						frame_array[i].push("r");
					} else {
						frame_array[i].push("n");
					}
				}
			}
		}
		//Log.trace(vistype);
		//Log.trace(props.get("vis-dmg"));
		//switch (vistype) {
			//case 0:
				AnimImporter.loadGraphic_from_data_with_id(crab_sprite, 16, 16, "Pod", "1");
				AnimImporter.loadGraphic_from_data_with_id(tiling_sprite, 16, 16, "WalkBlock",0);
			//default:
				//AnimImporter.loadGraphic_from_data_with_id(crab_sprite, 16, 16, "Pod", vistype);
				//AnimImporter.loadGraphic_from_data_with_id(tiling_sprite, 16, 16, "WalkBlock",vistype);
		//}
		
		set_dir_prefix();
		crab_sprite.animation.play(dir_prefix + "full", true);
		current_anim_suffix = "full";
		tiling_sprite.visible = false;
		
		AnimImporter.loadGraphic_from_data_with_id(feet, 16, 32, "WalkBlock", "feet_walkblock");
		
		feet.height = 16;
		feet.offset.y = 16;
		crab_sprite.visible = false;
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
		p.set("starts_moving_left_or_down", 0);
		p.set("AUTO_ORIENT", 1);
		p.set("f_speed",16);
		p.set("decel-frames", "120,20,30");
		p.set("w,h", "2,2");
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		
		
		if (props.get("f_speed") == 8 && props.get("decel-frames") == "120,20,30") {
			props.set("decel-frames", "400,25,20");
		}
		
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		dir = props.get("dir");
		frames_left_to_round_max = props.get("f_speed");
		frames_left_to_round = 0;
		computed_max_vel = 960.0 / props.get("f_speed"); // Change later for frame stuff
		vel = computed_max_vel;
		
		
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
		velocity.set(0, 0);
		
		change_visuals();
		
		set_initial_velocity();
	}
	
	private var t_sound:Int = 0;

	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [tiling_sprite, crab_sprite,feet]);
			ACTIVE_WalkBlocks.add(this);
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
		
		t_sound ++;
		if (t_sound > 30) {
			t_sound = Std.int( -5 + 5 * Math.random());
			R.sound_manager.set_pan_for_next_play(-1 + 2*((crab_sprite.x - FlxG.camera.scroll.x) / (416)));
			R.sound_manager.play(SNDC.walkblock, 0.5 + 0.5 * Math.random(), true, crab_sprite);
		}
		
		
		update_smooth_turnaround();
		
		
		// block lasers
		immovable = true;
		last.y = y;
		FlxObject.separateY(this, R.player);
		
		if (touching == FlxObject.UP) {
			R.player.extra_x += FlxG.elapsed * velocity.x;
			if (velocity.y < 0) {
				R.player.velocity.y = 15;
				
			} else if (velocity.y > 0) {
				R.player.velocity.y = velocity.y;
			}
		} else {
			if (R.player.is_in_wall_mode() && wall_mode == 0) {
				if (R.player.y < y && R.player.velocity.y > 0 && R.player.overlaps(this)) {
					R.player.touching = FlxObject.DOWN;
					//Log.trace(1);
				}
			}

		}
		
		if (wall_mode == 0) {
			var b:Bool = FlxObject.separateX(this, R.player);
			if (b && R.player.wasTouching & FlxObject.DOWN == 0) {
				if (R.player.y + R.player.height <= y + 2) {
					if (R.player.touching & FlxObject.RIGHT > 0 ) { 
						R.player.x += 2;
					} else {
						R.player.x -= 2;
					}
					R.player.last.x = R.player.x;
					R.player.last.y = R.player.y = y - R.player.height - 1;
					R.player.touching ^= (FlxObject.RIGHT | FlxObject.LEFT);
				} else if (R.player.is_in_wall_mode() == false) {
					if (R.player.touching & FlxObject.RIGHT > 0 && R.input.right) {
						if (R.player.touching & FlxObject.DOWN == 0) {
							wall_mode = 1;
							R.player.activate_wall_hang();
							R.player.x = x - R.player.width + 1;
						}
					} else if (R.player.touching & FlxObject.LEFT > 0 && R.input.left) {
						if (R.player.touching & FlxObject.DOWN == 0) {
							wall_mode = 2;
							R.player.activate_wall_hang();
							R.player.x = x + width - 1;
						}
					}
				}
			} else {
				if (R.player.overlaps(this) && R.player.y < y + height -2 && R.player.y +R.player.height > y + 4) {
					if (R.player.is_in_wall_mode() == false) {
						// only push you left
						if (R.player.x < x + width / 2) {
							if (velocity.x < 0) {
								R.player.x = R.player.last.x = x - R.player.width;
							}
						} else if (velocity.x > 0) {
							R.player.x = R.player.last.x = x +width;
						}
					}
					if (R.player.y > y + height - 4) {
						R.player.y = y + height;
					}
				}
			}
		} else {
			//Log.trace(wall_mode);
			if (wall_mode == 1) {
				
				if (R.input.left) {
					wht++;
					R.player.push_off_ctr = 0;
				} else {
					wht = 0;
				}
				//Log.trace(R.player.touching);
				if (R.player.wasTouching & FlxObject.DOWN > 0) {
					wall_mode = 0;
					//R.player.wasTouching = FlxObject.DOWN;
					//Log.trace("1");
				} else if (wht == 15) {
					wall_mode = 0;
					R.player.x = R.player.last.x = x - 1;
					R.player.velocity.x = -80;
					wht = 0;
					R.player.touching = R.player.wasTouching = 0;
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
				} else if (wht == 15) {
					wall_mode = 0;
					R.player.x = R.player.last.x = x +width+ 1;
					R.player.velocity.x = 80;
					wht = 0;
					R.player.touching = R.player.wasTouching = 0;
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
			
			if (!R.player.is_wall_hang_points_in_object(this)) {
				wall_mode = 0;
			}
		}
		immovable = false;
		
		super.update(elapsed);
	}
	
	private var wht:Int = 0;
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
		
		switch (dir) { // URDL
			case 0:
				crab_sprite.move(x + width/2 - crab_sprite.width/2, y + height - crab_sprite.height);
			case 1:
				crab_sprite.move(x, y + (height - crab_sprite.height)/2);
			case 2:
				crab_sprite.move(x + width/2 - crab_sprite.width/2, y);
			case 3:
				crab_sprite.move(x+width-crab_sprite.width, y + (height - crab_sprite.height)/2);
		}
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
				crab_sprite.animation.play(dir_prefix + "full", true);
				velocity.set(0, 0);
				set_initial_velocity();
			}
		}
		return 0;
	}
	
	
	function set_dir_prefix(play_anim_with_cur_suffix:Bool=false):Void 
	{
		dir_prefix = "";
		switch (dir) {
			case 0:
				crab_sprite.angle = 0;
			case 1:
				crab_sprite.angle = 90;
			case 2:
				crab_sprite.angle = 180;
			case 3:
				crab_sprite.angle = 270;
		}
		if (play_anim_with_cur_suffix) {
			crab_sprite.animation.play(dir_prefix + current_anim_suffix);
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
		//Log.trace(moving_mode);
		if (moving_mode == 0) {
			if (velocity.x != 0 || velocity.y != 0) {
				found_hard = found_gap = false;
				//if (HF.there_is_a_hard_tile(true,dir,this,parent_state.tm_bg)) found_hard = true;
				if (HF.there_is_a_gap(true,dir,this,parent_state.tm_bg) && HF.there_is_a_gap(true,dir,this,parent_state.tm_bg2)) found_gap = true;
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
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [crab_sprite, tiling_sprite,feet]);
		ACTIVE_WalkBlocks.remove(this);
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
	
	override public function draw():Void 
	{
		
		tiling_sprite.visible = true;
		for (i in 0...Std.int(pt.y)) {
			for (j in 0...Std.int(pt.x)) {
				tiling_sprite.animation.play(frame_array[i][j], true);
				tiling_sprite.x = x + j * 16;
				tiling_sprite.y = y + i * 16;
				tiling_sprite.draw();
			}
		}
		tiling_sprite.visible = false;
		
		
			var pref:String = "";
			if (dir == 0 && velocity.x < 0) pref = "reverse";
			if (dir == 2 && velocity.x > 0) pref = "reverse";
			if (dir == 1 && velocity.y < 0) pref = "reverse";
			if (dir == 3 && velocity.y > 0) pref = "reverse";
			feet.animation.play(pref + "walk");
			switch (dir) {
				case 3: feet.move(crab_sprite.x + 8, crab_sprite.y+8); feet.angle = 270;
				case 0: feet.move(crab_sprite.x, crab_sprite.y + 16); feet.angle = 0;
				case 1: feet.move(crab_sprite.x - 8, crab_sprite.y+8); feet.angle = 90;
				case 2: feet.move(crab_sprite.x, crab_sprite.y); feet.angle = 180;
			} 
			
		//super.draw();
	}
}