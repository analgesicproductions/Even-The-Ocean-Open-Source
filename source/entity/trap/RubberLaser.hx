package entity.trap;
import autom.SNDC;
import entity.MySprite;
import entity.player.BubbleSpawner;
import entity.util.RaiseWall;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import openfl.Assets;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import state.MyState;

// TODO change spritehsheets if vis changes
class RubberLaser extends MySprite
{

	private var bump:FlxSprite;
	private var laser_base:FlxSprite;
	private var laser_part:FlxSprite;
	
	public static var RubberLaserSpritesheet:BitmapData;
	
	public static var ACTIVE_RubberLasers:List < RubberLaser>;
	private static inline var state_inactive:Int = 0;
	private static inline var state_growing:Int = 1;
	private static inline var state_active:Int = 2;
	private static inline var state_shrinking:Int = 3;
	private var t_inactive:Float = 0;
	private var tm_inactive:Float = 2.0;
	private var t_active:Float = 0;
	private var tm_active:Float = 2.0;
	
	private var top_sensor:FlxObject;
	private var bottom_sensor:FlxObject;
	private var shield_bounce_vel:Int;
	private var noshield_bounce_vel:Int;
	private var dir:Int;
	private var init_wait:Float = 0;
	
	public function new(_x:Float, _y:Float, parent:MyState)
	{
		
		if (RubberLaserSpritesheet == null) {
			RubberLaserSpritesheet = Assets.getBitmapData("assets/sprites/trap/RubberLaser.png");
		}
		bump = new FlxSprite();
		ID = 0;
		laser_part = new FlxSprite();
		laser_base = new FlxSprite();
		top_sensor = new FlxObject(x - (laser_base.width + laser_part.width), y, laser_base.width + laser_part.width, 4);
		bottom_sensor = new FlxObject(x - (laser_base.width + laser_part.width), y + laser_base.height - 4, laser_base.width + laser_part.width, 4);
		
		super(_x, _y, parent, "RubberLaser");
		
	}
	
