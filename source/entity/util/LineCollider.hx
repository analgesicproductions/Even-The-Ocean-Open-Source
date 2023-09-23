package entity.util;
import autom.SNDC;
import entity.MySprite;
import entity.player.Player;
import flixel.FlxObject;
import haxe.Log;
import help.FlxX;
import help.HF;
import openfl.geom.Point;
import state.MyState;
import help.AnimImporter;
import flixel.FlxG;
import flixel.FlxSprite;

class LineCollider extends MySprite
{

	public static var player_touching:Bool = false;
	public static var player_no_slope_slow:Bool = false;
	private static var active_LineColliders:List<LineCollider>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		if (active_LineColliders == null) {
			active_LineColliders = new List<LineCollider>();
		}
		
		a = new Point();
		b = new Point();
		wall_a = new Point();
		wall_b = new Point();
		s = new Point();
		zipline_box = new FlxSprite(); zipline_box.makeGraphic(3, 7, 0xffff0000); zipline_box.alpha = 1; // tall so that if you are falling too fast you can still catch its
		super(_x, _y, _parent, "LineCollider");
	}
	
	override public function change_visuals():Void 
	{
		
		makeGraphic(8, 8, 0xffff0000);
		alpha = 0.5;
	}
	
	private var is_ceiling:Bool = false;
	private var is_zipline:Bool = false;
	private var is_conveyer:Bool = false;
	
	private var zipline_box:FlxSprite;
	private var base_accel:Float = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("coords", "0,0,32,0");
		p.set("invis", 1);
		p.set("is_ceiling", 0);
		p.set("is_zipline", 0);
		p.set("zip_max_vel", 330); 
		p.set("base_accel", 145);
		return p;
	}
	
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		
		pts = HF.string_to_point_array(props.get("coords"));
		base_accel = props.get("base_accel");
		recalculate_arrays();
		change_visuals();
		if (props.get("is_ceiling") == 1) {
			is_ceiling = true;
		}
		if (props.get("is_zipline") == 1) {
			is_zipline = true;
			is_conveyer = false;
			is_ceiling = false;
			props.set("is_ceiling", 0);
		} else if (props.get("is_zipline") == 2) {
			is_zipline = true;
			is_conveyer = true;
			is_ceiling = false;
			props.set("is_ceiling", 0);
		}
	}
	
	private function recalculate_arrays():Void {
		
		seg_is_hor = new Array<Bool>();
		w_array = new Array<Float>();
		h_array = new Array<Float>();
		arctans = new Array<Float>();
		overlapping = new Array <Bool>();
		
		for (i in 0...pts.length - 1) {
			if (pts[i].y == pts[i + 1].y) {
				seg_is_hor.push(true);
			} else {
				seg_is_hor.push(false);
			}
			
			w_array.push(pts[i + 1].x - pts[i].x);
			h_array.push(pts[i + 1].y - pts[i].y);
			overlapping.push(false);
			if (w_array[i] == 0) {
				arctans.push(100);
			} else {
				arctans.push(Math.atan(Math.abs(pts[i + 1].y - pts[i].y) / Math.abs(pts[i + 1].x - pts[i].x)));
				arctans[i] *= (360.0 / 6.28);
			}
		}
		
		for (i in 0...pts.length) {
			pts[i].x = Std.int(pts[i].x);
			pts[i].y = Std.int(pts[i].y);
		}
		props.set("coords", HF.point_array_to_string(pts));
		
		
	}
	override public function destroy():Void 
	{
		
		//HF.remove_list_from_mysprite_layer(this, parent_state, []);
		active_LineColliders.remove(this);
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [zipline_box]);
		zipline_box.destroy();
		mouse_pressed_LOCK = false;
		super.destroy();
	}

	var overlapping:Array<Bool>;
	var seg_is_hor:Array<Bool>;
	public var pts:Array<Point>;
	var w_array:Array<Float>;
	var h_array:Array<Float>;
	var arctans:Array<Float>;
	
	var a:Point; // lh of line segment
	var b:Point; // rh of line segment
	var w:Float; // lineseg dx
	var h:Float; // lineseg d
	var s:Point; // pt of player hitbox to push upwards
	
	private var drag_mode:Int = 0;
	
	private var wall_a:Point;
	private var wall_b:Point;
	
	private var mouse_pressed_inside:Bool = false;
	private var mouse_pressed_inside_wait:Bool = false;
	private static var mouse_pressed_LOCK:Bool = false;
	private var last_frame_played_touched:Bool = false;
	override public function update(elapsed: Float):Void 
	{

		
		if (!did_init) {
			if (cur_layer  != MyState.ENT_LAYER_IDX_FG2) {
				cur_layer = MyState.ENT_LAYER_IDX_FG2;
				parent_state.bg1_sprites.remove(this, true);
				parent_state.bg2_sprites.remove(this, true);
				parent_state.fg2_sprites.add(this);
			}
				//HF.add_list_to_mysprite_layer(this, parent_state, [zipline_box]);
			did_init = true;
			active_LineColliders.add(this);
		}
		if (drag_mode != 0) {
			update_drag();
			if (drag_mode == 0) {
				mouse_pressed_LOCK = false;
			}
			return;
		} else {
			if (mouse_pressed_LOCK == false && R.editor.mode_add_cur_group_idx == MyState.ENT_LAYER_IDX_FG2) {
				try_to_enter_drag_mode();
				if (drag_mode != 0) {
					mouse_pressed_LOCK = true;
				}
			}
		}
		
		/* If this becomes the movable ent in the editor then after
		 * the mouse is released if the mouse is inside another LC
		 * snap this entity to that one*/
		try_snap_to_other_lc();
		
		if (is_zipline) {
			if (Player.armor_on == false) {
				update_zipline();
			}
			super.update(elapsed);
			return;
		}
		
		var overlap_nonslope:Bool = false;
		var do_wall_update:Bool = false;
		for (i in 0...seg_is_hor.length) {
			if (R.player.x > ix + pts[i + 1].x || R.player.x + R.player.width < ix + pts[i].x) {
				overlapping[i] = false;
				continue;
			}
			if (last_frame_played_touched) {
				//Log.trace(22);
				if (R.player.velocity.y >= 0 && arctans[i] < 60  && !R.player.is_in_wall_mode()) {
					
					// Walking on hor to a tile - dont get stuck
					// need to check ahead and before so you 'snap' only once or twice
					//Log.trace("butt");
					if (seg_is_hor[i] && R.player.velocity.x > 0 && parent_state.tm_bg.getTileCollisionFlags(R.player.x + R.player.width+FlxG.elapsed*R.player.velocity.x, R.player.y + R.player.height + 3) == FlxObject.ANY && parent_state.tm_bg.getTileCollisionFlags(R.player.x + R.player.width-FlxG.elapsed*40, R.player.y + R.player.height + 3) == 0) {
						//Log.trace(2);
						// need this or u will colllide..?
						R.player.y = R.player.last.y = Math.round(R.player.last.y)-0.1; 
						R.player.x += FlxG.elapsed * R.player.velocity.x; 
						R.player.last.x = R.player.x; 
						R.player.touching |= FlxObject.DOWN; R.player.velocity.y = 0;
					} else if (seg_is_hor[i] && R.player.velocity.x < 0 && parent_state.tm_bg.getTileCollisionFlags(R.player.x + FlxG.elapsed*R.player.velocity.x, R.player.y + R.player.height + 3) == FlxObject.ANY && parent_state.tm_bg.getTileCollisionFlags(R.player.x-FlxG.elapsed*-40, R.player.y + R.player.height + 3) == 0) {
 						//Log.trace(3);
						R.player.y = R.player.last.y = Math.round(R.player.last.y) -0.1; 
						R.player.x += FlxG.elapsed * R.player.velocity.x; 
						
						R.player.last.x = R.player.x; 
						R.player.touching |= FlxObject.DOWN; 
						R.player.velocity.y = 0;
					}
					if (i == 0 && R.player.velocity.x < 0 &&  (R.player.x) - (pts[i].x + ix ) < 2 * FlxG.elapsed * -R.player.velocity.x) {
						//Log.trace(1);
					} else if (i+1==pts.length-1 && R.player.velocity.x > 0 && pts[i + 1].x + ix - (R.player.x + R.player.width) < 2 * FlxG.elapsed * R.player.velocity.x) {
						//Log.trace(2);
					} else {
						//don't do double slope snapping
						if (i > 0 && overlapping[i - 1] && pts[i].y >= pts[i - 1].y) {
							if (!HF.ray_intersects_box(ix + pts[i].x, iy + pts[i].y, w_array[i], h_array[i], R.player, 1)) {
								
							} else {
								if (seg_is_hor[i]) {
									// I don't get why this is here
									//R.player.y = R.player.last.y = R.player.y + 2;
									//R.player.y = R.player.last.y;
									// Because the previous segment set the below thing (For slope snapping), last.y will be GREATER than y
									
									//R.player.last.y = R.player.y;
								}
							}
						} else {
						//Log.trace(i);
							// Add this 3 pixel offset because
							// we don't want to bump player extra in cases where
							// the x overlaps but there is a significant Y difference
							// (EG a vertical cliff)
							R.player.y += 3;
							if (HF.ray_intersects_box(ix + pts[i].x, iy + pts[i].y, w_array[i], h_array[i], R.player, 1)) {
								R.player.y = R.player.last.y = R.player.y + 2;
							}
							R.player.y -= 3;
						}
					}
				}
			}
			if (HF.ray_intersects_box(ix + pts[i].x, iy + pts[i].y, w_array[i], h_array[i], R.player, 1)) {
				
				// if walking down ar-facing slope don't collide to
				// the 2nd slope if youve collided to the first
				if (i > 0 && overlapping[i - 1] && player_touching) {
					
					if (pts[i - 1].y < pts[i].y && h_array[i] > 0 && h_array[i - 1] > 0) {
						//Log.trace("ass");
						continue;
					}
				}
				
				// if segment is 0 degrees, push player upewards.
				if (seg_is_hor[i]) {
					
					var dont_Snap:Bool = false;
					// if at the lip don't snap up top
					dont_Snap = is_at_the_lip(i) && (in_wall || R.player.wasTouching == 0);
					if (parent_state.tm_bg.getTileCollisionFlags(R.player.x + 5, R.player.y + R.player.height + 3) != 0) {
						//Log.trace("floor tile");
						dont_Snap = true;
					}
					
					// if at the lip (As above) but traveling down and from above the segment
					// then u are intending to land... so don't run into the wall.
					if (dont_Snap && R.player.velocity.y > 0 && R.player.last.y + R.player.height < pts[i].y + iy) {
						dont_Snap = false;
						//Log.trace("snap anyways!");
					}
					
					if (in_wall) {
						if (wall_idx < i) { // Allow collisions with a hor seg at the bottom of wall
							if (pts[wall_idx].y < pts[i].y) {
								
							}
						} else if (wall_idx > i) {
							if (pts[wall_idx].y < pts[i].y) {
								
							}
						} else {
							dont_Snap = true;
						}
					}
					
					if (!dont_Snap) {
						//Log.trace("on nonslope");
						//Log.trace([R.player.y, R.player.last.y]);
						

						// lookbehind 2 and ahead 2 for cases where
						// you can be running on the gruond 
						if (i < seg_is_hor.length - 2) {
							if (HF.ray_intersects_box(ix + pts[i+2].x, iy + pts[i+2].y, w_array[i+2], h_array[i+2], R.player, 1) && pts[i+1].y < pts[i+2].y) {
								//Log.trace([10,i]);
								continue;
							}
						}
						
						if (i >1) {
							if (HF.ray_intersects_box(ix + pts[i-2].x, iy + pts[i-2].y, w_array[i-2], h_array[i-2], R.player, 1) && pts[i].y <= pts[i-1].y) {
								//Log.trace([20,i]);
								continue;
							}
						}
						
						overlap_nonslope = true;
						//Log.trace([R.player.y, R.player.last.y]);	
						if (R.player.y < R.player.last.y && R.player.y <= pts[i].y + iy && is_ceiling) { // ceilings
							R.player.y = R.player.last.y;
							R.player.velocity.y = 0;
							//Log.trace(["hello",i,in_wall]);
						} else {
							//Log.trace("poop");
							R.player.y = iy + pts[i].y - R.player.height + 1;
						}
						overlapping[i] = true;
						player_touching = true;
					} else {
						//Log.trace("dont snap y");
						continue;
					}
				} else {
					
					
					// a is leftmost end of line segment, b is rightmost
					a.setTo(ix+pts[i].x, iy+pts[i].y);
					b.setTo(ix + pts[i + 1].x, iy + pts[i + 1].y);
					
					
					/* do wall stuff if needed*/
					// wall calculates happen outside of the for loop
					if (in_wall && wall_idx == i) {
						do_wall_update = true;
						wall_a.setTo(a.x, a.y);
						wall_b.setTo(b.x, b.y);
						//Log.trace(i);
						continue;
					} 
					
					// special cases for too-steep slopes
					if (arctans[i] > 60 && !is_ceiling) {
						
					// slopes act as walls when walking
						if (R.player.is_on_the_ground(true) == true) {
							// if walking into a left-face slope from the ground
							if (pts[i + 1].y < pts[i].y && (R.player.y + R.player.height-3) > pts[i + 1].y + iy) {
								if (R.player.velocity.x > 0) {
									R.player.x = pts[i].x + ix - R.player.width - 1;	
									//Log.trace(1);
								}
							} else if (pts[i].y < pts[i + 1].y && (R.player.y + R.player.height-3) > pts[i].y + iy) {
								if (R.player.velocity.x < 0) {
									R.player.x = pts[i + 1].x + ix + 1;
							
									//Log.trace(12);
								}
							}
							continue;
						} else {
							
							// If not holding into the slope, don't wall climb
							//instead just have the player fall down the slope
							if (pts[i + 1].y < pts[i].y) {
								if (R.input.right == false) {
									if (pts[i + 1].x == pts[i].x) {
										
									} else {
										R.player.x = get_x_given_y(a, b, R.player.y + R.player.height);
										R.player.x -= R.player.width;
										
										//Log.trace(3);
										continue;
									}
								}	
							} else {
								if (R.input.left == false) {
									if (pts[i + 1].x == pts[i].x) {
										
									} else {
										R.player.x = get_x_given_y(a, b, R.player.y + R.player.height);
										//Log.trace(4);
										continue;
									}
								}	
							}
							
						}
					}
					
					
					/* ceiling - if coming from above dont collide */
					//
					//// Rigth at the left-edge of a segment
					if (is_ceiling) {
						//Log.trace(1);
						var _py:Float = pts[i].y + iy;
						var _px:Float = pts[i].x + ix;
						if (R.player.x <= _px) {
							if (R.player.x <= _px - (R.player.width - 2)) {
								if (R.player.y + 1 <= _py) {
									//Log.trace(2);
									continue;
								}
							} else {
								if (R.player.y +R.player.height - 2 <= _py) {
									//Log.trace(2);
									continue;
								}
							}
						} else if (R.player.x + R.player.width >= pts[i + 1].x + ix) {
							
							if (R.player.x + 2 >= pts[i + 1].x + ix) {
								if (R.player.y +1 <= _py) {
									continue;
								}
							} else {							
								if (R.player.y +R.player.height - 2 <= _py) {
									continue;
								}
							}
						}
					}
					
					// Figure out if it's a ceiling collision
					var is_below:Bool = false;
					if (is_ceiling) {
						is_below = true;
						if (R.player.is_in_wall_mode()) {
							continue;
						}
					}
					if (h_array[i] > 0) { // 'b' lower than a. pt to push out is bottom leftof player
						s.x = R.player.x;
						
						// Add a timestep so that you don't overlap it next frame?
						if (is_below) {
							if (arctans[i] > 50) {
								s.x = R.player.x + R.player.width + 1 * FlxG.elapsed * R.player.velocity.x;
							} else {
								s.x = R.player.x + R.player.width + 3 * FlxG.elapsed * R.player.velocity.x;
							}
							//Log.trace(2);
						}
						
						R.player.touching |= FlxObject.LEFT;
					} else { // 'a' is higher than b, pt is bottom right of player
						s.x = R.player.x + R.player.width;
						
						if (is_below) {
							if (arctans[i] > 50) {
								s.x = R.player.x + R.player.width + 1 * FlxG.elapsed * R.player.velocity.x;
							} else {
								s.x = R.player.x + R.player.width + 3 * FlxG.elapsed * R.player.velocity.x;
							}
						}
						
						R.player.touching |= FlxObject.RIGHT;
					}
					if (s.x < a.x) s.x = a.x;
					if (s.x > b.x) s.x = b.x;
					// find where on the line to pushplayer's y too. easy formula
					
					var q:Float = 0;
					var skip_set_y:Bool = false;

					if (is_at_the_lip(i) && (in_wall || R.player.wasTouching == 0)	) {
						//Log.trace(["at the lip, in wall",i]);
						
						// Avoid snapping in x dir off of a r-face wall's lip
						if (!in_wall && R.player.last.y + R.player.height <= pts[i+1].y + iy && R.player.velocity.y > 0) {
							//Log.trace(1);
						} else {
							continue;
						}
					}
					if (w_array[i] < 1) { // vertical case
						q = 0;
						skip_set_y = true;
					} else {
						q = (s.x - a.x) / w_array[i];
					}
					
					
					if (arctans[i] > 60 && !is_ceiling) {
						if (i+1 <= pts.length-1) {
							if (HF.ray_intersects_box(ix + pts[i + 1].x, iy + pts[i + 1].y, w_array[i + 1], h_array[i + 1], R.player, 1)) {
								// If at a lip and are trying to get onto the top of the lip
								// then skip the wall collision
								//Log.trace("a");
								var m:Float = (pts[i + 1].y + iy) - (R.player.y + R.player.height);
								//Log.trace(m);
								if (arctans[i + 1] < 60 && m >= -2.5) {
									//Log.trace("b");
									continue;
								}
							}
						}
					}
					
					if (skip_set_y) {
						
					} else {
						if (q < 0) q = 0;
						if (q > 1) q = 1;
						// since h_array is negative for left-facing slopes we don't need another conditional 
						s.y = q * h_array[i] + a.y;
						R.player.y = s.y - R.player.height;	
						// push a bit further for ceilings
						if (is_below) {
							R.player.y = R.player.last.y = s.y + 4;
							// steep ceiling problem?
							//if (h_array[i] > 0) {
								//Log.trace(1);
								//R.player.last.x = R.player.x = R.player.x - 1.5;
							//} else {
								//R.player.last.x = R.player.x = R.player.x + 1.5;
							//}
						}
						R.player.y += 1; // hack
					
					}
					if (R.input.right && parent_state.tm_bg.getTileCollisionFlags(R.player.x + R.player.width, R.player.y + R.player.height) != 0) {
						R.player.y--;
						R.player.x++;
					}
					if (R.input.left && parent_state.tm_bg.getTileCollisionFlags(R.player.x, R.player.y + R.player.height) != 0) {
						R.player.y--;
						R.player.x--;
					}
				}
				
				if (arctans[i] > 60 && !is_ceiling) {
					
					in_wall = true;
					//if (b.y > a.y) {
						//R.player.touching = FlxObject.LEFT;
						
					//} else {
						//R.player.touching = FlxObject.RIGHT;
					//}
					wall_idx = i;
						
					// Don't slide until you are travelling slow enough
					// (This is the same avlue as the normal tile collisions)
					if (R.player.velocity.y < -108) {
					} else {
						if (R.player.velocity.y < -20) {
							R.player.velocity.y = -90;
						}
						t_stick = 0;
						do_wall_update = true;
						wall_a.setTo(a.x, a.y);
						wall_b.setTo(b.x, b.y);
						//Log.trace(arctans[i]);
						//Log.trace("Enter wall!");
						//Log.trace(wall_idx);
					}
				} else {
					overlap_nonslope = true;
					if (!is_ceiling) {
						R.player.touching |= FlxObject.DOWN;
						if (R.player.velocity.y > 80 && R.player.wasTouching != FlxObject.DOWN) {
							//Log.trace(R.player.velocity.y);
							//Log.trace("hi");
							R.sound_manager.play(SoundZone.active_floor_sound);
						}
					}
					R.player.velocity.y = 0;
				}
				//Log.trace(i);
				overlapping[i] = true;
				player_touching = true;
				last_frame_played_touched = true;
				if (!is_ceiling && arctans[i] < 25) {
					player_no_slope_slow = true;
				}
			} else {
				if (i == wall_idx && in_wall) {
					in_wall = false;
					//Log.trace("exit");
				}
				overlapping[i] = false;
			}
		}
		if (!player_touching) {
			last_frame_played_touched = false;
		}
		// Wait till after checking all collisions to udpate wall
		if (do_wall_update) {
			
			// if touching a horzintaonl slope fall off the wall
			if (overlap_nonslope) {
				in_wall = false;
				overlapping[wall_idx] = false;
				//Log.trace("blah");
				if (R.input.right) {
					R.player.x -= 3;
				} else {
					R.player.x += 3;
				}
			} else {
				R.player.activate_wall_hang();
				update_wall_mode(wall_a, wall_b);
			}
		} else {
			//Log.trace("no wall");
		}
		super.update(elapsed);
	}
	
	private var in_wall:Bool = false;
	private var wall_idx:Int = 0;
	
	private var t_stick:Int = 0;
	private function update_wall_mode(a:Point, b:Point):Void {
		var dy:Float = b.y - a.y;
		var is_left_slope:Bool = true;
		if (dy > 0) {
			is_left_slope = false;
		}
		//Log.trace([R.player.x, R.player.y, R.player.last.x, R.player.last.y, R.player.velocity.x]);
		//Log.trace([R.player.touching]);
		if (is_left_slope) {
			//R.player.velocity.x = 10;
			//if (R.input.left|| (!R.input.right && !R.input.left)) {
			if (R.input.left) {
				t_stick++;
				if (t_stick == 9) {
					R.player.velocity.x = -30;
					R.player.velocity.y = 0;
					in_wall = false;
					R.player.x -= 3;
					R.player.y -= 2;
					return;
				}
			} else {
				t_stick = 0;
			}
		} else {
			//R.player.velocity.x = -10;
			if (R.input.right) {
				t_stick++;
				if (t_stick == 9) {
					R.player.velocity.x = 30;
					R.player.velocity.y = 0;
					in_wall = false;
					R.player.x += 3;
					R.player.y -= 2;
					return;
				}
			} else {
				t_stick = 0;
			}
		}
		
		//Log.trace([dx, dy, h]);
		//Log.trace(h); 
		//Log.trace([R.player.x, R.player.y]);
		R.player.x = get_x_given_y(a, b, R.player.y + R.player.height);
		if (is_left_slope) {
			R.player.x -= R.player.width;
			if (a.x != b.x) { // only add correction on non-vertical wall
				R.player.x += 1.5;
			}
			if (R.player.y + R.player.height + 2 * FlxG.elapsed * R.player.velocity.y < b.y) {
				R.player.x -= 1;
			}
		} else {
			if (a.x != b.x) {
				R.player.x -= 1.5;
			}	
			if (R.player.y + R.player.height + 2 * FlxG.elapsed * R.player.velocity.y < a.y) {
				R.player.x -= 1;
			}
		}
		
		
		R.player.activate_wall_hang();
	}
	
	private function get_x_given_y(a:Point, b:Point, py:Float):Float {
		var dx:Float = b.x - a.x;
		var dy:Float = Math.abs(b.y - a.y);
		var h:Float = 0.0;
		if (b.y > a.y) {
			h = b.y - py;
			h = dy - h;
		} else {
			h = a.y - py;
		}
		return a.x + (dx * (h / dy));
	}
	
	private var drag_iy:Float = 0;
	private var drag_pt_index:Int = 0;
	private var drag_move_y:Bool = false; // whether to move it in y dir or not, only after displacing mouse from intiial pt enough
	private var snapping_to_angle:Bool = false;
	private var snap_angle_x:Float = 0;
	private function update_drag():Void {
		
		
		// when u let go of mouse, exit, and recalculate values 
		
		// if you were snapping to a 45/etc deg angle, then allow letting go of shift
		// to lock in the value (it's hard to remember to let go of click first)
		if (FlxG.mouse.pressed == false) {
			drag_mode = 0;
			snapping_to_angle = false;
			
			// Try to snap endpts
			if (drag_pt_index == pts.length - 1) {
				for (lc in active_LineColliders) {
					if (lc != this) {
						
						// Create a sprite that the mouse can overlap
						var pt:Point = lc.pts[lc.pts.length - 1];
						lc.x += pt.x;
						lc.y += pt.y;
						if (FlxG.mouse.inside(lc)) {
							// set the correct pts..
							pts[drag_pt_index].x = lc.x - ix;
							pts[drag_pt_index].y = lc.y - iy;
							//this.x = this.ix = lc.ix;
							//this.y = this.iy = lc.iy;
							recalculate_arrays();
						}
						lc.x -= pt.x;
						lc.y -= pt.y;
					}
				}
			}
			
			x = ix;
			y = iy;
			recalculate_arrays();
		}
		
		/* Assumes drag_pt_index > 0 (should be enforced by initialization code) */
		if (drag_mode == 1) { 
			
			
			// Must move outside of a margin before y starts moving
			//if (Math.abs(FlxG.mouse.y - drag_iy) > 14) {
				drag_move_y = true;
			//}
			
			if (drag_move_y) {
				var _y:Float = FlxG.mouse.y - iy;
				// ALT held = snap to grid
				if (FlxG.keys.pressed.ALT) {
					_y += iy;
					_y = (Std.int(_y) - (Std.int(_y) % 16));
					_y -= iy;
					
					pts[drag_pt_index].y = _y;
				// shift held = rounds to arctan(1), 1/2, 0, -1/2, -1 angles.
				} else if (FlxG.keys.pressed.SHIFT) {
					// needs to be even to work
					//if (snapping_to_angle == false) {
						snap_angle_x = FlxG.mouse.x;
						if (Math.round(snap_angle_x) % 2 == 1) {
							snap_angle_x= Math.round(snap_angle_x) + 1;
						}
						snap_angle_x -= ix;
					//}
					snapping_to_angle = true;
					var dx:Int = Std.int(snap_angle_x) - Math.round(pts[drag_pt_index - 1].x);
					// round to arctan 1, 1/2, 0, etc
					var dy:Float = _y - pts[drag_pt_index - 1].y;
					var left_y:Float = pts[drag_pt_index - 1].y;
					if (dy < 1.74 * -dx) {
						_y = left_y - 1.74 * dx;
					}else if (dy < -dx) {
						_y = left_y - dx;
					} else if (dy < -dx / 2) {
						_y = left_y - dx/2;
					} else if (dy < 0) {
						_y = left_y;
					} else if (dy < dx / 2) {
						_y = left_y + dx / 2;
					} else if (dy < dx) {
						_y = left_y + dx;
					} else {
						_y = left_y + 1.74*dx;
					}
					pts[drag_pt_index].x = snap_angle_x;
					pts[drag_pt_index].y = _y;
				} else {
					pts[drag_pt_index].y = _y;
				}
			}
			
			var _x:Float = FlxG.mouse.x;
			// move x, only if shift not held
			if (!FlxG.keys.pressed.SHIFT) {
				
				
				// snap to grid
				if (FlxG.keys.pressed.ALT) {
					_x = (Std.int(_x) - (Std.int(_x) % 16));
				}
				
				// finally update the pt value
				pts[drag_pt_index].x = _x - ix;
			} 
			
				// Can't move past the left/right segments
			if (_x <= pts[drag_pt_index - 1].x+ix) {
				_x = pts[drag_pt_index - 1].x + ix;
				pts[drag_pt_index].x = _x - ix;
			} else if (drag_pt_index != pts.length - 1 && _x >= pts[drag_pt_index + 1].x+ ix) {
				_x = pts[drag_pt_index + 1].x + ix;
				pts[drag_pt_index].x = _x - ix;
			}
			
			
			
		}
		
	}
	
	function try_to_enter_drag_mode():Void 
	{
		
		if (R.editor.editor_active) {
			if (!R.editor.in_add()) {
				return;
			}
			for (i in 1...pts.length) {
				
				// Move the little red box so the mouse has something to intersect
				// this also is moved in draw() code so u can see the clickable boxes
				move(ix + pts[i].x, iy + pts[i].y);
				
				
				// regular click = either delete (if D held) or go to drag code
				if (!FlxG.keys.pressed.CONTROL && FlxG.mouse.justPressed && FlxG.mouse.inside(this)) {
					
					// Delete pt from the line segments
					if (FlxG.keys.pressed.D) {
						if (i == 0) {
							
						} else if (i == 1 && pts.length <= 2) {
							
						} else {
							pts.splice(i, 1);
							recalculate_arrays();
						}
						move(ix, iy);
						return;
					}
					drag_mode = 1;
					drag_pt_index = i; // which pt to s
					break;
				}
				
				
				// new segment if click box at right side of collider
				if (i == pts.length - 1) {
					x += 16;
					if (!FlxG.keys.pressed.CONTROL && FlxG.mouse.justPressed && FlxG.mouse.inside(this)) {
						drag_mode = 1;
						drag_pt_index = i+1;
						pts.push(new Point(x - ix, y - iy));
						break;
					}
				}
				
			}
			
			// Press ctrl + click: insert new pt between pts
			if (FlxG.keys.pressed.CONTROL && FlxG.mouse.justPressed && !FlxG.mouse.inside(new FlxObject(ix,iy,8,8))) {
				var n:Bool = false;
				for (i in 0...pts.length - 1) {
					
					// transform pt coordinates into game space
					pts[i].x += ix; pts[i].y += iy;
					pts[i + 1].x += ix; pts[i + 1].y += iy;
					
					// find x-interval that mouse-x lies in
					if (FlxG.mouse.x > pts[i].x && FlxG.mouse.x < pts[i + 1].x) {
						var dy:Float = Math.abs(pts[i].y - pts[i + 1].y);
						
						// If the pts are close enough y-distance-wise, allow clicking
						// anywhere close enough to either pt (margin of8 px)
						if (dy < 8) {
							if (Math.abs(FlxG.mouse.y - pts[i].y) <= 8 || Math.abs(FlxG.mouse.y - pts[i + 1].y) <= 8) {
								n = true;
								//new
							}
						// otherwise click must be between the two y values 
						// (i.e. rect defined by the 2 pts)
						} else {
							if (pts[i].y < pts[i + 1].y) {
								if (FlxG.mouse.y >= pts[i].y && FlxG.mouse.y <= pts[i + 1].y) {
									
								n = true;
								}
							} else {
								if (FlxG.mouse.y >= pts[i+1].y && FlxG.mouse.y <= pts[i].y) {
									
								n = true;
								}
							}
						}
					}
					pts[i].x -= ix; pts[i].y -= iy;
					pts[i + 1].x -= ix; pts[i + 1].y -= iy;
					
					
					// Inserts the new pt and also goes to drag mode (presumably wanted)
					if (n) {
						pts.insert(i + 1, new Point(FlxG.mouse.x - ix, FlxG.mouse.y - iy));
						recalculate_arrays();
						drag_mode = 1;
						drag_pt_index = i + 1;
						break;
					}
					
				// For loop end
				}
			}
			
			
			
			x = ix;
			y = iy;
			
			if (drag_mode != 0) {
				drag_iy = FlxG.mouse.y;
				drag_move_y = false;
				return;
			}
			
			
			
			
			
		}
		
		
	}
	
	private function is_at_the_lip(i:Int):Bool 
	{
		if (i > 0) {
			if (arctans[i - 1] > 60) {
				if (pts[i - 1].y > pts[i].y) {
					if (HF.ray_intersects_box(ix + pts[i - 1].x, iy + pts[i - 1].y, w_array[i - 1], h_array[i - 1], R.player, 1)) {
						//Log.trace("at the lip");
						return true;
					}
				}
			}
		} 
		
		//Log.trace("hi");
		//Log.trace([w_array.length, i + 1]);
		if (w_array.length > i + 1) {
			if (arctans[i + 1] > 60) {
				if (pts[i+1].y < pts[i+2].y) {
					if (HF.ray_intersects_box(ix + pts[i+1].x, iy + pts[i+1].y, w_array[i+1], h_array[i+1], R.player, 1)) {
						//Log.trace("at the lip");
						return true;
					}
				}
			}
		} 
		return false;
	}
	
	private function try_snap_to_other_lc():Void 
	{
		if (R.editor.editor_active && R.editor.in_add()) {
			if (!mouse_pressed_LOCK && !mouse_pressed_inside) {
				if (FlxG.mouse.pressed && FlxG.mouse.inside(this) && R.editor.movable_sprite == this) {
					mouse_pressed_inside = true;
					mouse_pressed_LOCK = true;
				}
			} else if (mouse_pressed_inside) {
				
				if (mouse_pressed_inside_wait) {
					mouse_pressed_inside_wait = false;
					for (lc in active_LineColliders) {
						if (lc != this) {
							if (FlxG.mouse.inside(lc)) {
								this.x = this.ix = lc.ix;
								this.y = this.iy = lc.iy;
								recalculate_arrays();
							}
						}
					}
				}
				
				if (FlxG.mouse.justReleased) {
					mouse_pressed_inside_wait = true;
				} else {
					if (FlxG.mouse.pressed == false) {
						mouse_pressed_inside = false;
						mouse_pressed_LOCK = false;
					}
				}
			}
		}
	}
	
	override public function draw():Void 
	{
		
		//Log.trace(y);
		if (R.editor.editor_active == false && props.get("invis") == 1) {
			return;
		}
		
		var start_x:Float = ix - FlxG.camera.scroll.x;
		var start_y:Float = iy - FlxG.camera.scroll.y;
		for (i in 0...pts.length-1) {
			if (overlapping[i]) {
				FlxG.camera.debugLayer.graphics.lineStyle(1, 0x00ff00, 1);
			} else {
				if (is_ceiling) {
					FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff4455, 1);
				} else if (is_zipline) {
					if (is_conveyer) {
						FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff44ff, 1);
					} else {
						FlxG.camera.debugLayer.graphics.lineStyle(1, 0xeeffee, 1);
					}
				} else {
					FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
				}
			}
			
			FlxG.camera.debugLayer.graphics.moveTo(start_x + pts[i].x, start_y + pts[i].y);
			FlxG.camera.debugLayer.graphics.lineTo(start_x+ pts[i+1].x, start_y + pts[i+1].y);
			
			
			if (R.editor.editor_active) {
				
				var ox:Float = x;
				var oy:Float =  y;
				//Don't duoble-draw the original red box
				if (i != 0) {
					x = ix+  pts[i].x;
					y = iy+ pts[i].y;
					super.draw();
				}
				// On the last iteration draw box on the final endpt + the box that will create new segment
				if (i == pts.length - 2) {
					x = ix+  pts[i+1].x;
					y = iy+ pts[i+1].y;
					super.draw();
					x += 16;
					super.draw();
				}
				x = ox;
				y = oy;
			}
		}
		if (R.editor.editor_active && drag_mode == 0) {
			move(ix, iy);
		}
		super.draw();
	}
	
	private var zipline_mode:Int = 0;
	private var zivx:Float = 0; // init vx set by plaer 
	private var zivy:Float = 0; // init vy set by ratio
	private var zmv:Float = 0; // max set above
	//private var zmvx:Float = 0; // x component
	private var zmvy:Float = 0; // y ciomponent
	private var zar:Float = 0; // acceleartion ratio
	private var zsyo:Float = -11; // shield y off
	private var zsxo:Float = 4;
	private function update_zipline():Void {
		zipline_box.x = R.player.x + zsxo;
		zipline_box.y = R.player.y + zsyo;
		if (zipline_mode == 0) {
			if (R.player.velocity.y > 10 && R.player.get_shield_dir() == 0 && HF.ray_intersects_box(ix + pts[0].x, iy + pts[0].y, w_array[0], h_array[0], zipline_box, 1)) {
				zipline_mode = 1;
				//Log.trace("on");
				R.sound_manager.play(SNDC.step_tile);
				zmv = props.get("zip_max_vel");
				//Log.trace(zmv);
				var r:Float = 0;
				if (w_array[0] < 8) {
					return;
				} else {
					r = Math.abs(h_array[0] / w_array[0]);
				}
				
				// cutoffs: 1/4, 1/2, 1.
				// Sets acceleration scaling towards zmvx
				if (r == 0) {
					zar = 0;
				} else if (r >= 0 && r <= 0.26) {
					zar = 0.25;
				} else if (r > 0.26 && r <= 0.51) {
					zar = 0.5;
				} else {
					zar = 1;
				}
				
				//Log.trace(["Accel ratio", r, zar]);
				// snap player to correct y pt
				
				r = Math.abs(((zipline_box.x + 1) - (ix + pts[0].x)) / w_array[0]);
				r = r * h_array[0] + (iy + pts[0].y); // r is now the correct y pos
				zipline_box.y = r - 1; // set the boxx there
				R.player.y = R.player.last.y = zipline_box.y - zsyo; // set the player
			R.player.y = R.player.last.y = R.player.y - 4; // visual correction
				//Log.trace([R.player.y]);
				// Get components of max vel based on angle
				//Log.trace(arctans[0]);
				//Log.trace(zmv);
				//zmvx = zmv * Math.cos(Math.abs(arctans[0]));
				//zmvy = Math.abs(zmv * Math.sin(Std.int(Math.abs(arctans[0]))));
				//Log.trace([zmvx, zmvy]);
				// Set the x velocity, cap it at zmvx
				if (h_array[0] > 0) { // going down to the right
					//zmvx = Math.abs(zmvx);
					if (R.player.velocity.x >= 0) {
						if (R.player.velocity.y > 300) {
							R.player.velocity.y = 300;
						} 
						R.player.velocity.y /= 4;
						
						R.player.velocity.x += R.player.velocity.y * zar;
					}
					if (!is_conveyer && R.player.velocity.x > zmv) {
						R.player.velocity.x = zmv;
					}
				} else { // going down tot he left
					//zmvx = -Math.abs(zmvx);
					if (R.player.velocity.x <= 0) {
						if (R.player.velocity.y > 300) {
							R.player.velocity.y = 300;
						}
						R.player.velocity.y /= 4;
						R.player.velocity.x += R.player.velocity.y * zar * -1;
					}
					if (!is_conveyer && R.player.velocity.x < -zmv) {
						R.player.velocity.x = -zmv;
					}
				}
				
				//Log.trace(zmvx);
				if (zar == 1) {
					if (h_array[0] > 0 && R.player.velocity.x < 0) {
						R.player.velocity.x /= 2;
					} else if (h_array[0] < 0 && R.player.velocity.x > 0) {
						R.player.velocity.x /= 2;
					}
				}
				zivx = R.player.velocity.x;
				//zivy = R.player.velocity.y;
				// Set the equal y velocity
				//r = R.player.velocity.x / zmvx;
				// IF DOWNWARDS
				//R.player.velocity.y = r * zmvy;
				
				//Log.trace([R.player.velocity.x, R.player.velocity.y]);
			}
		} else if (zipline_mode == 1) {
			//Log.trace([zivx, zmvx]);
			
			R.player.velocity.x = zivx;
			
			/* Update as conveyer */
			if (is_conveyer) {
				
				if (R.player.velocity.x  < zmv) {
					R.player.velocity.x += FlxG.elapsed * base_accel;
					if (R.player.velocity.x >= zmv) {
						R.player.velocity.x = zmv;
					}
				} else if (R.player.velocity.x > zmv) {
					R.player.velocity.x -= FlxG.elapsed * base_accel;
					if (R.player.velocity.x <= zmv) {
						R.player.velocity.x = zmv;
					}
				}
				zivx = R.player.velocity.x;
				
			/* Update as zipline */
			} else {
			
			
			if (zar == 0) {
				var q:Float = R.player.velocity.x;
				q *= 0.95;
				if (Math.abs(q) < 15) {
					q = 0;
					R.player.skip_motion_ticks = 1;
				}
				R.player.velocity.x = q;
			} else if (h_array[0] > 0) { 
				R.player.velocity.x += base_accel * zar * FlxG.elapsed;
				if (R.player.velocity.x < 0) {
					if (zar != 1) {
						R.player.velocity.x += base_accel * 2 * zar * FlxG.elapsed;
					}
				}
				if (R.player.velocity.x > zmv) R.player.velocity.x = zmv;
			} else {
				R.player.velocity.x -= base_accel * zar * FlxG.elapsed;
				if (R.player.velocity.x > 0) {
					if (zar != 1) { // 45 deg slope already slows you initially enough 
						R.player.velocity.x -= base_accel * 2 * zar * FlxG.elapsed;
					}
				}
				if (R.player.velocity.x < -zmv) R.player.velocity.x = -zmv;
			}
			zivx = R.player.velocity.x; // huh..
			}
			
			// Set Y position
			var r:Float = 0;
			r = Math.abs(((zipline_box.x + 1) - (ix + pts[0].x)) / w_array[0]);
			r = r * h_array[0] + (iy + pts[0].y); // r is now the correct y pos
			zipline_box.y = r - 1; // set the boxx there
			R.player.y = R.player.last.y = zipline_box.y - zsyo; // set the player
			R.player.y = R.player.last.y = R.player.y - 4;
			R.player.velocity.y = 0;
			// Check for falloff condition
			if (R.player.get_shield_dir() != 0 || !HF.ray_intersects_box(ix + pts[0].x, iy + pts[0].y, w_array[0], h_array[0], zipline_box, 1)) {
				//Log.trace("off");
				zipline_mode = 0;
				R.player.velocity.y = Math.abs(R.player.velocity.x  / zmv) * zmvy;
			} else if (R.input.jpA1) {
				zipline_mode = 0;
				R.player.velocity.y = R.player.get_base_jump_vel();
			}
		}
		
		
	}
}