package entity.trap;
import autom.SNDC;
import entity.MySprite;
import entity.ui.Inventory;
import entity.util.VanishBlock;
import global.C;
import global.Registry;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.MyState;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Melos Han-Tani
 */

class Pew extends MySprite
{
	
	
	public var _max_bullets:Int;
	private var _bullet_speed:Int;
	private var _fire_interval:Float;
	private var t_tick:Int = 0;
	private var tm_tick:Int = 0;
	private var fire_dir:Int;
	public var bullets:FlxGroup;
	public var buls_l:FlxGroup;
	public var buls_d:FlxGroup;
	public var fgContainer:FlxTypedGroup<FlxSprite>;
	private var fire_timer:Float = 0;
	private var fpattern:Int;
	public static var ACTIVE_Pews:FlxTypedGroup<Pew>;
	
	private static inline var BASE_DAMAGE:Int = 24;
	private static inline var PATTERN_LIGHT:Int = 0;
	private static inline var PATTERN_DARK:Int = 1;
	private static inline var PATTERN_ALTERNATE:Int = 2;
	
	private static inline var VIS_T_DEBUG:Int = 0;
	private static inline var VIS_T_LIGHT:Int = 1;
	private static inline var VIS_T_DARK:Int = 2;
	private static inline var VIS_T_LIGHT_DREAM:Int =3;
	private static inline var VIS_T_DARK_DREAM:Int = 4;
	
	private var is_dream:Bool = false;
	private var dream_no_Shield:Bool = false;
	
	
	public function new(_x:Int,_y:Int,_parent_state:MyState) 
	{
		// defaults
		fgContainer = new FlxTypedGroup<FlxSprite>();
		super(_x, _y, _parent_state, "Pew");
		R = Registry.R;
		does_proximity_sleep = true;
		
		//Log.trace(Type.typeof(this));	
		//bullets = HF.init_flxsprite_group(_max_bullets, 8, 8);
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var _p:Map<String,Dynamic> = new Map<String,Dynamic> ();
		_p.set("mb", 4);
		_p.set("bspd", 40);
		_p.set("fint", 0.7);
		_p.set("dir", 2); // urdl, 0123
		_p.set("fpattern", PATTERN_LIGHT); // 
		_p.set("vistype", VIS_T_LIGHT);
		_p.set("bullet_vis", "-1,-1");
		_p.set("is_dream", 0);
		_p.set("rhythm_pattern", "1,1");
		_p.set("fint_TICKS", -1);
		_p.set("white_no_dmg", 0);
		return _p;
		
		var s:String;
	}
	