	private var vtype_dark:Int = 0;
	private var vtype_light:Int = 1;
	private var face_l_no_dmg:Bool = false;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic> ();
		p.set("vtype", 0);
		dir = 0;
		p.set("dir",dir);
		p.set("tinact", tm_inactive);
		p.set("tact", tm_active);
		vistype = 0;
		noshield_bounce_vel = -120;
		shield_bounce_vel = -180;
		p.set("sbouncev", shield_bounce_vel);
		p.set("nosbouncev", noshield_bounce_vel);
		p.set("damage", 14);
		p.set("init_wait", 0);
		p.set("face_l_no_dmg", 0);
		return p;
		
	}
	private function set_positions():Void {
		switch (dir) {
			case 0:		
				laser_base.x = x;
				laser_base.y = y;
				laser_part.x = x- laser_part.width;
				laser_part.y = y;
				laser_base.scale.x = laser_part.scale.x = 1.01;
			case 2:
				laser_base.scale.x = laser_part.scale.x = -1.01;
				laser_base.x = x + 16;
				laser_base.y = y;
				laser_part.x = x + 16 + 16;
				laser_part.y = y;
		}
	}
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		if (p.get("damage") == 36) {
			props.set("damage", 8);
		}
		tm_inactive = p.get("tinact");
		tm_active = p.get("tact");
		dir = p.get("dir");
		shield_bounce_vel = p.get("sbouncev");
		noshield_bounce_vel = p.get("nosbouncev");
		vistype = props.get("vtype");
		init_wait = props.get("init_wait");
		face_l_no_dmg = props.get("face_l_no_dmg") == 1;
		set_positions();
		change_visuals();
	}
	override public function change_visuals():Void 
	{
		switch (vistype) {
		
			
			case _ if (vtype_dark == vistype):
				dmgtype = 0;
				AnimImporter.loadGraphic_from_data_with_id(laser_base, 16, 32, name, "dark_base",true);
				AnimImporter.loadGraphic_from_data_with_id(laser_part, 16, 32, name, "dark_laser",true);
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "dark_shooter", true);
				AnimImporter.loadGraphic_from_data_with_id(bump, 48, 16, name, "dark_bump", true);
				
				play_shooter_anim("off");
			case _ if (vtype_light == vistype):
				dmgtype = 1;
				AnimImporter.loadGraphic_from_data_with_id(laser_base, 16, 32, name, "light_base",false);
				AnimImporter.loadGraphic_from_data_with_id(laser_part, 16, 32, name, "light_laser",false);
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "light_shooter",false);
				AnimImporter.loadGraphic_from_data_with_id(bump, 48, 16, name, "light_bump", true);
				play_shooter_anim("on");
		}
		laser_base.visible = laser_part.visible = false;
		bump.exists = false;
	}
	
	private function play_shooter_anim(name:String):Void {
		if (dir == 0) { // left
			animation.play(name + "_l");
			angle = 0;
		} else if (dir == 2) { // right
			animation.play(name + "_l");
			angle = 180;
		}
	}
	
	public function generic_circle_overlap(cx:Float,cy:Float,cr:Float,only_dmgtype:Int):Bool {
		if (this.dmgtype != only_dmgtype) { //1 only light breaks
			return false;
		} 
		if (state == state_active) {
			if (FlxX.circle_flx_obj_overlap(cx, cy, cr, bottom_sensor) || FlxX.circle_flx_obj_overlap(cx, cy, cr, top_sensor)) {
				return true;
			}
		}
		return false;
	}
	public function generic_overlap(o:FlxObject,only_dmgtype:Int=-1):Bool {
		if (this.dmgtype != only_dmgtype && only_dmgtype != -1) { //1 only light breaks
			return false;
		} 
		if (state == state_active) {
			if (bottom_sensor.overlaps(o) || top_sensor.overlaps(o)) {
				return true;
			}
		}
		return false;
	}
		
	
	override public function sleep():Void 
	{
		asleep = true;
		laser_base.exists = laser_part.exists = false;
	}
	override public function wakeup():Void 
	{
		asleep = false;
		laser_base.exists = laser_part.exists = true;
	}
	
	private var t_increase_bounce_height:Float = 0;
	private var ctr_overlap:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		
		super.update(elapsed);
		
		// HANDLE SLEEPING
		if (!did_init) {
			ACTIVE_RubberLasers.add(this);
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [laser_base, laser_part]);
			HF.add_list_to_mysprite_layer(this, parent_state, [bump], MyState.ENT_LAYER_IDX_FG2);
		}
		if (x < FlxG.camera.scroll.x - 300 || x > FlxG.camera.scroll.x + 300 + FlxG.camera.width || y < FlxG.camera.scroll.y - 200 || y > FlxG.camera.scroll.y + FlxG.camera.height + 200) {
		 	if (state == state_inactive && !asleep) {
				//sleep();
			}
		} else {
			if (asleep) {
				//wakeup();
			}
		}
		if (asleep) {
			return;
		}
		
		// Snap visuals to current position
		set_positions();
		
		if (init_wait > 0) {
			init_wait -= FlxG.elapsed;
			return;
		}
		switch (state) {
			case state_inactive:
				t_inactive += FlxG.elapsed;
				if (t_inactive > tm_inactive / 2) {
					
					if (ID == 0) {
						R.sound_manager.play(SNDC.followLaserNear, 1, true, this);
						ID++;
					} else {
						ID++;
						if (ID >= 30) ID = 0;
					}
					
					if (animation.name != null && animation.name.indexOf("charge") == -1) {
						play_shooter_anim("charge");
						laser_part.animation.play("warn");
						laser_base.animation.play("warn");
						laser_part.alpha = laser_base.alpha = 1;
						laser_base.visible = laser_part.visible = true;
					}
					
					// alpha goes from 0 to one from 0.5tm to 1tm
					//laser_base.alpha = laser_part.alpha = 1 - ((tm_inactive-t_inactive) / (tm_inactive / 2));
					//laser_base.alpha = laser_part.alpha = laser_part.alpha + 0.25;
					var a:Float = 1 - ((tm_inactive-t_inactive) / (tm_inactive / 2));
					if (a > 1) a = 1;
					laser_base.setColorTransform(a, a, a);
					laser_part.setColorTransform(a, a, a);
					//laser_base.color = Std.int(255 * a) << 16 + Std.int(255 * a) << 8 + Std.int(255 * a);
					//laser_part.color = Std.int(255 * a) << 16 + Std.int(255 * a) << 8 + Std.int(255 * a);
					//laser_part.color = 0x333333;
					//a=1 , r = 0xff
				}
				if (t_inactive > tm_inactive) {
					laser_part.color = 0xffffff;
					t_inactive = 0;
					ID = 0;
					laser_base.animation.play("grow");
					laser_part.animation.play("grow");
					state = state_growing;
				}
			case state_growing:
				if (laser_base.animation.finished) {
					play_shooter_anim("on");
					R.sound_manager.play(SNDC.followLaserHit, 1, true, this);
					ID = 1;
					laser_base.animation.play("attacking");
					laser_part.animation.play("attacking");
					state = state_active;
				}
			case state_active:
				
					if (ID == 0) {
						R.sound_manager.play(SNDC.followLaserHit, 1, true, this);
						ID++;
					} else {
						ID++;
						if (ID >= 30) ID = 0;
					}
				
				t_active += FlxG.elapsed;
				if (t_active > tm_active) {
					t_active = 0;
					laser_base.animation.play("shrink");
					laser_part.animation.play("shrink");
					state = state_shrinking;
					ctr_overlap = 0;
				}
				
				if (t_increase_bounce_height > 0) t_increase_bounce_height -= FlxG.elapsed;
				if (R.input.jpA1) {
					//t_increase_bounce_height = 0.2;
				}

				// Snap sensors to current position
				top_sensor.width = bottom_sensor.width = cur_width;
				top_sensor.y = y+12;
				bottom_sensor.y = y + laser_base.height - 16;
				switch (dir) {
					case 0: // left...
						top_sensor.x = x - cur_width + 16;
						bottom_sensor.x = x - cur_width + 16;
					case 2: // right..?
						top_sensor.x = x + width / 2;
						bottom_sensor.x = x + width / 2;
				}
				// bubble flvor dark = 0, l = 1
				if (R.player.shield_overlaps(bottom_sensor, 0) || (R.player.has_bubble && R.player.velocity.y < -50 && (BubbleSpawner.cur_bubble_flavor == dmgtype) && R.player.overlaps(bottom_sensor))) {
					R.player.velocity.y = -shield_bounce_vel;
					R.sound_manager.play(SNDC.rlaser_shield);
					if (!bump.exists) {
						bump.exists = true;
						bump.angle = 0;
						bump.animation.play("bump");
						bump.x = R.player.x-20;
						bump.y = R.player.y - 6;
					}
				} else if (R.player.shield_overlaps(top_sensor, 2) || (R.player.has_bubble && R.player.y < top_sensor.y - 4 && R.player.velocity.y > 50 && (BubbleSpawner.cur_bubble_flavor == dmgtype) && R.player.overlaps(top_sensor))) {
					
					
					if (!bump.exists) {
						bump.exists = true;
						bump.angle = 180;
						bump.animation.play("bump");
						bump.x = R.player.x-17;
						bump.y = R.player.y +12;
					}
					
					R.sound_manager.play(SNDC.rlaser_shield);
					//if (t_increase_bounce_height > 0) {
						//R.player.do_bounce(true,0,2*shield_bounce_vel);
					//} else {
					R.player.do_bounce(true, 0, shield_bounce_vel);
					if (R.player.has_bubble && R.player.get_shield_dir() != 2) {
						R.player.y = top_sensor.y - R.player.height;
					}
					//}
				} else if (R.player.overlaps(top_sensor) || R.player.overlaps(bottom_sensor)) {
					if (face_l_no_dmg && R.player.facing == FlxObject.LEFT) {
						
					} else {
						ctr_overlap++;
						var max_ctr:Float = 45.0;
						if (ctr_overlap > max_ctr) {
							ctr_overlap = Std.int(max_ctr);
						}
						var c:Float = (ctr_overlap +45) / (45 + max_ctr);
						hurt_player();
						if (dir == 0) {
							if (R.player.get_shield_dir() == 1) {
								R.player.apply_wind( -150 * c, 0);
							} else {
								R.player.apply_wind( -120 * c, 0);
							}
						} else if (dir == 2) {
							if (R.player.get_shield_dir() == 3) {
								R.player.apply_wind( 150* c, 0);
							} else {
								R.player.apply_wind( 120* c, 0);
							}
						}
					}
				} else {
					ctr_overlap = 0;
				}
				
				
			case state_shrinking:
				if (laser_base.animation.finished) {
					state = state_inactive;
					play_shooter_anim("off");
				}
		}
		
		if (t_hurt < tm_hurt) {
			t_hurt += FlxG.elapsed;
		}
	}
	
	private var t_hurt:Float = 0;
	private var tm_hurt:Float = 0.033 * 6;
	private function hurt_player():Void {
		if (t_hurt > tm_hurt) {
			t_hurt = 0;
			R.sound_manager.play(SNDC.rlaser_hit);
			if (vistype == vtype_dark) {
				R.player.add_dark(props.get("damage"));
			} else if (vistype == vtype_light) {
				R.player.add_light(props.get("damage"));
			}
		}
	
	}
	private var cur_width:Int = 0;
	override public function draw():Void 
	{
		//Log.trace([bump.exists, bump.alpha, bump.visible, bump.x, bump.y]);
		if (bump.exists) {
			if (null != bump.animation.curAnim) {
				if (bump.animation.finished) {
					bump.exists = false;
				}
			}
		}
		
		
		var ox:Float = laser_part.x;
		var d:Float = 0;
		var chk:Float = 16;
		if (dir == 0) {
			chk = -16;
			d = -laser_part.width; 
		}else if (dir == 2) {
			d = laser_part.width;
		}
		// w64
		if (!asleep) {
		for (i in 0...25) {
			if (laser_part.visible == false) break;
			if ((dir == 0 && laser_part.x > FlxG.camera.scroll.x- 100) || (dir == 2 && laser_part.x < FlxG.camera.scroll.x + FlxG.camera.width + 100)) {
				
				var lpx:Int = Std.int(laser_part.x-1); // left 
				if (dir == 2) { // right
					lpx = Std.int(laser_part.x + 16);
				}
				if (dir == 0 || dir == 2) {
					//if (parent_state.tm_bg.getTileCollisionFlags(lpx, laser_part.y + 10) != 0 || parent_state.tm_bg.getTileCollisionFlags(lpx+2*chk, laser_part.y + 10)!= 0  ||  parent_state.tm_bg.getTileCollisionFlags(lpx+chk, laser_part.y + 10) != 0 ||  parent_state.tm_bg.getTileCollisionFlags(lpx+3*chk, laser_part.y + 10)!= 0 ) {
						//if (i != 0) laser_part.draw();
						//break;
					//}
					
					var db:Bool = false;
					for (raisewall in RaiseWall.ACTIVE_RaiseWalls.members) {
						if (raisewall != null && lpx >= raisewall.x && lpx <= raisewall.x + raisewall.width && laser_part.y + 10 >= raisewall.y && laser_part.y + 10 <= raisewall.y + raisewall.height) {
							if (i != 0) laser_part.draw();
							db = true;
							break;
						}
					}
					if (db) break;
					
					if (parent_state.tm_bg.getTileCollisionFlags(lpx, laser_part.y + 10) != 0 ) {
						var tid:Int = parent_state.tm_bg.getTileID(lpx, laser_part.y + 10);
						if (HF.array_contains(HelpTilemap.permeable, tid)) {
						} else {
							if (i != 0) laser_part.draw();
							break;
						}
					}
				}
				
				if (i != 0) laser_part.draw();
				laser_part.x += d;
				
			} else {
				break;
			}
		}
		}
		if (dir == 0) {
			cur_width = Math.floor(x - laser_part.x + 16);
		} else if (dir == 2) {
			cur_width = Math.floor((laser_part.x + laser_part.width) - (x + width/2));
		}
		laser_part.x = ox;
		super.draw();
	}
	override public function destroy():Void 
	{
		ACTIVE_RubberLasers.remove(this);
		
			HF.remove_list_from_mysprite_layer(this, parent_state, [bump], MyState.ENT_LAYER_IDX_FG2);
		HF.remove_list_from_mysprite_layer(this, parent_state, [laser_base, laser_part]);
		laser_base.destroy();
		laser_part.destroy();
		super.destroy();
	}
}