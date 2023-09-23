package entity.trap;
import autom.SNDC;
import entity.npc.Mole;
import entity.npc.WirePoint;
import entity.player.HurtEffectGroup;
import entity.util.RaiseWall;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.MyState;
import entity.MySprite;
import flash.display.BitmapData;

/**
 * Changes your energy balance
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class SapPad extends MySprite
{

	public static var ACTIVE_REVERSE_SapPads:List<SapPad>;
	public static var ACTIVE_NORMAL_SapPads:List<SapPad>;
	private static inline var VISTYPE_DARK:Int = 0;
	private static inline var VISTYPE_LIGHT:Int = 1;
	
	public var dmg_type:Int = 0;
	public var dmg:Int = 1;
	public var dmg_rate:Float = 0.10;
	public var t_dmg_rate:Float = 0;
	public var mode:Int = 0;
	public var MODE_IDLE:Int = 0;
	public var MODE_SAPPING:Int = 1;
	public var held:Int = 0;
	
	//public static var SapPad_Spritesheet:BitmapData;
	
	public var detector:FlxObject;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		
		//if (SapPad_Spritesheet == null) {
			//SapPad_Spritesheet = Assets.getBitmapData("assets/sprites/trap/SapPad.png");
		//}
		// Init sprites here
		super(_x, _y, _parent, "SapPad");
		// Change visuals or add things here
		detector = new FlxObject(x + 2, y - 5, 12, 5);
		
	}
	
	override public function change_visuals():Void 
	{
		offset.x = 0;
		offset.y = 0;
		if (reversed) {
			AnimImporter.loadGraphic_from_data_with_id(this, 48, 32, name, "reverse"); 
			width = 16;
			height = 16;
			offset.x = 16;
			offset.y = 16;
		} else {
			switch (vistype) {
				case VISTYPE_DARK:
					AnimImporter.loadGraphic_from_data_with_id(this, 48, 32, name, "light_up"); // b/c you get light but give dark
					dmg_type = VISTYPE_DARK;
					width = 16;
					height = 16;
					offset.x = 16;
					offset.y = 16;
				case VISTYPE_LIGHT:
					AnimImporter.loadGraphic_from_data_with_id(this, 48, 32, name, "dark_up");
					width = 16;
					height = 16;
					offset.x = 16;
					offset.y = 16;
					dmg_type = VISTYPE_LIGHT;
			}
		}
		animation.play("idle", true);
	}
	
	public function try_to_give(light:Bool = false, amt:Int):Bool {
		if (vistype == VISTYPE_DARK) { // try to take dark
			if (light == true) {
				return false;
			} 
			held += amt;
		} else {
			if (light == false) {
				return false;
			}
			held += amt;
		}
		
		force_sap = true;
		return true;
	}
	
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis", VISTYPE_DARK);
		p.set("dmg", 1);
		p.set("dmg_rate", 0.04);
		p.set("children", "");
		p.set("reverse", 0);
		p.set("max_storage", 64);
		p.set("one_for_all", 1);
		//p.set("max_reverse_energy", 64);
		return p;
	}
	private var bar_init:Bool = false;
	public var reversed:Bool = false;
	private var max_storage:Int = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		max_storage = props.get("max_storage");
		dmg_rate = props.get("dmg_rate");
		dmg = props.get("dmg");
		vistype = props.get("vis");
		reversed = props.get("reverse") == 1;
		ACTIVE_REVERSE_SapPads.remove(this);
		did_reverse_init = false;
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		ACTIVE_REVERSE_SapPads.remove(this);
		ACTIVE_NORMAL_SapPads.remove(this);
		super.destroy();
		
		
	}
	
	private var stored_reverse_energy:Int = 0;
	private var fctr_animate:Int = 0;
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == "animate") {
			animation.play("sap_test", true);
		}
		if (reversed) {
			if (message_type == C.MSGTYPE_ENERGIZE_TICK_DARK) {
				if (max_storage*-1 < stored_reverse_energy){ stored_reverse_energy--;
				fctr_animate = -5;
				}
			} else if (message_type == C.MSGTYPE_ENERGIZE_TICK_LIGHT) {
				if (max_storage > stored_reverse_energy) {stored_reverse_energy++;
				fctr_animate = 5;
				}
			} else if (message_type == C.MSGTYPE_ENERGIZE_DARK) {
				fctr_animate = -5;
				stored_reverse_energy = max_storage * -1; 
				
			} else if (message_type == C.MSGTYPE_ENERGIZE_LIGHT) {
				fctr_animate = 5;
				stored_reverse_energy = max_storage;
			}
		}
		//Log.trace(stored_reverse_energy);
		return C.RECV_STATUS_OK;
	}
	
	// never goes past where it should
	public function get_energy_from_reverse(light:Bool = false, amt:Int):Int {
		var i:Int = 0;
		if (light) {
			if (stored_reverse_energy <= amt && stored_reverse_energy >= 0) {
				i = stored_reverse_energy;
				stored_reverse_energy = 0;
				if (i >= 1) {
					return 1;
				}
				return 0;
			} else  if (stored_reverse_energy > amt) {
				stored_reverse_energy -= amt;
				stored_reverse_energy = 0;
				//return amt;	
				return 1;
			}
		} else {
			if (stored_reverse_energy >= -amt && stored_reverse_energy <= 0) {
				i = -stored_reverse_energy;
				stored_reverse_energy = 0;
				if (i >= 1) {
					return 1;
				}
				return 0;
			} else if (stored_reverse_energy < -amt) {
				stored_reverse_energy += amt;
				stored_reverse_energy = 0;
				//return amt;
				return 1;
			}
		}
		return 0;
	}
	
	// Called by some other object to get energy from an out-pad
	// pos = light, neg = dark
	public function external_get_reverse(amt:Int = 1):Int {
		
		if (stored_reverse_energy > 0) {
			return get_energy_from_reverse(true, amt);
		} 
		return -1*get_energy_from_reverse(false, amt);
		
	}
	
	private var did_reverse_init:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		detector.x = x + 2;
		detector.y = y - 5;
		
		
		if (!did_reverse_init) {
			did_reverse_init = true;
			if (reversed) {
				ACTIVE_REVERSE_SapPads.add(this);
			}  else {
				ACTIVE_NORMAL_SapPads.add(this);
			}
		}
		if (!did_init) {
			did_init = true;
			populate_parent_child_from_props();
		}
		
		if (reversed) {
			if (R.player.overlaps(detector)) {
				R.sound_manager.play(SNDC.SapPad);
				if (dmg_type == VISTYPE_DARK) {
					var amt:Int = get_energy_from_reverse(true, 1);
					R.player.add_light(amt,HurtEffectGroup.STYLE_NONE);
				} else if (dmg_type == VISTYPE_LIGHT) {
					var amt:Int = get_energy_from_reverse(false, 1);
					R.player.add_dark(amt,HurtEffectGroup.STYLE_NONE);
				}
			}
			if (fctr_animate > 0) {
				animation.play("sapping_l");
				fctr_animate --;
			} else if (fctr_animate < 0) {
				animation.play("sapping_d");
				fctr_animate ++;
			} else {
				animation.play("idle");
			}
			
			if (children.length > 0) {
				if (dmgtype == VISTYPE_LIGHT) {
					var amt:Int = get_energy_from_reverse(false, children.length);
					if (amt > 0) {
						broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
					}
				} else if (dmgtype == VISTYPE_DARK ) {
					var amt:Int = get_energy_from_reverse(true, children.length);
					if (amt > 0) {
						broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
					}
				}
				
			}
			super.update(elapsed);
			return;
		}
		
		
		if (R.player.overlaps(detector) && !R.player.is_jump_state_air()) {
			R.player.y = R.player.last.y = y - 4 - R.player.height;
			R.player.velocity.y = 0;
			R.player.touching |= 0x1000;
		}
		
		switch (mode) {
			case _ if (MODE_IDLE == mode):
				//if (R.player.shield_overlaps(detector, 2)) {
					//
				//} else 
				if (R.player.overlaps(detector) || force_sap) {
					
					
					var no_need_ct:Int = 0;
					// Find how many children need energy. If that number is 0, don't hurt the player.
					for (i in 0...children.length) {
						if (children[i] != null) {
							if (Std.is(children[i], RaiseWall)) {
								var r:RaiseWall = cast children[i];
								if (r.energy >= r.needed_energy) {
									no_need_ct ++;
								}
							} else if (Std.is(children[i], SapPad)) {
								var s:SapPad = cast children[i];
								if (s.reversed) {
									var j:Int = -1;
									for (m in Mole.ACTIVE_Mole) {
										j++;
										if (m == null) continue;
										// The childed sappad doesn't overlap any moles.
										if (!s.detector.overlaps(m))  {
											if (j == Mole.ACTIVE_Mole.length - 1) {
												no_need_ct ++;
											}
										} else {
											break;
										}
									}
								}
							}else if (Std.is(children[i], BarbedWire)) {
								var bw:BarbedWire = cast children[i];
								if (bw.energy >= bw.max_energy || -bw.energy <= bw.max_energy) {
									no_need_ct++;
								}
							
							} else if (Std.is(children[i], WirePoint)) {
								no_need_ct++;
							}
						}
					}
					
					
					// Need to have a child to not hurt player, so if there's nothing connected nothing breaks
					if (no_need_ct > 0 && no_need_ct == children.length) {
						
					} else if (R.player.energy_bar.allow_move) {
						animation.play("sapping");
						mode = MODE_SAPPING;
					}
				}
			case _ if ( MODE_SAPPING == mode):
				
				
					var no_need_ct:Int = 0;
					// Find how many children need energy. If that number is 0, don't hurt the player.
					for (i in 0...children.length) {
						if (children[i] != null) {
							if (Std.is(children[i], RaiseWall)) {
								var r:RaiseWall = cast children[i];
								if (r.energy >= r.needed_energy) {
									no_need_ct ++;
									
								}
							} else if (Std.is(children[i], SapPad)) {
								var s:SapPad = cast children[i];
								if (s.reversed) {
									var j:Int = -1;
									for (m in Mole.ACTIVE_Mole) {
										j++;
										if (m == null) continue;
										// The childed sappad doesn't overlap any moles.
										if (!s.detector.overlaps(m))  {
											if (j == Mole.ACTIVE_Mole.length - 1) {
												no_need_ct ++;
											}
										} else {
											break;
										}
									}
								}
							} else if (Std.is(children[i], BarbedWire)) {
								var bw:BarbedWire = cast children[i];
								if (bw.energy >= bw.max_energy || -bw.energy <= bw.max_energy) {
									no_need_ct++;
								}
							
							} else if (Std.is(children[i], WirePoint)) {
								no_need_ct++;
							}
						}
					}
					
					// Need to have a child to not hurt player, so if there's nothing connected nothing breaks
					if (no_need_ct > 0 && no_need_ct == children.length) {
						animation.play("idle");
						 mode = MODE_IDLE;
					}
					
				
				//if (R.player.shield_overlaps(detector, 2)) {
					//play("idle");
					//mode = MODE_IDLE;
				//} else
				if ((!R.player.overlaps(detector) && !force_sap) || (parent_state.dialogue_box.is_active() == true)) {
					animation.play("idle");
					mode = MODE_IDLE;
				}
				force_sap = false;
				
				
				
				t_dmg_rate += FlxG.elapsed;
				if (t_dmg_rate > dmg_rate) {
					if (R.player.overlaps(detector)) {
						
						R.sound_manager.play(SNDC.SapPad);
						if (dmg_type == VISTYPE_DARK) { // meaning it absorbs dark
							held += R.player.add_light(dmg,HurtEffectGroup.STYLE_NONE);
						} else if (dmg_type == VISTYPE_LIGHT) {
							held += R.player.add_dark(dmg,HurtEffectGroup.STYLE_NONE);
						}
						R.player.energy_bar.player_shade_timer = 0.15;
					}
					t_dmg_rate -= dmg_rate;
				}
				
				if (held >= children.length) {
					if (props.get("one_for_all") == 1) {
						held--;
					} else {
						held -= children.length;
					}
					if (dmg_type == VISTYPE_DARK) {
						broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
					} else if (dmg_type == VISTYPE_LIGHT) {
						broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
					}
				}
		}
		super.update(elapsed);
	}
	private var force_sap:Bool = false;
	public static var sap_shutup:Bool = false;
}
