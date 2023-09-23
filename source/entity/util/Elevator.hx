package entity.util;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

import autom.SNDC;
import entity.MySprite;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxObject;
import global.EF;
import haxe.Log;
import help.HF;
import state.MyState;
import help.AnimImporter;
import flixel.FlxG;
import flixel.FlxSprite;
import state.TestState;

class Elevator extends MySprite
{

	private var console:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		console = new FlxSprite();
		super(_x, _y, _parent, "Elevator");
		x = ix; y = iy;
	}
	
	private var anim_prefix:String = "";
	override public function change_visuals():Void 
	{
		if (vistype == 1) vistype = 0;
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "Elevator", "0");
				// if no user-set prefix, try to use default
				if (props.get("override_anim_prefix") == "") {
					if (R.TEST_STATE.MAP_NAME.indexOf("_") != -1) {
						var pref:String = R.TEST_STATE.MAP_NAME.split("_")[0];
						if (animation._animations.exists(pref + "_" + "idle")) {
							anim_prefix = pref + "_";
							//Log.trace(anim_prefix);
						}
					} else {
						anim_prefix = "";
					}
				}
				animation.play(anim_prefix+ "idle");
				AnimImporter.loadGraphic_from_data_with_id(console, 16, 16, "ElevatorConsole", "0");
			default:
				AnimImporter.loadGraphic_from_data_with_id(console, 16, 16, "ElevatorConsole", "0");
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, "Elevator",vistype);
		}
		console.animation.play("idle");
		height = 16;
		offset.y = 16;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("starts_at_top", 1);
		p.set("rise_height", 8);
		p.set("rise_vel", 60);
		p.set("children", "");
		p.set("has_console", 1);
		p.set("override_anim_prefix", "");
		p.set("is_basin", 0);// lol
		p.set("door_info", "none");
		return p;
	}
	private var mode:Int = 0;
	private var MODE_TOP:Int = 0;
	private var MODE_MOVING:Int = 1;
	private var MODE_BOTTOM:Int = 2;
	
	private var starts_at_top:Bool = false;
	private var has_console:Bool = false;
	private var rise_height:Float = 0;
	public static var num_Active_elevators:Int = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		if (props.get("override_anim_prefix") != "") {
			anim_prefix = props.get("override_anim_prefix");
		}
		rise_height = props.get("rise_height") * 16.0;
		velocity.set(0, 0);
		mode = MODE_BOTTOM;
		starts_at_top = false;
		if (props.get("starts_at_top") == 1) {
			mode = MODE_TOP;
			starts_at_top = true;
		}
		has_console = props.get("has_console") == 1;
		if (!has_console) console.visible = false;
		allowCollisions = FlxObject.UP;
		immovable = true;
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		if (mode == MODE_MOVING) {
			num_Active_elevators--;
		}
		HF.remove_list_from_mysprite_layer(this, parent_state, [console]);
		super.destroy();
	}
	
	private var force_activate:Bool = false;
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == "b") {
			force_activate = true;
		}
		
		return 1;
	}
	private var undo_id:Int = -1;
	private var undo_ticks:Int = 0;
	private var overlapping_accepter:Bool = false;
	private var overlapping_console:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		
		if (ID == 3) {
			return;
		}
		// Transitioning after talking to door-elevator
		
		if (ID == 2) {
			//transition after bubble in basin talk
				if (1 == props.get("is_basin")) {
					if (parent_state.dialogue_box.is_active() == false) {
						R.sound_manager.play(SNDC.Elevator);
						var ts:TestState = R.TEST_STATE;
						R.player.enter_door();
						ts.DO_CHANGE_MAP = true;
						ID = 3;
						if (!R.story_mode) {
							ts.next_map_name = "BASIN_G1";
							ts.next_player_x = Std.int(17 * 16.0);
							ts.next_player_y = Std.int(9 * 16.0 - R.player.height + 1);
						} else {
							ts.next_map_name = "BASIN_B";
							ts.next_player_x = Std.int(5 * 16.0);
							ts.next_player_y = Std.int(12 * 16.0 - R.player.height + 1);
						}
					}
				}
			
			return;
		}
		if (parent_state.dialogue_box.is_active()) {
			
			if (props.get("door_info").length > 5) {
				if (ID == 1) {
					
					
					if (parent_state.dialogue_box.last_yn != -1) {
						if (parent_state.dialogue_box.last_yn == 0) {
							var ts:TestState = R.TEST_STATE;
							ts.DO_CHANGE_MAP = true;
							ts.next_map_name = props.get("door_info").split(",")[0];
							ts.next_player_x = Std.parseInt(props.get("door_info").split(",")[1]) * 16;
							ts.next_player_y = Std.int(Std.parseInt(props.get("door_info").split(",")[2]) * 16 - R.player.height + 1);
							R.player.enter_door();
							R.sound_manager.play(SNDC.Elevator);
							ID = 2;
						} else {
							ID = 0;
						}
					}
				}
				
				super.update(elapsed);

				return;
			}
		}
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [console]);
			populate_parent_child_from_props();
		}
		
		console.x = ix - 16;
		console.y = iy - 16;
		
		FlxObject.separateY(this, R.player);
		

		// Interact with console to activate
		if (mode != MODE_MOVING && has_console) {
			// logical console overlap moves based on state
			if (mode == MODE_BOTTOM && !starts_at_top) console.y -= rise_height;
			if (mode == MODE_TOP && starts_at_top) console.y += rise_height;
			
			if (console.overlaps(R.player) && !force_activate) {
				if (!overlapping_console) {
					R.player.activate_npc_bubble("speech_appear");
					overlapping_console = true;
				} else {
					if (R.input.jpCONFIRM) {
						
						
						R.sound_manager.play(SNDC.Elevator);
						force_activate = true;
						overlapping_console = false;
						broadcast_to_children("b");
						R.player.activate_npc_bubble("speech_disappear");
					}
				}
			} else if (overlapping_console) {
				overlapping_console = false;
				R.player.activate_npc_bubble("speech_disappear");
			}
			
			if (mode == MODE_TOP && starts_at_top) console.y -= rise_height;
			if (mode == MODE_BOTTOM && !starts_at_top) console.y += rise_height;
		}
		
		
		R.player.y += 2;
		var player_overlaps_if_nudged:Bool = R.player.overlaps(this);
		R.player.y -= 2;
		
		// Interact with elevator to activate
		
		
		// BUBBLE CODE ONLY
		// Turn on the bubble when distances of x-midpoints are within 8 (thus, overlapping accepter)
		if (!overlapping_accepter && (touching != 0 || player_overlaps_if_nudged) && (mode == MODE_TOP || mode == MODE_BOTTOM ) && Math.abs((this.x+this.width/2) - (R.player.x+R.player.width/2)) < 8) {
			R.player.activate_npc_bubble("speech_appear");
			overlapping_accepter = true;
			
		
			//  overlapping the acceptercode. bubble should be on here.
		} else if (overlapping_accepter) {
			
			// If you are not colliding with elevator, nor overlapping it...
				// turn off bubble, flip bool for overlapping accepter.
			if (Math.abs((this.x + this.width / 2) - (R.player.x + R.player.width / 2)) > 8) {
				R.player.activate_npc_bubble("speech_disappear");
				overlapping_accepter = false;
			} else if (touching == 0 && !player_overlaps_if_nudged) {
				R.player.activate_npc_bubble("speech_disappear");
				overlapping_accepter = false;
			// otherwise, preesing confirm to turn on elevator..
			} else if (R.input.jpCONFIRM) {
				
				/* ********This is a door elevator************/
				if (props.get("door_info").length > 5) {
					parent_state.dialogue_box.start_dialogue("forest", "aliph_lift", 2);
					ID = 1;
					R.player.activate_npc_bubble("speech_disappear");
					return;
				/* *********This is special basin powre-plant lift eveleator***********/
				} else if (props.get("is_basin") == 1) {
					if (R.player.is_in_cutscene() == true) {
						return;
					} else {
					if (R.inventory.is_item_found(47)) {
						if (R.event_state[EF.forest_done] == 1) {
							parent_state.dialogue_box.start_dialogue("forest", "aliph_lift", 5);
							R.player.activate_npc_bubble("speech_disappear");
							return;
						}
						if (R.player.has_bubble) {
							R.player.activate_npc_bubble("speech_disappear");
							parent_state.dialogue_box.start_dialogue("forest", "aliph_lift", 4);
							ID = 2;
							return;
							
						} else {
							parent_state.dialogue_box.start_dialogue("forest", "aliph_lift", 1);
							R.player.activate_npc_bubble("speech_disappear");
							return;
						}
					} else {
						parent_state.dialogue_box.start_dialogue("forest", "aliph_lift", 0);
							R.player.activate_npc_bubble("speech_disappear");
						return;
					}
					}
					
				/* ********************/
				} else {
					overlapping_accepter = false;
					R.player.activate_npc_bubble("speech_disappear");
					R.sound_manager.play(SNDC.Elevator);
				}
				
				/* ********************/
			}
		}
		
		
		if (force_activate) {
			touching = FlxObject.UP;
		}
		
		if (undo_id > -1) {
			undo_ticks++;
			if (undo_ticks > 35) {
				parent_state.tm_bg.setTileProperties(undo_id, FlxObject.UP);
				parent_state.tm_bg2.setTileProperties(undo_id, FlxObject.UP);
				undo_id = -1;
			}
		}
		
		
		if (mode == MODE_TOP) {
			if (ID >= 11 && ID <= 45) { // avoid anim thingy bug
				if (!R.input.a1 && !R.input.jpA1) {
					R.player.touching = FlxObject.DOWN;
					//Log.trace(123);
				} else {
					ID = 45;
				}
				ID++;
			} else {
				ID = 0;
			}
			
			if (touching != 0 || player_overlaps_if_nudged) {
				if ((R.input.jpCONFIRM && Math.abs((this.x+this.width/2) - (R.player.x+R.player.width/2)) <= 8)|| force_activate) {
					mode = MODE_MOVING;
					ID = 0;
					num_Active_elevators++;
					if (!force_activate) {
						broadcast_to_children("b");
					}
					animation.play(anim_prefix + "down");
					force_activate = false;
					velocity.y = props.get("rise_vel");
					acceleration.y = velocity.y;
					maxVelocity.y = velocity.y;
					velocity.y = 0;
					var tm:FlxTilemapExt = null;
					for (tm in [parent_state.tm_bg,parent_state.tm_bg2]) {
					if (tm.getTileCollisionFlags(R.player.x + R.player.width / 2, R.player.y + R.player.height) == FlxObject.UP) {
						undo_id = tm.getTileID(R.player.x + R.player.width / 2, R.player.y + R.player.height);
						tm.setTileProperties(undo_id , 0x0000);
						undo_ticks = 0;
					}
					}
				}
			} 
		} else if (mode == MODE_BOTTOM) { 
			if (touching != 0 || player_overlaps_if_nudged) {
				if ((R.input.jpCONFIRM  && Math.abs((this.x + this.width / 2) - (R.player.x + R.player.width / 2)) <= 8) || force_activate) {
					ID = 0;
					if (!force_activate) {
						broadcast_to_children("b");
					}
					if (player_overlaps_if_nudged && touching == 0) {
						R.player.y --;
						R.player.touching = FlxObject.DOWN;
					}
					animation.play(anim_prefix + "up");
					force_activate = false;
					mode = MODE_MOVING;
					
					num_Active_elevators++;
					velocity.y = -props.get("rise_vel");
					acceleration.y = -Math.abs(velocity.y);
					maxVelocity.y = Math.abs(velocity.y);
					velocity.y = 0;
				}
			}
		} else if (mode == MODE_MOVING) {
			if (touching != 0) {
				if (velocity.y < 0) {
					R.player.velocity.y = 15;
				} else if (velocity.y > 0) {
					R.player.velocity.y = velocity.y;
				}
			}
			
			
				// Move the elevator with the player if riding an elevator during a vertical newcamtrig screen transition.
			y -= 8;
			height += 16;
			if (overlaps(R.player) && R.player.animation.curAnim != null && R.player.animation.curAnim.name.charAt(0) != "c") {
				height -= 16;
				y += 8;
				if (NewCamTrig.active_cam != null && (NewCamTrig.active_cam.mode == 12 || NewCamTrig.active_cam.mode == 13 || NewCamTrig.active_cam.mode == 100)) {
					if (velocity.y > 0) {
						ID = 10;
					} else {
						ID = 11;
					}
					y = last.y = R.player.y + R.player.height + elapsed * R.player.velocity.y;
					R.player.touching = FlxObject.DOWN;
				// During downward transition make it so the player stays in sync with elevator motion afte
				// the transition ends
				} else if (ID == 10) {
					R.player.y = R.player.last.y = y - R.player.height;
					R.player.velocity.y = velocity.y;
					ID = 11;
					R.player.touching = FlxObject.DOWN;
					//Log.trace(10);
				} else if (ID >= 11 && ID <= 25) { // In both up and down dirs, fake touching ground to avoid the animation hiccup. This code also continues in MODE_TOP
					if (velocity.y < 0) {
						R.player.y = R.player.last.y = y - R.player.height - 1;
						R.player.velocity.y = 15;
					}
					
					R.player.touching = FlxObject.DOWN;
					ID++;
				} else {
					ID = 0;
				}
			} else {
				height -= 16;
				y += 8;
			}
			
			if (velocity.y < 0) {
				
				var b:Bool = false;
				for (rw in RaiseWall.ACTIVE_RaiseWalls) {
					y -= 32;
					if (overlaps(rw)) {
						velocity.y = 0;
						acceleration.y *= -1;
						b = true;
						
						animation.play(anim_prefix + "down");
					}
					y += 32;
				}
				if (b) {
					super.update(elapsed);
					return;
				}
				var dy:Float = starts_at_top ? iy  : iy - rise_height;
				if (y <= dy) {
					y = dy;
					velocity.set(0, 0); acceleration.set(0, 0);
					mode = MODE_TOP;
					num_Active_elevators --;
					animation.play(anim_prefix + "idle");
					if (touching != 0) {
						R.player.y = y - R.player.height + 1;
					}
				} else {
					if (y < dy + (-velocity.y / 2) && ID == 0) {
						acceleration.y = -velocity.y * 1.6;
					}
				}
			} else {
				
				
				var b:Bool = false;
				for (rw in RaiseWall.ACTIVE_RaiseWalls) {
					y += 8;
					if (overlaps(rw)) {
						velocity.y = 0;
						acceleration.y *= -1;
						b = true;
						
						animation.play(anim_prefix + "up");
					}
					y -= 8;
				}
				if (b) {
					super.update(elapsed);
					return;
				}
				
				var dy:Float = starts_at_top ? iy +rise_height : iy;
				if (y >= dy) {
					y = dy;
					velocity.set(0, 0); acceleration.set(0, 0);
					mode = MODE_BOTTOM;
					num_Active_elevators --;
					
					animation.play(anim_prefix + "idle");
				} else {
					if (y >= dy - (velocity.y / 2)) {
						acceleration.y = -velocity.y*1.6;
					}
				}
			}
		}
		super.update(elapsed);
	}
	
	override public function draw():Void 
	{
		if (has_console) {
			if (starts_at_top == false) {
				console.y -= rise_height;
				console.draw();
				console.y += rise_height;
			}
			
			if (starts_at_top) {
				console.y += rise_height;
				console.draw();
				console.y -= rise_height;
			}
		}
		if (mode == MODE_BOTTOM) {
			if (R.editor.editor_active) {
				alpha = 0.5;
				y -= rise_height;
				super.draw();
				y += rise_height;
				alpha = 1;
			}
		} else if (mode == MODE_TOP) {
			if (R.editor.editor_active) {
				alpha = 0.5;
				y += rise_height;
				super.draw();
				y -= rise_height;
				alpha = 1;
			}
			
			
		}
		super.draw();
	}
	
	override public function postUpdate(elapsed):Void 
	{
		if (Reflect.getProperty(R.player, "mode") == 2) {
			
		} else {
			super.postUpdate(elapsed);
		}
	}
}