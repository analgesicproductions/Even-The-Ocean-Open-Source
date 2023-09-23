package entity.util;

import autom.SNDC;
import entity.MySprite;
import flash.geom.Point;
import flixel.FlxG;
import flixel.FlxSprite;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import help.JankSave;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import state.MyState;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flash.geom.Point;
import flash.geom.Rectangle;

class PlantBlockAccepter extends MySprite
{
	
	public static var ACTIVE_PlantBlockAccepters:List<PlantBlockAccepter>;
	public var behavior:Int = 0;
	
	private var ball:FlxSprite;
	private var laser_contact:FlxSprite;
	private var laser_ss:BitmapData;
	private var bar:FlxSprite;
	private var cover:FlxSprite;
	
	private var crosshair:FlxSprite;
	private var circle:FlxSprite;
	
	public var copy_rect:FlxRect;
	public var copy_flash_rect:Rectangle;
	public var copy_point:FlxPoint;
	public var copy_flash_point:Point;
	
	private var t_osc:Float = 0;
	private var tm_osc:Float = 0.03;
	private var osc_idx:Int = 0;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
	
		crosshair = new FlxSprite();
		circle = new FlxSprite();
		copy_rect = new FlxRect();
		cover = new FlxSprite();
		copy_point = new FlxPoint();
		copy_flash_point = new Point();
		copy_flash_rect = new Rectangle();
		copy_flash_rect.setTo(0, 0, 80, 16);
		copy_flash_point.setTo(0, 0);
		ACTIVE_PlantBlockAccepters.add(this);
		ball = new FlxSprite();
		laser_contact = new FlxSprite();
		bar = new FlxSprite();
		super(_x, _y, _parent, "PlantBlockAccepter");
	}
	
	private var facing_left:Bool = false;
	override public function change_visuals():Void 
	{
		var nname:String = "default";
		var suffix:String = "";
		if (R.TEST_STATE.MAP_NAME == "PASS_B") {
			suffix = "_pass";
		} else if (R.TEST_STATE.MAP_NAME == "CLIFF_B") {
			suffix = "_cliff";
		} else if (R.TEST_STATE.MAP_NAME == "FALLS_B") {
			suffix = "_falls";
		}
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 80, 80, name,nname+suffix);	
				AnimImporter.loadGraphic_from_data_with_id(cover, 80, 80, name,"cover"+suffix);
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 80, 80, name,nname+suffix);
				AnimImporter.loadGraphic_from_data_with_id(cover, 80, 80, name,"cover"+suffix);
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 80, 80, name,nname+suffix);	
				AnimImporter.loadGraphic_from_data_with_id(cover, 80, 80, name,"cover"+suffix);
		}
		crosshair.myLoadGraphic(Assets.getBitmapData("assets/sprites/util/plantblock_target.png"), true, false, 48, 48);
		circle.myLoadGraphic(Assets.getBitmapData("assets/sprites/util/plantblock_target.png"), true, false, 48, 48);
		crosshair.animation.add("a", [1], 1);
		circle.animation.add("a", [0], 1);
		crosshair.animation.play("a");
		circle.animation.play("a");
		crosshair.blend = circle.blend = BlendMode.ADD;
		if (suffix == "") {
			crosshair.exists = circle.exists = false;
		} 
		crosshair.alpha = circle.alpha = 0;
		
		width = height = 16;
		
		// remove later
		AnimImporter.loadGraphic_from_data_with_id(bar, 0, 0, "PlantBlock", "hor");
		if (suffix != "") {
			suffix = "_pass";
		}
		if (behavior == 0) {
			copy_flash_rect.setTo(0, 0, 80,16);
			AnimImporter.loadGraphic_from_data_with_id(ball, 16, 16, "PlantBlock", "block");
			AnimImporter.loadGraphic_from_data_with_id(bar, 0, 0, "PlantBlock", "hor"+suffix);
			laser_contact.makeGraphic(80,16, 0xff88ff88,false,Std.string(geid)+"W"+parent_state.MAP_NAME);
			ball.x = x + 3;
			ball.y = y + 16;
			ball.alpha = laser_contact.alpha = 0;
			laser_contact.alpha = 1;
			bar.alpha = 0;
			bar.animation.play("small");
			laser_ss = Assets.getBitmapData("assets/sprites/util/pb_laser_hor.png");
			
			laser_contact.x = x - 32;
			laser_contact.y = y + 16;
		} else if (behavior == 1) {
			copy_flash_rect.setTo(0, 0, 16, 80);
			AnimImporter.loadGraphic_from_data_with_id(ball, 16, 16, "PlantBlock", "block");
			AnimImporter.loadGraphic_from_data_with_id(bar, 0, 0, "PlantBlock", "vert"+suffix);
			laser_contact.makeGraphic(16,80, 0xff88ff88,false,Std.string(geid)+"H"+parent_state.MAP_NAME);
			ball.x = x + 3;
			ball.y = y + 16;
			ball.alpha = laser_contact.alpha = 0;
			laser_contact.alpha = 1;
			bar.alpha = 0;
			bar.animation.play("small");
			laser_ss = Assets.getBitmapData("assets/sprites/util/pb_laser_vert.png");
		}
		
		if (suffix != "") {
			laser_contact.visible = false;
		}
		
		if (behavior == 0) {
			cover.animation.play("off_lr");
			animation.play("off_lr",true);
			offset.set(48, 32);
		} else if (behavior == 1) {
			
			if (parent_state.tm_bg.getTileCollisionFlags(x - 8, y + 8) == 0) {
				facing_left = true;
				laser_contact.x = x + 16;
				laser_contact.y = y - 32;
				animation.play("off_ud_l");
				cover.animation.play("off_ud_l");
				offset.set(32,48);
			} else {
				facing_left = false;
				laser_contact.x = x - 16;
				laser_contact.y = y - 32;
				animation.play("off_ud");
				cover.animation.play("off_ud");
				offset.set(64,48);
			}
		} else if (behavior == 2) {
			animation.play("off_lr");
			cover.animation.play("off_lr");
			offset.set(48, 32);
		} else {
			animation.play("off_lr");
			cover.animation.play("off_lr");
			offset.set(48, 32);
		}
		
		cover.offset.set(offset.x, offset.y);
		cover.width = width;
		cover.height = height;
		
		//Log.trace([frame, scale]);
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("children", "");
		p.set("behavior", 0);
		p.set("init_state", 0);
		p.set("s_on", 0);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		behavior = props.get("behavior"); // lr, ud, circle

		// If a checkpoint is active and u activate one of these,
		// then it updates the in-memory entity data.
		
		// if not in a chkpt or the chkpt is not this map then reset this
		// (for if u leave map in gautlet)
		if (props.get("init_state") > -1 && (!JankSave.force_checkpoint_things || Checkpoint.tempmap != R.TEST_STATE.MAP_NAME)) {
			props.set("s_on", props.get("init_state"));
		}
		
		
		change_visuals();
		
	}
	
	override public function destroy():Void 
	{
		ACTIVE_PlantBlockAccepters.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [ball,bar, cover,laser_contact,circle,crosshair]);
		super.destroy();
	}
	
	private var mode:Int = 0;
	
	public function is_on():Bool {
		if (mode >= 1) return true;
		return false;
	}
	public function activate(plantblock_behavior:Int, turn_on:Bool = false, nosound:Bool = false,save_ent:Bool=true,oscd_idx:Int=0):Bool {
		if (mode != 1) {
			if (turn_on) {
				switch (behavior) {
					case 0: animation.play("on_lr");
				case 1: 
					if (facing_left) {
						animation.play("on_ud_l");
					} else {
						animation.play("on_ud");
					}
					case 2: animation.play("on_lr");
					case 3: animation.play("on_lr");
				}
			} else {
				if (behavior == 0 && plantblock_behavior == 1) {
					animation.play("on_lr");
				} else if (behavior == 1 && plantblock_behavior ==2) {
					if (facing_left) {
						animation.play("on_ud_l");
					} else {
						animation.play("on_ud");
					}
				} else if (behavior == 2 && plantblock_behavior == 3) {
					animation.play("on_lr");
				} else if (behavior == 3) {
					animation.play("on_lr"); 
				} else  {
					R.sound_manager.play(SNDC.lens_attach);
					return false;
				}
			}
			
			if (props.get("s_on") == 0) {
				broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
				broadcast_to_children("GNPC" +" " + Std.string(geid));
			}
			
			props.set("s_on", 1);
			
			//if (save_ent) {
				//HF.save_map_entities(R.TEST_STATE.MAP_NAME, cast R.TEST_STATE, true);	
			//}
			//R.gauntlet _manager.cache_gauntlet_entity_data();
			mode = 1;
			if (nosound) {
				snap_bar = true;
			}
			
				bar.x = R.player.x + R.player.width / 2 - bar.width / 2;
				bar.y = R.player.y + R.player.height / 2 - bar.height / 2;
				osc_idx = oscd_idx;
			
			if (!nosound) {
				R.sound_manager.play(SNDC.lens_attach);
			}
			return true;
		}
		return false;
	}
	private var snap_bar:Bool = false;
	private var overlapping_accepter:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			populate_parent_child_from_props();
			HF.add_list_to_mysprite_layer(this, parent_state, [bar,ball, laser_contact,cover,circle,crosshair]);
			// on first tick if active then turn it on and tell children
			if (props.get("s_on") == 1) {
				activate(behavior,true,true,false);
			}
		}
		cover.x = x;
		cover.y = y;
		
			R.player.y += 2;
			if (!parent_state.dialogue_box.is_active()) {
				
					this.width += 4;
					this.height += 4;
					this.x -= 2;
					this.y -= 2;
				if (!overlapping_accepter && R.player.overlaps(this) && R.player.is_on_the_ground(true)) {
					if (!R.input.a2) {
						R.player.activate_npc_bubble("speech_appear");
						overlapping_accepter = true;
					}
				} else if (overlapping_accepter) {
					if (!R.player.overlaps(this) || R.input.jpA1) {
						R.player.activate_npc_bubble("speech_disappear");
						overlapping_accepter = false;
					} else if (R.input.jpCONFIRM) {
						overlapping_accepter = false;
						R.player.activate_npc_bubble("speech_disappear");
						if (PlantBlock.BLOCK_LOCK) {
							
						} else {
							if (is_on()) {
								parent_state.dialogue_box.start_dialogue("intro", "plantblock", 7);
							} else {
								parent_state.dialogue_box.start_dialogue("intro", "plantblock", behavior);
							}
						}
					}
					
				}
				
					this.width -= 4;
					this.height -= 4;
					this.x += 2;
					this.y += 2;
			}
			R.player.y -= 2;
		
		if (mode == 1) {
			// fade or someting or wait for something to move to it...
			ball.alpha = 1;
			bar.alpha = 1;
			crosshair.alpha = circle.alpha = 1;
			if (behavior == 0) { // hor
				var dy:Float = y + 8;
				if (bar.y != dy) {
					if (bar.y < dy) {
						bar.y += 3;
					if (bar.y >= dy ||snap_bar) bar.y = dy;
					} else {
						bar.y -= 3;
						if (bar.y < dy||snap_bar) bar.y = dy;
					}
				}
				var dx:Float = x + width / 2 - bar.width / 2;
				if (bar.x != dx) {
					if (bar.x <= dx||snap_bar) {
						bar.x += 3;
						if (bar.x > dx ||snap_bar) bar.x = dx;
					} else {
						bar.x -= 3;
						if (bar.x <= dx||snap_bar) bar.x = dx;
					}
				}
				ball.y = bar.y + bar.height / 2 - ball.height / 2;
				//ball.x = bar.x + bar.width / 2 - ball.width / 2; // change
				if (bar.y == dy && bar.x ==dx) {
					mode = 2;
				}
			} else if (behavior == 1) {
				var dy:Float = y + 8;
				var dx:Float = x + width / 2 - bar.width / 2;
				if (facing_left) {
					dy = y + height / 2 - bar.height / 2;
					dx = x + 8;
				} else {
					dy = y + height / 2 - bar.height / 2;
					dx  = x - bar.width + 8;
				}
				if (bar.y != dy) {
					if (bar.y < dy ) {
						bar.y += 3;
						if (bar.y >= dy||snap_bar) bar.y = dy;
					} else {
						bar.y -= 3;
						if (bar.y < dy||snap_bar) bar.y = dy;
					}
				}
				if (bar.x != dx) {
					if (bar.x <= dx) {
						bar.x += 3;
						if (bar.x > dx||snap_bar) bar.x = dx;
					} else {
						bar.x -= 3;
						if (bar.x <= dx||snap_bar) bar.x = dx;
					}
				}
				ball.x = bar.x + bar.width / 2 - ball.width / 2;
				//ball.y = bar.y + bar.height / 2 - ball.height / 2; // change
				if (bar.y == dy && bar.x ==dx) {
					mode = 2;
					snap_bar = false;
				} 
			}
		} else if (mode == 2) {
			
		}
		t_osc += FlxG.elapsed;
		if (t_osc > tm_osc) {
			t_osc = 0;
			if (mode == 2) osc_idx += 3;
			// hack for frame
			if (behavior == 0) {
				if (osc_idx % 30 == 0) {
					if (mode != 0) ball.ID = 0;
					copy_flash_rect.y = 0;
				} else if (osc_idx % 15 == 0) {
					if (mode != 0) ball.ID = 1;
					copy_flash_rect.y = 16;
				}
				if (osc_idx >= 360) osc_idx = 0;
				var ball_start:Int = Std.int(x + 8 - (ball.width / 2));
				if (mode == 2) {
					ball.x = ball_start;
					ball.x += Std.int(32 * FlxX.sin_table[osc_idx]);
					copy_flash_rect.x = (160 / 2) - (80 / 2);
					copy_flash_rect.x -= Std.int(ball.x - ball_start);
					if (osc_idx == 90 || osc_idx == 270) {
						t_osc = -0.25;
					}
				} else {
					copy_flash_rect.x = laser_ss.width - copy_flash_rect.width;
				}
			} else if (behavior == 1) {
				if (osc_idx % 30 == 0) {
					ball.ID = 0;
					copy_flash_rect.x = 0;
				} else if (osc_idx % 15 == 0) {
					ball.ID = 1;
					copy_flash_rect.x = 16;
				}
				if (osc_idx >= 360) osc_idx = 0;
				
				var ball_start:Int = Std.int(y + 8 - (ball.height / 2));
				if (mode == 2) {
					ball.y = ball_start;
					ball.y += Std.int(32 * FlxX.sin_table[osc_idx]);
					copy_flash_rect.y = (160 / 2) - (80 / 2); // START AT 40
					copy_flash_rect.y -= Std.int(ball.y - ball_start);
					if (osc_idx == 90 || osc_idx == 270) {
						t_osc = -0.25;
					}
				} else {
					// NO LEGO YET
					copy_flash_rect.y = laser_ss.height - copy_flash_rect.height;
				}
			}
			
			laser_contact.pixels.copyPixels(laser_ss,copy_flash_rect, copy_flash_point);
		}
				
		//if (mode == 2) {
			if (behavior == 0) {
				ball.x = Std.int(x + 8 - (ball.width / 2));
				ball.x += Std.int(32 * FlxX.sin_table[osc_idx]);
			} else if (behavior == 1) {
				ball.y = Std.int(y + 8 - (ball.height / 2));
				ball.y += Std.int(32 * FlxX.sin_table[osc_idx]);
			}
		//}
		
		crosshair.x = ball.x - (crosshair.width - ball.width) / 2;
		crosshair.y = ball.y - (crosshair.height - ball.height) / 2;
		circle.move(crosshair.x, crosshair.y);
		crosshair.angularVelocity = 60;
		
		super.update(elapsed);
	}
	public static function reinit(ent_line:String):String {
		var init_state:Int = HF.get_int_prop_in_ent_line(ent_line, "init_state");
		if (init_state > -1) {
			if (init_state == 0) {
				return HF.replace_prop_in_ent_line(ent_line, 0, "s_on");
			} else {
				return HF.replace_prop_in_ent_line(ent_line, 1, "s_on");
			}
		}
		return ent_line;
	}
}