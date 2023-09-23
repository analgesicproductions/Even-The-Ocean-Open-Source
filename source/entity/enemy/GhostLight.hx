package entity.enemy;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

import autom.SNDC;
import entity.MySprite;
import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import openfl.Assets;
import openfl.geom.Point;
import state.MyState;

class GhostLight extends MySprite
{

	public var is_ghost:Bool = false;
	public var light_radius:Float = 4;
	public var attached_light:GhostLight;
	public var mode:Int = 0;
	public var ghost_midpoint:Point;
	public var ghost_angle:Float;
	public var sigil:FlxSprite;
	public var enter_box:FlxObject;
	public var exit_box:FlxObject;
	public var sigil_mode:Int = 0;
	public var glowSprite:FlxSprite;
	public var splotchBottom:FlxSprite;
	public var splotchTop:FlxSprite;
	
	public var particles:FlxTypedGroup<FlxSprite>;
	
	
	private var t_dmg:Float = 0;
	private var tm_dmg:Float = 0;
	
	private var t_immune:Float = 0;
	private var tm_immune:Float = 0;
	
	private var t_rotate:Float = 0;
	private var tm_rotate:Float = 0;
	
	private var accel:Float = 0;
	private var deaccel:Float = 0;
	
	private var t_wait:Float = 0;
	private var tm_wait:Float = 0;
	private var target_pos:Point;
	private var target_angle:Float;
	
	private var chase_vel:Float;
	private var GHOST_MODE_INVISIBLE:Int = 0;
	private var GHOST_MODE_CHASING:Int = 1;
	private var GHOST_MODE_ON_PLAYER:Int = 2;
	private var GHOST_MODE_CIRCLING_LIGHT:Int = 3;
	private var GHOST_MODE_CIRCLING_LIGHT_INIT:Int = 4;
	private var GHOST_MODE_FADE_IN:Int = 5;
	private var GHOST_MODE_FADE_OUT:Int = 6;
	
