package entity.enemy;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

import autom.SNDC;
import entity.MySprite;
import flash.geom.Point;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import haxe.Constraints.FlatEnum;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import state.MyState;

class SmashHand extends MySprite
{

	public static var ACTIVE_SmashHands:List<SmashHand>;
	public var aggro_zone:FlxSprite;
	
	private var drag_box:FlxSprite;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		drag_box = new FlxSprite();
		aggro_zone = new FlxSprite();
		drag_box.makeGraphic(16, 16, 0xffff0000);
		drag_box.alpha = 0.75;
		super(_x, _y, _parent, "SmashHand");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0: //dark
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "SmashHand", 0);
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "SmashHand", 1);
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "SmashHand", 1);
		}
	
		//24x12
		
		animation.play("tick_1");
		if (dir == 2) {
			angle = 0;
		width = 24;
		height = 12;
		offset.set(4, 10);
		} else {
			if (dir == 1) {
				angle = 270;
			} else {
				angle = 90;
			}
		width = 12;
		height = 24;
		offset.set(10, 4);
		}
		visible = false;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("tm_wait", 0);
		p.set("dmg", 64);
		p.set("init_vel", 150);
		p.set("accel", 1000);
		p.set("tm_follow",1.5);
		p.set("vel_follow", 150);
		p.set("tm_ground_wait", 1.5);
		p.set("tm_pause", 0.5);
		p.set("dir", 2);
		p.set("aggro_dims", "200,200");
		return p;
	}

	private var dir:Int = 0;
	private var tm_pause:Float = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		props.remove("is_32");
		props.remove("push_vel");
		props.remove("push_ticks");
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		tm_wait = props.get("tm_wait");
		tm_follow = props.get("tm_follow");
		vel_follow = props.get("vel_follow");
		tm_ground_wait = props.get("tm_ground_wait");
		dir = props.get("dir");
		tm_pause = props.get("tm_pause");
		
		var pt:Point = HF.string_to_point_array(props.get("aggro_dims"))[0];
		aggro_zone.make_rect_outline(Std.int(pt.x), Std.int(pt.y), 0x88ff00ff,"SmashHand");
		aggro_zone.x = ix;
		aggro_zone.y = iy;
		
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		ACTIVE_SmashHands.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [aggro_zone,drag_box]);
		super.destroy();
	}
	
	private var vel_follow:Float = 0;
	private var t_follow:Float = 0;
	private var tm_follow:Float = 0;
	private var t_ground_wait:Float = 0;
	private var tm_ground_wait:Float = 0;
	private var t_wait:Float = 0;
	private var tm_wait:Float = 0;
	private var inactive:Bool = true;
	private var searching:Bool = false;
	private var dmgd:Bool = false;
	private var on_ground:Bool = false;
	private var search_y:Int = 0;

	private var drag_mode:Int = 0;
	
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [aggro_zone,drag_box]);
			ACTIVE_SmashHands.add(this);
		}
		if (R.editor.editor_active) {
			visible = true;
			x = ix;
			y = iy;
			aggro_zone.visible = true;
			aggro_zone.x = ix;
			aggro_zone.y = iy;
			drag_box.alpha = 0.75;
		} else {
			drag_box.alpha = 0;
			aggro_zone.visible = false;
			if (inactive) {
				visible = false;
			} else {
				visible = true;
			}
		}
		
		if (R.editor.editor_active) {
			update_dragbox();
		}
		
		if (inactive) {
			if (t_wait < tm_wait) {
				t_wait += FlxG.elapsed;
			} else {
				// Don't spawn if you're not in the aggro zone
				if (!R.player.overlaps(aggro_zone)) {
					return;
				}
				immovable = true;
				search_y = -1;
				
				//if (dir == 2) {
					//width = 14;
					//offset.x = 9;
				//} else {
					//height = 14;
					//offset.y = 9;
				//}
				
				for (tm in [parent_state.tm_bg, parent_state.tm_bg2]) {
					var outerbreak:Bool = false;
					
					if (dir == 2) {
						for (i in [32, 16, -1]) {
							search_y = i;
							if (HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x + R.player.width / 2 - (width/2), R.player.y - search_y)) && HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x + R.player.width / 2 + (width/2), R.player.y - search_y)) && HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x + R.player.width / 2 - (width/2), R.player.y - search_y - height)) && HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x + R.player.width / 2 + (width/2), R.player.y - search_y - height))) {
								x = R.player.x + R.player.width / 2 - (width/2);
								y = R.player.y - search_y - height;
								outerbreak = true;
								break;
							}
						}
					}
					if (dir == 1) { // goig right, appears on left
						for (i in [48, 32, 16]) {
							search_y = i;
							if (HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x - search_y, R.player.y + R.player.height/2 - height/2)) && HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x - search_y,  R.player.y + R.player.height/2 + height/2 - 3)) && HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x - search_y + width, R.player.y + R.player.height/2 - height/2)) && HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x - search_y + width,  R.player.y + R.player.height/2 + height/2 - 3)) ) {
								x = last.x = R.player.x - search_y;
								y = last.y = R.player.y + R.player.height / 2 - (height / 2) - 4;
								outerbreak = true;
								break;
							}
						}
					}
					if (dir == 3) { // goig left, appears on right
						for (i in [32, 16,0]) {
							search_y = i;
							if (HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x +R.player.width+ search_y, R.player.y + R.player.height/2 - height/2)) && HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x  +R.player.width+ search_y,  R.player.y + R.player.height/2 + height/2 - 3)) && HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x  +R.player.width+ search_y + width, R.player.y + R.player.height/2 - height/2)) && HF.array_contains(HelpTilemap.organic, tm.getTileID(R.player.x  +R.player.width+ search_y + width,  R.player.y + R.player.height/2 + height/2 - 3)) ) {
								x = last.x = R.player.x  +R.player.width+ search_y;
								y = last.y = R.player.y + R.player.height / 2 - (height / 2) - 4;
								outerbreak = true;
								break;
							}
						}
					}
					if (outerbreak) {
						inactive = false;
						immovable = false;
						visible = true;
						alpha = 0.5;
						searching = true;
						t_follow = 0;
						t_wait = props.get("tm_wait");
						animation.play("tick_1", true);
						break;
					}
				}
			}
		} else if (searching) {
			var dest_x:Float = 0;
			var dest_y:Float = 0;
			if (dir == 2) {
				dest_x = R.player.x + R.player.width / 2 - (width/2);
				dest_y = R.player.y - 32 - height;
			} else if (dir == 1) {
				dest_x = R.player.x - 48;
				dest_y = R.player.y + R.player.height / 2 - (height / 2);
			} else if (dir == 3) {
				dest_x = R.player.x +R.player.width + 32;
				dest_y = R.player.y + R.player.height / 2 - (height / 2);
			}
			// now fall
			if (t_follow < 0) {
				//angle = 360 * Math.random();
				alpha += 0.04;
				if (t_follow == -tm_pause) {
					//alpha = 0.5;
					R.sound_manager.play(SNDC.smashwarn1,0.75);
					animation.play("warn", true);
				} else if (t_follow < -.5* tm_pause && t_follow + FlxG.elapsed >= -.5 * tm_pause) {
					//alpha = 0.5;
					//R.sound_manager.play(SNDC.menu_move);
				} 
				
				t_follow += FlxG.elapsed;
				if (t_follow >= 0) {
					animation.play("attack");
					//R.sound_manager.play(SNDC.menu_move);
					//angle = 0;
					searching = false;
					alpha = 1;
					if (dir == 2) {
						velocity.y = props.get("init_vel");
						velocity.x = 0;
						acceleration.y = props.get("accel");
					} else if (dir == 1) {
						velocity.x = props.get("init_vel");
						velocity.y = 0;
						acceleration.x = props.get("accel");
					} else if (dir == 3) {
						velocity.x = -props.get("init_vel");
						velocity.y = 0;
						acceleration.x = -props.get("accel");
					}
					
					
					//if (dir == 2) {
						//width = 26; offset.x = 3;
						//x -= 6;
					//} else if (dir == 1 || dir == 3) {
						//height = 26; offset.y = 3;
						//y -= 6;
					//}
					
					
				}
			} else {
				
				if (t_follow == 0) {
					//alpha = 0.5;
					R.sound_manager.play(SNDC.smashwarn2);
					animation.play("tick_1", true);
				} else if (t_follow < .33 * props.get("tm_follow") && t_follow + FlxG.elapsed >= .33 * props.get("tm_follow")) {
					//alpha = 0.5;
					R.sound_manager.play(SNDC.smashwarn2);
					animation.play("tick_2", true);
				}else if (t_follow < .66 * props.get("tm_follow") && t_follow + FlxG.elapsed >= .66 * props.get("tm_follow")) {
					//alpha = 0.5;
					R.sound_manager.play(SNDC.smashwarn2);
					animation.play("tick_3", true);
				}
				
				t_follow += FlxG.elapsed;
				alpha += 0.04;
				//alpha = 0.9 + 0.1 * (t_follow / tm_follow);
				
				if (y < dest_y && Math.abs(y-dest_y) > 2) {
					velocity.y = vel_follow;
				} else if ( y > dest_y && Math.abs(y - dest_y) > 2) {
					velocity.y = -vel_follow;
				} else {
					velocity.y = 0;
				}
				
				if (x < dest_x && Math.abs(x-dest_x) > 2) {
					velocity.x = vel_follow;
				} else if (x > dest_x && Math.abs(x - dest_x) > 2){
					velocity.x = -vel_follow;
				} else {
					velocity.x = 0;
				}
				
				if (t_follow > tm_follow) {
					t_follow = -1 * tm_pause;
					velocity.set(0, 0);
				} 
			}
		} else if (on_ground) {
			t_ground_wait += FlxG.elapsed;
			alpha = 1 - (t_ground_wait / tm_ground_wait);
			
			if (t_ground_wait > tm_ground_wait) {
				t_ground_wait = 0;
				on_ground = false;
				t_wait = 0;
				inactive = true;
				dmgd = false;
				fadeout = false;
				return;
			}
			
			if (fadeout) {
				//Log.trace(2);
				super.update(elapsed);
				return;
			}
			
			// Wall hang 
			immovable = true;
			if (dir != 2) {
				var sepd_x:Bool = FlxObject.separateX(this, R.player);
				if (wall_mode == 0) {
					if (false == R.player.is_in_wall_mode()) {
						if (sepd_x) {
							if (R.player.touching & FlxObject.RIGHT > 0) {
								wall_mode = 1;
								R.player.activate_wall_hang();
							} else if (R.player.touching & FlxObject.LEFT > 0) {
								wall_mode = 2;
								R.player.activate_wall_hang();
							}
						}
					}
				} else {
					if (!R.player.is_wall_hang_points_in_object(this)) {
						wall_mode = 0;
					}
							
					if (wall_mode == 1) {
						
						if (!R.input.right) {
							wht++;
						} else {
							wht = 0;
						}
						if (wht == 15) {
							wall_mode = 0;
							R.player.x = R.player.last.x = x - 1;
							R.player.velocity.x = -80;
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
						if (!R.input.left) {
							wht++;
						} else {
							wht = 0;
						}
						if (wht == 15) {
							wall_mode = 0;
							R.player.x = R.player.last.x = x +width+ 1;
							R.player.velocity.x = 80;
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
				}
			}
			if (dir == 2) {
				allowCollisions = FlxObject.UP;
				if (FlxObject.separateY(R.player, this)) {
					R.player.velocity.y = 10;
				}
			}
			immovable = false;
			allowCollisions = FlxObject.ANY;
			
			/* FALL MODE */
			
		} else if (!inactive) { // FALLING, hit player
			
			
			
			var fxoff_x:Float = 0;
			var fxoff_y:Float = 0;
			if (dir == 2) {
				fxoff_x = 0;
				fxoff_y = 8;
			} else if (dir == 1) {
				fxoff_x = 8;
				fxoff_y = 0;
			} else {
				fxoff_x = -8;
				fxoff_y = 0;
			}
			
			
			if (overlaps(R.player) && !dmgd) {
				dmgd = true;
				R.sound_manager.play(SNDC.se_hit);
				if (R.player.shield_overlaps(this, 0)) {
					velocity.y /= 3; 
					velocity.x /= 3;
					if (dmgtype == 0) {
						R.player.add_dark(Std.int(props.get("dmg") / 2),2,x+fxoff_x+width/2,y+fxoff_y+height/2);
					} else {
						R.player.add_light(Std.int(props.get("dmg") / 2),3,x+fxoff_x+width/2,y+fxoff_y+height/2);
					}
				} else {
					if (dmgtype == 0) {
						R.player.add_dark(props.get("dmg"),2,x+fxoff_x+width/2,y+fxoff_y+height/2);
					} else {
						R.player.add_light(props.get("dmg"),3,x+fxoff_x+width/2,y+fxoff_y+height/2);
					}
				}
				R.player.skip_motion_ticks = 8;
				no_motion_ticks = 8;
			}
			
			
			
			if (touching & FlxObject.LEFT != 0 || touching & FlxObject.RIGHT != 0) {
				on_ground = true;
				velocity.set(0, 0);
				acceleration.set(0, 0);
				R.sound_manager.play(SNDC.se_hit);
				
				if (dmgtype == 0) {
					R.player.add_dark(0,4,x+fxoff_x+width/2,y+fxoff_y+height/2);
				} else {
					R.player.add_light(0,5,x+fxoff_x+width/2,y+fxoff_y+height/2);
				}
			}
			if (touching & FlxObject.DOWN != 0) {
				on_ground  = true;
				R.sound_manager.play(SNDC.se_hit);
				velocity.set(0, 0);
				acceleration.set(0, 0);
				if (dmgtype == 0) {
					R.player.add_dark(0,4,x+fxoff_x+width/2,y+fxoff_y+height/2);
				} else {
					R.player.add_light(0,5,x+fxoff_x+width/2,y+fxoff_y+height/2);
				}
			}
			if (on_ground) {
				on_ground_width_adjust();
			}
		}
		super.update(elapsed);
	}
	private var wht:Int = 0;
	private function update_dragbox():Void {
		if (drag_mode == 0) {
			
			drag_box.x = aggro_zone.x + aggro_zone.width - drag_box.width;
			drag_box.y = aggro_zone.y + aggro_zone.height - drag_box.height;
			if (FlxG.mouse.justPressed) {
				if (FlxG.mouse.inside(drag_box)) {
					drag_mode = 1;
				}
			}
				
		} else if (drag_mode == 1) {
			//drag_box.move(aggro_zone.x, aggro_zone.y);
			drag_box.x = (Std.int(FlxG.mouse.x) );
			drag_box.y = (Std.int(FlxG.mouse.y) );
		
			//trigger_w = Std.int(drag_box.x + drag_box.width - x);
			//trigger_h = Std.int(drag_box.y + drag_box.height - y);
			//
			//if (trigger_w < C.GAME_WIDTH) {
				//trigger_w = C.GAME_WIDTH;
				//drag_box.x = x + C.GAME_WIDTH - drag_box.width;
			//}
			//if (trigger_h < C.GAME_HEIGHT) {
				//trigger_h = C.GAME_HEIGHT;
				//drag_box.y = y + C.GAME_HEIGHT - drag_box.height;
			//}
			//
			if (!FlxG.mouse.pressed) {
				//props.set("tile_w", trigger_w / 16);
				//props.set("tile_h", trigger_h / 16);
				
				props.set("aggro_dims", Std.string(Std.int(drag_box.x + drag_box.width - aggro_zone.x)) + "," + Std.string(Std.int(drag_box.y + drag_box.height - aggro_zone.y)));
				//Log.trace(props.get("aggro_dims"));
				set_properties(props);
				//trigger_box.width = trigger_w;
				//trigger_box.height = trigger_h;
				drag_mode = 0;
			}
		}
	}
	
	
	private var wall_mode:Int = 0;
	private var no_motion_ticks:Int = -11;
	override public function postUpdate(elapsed):Void 
	{
		
		if (no_motion_ticks > -10) {
			no_motion_ticks--;
			if (no_motion_ticks <= 0) {
				// If not standing on the ground, push you downwards, if this is a down-hand.
				if (dir == 2) {
					if (R.player.wasTouching != FlxObject.DOWN && no_motion_ticks == 0) {
						R.player.do_vert_push(300);
					}
				}
				move_player_on_hit();
				//if (dir != 2) {
					//move_player_on_hit();
				//}
				if (no_motion_ticks == 0) {
					FlxG.cameras.shake(0.02, 0.08);
				}
				if (dir == 2 && no_motion_ticks == -5 && R.player.is_on_the_ground(true)) {
					R.player.FORCE_FALL_THROUGH_TOP = true;
					R.player.velocity.y = 100;
				}
			}
			return;
		}
		super.postUpdate(elapsed);
		if (searching || !inactive) {
			
			var ow:Float= width; var ox:Float = offset.x;
			var oh:Float = height; var oy:Float = offset.y;
			//if (dir == 2) {
				//width = 14; offset.x = 9;
			//} else {
				//height = 14; offset.y = 9;
			//}
			//
			//if (!searching) {
				//if (dir == 2) {
					//x += 6;
				//} else {
					//y += 6;
				//}
				//
			//}
			
			
			
			FlxObject.separate(this, parent_state.tm_bg);
			
			//Log.trace(visible);
			//Log.trace(alpha);
			var o_vy:Float = velocity.y;
			var sssoy:Float = y;
			if (FlxObject.separate(this, parent_state.tm_bg2)) {
				if (searching) {
					//Log.trace(1);
					var col1 :Int = parent_state.tm_bg2.getTileCollisionFlags(x, y + height + 2);
					var col2:Int = parent_state.tm_bg2.getTileCollisionFlags(x+width/2, y + height + 2);
					var col3:Int = parent_state.tm_bg2.getTileCollisionFlags(x + width, y + height + 2);
					if (col1 == FlxObject.UP || col2 == FlxObject.UP || col3 == FlxObject.UP) {
						velocity.y = o_vy;
						//Log.trace(2);
						y = sssoy;
						last.y = sssoy;
						//y += FlxG.elapsed * velocity.y;
						//last.y = y;
						touching = 0;
					}
				}
			}
			
			if (searching || !inactive) {
				var hx:Int = 0;
				var hy:Int = 0;
				for (tm in [parent_state.tm_bg,parent_state.tm_bg2]) {
					if (velocity.x > 0) {
						if (tm.getTileCollisionFlags(x + width, y + height / 2) == 0 && !HF.array_contains(HelpTilemap.organic, tm.getTileID(x + width, y + height / 2))) {
							hx++;
						}
					} else if (velocity.x < 0) {
						if (tm.getTileCollisionFlags(x, y + height / 2) == 0 && !HF.array_contains(HelpTilemap.organic, tm.getTileID(x, y + height / 2))) {
							hx++;
						}
					}
					
					if (velocity.y > 0) {
						if (tm.getTileCollisionFlags(x + width / 2, y + height) == 0 && !HF.array_contains(HelpTilemap.organic, tm.getTileID(x + width / 2, y + height))) {
							hy++;
						}
					} else if (velocity.y < 0) {
						if (tm.getTileCollisionFlags(x + width / 2, y) == 0 && !HF.array_contains(HelpTilemap.organic, tm.getTileID(x + width / 2, y))) {
							hy++;
						}
					}
				}
				if (hx == 2) {
					x = last.x;
					if (!inactive && !searching) {
						velocity.set(0, 0);
						acceleration.set(0, 0);
						on_ground = true;
						//fadeout = true;
						on_ground_width_adjust();
					}
				}
				if (hy == 2) {
					if (!inactive && !searching) {
						velocity.set(0, 0);
						acceleration.set(0, 0);
						on_ground = true;
						on_ground_width_adjust();
						//fadeout = true;
						//Log.trace(1);
					}
					y = last.y;
				}
			}
			
			if (!searching) {
				//if (dir == 2) {
					//x -= 6;
				//} else {
					//y -= 6;
				//}
				
			}
			
			width = ow; height = oh;
			offset.set(ox, oy);
		}
	}
	
	public var fadeout:Bool = false;
	
	public function generic_circle_overlap(cx:Float, cy:Float, cr:Float, _dmgtype:Int):Bool {
		if (FlxX.circle_flx_obj_overlap(cx, cy, cr, this)) {
			if (_dmgtype == dmgtype) {
				if (!searching && !inactive && !on_ground) {
					return true;
				}
			} 
		}
		return false;
	}
	
	public function generic_overlap(o:FlxObject, is_plantblock:Bool = true):Bool {
		if (is_plantblock) {
			if (!searching && !inactive && !on_ground) {
				if (o.overlaps(this)) {
					return true;
				}
			}
		}
		return false;
	}
	
	function move_player_on_hit():Void 
	{
		if (dir == 2) {
			if (R.player.facing == FlxObject.LEFT) {
				R.player.do_hor_push(175, false, false, 6);
			} else {
				R.player.do_hor_push( -175, false, false, 6);
			}
		} else {
			if (velocity.x > 0) {
				R.player.do_hor_push(225, false, false, 9);
				
			} else if (velocity.x < 0) {
				R.player.do_hor_push( -225, false, false, 9);
			}
		}
	}
	
	function on_ground_width_adjust():Void 
	{
		//if (dir == 2) {
			//width = 32; offset.x = 0;
			//x -= 3;
		//} else if (dir == 1 || dir == 3) {
			//height = 32; offset.y = 0;
			//y -= 3;
		//}
	}
}