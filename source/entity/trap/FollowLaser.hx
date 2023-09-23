package entity.trap;
import autom.SNDC;
import entity.enemy.Dasher;
import entity.enemy.ExtendStem;
import entity.enemy.SpikeExtend;
import entity.MySprite;
import entity.npc.Mole;
import entity.player.BubbleSpawner;
import entity.ui.Inventory;
import entity.util.OrbSlot;
import entity.util.PlantBlock;
import entity.util.RaiseWall;
import entity.util.VanishBlock;
import entity.util.WalkBlock;
import flash.geom.Point;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import openfl.display.BlendMode;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class FollowLaser extends MySprite
{

	public static var sin_table:Array<Float>;
	public static var cos_table:Array<Float>;
	
	
	private var big_part:FlxSprite;
	private var small_part:FlxSprite;
	private var laser_contact_sprite:FlxSprite;
	//private var laser_movement_sprites:FlxTypedGroup<FlxSprite>;
	private var laser_sparkle_sprites:FlxTypedGroup<FlxSprite>;
	
	private var center_point:Point;
	
	private var is_dream:Bool = false;
	private var dream_no_shield:Bool = false;
	public static var ACTIVE_FollowLasers:FlxTypedGroup<FollowLaser>;
	private var line1:FlxSprite;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		if (sin_table == null) {
			sin_table = [];
			cos_table = [];
			var rad:Float = 0;
			var radslice:Float = (Math.PI * 2) / 360.0;
			for (i in 0...360) {
				sin_table.push(Math.sin(rad));
				cos_table.push(Math.cos(rad));
				rad += (radslice);
			}
		}
		small_part = new FlxSprite();
		big_part = new FlxSprite();
		big_part.ID = 0;
		contact_point = new Point();
		line1 = new FlxSprite();
		line1.makeGraphic(1, 1, 0xffff0000);
		laser_contact_sprite = new FlxSprite();
		laser_contact_sprite.makeGraphic(1,1, 0x00ff0000);
		//laser_contact_sprite.visible = false;
		//laser_movement_sprites = new FlxTypedGroup<FlxSprite>();
		laser_sparkle_sprites = new FlxTypedGroup<FlxSprite>();
		center_point = new Point(0, 0);
		super(_x, _y, _parent, "FollowLaser");
		does_proximity_sleep = true;
		
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				if (vistype == 0) {
					props.set("dmgtype", 0);
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "light");
					AnimImporter.loadGraphic_from_data_with_id(big_part, 16, 16, name, "l_parts");
					AnimImporter.loadGraphic_from_data_with_id(small_part, 16, 16, name, "l_parts");
					
				} else if (vistype == 1) {
					props.set("dmgtype", 1);
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "dark");
					AnimImporter.loadGraphic_from_data_with_id(big_part, 16, 16, name, "d_parts");
					AnimImporter.loadGraphic_from_data_with_id(small_part, 16, 16, name, "d_parts");
				} else {
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, Std.string(vistype));
					AnimImporter.loadGraphic_from_data_with_id(big_part, 16, 16, name, "d_parts");
					AnimImporter.loadGraphic_from_data_with_id(small_part, 16, 16, name, "d_parts");
				}
				big_part.animation.play("big");
				small_part.animation.play("small");
				big_part.width = big_part.height = 2;
				small_part.width = small_part.height = 2;
				big_part.offset.set(7, 7);
				small_part.offset.set(7, 7);
				
				animation.play("idle");
				//laser_movement_sprites.callAll("destroy");
				//laser_movement_sprites.clear();
				laser_sparkle_sprites.callAll("destroy");
				laser_sparkle_sprites.clear();
				//for (i in 0...4) {
					//var laser_movement_sprite:FlxSprite = new FlxSprite(0, 0);
					//if (vistype == 0) {
						//AnimImporter.loadGraphic_from_data_with_id(laser_movement_sprite, 16, 16, name, "light_bullet");
					//} else if (vistype == 1) {
						//AnimImporter.loadGraphic_from_data_with_id(laser_movement_sprite, 16, 16, name, "dark_bullet");
					//} else {
						//AnimImporter.loadGraphic_from_data_with_id(laser_movement_sprite, 16, 16, name, Std.string(vistype)+"_bullet");
					//}
					//laser_movement_sprite.animation.play("bullet");
					//laser_movement_sprite.angle = 360 * Math.random();
					//laser_movement_sprites.add(laser_movement_sprite);
					//laser_movement_sprite.width = laser_movement_sprite.height = 2;
					//laser_movement_sprite.offset.set(7, 7);
				//}
				for (i in 0...6) {
					var laser_sparkle:FlxSprite = new FlxSprite(0, 0);
					if (vistype == 0) { // light
						if (i % 2 == 0) {
							laser_sparkle.makeGraphic(1, 1, 0xffdfffcd);
						} else {
							laser_sparkle.makeGraphic(1, 1, 0xff5dcaa5);
						}
					} else {
						if (i % 2 == 0) {
							laser_sparkle.makeGraphic(1, 1, 0xffd3549c);
						} else {
							laser_sparkle.makeGraphic(1, 1, 0xffff9c95);
						}
					}
					laser_sparkle.blend = BlendMode.ADD;
					//laser_sparkle.angle = 360 * Math.random();
					laser_sparkle.angle = 0;
					laser_sparkle_sprites.add(laser_sparkle);
				}
		}
	}
	override public function sleep():Void 
	{
		laser_contact_sprite.exists = false;
		//laser_movement_sprites.exists = false;
		laser_sparkle_sprites.exists = false;
		
	}
	override public function wakeup():Void 
	{
		laser_contact_sprite.exists = true;
		//laser_movement_sprites.exists = true;
		laser_sparkle_sprites.exists = true;
	}
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("is_fixed", 1);
		p.set("fixed_angle", 90);
		p.set("axis_tracks_player", 1);
		p.set("tracked_axis", "x");
		p.set("tracking_vel", 0);
		p.set("accel", 50);
		p.set("vistype", 0);
		p.set("angvel", 0);
		p.set("is_dream", 0);
		p.set("dmgtype", 0);
		return p;
	}
	
	private var angle_is_fixed:Bool = false;
	private var fixed_angle:Float = 0;
	private var tracks_player_on_axis:Bool = false;
	private var tracked_axis:String = "x"; // 0 = X, 1 = Y
	private var tracking_velocity:Int = 50;
	private var angvel:Int = 0;
	private var accel:Int = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		
		angle_is_fixed = props.get("is_fixed");
		fixed_angle = props.get("fixed_angle");
		tracks_player_on_axis = props.get("axis_tracks_player");
		tracked_axis = props.get("tracked_axis").toLowerCase();
		tracking_velocity = props.get("tracking_vel");
		vistype = props.get("vistype");
		is_dream = props.get("is_dream") == 1;
		change_visuals();
		dmgtype = props.get("dmgtype");
		line1.origin.set(0, 0);
		ID = 3;
		if (angle_is_fixed) {
			//angularAcceleration = 0;
			angle = fixed_angle;
			angularVelocity = 0;
			velocity.x = velocity.y = 0;
			acceleration.x = 0;
		}
		
		if (!angle_is_fixed && tracks_player_on_axis && tracking_velocity == 0) {
			angle = fixed_angle;
		}
		
		angularVelocity = angvel = props.get("angvel");
		//angularAcceleration = accel = props.get("accel");
	}
	
	override public function destroy():Void 
	{
		ACTIVE_FollowLasers.remove(this, true);
		//HF.remove_list_from_mysprite_layer(this, parent_state,[laser_contact_sprite,laser_sparkle_sprites,laser_movement_sprites,line1]);
		HF.remove_list_from_mysprite_layer(this, parent_state,[laser_contact_sprite,laser_sparkle_sprites,big_part]);
		//HF.remove_list_from_mysprite_layer(this, parent_state,[laser_contact_sprite,line1,big_part]);
		HF.remove_list_from_mysprite_layer(this, parent_state,[small_part],MyState.ENT_LAYER_IDX_FG2);
		HF.remove_list_from_mysprite_layer(this, parent_state,[line1],MyState.ENT_LAYER_IDX_BG1);
		laser_contact_sprite.destroy(); laser_contact_sprite = null;
		//laser_movement_sprites.destroy(); laser_movement_sprites = null;
		laser_sparkle_sprites.destroy(); laser_sparkle_sprites = null;
		
		super.destroy();
	}
	
	public var _kx:Float = 0;
	public var _ky:Float = 0;
	public var t_max:Float = 0;
	public var contact_point:Point;
	override public function update(elapsed: Float):Void 
	{
		
		if (is_dream) {
			if (R.inventory.is_item_found(Inventory.ITEM_DREAMAMINE)) {
				dream_no_shield = false;
				alpha = 1;
				//laser_movement_sprites.setAll("alpha", 1);
			} else {
				dream_no_shield = true;
				alpha = 0.5;
				//laser_movement_sprites.setAll("alpha", 0.5);
			}
		}
		if (!did_init) {
			did_init = true;
			ACTIVE_FollowLasers.add(this);
			HF.add_list_to_mysprite_layer(this, parent_state, [laser_contact_sprite,  laser_sparkle_sprites,big_part]);
			//HF.add_list_to_mysprite_layer(this, parent_state, [laser_contact_sprite,big_part,small_part]);
			HF.add_list_to_mysprite_layer(this, parent_state, [small_part],MyState.ENT_LAYER_IDX_FG2);
			//HF.insert_list_before_object_in_mysprite_layer(this, parent_state,[laser_movement_sprites]);
			//HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [line1]);
			HF.add_list_to_mysprite_layer(this, parent_state, [line1], MyState.ENT_LAYER_IDX_BG1);
		}
		
		if (asleep) {
			velocity.x = velocity.y = 0;
			acceleration.x = acceleration.y = 0;
			last.x = x = ix; last.y = y = iy;
			super.update(elapsed);
			return;
		}
		var turnoff_This_tick:Bool = false;
		
		//for (vanish in VanishBlock.ACTIVE_VanishBlocks) {
			//if (vanish.overlaps(this) && vanish.props.get("s_open") == 0) {
				//turnoff_This_tick = true;
			//}
		//}
		
		if (turnoff_This_tick) {
			//laser_contact_sprite.visible = laser_movement_sprites.visible = laser_sparkle_sprites.visible = false;
			laser_contact_sprite.visible = laser_sparkle_sprites.visible = false;
			super.update(elapsed);
			return;
		} else {
			//laser_contact_sprite.visible = laser_movement_sprites.visible = laser_sparkle_sprites.visible = true;
			laser_contact_sprite.visible = laser_sparkle_sprites.visible = true;
		}
		
		// Parametrically cast a ray to find tile
		if (angle_is_fixed) {
			
		} else {
			if (angularAcceleration > 0) {
				angularAcceleration = accel;
				if (angularVelocity > angvel) {
					angularAcceleration = -accel;
				} 
			} else if (angularAcceleration < 0) {
				angularAcceleration = -accel;
				if (angularVelocity < -angvel) {
					angularAcceleration = accel;
				}
			} else {
				
			}
		}
		//Log.trace(angle);
		
		/* Raytrace */
		_kx = cos_table[Std.int(Math.abs(Std.int(angle) % 360))]; // % is NOT in Z+
		_ky = sin_table[Std.int(Math.abs(Std.int(angle) % 360))];
		var kx:Float = 14 * _kx;
		var ky:Float = 14 * _ky;
		x += 8;
		y += 8;
		var g:Int = 16;
		// Laser can hit at most a distance of 16*30 pixels
		for (i in 0...30) {
			var tile_id:Int = parent_state.tm_bg.getTileID(x + i * kx, y + i * ky);
			var tile_id2:Int = parent_state.tm_bg2.getTileID(x + i * kx, y + i * ky);
				
			if (!HF.array_contains(HelpTilemap.permeable, tile_id) && !HF.array_contains(HelpTilemap.permeable, tile_id2)  &&
			(parent_state.tm_bg.getTileCollisionFlags(x  + i * kx, y + i * ky) != 0 || parent_state.tm_bg2.getTileCollisionFlags(x  + i * kx, y + i * ky) != 0 )) {
				laser_contact_sprite.x = x + i * kx;
				laser_contact_sprite.y = y  + i * ky;
				// Step backwards to figure out where to put the laser collision sprite
				for (j in 0...g) {
					if (parent_state.tm_bg.getTileCollisionFlags(laser_contact_sprite.x - (1 / g) * kx, laser_contact_sprite.y - (1 / g) * ky) != 0 ||parent_state.tm_bg2.getTileCollisionFlags(laser_contact_sprite.x - (1 / g) * kx, laser_contact_sprite.y - (1 / g) * ky) != 0 ) {
						laser_contact_sprite.x -= (1 / g) * kx;
						laser_contact_sprite.y -= (1 / g) * ky;
						if (j == g - 1) {
							if (Math.abs(_kx) > 0.3) {
								t_max = (laser_contact_sprite.x - x) / _kx;
							} else {
								t_max = (laser_contact_sprite.y - y) / _ky;
							}
						}
						continue;
					}
					// If the ray is a parametric equation, find the max "time" the collision
					// point travelled - used to calculate entity collisions
					if (Math.abs(_kx) > 0.3) {
						t_max = (laser_contact_sprite.x - x) / _kx;
					} else {
						t_max = (laser_contact_sprite.y - y) / _ky;
					}
					break;
				}
				for (raisewall in RaiseWall.ACTIVE_RaiseWalls.members) {
					if (raisewall != null && HF.ray_intersects_box(x, y, _kx, _ky, raisewall, t_max, 0.01, contact_point)) {
							laser_contact_sprite.move(contact_point.x, contact_point.y);
							if (Math.abs(_kx) > 0.3) {
								t_max = (contact_point.x - x) / _kx;
							} else {
								t_max = (contact_point.y - y) / _ky;
							}
					}
				}
				
				for (es in ExtendStem.ACTIVE_ExtendStems) {
					if (es != null && HF.ray_intersects_box(x, y, _kx, _ky, es.collision_sprite, t_max, 0.01, contact_point)) {
						laser_contact_sprite.move(contact_point.x, contact_point.y);
						if (Math.abs(_kx) > 0.3) {
							t_max = (contact_point.x - x) / _kx;
						} else {
							t_max = (contact_point.y - y) / _ky;
						}
					}
				}
				for (spikeextend in SpikeExtend.ACTIVE_SpikeExtends) {
					if (spikeextend != null && HF.ray_intersects_box(x, y, _kx, _ky, spikeextend, t_max, 0.01, contact_point)) {
						laser_contact_sprite.move(contact_point.x, contact_point.y);
						if (Math.abs(_kx) > 0.3) {
							t_max = (contact_point.x - x) / _kx;
						} else {
							t_max = (contact_point.y - y) / _ky;
						}
					}
				}
				
				for (vb in VanishBlock.ACTIVE_VanishBlocks) {
					if (!vb.is_open && HF.ray_intersects_box(x, y, _kx, _ky, vb, t_max, 0.01, contact_point)) {
						laser_contact_sprite.move(contact_point.x, contact_point.y);
						if (Math.abs(_kx) > 0.3) {
							t_max = (contact_point.x - x) / _kx;
						} else {
							t_max = (contact_point.y - y) / _ky;
						}
					}
				}
				
				for (d in Dasher.ACTIVE_Dashers) {
					if (HF.ray_intersects_box(x, y, _kx, _ky, d, t_max, 0.01, contact_point)) {
						laser_contact_sprite.move(contact_point.x, contact_point.y);
						if (Math.abs(_kx) > 0.3) {
							t_max = (contact_point.x - x) / _kx;
						} else {
							t_max = (contact_point.y - y) / _ky;
						}
					}
				}
				
				
				var wc:WaterCharger;
				for (wc in WaterCharger.ACTIVE_WaterChargers) {
					for (j in 0...30) {
						// dmgtype is backwards here
						if (wc.pt_overlaps_tile(x + kx * j, y + ky * j, dmgtype, true)) {
							var new_t:Float = 0;
							
							if (Math.abs(_kx) > 0.3) {
								new_t = ((x+kx*j) - x) / _kx;
							} else {
								new_t = ((y+ky*j)- y) / _ky;
							}
							if (Math.abs(new_t) < Math.abs(t_max)) {
								t_max = new_t;
								laser_contact_sprite.move(x+kx*(j+0.5), y+ky*(j+0.5));
							}
							break;
							
						}
					}
				}
				
				
				
				for (d in WalkBlock.ACTIVE_WalkBlocks) {
					if (HF.ray_intersects_box(x, y, _kx, _ky, d, t_max, 0.01, contact_point)) {
						laser_contact_sprite.move(contact_point.x, contact_point.y);
						if (Math.abs(_kx) > 0.3) {
							t_max = (contact_point.x - x) / _kx;
						} else {
							t_max = (contact_point.y - y) / _ky;
						}
					}
				}
					
				if (R.player.exists) {
					// have to order these
					var blocked_by_shield:Bool = false;
					var newpoint:Point = new Point();
					var on_shield:Bool = false;
					if (R.player.get_shield_dir() != 4) {
						on_shield = HF.ray_intersects_box(x, y, _kx, _ky, R.player.get_active_shield_logic(), t_max, 0.01, contact_point);
					}
						var on_player:Bool = HF.ray_intersects_box(x, y, _kx, _ky, R.player, t_max, 0.01, newpoint);
						
						R.player.width += 64; R.player.height += 64; R.player.y -= 32; R.player.x -= 32;
						if (HF.ray_intersects_box(x, y, _kx, _ky, R.player, t_max, 0.01)) {
							if (big_part.ID == 0 && !(on_player || on_shield)) {
								R.sound_manager.play(SNDC.followLaserNear);
							}
							big_part.ID ++;
							if (big_part.ID == 30) big_part.ID = 0;
						} else { big_part.ID = 0; }	
						R.player.width -= 64; R.player.height -= 64; R.player.y += 32; R.player.x += 32;
						
						
						if (on_player || on_shield) {
							if (small_part.ID == 0) R.sound_manager.play(SNDC.followLaserHit);
							small_part.ID ++;
							if (small_part.ID == 30) small_part.ID = 0;
						} else { small_part.ID = 0; }
						
						
						if (dream_no_shield) {
							on_shield = false;
						}
						var popped_bubble:Bool = true;
						if (on_shield || on_player) {
							if (BubbleSpawner.cur_bubble != null) {
								if (vistype == 0 && BubbleSpawner.cur_bubble_flavor == BubbleSpawner.BUBBLE_DARK) {
									BubbleSpawner.force_pop();
								} else if (vistype == 1 && BubbleSpawner.cur_bubble_flavor == BubbleSpawner.BUBBLE_LIGHT) {
									BubbleSpawner.force_pop();
								} else {
									popped_bubble = false;
								}
							}
						}
						if (on_shield && on_player) {
							// If it hit the shield first...
							if (Math.sqrt((x - newpoint.x) * (x - newpoint.x) + (y - newpoint.y) * (y - newpoint.y)) > Math.sqrt((x - contact_point.x) * (x - contact_point.x) + (y - contact_point.y) * (y - contact_point.y))) {
								on_player = false;
							}
						}
						if (on_shield) {
							laser_contact_sprite.x = contact_point.x;
							laser_contact_sprite.y = contact_point.y;
							if (Math.abs(_kx) > 0.3) {
								t_max = (laser_contact_sprite.x - x) / _kx;
							} else {
								t_max = (laser_contact_sprite.y - y) / _ky;
							}
						} 
						
						
						if (PlantBlock.active_plantblock != null) {
							//Log.trace([PlantBlock.active_plantblock.x, PlantBlock.active_plantblock.y]);
							if (HF.ray_intersects_box(x, y, _kx, _ky, PlantBlock.active_plantblock.block, t_max, 0.01, contact_point)) {
								PlantBlock.active_plantblock.destroy_active_block();
								PlantBlock.active_plantblock = null;
							}
						}
						
						if (on_player) {
							
							laser_contact_sprite.x = newpoint.x + _kx;
							laser_contact_sprite.y = newpoint.y + _ky;
							
							if (Math.abs(_kx) > 0.3) {
								t_max = (laser_contact_sprite.x - x) / _kx;
							} else {
								t_max = (laser_contact_sprite.y - y) / _ky;
							}
							if (popped_bubble) {
								if (angle == 180 && R.player.get_shield_dir() == 1) {
										
								} else if (angle == 0 && R.player.get_shield_dir() == 3) {
									
								} else {
							
								if (t_hurt_a_lot >= 1) {
									t_hurt_a_lot = 0;
									R.sound_manager.play(SNDC.pew_hit);
									if (vistype == 0) {
										R.player.add_light(48);
									} else if (vistype == 1) {
										R.player.add_dark(48);
									}
								} else {
									t_hurt += FlxG.elapsed;
									if (t_hurt > 0.025) {
										t_hurt -= 0.025;
										if (vistype == 0) {
											R.player.add_light(1);
										} else if (vistype == 1) {
											R.player.add_dark(1);
										}
									}
								}
								}
							} else {
							
							}
						} else {
							if (t_hurt_a_lot < 1) {
								t_hurt_a_lot += FlxG.elapsed;
							}
						}
						
						for (mole in Mole.ACTIVE_Mole) {
							if (HF.ray_intersects_box(x, y, _kx, _ky, mole, t_max, 0.01)) {
								if (vistype == 0) { //light
									mole.add_energy(true, 1);
								} else if (vistype == 1) {
									mole.add_energy(false, 1);	
								}
							}
						}
				}
				
				for (j in 0...OrbSlot.ACTIVE_OrbSlots.length) {
					var orbslot:OrbSlot = cast OrbSlot.ACTIVE_OrbSlots.members[j]; 
					if (orbslot == null) continue;
					if (HF.ray_intersects_box(x, y, _kx, _ky, orbslot, t_max)) {
						if (vistype == 0) {
							orbslot.lrecv_message(C.MSGTYPE_ENERGIZE_LIGHT);
						} else if (vistype == 1) {
							orbslot.lrecv_message(C.MSGTYPE_ENERGIZE_DARK);
						}
					}
				}
				
				//for (j in 0...laser_movement_sprites.length) {
					//var scalerand:Float = Math.random();
					//laser_movement_sprites.members[j].x = x  - 1 + scalerand * (laser_contact_sprite.x - x);
					//laser_movement_sprites.members[j].y = y  - 1 + scalerand * (laser_contact_sprite.y - y);
				//}
				for (j in 0...laser_sparkle_sprites.length) {
					var radius:Float = 12 * Math.random();
					var x_r:Float = radius * Math.random();
					var y_r:Float = Math.sqrt(Math.max(0, radius * radius - x_r * x_r));
					if (Math.random() > 0.5) y_r *= -1;
					if (Math.random() > 0.5) x_r *= -1;
					
					laser_sparkle_sprites.members[j].x = laser_contact_sprite.x + x_r;
					laser_sparkle_sprites.members[j].y = laser_contact_sprite.y + y_r;
				}
				break;
			}
		}
		
		line1.move(x, y);
		line1.scale.y = Math.sqrt(Math.pow(x - laser_contact_sprite.x, 2) + Math.pow(y - laser_contact_sprite.y, 2));
		line1.angle = angle-90;	
		
		line1.alpha = 0.75;
		if (Math.random() > 0.5) {
			if (vistype == 0) {
			line1.makeGraphic(2, 1, 0xff4ddf8d);
			} else {
				line1.makeGraphic(2, 1, 0xffc926cb);
			}
			line1.origin.set(0, 0);
			line1.blend = BlendMode.ADD;
			//line1.x -= 1; line1.x += 2 * Math.random();
			//line1.y -= 1; line1.y += 2 * Math.random();
		} else {
			if (vistype == 0) {
				line1.makeGraphic(2, 1, 0xff57eea5);
			} else {
				line1.makeGraphic(2, 1, 0xffa626cb);
			}
			line1.origin.set(0, 0);
			line1.blend = BlendMode.ADD;
		}
		
		//dfffcd
		
		x -= 8;
		y -= 8;
		
		
		
		/* Move */
		if (tracks_player_on_axis) {
			var eps:Int = 2;
			
			//if (dir == 0 || dir == 2) {
				//if (y + height / 2 < R.player.y + R.player.height / 2) {
					//velocity.y = 200;
					//if (Math.abs(R.player.velocity.y) > 200) {
						//velocity.y = R.player.velocity.y;
					//}
				//} else {
					//velocity.y = -200;
				//}
			//}
			//if (Math.abs(R.player.y + R.player.height / 2 - (y + height / 2)) < 8) {
				//velocity.y = 0;
			//}
			
			if (tracked_axis == "x") {
				if (ID == 3) {
					if (x + width/2 < R.player.x + R.player.width/2) {
						velocity.x = 220;
					} else {
						velocity.x = -220;
					}
					var ov:Float = velocity.x;
					x += FlxG.elapsed * velocity.x;
					if (point_collides(x, y + 8)) {
						x -= FlxG.elapsed * velocity.x;
						velocity.x = 0;
					} else if (point_collides(x + width - 1, y + 8)) {
						x -= FlxG.elapsed * velocity.x;
						velocity.x = 0;
					}
					if (Math.abs(R.player.x + R.player.width/ 2 - (x + width/ 2)) < 4) {
						velocity.x = 0;
						ID  = 0;
					}
				} else if (ID == 0) {
					if (R.editor.editor_active == false) {
						
						// Don't warp unless actually close to player
						if (Math.abs(R.player.x + R.player.width/ 2 - (x + width/ 2)) < 16) {
							x = R.player.x + R.player.width / 2 - width / 2;
						}
					} else {
						ID = 3;
						return;
					}
					if (point_collides(x, y + 8)) {
						x = last.x;
						
						if (was_vanish) {
							was_vanish = false;
							ID = 3;
						} else {
							ID = 1;
						}
					} else if (point_collides(x + width - 1, y + 8)) {
						x = last.x;
						
						if (was_vanish) {
							was_vanish = false;
							ID = 3;
						} else {
							ID = 2;
						}
					}
				} else if (ID == 1) {
					if (R.player.x +R.player.width/2> x + width/2) {
						ID = 3;
					}
				} else if (ID == 2) {
					if (R.player.x + R.player.width/2 < x + width / 2) {
						ID = 3;
					}
				}
			} else if (tracked_axis == "y") {
				if (ID == 3) {
					if (y+ height/2 < R.player.y + R.player.height/2) {
						velocity.y = 220;
					} else {
						velocity.y = -220;
					}
					var ov:Float = velocity.y;
					y += FlxG.elapsed * velocity.y;
					if (point_collides(x+8, y )) {
						y -= FlxG.elapsed * velocity.y;
						velocity.y = 0;
					} else if (point_collides(x +8, y + height-1)) {
						y -= FlxG.elapsed * velocity.y;
						velocity.y = 0;
					}
					if (Math.abs(R.player.y + R.player.height/ 2 - (y + height/ 2)) < 4) {
						velocity.y = 0;
						ID  = 0;
					}
				} else if (ID == 0) {
					if (R.editor.editor_active == false) {
						
						if (Math.abs(R.player.y + R.player.height/ 2 - (y + height/ 2)) < 16) {
							y = R.player.y + R.player.height / 2 - height / 2;
						}
					} else {
						ID = 3;
						return;
					}
					if (point_collides(x+8,y)) {
						y = last.y;
						if (was_vanish) {
							was_vanish = false;
							ID = 3;
						} else {
						ID = 1;
						}
					} else if (point_collides(x + 8, y +height-1)) {
						y = last.y;
						if (was_vanish) {
							was_vanish = false;
							ID = 3;
						} else {
						ID = 2;
						}
					}
				} else if (ID == 1) {
					if (R.player.y +R.player.height/2> y+ height/2) {
						ID = 3;
					}
				} else if (ID == 2) {
					if (R.player.y + R.player.height/2 < y + height/ 2) {
						ID = 3;
					}
				}
			}
		} else {
			maxVelocity.x = tracking_velocity;
			maxVelocity.y = tracking_velocity;
			if (tracked_axis == "x") {
				if (velocity.x < 0) {
					acceleration.x = -props.get("accel");
					if (point_collides(x, y + 8)) {
						velocity.x = 60;
					}	
				} else {
					acceleration.x = props.get("accel");
					if (point_collides(x + 15, y + 8)) {
						velocity.x = -60;
					}
				}
			} else {
				if (velocity.y < 0) {
					acceleration.y = -props.get("accel");
					if (point_collides(x+8, y ) ) {
						velocity.y = 60;
					}	
				} else {
					acceleration.y = props.get("accel");
					if (point_collides(x + 8, y + 15)) {
						velocity.y = -60;
					}
				}
			}
		}
		super.update(elapsed);
	}
	
	private var t_hurt:Float = 0;
	private var t_hurt_a_lot:Float = 0;
	private var was_vanish:Bool = false;
	private function point_collides(_x:Float, _y:Float):Bool {
		if (parent_state.tm_bg.getTileCollisionFlags(_x, _y) != 0) return true;
		if (parent_state.tm_bg2.getTileCollisionFlags(_x, _y) != 0) return true;
		if (FlxX.point_inside_group_member(_x, _y, RaiseWall.ACTIVE_RaiseWalls)) {
			was_vanish = true;
			return true;
		}
		for (vb in VanishBlock.ACTIVE_VanishBlocks) {
			if (_x > vb.x && _x < vb.x + vb.width && _y > vb.y && _y < vb.y + vb.height && vb.is_open == false) {
				was_vanish = true;
				return true;
			}
		}
		return false;
	}
	override public function draw():Void 
	{
		
		
		angle -= 90;
		super.draw();
		angle += 90;
	}
	override public function postUpdate(elapsed):Void 
	{
		super.postUpdate(elapsed);
		
		
		
		if (angle == 0) {
			line1.move(x + 7, y + 9);
		} else if (angle == 90) {
			line1.move(x + 7, y + 7);
		} 
		if (angle == 180) {
			line1.move(x + 7, y + 7);
		} else if (angle == 270) {
			line1.move(x + 9, y + 7);
		} 
		
		// r
		if (angle == 0) { 
			big_part.move(line1.x+11, line1.y-2);
			small_part.move(laser_contact_sprite.x, line1.y-2);
			//small_part.move(laser_contact_sprite.x, laser_contact_sprite.y - 1);
			// d
		} else if (angle == 90) {
			big_part.move(line1.x, line1.y+10);
			small_part.move(line1.x, laser_contact_sprite.y-1);
			//small_part.move(laser_contact_sprite.x-1, laser_contact_sprite.y-1);
		} 
		// l
		if (angle == 180) {
			big_part.move(line1.x-10, line1.y);
			small_part.move(laser_contact_sprite.x-2, line1.y);
			//small_part.move(laser_contact_sprite.x, laser_contact_sprite.y-1);
			// u
		} else if (angle == 270) {
			big_part.move(line1.x-2, line1.y-11);
			small_part.move(line1.x-2, laser_contact_sprite.y-3);
			//small_part.move(laser_contact_sprite.x-1, laser_contact_sprite.y);
		}  
	}
}