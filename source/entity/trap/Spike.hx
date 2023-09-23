package entity.trap;
import entity.MySprite;
import global.C;
import haxe.Constraints.FlatEnum;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Spike extends MySprite
{

	public static var ACTIVE_Spikes:FlxTypedGroup<Spike>;
	private var hitbox:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		if (ACTIVE_Spikes == null) ACTIVE_Spikes = new FlxTypedGroup<Spike>();
		hitbox = new FlxSprite(0, 0);
		hitbox.immovable = true;
		super(_x, _y, _parent, "Spike");
		
	}
	
	private var dir:Int = 0;
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "0");
				dmgtype = 0;
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "1");
				dmgtype = 1;
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, Std.string(vistype));
		}
		
		
		switch (dir) {
			case 0:
				animation.play("u",true);
				hitbox.makeGraphic(8, 10, 0xffff0000);
			case 1:
				animation.play("r",true);
				hitbox.makeGraphic(10,8, 0xffff0000);
			case 2:
				animation.play("d",true);
				hitbox.makeGraphic(8, 10, 0xffff0000);
			default:
				animation.play("l",true);
				hitbox.makeGraphic(10,8, 0xffff0000);
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		// Set default properties here
		p.set("vistype", 0);
		p.set("dir", 0); // urdl
		p.set("dmgtype", 0);
		p.set("hor_bounce_vel", 166);
		//p.set("vert_bounce_vel", 180);
		p.set("bounce_vel_max", 250);
		p.set("bounce_vel_mid", 210);
		p.set("bounce_vel_min", 125);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		if (props.exists("vert_bounce_vel")) {
			props.remove("vert_bounce_vel");
		}
		vistype = props.get("vistype");
		dir = props.get("dir");
		dmgtype = props.get("dmgtype");
		change_visuals();
		// Do stuff
	}
	
	override public function destroy():Void 
	{
		ACTIVE_Spikes.remove(this, true);
		HF.remove_list_from_mysprite_layer(this, parent_state, [hitbox]);
		if (has_bounce_lock) {
			bounce_locked = false;
		}
		super.destroy();
	}
	
	private  var has_bounce_lock:Bool = false;
	private static var bounce_locked:Bool = false;
	private var lock_x:Int = -1;
	private var lock_y:Int = -1;
	private var has_position_lock:Bool = false;
	private static var position_locked:Bool = false;
	private static var bounce_ctr:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			ACTIVE_Spikes.add(this);
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [hitbox]);
		}
		if (R.editor.editor_active) {
			hitbox.visible = true;
		} else {
			hitbox.visible = false;
		}
		
		move_hitbox();
		

		if (has_bounce_lock) {
			if (R.player.get_shield_dir() != 2 || R.player.is_on_the_ground() || !R.player.is_in_main_mode()) {
				has_bounce_lock = false;
				bounce_locked = false;
			}
		}
		if (bounce_ctr > 0) {
			if (R.player.is_on_the_ground() || !R.player.is_in_main_mode()) {
				bounce_ctr = 0;
			}
		}
		
		
		if (R.player.get_shield_dir() == 2 && has_position_lock) {
			if (lock_x == -1) {
				lock_x = Std.int(R.player.x);
				lock_y = Std.int(R.player.y);
			}
			R.player.velocity.y = 0;
			R.player.x = R.player.last.x =  lock_x;
			R.player.y = R.player.last.y = lock_y;
		} else if (has_position_lock) {
			has_position_lock = false;
			position_locked = false;
			lock_x = lock_y = -1;
			R.player.velocity.y = -props.get("bounce_vel_min") + 10;
		}
		
		
		// quick optimization
		if (FlxX.l1_norm_from_mid(hitbox, R.player) < 25) {
			
			var touches:Bool = false;
			
			var vy:Float = R.player.velocity.y;
			var vx:Float = R.player.velocity.x;
			touches = FlxObject.separate(hitbox, R.player);
			if (dir == 1 || dir == 3 ) {
				var sd:Int = R.player.get_shield_dir();
				if (sd == 1 || sd == 3) {
					if (hitbox.overlaps(R.player.get_active_shield_logic())) {
						touches = true;
					}
				}
			}
			
			if (touches) {
					var no_hurt:Bool = false;
					switch (dir) {
						case 0:
							//Don't touch spike if you are moving upwards or ont he ground
							if (R.player.is_on_the_ground()  || R.player.velocity.y < 0) {
								return;
							}
							// Bounce locks means you should
							if (bounce_locked == false) {
								
								if (bounce_ctr == 0) {
									bounce_ctr ++ ;
									R.player.velocity.y = -props.get("bounce_vel_max") + 10;
								} else if (bounce_ctr == 1) {
									bounce_ctr ++;
									R.player.velocity.y = -props.get("bounce_vel_mid") + 10;
								} else if (bounce_ctr == 2) {
									bounce_ctr++;
									R.player.velocity.y = -props.get("bounce_vel_min") + 10;
								} else {
									if (R.player.get_shield_dir() == 2) {
										bounce_locked = true;
										has_bounce_lock = true;	
									} else {
										R.player.velocity.y = -props.get("bounce_vel_min") + 10;
									}
								}
							}  else if (position_locked == false) {
								has_position_lock = true;
								position_locked = true;
							}
							if (R.player.get_shield_dir() == 2) {
								no_hurt = true;
							}
						case 1:
							if (vx> 0)  {
								return;
							}
							R.player.give_more_air_vel_change_delay(5);
							R.player.velocity.x = props.get("hor_bounce_vel");
							//if (fctr_dbl_bounce > 0) {
								//R.player.do_vert_push( -props.get("bounce_vel_max"));
							//}
							R.player.do_hor_push(Std.int(R.player.velocity.x), false, false, 10);
							if (R.player.get_shield_dir() == 3) {
								no_hurt = true;
							}
						case 2:
							if (vy > 0) {
								return;
							}
							R.player.y = y + height + 1;
							R.player.do_vert_push(props.get("bounce_vel_max"));
							
							if (R.player.get_shield_dir() == 0) {
								no_hurt = true;
							}
						case 3: // Left
							if (vx< 0) {
								return;
							}
							R.player.give_more_air_vel_change_delay(5);
							R.player.velocity.x = -props.get("hor_bounce_vel");
							//if (fctr_dbl_bounce > 0) {
								//R.player.do_vert_push( -props.get("bounce_vel_max"));
							//}
							R.player.do_hor_push(Std.int(R.player.velocity.x), false, false, 10);
							if (R.player.get_shield_dir() == 1) {
								no_hurt = true;
							}
					}
					
					
					if (!no_hurt) {
						if (dmgtype == 0) {
							R.player.add_dark(128);
						} else {
							R.player.add_light(128);
						}
					} 
			}
		}
		
		super.update(elapsed);
	}
	override public function recv_message(message_type:String):Int 
	{
		//Log.trace(message_type);
		if (message_type == C.MSGTYPE_MOVED_BY_EDITOR) {
			if (parent_state.tm_bg.getTileCollisionFlags(x, y + 17) != FlxObject.NONE) {
				props.set("dir", 0);
				animation.play("u");
			} else if (parent_state.tm_bg.getTileCollisionFlags(x, y -14) != FlxObject.NONE) {
				props.set("dir", 2);
				animation.play("d");
			} else if (parent_state.tm_bg.getTileCollisionFlags(x-10, y) != FlxObject.NONE) {
				props.set("dir", 1);
				animation.play("r");
			} else if (parent_state.tm_bg.getTileCollisionFlags(x+17, y) != FlxObject.NONE) {
				props.set("dir", 3);
				animation.play("l");
			}
			move_hitbox();
		}
		return 0;
	}
	
	
	public function generic_circle_overlap(cx:Float,cy:Float,cr:Float,only_dmgtype:Int):Bool {
		if (this.dmgtype != only_dmgtype) {
			return false;
		} 
		
		if (FlxX.l1_norm_from_mid(hitbox, R.player) > 48) {
			return false;
		}
		
		if (FlxX.circle_flx_obj_overlap(cx,cy,cr,hitbox)) {
			return true;
		}
		return false;
	}
	public function generic_overlap(o:FlxObject,dmgtype:Int=-1):Bool {
		if (this.dmgtype != dmgtype && dmgtype != -1) {
			return false;
		} 
		
		if (o.overlaps(hitbox)) {
			return true;
		}
		
		return false;
	}
	
	function move_hitbox():Void 
	{
		switch (dir) {
			case 0: hitbox.x = x + (width - hitbox.width) / 2; hitbox.y = y + 16 - hitbox.height;
			case 1: hitbox.y = y + (height - hitbox.height) / 2; hitbox.x = x;
			case 2: hitbox.x = x + (width - hitbox.width) / 2; hitbox.y = y;
			case 3: hitbox.y = y + (height - hitbox.height) / 2; hitbox.x = x + 16 - hitbox.width;
		}
	}
	
}