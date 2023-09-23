package entity.npc;

import entity.MySprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import state.MyState;

class Pendulum extends MySprite
{

	private var pt:FlxPoint;
	private var vine_sprite:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		pt = new FlxPoint();
		vine_sprite = new FlxSprite();
		line = new FlxSprite();
		line.makeGraphic(1, 1, 0xffffffff);
		line.origin.set(0, 0);
		super(_x, _y, _parent, "Pendulum");
	}
	private var animarray:Array<String>;
	private var whattoplay:Array<String>;
	private var hasvine:Bool = false;
	override public function change_visuals():Void 
	{
		if (vistype == 1) vistype = 0;
		switch (vistype) {
			case 0:
				if (props.get("vine_set").length > 1) {
					hasvine = true;
					
					AnimImporter.loadGraphic_from_data_with_id(vine_sprite, 1, 1, name, "vine_" + props.get("vine_set"));
					animarray = AnimImporter.get_Animations_array(name, "vine_" + props.get("vine_set"), "bottom_"); 
					//Log.trace(animarray);
					AnimImporter.loadGraphic_from_data_with_id(this, 1, 1, name, "vine_"+props.get("vine_set"));
					whattoplay = [];
					for (i in 0...animarray.length) {
					}
					for (i in 0...nr_vine) {
						var idx:Int = Std.int(Math.random() * animarray.length);
						whattoplay.push(animarray[idx]);
					}
				} else {
					hasvine = false;
					vine_sprite.exists = false;
					AnimImporter.loadGraphic_from_data_with_id(this, 1, 1, name, "0");
				}
				//makeGraphic(8, 8, 0xffff0000);
			default:
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("anim_name", "test_star");
		p.set("l", 16 * 6);
		p.set("line_alpha", 0.8);
		p.set("line_rgb", "0xffffff");
		p.set("extra_len", 1);
		p.set("vine_set", "0");
		p.set("nr_vine", 5);
		p.set("upside_down", 0);
		p.set("no_y_movement", 0);
		return p;
	}
	
	private var l:Float = 0;
	private var nr_vine:Int = 0;
	private var no_y_movement:Bool = false;
	private var upside_down:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		l = props.get("l");
		nr_vine = props.get("nr_vine");
		upside_down = props.get("upside_down") == 1;
		no_y_movement = props.get("no_y_movement") == 1;
		
		change_visuals();
		animation.play(props.get("anim_name").toLowerCase());
		extra_len = props.get("extra_len");
		line.alpha = props.get("line_alpha");
		line.color = Std.parseInt(props.get("line_rgb"));
		width = height = 10;
		offset.x = (frameWidth - width) / 2;
		
		
	}
	
	override public function destroy():Void 
	{
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [line,vine_sprite]);
		super.destroy();
	}
	
	private var _origin:FlxPoint;
	private var t:Float = 0;
	private var g:Float = 350;
	private var time_scaling:Float = 1;
	private var theta_max:Float = 0;
	private var init_pi:Float = 0;
	private var extra_len:Float = 0;
	
	private var line:FlxSprite; 
	private var overlapping:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [line,vine_sprite]);
		}
		// origin stores position of 1x1 line sprite which is scaled to make the string/vine
		if (_origin == null) {
			if (upside_down) {
				_origin = new FlxPoint(x + width / 2, y + l);
			} else {
				_origin = new FlxPoint(x + width / 2, y - l);
			}
		}
		
		_origin.x = ix + width / 2;
		if (upside_down) {
			_origin.y = iy + l;
		} else {
			_origin.y = iy - l;
		}
		
		line.x = _origin.x;
		line.y = _origin.y;
		
		if (upside_down) {
			line.scale.y = - (l + extra_len - 4);
		} else { 
			line.scale.y = l + extra_len;
		}
		
		var gfac:Float = Math.sqrt(g / l);
		if (theta_max == 0) {
			t = 0; 
		} else {
			t += FlxG.elapsed * time_scaling;
			if (t > (3.14159 * 2)/gfac) {
				t -= (3.14159 * 2) / gfac;
			}
			//Log.trace([Math.sin(gfac * t), t]);
		}
		var theta:Float = 0;
		theta = theta_max * Math.sin(gfac * t);
		//Log.trace([t, theta, theta_max]);
		
		line.angle = -theta;
		
		if (upside_down) line.angle *= -1;
		if (overlapping == false && (R.player.overlaps(this) || (hasvine && vine_overlaps()))) {
			// If it is at rest (theta_max = 0) or it is swinging but really close to 0 (theta_max < 2) and it hasn't just started swinging (t > 0.25) then swing it again
			overlapping = true;
			if (theta_max == 0) {
				if (R.player.velocity.x > 0) {
					theta = t = 0;
					theta_max = R.player.velocity.x / 4.0;
				} else if (R.player.velocity.x < 0) {
					theta = t = 0;
					theta_max = Math.abs(R.player.velocity.x) / 4.0;
					t = 3.14 / (Math.sqrt(g / l));
				}
				
				theta_max *= (0.9 + 0.2 * Math.random());
				if (theta_max > 50) theta_max = 50;
			// if already swinging and not at rest, edpengin on the pendulum direction and player direction,
			// figure out the new 'time' the parametrically defined angle should start at. smoetimes
			// we need to flip angle phase to fix this. look in notebook for image
			} else if (Math.abs(R.player.velocity.x) > 30) {
				
				var tmax:Float = (3.14159 * 2) / gfac;
				var theta2:Float  = theta_max * Math.sin(gfac * (t + FlxG.elapsed * time_scaling));
				// find angular rate ofo change
				
				var pv:Float = R.player.velocity.x;
				// going tot her ight
				if (theta2 >= theta) {
					if (pv > 0) {
						theta_max += pv / 6.0;
						if (theta_max > 50) theta_max = 50;
						t = (Math.asin(theta / theta_max)) / Math.sqrt(g / l);	
					} else {
						var new_theta_max:Float = -R.player.velocity.x / 4.0;
						if (Math.abs(theta) >= Math.abs(new_theta_max)) {
							//ignore it bc it'll cause bugs
						} else {
							theta_max = new_theta_max;
							if (theta_max >= 50) theta_max = 50;
							//Log.trace("pendulum moving rigiht, player left");
							//Log.trace([t, tmax]);
							t = (Math.asin(theta / theta_max)) / Math.sqrt(g / l);
							//Log.trace([t]);
							if (t <= 0.25 * tmax) {
								t = 0.5 * tmax - t;
							} else { // (if t >= 0.75*tmax)
								t = 0.5 * tmax + (tmax - t);
							}
						}
						//Log.trace([t]);
					}
				// going to the left
				} else {
					if (pv < 0) {
						//Log.trace("pendulum moving left, player left");
						//Log.trace([t, tmax]);
						theta_max -= pv / 6.0;
						if (theta_max > 50) theta_max = 50;
						t = (Math.asin(theta / theta_max)) / Math.sqrt(g / l);	
						// reconvert 
						if (t <= 0.25 * tmax) {
							t = 0.5 * tmax - t;
						} else { // (if t >= 0.75*tmax)
							t = 0.5 * tmax + (tmax - t);
						}
						//Log.trace([t]);
					} else {
						//Log.trace("pendulum moving left, player right");
						//Log.trace([t, tmax]);
						
						var new_theta_max:Float = R.player.velocity.x / 4.0;
						if (Math.abs(theta) > Math.abs(new_theta_max)) {
							//ignore it bc it'll cause bugs
						} else {
							theta_max = new_theta_max;
							if (theta_max >= 50) theta_max = 50;
							t = (Math.asin(theta / theta_max)) / Math.sqrt(g / l);
						}
						// angle back to -pi/2,pi/2
						// dont need this conversion?
						//if (t <= 0.5 * tmax) {
							//t = 0.5 * tmax - t;
						//} else {
							//t = (0.75 * tmax - t) + 0.75 * tmax;
						//}	
						//Log.trace([t]);
					}
					
				}
			}
		} else {
			if (hasvine) {
				if (!vine_overlaps()) {
					overlapping = false;
				}
			} else if (R.player.overlaps(this) == false) {
				overlapping = false;
			}
		}
		
		pt.x = _origin.x + l * Math.sin(theta * (6.28 / 360.0));
		if (no_y_movement) {
			if (upside_down) {
				pt.y = _origin.y - l;
			} else {
				pt.y = _origin.y + l;
			}
		} else {
			if (upside_down)  {
				pt.y = _origin.y - l * Math.cos(theta * (6.26 / 360.0));
			} else {
				pt.y = _origin.y + l * Math.cos(theta * (6.26 / 360.0));
			}
			
		}
		x = pt.x - width / 2;
		y = pt.y;
		
		if (theta_max > 0.5) {
			theta_max *= 0.998; 
		} else {
			theta_max = 0;
		}
		
		
		//if (FlxG.keys.pressed.UP) {
			//g ++;
			//Log.trace(g);
		//} else if (FlxG.keys.pressed.DOWN) {
			//g--;
			//Log.trace(g);
		//}
		//
		//if (FlxG.keys.pressed.LEFT) {
			//time_scaling -= 0.01;
			//Log.trace(time_scaling);
		//} else if (FlxG.keys.pressed.RIGHT) {
			//time_scaling += 0.01;
			//Log.trace(time_scaling);
		//}
		//
		//if (FlxG.keys.pressed.A) {
			//l --; 
			//Log.trace(l);
		//} else if (FlxG.keys.pressed.S) {
			//l++;
			//Log.trace(l);
		//}
		super.update(elapsed);
		
	}
	
	override public function recv_message(message_type:String):Int 
	{
		if (upside_down && message_type == C.MSGTYPE_MOVED_BY_EDITOR) {
			
		}
		return 1;
	}
	
	private function vine_overlaps():Bool {
		//return R.player.overlaps(this);
		var dx:Float = (pt.x - _origin.x) / (nr_vine);
		var dy:Float = (pt.y - _origin.y) / (nr_vine);
		//for (i in 0...nr_vine) {
		for (i in 0...1) {
			vine_sprite.x = pt.x - dx * (1+i);
			vine_sprite.y = pt.y - dy * (1+i);
			vine_sprite.x -= 16;
			
			var b:Bool = false;
			var oh:Float = vine_sprite.height;
			var ow:Float = vine_sprite.width;
			vine_sprite.width /= 2;
			vine_sprite.height /= 2;
			vine_sprite.x += ow / 4;
			vine_sprite.y += oh / 4;
			if (vine_sprite.overlaps(R.player)) {
				b = true;
			}
			
			vine_sprite.width = ow;
			vine_sprite.height = oh;
			return b;
		
		}
		return false;
	}
	override public function draw():Void 
	{
		
		
		if (hasvine) {
		if (nr_vine == 0) {
			vine_sprite.exists = false;
		} else {
			vine_sprite.exists = true;
			vine_sprite.visible = false;
			if (pt != null && _origin != null) {
				var dx:Float = (pt.x - _origin.x) / (nr_vine+1);
				var dy:Float = (pt.y - _origin.y) / (nr_vine+1);
				for (i in 0...nr_vine) {
					if (whattoplay != []) {
						vine_sprite.animation.play(whattoplay[i]);
					}
					vine_sprite.x = pt.x - dx * (1+i);
					vine_sprite.y = pt.y - dy * (1+i);
					vine_sprite.x -= 16;
					vine_sprite.draw();
				
				}
			}
		}
			super.draw();
		} else {
			super.draw();
		}
		
	}
}