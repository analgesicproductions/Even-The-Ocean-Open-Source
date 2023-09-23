package entity.trap;
import autom.SNDC;
import entity.MySprite;
import entity.npc.Mole;
import entity.util.VanishBlock;
import flixel.FlxSprite;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import state.MyState;
/**
 * ...
 * @author Melos Han-Tani
 */

class Pod extends MySprite
{

	private static inline var VISTYPE_DEBUG_L:Int = 0;
	private static inline var VISTYPE_DEBUG_D:Int = 1;
	
	public static var ACTIVE_Pods:List<Pod>;
	public static var ACTIVE_PodSwitches:List<Pod>;
	private var damage:Int;
	private static inline var BASE_DAMAGE:Int = 24;
	private static inline var MODE_ALIVE:Int = 0;
	private static inline var MODE_DEAD:Int = 1;
	private var poof:FlxSprite;
	private var poof_mode:Int = 0;
	
	public function new(_x:Float, _y:Float,_parent:MyState)
	
	{
		poof = new FlxSprite();
		super(_x, _y, _parent, "Pod");
	}
	
	var dir_prefix:String = "";
	override public function change_visuals():Void 
	{
		AnimImporter.loadGraphic_from_data_with_id(poof, 64, 64, "HurtEffectGroup", "pod_poof");
		poof.exists = false;
		switch (vistype) {
			case VISTYPE_DEBUG_D:
				props.set("dmgtype", VISTYPE_DEBUG_D);
				if (is_big) {
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "BigPod", "1");
				} else {
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", "1");
				}
				dmgtype = VISTYPE_DEBUG_D;
			case VISTYPE_DEBUG_L:
				props.set("dmgtype", VISTYPE_DEBUG_L);
				if (is_big) {
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "BigPod", "0");
				} else {
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", "0");
				}
				dmgtype = VISTYPE_DEBUG_L;
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", vistype); // no
				
		}
		animation.play(dir_prefix + "full", true,false,-1);
		if (is_big) {
			width = height = 20;
		offset.x = offset.y = 6;
		} else {
			width = height = 8;
			height = 9;
		offset.x = offset.y = width / 2;
		}
	}
	
	private var t_dead:Float = 0;
	private var tm_dead:Float = 0;
	private var is_big:Bool = false;
	public var is_vanish:Bool = false;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		
		p.set("vistype", VISTYPE_DEBUG_L);
		p.set("dmgtype", 0);
		p.set("damage", 24);
		p.set("tm_dead", 1.0);
		p.set("dir", 0); // URDL
		p.set("AUTO_ORIENT", 1);
		p.set("children", "");
		p.set("is_big", 0);
		p.set("is_vanish_switch", 0);
		
		p.set("onOff_on_time", -1);
		p.set("onOff_off_time", 1);
		p.set("onOff_start_offset", 0);
		
		return p;
	}
	
	private var onOff_on_time:Float = 0;
	private var onOff_off_time:Float = 0;
	private var onOff_t:Float = 0;
	
	
	override public function recv_message(message_type:String):Int 
	{
		//Log.trace(message_type);
		if (message_type == C.MSGTYPE_MOVED_BY_EDITOR) {
			if (props.get("AUTO_ORIENT") == 1) {
				if (parent_state.tm_bg.getTileCollisionFlags(x, y + 17) != FlxObject.NONE) {
					props.set("dir", 0);
				} else if (parent_state.tm_bg.getTileCollisionFlags(x, y -14) != FlxObject.NONE) {
					props.set("dir", 2);
				} else if (parent_state.tm_bg.getTileCollisionFlags(x-10, y) != FlxObject.NONE) {
					props.set("dir", 1);
				} else if (parent_state.tm_bg.getTileCollisionFlags(x+17, y) != FlxObject.NONE) {
					props.set("dir", 3);
				} else if (is_big && parent_state.tm_bg.getTileCollisionFlags(x+28, y) != FlxObject.NONE) {
					props.set("dir", 3);
				} else {
					props.set("dir", 4);
				}
				set_dir_prefix();
				animation.play(dir_prefix + "full", true);
			}	
		}
		return 0;
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [poof]);
		ACTIVE_Pods.remove(this);
		ACTIVE_PodSwitches.remove(this);
		is_vanish_flip = false; // prevent softlocks in baisn
		super.destroy();
	}
	public var flip_switch:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		dmgtype = props.get("dmgtype");
		vistype = props.get("vistype");
		damage = props.get("damage");
		tm_dead = props.get("tm_dead");
		is_big = props.get("is_big") == 1;
		set_dir_prefix();
		if (damage < BASE_DAMAGE) {
			damage = BASE_DAMAGE;
			props.set("damage", BASE_DAMAGE);
		}
		ACTIVE_PodSwitches.remove(this);
		is_vanish = false;
		if (props.get("is_vanish_switch") == 1) {
			is_vanish = true;
			ACTIVE_PodSwitches.add(this);
			if (VanishBlock.light_on) {
				dmgtype = 0;
				vistype = 3;
			} else {
				dmgtype = 1;
				vistype = 2;
			}
		}
		change_visuals();
		
		if (props.get("onOff_on_time") > 0) {
			onOff_off_time = props.get("onOff_off_time");
			onOff_on_time = props.get("onOff_on_time");
			onOff_t = props.get("onOff_start_offset");
		}
	}
	
	public static var is_vanish_flip:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		
		x = ix + offset.x;
		y = iy + offset.y;
		
		if (!did_init) {
			populate_parent_child_from_props();
			did_init = true;
			ACTIVE_Pods.add(this);
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [poof]);
		}
		
		if (poof_mode == 0) {
			// set to 1 when hit player
		} else if (poof_mode == 1) {
			poof.exists = true;
			if (dmgtype == VISTYPE_DEBUG_D) {
				poof.animation.play("d", true);
			} else {
				poof.animation.play("l", true);
			}
			poof.x = (x + width / 2) - poof.width / 2;
			poof.y = (y + height / 2) - poof.height / 2;
			//poof.x += 30;
			//poof.y += 30;
			//Log.trace(1);
			poof_mode = 2;
		} else if (poof_mode == 2) {
			//Log.trace(2);
			if (poof.animation.finished) {
				poof_mode = 0;
				poof.exists = false;
				
			}
		}
		
		if (onOff_on_time > 0) {
			onOff_t += elapsed;
			if (onOff_t > onOff_on_time + onOff_off_time) {
				onOff_t = 0;
				
			}
		}
		
		super.update(elapsed);
		
		var transition_time:Float = 0.1;
		switch (state) {
			case MODE_ALIVE:
				
				
				if (1 == props.get("is_vanish_switch")) {
					if (R.player.overlaps(this) || flip_switch) {
						flip_switch = false;
						VanishBlock.light_on = !VanishBlock.light_on;
						is_vanish_flip = true;
						ID = 2;
						R.player.add_light(0, 6, x + width / 2, y + width / 2);
						R.sound_manager.play(SNDC.pop);
					}
					if (is_vanish_flip) {
						if (dmgtype == 0) {
							vistype = 2; dmgtype = 1;
						} else if (dmgtype == 1) {
							vistype = 3; dmgtype = 0;
						}
						change_visuals();
						
						animation.play(dir_prefix + "empty");
						state = MODE_DEAD;
					}
				}

				
					if (onOff_on_time > 0) {
						
						var full_time:Float = onOff_off_time + onOff_on_time;
						if (onOff_t <= onOff_on_time && onOff_t + elapsed > onOff_on_time) {
							animation.play(dir_prefix + "shrink");
							// 
						} else if (onOff_t <= onOff_on_time + transition_time && onOff_t + elapsed > onOff_on_time + transition_time) {
							animation.play(dir_prefix + "empty");
						} else if (onOff_t <= full_time - transition_time && onOff_t + elapsed > full_time - transition_time) {
							animation.play(dir_prefix + "grow");
						} else if (onOff_t == 0) {
							animation.play(dir_prefix + "full");
						}
					}
				
				if (R.player.overlaps(this)) {
					
					if (onOff_on_time > 0) {
						if (onOff_t >= onOff_on_time) { // can't hurt when in off phase
							return;
						}
					} 
					animation.play(dir_prefix + "empty");
					if (vistype == VISTYPE_DEBUG_L || VISTYPE_DEBUG_D == vistype) {
							hurt_player();
						if (children != []) {
							if (dmgtype == 0) {
								broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
							} else {
								broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
							}
						}
					} else {
						
					}
					state = MODE_DEAD;
				}
			case MODE_DEAD:
				// use this so that the touched thing has to be stpepd off of to revert anything
				
				var molecheck:Bool = true;
				for (m in Mole.ACTIVE_Mole) {
					if (m != null && m.overlaps(this)) {
						molecheck = false;
						break;
					}
				}
				// make it easier to tell when u step of
				width += 6;
				x -= 3;
				//Log.trace([molecheck, !R.player.overlaps(this), ID == 2, 1 == props.get("is_vanish_switch")]);
				if (molecheck && !R.player.overlaps(this) && ID == 2 && 1 == props.get("is_vanish_switch")) {
					is_vanish_flip = false;
				}
				if (R.player.overlaps(this) && t_dead == 0) {

				} else if (is_vanish_flip == false || 0 == props.get("is_vanish_switch")) {
					t_dead += FlxG.elapsed;
					if (0 == props.get("is_vanish_switch")) { // Pod, BigPod ONLY
						
						if (is_big) {
							if (t_dead == FlxG.elapsed) {
								animation.play(dir_prefix + "recover"); 
							} else {
								if (animation.finished) {
									t_dead = 0;
									scale.x = scale.y = 1;
									animation.play(dir_prefix + "full");
									state = MODE_ALIVE;
								}
							}
						} else if (onOff_on_time > 0) { // for on off pods
							if (onOff_t <= onOff_off_time+onOff_on_time-transition_time-elapsed && onOff_t + elapsed > onOff_on_time+onOff_off_time-transition_time-elapsed) {
								t_dead = 0;
								state = MODE_ALIVE;
							}
							
						} else {
							if (t_dead > 0.7) {
								t_dead = 0;
								scale.x = scale.y = 1;
								animation.play(dir_prefix + "full");
								state = MODE_ALIVE;
							} else {
								animation.play(dir_prefix + "recover");
							}
						}
					} else if (t_dead > 0.2) {
						t_dead = 0;
						scale.x = scale.y = 1;
						animation.play(dir_prefix + "full");
						state = MODE_ALIVE;
							ID = 0;
					} else {
						animation.play(dir_prefix + "recover");
					}
				}
				
				width -= 6;
				x += 3;
		}
		
	}
	
	private function hurt_player():Void {
		R.sound_manager.play(SNDC.pod_hit);
		switch (dmgtype) {
			case VISTYPE_DEBUG_D:
				if (R.player.add_dark(damage, 2, x + width / 2, y + width / 2) > 0) {
					if (poof_mode == 0) poof_mode = 1;
					if (is_big) {
						R.player.add_dark(damage);
						R.player.add_dark(damage);
						FlxG.cameras.shake(0.02, 0.1);
						R.player.skip_motion_ticks = 6;
					} else {
						R.player.skip_motion_ticks = 3;
					}
				}
			case VISTYPE_DEBUG_L:
				if (R.player.add_light(damage,3,x+width/2,y+width/2) > 0) {
					if (poof_mode == 0) poof_mode = 1;
					if (is_big) {
						R.player.add_light(damage);
						R.player.add_light(damage);
						FlxG.cameras.shake(0.02, 0.1);
						R.player.skip_motion_ticks = 6;
					} else {
						R.player.skip_motion_ticks = 3;
					}
				}
		}
	}
	
	function set_dir_prefix():Void 
	{
		dir_prefix = "";
		switch (props.get("dir")) {
			case 0:
				angle = 0;
			case 1:
				angle = 90;
			case 2:
				angle = 180;
			case 3:
				angle = 270;
			case 4:
				angle = 0;
				dir_prefix = "n_";
		}
	}
	
	public function generic_circle_overlap(cx:Float, cy:Float, cr:Float, _dmgtype:Int):Bool {
		if (MODE_DEAD == state) {
			return false;
		}
		if (FlxX.circle_flx_obj_overlap(cx, cy, cr, this)) {
			if (_dmgtype == 0 && vistype == 1) {
				return true;
			} else if (_dmgtype == 1 && vistype == 0) {
				return true;
			}
		}
		return false;
	}
	public function generic_overlap(o:FlxObject,dmgtype:Int =-1):Bool {
		if (MODE_DEAD == state) {
			return false;
		}
		if (o.overlaps(this)){
			if (dmgtype == 0 && vistype == 1) {
				return true;
			} else if (dmgtype == 1 && vistype == 0) {
				return true;
			} else if (dmgtype == -1) {
				return true;
			}
		}
		return false;
	}
	
	override public function draw():Void 
	{
		//var ox:Float = x;
		//var oy:Float = y;
		//x = Std.int(ox);
		//y = Std.int(oy);
		super.draw();
		//x = ox;
		//y = oy;
		
	}
	
}