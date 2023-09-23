package help;

import entity.tool.LightBox;
import entity.tool.MyParticle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import global.C;
import global.EF;
import global.Registry;
import haxe.Log;
import openfl.display.BlendMode;
import openfl.geom.Point;
import openfl.Assets;
import sys.io.File;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class ParticleSystem extends FlxGroup
{

	
	private var anim_map:Map<String,Dynamic>; 
	private var layer_map:Map<String,Dynamic>;
	private var map_map:Map<String,Dynamic>;
	
	
	public var bg_draw_layer:FlxGroup; 
	public var fg_draw_layer:FlxGroup; //grou pof groups
	public var bfg_draw_layer:FlxGroup; // below fg1/fg2 bg layers
	private var particle_layers:Array<FlxGroup>;
	private var layer_id:Array<String>; 
	private var layer_a:List<Float>;
	private var layer_xv:List<Float>; // [min_a1,max_a1,min_a2...]
	private var layer_yv:List<Float>;
	private var layer_movetype:List<Int>;
	private var layer_light:List<Bool>;
	
	public function new(MaxSize:Int=0, _name:String="") 
	{
		super(MaxSize, _name);	
		
		bg_draw_layer = new FlxGroup();
		fg_draw_layer = new FlxGroup();
		bfg_draw_layer = new FlxGroup();
		particle_layers = new Array<FlxGroup>();
		layer_id = new Array<String>();
		layer_a = new List<Float>(); 
		layer_xv = new List<Float>(); 
		layer_yv = new List<Float>(); 
		layer_light = new List<Bool>(); 
		layer_movetype = new List<Int>(); 
		init_maps(false);
		//dusts = new Array<FlxSprite>();
			//ic = 0xdbbb77;
			//nr = 35;
		//for (i in 0...nr) {
			//dusts.push(new FlxSprite());
			//dusts[i].makeGraphic(1, 1, 0xff000000 + ic);
			//add(dusts[i]);
		//}
		
		
	}
	
	private var a_cw_90:Array<Float>;
	private var a_cw_90_target:Array<Float>;
	public function cw_90(init:Bool=false):Bool {
		
		var a:Array<MyParticle> = cast particle_layers[0].members;
		if (init) {
			a_cw_90 = [a[0].min_ixv, a[0].max_ixv, a[0].min_iyv, a[0].max_iyv];
			a_cw_90_target = [-a[0].min_iyv, -a[0].max_iyv,a[0].min_ixv, a[0].max_ixv];
		}
		
		var c:Int = 0;
		for (i in 0...4) {
			if (a_cw_90[i] < a_cw_90_target[i]) {
				a_cw_90[i]++;
			} else if (a_cw_90[i] > a_cw_90_target[i]) {
				a_cw_90[i]--;
			} else {
				c++;
			}
		}
		if (c == 4) {
			return true;
		} else {
			for (p in a) {
				var mp:MyParticle = cast p;
				mp.min_ixv = a_cw_90[0];
				mp.max_ixv = a_cw_90[1];
				mp.min_iyv = a_cw_90[2];
				mp.max_iyv = a_cw_90[3];
				if (mp.angle < 90) {
					mp.angle++;
				}
			}
		}
		return false;
	}
	public function load_system(map_name:String):Void {
		bg_draw_layer.exists = false;
		fg_draw_layer.exists = false;
		bfg_draw_layer.exists = false;
		particle_layers = new Array<FlxGroup>();
		bg_draw_layer.callAll("destroy");
		fg_draw_layer.callAll("destroy");
		bfg_draw_layer.callAll("destroy");
		bg_draw_layer.clear();
		fg_draw_layer.clear();
		bfg_draw_layer.clear();
		layer_id = new Array<String>();
		
		// Don't load map1 particles till far enough in game
		if ((map_name == "MAP1" || map_name == "WF_HI_1" || map_name == "WF_LO_0")) {
			
			
			// No rain till after geomes.
			if (Registry.R.event_state[EF.air_done] == 0) {
				return;
			} else {
				// No rain after radio tower,
				if (Registry.R.event_state[EF.radio_tower_done] == 1) {
					return;
				// Show rain if radio tower not done
				} else {
					
				}
			}
		}
		
		if (map_map.exists(map_name)) {
			//Log.trace("Particle system found!");
			var fg:Array<String> = map_map.get(map_name).get("fg");
			var bg:Array<String> = map_map.get(map_name).get("bg");
			var bfg:Array<String> = map_map.get(map_name).get("bfg");
			for (a_layer_ids in [bg,fg,bfg]) {
				for (a_layer_id in a_layer_ids.iterator()) {
					if (a_layer_id == "none") continue;
					var g:FlxGroup = new FlxGroup();
					particle_layers.push(g);
					layer_id.push(a_layer_id);
					if (layer_map.exists(a_layer_id)) {
						// movetpye, color, anims, xv_min, yv, a, p, 
						var meta:Map<String,Dynamic> = layer_map.get(a_layer_id);
						for (i in 0...meta.get("nr")) {
							var mp:MyParticle = new MyParticle();
							mp.movetype = meta.get("movetype");
							mp.needs_light = meta.get("light");
							mp.min_alpha = meta.get("a_min");
							mp.max_alpha = meta.get("a_max");
							mp.min_ixv = meta.get("xv_min");
							mp.max_ixv = meta.get("xv_max");
							if (mp.min_ixv > mp.max_ixv) {
								var __t:Float = mp.min_ixv;
								mp.min_ixv = mp.max_ixv;
								mp.max_ixv = __t;
							}
							mp.min_iyv = meta.get("yv_min");
							mp.max_iyv = meta.get("yv_max");
							if (mp.min_iyv > mp.max_iyv) {
								var __t:Float = mp.min_ixv;
								mp.min_ixv = mp.max_ixv;
								mp.max_ixv = __t;
							}
							mp.anims = meta.get("anims");
							if (i == 0) {
								//Log.trace(meta.toString());
								//Log.trace([mp.movetype, mp.needs_light, mp.min_alpha, mp.max_alpha, mp.min_ixv, mp.max_ixv, mp.min_iyv, mp.max_iyv, mp.anims]);
							}
							if (meta.exists("color")) {
								mp.makeGraphic(1, 1, 0xff000000 + meta.get("color"));
							} else {
								mp.makeGraphic(1, 1, 0xff000000);
								mp.alpha = 0;
							}
							g.add(mp);
						}
					} else {
						Log.trace("Layer ID not found - " + a_layer_id);
					}
					if (bg == a_layer_ids) {
						bg_draw_layer.exists = true;
						bg_draw_layer.add(g);
					} else if (bfg == a_layer_ids) {
						bfg_draw_layer.exists = true;
						bfg_draw_layer.add(g);
					} else {
						fg_draw_layer.exists = true;
						fg_draw_layer.add(g);
					}
					for (pl in particle_layers.iterator()) {
						pl.setAll("exists", false);
					}
				}
			}
			// Note; if i go with positions isntead of flxsprites for the particles, then the partile layers should be an ext of flxgroup that override draw 
		}
	}
	
	public function init_maps(from_dev:Bool = false):Void {
		//Log.trace("Initing particle system meta");
		var path:String = "assets/misc/particles.txt";
		var data:String = "";
		anim_map = new Map<String,Dynamic>();
		layer_map = new Map<String,Dynamic>();
		map_map = new Map<String,Dynamic>();
		if (from_dev) {
			Log.trace("particlesystem from file");
			path = C.EXT_DEV + path;
			data = File.getContent(path);
		} else {
			data = Assets.getText(path);
		}
		
		var lines:Array<String> = data.split("\n");
		for (line in lines) {
			if (line.length < 3 || line.charAt(0) == "#" || line.charAt(0) == " " || line.charAt(0) == "\t") {
				continue;
			}
			if (mode == 0) {
				if (line.indexOf("!PARTICLE_ANIMS") != -1) {
					mode = 1;
				} else if (line.indexOf("!PARTICLE_LAYERS") != -1) {
					mode = 2;
				} else if (line.indexOf("!MAP_LIST") != -1) {
					mode = 3;
				}
			} else if (mode == 1) {
				if (line.indexOf("END_PARTICLE_ANIMS") != -1) {
					mode = 0;
				} else {
					parse_anim_line(line);
				}
			} else if (mode == 2) {
				if (line.indexOf("END_PARTICLE_LAYERS") != -1) {
					mode = 0;
				} else {
					parse_layer_line(line);
				}
			} else if (mode == 3) {
				if (line.indexOf("END_MAP_LIST") != -1) {
					mode = 0;
				} else {
					parse_map_line(line);
				}
			}
		}
	}	
	
	
	private function parse_anim_line(line:String):Void {
		var a:Array<String> = HF.extract_whitespace_delim_arg(line);
		
//# ID			filename								w h		frames		frame_rate blend
//test_1			test_2x2.png							2 2		0,1			3	[0,1,2,3]
		var _blendData:Int = 0;
		if (a.length > 6) {
			_blendData = Std.parseInt(a[6]);
		}
		anim_map.set(a[0], ["assets/sprites/bg/p/" + a[1], Std.parseInt(a[2]), Std.parseInt(a[3]), HF.string_to_int_array(a[4]), Std.parseInt(a[5]),_blendData]);
	}
	
	private function parse_layer_line(line:String):Void {
		//
//rouge_1		light=1  color=0xdbbb77  nr=35  movetype=0  xv=9,14		yv=12,20	a=0.1,0.87
//test_1		light=0		anims=test_1,test_2	nr=30	p=25,75	movetype=0	xv=5,15	yv=12,20	a=0.6 draw_layer=bbg
		var a:Array<String> = HF.extract_whitespace_delim_arg(line);
		var m:Map<String,Dynamic> = new Map<String,Dynamic>();
		
		for (i in 1...a.length) {
			var key:String = a[i].split("=")[0];
			var val:String = a[i].split("=")[1];
			switch (key) {
				case "light":
					m.set("light", Std.parseInt(val));
				case "color":
					m.set("color", Std.parseInt(val.toLowerCase()));
				case "nr":
					m.set("nr", Std.parseInt(val));
				case "a":
					parse_set_range_val(val, "a", m);
				case "anims":
					m.set("anims", val.split(","));
				case "movetype":
					m.set("movetype", Std.parseInt(val));
				case "xv":
					parse_set_range_val(val, "xv", m);
				case "yv":
					parse_set_range_val(val, "yv", m);
				case "p":
						
			}
		}
		layer_map.set(a[0], m);
	}
	private function parse_map_line(line:String):Void {
		var a:Array<String> = HF.extract_whitespace_delim_arg(line);
		var m:Map<String,Dynamic> = new Map<String,Dynamic>();
		m.set("bg", a[1].split(","));
		m.set("fg", a[2].split(","));
		if (a.length < 4) {
			m.set("bfg", ["none"]);
		} else {
			m.set("bfg", a[3].split(","));
		}
		map_map.set(a[0].toUpperCase(), m);
	}
	private function parse_set_range_val(s:String, prefix:String, m:Map<String,Dynamic>):Void {
		if (s.indexOf(",") != -1) {
			m.set(prefix + "_min", Std.parseFloat(s.split(",")[0]));
			m.set(prefix + "_max", Std.parseFloat(s.split(",")[1]));
		} else {
			m.set(prefix + "_min", Std.parseFloat(s));
			m.set(prefix + "_max", Std.parseFloat(s));
		}
		//Log.trace([s, m.get(prefix + "_min"), m.get(prefix + "_max")]);
	}
	
	private var mode:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		// randomize positions
		var i:Int = 0;
		var m:Array<MyParticle> = null;
		var part:MyParticle = null;
		for (i in 0...particle_layers.length) {
			var p_layer:Array<MyParticle> = cast particle_layers[i].members;
			
			for (j in 0...p_layer.length) {
				part = p_layer[j];
				
				//Log.trace([i, part.exists, part.x, part.y, part.velocity.x, part.velocity.y]);
				/* */
				// If the particle doesn't exist (just created by load_system()) or is off_screen, move it, reset its velocity and alpha and anim
				if (part.exists == false || part.x +part.width< FlxG.camera.scroll.x || part.y + part.height< FlxG.camera.scroll.y - 16 || part.x > FlxG.camera.scroll.x + FlxG.camera.width || part.y  > FlxG.camera.scroll.y + FlxG.camera.height) {
					part.exists = true;
					
					// Play next anim maybe
					if (part.anims != null && part.anims.length > 0) {
						var next_anim:String = part.anims[Std.int(part.anims.length * Math.random())];

						if (part.animation.name != null && next_anim == part.animation.name) {
							
						} else {
							var am:Array<Dynamic> = anim_map.get(next_anim);
							part.myLoadGraphic(Assets.getBitmapData(am[0]), true, false, am[1], am[2]);
							part.animation.add(next_anim, am[3], am[4]);
							part.animation.play(next_anim, true);
							if (am[5] == 1) {
								part.blend= BlendMode.ADD;
							} else if (am[5] == 2) {
								part.blend= BlendMode.MULTIPLY;
							} else if (am[5] == 3) {
								part.blend= BlendMode.SCREEN;
							} else if (am[5] == 0) {
								part.blend= BlendMode.NORMAL;
							}
							
							
						}
//# ID			filename								w h		frames		frame_rate
//test_1			test_2x2.png							2 2		0,1			3
	//anim_map.set(a[0], ["assets/sprites/bg/p/" + a[1], Std.parseInt(a[2]), Std.parseInt(a[3]), a[4], Std.parseInt(a[5])]);
					}
					
					// Set initial conditions for movetype like velocity
					part.ID = 0;
					
					// Initial particle spawn should be random
					if (part.velocity.x == 0) {
						part.x = FlxG.camera.scroll.x + Math.random() * FlxG.camera.width;
					} 
					if (part.velocity.y == 0) {
						part.y = FlxG.camera.scroll.y + (-part.height) + Math.random() * FlxG.camera.height;
					}
					
					
					var r:Float = Math.random();
					r = 1.0 + (18.0 * r); // [1.0,10.0]
					r = 1 / r; // [1.0,.111], weighted to .111
					r -= 1/(1.0+18.0); // [0,.89] weighte dto .001
					if (part.x < FlxG.camera.scroll.x) { //weight to right of screen
						part.x = FlxG.camera.scroll.x + (FlxG.camera.width - r * 0.75 * FlxG.camera.width);
					} else if ( part.x > FlxG.camera.scroll.x + FlxG.camera.width) {
						part.x = FlxG.camera.scroll.x + r * 0.75 * FlxG.camera.width;
					} else {
						part.x = FlxG.camera.scroll.x + Math.random() * FlxG.camera.width;
					}
					
					if (part.y < FlxG.camera.scroll.y) {
						part.y = FlxG.camera.scroll.y + (FlxG.camera.height - r * 0.75 * FlxG.camera.height);
					} else if (part.y > FlxG.camera.scroll.y + FlxG.camera.height) {
						part.y = FlxG.camera.scroll.y + r * 0.75 * FlxG.camera.height;
					} else {
						part.y = FlxG.camera.scroll.y + Math.random() * FlxG.camera.height;
					}
					part.y -= part.height;
					
					if (part.movetype == 0) {
						part.velocity.x = Math.random() * (part.max_ixv - part.min_ixv) + part.min_ixv;
						if (Math.random() > 0.5) part.velocity.x *= -1;
						
						part.velocity.y = Math.random() * (part.max_iyv - part.min_iyv) + part.min_iyv;
						//if (Math.random() > 0.5) part.velocity.y *= -1;
						
						if (part.velocity.x > 0) {
							part.ID = 0;
							part.acceleration.x = -22;
						} else {
							part.ID = 1;
							part.acceleration.x = 22;
						}
						
					} else if (part.movetype == 1) { // steady mving
						part.velocity.x = Math.random() * (part.max_ixv - part.min_ixv) + part.min_ixv;
						if (Math.random() > 0.5) part.velocity.x *= -1;
						part.velocity.y = Math.random() * (part.max_iyv - part.min_iyv) + part.min_iyv;
					} else if (part.movetype == 2) { // no random x
						part.velocity.x = Math.random() * (part.max_ixv - part.min_ixv) + part.min_ixv;
						part.velocity.y = Math.random() * (part.max_iyv - part.min_iyv) + part.min_iyv;
					}
					
				
					
					part.alpha = 0; // works for needs light and doesnt need lights
				}
				/* */
				
				// Now change stuff on movement an alpha 
				if (part.needs_light) {
					var found:Bool = false;
					for (l in LightBox.NONSLEEPING_LightBoxes) {
						if (l.ID  == 0 && l.pt_inside(part.x, part.y)) {
							if (part.alpha < part.max_alpha) {
								part.alpha += 0.02;
							}
							found = true;
							break;
						} 
					}
					if (!found) {
						if (part.alpha > part.min_alpha) {
							part.alpha -= 0.02;
						} else if (part.alpha < part.min_alpha) {
							part.alpha += 0.02;
						}
					}
				} else {
					if (part.alpha < part.max_alpha) {
						part.alpha += 0.06;
					}
				}
				
				if (part.movetype == 0) {
					if (part.ID == 0) { // Accelerating left
						if (part.velocity.x < -part.max_ixv) {
							part.acceleration.x *= -1;
							part.ID = 1;
						}
					} else if (part.ID == 1) {
						if (part.velocity.x > part.max_ixv) {
							part.acceleration.x *= -1;
							part.ID = 0;
						}
					}
				}
			}
		}
		
		super.update(elapsed);
	}
	
	//public function norm(a:Int):Float {
		//return (a * 1.0 / 255.0);
	//}
	//public function overlay(bottom:Int, top:Int):Int {
		//if (bottom < 128) {
			//return Std.int(255 * (2.0 * norm(top) * norm(bottom)));
		//}  
		//return Std.int(255.0 * (1 - 2 * (1 - norm(top)) * (1 - norm(bottom))));
	//}
	
}