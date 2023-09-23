package entity.util;
import autom.SNDC;
import entity.MySprite;
import entity.trap.MirrorLaser;
import entity.trap.Pew;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import openfl.Assets;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import openfl.display.BlendMode;
import state.MyState;

/**
 * An OrbSlot broadcasts an energize message to its children
 * when an EnergyOrb is placed inside of it.
 * @author Melos Han-Tani
 */


class OrbSlot extends MySprite
{
	public static var ACTIVE_OrbSlots:FlxGroup; 
	
	public var VIS_DEBUG_L:Int = 0;
	public var VIS_DEBUG_D:Int = 1;
	public var VIS_DEBUG_both:Int = 2;
	
	public var accept_type:Int = 0;
	
	public var orbTop:FlxSprite;
	private var t_animate:Float = 0;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		

		orbTop = new FlxSprite();
		if (ACTIVE_OrbSlots == null) {
			ACTIVE_OrbSlots = new FlxGroup(0, "ACTIVE_OrbSlots");
		}
		
		super(_x, _y, _parent, "OrbSlot");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case _ if (vistype == VIS_DEBUG_L):
				accept_type = VIS_DEBUG_L;
			case _ if (vistype == VIS_DEBUG_D):
				accept_type = VIS_DEBUG_D;
			case _ if (vistype == VIS_DEBUG_both):
				accept_type = VIS_DEBUG_both;
		}
		AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "OrbSlot");
		AnimImporter.loadGraphic_from_data_with_id(orbTop, 16, 16, "OrbSlot");
		orbTop.blend = BlendMode.ADD;
		
		// Change visuals
	}
	
	private var needed_en:Int = 0;
	private var cur_en:Int = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("children", "");
		p.set("vis", VIS_DEBUG_D);
		p.set("needed_en", 0);
		p.set("transmit_en", 16);
		p.set("angle", 0);
		// Set default properties here
		return p;
	}
	
	private var transmit_en:Int = -1;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		transmit_en = props.get("transmit_en");
		vistype = props.get("vis");
		change_visuals();
		needed_en = props.get("needed_en");
		angle = orbTop.angle = props.get("angle");
		if (did_init) {
			populate_parent_child_from_props();
		}
		// Do stuff
	}
	
	override public function destroy():Void 
	{
		ACTIVE_OrbSlots.remove(this, true);
		HF.remove_list_from_mysprite_layer(this, parent_state, [orbTop]);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			ACTIVE_OrbSlots.add(this);
			populate_parent_child_from_props();
			HF.add_list_to_mysprite_layer(this, parent_state, [orbTop]);
			did_init = true;
		}
		
		orbTop.move(x, y);
		if (t_animate < 0) {
			orbTop.animation.play("dark");
			orbTop.alpha += 0.05;
			t_animate += elapsed;
			if (t_animate > 0) t_animate = 0;
		} else if (t_animate > 0) {
			orbTop.animation.play("light");
			orbTop.alpha += 0.05;
			t_animate -= elapsed;
			if (t_animate < 0) t_animate = 0;
		} else {
			orbTop.alpha -= 0.05;
		}
		
		for (pew in Pew.ACTIVE_Pews.members) {
			if (pew == null) continue;
			if (accept_type == VIS_DEBUG_both) {
				if (pew.generic_overlap(this, 0)) {
					R.sound_manager.play(SNDC.pew_wall,1,true,this);
					R.sound_manager.play(SNDC.particle_hit,1,true,this);
					transmit(0);
				}
				if (pew.generic_overlap(this, 1)) {
					R.sound_manager.play(SNDC.pew_wall,1,true,this);
					R.sound_manager.play(SNDC.particle_hit,1,true,this);
					transmit(1);
				}
			} else if (accept_type == VIS_DEBUG_D) {
				if (pew.generic_overlap(this, 0)) {
					R.sound_manager.play(SNDC.pew_wall,1,true,this);
					R.sound_manager.play(SNDC.particle_hit,1,true,this);
					transmit(0);
				}
				
			} else if (accept_type == VIS_DEBUG_L) {
				if (pew.generic_overlap(this, 1)) {
					R.sound_manager.play(SNDC.pew_wall,1,true,this);
					R.sound_manager.play(SNDC.particle_hit,1,true,this);
					transmit(1);
				}
			}
		}
		
		width = height = 10;
		x += 3; y += 3;
		for (ml in MirrorLaser.ACTIVE_MirrorLasers) {
			var q:Int = 0;
			if (accept_type == VIS_DEBUG_both) {
				q = -1;
			} else if (accept_type == VIS_DEBUG_D) {
				q = 0;
			} else {
				q = 1;
			}
			if (ml.generic_overlap(this, true, q)) {
					R.sound_manager.play(SNDC.pew_wall,1,true,this);
					R.sound_manager.play(SNDC.particle_hit,1,true,this);
				if (ml.lastcolor == 1) { // dark bul
					transmit(0);
				} else {
					transmit(1);
				}
				break;
			}
		}
		x -= 3; y -= 3;
		width = height = 16;
		
		if (laser_on) {
			
			t_laser_send += FlxG.elapsed;
			if (t_laser_send > 1) t_laser_send = 1;
			var nr:Int =  Std.int(transmit_en * t_laser_send - laser_sent);
			for (i in 0...nr) {
				if (laser_send_type == 0) {
					t_animate = -1;
					broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
				} else {
					t_animate = 1;
					broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
				}
				laser_sent++;
			}
			if (t_laser_send == 1) {
				t_laser_send = laser_sent = 0;
			}
			
		} else {
			t_laser_send = laser_sent = 0;
		}
		laser_on = false;
		super.update(elapsed);
		
	}
	private var t_laser_send:Float = 0;
	private var laser_sent:Int = 0;
	
	private function transmit(dmgtype:Int):Void {
		if (transmit_en == -1) {
			if (dmgtype == 0) {
				recv_message(C.MSGTYPE_ENERGIZE_DARK);
			} else {
				recv_message(C.MSGTYPE_ENERGIZE_LIGHT);
			}
		} else {
			
			for (i in 0...transmit_en) {
				if (dmgtype == 0) {
					t_animate = -1;
					broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
				} else {
					t_animate = 1;
					broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
				}
			}
		}
	}
	private var laser_on:Bool = false;
	private var laser_send_type:Int = 0;
	override public function recv_message(message_type:String):Int 
	{
		switch (accept_type) {
			case _ if (accept_type == VIS_DEBUG_D):
				if (message_type == C.MSGTYPE_ENERGIZE_DARK) {
					if (cur_en < needed_en) cur_en++;
					if (cur_en == needed_en) {
						broadcast_to_children(C.MSGTYPE_ENERGIZE_DARK);
						
							t_animate = -1;
					}
					return C.RECV_STATUS_OK;
				} else {
					if (cur_en > 0) cur_en--;
					return C.RECV_STATUS_OK;
				}
			case _ if (accept_type ==VIS_DEBUG_L):
				if (message_type == C.MSGTYPE_ENERGIZE_LIGHT) {
					if (cur_en < needed_en) cur_en++;
					if (cur_en == needed_en) {
						broadcast_to_children(C.MSGTYPE_ENERGIZE_LIGHT);
					t_animate = 1;
					}
					return C.RECV_STATUS_OK;
				} else {
					if (cur_en > 0) cur_en--;
					return C.RECV_STATUS_OK;
				}
			case _ if (accept_type == VIS_DEBUG_both):
				if (cur_en < needed_en) cur_en++;
				if (cur_en == needed_en) {
					if (message_type == C.MSGTYPE_ENERGIZE_LIGHT) {
						broadcast_to_children(C.MSGTYPE_ENERGIZE_LIGHT);
						
						t_animate = 1;
					} else if (message_type == C.MSGTYPE_ENERGIZE_DARK) {
						broadcast_to_children(C.MSGTYPE_ENERGIZE_DARK);
						t_animate = -1;
					}
				}
				return C.RECV_STATUS_OK;
		}
		return C.RECV_STATUS_NOGOOD;
	
	}	
	public function lrecv_message(message_type:String ):Void {
		if (transmit_en < 0) return;
		switch (accept_type) {
			case _ if (accept_type == VIS_DEBUG_D):
				if (message_type == C.MSGTYPE_ENERGIZE_DARK) {
					laser_on = true;
					laser_send_type = 0;
				}
			case _ if (accept_type ==VIS_DEBUG_L):
				if (message_type == C.MSGTYPE_ENERGIZE_LIGHT) {
					laser_on = true;
					laser_send_type = 1;
				}
			case _ if (accept_type == VIS_DEBUG_both):
				if (message_type == C.MSGTYPE_ENERGIZE_LIGHT) {
					laser_on = true;
					laser_send_type = 1;
				} else if (message_type == C.MSGTYPE_ENERGIZE_DARK) {
					laser_on = true;
					laser_send_type = 0;
				}
		}
	}
	
}