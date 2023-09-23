package entity.tool;

import entity.MySprite;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import haxe.Log;
import help.HelpTilemap;
import help.HF;
import openfl.geom.Point;
import state.MyState;
/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class LightBox extends MySprite
{

	public static var ACTIVE_LightBoxes:List<LightBox>;
	
	public var shape_type:Int = 0;
	public var TYPE_RECTANGLE:Int = 0;
	public var TYPE_PARALLELOGRAM:Int = 1;
	public var TYPE_CIRCLE:Int = 2;
	
	
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		
		r = new FlxObject(0, 0, 1, 1);
		gas_particle = new FlxSprite();
		super(_x, _y, _parent, "LightBox");
		makeGraphic(8, 8, 0x99ff0077);
		
	}
	
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("shapetype", 0);
		p.set("coords", "0,0,32,0,32,32,0,32");
		p.set("is_gas", 0);
		p.set("particle_color", "0xff0000");
		p.set("alpha", 0.8);
		p.set("minmax_vel", "20,30");
		p.set("density", 0.28);
		return p;
	}
	
	private var coords:Array<Point>;
	private var r:FlxObject;
	private var t_sleep:Float = 0;
	private var gas_particle:FlxSprite;
	private var particle_pos:Array<FlxPoint>;
	private var particle_vel:Array<FlxPoint>;
	private var particle_active:Array<Bool>;
	private var min_vel:Float = 0;
	private var max_vel:Float = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		shape_type = props.get("shapetype");
		coords = HF.string_to_point_array(props.get("coords"));
		if (coords.length <= 1) {
			Log.trace("error");
			// Coords, clockwise
			props.set("coords", "0,0,32,0,32,32,0,32");
			coords = HF.string_to_point_array(props.get("coords"));
		}
		if (shape_type == TYPE_PARALLELOGRAM) {
			r = new FlxObject(Math.min(coords[0].x,coords[3].x), Math.min(coords[0].y,coords[1].y), Math.max(coords[1].x,coords[2].x) - Math.min(coords[0].x,coords[3].x), Math.max(coords[2].y,coords[3].y) - Math.min(coords[1].y,coords[0].y));
			//r = new FlxObject(coords[0].x, coords[0].y, Math.abs(coords[2].x), Math.abs(coords[2].y));
		} else {
			r = new FlxObject(coords[0].x, coords[0].y, Math.abs(coords[2].x), Math.abs(coords[2].y));
		}
		change_visuals();
		var a:Array<Float> = HF.string_to_float_array(props.get("minmax_vel"));
		min_vel = a[0];
		max_vel = a[1];
		if (props.get("is_gas") == 1) {
			//gas_particle.makeGraphic(1, 1, Std.parseInt(props.get("particle_color")));
			gas_particle.makeGraphic(1, 1, 0xffffffff);
			gas_particle.color = Std.parseInt(props.get("particle_color").toLowerCase());
			gas_particle.alpha = props.get("alpha");
			is_gas = true;
			particle_pos = new Array<FlxPoint>();
			particle_vel = new Array<FlxPoint>();
			particle_active = new Array<Bool>();
			var nr:Int = 1 + Std.int((r.width * r.height / 256.0) * props.get("density"));
			for (i in 0...nr) {
				var p:FlxPoint = new FlxPoint(0, 0);
				particle_pos.push(p);
				particle_active.push(false);
				particle_vel.push(new FlxPoint(min_vel + (max_vel - min_vel) * Math.random() * (Math.random() > 0.5 ? -1 : 1), min_vel + (max_vel - min_vel) * Math.random() * (Math.random() > 0.5 ? -1 : 1)));
			}
		} else {
			is_gas = false;
		}
	}
	
	private var jp:Bool = false;
	private var pressed:Bool = false;
	private var editor_on:Bool = false;
	private var p:FlxSprite;
	private var mouse_mode:Int = 0;
	private var active_v:Int = 0;
	private var circ_draw:FlxSprite;
	private var can_update_mouse:Bool = false;
	private var is_gas:Bool = false;
	override public function draw():Void 
	{
		//visible = false;
		alpha = 0;
		can_update_mouse = true;
		
		// draw gas
		// sleep?
		if (is_gas) {
			for (i in 0...particle_pos.length) {
				if (particle_active[i] == false) {
					continue;
				}
				//Log.trace([gas_particle.x,gas_particle.y,gas_particle.color,gas_particle.alpha]);
				gas_particle.x = particle_pos[i].x;
				gas_particle.y = particle_pos[i].y;
				gas_particle.draw();
			}
		}
		if (R.editor.editor_active) {
			
			//FlxG.log.clear();
			//FlxG.log.add(pt_inside(FlxG.mouse.x, FlxG.mouse.y));
			
			alpha = 1;
			FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 0.8);
			
			
			if (editor_on) {
				if (p == null) {
					p = new FlxSprite();
					p.makeGraphic(6, 6, 0xaa00ff00);
				}
				for (i in 0...4) {
					p.x = coords[i].x + this.x;
					p.y = coords[i].y + this.y + 16;
					if (shape_type == TYPE_RECTANGLE && i == 2) {
						p.draw(); 
					} else if (shape_type == TYPE_PARALLELOGRAM) {
						p.draw();
					} else if (shape_type == TYPE_CIRCLE && i == 1) {
						p.draw();
					} else {
						continue;
					}
					if (mouse_mode == 0) {
						if (jp && FlxG.mouse.inside(p)) {
							mouse_mode = 1;
							active_v = i;
						}
					} else if (mouse_mode == 1) {
						if (pressed == false) {
							mouse_mode = 0;
							props.set("coords", HF.point_array_to_string(coords));
						} else {
							if (shape_type == TYPE_RECTANGLE) {
								coords[active_v].x = Math.fround(FlxG.mouse.x - this.x);
								coords[active_v].y = Math.fround(FlxG.mouse.y - this.y - 16);
								coords[1].x = coords[2].x;
								coords[3].y = coords[2].y;
							} else if (shape_type == TYPE_PARALLELOGRAM) {
								coords[active_v].x = Math.fround(FlxG.mouse.x - this.x);
								coords[active_v].y = Math.fround(FlxG.mouse.y - this.y - 16);
							} else if (shape_type == TYPE_CIRCLE) {
								coords[active_v].x = Math.fround(FlxG.mouse.x - this.x);
								if (coords[active_v].x < 1) coords[active_v].x = 1;
							}
						}
					}
				}
			} else {
				if (jp && FlxG.mouse.inside(this)) {
					editor_on = true;
					Log.trace("editor on!");
				}
			}
			//draw the debug box lower
			y += 16;
			if (shape_type == TYPE_RECTANGLE || shape_type == TYPE_PARALLELOGRAM) {
				var l:Int = coords.length;
				for (i in 0...coords.length) {
					FlxG.camera.debugLayer.graphics.moveTo(x+ coords[i].x - FlxG.camera.scroll.x, y+coords[i].y - FlxG.camera.scroll.y);
					FlxG.camera.debugLayer.graphics.lineTo(x+ coords[(i+1)%l].x - FlxG.camera.scroll.x, y+coords[(i+1)%l].y - FlxG.camera.scroll.y);
				}
			} else if (shape_type == TYPE_CIRCLE) {
				for (i in 0...1) {
					FlxG.camera.debugLayer.graphics.moveTo(x+ coords[i].x - FlxG.camera.scroll.x, y+coords[i].y - FlxG.camera.scroll.y);
					FlxG.camera.debugLayer.graphics.lineTo(x+ coords[i+1].x - FlxG.camera.scroll.x, y+coords[i+1].y - FlxG.camera.scroll.y);
				}
				FlxG.camera.debugLayer.graphics.drawCircle(x + coords[0].x- FlxG.camera.scroll.x, y + coords[0].y- FlxG.camera.scroll.y,coords[1].x);
			}
			y -= 16;
		} else {
			if (editor_on) {
				editor_on = false;
				Log.trace("editor off!");
			}
		}
		super.draw();
	}
	
	override public function destroy():Void 
	{
		ACTIVE_LightBoxes.remove(this);
		NONSLEEPING_LightBoxes.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [gas_particle]);
		super.destroy();
	}
	
	
	
		//The second approach is to go around the polygon in order and for every pair of vertices vi and vi+1 (wrapping around to the first vertex if necessary), compute the quantity (x - xi) * (yi+1 - yi) - (xi+1 - xi) * (y - yi). If these quantities all have the same sign, the point is inside the polygon. (These quantities are the Z component of the cross product of the vectors (vi+1 - vi) and (p - vi). The condition that they all have the same sign is the same as the condition that p is on the same side (left or right) of every edge.)
	public function pt_inside(px:Float, py:Float):Bool {
		px -= this.x;
		py -= this.y;
		py -= 16;
		//Log.trace("hi");
		//Log.trace([px, py, r.x, r.y, r.width, r.height]);
		if (shape_type == TYPE_RECTANGLE) {
			return (px > r.x) && (px < r.x + r.width) && (py > r.y) && (py < r.y + r.height);
		} else if (shape_type == TYPE_CIRCLE) {
			var r:Float = coords[1].x;
			var _x:Float = coords[0].x;
			var _y:Float = coords[0].y;
			return (px - _x) * (px - _x) + (py - _y) * (py - _y) < r * r;
		} else if (shape_type == TYPE_PARALLELOGRAM) {
			var prev_sign_pos:Bool = false;
			for (i in 0...4) {
				if ((px - coords[i].x) * (coords[(i + 1) % 4].y - coords[i].y) - (coords[(i + 1) % 4].x - coords[i].x) * (py - coords[i].y) > 0) {
					if (i == 0) {
						prev_sign_pos = true;
					} else {
						if (prev_sign_pos) {
							continue;
						} else {
							return false;
						}
					}
				} else {
					if (i == 0) {
						prev_sign_pos = false;
					} else {
						if (!prev_sign_pos) {
							continue;
						} else {
							return false;
						}
					}
				}
			}
			return true;
		}
		return false;
	}
	public static var NONSLEEPING_LightBoxes:List<LightBox>;
	override public function update(elapsed: Float):Void 
	{
		if (can_update_mouse) {
			jp = FlxG.mouse.justPressed;
			pressed = FlxG.mouse.pressed;
			can_update_mouse = false;
		}
		if (!did_init) {
			did_init = true;
			ID = 0;
			if (props.get("is_gas") == 0) {
				NONSLEEPING_LightBoxes.add(this);
				ACTIVE_LightBoxes.add(this);
			} else {
				HF.add_list_to_mysprite_layer(this, parent_state, [gas_particle]);
			}
		}
		t_sleep += FlxG.elapsed;
		if (t_sleep > 1) {
			t_sleep = 0;
			if (ID == 0) { // not sleepong
				var o:FlxObject = new FlxObject(FlxG.camera.scroll.x, FlxG.camera.scroll.y, FlxG.camera.width, FlxG.camera.height);
				r.x += x;
				r.y += y + 16;
				if (r.overlaps(o) == false) {
					NONSLEEPING_LightBoxes.remove(this);
					ID = 1;
					//Log.trace(NONSLEEPING_LightBoxes.length);
					//Log.trace("sleep");
				}
				r.x -= x;
				r.y -= y + 16;
			} else {
				var o:FlxObject = new FlxObject(FlxG.camera.scroll.x, FlxG.camera.scroll.y, FlxG.camera.width, FlxG.camera.height);
				r.x += x;
				r.y += y + 16;
				if (r.overlaps(o) == true) {
					NONSLEEPING_LightBoxes.add(this);
					ID = 0;
					//Log.trace(NONSLEEPING_LightBoxes.length);
					//Log.trace("unsleep");
				}
				r.x -= x;
				r.y -= y + 16;
			}
		}
		
		if (ID == 0 && is_gas) { // not sleeping, update gas pos
			var tt:Int = 0;
			var ar:Array<Int> = HelpTilemap.active_gas;
			var tm:FlxTilemapExt = parent_state.tm_bg;
			for (i in 0...particle_pos.length) {
				tt = tm.getTileID(particle_pos[i].x, particle_pos[i].y);
				//if (!pt_inside(particle_pos[i].x, particle_pos[i].y)) {
				// If not touching gas, spawn randomly in the lightbox rectangle.
				if (Lambda.indexOf(ar, tt) == -1) {
					particle_active[i] = false;
					particle_pos[i].x = this.x + r.width * Math.random();
					particle_pos[i].y = this.y + r.height * Math.random() + 16;
					particle_vel[i].x = min_vel + (max_vel - min_vel) * Math.random() * (Math.random() > 0.5 ? -1 : 1);
					particle_vel[i].y = min_vel + (max_vel - min_vel) * Math.random() * (Math.random() > 0.5 ? -1 : 1);
					if (Math.random() > 0.5) particle_vel[i].x *= -1;
					if (Math.random() > 0.5) particle_vel[i].y *= -1;
				} else {
					particle_active[i] = true;
					particle_pos[i].x += FlxG.elapsed * particle_vel[i].x;
					particle_pos[i].y += FlxG.elapsed * particle_vel[i].y;
				}
			}
		}
		super.update(elapsed);
	}
	
}