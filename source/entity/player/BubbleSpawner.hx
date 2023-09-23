package entity.player;

import autom.SNDC;
import entity.enemy.SmashHand;
import entity.enemy.SpikeExtend;
import entity.enemy.SquishyChaser;
import entity.MySprite;
import entity.trap.BarbedWire;
import entity.trap.FlameBlower;
import entity.trap.HurtOutlet;
import entity.trap.MirrorLaser;
import entity.trap.Pew;
import entity.trap.Pod;
import entity.trap.RubberLaser;
import entity.trap.Spike;
import entity.trap.Weed;
import entity.util.BubbleSwitch;
import flash.display.Bitmap;
import flash.geom.Point;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import global.C;
import haxe.CallStack;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import flixel.FlxG;
import flixel.FlxSprite;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class BubbleSpawner extends MySprite
{
	
	private var bubble_type:Int = 0;
	
	public static var BUBBLE_DARK:Int = 0;
	public static var BUBBLE_LIGHT:Int = 1;
	
	private var bubble:FlxSprite;
	
	private static var circle_pts_x:Array<Float>;
	private static var circle_pts_y:Array<Float>;
	
	private var antennae:FlxGroup;
	private var sparkles:FlxTypedGroup<FlxSprite>;
	private var sparkle_trail:FlxSprite;
	private var nr_trail:Int = 5;
	private var sparkle_trail_pos:Array<Array<Point>>;
	private var sparkle_wait:Float = 0;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		sparkle_trail = new FlxSprite();
		sparkle_trail_pos = [];
		for (i in 0...8) {
			sparkle_trail_pos.push([]);
			for (j in 0...nr_trail) { // nr of trail
				sparkle_trail_pos[i].push(new Point(-8,-8));
			}
		}
		bubble = new FlxSprite();
		circle = [0, 0, 0];
		antennae = new FlxGroup();
		sparkles = new FlxTypedGroup<FlxSprite>();
		for (i in 0...4) {
			var a:FlxSprite = new FlxSprite();
			antennae.add(a);
		}
		for (i in 0...8) {
			var s:FlxSprite = new FlxSprite();
			sparkles.add(s);
		}
		if (circle_pts_x == null) {
			circle_pts_x = [0, C_radius, C_radius_over_rt2, 0, -C_radius_over_rt2, -C_radius, -C_radius_over_rt2, 0, C_radius_over_rt2];
			circle_pts_y = [0, 0, C_radius_over_rt2, C_radius, C_radius_over_rt2, 0, -C_radius_over_rt2, -C_radius, -C_radius_over_rt2];
			
		}
		
		super(_x, _y, _parent, "BubbleSpawner");
	}
	
	override public function change_visuals():Void 
	{
		
		// dont forget to change move_bubble call in player
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 32, name, "dark");
				AnimImporter.loadGraphic_from_data_with_id(bubble, 32,32, "Bubble", "dark");
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 32, name, "light");
				AnimImporter.loadGraphic_from_data_with_id(bubble, 32, 32, "Bubble", "light");
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 32, name, Std.string(vistype));
				AnimImporter.loadGraphic_from_data_with_id(bubble, 32, 32, "Bubble", Std.string(vistype));
				
		}
		height = 16;
		offset.y = 16;
		//origin.set(0, 16);
		for (i in 0...8) {
			var s:FlxSprite = cast sparkles.members[i];
			
			if (bubble_type == 0) {
				AnimImporter.loadGraphic_from_data_with_id(s, 4, 4, "BubblePop", "d");
				// only load spralkle trail once
				if (i == 0) AnimImporter.loadGraphic_from_data_with_id(sparkle_trail,4, 4, "BubblePop", "d");
			} else if (bubble_type == 1) {
				AnimImporter.loadGraphic_from_data_with_id(s, 4, 4, "BubblePop", "l");
				if (i == 0) AnimImporter.loadGraphic_from_data_with_id(sparkle_trail,4, 4, "BubblePop", "l");
			} else {
				AnimImporter.loadGraphic_from_data_with_id(s, 4, 4, "BubblePop", vistype);
				AnimImporter.loadGraphic_from_data_with_id(sparkle_trail,4, 4, "BubblePop", vistype);
			}
			s.alpha = 0;
			s.animation.play("idle");
		}
			sparkle_trail.animation.play("trail");
		
		for (i in 0...4) {
			var a:FlxSprite = cast(antennae.members[i], FlxSprite);
			switch (vistype) {
				case 0:
					AnimImporter.loadGraphic_from_data_with_id(a, 16, 16, "BubbleSpawner", "dark_antennae");
				case 1:
					AnimImporter.loadGraphic_from_data_with_id(a, 16, 16, "BubbleSpawner", "light_antennae");
			}
			if (i == 0) a.animation.play("u"); 
			if (i == 1) a.animation.play("r");
			if (i == 2) a.animation.play("d");
			if (i == 3) a.animation.play("l");
			a.visible = false;
		}
		
		animation.play("idle", true);
		bubble.animation.play("idle", true);
		bubble.width = bubble.height = 40;
		bubble.offset.set(4, 4);
		if (!bubble_is_On) {
			bubble.visible = false;
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", 0);
		p.set("bubble_type", 0);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		vistype = props.get("vistype");
		if (vistype == 0 || vistype == 1) {
			props.set("bubble_type", vistype);
		}
		bubble_type = props.get("bubble_type");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [bubble,sparkles], MyState.ENT_LAYER_IDX_FG2);
		HF.remove_list_from_mysprite_layer(this, parent_state, [antennae]);
		if (bubble_is_On) {
			do_sparkle = false;
			sparkle_x = sparkle_y = -1;
			reset_statics();
			R.player.has_bubble = false;
		}
		super.destroy();
	}
	
	public static var BUBBLE_DEBUG_MESSAGES_ON:Bool = false;
	public static var BUBBLE_LOCKED:Bool = false;
	public var bubble_is_On:Bool = false;
	
	private var mode:Int = 0;
	public static inline var C_radius:Float = 18;
	private static var C_radius_over_rt2:Float = 12.73;
	public static var px:Int = 0;
	public static var py:Int = 2;
	public static var cur_bubble:FlxSprite;
	public static var cur_bubble_flavor:Int = 0;
	public static var circle:Array<Float>;
	
	override public function draw():Void 
	{
		//for (i in 0...9) {
			//FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
			//FlxG.camera.debugLayer.graphics.moveTo(circle[0] - FlxG.camera.scroll.x,circle[1] - FlxG.camera.scroll.y);
			//FlxG.camera.debugLayer.graphics.lineTo(circle[0]+circle_pts_x[i] - FlxG.camera.scroll.x,circle[1]+circle_pts_y[i] - FlxG.camera.scroll.y) ;
		//}
		//
		//if (cur_bubble != null) {
			//FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
			//FlxG.camera.debugLayer.graphics.moveTo(cur_bubble.x - FlxG.camera.scroll.x,cur_bubble.y - FlxG.camera.scroll.y);
			//FlxG.camera.debugLayer.graphics.lineTo(cur_bubble.x - FlxG.camera.scroll.x,cur_bubble.y + C_radius - FlxG.camera.scroll.y) ;
			//FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
			//FlxG.camera.debugLayer.graphics.moveTo(cur_bubble.x - FlxG.camera.scroll.x,cur_bubble.y - FlxG.camera.scroll.y);
			//FlxG.camera.debugLayer.graphics.lineTo(cur_bubble.x +C_radius - FlxG.camera.scroll.x, cur_bubble.y - FlxG.camera.scroll.y);	
			//
			//FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
			//FlxG.camera.debugLayer.graphics.moveTo(cur_bubble.x - FlxG.camera.scroll.x,cur_bubble.y - FlxG.camera.scroll.y);
			//FlxG.camera.debugLayer.graphics.lineTo(cur_bubble.x+C_radius +C_radius  - FlxG.camera.scroll.x,cur_bubble.y + C_radius - FlxG.camera.scroll.y) ;
			//FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
			//FlxG.camera.debugLayer.graphics.moveTo(cur_bubble.x - FlxG.camera.scroll.x,cur_bubble.y - FlxG.camera.scroll.y);
			//FlxG.camera.debugLayer.graphics.lineTo(cur_bubble.x +C_radius - FlxG.camera.scroll.x, cur_bubble.y +C_radius +C_radius - FlxG.camera.scroll.y);
		//}
		
		for (i in 0...8) {
			if (do_sparkle) {
				for (j in 0...nr_trail) {
					if (sparkles.members[i].alpha == 0) {
						
					} else {
					// 0 1 2
					if (j == nr_trail-1) {
						sparkle_trail_pos[i][j].setTo( sparkles.members[i].last.x,sparkles.members[i].last.y);
					} else {
						sparkle_trail_pos[i][j].setTo(sparkle_trail_pos[i][j+1].x,sparkle_trail_pos[i][j+1].y);
					}
					sparkle_trail.move(sparkle_trail_pos[i][j].x, sparkle_trail_pos[i][j].y);
					sparkle_trail.alpha = (j + 2.0) / (nr_trail + 2);
					sparkle_trail.alpha *= sparkles.members[i].alpha;
					sparkle_trail.draw();
					}
				}
			} else {
				for (j in 0...nr_trail) {
					sparkle_trail_pos[i][j].setTo( -8, -8);
				}
			}
		}
		
		super.draw();
	}
	
	// only have one now
	private function set_antenna_pos():Void {
		antennae.setAll("visible", false);
		for (i in 0...4) {
			var a:FlxSprite = cast(antennae.members[i], FlxSprite);
			a.visible = false;
			if (i == 0) {
				if (parent_state.tm_bg.getTileCollisionFlags(x, y - 16) == 0) {
					a.visible = true;
					a.alpha = 0;
					a.x = x; a.y = y - 16;
					angle = 0;
					offset.set(0, 16);
					break;
				}
			} else if (i == 1) {
				if (parent_state.tm_bg.getTileCollisionFlags(x+16, y) == 0) {
					a.visible = true;
					a.alpha = 0;
					a.x = x + 16; a.y = y;
					angle = 90;
					offset.set(-8, 8);
					break;
				}
			} else if (i == 2) {
				if (parent_state.tm_bg.getTileCollisionFlags(x, y+16) == 0) {
					a.visible = true;
					a.alpha = 0;
					a.x = x; a.y = y + 16;
					
					angle = 180;
					offset.set(0, 0);
					break;
				}
			} else if (i == 3) {
				if (parent_state.tm_bg.getTileCollisionFlags(x - 16, y) == 0) {
					a.visible = true;
					a.alpha = 0;
					a.x = x - 16; a.y = y;
					angle = 270;
					offset.set(8, 8);
					break;
				}
			}
		}
	}
	
	public static function reset_statics():Void 
	{
		BUBBLE_LOCKED = false;
		cur_bubble = null;
	}
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			set_antenna_pos();
			HF.add_list_to_mysprite_layer(this, parent_state, [bubble,sparkles], MyState.ENT_LAYER_IDX_FG2);
			HF.add_list_to_mysprite_layer(this, parent_state, [antennae]);
		}
		if (R.editor.editor_active) {
			set_antenna_pos();
		}
		
		if (do_sparkle) {
			var j:Int = 0;
			var s:FlxSprite = null;
			if (sparkle_x == -1) {
				for (i in 0...8) {
					s = sparkles.members[i];
					s.alpha -= 0.016;
					if (s.alpha <= 0) {
						j++;
						if (j == 8) {
						do_sparkle = false;
						}
					}
				}
			} else {
				
				if (sparkle_wait > 0) sparkle_wait --;
				for (i in 0...8) {
					s = cast sparkles.members[i];
					//s.alpha -= 0.017;
					if (sparkle_wait > 0) {
						continue;
					}
					if (s.ID == 1) {
						s.alpha -= 0.1;
						if (s.alpha <= 0) {
							s.alpha = 0;
						}
					} else if ((s.alpha <= 1.0 - .0001 * 120) || (Math.abs(sparkle_x - s.x + s.width / 2) < 5 && Math.abs(sparkle_y - s.y + s.height / 2) < 5)) {
						s.ID = 1;
						R.sound_manager.play(SNDC.particle_hit);
						if (BubbleSwitch.lasttouched != null) {
							if (cur_bubble_flavor == 0) {
								BubbleSwitch.lasttouched.broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
							} else if (cur_bubble_flavor == 1) {
								BubbleSwitch.lasttouched.broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
							}
						}
					} else {
						// Timeout for if the particle never 'hits'. Currently 120 ticks
						s.alpha -= .0001;
					}
					s.maxVelocity.set(110, 110);
					var brake:Float = 2;
					var accel:Float = 425;
					if (s.alpha <= 1) {
						accel *= 1.5;
					}
					if (s.x + s.width/2 < sparkle_x) {
						s.acceleration.x = accel;
						if (s.velocity.x < 30) s.velocity.x += brake;
					} else {
						s.acceleration.x = -accel;
						if (s.velocity.x > -30) s.velocity.x -= brake;
					}
					
					if (s.y + s.height / 2 > sparkle_y) {
						s.acceleration.y = -accel;
						if (s.velocity.y > -30) s.velocity.y -= brake;
					} else {
						s.acceleration.y = accel;
						if (s.velocity.y < 30) s.velocity.y += brake;
					}
					if (s.alpha <= 0) {
						j++;
						if (j == 8) {
							do_sparkle = false;
							sparkle_x = sparkle_y = -1;
							for (k in 0...8) {
								sparkles.members[k].ID = 0;
							}
						}
					}
				}
			}
		}
		if (bubble_is_On) {
			
			// 1 = only light breaks, 0 = only dark breaks
			var dmgtype:Int = vistype == 0 ? 1 : 0;
			// Only opposite type can pop
			for (i in 0...Pew.ACTIVE_Pews.length) {
				var p:Pew = Pew.ACTIVE_Pews.members[i];
				if (p != null && p.generic_circle_overlap(circle[0], circle[1], circle[2], bubble, dmgtype)) {
					do_pop = true;
					if (BUBBLE_DEBUG_MESSAGES_ON) Log.trace(["Pew Pop"]);
					break;
				}
			}
			
			for (i in 0...Spike.ACTIVE_Spikes.length) {
				var spike:Spike = Spike.ACTIVE_Spikes.members[i];
				if (spike != null && spike.generic_circle_overlap(circle[0],circle[1],circle[2],dmgtype)) {
					do_pop = true;
					if (BUBBLE_DEBUG_MESSAGES_ON) Log.trace(["Spike Pop"]);
					break;
				}
			}
			
			for (bw in BarbedWire.ACTIVE_BarbedWires) {
				if (bw.generic_circle_overlap(circle[0], circle[1], circle[2], dmgtype)) {
					do_pop = true;
					break;
				}
			}
			
			for (sc in SquishyChaser.ACTIVE_SquishyChasers) {
				if (sc.generic_circle_overlap(circle[0], circle[1], circle[2], dmgtype)) {
					do_pop = true;
					break;
				}
			}
			for (sh in SmashHand.ACTIVE_SmashHands) {
				if (sh.generic_circle_overlap(circle[0], circle[1], circle[2], dmgtype)) {
					do_pop = true;
					break;
				}
			}
			for (ml in MirrorLaser.ACTIVE_MirrorLasers) {
				if (ml.generic_circle_overlap(circle[0], circle[1], circle[2], dmgtype)) {
					do_pop = true;
					break;	
				}
			}
			for (weed in Weed.ACTIVE_Weeds) {
				if (weed.circle_overlap(circle[0], circle[1], circle[2], dmgtype)) {
					do_pop = true;
					if (BUBBLE_DEBUG_MESSAGES_ON) Log.trace(["weed Pop"]);
					break;
				}
			}
			
			for (pod in Pod.ACTIVE_Pods) {
				if (pod.generic_circle_overlap(circle[0], circle[1], circle[2], dmgtype)) {
					do_pop = true;
					if (BUBBLE_DEBUG_MESSAGES_ON) Log.trace(["pod Pop"]);
					break;
				}
			}
			
			for (hurtoutlet in HurtOutlet.ACTIVE_HurtOutlets) {
				if (hurtoutlet.generic_circle_overlap(circle[0], circle[1], circle[2], dmgtype)) {
					do_pop = true;
					if (BUBBLE_DEBUG_MESSAGES_ON) Log.trace(["hurtoutlet Pop"]);
					break;
				}
			}
			
			for (rubberlaser in RubberLaser.ACTIVE_RubberLasers) {
				if (rubberlaser.generic_circle_overlap(circle[0], circle[1], circle[2], dmgtype)) {
					do_pop = true;
					if (BUBBLE_DEBUG_MESSAGES_ON) Log.trace(["rubberlaser Pop"]);
					break;
				}
			}
			
			for (fb in FlameBlower.ACTIVE_FlameBlowers) {
				if (fb.generic_circle_overlap(circle[0], circle[1], circle[2], dmgtype)) {
					do_pop = true;
					break;
				}
			}
			
			for (se in SpikeExtend.ACTIVE_SpikeExtends) {
				if (se.generic_circle_overlap(circle[0], circle[1], circle[2], dmgtype)) {
					do_pop = true;
					break;
				}
			}
			
			var gasarray:Array<Int> = [];
			if (cur_bubble_flavor == BUBBLE_DARK) {// opposite color gas pops bubble
				gasarray = HelpTilemap.active_gaslight;
			} else {
				gasarray = HelpTilemap.active_gasdark;
			}
			for (i in 0...9) {
				for (tm in [parent_state.tm_bg,parent_state.tm_bg2]) {
				if (HF.array_contains(gasarray, tm.getTileID(circle[0] + circle_pts_x[i], circle[1] + circle_pts_y[i]))) {
					do_pop = true;
					if (BUBBLE_DEBUG_MESSAGES_ON) Log.trace(["gas Pop"]);
					break;
				}
				}
			}
		
			
			if (do_pop) {
				do_pop = false;
				R.sound_manager.play(SNDC.splashfx);
				BUBBLE_LOCKED = false;
				bubble_is_On = false;
				cur_bubble = null;
				R.player.has_bubble = false;
				bubble.animation.play("pop");
				do_sparkle = true;
				
				
				
				if (cur_bubble_flavor == BUBBLE_DARK) {
					R.player.add_dark(0, 2, circle[0], circle[1]);
				} else {
					R.player.add_light(0, 3, circle[0], circle[1]);
				}
				
				sparkle_x = global_sparkle_x;
				sparkle_y = global_sparkle_y;
				global_sparkle_x = global_sparkle_y = -1;
				for (i in 0...8) {
					var s:FlxSprite = cast sparkles.members[i];
					
					// Didjn't pop on switch
					if (sparkle_x == -1) {
						s.acceleration.x = 0;
						s.velocity.y = R.player.velocity.y * 0.2;
						s.velocity.x = R.player.velocity.x * (0.3 + 0.3 * Math.random());
						s.acceleration.y = 135 + 30 * Math.random();
					// did pop on switch
					} else {
						//s.velocity.x = -20 + 40 * Math.random();
						s.velocity.x = R.player.velocity.x * (0.15 + 0.3 * Math.random());
						s.velocity.y = -70-40*Math.random();
						s.acceleration.set(0, 160);
					}
					sparkle_wait = 35;
					s.x = circle[0] + C_radius * FlxX.cos_table[45 * i];
					s.y = circle[1] + C_radius * FlxX.sin_table[45 * i];
					s.alpha = 1;
				}
			}
		} else {
			var unshift:Bool = false;
			if (R.player.is_in_wall_mode()) {
				width += 2; x -= 1;
			}
			if (R.player.overlaps(this) && BUBBLE_LOCKED == false) {
				overlap_dir = -1;
				
				if (R.player.is_in_wall_mode()) {
					width -= 2; x += 1;
					unshift = true;
				}
				var d:Float = (bubble.width - width) / 2;
				if (R.player.overlaps(antennae.members[0]) && antennae.members[0].visible) {
					overlap_dir = 0;
					bubble.x = x - d;
					bubble.y = y - 16 - d;
				} else if (R.player.overlaps(antennae.members[1]) && antennae.members[1].visible) {
					overlap_dir = 1;
					bubble.x = x + 16 - d;
					bubble.y = y - d;
				} else if (R.player.overlaps(antennae.members[2]) && antennae.members[2].visible) {
					overlap_dir = 2;
					bubble.x = x - d;
					bubble.y = y + 16 - d;
				} else if (R.player.overlaps(antennae.members[3]) && antennae.members[3].visible) {
					overlap_dir = 3;
					bubble.x = x - 16 - d;
					bubble.y = y - d;
				} 
				
				if (overlap_dir != -1) {
					sparkles.setAll("alpha", 0);
					do_sparkle = false; sparkle_x = sparkle_y = -1;
					do_pop = false;
					R.sound_manager.play(SNDC.checkpoint);
					bubble.visible = true;
					cur_bubble = bubble;
					BUBBLE_LOCKED = true;
					cur_bubble_flavor = bubble_type;
					bubble.animation.play("grow");
					
					bub_x_locked = false;
					bub_y_locked = false;
				}
			} else if (BUBBLE_LOCKED && bubble == cur_bubble) { // play grow anim, move to player
				if (bubble.animation.finished && bub_x_locked && bub_y_locked) {
						bubble_is_On = true;
						bubble.animation.play("idle");
						bubble.velocity.set(0, 0);
				R.player.has_bubble = true;
						move_bubble(R.player.x, R.player.y);
				} else {
					if (!bub_x_locked) {
						if (Math.abs((R.player.x + R.player.width/2) - (bubble.x + bubble.width/2)) < 1.5) {
							bub_x_locked = true;
							bubble.velocity.x = 0;
						} else if (bubble.x + bubble.width/2 < R.player.x + R.player.width/2) {
							bubble.velocity.x = 200;
						} else {
							bubble.velocity.x = -200;
						}
					} else {
						bubble.x = R.player.x - (bubble.width - R.player.width) / 2;
					}
					if (!bub_y_locked) {
						if (Math.abs((R.player.y  + R.player.height/2) - (bubble.y  +  bubble.height/2)) < 1.5) {
							bub_y_locked = true;
							bubble.velocity.y = 0;
						} else if (bubble.y + bubble.height/2 < R.player.y + R.player.height/2 ) {
							bubble.velocity.y = 200;
						} else {
							bubble.velocity.y = -200;
						}
					} else {
						bubble.y = R.player.y - (bubble.height - R.player.height) / 2;
					}
				}
			}
			
			if (!unshift && R.player.is_in_wall_mode()) {
				width -= 2; x += 1;
			}
		}
		
		super.update(elapsed);
	}
	private var bub_x_locked:Bool = false;
	private var bub_y_locked:Bool = false;
	private var overlap_dir:Int = 0;
	public static var vel:FlxPoint = null;
	//override_class = this movement command will be overridden if the bubble is in grow anim mode
	public static function move_bubble(x:Float, y:Float, _vel:FlxPoint = null):Void {
		
		if (cur_bubble != null) {
			cur_bubble.x = x;
			cur_bubble.y = y + 2;
		}
		
		circle[0] = cur_bubble.x + 20;
		circle[1] = cur_bubble.y + 20;
		circle[2] = C_radius;
	}
	public static var do_pop:Bool = false;
	public  var do_sparkle:Bool = false;
	public  var sparkle_x:Float = -1;
	public  var sparkle_y:Float = -1;
	public  static var global_sparkle_x:Float = -1;
	public  static var global_sparkle_y:Float = -1;
	public static function force_pop(kind:Int=0,_x:Float=0,_y:Float=0):Void {
		//Log.trace("hey");
		//Log.trace(CallStack.toString([CallStack.callStack()[1]]));
		global_sparkle_x = _x;
		global_sparkle_y = _y;
		do_pop = true;
	}
	
}