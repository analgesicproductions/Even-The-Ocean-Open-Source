package entity.trap;
import autom.SNDC;
import entity.MySprite;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flixel.FlxSprite;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxObject;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Wind extends MySprite
{
	public static var wind_spritesheet:BitmapData;
	public var wind_region:FlxObject;
	private var cur_energy:Int;
	
	private var drag_box:FlxSprite;
	private var wind_x:Array<Float>;
	private var wind_y:Array<Float>;
	private var wind_a:Array<Float>;
	private var wind_size:Array<Float>;
	private var windblock:FlxSprite;
	private var fadeout_windblock:Bool = false;

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		windblock = new FlxSprite();
		drag_box = new FlxSprite();
		drag_box.makeGraphic(16, 16, 0xffff0000);
		drag_box.alpha = 0.65;
		// Init sprites here
		if (wind_spritesheet == null) {
			//wind_spritesheet = Assets.getBitmapData("assets/sprites/Trap/Wind.png");
		}
		super(_x, _y, _parent, "Wind");
		// Change visuals or add things here
		ID = 0;
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				AnimImporter.loadGraphic_from_data_with_id(windblock, 32, 32, "WindBlock");
				windblock.animation.play("blow");
				windblock.exists = false;
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Wind");
		}
		//blend = BlendMode.ADD;
	}
	
	private var needs_energy:Bool = false;
	private var tm_next_particle:Float = 0;
	private var t_next_particle:Float = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		// Set default properties here
		p.set("w", 16);
		p.set("h", 16);
		p.set("speed", 50);
		p.set("angle", 0);
		p.set("req_energy", 0); 
		p.set("global", 0);
		p.set("en_align", -1);
		p.set("invis", 0);
		p.set("tm_next_particle", 0.05);
		return p;
	}
	
	var _w:Int = 16;
	var _h:Int = 16;
	var vx:Float = 0;
	var vy:Float = 0;
	public static var last_y:Float;
	private var invis:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		_w = Std.int(props.get("w") / 16) * 16;
		_h = Std.int(props.get("h") / 16) * 16;
		props.set("w", _w);
		props.set("h", _h);
		tm_next_particle = props.get("tm_next_particle");
		if (_w <= 16) _w = 16;
		if (_h <= 16) _h = 16;
		wind_region = new FlxObject(x, y, _w, _h);
		if (props.get("req_energy") > 0) {
			needs_energy = true;
		}
		if (props.get("en_align") > -1) {
			needs_energy = true;
			cur_energy = 0;
		}
		
		vx = props.get("speed") * Math.cos((props.get("angle") / 360.0) * 2 * Math.PI);
		vy = props.get("speed") * Math.sin((props.get("angle") / 360.0) * 2 * Math.PI);
		change_visuals();
		invis = false;
		if (props.get("invis") == 1) {
			invis = true;
		}
	}
	
	override public function add_parent(parent:MySprite):Void 
	{
		super.add_parent(parent);
		if (props.get("req_energy") <= 0) {
			props.set("req_energy", 1);
		}
	}
	override public function recv_message(message_type:String):Int 
	{
		
		if (props.get("en_align") > -1) {
			if (props.get("en_align") == 0) {
				if (message_type == C.MSGTYPE_ENERGIZE_TICK_LIGHT) {
					if (cur_energy > 0) cur_energy--;
				} else {
					cur_energy++;
				}
			} else { // need light
				if (message_type == C.MSGTYPE_ENERGIZE_TICK_DARK) {
					if (cur_energy > 0) cur_energy--;
				} else {
					cur_energy++;
				}
			}
			if (cur_energy >= props.get("req_energy")) {
				cur_energy = props.get("req_energy");
				needs_energy = false;
			} else {
				needs_energy = true;
			}
		} else {
			if (message_type == C.MSGTYPE_ENERGIZE) {
				needs_energy = false;
			} else if (message_type == C.MSGTYPE_DEENERGIZE) {
				needs_energy = true;
			}
		}
		return C.RECV_STATUS_OK;
	}
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [drag_box]);
		HF.remove_list_from_mysprite_layer(this, parent_state, [windblock],MyState.ENT_LAYER_IDX_FG2);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		
		if (!did_init) {
			did_init = true;
			wind_x = [];
			wind_y = [];
			wind_a = [];
			wind_size = [];
			var windparticles:Int = Std.int((wind_region.width * wind_region.height) / 230);
			for (i in 0...windparticles) {
				wind_x.push( -1);
				wind_y.push( -1);
				wind_a.push(0);
				wind_size.push(0);
			}
			HF.add_list_to_mysprite_layer(this, parent_state, [drag_box]);
			HF.add_list_to_mysprite_layer(this, parent_state, [windblock],MyState.ENT_LAYER_IDX_FG2);
		}
		
		dragmde();
		
		if (invis) {
			if (R.editor.editor_active) {
				visible = true;
			} else {
				visible = false;
			}
		}
		
		if (needs_energy) {
			if (R.editor.editor_active) {
				visible = true;
			} else {
				visible = false;
			}
			return;
		} else {
			if (R.editor.editor_active) {
				return;
			}
			if (!invis) {
				visible = true;
			}
		}
		
		
		fadeout_windblock = true;
		if (windblock.alpha > 0) {
			if (windblock.alpha > 0.98) {
				windblock.alpha -= 0.01;
			} else {
				windblock.alpha -= 0.15;
			}
			if (windblock.alpha <= 0) {
				windblock.ID = -1;
				windblock.exists = false;
			}
		}
		wind_region.x = x;
		wind_region.y = y;
		if (props.get("global") == 1)  {
			if (p_wall == 1 ) {
				// No wind effect until touching ground or you jump off wall (so if you fall off wall no effect)
				if (R.player.is_on_the_ground(true) || R.input.jpA1) {
					p_wall = 0;
				}
			} else if (p_wall == 0) {
				var inwall:Bool = false;
				var ex:Float = 4.5;
				if (R.player.facing == FlxObject.LEFT) {
					if (parent_state.tm_bg.getTileCollisionFlags(R.player.x - 4.5, R.player.y) != 0) {
						inwall = true;
					} else if (parent_state.tm_bg.getTileCollisionFlags(R.player.x - 4.5, R.player.y + R.player.height/2) != 0) {
						inwall = true;
					} else if (parent_state.tm_bg.getTileCollisionFlags(R.player.x - 4.5, R.player.y+ R.player.height) != 0) {
						inwall = true;
					}
				} else {
					if (parent_state.tm_bg.getTileCollisionFlags(R.player.x +R.player.width+4.5, R.player.y) != 0) {
						inwall = true;
					} else if (parent_state.tm_bg.getTileCollisionFlags(R.player.x +R.player.width+4.5, R.player.y + R.player.height/2) != 0) {
						inwall = true;
					} else if (parent_state.tm_bg.getTileCollisionFlags(R.player.x +R.player.width+4.5, R.player.y+ R.player.height) != 0) {
						inwall = true;
					}
					
				}
				if (R.player.is_on_the_ground(true)) {
					inwall = false;
				}
				if (!inwall && !R.player.is_in_wall_mode()) {
					R.player.apply_wind(vx, vy);
					Wind.last_y = y;
				} else {
					p_wall = 1;
				}
			}
			
		} else if (R.player.overlaps(wind_region)) {
			
			if (Math.abs(vx) > Math.abs(vy)) {
				if (vx > 0) {
					// against
					if (R.player.velocity.x < 0 && R.input.left && R.player.get_shield_dir() % 2 == 1) {
						fadeout_windblock = false; windblock.animation.play("blow");
						if (R.player.get_shield_dir() == 3) { windblock.ID = 10; } 
						else { windblock.ID = 11; } windblock.angle = 180; }
					// Running with the wind
					if (R.player.velocity.x > 0 && R.input.right && R.player.get_shield_dir() % 2 == 1) {
						fadeout_windblock = false; windblock.animation.play("blow_flat");
						if (R.player.get_shield_dir() == 3) { windblock.ID = 12; } 
						else { windblock.ID = 13; } windblock.angle = 180; }
				} else {
					// Running against the wind
					if (R.player.velocity.x > 0 && R.input.right && R.player.get_shield_dir() % 2 == 1) {
						fadeout_windblock = false; windblock.animation.play("blow");
						if (R.player.get_shield_dir() == 1) { windblock.ID = 20; } 
						else { windblock.ID = 21; } windblock.angle = 0; }
					if (R.player.velocity.x < 0 && R.input.left && R.player.get_shield_dir() % 2 == 1) {
						fadeout_windblock = false; windblock.animation.play("blow_flat");
						if (R.player.get_shield_dir() == 1) { windblock.ID = 22; } 
						else { windblock.ID = 23; } windblock.angle = 0; }
				}
			} else {
				if (R.player.is_on_the_ground(true) == false) {
					if (vy > 0) { // downwards wind
						// against (shield up)
						if (R.player.velocity.y <= 0 && R.player.get_shield_dir() % 2 == 0 && R.player.get_shield_dir() != 4) {
							fadeout_windblock = false; windblock.animation.play("blow");
							if (R.player.get_shield_dir() == 0) { windblock.ID = 30; }
							else { windblock.ID = 31; } windblock.angle = 270;
						}
						if (R.player.velocity.y > 0 && R.player.get_shield_dir() % 2 == 0 && R.player.get_shield_dir() != 4) {
							fadeout_windblock = false; windblock.animation.play("blow_flat");
							if (R.player.get_shield_dir() == 0) { windblock.ID = 30; }
							else { windblock.ID = 31; } windblock.angle = 270;
						}
					} else { // up wind
						// against (shield down)
						if (R.player.velocity.y >= 0 && R.player.get_shield_dir() % 2 == 0 && R.player.get_shield_dir() != 4) {
							fadeout_windblock = false; windblock.animation.play("blow");
							if (R.player.get_shield_dir() == 2) { windblock.ID = 40; }
							else { windblock.ID = 41; } windblock.angle = 90;
						}
						if (R.player.velocity.y < 0 && R.player.get_shield_dir() % 2 == 0 && R.player.get_shield_dir() != 4) {
							fadeout_windblock = false; windblock.animation.play("blow_flat");
							if (R.player.get_shield_dir() == 2) { windblock.ID = 40; }
							else { windblock.ID = 41; } windblock.angle = 90;
						}
					}
				}
			}
			
			if (ID == 0) {
				R.sound_manager.play(SNDC.wind_with);
				ID++;
			} else {
				ID++;
				if (ID == 27) ID = 0;
			}
			R.player.apply_wind(vx, vy);
			Wind.last_y = y;
		} else {
			ID = 0;
		}
		
		/* Set windblock pos */
		
		if (windblock.ID == 10) { windblock.move(R.player.x - windblock.width, R.player.y - 7); }
		else if (windblock.ID == 11) { windblock.move(R.player.x - windblock.width + 5, R.player.y - 7); }
		// run with wind to right, shield left/right
		if (windblock.ID == 12) { windblock.move(R.player.x - windblock.width + 4, R.player.y - 7); }
		else if (windblock.ID == 13) { windblock.move(R.player.x- windblock.width + 8, R.player.y - 7); }
		
		if (windblock.ID == 20) { windblock.move(R.player.x + R.player.width - 1, R.player.y - 7); }
		else if (windblock.ID == 21) { windblock.move(R.player.x + R.player.width - 6, R.player.y - 7); }
		// run with wind to left, shield right/left
		if (windblock.ID == 22) { windblock.move(R.player.x + R.player.width + 1 - 2, R.player.y - 7); }
		else if (windblock.ID == 23) { windblock.move(R.player.x + R.player.width - 4 - 3, R.player.y - 7); }
		
		if (windblock.ID == 30) { windblock.move(R.player.x - 10, R.player.y - 28); if (R.player.facing == FlxObject.LEFT) windblock.x -= 3; }
		else if (windblock.ID == 31) { windblock.move(R.player.x - 10, R.player.y - 26);if (R.player.facing == FlxObject.LEFT) windblock.x -= 3; }
		
		if (windblock.ID == 40) { windblock.move(R.player.x - 11, R.player.y + 15);if (R.player.facing == FlxObject.LEFT) windblock.x -= 2; }
		else if (windblock.ID == 41) { windblock.move(R.player.x - 11	, R.player.y +11);if (R.player.facing == FlxObject.LEFT) windblock.x -= 2; }
		
		// if windblock goes off of wind region, fade out bc it looks weird
		if (windblock.overlaps(wind_region) == false) {
			fadeout_windblock = true;
		}
		//stops windblock from tracking player
		if (fadeout_windblock) {
			windblock.ID = -1;
		}
		// set to false in above code, keeps wnidblock visible and at fulla lpha
		if (!fadeout_windblock && windblock.ID != -1) {
			windblock.exists = true;
			windblock.alpha = 1;
		}
		
		super.update(elapsed);
	}
	private var p_wall:Int = 0;
	override public function draw():Void 
	{
	
		if (!did_init) return;
	
		if (R.editor.editor_active) {
			var ox:Float = drag_box.x;
			var oy:Float = drag_box.y;
			drag_box.move(x, y);
			drag_box.draw();
			drag_box.move(ox, oy);
		}
		
		// figure out angle to draw
		
		var xmul:Int = 0;
		var ymul:Int = 0;
		if (Math.abs(vx) > Math.abs(vy)) {
			if (vx > 0) {
				angle = 0;
				xmul = 1;
			} else {
				angle = 180;
				xmul = -1;
			}
		} else {
			if (vy > 0) {
			angle = 90;
				ymul = 1;
			} else {
			angle = 270;
				ymul = -1;
			}
		}
		
		var el:Float = FlxG.elapsed;
		if (FlxG.drawFramerate == 30) {
			el += FlxG.elapsed;
		}
		t_next_particle += el;
		if (t_next_particle > tm_next_particle) {
			t_next_particle -= tm_next_particle;
			for (i in 0...wind_x.length) {
				if (wind_x[i] == -1) {
					if (xmul != 0) {
						if (xmul == 1) wind_x[i] = wind_region.x - 16;
						if (xmul == -1) wind_x[i] = wind_region.x +wind_region.width;
						// weight randomized positions to be nearer to edges (easier to read)
						if (Math.random() <= 0.2) {
							if (Math.random() <= 0.5) {
								wind_y[i] = wind_region.y + (wind_region.height / 4) * Math.random();
							} else {
								wind_y[i] = wind_region.y + wind_region.height - (wind_region.height / 4) * Math.random();
							}
						} else {
							wind_y[i] = wind_region.y + wind_region.height * Math.random();
						}
						if (xmul == -1) wind_y[i] -= 14;
					} else {
						if (Math.random() <= 0.2) {
							if (Math.random() <= 0.5) {
								wind_x[i] = wind_region.x -16 + (wind_region.width / 4) * Math.random();
							} else {
								wind_x[i] = wind_region.x -16 + wind_region.width- (wind_region.width / 4) * Math.random();
							}
						} else {
							wind_x[i] = wind_region.x - 16 + wind_region.width * Math.random();
						}
						if (ymul == 1) {
							wind_y[i] = wind_region.y - 16;
						} else {
							wind_y[i] = wind_region.y +wind_region.height;
							wind_x[i] += 15;
						}
					}
					wind_a[i] = 0;
					if (Math.random() < 0.5) {
						wind_size[i] = 0;
					} else if (Math.random() < 0.6) {
						wind_size[i] = 1;
					} else {
						wind_size[i] = 2;
					}
					break;
				}
			}
		}
		
		
		
		// move each particle along at speeds depending on wind size
		var ox:Float = x;
		var oy:Float = y;
		for (i in 0...wind_x.length) {
			if (wind_x[i] != -1) {
				if (wind_size[i] == 0) {
					animation.play("s", true);
					wind_x[i] += xmul* el * 75;
					wind_y[i] += ymul* el * 75;
				} else if (wind_size[i] == 1) {
					animation.play("m",true);
					wind_x[i] += xmul * el * 110;
					wind_y[i] += ymul* el * 110;
				} else {
					animation.play("l", true);
					wind_x[i] += xmul * el * 140;
					wind_y[i] += ymul* el * 140;
					
				}
				move(wind_x[i], wind_y[i]);
				
				var ww:Bool = false;
				// parrticles fade when they begin to exit
				if (xmul == 1) {
					if (x +width> wind_region.x + wind_region.width) {
						ww = true;
					}
				} else if (xmul == -1) {
					if (x < wind_region.x ) {
						
						ww = true;
					}
					
				} else if (ymul == 1) {
					if (y +height > wind_region.y + wind_region.height) {
						
						ww = true;
					}
				} else {
					if (y < wind_region.y) {
						
						ww = true;
					}
				}
				if (ww) {
					wind_a[i] -= 0.1;
					if (wind_a[i] <= 0) {
						wind_x[i] = -1;
						wind_y[i] = -1;
					}
				} else {
					if (wind_a[i] < 1) wind_a[i] += 0.05;
				}
				alpha = wind_a[i];
				super.draw();
			}
		}
		move(ox, oy);
		
	}
	
	private var drag_mode:Int = 0;
	private function dragmde():Void 
	{
		if (R.editor.editor_active == false) {
			drag_box.exists = false;
			return;
		} else {
			if (R.editor.in_add() == false) {
				return;
			}
			drag_box.exists = true;
		}
		
		
		if (drag_mode == 0) {
			drag_box.x = x + _w - 16;
			drag_box.y = y + _h - 16;
			if (FlxG.mouse.justPressed) {
				if (FlxG.mouse.inside(drag_box)) {
					drag_mode = 1;
				}
			}
				
		} else if (drag_mode == 1) {
			drag_box.x = (Std.int(FlxG.mouse.x) - (Std.int(FlxG.mouse.x) % 16));
			drag_box.y = (Std.int(FlxG.mouse.y) - (Std.int(FlxG.mouse.y) % 16));
			if (!FlxG.mouse.pressed) {
				props.set("w", Std.int(drag_box.x - x + 16));
				props.set("h", Std.int(drag_box.y - y + 16));
				if (props.get("w") < 1) props.set("w", 1);
				if (props.get("h") < 1) props.set("h", 1);
				set_properties(props);
				drag_mode = 0;
			}
		}
	}
}