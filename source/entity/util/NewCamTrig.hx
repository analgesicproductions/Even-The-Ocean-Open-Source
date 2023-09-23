package entity.util;

import entity.enemy.GhostLight;
import entity.MySprite;
import entity.player.Player;
import flixel.FlxObject;
import flixel.math.FlxRect;
import global.C;
import haxe.Log;
import help.HF;
import state.MyState;
import help.AnimImporter;
import flixel.FlxG;
import flixel.FlxSprite;
import state.TestState;

class NewCamTrig extends MySprite
{

	public static var active_cam:NewCamTrig;
	public static var active_leveler:NewCamTrig;
	private var drag_box:FlxSprite;
	private var trigger_box:FlxObject;
	public var mode:Int;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		drag_box = new FlxSprite();
		trigger_box = new FlxObject();
		super(_x, _y, _parent, "NewCamTrig");
	}
	
	override public function change_visuals():Void 
	{
		makeGraphic(16, 16, 0xffff0000);
		alpha = 0.75;
		drag_box.makeGraphic(16, 16, 0xffff0000);
		drag_box.alpha = 0.75;
	}
	
	public var trigger_w:Int = 0;
	public var trigger_h:Int = 0;
	public var vel:Float = 0;
	public var vel_2:Float = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("tile_w", C.GAME_WIDTH / 16);
		p.set("tile_h", C.GAME_HEIGHT/ 16);
		p.set("transition_v", 390);
		p.set("is_hor_leveler", 0);
		p.set("hor_leveler_px_up", 0);
		p.set("is_look_downer", 0);
		p.set("is_VERT", 0);
		return p;
	}
	
	private var is_VERT:Bool = false;
	private var is_hor_leveler:Bool = false;
	private var hor_leveler_px_up:Int = 0;
	private var is_look_downer:Bool = false;
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);

		trigger_w = 16*Std.int(props.get("tile_w"));
		trigger_h = 16 * Std.int(props.get("tile_h"));
		vel = props.get("transition_v");
		hor_leveler_px_up = props.get("hor_leveler_px_up");
		is_hor_leveler = 1 == props.get("is_hor_leveler");
		is_look_downer = 1 == props.get("is_look_downer");
		is_VERT = props.get("is_VERT") == 1;
		if (hor_leveler_px_up < 0) {
			hor_leveler_px_up *= -1;
			props.set("hor_leveler_px_up", hor_leveler_px_up);
		}
		
		if ((is_hor_leveler || is_look_downer) && trigger_w == C.GAME_WIDTH && trigger_h == C.GAME_HEIGHT) {
			props.set("tile_w", 6);
			props.set("tile_h", 6);
			trigger_w = 16 * 6;
			trigger_h = 16 * 6;
		}
		vel_2 = 650;
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		active_cam = null;
		if (LOCK && active_leveler == this) {
			LOCK = false;
		}
		HF.remove_list_from_mysprite_layer(this, parent_state, [drag_box]);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		
		if (!did_init) {
			did_init = true;
			ID = 0;
			trigger_box.width = trigger_w;
			trigger_box.height = trigger_h;
			HF.add_list_to_mysprite_layer(this, parent_state, [drag_box]);
			trigger_box.move(x, y);
		}
		
		if (R.easycutscene.is_off() == false) {
			if (R.easycutscene.ping_last) {
				exists = false;
			}
			super.update(elapsed);
			//Log.trace("exited");
			return;
		}
			//Log.trace("entered");
			
		
		//Log.trace([x, y]);
		trigger_box.width = trigger_w;
		trigger_box.height = trigger_h;
		trigger_box.move(x, y);
		
		
		if (ID == 0) {
			drag_box.x = x + trigger_w - drag_box.width;
			drag_box.y = y + trigger_h - drag_box.height;
			if (FlxG.mouse.justPressed) {
				if (FlxG.mouse.inside(drag_box)) {
					ID = 1;
				}
			}
		} else if (ID == 1) {
			drag_box.x = Std.int(FlxG.mouse.x) - (Std.int(FlxG.mouse.x) % 16);
			drag_box.y = Std.int(FlxG.mouse.y) - (Std.int(FlxG.mouse.y) % 16);
			
			trigger_w = Std.int(drag_box.x + drag_box.width - x);
			trigger_h = Std.int(drag_box.y + drag_box.height - y);
			
		
			if (is_hor_leveler || is_look_downer) {
				if (trigger_w < 16) {
					trigger_w = 16;
					drag_box.x = x + 16 - drag_box.width;
				}
				if (trigger_h < 16) {
					trigger_h = 16;
					drag_box.y = y + 16 - drag_box.height;
				}
			} else {
				if (trigger_w < C.GAME_WIDTH) {
					trigger_w = C.GAME_WIDTH;
					drag_box.x = x + C.GAME_WIDTH - drag_box.width;
				}
				if (trigger_h < C.GAME_HEIGHT) {
					trigger_h = C.GAME_HEIGHT;
					drag_box.y = y + C.GAME_HEIGHT - drag_box.height;
				}
			}
			
			if (!FlxG.mouse.pressed) {
				props.set("tile_w", trigger_w / 16);
				props.set("tile_h", trigger_h / 16);
				trigger_box.width = trigger_w;
				trigger_box.height = trigger_h;
				ID = 0;
			}
		}
		
		if (R.editor.editor_active == false) {
			if (is_look_downer) {
				if (hor_level_state == 0) {
					if (R.player.overlaps(trigger_box)) {
						
						if (FlxG.camera.deadzone.height > 24) {
							//Log.trace((R.player.y + R.player.height / 2));
							//Log.trace(FlxG.camera.scroll.y + FlxG.camera.deadzone.height / 2);
							if ((R.player.y + R.player.height / 2) - (FlxG.camera.scroll.y + FlxG.camera.deadzone.y + FlxG.camera.deadzone.height / 2) > 0) {
								FlxG.camera.scroll.y ++; 
								FlxG.camera._scrollTarget.y++;
								//Log.trace(1);
							} else  {
								hor_level_state = 1;
								//Log.trace(2);
							}
						}
						//if (R.player.is_in_wall_mode()) {
							//hor_level_state = 2;
							//return;
						//}
						//if (R.player.wasTouching == FlxObject.DOWN) {
						//
						//
							//FlxG.camera.followLerp = 30;
							//TestState.truly_set_default_cam(parent_state.tm_bg.width, parent_state.tm_bg.height, "wall_climb");
							//R.TEST_STATE.redraw_camera_debug();
							//hor_level_state = 1;
							//Log.trace(1);
						//}
					}
					
				} else if (hor_level_state == 1) {
					if (!R.player.overlaps(trigger_box)) {
						hor_level_state = 0;
					}
					//Log.trace(FlxG.camera.followLerp);
					//if (FlxG.camera.followLerp == 0 && !R.player.overlaps(trigger_box)) {
						//hor_level_state = 0;
						//R.TEST_STATE.redraw_camera_debug();
						//Log.trace(2);
						//TestState.truly_set_default_cam(parent_state.tm_bg.width, parent_state.tm_bg.height);
					//}
				}
				//} else if (hor_level_state == 2) {
					//if (!R.player.overlaps(trigger_box)) {
						//hor_level_state = 0;
					//}
				//}
			} else if (is_hor_leveler) {
				
				var pb:Float = 0;
				if (hor_level_state == 0) {
					if (snap_x && FlxG.camera.followLerp > 0) {
						FlxG.camera.scroll.x = FlxG.camera._scrollTarget.x;
					} else {
						snap_x = false;
					}
					if (R.player.wasTouching == FlxObject.DOWN && R.player.overlaps(trigger_box) && Elevator.num_Active_elevators == 0) {
						if (LOCK == false) {
							LOCK = true;
							active_leveler = this;
							//pb = R.player.y + R.player.height - FlxG.camera.scroll.y;
							// Deattach cam from player
							_pb = R.player.y + R.player.height;
							hor_level_state = 1;
							FlxG.camera.deadzone.height = R.TEST_STATE.DEFAULT_DEADZONE_HEIGHT + 80;
							R.TEST_STATE.redraw_camera_debug();
							FlxG.camera.followLerp = 0;
						}
					}
				}
				if (hor_level_state == 1) {
					if (!R.player.overlaps(trigger_box)) {
						//reset cam?
						LOCK = false; // hwatttt
						hor_level_state = 3;
						return;
					}
					pb = _pb - FlxG.camera.scroll.y;
					var dead_bottom:Float = FlxG.camera.deadzone.y + R.TEST_STATE.DEFAULT_DEADZONE_HEIGHT ;
					var target:Int = Std.int(FlxG.camera.height - hor_leveler_px_up);
					
					if (pb > target && pb - target > 1) {
						if (FlxG.camera.scroll.y + FlxG.camera.height < parent_state.tm_bg.height - 2) {
							FlxG.camera.scroll.y ++;
							FlxG.camera._scrollTarget.y ++;
						}
					} else if (pb < target && target - pb > 1) {
						if (FlxG.camera.scroll.y > 1) {
							FlxG.camera.scroll.y --;
							FlxG.camera._scrollTarget.y--;
						}
					} else {
						hor_level_state = 2;
					}
				} else if (hor_level_state == 2) {
					if (!R.player.overlaps(trigger_box)) {
						
						LOCK = false;
						hor_level_state = 3;
					}
				} else if (hor_level_state == 3) {
					// If lock hasn't been set by another thing, reset the deadzone
					if (!LOCK) {
						FlxG.camera.deadzone.height = R.TEST_STATE.DEFAULT_DEADZONE_HEIGHT;
						if (Player.armor_on) {
							FlxG.camera.deadzone = new FlxRect(180, 80-20+90, FlxG.width - 360, TestState._DEFAULT_DEADZONE_HEIGHT-90);
						} else {
							TestState.truly_set_default_cam(parent_state.tm_bg.width, parent_state.tm_bg.height);
						}
						FlxG.camera.followLerp = 15;
						snap_x = true;
						R.TEST_STATE.redraw_camera_debug();
					}
					hor_level_state = 0;
				}
				// reattach cam somehow
			} else {
				update_cam();
					
			}
		} else {
			mode = 0;
		}
		
		super.update(elapsed);
	}
	
	private static var LOCK:Bool = false;
	private var hor_level_state:Int = 0;
	private var _pb:Float = 0;
	private var snap_x:Bool = false;
	
	private var final_y:Float = 0;
	private var final_x:Float = 0;
	private var force_y:Float = 0;
	private var player_distance:Int = 0;
	private function update_cam():Void {
		if (mode == 0) {
			if (R.player.overlaps(trigger_box)) {
				
				if (active_cam != null && active_cam != this) {
					if (active_cam.mode != 0 && active_cam.mode != 1) {
						return;
					}
				}
				//Log.trace("activated"+" "+Std.string(iy));
				
				if (active_cam != null) {
					
					if (R.player.touching == FlxObject.UP) {
						R.player.y -= R.player.velocity.y * FlxG.elapsed;
						R.player.y -= 0.5;
						R.player.last.y = R.player.y;
						return;
					}
					//
					
					vel = 0;
					
					if (R.player.x + R.player.width + 1 >= active_cam.x + active_cam.trigger_w) {
						mode = 2;
						player_distance = 24;
						R.player.x = active_cam.x + active_cam.trigger_w - R.player.width;
					} else if (R.player.x - 1 <= active_cam.x) {
						mode = 3;
						player_distance = 24;
						R.player.x = active_cam.x;
					} else {
						if (R.player.y -1 <= active_cam.y) { //scroll up
							mode = 13;
							player_distance = 65;
							R.player.y = active_cam.y;
						} else if (R.player.y + R.player.height +1 >= active_cam.y + active_cam.trigger_h) {
							mode = 12;
							player_distance = 16;
							R.player.y = active_cam.y + active_cam.trigger_h - R.player.height;
						}
					}
							
					
					// going right or left
					if (mode == 2 || mode == 3) {
						
						
						// The next trig's y-span goes beyond the current camera bounds
						// (going from one trig to one that "contains" the current one along the y-axis
						if (y + trigger_h >= FlxG.camera.scroll.y + FlxG.camera.height && y <= FlxG.camera.scroll.y) {
							var psy:Float = R.player.y - FlxG.camera.scroll.y;
							//Log.trace([psy, FlxG.camera.deadzone.y,FlxG.camera.scroll.y]);
							if (FlxG.camera.deadzone.y - psy >= 0) {
								final_y = FlxG.camera.scroll.y - (FlxG.camera.deadzone.y - psy) - 16;
								if (final_y < y) final_y = y;
							} else if (psy + R.player.height > FlxG.camera.deadzone.bottom) {
								//Log.trace(2);
								final_y = FlxG.camera.scroll.y + ((psy + R.player.height) - FlxG.camera.deadzone.bottom);
								// going to a trigger vertically enveloping the current one,
								// but the new one is not low enough to contain the above final_y calclations
								if (final_y > y + trigger_h - FlxG.camera.height) {
									final_y = y + trigger_h - FlxG.camera.height;	
								}
							} else {
								final_y = FlxG.camera.scroll.y;
							}
							
							//Log.trace(1);
							
						//the next trig's bottom extends beyond the current one's
						} else if (y + trigger_h > active_cam.y + active_cam.trigger_h) {
							var psy:Float = R.player.y - FlxG.camera.scroll.y;
							// going to a 'lower' camtrig, you're at bottom of current, and the top of the camera view is above the top of the next camtrig
							if (FlxG.camera.scroll.y <= y) {
								final_y = y;
							} else if (psy + R.player.height > FlxG.camera.deadzone.bottom) {
							//Log.trace(2);
								final_y = y + ((psy + R.player.height) - FlxG.camera.deadzone.bottom);
							} else {
							//Log.trace(3);
								final_y = y;
							}
						} else { // new trigger's bottom is higher than current trigger
							
							if (FlxG.camera.scroll.y <= y) {
								//Log.trace(4);
								final_y = y;
							} else {
								//Log.trace(4);
								final_y = y + trigger_h - 256;
								//final_y = y;	
							}
						}
					} else {
						//transition
						//
						var o_stx:Float = FlxG.camera._scrollTarget.x;
						var o_sty:Float = FlxG.camera._scrollTarget.y;
						var o_sx:Float = FlxG.camera.scroll.x;
						var o_sy:Float = FlxG.camera.scroll.y;
						
						FlxG.camera.follow(R.player);
						FlxG.camera.deadzone = new FlxRect(180, 60, FlxG.width - 360, TestState._DEFAULT_DEADZONE_HEIGHT);
						FlxG.camera.setScrollBoundsRect(x, y, trigger_w, trigger_h);
						final_y = FlxG.camera.scroll.y;
						final_x = FlxG.camera.scroll.x;
						
						// setBounds() changes these values, so set them to the old onse
						// so there isn't weird clipping bug
						FlxG.camera._scrollTarget.set(o_stx, o_sty);
						FlxG.camera.scroll.set(o_sx, o_sy);
						
						var psx:Float = R.player.x - FlxG.camera.scroll.x;
						var dead_x:Float = FlxG.camera.deadzone.x;
						var dead_rx:Float = FlxG.camera.deadzone.x + FlxG.camera.deadzone.width;
						
						// Player is in the deadzone x-wise, so don't need to update the final_x value
						if (psx >= dead_x && psx + R.player.width <= dead_rx) {
							
						// the current final_X value is incorrect so chang eit
						} else {
							//Log.trace("hi");
							// new player coords, in screen space.
							var new_prx:Float = (R.player.x + R.player.width) - final_x;
							var new_plx:Float = R.player.x  - final_x;
							//Log.trace([final_x]);
							if (new_prx > dead_rx) {
								//Log.trace([dead_x, new_prx]);
								final_x += (new_prx - dead_rx);
								final_x += (FlxG.camera.deadzone.width / 2);
							} else if (new_plx < dead_x) {
								//Log.trace([dead_x, new_plx]);
								final_x -= (dead_x - new_plx);
								final_x -= (FlxG.camera.deadzone.width / 2);
							}
							if (final_x < x) final_x = x;
							if (final_x + C.GAME_WIDTH > x + trigger_w) final_x = x + trigger_w - C.GAME_WIDTH;
							//Log.trace([final_x]);
						}
					}
					
					FlxG.camera.follow(null);
					FlxG.camera.setScrollBoundsRect(0, 0, parent_state.tm_bg.width, parent_state.tm_bg.height);
					
					//if (mode == 2 || mode == 3) {
						//force_y = FlxG.camera.scroll.y;
					//}
					
					if (parent_state.tm_bg.getTileCollisionFlags(R.player.x + 4, R.player.y - 4) != 0) {
						R.player.y += 3;  R.player.last.y = R.player.y;
					}
					
					// change aactive cam at da end
					active_cam = this;
					R.player.enter_cutscene();
					
					for (ghost in GhostLight.ACTIVE_GhostLights) {
						if (ghost != null) {
							if (ghost.is_ghost) {
								ghost.kill_from_newcamtrig();
							}
						}
					}
							
					
					
				} else {
					
					active_cam = this;
					mode = 1;
					FlxG.camera.setScrollBoundsRect(x, y, trigger_w, trigger_h);
				}
				
			}
		} else if (mode == 1) {
			if (active_cam != this) {
				mode = 0;
			}
		} else if (mode == 2) { // scroll right
			//Log.trace(mode);
			//FlxG.camera.scroll.y = force_y;
			//Log.trace(FlxG.camera.scroll.y);
			if (active_cam.x - FlxG.camera.scroll.x < 150) {
				if (vel > 150) {
					vel -= 23;
				}
			} else {
				if (vel < vel_2) {
					vel += 73;
				} else {
					vel = vel_2;
				}
			}
			R.player.skip_motion_ticks = 2;
			
			if (R.player.x - active_cam.x >= player_distance) {
				
			} else {
				R.player.x += 0.25;
				R.player.last.x = R.player.x;
			}
			
			FlxG.camera.scroll.x += vel * FlxG.elapsed;
			
			scroll_final_y();
			
			if (FlxG.camera.scroll.x >= active_cam.x) {
				FlxG.camera.scroll.x = active_cam.x;
				mode = 100;
			}
			
			
			
		} else if (mode == 3) { // scroll left
			if ((FlxG.camera.scroll.x +FlxG.camera.width ) - (active_cam.x + active_cam.trigger_w) < 150) {
				if (vel > 150) {
					vel -= 23;
				}
			} else {
				if (vel < vel_2) {
					vel += 73;
				} else {
					vel = vel_2;
				}
			}
			//Log.trace(mode);
			//FlxG.camera.scroll.y = force_y;
			//Log.trace(FlxG.camera.scroll.y);
			R.player.skip_motion_ticks = 2;
			if (active_cam.x + active_cam.trigger_w - (R.player.x + R.player.width) >= player_distance) {
				
			} else {
				R.player.x -= 0.25;
				R.player.last.x = R.player.x;
			}
			FlxG.camera.scroll.x -= vel * FlxG.elapsed;
			
			scroll_final_y();
			
			if (FlxG.camera.scroll.x +FlxG.camera.width <= active_cam.x+active_cam.trigger_w) {
				FlxG.camera.scroll.x = active_cam.x + active_cam.trigger_w - FlxG.camera.width;
				mode = 100;
			}
		} else if (mode == 12) { // scroll down
			
			if ((active_cam.y) - (FlxG.camera.scroll.y)< 120) {
				if (vel > 150) {
					vel -= 33;
				}
			} else {
				if (vel < vel_2) {
					vel += 73;
				} else {
					vel = vel_2;
				}
			}
			
			R.player.skip_motion_ticks = 2;
			if (R.player.y - active_cam.y >= player_distance) {
				
			} else {
				R.player.y += 4;
				R.player.last.y = R.player.y;
			}
			FlxG.camera.scroll.y += vel * FlxG.elapsed;
			scroll_final_x();
			if (FlxG.camera.scroll.y > active_cam.y) {
				FlxG.camera.scroll.y = active_cam.y;
				R.player.y = active_cam.y + player_distance;
				mode = 100;
			}
		} else if (mode == 13) { // scroll up
			if ( (FlxG.camera.scroll.y + 256) - (active_cam.y+active_cam.trigger_h) < 120) {
				if (vel > 150) {
					vel -= 33;
				}
			} else {
				if (vel < vel_2) {
					vel += 73;
				} else {
					vel = vel_2;
				}
			}
			R.player.skip_motion_ticks = 2;
			if ((active_cam.y + active_cam.trigger_h) - (R.player.y + R.player.height) >= player_distance) {
			} else {
				R.player.y -= 4;
				R.player.last.y = R.player.y;
			}
			FlxG.camera.scroll.y -= vel * FlxG.elapsed;
			scroll_final_x();
			if (FlxG.camera.scroll.y +FlxG.camera.height < active_cam.y + active_cam.trigger_h) {
				FlxG.camera.scroll.y = active_cam.y + active_cam.trigger_h -FlxG.camera.height;
				mode = 100;
				//Log.trace([final_x, FlxG.camera.scroll.x, FlxG.camera._scrollTarget.x]);
				R.player.y = (active_cam.y + active_cam.trigger_h) - (R.player.height) - player_distance;
			}
		} else if (mode == 100) {
			
			//FlxG.camera.scroll.y = Std.int(FlxG.camera.scroll.y);
			//Log.trace(FlxG.camera.scroll.y);
			R.player.enter_main_state();
			R.player.npc_interaction_off = true; // So the shield bug doesn' happe lol
			
			FlxG.camera.follow(R.player);
			FlxG.camera.deadzone = new FlxRect(180, 60, FlxG.width - 360, TestState._DEFAULT_DEADZONE_HEIGHT);
			FlxG.camera.setScrollBoundsRect(x, y, trigger_w, trigger_h);
				//Log.trace([final_x, FlxG.camera.scroll.x, FlxG.camera._scrollTarget.x]);
			
			//FlxG.camera.scroll.y = Std.int(FlxG.camera.scroll.y);
			//Log.trace(FlxG.camera.scroll.y);
			mode = 1;
		}
		
	}
	
	private function scroll_final_y():Void 
	{
		if (FlxG.camera.scroll.y < final_y) {
			FlxG.camera.scroll.y += Math.abs(vel*0.5) * FlxG.elapsed;
			if (FlxG.camera.scroll.y > final_y) {
				FlxG.camera.scroll.y = final_y;
			}
		} else if (FlxG.camera.scroll.y > final_y) {
			FlxG.camera.scroll.y -= Math.abs(vel*0.5) * FlxG.elapsed;
			if (FlxG.camera.scroll.y < final_y) {
				FlxG.camera.scroll.y = final_y;
			}
		}
		//Log.trace([FlxG.camera.scroll.y, FlxG.camera._scrollTarget.y, final_y]);
		FlxG.camera._scrollTarget.y = FlxG.camera.scroll.y;
	}
	private function scroll_final_x():Void {
		if (FlxG.camera.scroll.x < final_x) {
			FlxG.camera.scroll.x += Math.abs(vel*0.8) * FlxG.elapsed;
			if (FlxG.camera.scroll.x > final_x) {
				FlxG.camera.scroll.x = final_x;
			}
		} else if (FlxG.camera.scroll.x > final_x) {
			FlxG.camera.scroll.x -= Math.abs(vel*0.8) * FlxG.elapsed;
			if (FlxG.camera.scroll.x < final_x) {
				FlxG.camera.scroll.x = final_x;
			}
		}
		FlxG.camera._scrollTarget.x = FlxG.camera.scroll.x;
	}
	override public function draw():Void 
	{
		if (R.editor.editor_active) {
			if (active_cam == this) {
				// do something
			}
			active_cam = null;
			drag_box.visible = true;
			
			if (R.editor.hide_zones) {
				alpha = 0.1;
				drag_box.alpha = 0.1;
			} else {
				alpha = drag_box.alpha = 0.75;
			}
			var sx:Float = FlxG.camera.scroll.x;
			var sy:Float = FlxG.camera.scroll.y;
			if (is_hor_leveler) {
				if (R.editor.hide_zones) {
					FlxG.camera.debugLayer.graphics.lineStyle(1, 0xffbb22, 0.1);	
				} else {
					FlxG.camera.debugLayer.graphics.lineStyle(1, 0xffbb22, 1);	
				}
			} else {
				if (R.editor.hide_zones) {
					FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 0.1);	
				} else {
					FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
				}
			}
			FlxG.camera.debugLayer.graphics.moveTo(x-sx,y-sy);
			FlxG.camera.debugLayer.graphics.lineTo(x-sx+trigger_w,y-sy);
			FlxG.camera.debugLayer.graphics.moveTo(x-sx+trigger_w,y-sy);
			FlxG.camera.debugLayer.graphics.lineTo(x-sx+trigger_w,y+trigger_h-sy);
			FlxG.camera.debugLayer.graphics.moveTo(x-sx+trigger_w,y+trigger_h-sy);
			FlxG.camera.debugLayer.graphics.lineTo(x-sx,y+trigger_h-sy);
			FlxG.camera.debugLayer.graphics.moveTo(x-sx,y+trigger_h-sy);
			FlxG.camera.debugLayer.graphics.lineTo(x-sx,y-sy);
			super.draw();

		} else {
			
			drag_box.visible = false;
		}
		
	}
	
}