	public static var ACTIVE_GhostLights:List<GhostLight>;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		particles = new FlxTypedGroup<FlxSprite>();
		for (i in 0...15) {
			var p:FlxSprite = new FlxSprite();
			particles.add(p);
		}
		glowSprite = new FlxSprite();
		splotchBottom = new FlxSprite();
		splotchTop = new FlxSprite();
		ghost_midpoint = new Point();
		enter_box = new FlxObject(0, 0, 16, 64);
		exit_box = new FlxObject(0, 0, 16, 64);
		sigil = new FlxSprite();
		target_pos = new Point();
		super(_x, _y, _parent, "GhostLight");
		ID = 0;
	}
	
	override public function change_visuals():Void 
	{
		AnimImporter.loadGraphic_from_data_with_id(sigil, 64, 64, "GhostLight_Sigil");
		
		for (i in 0...particles.length) {
			var p:FlxSprite = particles.members[i];
			p.myLoadGraphic(Assets.getBitmapData("assets/sprites/enemy/GhostParticle.png"), true, false, 16, 16);
			if (vistype == 0) {
				p.animation.add("a", [0]);
				p.animation.add("b", [1]);
			} else {
				p.animation.add("a", [2]);
				p.animation.add("b", [3]);
			}
			p.exists = false;
			p.alpha = 0;
			p.ID = 0;
			p.velocity.y = 0;
			p.blend = BlendMode.ADD;
		}
		
		
		if (is_ghost) {
			switch (vistype) {
				case 0:
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "GhostLight_Ghost");
					AnimImporter.loadGraphic_from_data_with_id(splotchBottom, 32, 32, "GhostLight_Ghost");
					AnimImporter.loadGraphic_from_data_with_id(splotchTop, 32, 32, "GhostLight_Ghost");
					if (1 == props.get("l_to_r")) {
						sigil.animation.play("dark_r", true);
					} else {
						sigil.animation.play("dark_l", true);
					}
				case 1:
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "GhostLight_Ghost", vistype);
					AnimImporter.loadGraphic_from_data_with_id(splotchBottom, 32, 32, "GhostLight_Ghost",vistype);
					AnimImporter.loadGraphic_from_data_with_id(splotchTop, 32, 32, "GhostLight_Ghost",vistype);
					if (1 == props.get("l_to_r")) {
						sigil.animation.play("light_r", true);
					} else {
						sigil.animation.play("light_l", true);
					}
				default:
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "GhostLight_Ghost",vistype);
					AnimImporter.loadGraphic_from_data_with_id(splotchBottom, 32, 32, "GhostLight_Ghost",vistype);
					AnimImporter.loadGraphic_from_data_with_id(splotchTop, 32, 32, "GhostLight_Ghost",vistype);
					if (1 == props.get("l_to_r")) {
						sigil.animation.play("light_r", true);
					} else {
						sigil.animation.play("light_l", true);
					}
			}
			splotchBottom.animation.play("splotchBottom");
			splotchTop.animation.play("splotchTop");
			sigil.exists = true;
			sigil.width = sigil.height = 64;
			sigil.offset.set(16, 16);
			sigil.blend = BlendMode.ADD;
			glowSprite.exists = false;
			splotchTop.exists = splotchBottom.exists = true;
			
			//animation.play("idle");
			width = height = 20;
			offset.set(6, 6);
			splotchTop.width = splotchBottom.width = width;
			splotchTop.height = splotchBottom.height = height;
			splotchTop.offset.set(offset.x, offset.y);
			splotchBottom.offset.set(offset.x, offset.y);
		} else {
			splotchTop.exists = splotchBottom.exists = false;
			glowSprite.exists = true;
			sigil.exists = false;
			switch (vistype) {
				case 0:
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "GhostLight_Light");
				case 1:
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "GhostLight_Light",0);
				default:
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "GhostLight_Light", vistype);
			}
			glowSprite.loadGraphic(Assets.getBitmapData("assets/sprites/enemy/GhostLight_Glow.png"), true, 112, 112);
			glowSprite.blend = BlendMode.ADD;
			if (mode == 0) {
				animation.play("off");
			} else {
				animation.play("on");
			}
		}
	}
	
	
	public function generic_overlap(o:FlxObject, only_dmgtype:Int = -1):Bool {
		if (mode == GHOST_MODE_FADE_IN || mode == GHOST_MODE_FADE_OUT || mode == GHOST_MODE_INVISIBLE) {
			return false;
		}
		if (this.dmgtype != only_dmgtype && only_dmgtype != -1) { //1 only light breaks
			return false;
		} 
		
		if (this.overlaps(o)) {
			return true;
		}
		
		return false;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("is_ghost", 0);
		p.set("tm_hurt", 0.08);
		p.set("vel_chase", 200);
		p.set("light_radius", 48);
		p.set("light_is_on", 1);
		p.set("tm_immune", 1);
		p.set("l_to_r", 1);
		p.set("accel", 400);
		p.set("deaccel", 400);
		p.set("tm_rotate", 0.5);
		p.set("tm_wait", 0.2);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		is_ghost = props.get("is_ghost") == 1;
		light_radius = props.get("light_radius");
		chase_vel = props.get("vel_chase");
		tm_dmg = props.get("tm_hurt");
		tm_immune = props.get("tm_immune");
		tm_rotate = props.get("tm_rotate");
		accel = props.get("accel");
		deaccel = props.get("deaccel");
		tm_wait = props.get("tm_wait");
		
		mode = 0;
		if (!is_ghost && props.get("light_is_on") == 1) {
			mode = 1;
		}
		change_visuals();
		if (did_light_init) {
			x = ix;
			y = iy;
		}
		t_immune = tm_immune;
		did_light_init = false;
	}
	
	override public function preUpdate():Void 
	{
		
		if (ID != -1 && HF.array_contains(HelpTilemap.active_sand, parent_state.tm_bg2.getTileID(this.x + width / 2, this.y + height / 2))) {
			x = last.x;
			y = last.y;
			
				ID = -1;
				
				//mode = GHOST_MODE_FADE_OUT;
				velocity.set(0, 0);
				acceleration.set(0, 0);
				t_wait = 0; t_rotate = 0;
				drag.set(0, 0);
				animation.play("chase");
				
				//acceleration.set(0, 0);
			//if (mode == GHOST_MODE_ON_PLAYER) {
				//mode = GHOST_MODE_CHASING;
			//}
		} else {
			if (ID == -1 && target_vel != null) {
				this.x += width / 2; this.y += height / 2;
				R.player.x += R.player.width / 2; R.player.y += R.player.height / 2;
				HF.scale_velocity(target_vel, this, R.player, 240);
				 
				if (!HF.array_contains(HelpTilemap.active_sand, parent_state.tm_bg2.getTileID(this.x + FlxG.elapsed * target_vel.x , this.y + FlxG.elapsed * target_vel.y ))) {
					ID = 0;
				}
				
				this.x -= width / 2; this.y -= height / 2;
				R.player.x -= R.player.width / 2; R.player.y -= R.player.height / 2;
			}
			
		}
		super.preUpdate();
	}
	override public function destroy():Void 
	{
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [sigil,particles,splotchBottom,splotchTop]);
		HF.remove_list_from_mysprite_layer(this, parent_state, [glowSprite],MyState.ENT_LAYER_IDX_FG2);
		ACTIVE_GhostLights.remove(this);
		sigil.destroy(); glowSprite.destroy();
		splotchTop.destroy(); splotchBottom.destroy();
		super.destroy();
	}
	private var did_light_init:Bool = false;
	
	public function kill_from_newcamtrig():Void {
		if (is_ghost && mode != GHOST_MODE_INVISIBLE) {
			ID = 0;
			mode = GHOST_MODE_FADE_OUT;
			animation.play("off");
 			velocity.set(0, 0);
			acceleration.set(0, 0);
		}
	}
	
	override public function update(elapsed: Float):Void 
	{
		
		if (!did_light_init) {
			did_light_init = true;
			//if (!is_ghost) {
			//} else {
				//ACTIVE_GhostLights.remove(this);
			//}
		}
		if (!did_init) {
			did_init = true;
				ACTIVE_GhostLights.add(this);
			target_vel = new FlxPoint();
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [sigil]);
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [particles,splotchBottom, splotchTop]);
			splotchBottom.ID = splotchTop.ID = 0;
			HF.add_list_to_mysprite_layer(this, parent_state, [glowSprite],MyState.ENT_LAYER_IDX_FG2);
		}
		
		sigil.x = ix - 24 -8;
		sigil.y = iy - 24 -8;
		
		
		if (is_ghost) {
			update_ghost();
		} else {
			update_light();
			glowSprite.move(x + width / 2 - glowSprite.width / 2, y + height / 2 - glowSprite.height / 2);
			if (glowSprite.ID == -1) {
				glowSprite.alpha *= 0.997;
				if (glowSprite.alpha <= 0.7) {
					glowSprite.ID = 0;
				}
			} else {
				glowSprite.alpha *= 1.003;
				if (glowSprite.alpha >= 1) {
					glowSprite.ID = -1;
				}
			}
			//Log.trace(glowSprite.alpha);
		}
		super.update(elapsed);
	}
	
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == C.MSGTYPE_ENERGIZE_TICK_LIGHT || message_type == C.MSGTYPE_ENERGIZE_LIGHT) {
			//if (dmgtype == 0) {
				//mode = 0;
			//} else {
				//mode = 1;
			//}
			mode = 1;
			animation.play("on");
		} else if (message_type == C.MSGTYPE_ENERGIZE_TICK_DARK || message_type == C.MSGTYPE_ENERGIZE_DARK) {
			//if (dmgtype = 0) { // Dark lantern, gets dark, stay on
				//
				//mode = 1;
			//} else {
				//mode = 0;
			//}
			mode = 0;
			animation.play("off");
		}
		return 1;
	}
	public var has_player:Bool = false;
	
	private var target_vel:FlxPoint;
	private function update_light():Void {
		if (mode == 0) {
			has_player = false;
		} else if (mode == 1) {
			if (HF.get_midpoint_distance(R.player, this) < light_radius) {
				has_player = true;
			} else {
				has_player = false;
			}
		}
	}
	private var t_particle:Float = 0;
	private function update_ghost():Void {
		
		//if (R.player.x < x + width / 2) {
			//scale.x = -1;
		//} else if (R.player.x > x + 2 + width / 2) {
			//scale.x = 1;
		//}
		
		
		if (mode == GHOST_MODE_INVISIBLE || mode == GHOST_MODE_FADE_OUT) {
			var p:FlxSprite = null;
			for (i in 0...particles.length) {
				p = particles.members[i];
				if (p.exists) {
					p.alpha -= 0.02;
					if (p.alpha <= 0) {
						p.velocity.y = 0;
						p.exists = false;
					}
				}
			}
		} else {
			t_particle += 0.0167;
			var p:FlxSprite = null;
			// show partciels faster when moving or circling, slower when idle
			if (((velocity.x != 0 || velocity.y != 0 || mode==GHOST_MODE_CIRCLING_LIGHT) && t_particle > 0.065) || t_particle > 0.75) {
				t_particle = 0;
				for (i in 0...particles.length) {
					p = particles.members[i];
					if (!p.exists) {
						if (Math.random() > 0.5) { p.animation.play("a");
						} else { p.animation.play("b"); }
						p.width = p.height = 2; p.alpha = 0;
						p.offset.set(7, 7); p.ID = 0; p.velocity.y = -30-35*Math.random(); p.exists = true;
						p.x = x + (width - 2) * Math.random();
						p.y = y + (height - 2) * Math.random();
						break;
					}
				}
			}
			
			for (i in 0...particles.length) {
				p = particles.members[i];
				if (p.exists) {
					if (p.ID == 0) {
						p.alpha += 1.0 / 10.0;
						p.alpha *= 1.06;
						if (p.alpha >= 1) {
							p.ID = 1;
						}
					} else if (p.ID == 1) {
						p.alpha -= 1.0/23.0;
						if (p.alpha <= 0) {
							p.velocity.y = 0;
							p.exists = false;
						}
					}
				}
			}
		}
		
			//Log.trace([mode, x, y, ghost_angle]);
		
		if (mode == GHOST_MODE_INVISIBLE) {
			// Overlap -> fade_in
			if (R.editor.editor_active == false) {
				alpha = 0;
				splotchTop.alpha = splotchBottom.alpha = 0;
			}

			width += 16;
			height += 16;
			x -= 16;
			y -= 16;
			
			
			if (props.get("l_to_r") == 0) {
				exit_box.move(sigil.x - enter_box.width, sigil.y);
				enter_box.move(sigil.x +sigil.width, sigil.y);
			} else {
				enter_box.move(sigil.x - enter_box.width, sigil.y);
				exit_box.move(sigil.x +sigil.width, sigil.y);
			}
			
			if (sigil_mode == 0) {
				if (sigil.alpha > 0.2) {
					sigil.alpha -= 0.02;
				}
				if (R.player.overlaps(enter_box)) {
					sigil_mode = 1;
				}
			} else if (sigil_mode == 1) {
				sigil.alpha += 0.02;
				if (props.get("l_to_r") == 1) {
					if (R.player.x + R.player.width < enter_box.x) {
						sigil_mode = 0;
					}
				} else {
					if (R.player.x > enter_box.x + enter_box.width) {
						sigil_mode = 0;
					}
				}
				if (R.player.overlaps(exit_box)) {
					sigil_mode = 0;
					mode = GHOST_MODE_FADE_IN;
					R.sound_manager.play(SNDC.rlaser_shield);
					alpha = 0;
					//animation.play("on", true);
					animation.play("chase");
					x -= 9;
					y -= 9;
					// sfx laugh?
				}
				
			}
			width -= 16;
			height -= 16;
			x += 16;
			y += 16;
			
		} else if (mode == GHOST_MODE_FADE_IN) {
			// fade_in -> chase
			alpha += 0.03;
			splotchBottom.alpha = splotchTop.alpha = alpha;
			if (alpha >= 1) {
				mode = GHOST_MODE_CHASING;
				animation.play("chase");
				ID = 0;
			}
		}else if (mode == GHOST_MODE_FADE_OUT) {
			// fade_in -> chase
			alpha -= 0.03;
			scale.x -= 0.02;
			scale.y -= 0.02;
			splotchBottom.alpha = splotchTop.alpha = alpha;
			if (alpha <= 0.02) {
				scale.set(1, 1);
				alpha = 0;
				velocity.set(0, 0);
				x = last.x = ix;
				y = last.y = iy;
				mode = GHOST_MODE_INVISIBLE;
			}
		} else if (mode == GHOST_MODE_CHASING) {
			
			if (ID == 0) {
				ID = 1;	
				animation.play("charge");
			} else if (ID == 1) {
				R.player.y += R.player.height / 2; R.player.x += R.player.width / 2;
				x += width / 2; y += height / 2;
				
				HF.scale_velocity(target_vel, this, R.player, chase_vel);
				target_pos.x = R.player.x;
				target_pos.y = R.player.y;
				R.player.y -= R.player.height / 2; R.player.x -= R.player.width / 2;
				x -= width / 2; y -= height / 2;
				
				target_angle = Math.atan( -target_vel.y / target_vel.x) * (360.0 / 6.28);
				target_angle = Std.int(target_angle);
				
				var a:Float = 270;
				if (target_vel.x > 0) {
					target_angle = a + -1 * target_angle;
				} else {
					if (target_vel.y > 0) {
						target_angle = a + (90 - target_angle) + 90;
						// III, 0 to 90 ccw
					} else {
						target_angle = a + 180 + -1 * target_angle;
						// II , 0 to -90 CW
					}
				}
				if (target_angle >= 360) target_angle -= 360;
				
				for (i in 0...15) {
					if (Math.abs(angle - target_angle) < 1.4) {
						break;
					} else if (angle < target_angle) {
						if (target_angle - angle > 180) {
							angle--;
						} else {
							angle++;
						}
					} else if (angle > target_angle) {
						if (angle - target_angle > 180) {
							angle++;
						} else {
							angle--;
						}
					}
					if (angle >= 360) angle -= 360;
					if (angle < 0) angle += 360;
				}
				
				t_rotate+= FlxG.elapsed;
				if (t_rotate > tm_rotate) {
					t_rotate = 0;
					ID = 2;
				}
			} else if (ID == 2) {
				t_wait += FlxG.elapsed;
				if (t_wait > tm_wait) {
					t_wait = 0;
					ID = 3;
					animation.play("attack");
				}
				// finish charge anim
			} else if (ID == 3 || ID == 5) {
				
				//
				//R.player.y += R.player.height / 2; R.player.x += R.player.width / 2;
				//x += width / 2; y += height / 2;
				////
				////Log.trace(velocity);
				//var ox:Float = target_vel.x;
				//var oy:Float = target_vel.y;
				////HF.scale_velocity(target_vel, this, R.player, chase_vel);
				//velocity.x += (-velocity.x + target_vel.x) * 1 / 25;
				//velocity.y += (-velocity.y + target_vel.y) * 1 / 25;
				//target_vel.set(ox, oy);
				////
				//R.player.y -= R.player.height / 2; R.player.x -= R.player.width / 2;
				//x -= width / 2; y -= height / 2;
				
				// accel to target vel
				// go to ID=4 if touching or near pt (or 6 etc)
				if (target_vel.x > 0) {
					if (velocity.x < target_vel.x) velocity.x += FlxG.elapsed * accel;
				} else {
					if (velocity.x > target_vel.x)velocity.x -= FlxG.elapsed * accel;
				}
				if (target_vel.y > 0) {
					if (velocity.y < target_vel.y) velocity.y += FlxG.elapsed * accel;
				} else {
					if (velocity.y > target_vel.y) velocity.y -= FlxG.elapsed * accel;
				}
				target_pos.x = R.player.x + R.player.width / 2;
				target_pos.y = R.player.y + R.player.height / 2;
				
				
				var u1:Float = target_vel.x;
				var u2:Float = -target_vel.y;
				var h:Float = Math.sqrt(u1 * u1 + u2 * u2);
				u1 /= h;
				u2 /= h;
				
				var v1:Float =  target_pos.x - (x + width / 2);
				var v2:Float = (y + height / 2) - target_pos.y;
				h = Math.sqrt(v1 * v1 + v2 * v2);
				v1 /= h;
				v2 /= h;
				
				var ang:Float = Math.acos(u1 * v1 + u2 * v2);
				ang *= (360.0 / (3.14159 * 2));
				//Log.trace(ang);
				if (ang > 90) {
					if (ID == 5) ID = 6;
					if (ID == 3) ID = 4;
				}
			} else if (ID == 4 || ID == 6) {
				// decel to zero
				drag.x = drag.y = deaccel;
				if (Math.abs(velocity.y) < 10 && Math.abs(velocity.x) < 10) {
					velocity.set(0, 0);
					ID = 0;
					drag.set(0, 0);
					animation.play("chase");
				}
			}
			
			// circle light or hurt if necessary
			if (ID >= 3 && ID <= 6) {
				// overlaps w/ light -> circling light
				if (t_immune >= tm_immune) {
					for (light in ACTIVE_GhostLights) {
						if (!light.is_ghost && light.mode == 1 && HF.get_midpoint_distance(light, this) < light.light_radius) {
							mode = GHOST_MODE_CIRCLING_LIGHT_INIT;
							attached_light = light;
							ID = 0;
							drag.set(0, 0);
							return;
						}
					}
				} else {
					t_immune += FlxG.elapsed;
				}
				
				
				if ((ID == 3 || ID == 4) && overlaps(R.player)) {
					if (ID == 3) ID = 5;
					if (ID == 4) ID = 6;
					//R.player.skip_motion_ticks = 5;
					R.sound_manager.play(SNDC.clam_1);
					if (dmgtype == 0) {
						R.player.add_dark(24);
					} else {
						R.player.add_light(24);
					}
				}
			}
		} else if (mode == GHOST_MODE_CIRCLING_LIGHT_INIT) {
			if (angle > 0) { 
				angle --;
			}
			if (ID == 0) {
				HF.scale_velocity(target_vel, new FlxObject(getMidpoint().x, getMidpoint().y, 1, 1), new FlxObject(attached_light.getMidpoint().x, attached_light.getMidpoint().y, 1, 1), 80);
				target_vel.x *= -1;
				target_vel.y *= -1;
				if (Math.abs(target_vel.x) < 30) {
					target_vel.x = 30;
				}
				if (Math.abs(target_vel.y) < 30) {
					target_vel.y = 30;
				}
				ID = 1;
			} else if (ID == -1) {
				
			} else if (ID == 1) {
				if (Math.abs(velocity.x - target_vel.x) < 10) {
					velocity.x = target_vel.x;
				} else if (velocity.x < target_vel.x) {
					velocity.x += 9;
				} else {
					velocity.x -= 9;
				}
				if (Math.abs(velocity.y - target_vel.y) < 10) {
					velocity.y = target_vel.y;
				} else if (velocity.y < target_vel.y) {
					velocity.y += 9;
				} else {
					velocity.y -= 9;
				}
				
				
				
				if (HF.get_midpoint_distance(attached_light, this) > attached_light.light_radius + 4) {
					velocity.set(0, 0);
					ID = 0;
					mode = GHOST_MODE_CIRCLING_LIGHT;
					animation.play("stun");
					var dy:Float = attached_light.getMidpoint().y - getMidpoint().y;
					var dx:Float = attached_light.getMidpoint().x - getMidpoint().x;
					if (dy > attached_light.light_radius + 4) dy = attached_light.light_radius + 4;
					if (dy < -(attached_light.light_radius + 4)) dy = -(attached_light.light_radius + 4);
					
					ghost_angle = Math.asin(dy / (attached_light.light_radius + 4));
					
					//Log.trace(ghost_angle);
					
					if (dx >= 0) {
						if (dy >= 0) {
							ghost_angle += Math.PI;
						} else {
							ghost_angle *= -1;
							ghost_angle = Math.PI - ghost_angle;
						}
					} else {
						if (dy >= 0) {
							ghost_angle = 2 * Math.PI - ghost_angle;
						} else {
							ghost_angle *= -1;
						}
					}
				}
			}
			// Find midpoint pt 4 px from outside of radius at current angle. move there, then -> circling_light
		} else if (mode == GHOST_MODE_CIRCLING_LIGHT) {
			
			// Circle light
			ghost_midpoint.x = (attached_light.x + attached_light.width/2) + (4 + attached_light.light_radius) * Math.cos(ghost_angle);
			ghost_midpoint.y = (attached_light.y + attached_light.height/2) + (4 + attached_light.light_radius) * Math.sin(ghost_angle);
			x = ghost_midpoint.x - width / 2;
			y = ghost_midpoint.y - height / 2;
			ghost_angle += (6.28 / 180.0);
			if (ghost_angle > 2 * Math.PI) {
				ghost_angle = 0;
			}
			
			// If the movement towards player is not in the light, then chase the player
			HF.scale_velocity(velocity, new FlxObject(getMidpoint().x, getMidpoint().y, 1, 1), new FlxObject(R.player.getMidpoint().x, R.player.getMidpoint().y, 1, 1), 8 * 60.0);
			ghost_midpoint.x += velocity.x * FlxG.elapsed;
			ghost_midpoint.y += velocity.y * FlxG.elapsed;
			
			if (attached_light.mode == 0 || HF.get_midpoint_distance(attached_light, new FlxObject(ghost_midpoint.x, ghost_midpoint.y, 1, 1)) > attached_light.light_radius) {
				mode = GHOST_MODE_CHASING;
				animation.play("chase");
				t_immune = 0;
			}
			velocity.set(0, 0);
			
		} else if (mode == GHOST_MODE_ON_PLAYER) {
				var dx:Float = R.player.x + 2;
				var dy:Float = R.player.y;
				var spd:Float = 1.8;
			if (ID == 0) {
				velocity.set(0, 0);
				if (x < dx) {
					x += spd;
					if (x > dx) {
						x = dx;
					}
				} else {
					x -= spd;
					if (x < dx) {
						x = dx;
					}
				}
				
				if (y < dy) {
					y += spd;
					if (y > dy) {
						y = dy;
					}
				} else {
					y -= spd;
					if (y < dy) {
						y = dy;
					}
				}
				
				if (x == dx && y == dy) {
					ID = 1;
				}
				
			} else {
				t_dmg += FlxG.elapsed;
				if (t_dmg > tm_dmg) {
					t_dmg -= tm_dmg;
					if (dmgtype == 0) {
						R.player.add_dark(1);
					} else {
						R.player.add_light(1);
					}
				}
				x = dx;
				y = dy;
				
				for (light in ACTIVE_GhostLights) {
					if (light.has_player && !light.is_ghost) {
						
						mode = GHOST_MODE_CHASING;
						ID = 0;
					}
				}
			}
			// Stick to player until plyaer overlaps light -> chse mode
		}
	}
	
	override public function postUpdate(elapsed:Float):Void 
	{
		super.postUpdate(elapsed);
		if (is_ghost) {
			splotchBottom.move(x, y);
			splotchTop.move(x, y);
			if (splotchBottom.ID == 0) {
				if (splotchBottom.angularVelocity < 25) {
					splotchBottom.angularVelocity = 25;
				}
				if (splotchTop.angularVelocity > -25) {
					splotchTop.angularVelocity = -25;
				}
				if (mode == GHOST_MODE_CHASING) {
					if (ID != 0) { // starting charging
						splotchBottom.ID = 1;
						splotchTop.angularAcceleration = -300;
						splotchBottom.angularAcceleration = 300;
					}
				}
			} else if (splotchBottom.ID == 1) {
				if (splotchBottom.angularVelocity > 150) {
					splotchBottom.angularVelocity = 150;
				}
				if (splotchTop.angularVelocity < -150) {
					splotchTop.angularVelocity = -150;
				}
				if (mode != GHOST_MODE_CHASING || (ID != 1 && ID != 2)) {
					splotchTop.angularAcceleration = 500;
					splotchBottom.angularAcceleration = -500;
					splotchBottom.ID = 0;
				}
			}
		}
	}
	override public function draw():Void 
	{
		if (is_ghost == false) {
			if (R.editor.editor_active) {
				alpha = 1;
				FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
				FlxG.camera.debugLayer.graphics.drawCircle(x + width/2 - FlxG.camera.scroll.x, y + height/2 - FlxG.camera.scroll.y, light_radius);
			}
		} else {
			
			if (R.editor.editor_active) {
				alpha = 1;
			}
		}
		super.draw();
	}
}