	private var white_no_dmg:Bool = false;
	private var rit:Array<Int>;
	private var rit_idx:Int;
	override public function change_visuals():Void 
	{
		
		if (vistype == 0 || vistype == 1) {
			if (fpattern == PATTERN_DARK) {
				vistype = VIS_T_DARK;
			} else {
				vistype = VIS_T_LIGHT;
			}
		}
		switch (vistype) {
			default:
				if (vistype == 0) {
					vistype = VIS_T_LIGHT;	
				}
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, Std.string(vistype));
			case VIS_T_LIGHT:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, Std.string(VIS_T_LIGHT));
			case VIS_T_DARK:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, Std.string(VIS_T_DARK));
		}
		
		width = height = 16;
		offset.set(8,8);
		animation.play("idle", true);
		if (fire_dir == 0) {
			angle = 0;
			offset.y -= 16;
		}
		if (fire_dir == 1) {
			angle = 90;
			offset.x += 16;
		}
		if (fire_dir == 2) {
			angle = 180;
			offset.y += 16;
		}
		if (fire_dir == 3) {
			angle = 270;
			offset.x -= 16;
		}
	}
	override public function destroy():Void 
	{
		ACTIVE_Pews.remove(this, true);
		HF.remove_list_from_mysprite_layer(this, parent_state, [buls_l, buls_d],MyState.ENT_LAYER_IDX_BG1);
		HF.remove_list_from_mysprite_layer(this, parent_state, [fgContainer],MyState.ENT_LAYER_IDX_FG2);
		buls_l.destroy();
		buls_d.destroy();
		fgContainer.destroy();
		fgContainer = null;
		buls_l = buls_d  = null;
		super.destroy();
	}
	private function create_bullets(nr_bullets:Int):Void {
		
		if (buls_d != null && buls_l != null) {
			buls_d.clear();
			buls_l.clear();
		} else {
			buls_d = new FlxGroup();
			buls_l = new FlxGroup();
		}
		
		for (i in 0..._max_bullets) {
			var b:MyBullet = new MyBullet(0, 0, true);
			buls_d.add(b);
			
			b = new MyBullet(0, 0, false);
			buls_l.add(b);
		}
	}
	
	private function set_bullet_vistype(vis:Int):Void {
		for (i in 0..._max_bullets) {
			var b:MyBullet = cast(buls_d.members[i], MyBullet);
			var bb:MyBullet = cast(buls_l.members[i], MyBullet);
			AnimImporter.loadGraphic_from_data_with_id(b, 16, 16, name + "Bullet", Std.string(VIS_T_DARK));
			AnimImporter.loadGraphic_from_data_with_id(bb, 16, 16, name + "Bullet", Std.string(VIS_T_LIGHT));
			b.width = b.height = bb.width = bb.height = 8;
			b.offset.x = b.offset.y = bb.offset.x = bb.offset.y = 4;
			b.height = bb.height = 9;
			
			b.animation.play("move");
			bb.animation.play("move");
		}
	}
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		
		rit = HF.string_to_int_array(props.get("rhythm_pattern"),true);
		rit_idx = -1;
		_max_bullets = props.get("mb");
		_bullet_speed = props.get("bspd");
		_fire_interval = props.get("fint");
		fire_dir = props.get("dir");
		fpattern = props.get("fpattern");
		vistype = props.get("vistype");
		tm_tick = t_tick = -1;
		white_no_dmg = 1 == props.get("white_no_dmg");
		if (props.get("fint_TICKS") > 0) {
			tm_tick = props.get("fint_TICKS");
			t_tick = tm_tick;
			
		}
		change_visuals();
		
		create_bullets(_max_bullets);
		set_bullet_vistype(vistype);
		if (props.get("is_dream") == 1) {
			is_dream = true;
			
		}
		buls_d.setAll("exists", false);
		buls_l.setAll("exists", false);
	}

	override public function sleep():Void {
		buls_d.exists = false;
		buls_l.exists = false;
	}
	override public function wakeup():Void {
		buls_l.exists = true;
		buls_d.exists = true;
	}
	private var next_kind:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (is_dream) {
			if (R.inventory.is_item_found(Inventory.ITEM_DREAMAMINE)) {
				alpha = 1;
				buls_d.setAll("alpha", 1);
				buls_l.setAll("alpha", 1);
				dream_no_Shield = false;
			} else {
				alpha = 0.5;
				buls_d.setAll("alpha", 0.5);
				buls_l.setAll("alpha", 0.5);
				dream_no_Shield = true;
			}
		}
		
		super.update(elapsed);
		
		
		
		if (!did_init) {	
			ACTIVE_Pews.add(this);
		
			//HF.insert_list_before_object_in_mysprite_layer(this, parent_state,[buls_d, buls_l]);
			HF.add_list_to_mysprite_layer(this, parent_state, [buls_d, buls_l], MyState.ENT_LAYER_IDX_BG1);
			HF.add_list_to_mysprite_layer(this, parent_state, [fgContainer], MyState.ENT_LAYER_IDX_FG2);
			//HF.add_list_to_mysprite_layer(this, parent_state, [buls_d, buls_l]);
			did_init = true;
		}
		
		var moveonticks:Bool = false;
		if (tm_tick > 0) {
			t_tick++;
			if (t_tick >= tm_tick) {
				t_tick = 0;
				moveonticks = true;
			}
		}
		
		fire_timer += FlxG.elapsed;
		if (fire_timer > _fire_interval || moveonticks) {
			
			fire_timer = 0;
			
			rit_idx ++;
			if (rit_idx == rit.length) {
				rit_idx = 0;
			}
			
			
			if (asleep) {
				return;
			}
			
			if (rit[rit_idx] == 0) {
				
			} else {
				if (rit[rit_idx] == 2) { // fprce light
					next_kind = 1;
				}  else {
					next_kind = 0; // forec dark
				}

			var b:MyBullet = null;
			if (fpattern == PATTERN_DARK) {
				if (buls_d.getFirstAvailable() != null) {
					b = cast(buls_d.getFirstAvailable(), MyBullet);
				}
			} else if (fpattern == PATTERN_LIGHT) {
				if (buls_l.getFirstAvailable() != null) {
					b = cast(buls_l.getFirstAvailable(), MyBullet);
				}
			} else if (fpattern == PATTERN_ALTERNATE) {
				if (next_kind == 0) {
					next_kind = 1;
					if (buls_d.getFirstAvailable() != null) {
						b = cast(buls_d.getFirstAvailable(), MyBullet);
					}
				} else {
					next_kind = 0;
					if (buls_l.getFirstAvailable() != null) {
						b = cast(buls_l.getFirstAvailable(), MyBullet);
					}
				}
			}
			if (b != null) {
				b.timers[0] = -1; b.timers[1] = -1; b.timers[2] = -1;
				b.timers[3] = -1; b.timers[4] = -1;
				b.exists = true;
				b.x = x + (width / 2) - (b.width / 2);
				b.y = y + (height / 2) - (b.height / 2);
				b.animation.play("move");
				b.alpha = 0;
				b.nohittile = 15;
				animation.play("shoot",true);
				switch (fire_dir) {
					case 0:
						b.velocity.y = -_bullet_speed;
						b.y -= 6;
						b.y += 16;
					case 1:
						b.x += 6;
						b.x -= 16;
						b.velocity.x = _bullet_speed;
					case 2:
						b.y += 6;
						b.y -= 16;
						b.velocity.y = _bullet_speed;
					case 3:
						b.x -= 6;
						b.x += 16;
						b.velocity.x = -_bullet_speed;
				}
			}
			}
		}
		
		
		for (vb in VanishBlock.ACTIVE_VanishBlocks) {
			if (vb.is_open == false) {
				if (fire_dir == 0) {
					//urdl
					if (vb.x == x && vb.y < y) {
						generic_overlap(vb);
					}
				} else if (fire_dir == 1) {
					if (vb.y == y && vb.x > x) {
						
						generic_overlap(vb);
					}
				} else if (fire_dir == 2) {
					if (vb.x == x && vb.y > y) {
						
						generic_overlap(vb);
					}
				} else if (fire_dir == 3) {
					if (vb.y == y && vb.x < x) {
						
						generic_overlap(vb);
					}
				}
			}
		}
		
		var i:Int = 0;
		if (fpattern != PATTERN_DARK ) {
			for (i in 0...buls_l.members.length) {
				if (buls_l.members[i] == null) continue;
				var b:MyBullet = cast(buls_l.members[i], MyBullet);	
				b.alpha += 0.1; b.alpha *= 1.3;
				if (b.nohittile > 0) b.nohittile --;
				if (b.exists && (Math.abs(b.y - y) + Math.abs(b.x - x)) > 900) {
 					b.velocity.x = b.velocity.y = 0;
					if (b.animation.curAnim != null && b.animation.curAnim.name != "burst") b.animation.play("burst");
					if (b.animation.finished) {
						b.exists = false;
					}
				} else {
					if (b.ID == 1) {
						b.velocity.x = b.velocity.y = 0;
						if (b.animation.curAnim != null && b.animation.curAnim.name != "burst") {
							b.animation.play("burst");
							if (fgContainer.members.indexOf(b) == -1) fgContainer.add(b);
						} else {
							if (b.animation.finished) {
								fgContainer.remove(b, true);
								b.exists = false;
								b.ID = 0;
							}
						}
					} else if (b.exists) {
						water_charger_help(b, 0);
						// crazy unused pew buonce thing
						if (white_no_dmg && b.ID != 1) {
							
							b.immovable = true;
							b.width = b.height = 16;
							b.height = 12;
							b.offset.set(0, 0);
							var ovy:Float = R.player.velocity.y;
							if (ix - b.x > 4 && FlxObject.separate(b, R.player) && ovy > 50 && R.player.touching == FlxObject.DOWN) {
								if (b.acceleration.y == 0) {
									b.acceleration.y = -359;
									b.velocity.y = 80;
								} 
							}
							if (b.y < iy+3 && b.acceleration.y != 0) {
								b.y = iy+4;
								b.velocity.y = b.acceleration.y = 0;
								R.player.y+=2;
								if (R.player.x < b.x + b.width && R.player.x + R.player.width > b.x) {
									if (R.player.overlaps(b)) {
										R.player.velocity.y = 0;
										R.player.y = b.y - R.player.height + 2;
									}
								}
								R.player.y-=2;
							}
							b.width = b.height = 8;
							b.offset.set(4,4);
						} 
						if (!white_no_dmg && R.player.shield_overlaps(b) && !dream_no_Shield) {
							b.ID = 1;
							R.sound_manager.play(SNDC.pew_hit_shield);
						} else if (!white_no_dmg && b.overlaps(R.player)) {
							
							if (R.player.has_bubble == false && R.player.add_light(BASE_DAMAGE,5,b.x+b.width/2,b.y+b.width/2) > 0) {
								FlxG.cameras.shake(0.01, 0.1);
								R.sound_manager.play(SNDC.pew_hit);
							}
							b.ID = 1;
						// Check for BG or BG2 collisions
						} else {
							
							if (b.nohittile <= 0) {
								var mid_x:Int = Std.int(b.x + 4);
								var mid_y:Int = Std.int(b.y + 4);
								var tile_type_bg:Int = parent_state.tm_bg.getTileID(mid_x, mid_y);
								var tile_type_bg2:Int = parent_state.tm_bg2.getTileID(mid_x, mid_y);
								if (parent_state.tm_bg.getTileCollisionFlags(mid_x, mid_y) != 0 || parent_state.tm_bg2.getTileCollisionFlags(mid_x, mid_y) != 0) {
									
									if (!HF.array_contains(HelpTilemap.permeable, tile_type_bg) && !HF.array_contains(HelpTilemap.permeable, tile_type_bg2)) {
										//Log.trace([HelpTilemap.permeable, tile_type_bg, tile_type_bg2]);
										b.ID = 1;
										R.sound_manager.play(SNDC.pew_wall, 1, true, b);
									}
								}
							}
							
						}
					}
				}
			}
		}
		if (fpattern != PATTERN_LIGHT) {
			for (i in 0...buls_d.members.length) {
				if (buls_d.members[i] == null) continue;
				var b:MyBullet = cast(buls_d.members[i], MyBullet);
				
				if (b.nohittile > 0) b.nohittile --;
				b.alpha += 0.1; b.alpha *= 1.3;
				if (b.exists && (Math.abs(b.y - y) + Math.abs(b.x - x)) > 900) {
					b.velocity.x = b.velocity.y = 0;
					if (b.animation.curAnim != null &&b.animation.curAnim.name != "burst") b.animation.play("burst");
					if (b.animation.finished) {
						b.exists = false;
					}
				} else {
					if (b.ID == 1) {
						b.velocity.x = b.velocity.y = 0;
						if (b.animation.curAnim != null &&b.animation.curAnim.name != "burst") {
							b.animation.play("burst");
							if (fgContainer.members.indexOf(b) == -1) fgContainer.add(b);
						} else {
							if (b.animation.finished) {
								fgContainer.remove(b, true);
								b.exists = false;
								b.ID = 0;
							}
						}
					} else if (b.exists) {
						water_charger_help(b,1);
						if (R.player.shield_overlaps(b) && !dream_no_Shield) {
							b.ID = 1;
							R.sound_manager.play(SNDC.pew_hit_shield);
						} else if (b.overlaps(R.player)) {
							if (R.player.has_bubble == false && R.player.add_dark(BASE_DAMAGE,4,b.x+b.width/2,b.y+b.width/2) > 0) {
								//FlxG.cameras.shake(0.01, 0.1);
								R.sound_manager.play(SNDC.pew_hit);
							}
							b.ID = 1;
						} else {
							
							
							if (b.nohittile <= 0) { 
								var mid_x:Int = Std.int(b.x + 4);
								var mid_y:Int = Std.int(b.y + 4);
								var tile_type_bg:Int = parent_state.tm_bg.getTileID(mid_x, mid_y);
								var tile_type_bg2:Int = parent_state.tm_bg2.getTileID(mid_x, mid_y);
								
								if (!HF.array_contains(HelpTilemap.permeable, tile_type_bg) && !HF.array_contains(HelpTilemap.permeable, tile_type_bg2)) {
									if (parent_state.tm_bg.getTileCollisionFlags(mid_x, mid_y) != 0 || parent_state.tm_bg2.getTileCollisionFlags(mid_x, mid_y) != 0) {
										b.ID = 1;
										
										R.sound_manager.play(SNDC.pew_wall, 1, true, b);
									}
								}
							}
						}
					}
				}
			}
		}
		
	}
	
	private function water_charger_help(b:FlxSprite,needed_dmgtype:Int):Void {
		if (WaterCharger.ACTIVE_WaterChargers.length > 0) {
			for (wc in WaterCharger.ACTIVE_WaterChargers) {
				if (wc.pt_overlaps_tile(b.x + 4, b.y + 4,needed_dmgtype)) {
					b.ID = 1;
					return;
				}
			}
		}
		return;
	}
	/**
	 * Checks if o overlaps any bullets. type = 0 = dark only, type = 1 = light only
	 * @param	o
	 * @param	type: 0 = check for dark
	 * @return
	 */
	public function generic_overlap(o:FlxObject, type:Int = -1,sorrymom:Int=-1):Bool {
		if (asleep) return false;
		var bul:FlxSprite;
		
		if (type == 0 || type == -1) { 
			for (i in 0...buls_d.length) {
				bul = cast buls_d.members[i];
				if (bul.exists && bul.overlaps(o) && bul.ID != 1) {
					bul.ID = 1;
					if (sorrymom == 0) { // the non-pew only breaks on lights. note this is backwards from 'type'. haha sory
						return false;
					}
					return true;
				}
			} 
		} 
		
		if (type == 1 || type == -1) {
			for (i in 0...buls_l.length) {
				bul = cast buls_l.members[i];
				if (bul.exists && bul.overlaps(o) && bul.ID != 1) {
					bul.ID = 1;
					if (sorrymom == 1) {
						return false;
					}
					return true;
				}
			} 
		}
		return false;
	}
	public function generic_circle_overlap(cx:Float,cy:Float,cr:Float,o:FlxObject, type:Int = -1):Bool {
		if (asleep) return false;
		var bul:FlxSprite;
		if (fpattern !=  PATTERN_LIGHT) {
			for (i in 0...buls_d.length) {
				bul = cast buls_d.members[i];
				if (bul.exists && bul.ID != 1 && FlxX.circle_flx_obj_overlap(cx,cy,cr,bul) ) {
					bul.ID = 1;
					
					if (type == 0 || type == -1) {
						return true;
					}
					return false;
				}
			}
		} 
		
		if (fpattern != PATTERN_DARK ) {
			for (i in 0...buls_l.length) {
				bul = cast buls_l.members[i];
				if (bul.exists  && bul.ID != 1 && FlxX.circle_flx_obj_overlap(cx,cy,cr,bul)) {
					bul.ID = 1;
					if (type == -1 || type == 1) {
						return true;
					}
					return false;
				}
			}
		}
		return false;
	}
	
	override public function draw():Void 
	{
		if (R.editor.editor_active) {
			var ox:Float = offset.x;
			var oy:Float = offset.y;
			
			offset.set(8, 8);
			super.draw();
			offset.set(ox, oy);
		}
		super.draw();
	}
		
}