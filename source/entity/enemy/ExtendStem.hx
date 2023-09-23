package entity.enemy;
import autom.SNDC;
import entity.MySprite;
import entity.trap.Pew;
import flixel.FlxSprite;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import openfl.geom.Point;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class ExtendStem extends MySprite
{

	public static var ACTIVE_ExtendStems:List<ExtendStem>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		arrow = new FlxSprite();
		stem = new FlxSprite();
		l_part = new FlxSprite();
		r_part = new FlxSprite();
		n_part = new FlxSprite();
		collision_sprite = new FlxSprite();
		collision_sprite.x = _x;
		collision_sprite.y = _y;
		collision_sprite.last.set(_x, _y);
		super(_x, _y, _parent, "ExtendStem");
		immovable = true;
	}
	
	private var arrow:FlxSprite;
	private var stem:FlxSprite;
	private var l_part:FlxSprite;
	private var n_part:FlxSprite;
	private var r_part:FlxSprite;
	
	
	override public function change_visuals():Void 
	{
		
		AnimImporter.loadGraphic_from_data_with_id(arrow, 16, 16, "ExtendStem");
		AnimImporter.loadGraphic_from_data_with_id(stem, 16, 16, "ExtendStem");
		AnimImporter.loadGraphic_from_data_with_id(l_part, 16, 16, "ExtendStem");
		AnimImporter.loadGraphic_from_data_with_id(n_part, 16, 16, "ExtendStem");
		AnimImporter.loadGraphic_from_data_with_id(r_part, 16, 16, "ExtendStem");
		arrow.animation.play("arrow_off", true);
		stem.animation.play("stem", true);
		l_part.animation.play("l_off", true);
		r_part.animation.play("r_off", true);
		n_part.animation.play("n_off", true);
		makeGraphic(Std.int(tile_width * 16), 16, 0x66ff0000);
		collision_sprite.makeGraphic(Std.int(tile_width * 16), 16, 0x66ff0000);
		//visible = false;
		alpha = 0;
		collision_sprite.visible = false;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("deaccel", 150);
		p.set("accel", 70);
		p.set("tile_width", 3);
		p.set("vis-dmg", "2,2");
		p.set("angle", 315.0);
		p.set("vel", 55);
		p.set("return_vel", 35);
		p.set("tm_hurt", 0.1);
		return p;
	}
	
	private var t_hurt:Float = 0;
	private var tm_hurt:Float = 0;
	private var vel:Point;
	private var return_vel:Point;
	private var accel:Point;
	private var deaccel:Point;
	private var tile_width:Float = 0;
	public var collision_sprite:FlxSprite;
	
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		if (Std.is(props.get("vis-dmg"), String) == false) {
			props.set("vis-dmg", "0,0");
		}
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		tile_width = props.get("tile_width");
		
		vel = new Point();
		return_vel = new Point();
		accel = new Point();
		deaccel = new Point();
		
		var a:Float = props.get("angle");
		var vel_mag:Float = props.get("vel"); 
		vel.x = vel_mag * Math.cos((a / 360.0) * 2 * Math.PI); // sign matters
		vel.y = vel_mag * Math.sin((a / 360.0) * 2 * Math.PI);
		
		vel_mag  = props.get("return_vel");
		return_vel.x = vel_mag * Math.cos((a / 360.0) * 2 * Math.PI + Math.PI); // sign Matters
		return_vel.y = vel_mag * Math.sin((a / 360.0) * 2 * Math.PI + Math.PI);
		
		vel_mag = props.get("accel");
		accel.x = Math.abs(vel_mag * Math.cos((a / 360.0) * 2 * Math.PI)); // signd oesnt matter
		accel.y = Math.abs(vel_mag * Math.sin((a / 360.0) * 2 * Math.PI));
		
		vel_mag = props.get("deaccel");
		deaccel.x = Math.abs(vel_mag * Math.cos((a / 360.0) * 2 * Math.PI));
		deaccel.y = Math.abs(vel_mag * Math.sin((a / 360.0) * 2 * Math.PI));
		
		
		if (Std.int(a) == 90 || Std.int(a) == 270) {
			accel.x = deaccel.x = vel.x = return_vel.x = 0;
		}
		if (Std.int(a) == 0 || Std.int(a) == 180) {
			accel.y = deaccel.y = vel.y = return_vel.y = 0;
		}
		change_visuals();
		
		arrow.angle = a;
		t_hurt = 0;
		tm_hurt = props.get("tm_hurt");
	}
	
	override public function destroy():Void 
	{
		ACTIVE_ExtendStems.remove(this);
		stem.destroy();
		l_part.destroy();
		n_part.destroy();
		r_part.destroy();
		arrow.destroy();
		HF.remove_list_from_mysprite_layer(this, parent_state, [collision_sprite]);
		//HF.remove_list_from_mysprite_layer(this, parent_state, [stem,l_part,n_part,r_part,arrow]);
		super.destroy();
	}
	
	private var touched_tilemap:Bool = false;
	override public function preUpdate():Void 
	{
		collision_sprite.immovable = false;
		
		FlxObject.separate(parent_state.tm_bg, collision_sprite);
		FlxObject.separate(parent_state.tm_bg2, collision_sprite);
		if (collision_sprite.touching != 0) {
			touched_tilemap = true;
			x = last.x;
			y = last.y;
			velocity.set(0, 0); collision_sprite.velocity.set(0, 0);
		}else {
			touched_tilemap = false;
		}
		collision_sprite.immovable = true;
		super.preUpdate();
	}
	private var mode:Int = 0;
	private var MODE_IDLE:Int = 0;
	private var MODE_MOVING:Int = 1;
	private var wall_mode:Int = 0;
	private var stored_x:Bool = false;
	private var stored_x_offset:Float = 0;
	
	override public function draw():Void 
	{
		
		if (R.editor.editor_active == false) {
			move(collision_sprite.x, collision_sprite.y);
		} else {
			collision_sprite.x = x;
			collision_sprite.y = y;
		}
		
		
		stem.move(ix + (tile_width * 16) / 2 - (stem.width / 2), iy);
		
		stem.draw();
		
		
		arrow.y = y;
		arrow.x = x + (tile_width * 16) / 2 - (arrow.width / 2);
		
		var d:Float = HF.get_midpoint_distance(arrow, stem);
		var nrToDraw:Int = Std.int((d) / 16);
		HF.scale_velocity(arrow.velocity, stem, arrow, 16);
		stem.move(arrow.x, arrow.y);
		for (i in 0...nrToDraw) {
			stem.x -= arrow.velocity.x;
			stem.y -= arrow.velocity.y;
			stem.draw();
		}
		arrow.velocity.set(0, 0);
		
		l_part.move(x, y);
		l_part.draw();
		
		for (i in 0...Std.int(tile_width )- 1) {
			x = x + 16;
			if (i == Std.int(tile_width) - 2) {
				r_part.move(x, y);
				r_part.draw();
			} else {
				n_part.move(x, y);
				n_part.draw();
			}
		}
		x -= (tile_width - 1) * 16;
		
		arrow.draw();
	}
	private var wht:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_ExtendStems.add(this);
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [collision_sprite], true);
			collision_sprite.alpha = 0;
		}
		
		// Wall logic
		if (wall_mode == 0) {
			var b:Bool = FlxObject.separateX(collision_sprite, R.player);
			if (b) {
				if (R.player.wasTouching & FlxObject.DOWN > 0) { // do nothing
					 
				} else {
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
			//if (wall_mode == 1 && R.input.right) {
				//R.player.x = collision_sprite.x - R.player.width + 1;
				//R.player.activate_wall_hang();
			//} else if (wall_mode == 2 && R.input.left) {	
				//R.player.x = collision_sprite.x + collision_sprite.width - 1;
				//R.player.activate_wall_hang();
			//}
			
			
			if (wall_mode == 1) {
				
				if (!R.input.right) {
					wht++;
				} else {
					wht = 0;
				}
				if (wht == 15) {
					wall_mode = 0;
					R.player.x = R.player.last.x = collision_sprite.x - 1;
					R.player.velocity.x = -80;
					wht = 0;
				} else {
					R.player.x = collision_sprite.x - R.player.width + 1;
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
					R.player.x = R.player.last.x = collision_sprite.x +width+ 1;
					R.player.velocity.x = 80;
					wht = 0;
				} else {
					R.player.x = collision_sprite.x + collision_sprite.width - 1;
					R.player.activate_wall_hang();
					if (R.input.jpA1) {
						R.player.velocity.x = 80;
						R.player.x++;
						wall_mode = 0;
					}
				}
			}
			
			
			if (!R.player.is_wall_hang_points_in_object(collision_sprite)) {
				wall_mode = 0;
			}
		}
		
		
		for (pew in Pew.ACTIVE_Pews.members) {
			if (pew != null && pew.generic_overlap(collision_sprite, -1)) {
			}
		}
		
		if (mode == MODE_IDLE) {
			
				var oldallowcol:Int = R.player.allowCollisions;
				R.player.allowCollisions |= FlxObject.DOWN;
			if (iscollding()) {
				mode = MODE_MOVING;
				r_part.animation.play("r_step");
				l_part.animation.play("l_step");
				n_part.animation.play("n_step");
				arrow.animation.play("arrow_step");
			}
			
				R.player.allowCollisions = oldallowcol;
		} else if (mode == MODE_MOVING) {
			if (FlxObject.separateY(collision_sprite, R.player)) {
				
				if (r_part.animation.curAnim.finished) {
					r_part.animation.play("r_on");
					l_part.animation.play("l_on");
					n_part.animation.play("n_on");
					arrow.animation.play("arrow_on");
				}
				
				if (vel.x > 0) {
					collision_sprite.velocity.x += FlxG.elapsed * accel.x;
					if (collision_sprite.velocity.x > vel.x) {
						collision_sprite.velocity.x = vel.x;
					}
				} else {
					collision_sprite.velocity.x -= FlxG.elapsed * accel.x;
					if (collision_sprite.velocity.x < vel.x) {
						collision_sprite.velocity.x = vel.x;
					}
				}
				
				if (vel.y > 0) {
					collision_sprite.velocity.y += FlxG.elapsed * accel.y;
					if (collision_sprite.velocity.y > vel.y) {
						collision_sprite.velocity.y = vel.y;
					}
					
					R.player.velocity.y = collision_sprite.velocity.y + FlxG.elapsed * accel.y;
				} else {
					collision_sprite.velocity.y -= FlxG.elapsed * accel.y;
					if (collision_sprite.velocity.y < vel.y) {
						collision_sprite.velocity.y = vel.y;
					}
					
					R.player.velocity.y = collision_sprite.velocity.y - FlxG.elapsed * accel.y;
					
					if (parent_state.tm_bg.getTileCollisionFlags(R.player.x + R.player.width / 2, R.player.y - 3) == FlxObject.ANY || parent_state.tm_bg2.getTileCollisionFlags(R.player.x + R.player.width / 2, R.player.y - 3) == FlxObject.ANY) {
						collision_sprite.velocity.y = 0;
						collision_sprite.velocity.x = 0;
					}
				}
				
				for (e in ACTIVE_ExtendStems) {
					if (e != null && e != this) {
						if (collision_sprite.overlaps(e)) {
							collision_sprite.velocity.set(0, 0);
						}
					}
				}
				
				
				if (touched_tilemap) {
					mode = 12312312;
					collision_sprite.velocity.set(0, 0);
				} else {
					R.sound_manager.play(SNDC.extendstem_grow);
				}
				
				if (R.player.velocity.y < 0) R.player.velocity.y = 0;
				
				
				t_hurt += FlxG.elapsed;
				if (t_hurt > tm_hurt) {
					t_hurt -= tm_hurt;
					if (dmgtype == 0) {
						R.player.add_dark(1);
					} else if (dmgtype == 1) {
						R.player.add_light(1);
					}
				}
				
				if (!R.input.left && !R.input.right) {
					if (!stored_x) {
						stored_x = true;
						stored_x_offset = R.player.x - x;
					} else {
						// If you were touching a wall or whatever don't let it move your x position
						if (R.player.wasTouching & (FlxObject.LEFT | FlxObject.RIGHT) == 0) {
							R.player.x = x + stored_x_offset;
						}
					}
					
					if (R.player.velocity.x == 0) {
						if (collision_sprite.velocity.x < 0) {
							//R.player.velocity.x = -1;
						} else {
							//R.player.velocity.x = 1;
						}
					}
				} else {
					stored_x = false;
					stored_x_offset = 0;
				}
			} else {
				
				r_part.animation.play("r_step_off");
				l_part.animation.play("l_step_off");
				n_part.animation.play("n_step_off");
				arrow.animation.play("arrow_step_off");
				mode = 2;
				stored_x = false;
				stored_x_offset = 0;
			}
			
			// touching tilemap
		} else if (mode == 12312312) {
			if (!iscollding()) {
				
				r_part.animation.play("r_step_off");
				l_part.animation.play("l_step_off");
				n_part.animation.play("n_step_off");
				arrow.animation.play("arrow_step_off");
				mode = 2;
			}
		} else if (mode == 2) {
			stored_x = false;
			stored_x_offset = 0;
			if (iscollding()) {
				
				r_part.animation.play("r_step");
				l_part.animation.play("l_step");
				n_part.animation.play("n_step");
				arrow.animation.play("arrow_step");
				mode = MODE_MOVING;
				return;
			}

			if (vel.x > 0) {
				if (x <= ix) {
					collision_sprite.velocity.x = 0;
					x = ix;
				} else {
					collision_sprite.velocity.x -= FlxG.elapsed * deaccel.x;
					if (collision_sprite.velocity.x <= return_vel.x) {
						collision_sprite.velocity.x = return_vel.x;
					}
				}
			} else if (vel.x < 0) {
				if (x >= ix) {
					collision_sprite.velocity.x = 0;
					x = ix;
				} else {
					collision_sprite.velocity.x += FlxG.elapsed * deaccel.x;
					if (collision_sprite.velocity.x >= return_vel.x) {
						collision_sprite.velocity.x = return_vel.x;
					}
				}
			} else {
				if (x < ix) {
					collision_sprite.x += 20 * FlxG.elapsed;
					if (collision_sprite.x >= ix) {
						x = ix;
					}
				} else if (x > ix) {
					collision_sprite.x -= 20 * FlxG.elapsed;
					if (collision_sprite.x <= ix) {
						x = ix;
					}
				}
			}
			
			if (vel.y > 0) {
				if (y <= iy) {
					collision_sprite.velocity.y = 0;
					y = iy;
				} else {
					collision_sprite.velocity.y -= FlxG.elapsed * deaccel.y;
					if (collision_sprite.velocity.y <= return_vel.y) {
						collision_sprite.velocity.y = return_vel.y;
					}
				}
			} else if (vel.y < 0) {
				if (y >= iy) {
					collision_sprite.velocity.y = 0;
					y = iy;
				} else {
					collision_sprite.velocity.y += FlxG.elapsed * deaccel.y;
					if (collision_sprite.velocity.y >= return_vel.y) {
						collision_sprite.velocity.y = return_vel.y;
					}
				}
			} else {
				if (y < iy) {
					collision_sprite.y += 20 * FlxG.elapsed;
					if (collision_sprite.y >= iy) {
						y = iy;
					}
				} else if (y > iy) {
					collision_sprite.y -= 20 * FlxG.elapsed;
					if (collision_sprite.y <= iy) {
						y = iy;
					}
				}
			}
			if (x == ix && y == iy) {
				mode = MODE_IDLE;
				r_part.animation.play("r_off");
				l_part.animation.play("l_off");
				n_part.animation.play("n_off");
				arrow.animation.play("arrow_off");
			} else {
				R.sound_manager.play(SNDC.extendstem_retract);
			}
			
		}
		if (touched_tilemap) {
			collision_sprite.velocity.set(0, 0);
		}
		r_part.update(elapsed);
		arrow.update(elapsed);
		n_part.update(elapsed);
		l_part.update(elapsed);
		super.update(elapsed);
	}
	override public function postUpdate(elapsed):Void 
	{
		if (touched_tilemap == false) { 
			super.postUpdate(elapsed);
		} else {
			velocity.set(0, 0);
		}
	}
	function iscollding():Bool
	{
		if (FlxObject.separateY(collision_sprite, R.player) && R.player.touching != FlxObject.UP) {
			//R.sound_manager.play(SNDC.pop);
			return true;
		}
		if (wall_mode > 0) {
			//R.sound_manager.play(SNDC.pop);
			return true;
		}
		return false;
	}
}