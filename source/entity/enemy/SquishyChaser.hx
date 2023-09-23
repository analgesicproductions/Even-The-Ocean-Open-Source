package entity.enemy;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

import autom.SNDC;
import entity.MySprite;
import entity.util.RaiseWall;
import entity.util.VanishBlock;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import state.MyState;

class SquishyChaser extends MySprite
{

	public static var ACTIVE_SquishyChasers:List<SquishyChaser>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		aggro_zone = new FlxSprite();
		aggro_zone.makeGraphic(160 + 160 + 32, 32 + 160, 0xaaffffff);
		super(_x, _y, _parent, "SquishyChaser");
	}
	
	override public function change_visuals():Void 
	{
		
		var prefix:String = "";
		if (R.TEST_STATE.MAP_NAME.indexOf("PASS") != -1) prefix = "_pass";
		if (R.TEST_STATE.MAP_NAME.indexOf("CLIFF") != -1) prefix = "_cliff";
		if (R.TEST_STATE.MAP_NAME.indexOf("FALLS") != -1) prefix = "_falls";
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "dark"+prefix);
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "light"+prefix);
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, vistype);
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("chasevel", 120);
		p.set("tm_allow_damage", 1.5);
		p.set("bounce_mul", 1.4);
		p.set("dmg_amt", 32);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		acceleration.y = 200;
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		CHASE_VEL = props.get("chasevel");
		change_visuals();
		DMG_AMT = props.get("dmg_amt");
		tm_allow_damage = props.get("tm_allow_damage");
		width = 24; height = 16;
		offset.set(12, 16);
	}
	
	override public function destroy():Void 
	{
		
		ACTIVE_SquishyChasers.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [aggro_zone]);
		super.destroy();
	}
	
	
	private var is_aggro:Bool = false;
	private var aggro_zone:FlxSprite;
	private var allow_damage:Bool = false;
	override public function preUpdate():Void 
	{
		FlxObject.separate(this, parent_state.tm_bg);
		FlxObject.separate(this, parent_state.tm_bg2);
		super.preUpdate();
	}
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_SquishyChasers.add(this);
			HF.add_list_to_mysprite_layer(this, parent_state, [aggro_zone]);
		}
		
		
		t_allow_damage += FlxG.elapsed;
		if (t_allow_damage > tm_allow_damage) {
			t_allow_damage = 0;
			allow_damage = true;
		}
		aggro_zone.x = (x + width / 2) - (aggro_zone.width / 2);
		aggro_zone.y = (y  - aggro_zone.height + height + 16);
		aggro_zone.visible = false;
		if (is_aggro) {
			aggro_logic();
		} else {
			normal_logic();
		}
		
		//aggrod: 
		
		// touch you while velocity <= 0  = you bounce in dir of its velocity
		// touch while velocity > 0 : no shield = damage, bounce back, shield = no damage, bounce back
		// velocity > ?? with shield touching down: it flattens
		
		// pops up - no shield = damage, etc, jump before = higher effect 
		
		// Passive state
		//aggro state
		// - moving mode
		// - flattened mode
		super.update(elapsed);
	}
	
	private var mode:Int = 0;
	
	private function normal_logic():Void {
		velocity.x = 0;
		animation.play("idle");
		if (R.player.overlaps(aggro_zone)) {
			is_aggro = true;
			determine_and_enact_chase_dir();
		}
	}
	private var t_allow_damage:Float = 0;
	private var tm_allow_damage:Float = 1.5;
	private var CHASE_VEL:Int = 150;
	private var BRAKING_PER_FRAME:Int = 3;
	private var ACCEL_PER_FRAME:Int = 7;
	private var DMG_AMT:Int = 32;
	private var HOR_BOUNCE_VEL:Int = 100;
	private var fctr_jump:Int = 0;
	
	private var t_bounce:Float = 0;
	private var tm_bounce:Float = 1;
	private function aggro_logic():Void {
		
		
		
		// To pop, must be falling, in the air, and at a certain vertical position relative to enemy
		if (mode <= 4 && mode != 3) {
			if (R.player.overlaps(this) && R.player.velocity.y > 30 && R.player.is_on_the_ground(true)==false && R.player.y+R.player.height < y+8) {
				mode = 3;
				R.player.velocity.x = 0;
				R.player.y = y - R.player.height;
				//animation.play("squished");
				return;
			}
		}
		
		if (mode == 0) { // Follow you left
			if (R.player.x > x) {
				velocity.x += BRAKING_PER_FRAME;
				if (R.player.x > x + width) {
					if (velocity.x >= 0) {
						mode = 1;
						animation.play("walk_r");
					} 
				} else {
					velocity.x += ACCEL_PER_FRAME;
					if (velocity.x > 0) velocity.x = 0;
					animation.play("idle");
				}
			} else {
				if (velocity.x == 0) {
					animation.play("walk_l");
				}
				velocity.x -= ACCEL_PER_FRAME;
				if (velocity.x <= -CHASE_VEL) {
					velocity.x = -CHASE_VEL;
				}
			}
			if (R.player.overlaps(this) && R.player.velocity.x <= 0) {
				R.player.do_hor_push( -2 * HOR_BOUNCE_VEL, false, true, 5);
				if (velocity.x < 0 && R.player.get_shield_dir() == 1) {
					 
				} else if (velocity.x > 0 && R.player.get_shield_dir() == 3) {
					
				} else {
					if (allow_damage) damage_player(DMG_AMT);
				}
			} else if (R.player.overlaps(this)) {
				if (R.player.get_shield_dir() == 1 && velocity.x <= 0) {
				} else if (velocity.x > 0 && R.player.get_shield_dir() == 3) {
					
				}else {
					damage_player(DMG_AMT);
				}
				mode = 2;
				velocity.x = R.player.velocity.x;
				R.player.do_hor_push( Std.int(-R.player.velocity.x), false, true, 10);
				animation.play("idle_l");
			}
			if (!R.player.overlaps(aggro_zone)) {
				is_aggro = false;
			}
		} else if (mode == 1) { // Follow you right
			if (R.player.x + R.player.width < x + width) {
				velocity.x -= BRAKING_PER_FRAME;
				if (R.player.x + R.player.width < x) {
					if (velocity.x <= 0) {
						mode = 0;
						animation.play("walk_l");
					}
				} else {
					velocity.x -= ACCEL_PER_FRAME;
					if (velocity.x < 0) velocity.x = 0;
					animation.play("idle");
				}
			} else {
				if (velocity.x == 0) {
					animation.play("walk_r");
				}
				velocity.x += ACCEL_PER_FRAME;
				if (velocity.x >= CHASE_VEL) {
					velocity.x = CHASE_VEL;
				}
			}
			
			if (R.player.overlaps(this) && R.player.velocity.x >= 0) {
				R.player.do_hor_push( 2 * HOR_BOUNCE_VEL, false, true, 5);
				
				if (R.player.get_shield_dir() == 3) {
					
				} else {
					if (allow_damage) damage_player(DMG_AMT);
				}
			} else if (R.player.overlaps(this)) {
				if (R.player.get_shield_dir() == 3) {
				} else {
					damage_player(DMG_AMT);
				}
				mode = 2;
				velocity.x = R.player.velocity.x;
				R.player.do_hor_push( Std.int(-R.player.velocity.x), false, true, 10);
				animation.play("idle_r");
			}
			
			if (!R.player.overlaps(aggro_zone)) {
				is_aggro = false;
			}
		} else if (mode == 2) { // bumped
			if (velocity.x >= 16) {
				velocity.x -= BRAKING_PER_FRAME;
			} else if (velocity.x <= -16) {
				velocity.x += BRAKING_PER_FRAME;
			} else {
				velocity.x = 0;
				determine_and_enact_chase_dir();
			}
		} else if (mode == 3) {
			velocity.x = 0;
			y -= 8;
			if (overlaps(R.player)) {
				R.player.velocity.y = -200 * props.get("bounce_mul");
				R.sound_manager.play(SNDC.SFX_slimewall);
				if (R.player.energy_bar.get_LIGHT_percentage() > 0.65) {
					R.player.velocity.y *= 1.1;
				}
				if (R.player.energy_bar.get_LIGHT_percentage() > 0.8) {
					R.player.velocity.y *= 1.1;
				}
			}
			y += 8;
			animation.play("pop",true);
			mode = 4;
			
		} else if (mode == 4) {
			// Allow re-running into and bumping the slime, or awt for pop anim to finish and reset motion
			if (R.player.overlaps(this) && R.player.is_on_the_ground(true) && R.player.velocity.x >= 0) {
				mode = 2;
				velocity.x = R.player.velocity.x;
				R.player.do_hor_push( Std.int(-R.player.velocity.x), false, true, 10);
				animation.play("idle_l");
			} else if (R.player.overlaps(this) && R.player.is_on_the_ground(true) && R.player.velocity.x <= 0) {
				mode = 2;
				velocity.x = R.player.velocity.x;
				R.player.do_hor_push( Std.int(-R.player.velocity.x), false, true, 10);
				animation.play("idle_r");
			} else if (animation.finished) {
				determine_and_enact_chase_dir();
			}
		}
		
	}
	
	
	public function generic_overlap(o:FlxObject, is_plantblock:Bool = true):Bool {
		if (is_plantblock) {
			if (mode == 1 || mode == 2) {
				if (o.overlaps(this)) {
					return true;
				}
			}
		}
		return false;
	}
	public function generic_circle_overlap(cx:Float, cy:Float, cr:Float, _dmgtype:Int):Bool {
		if (FlxX.circle_flx_obj_overlap(cx, cy, cr, this)) {
			if (mode == 1 || mode == 2) { // Only pop if moving
				if (_dmgtype == dmgtype && Math.abs(velocity.x) > 30) {
					return true;
				} 
			}
		}
		return false;
	}
	
	private function damage_player(n:Int):Void {
		allow_damage = false;
		if (dmgtype == 0) {
			R.player.add_dark(n);
		} else {
			R.player.add_light(n);
		}
	}
	private function determine_and_enact_chase_dir():Void 
	{
		animation.play("idle");
		if (R.player.x < x) {
			mode = 0;
		} else {
			mode  = 1;
		}
	}
	override public function postUpdate(elapsed):Void 
	{
		
		
		super.postUpdate(elapsed);
		
		var tt:Int = parent_state.tm_bg2.getTileID(x + width, y + height / 2);
		var tt2:Int = parent_state.tm_bg2.getTileID(x, y + height / 2);
		
		if (HF.array_contains(HelpTilemap.active_sand, tt) || HF.array_contains(HelpTilemap.active_sand, tt2)) {
			x = last.x;
			y = last.y;
			velocity.y = 0;
		}
		
		for (rw in RaiseWall.ACTIVE_RaiseWalls.members) {
			if (rw != null && rw.overlaps(this)) {
				FlxObject.separate(this, rw);
			}
		}
		for (vb in VanishBlock.ACTIVE_VanishBlocks) {
			if (vb.is_active() && vb.overlaps(this)) {
				FlxObject.separate(this, vb);
			}
		}
			
	}
}