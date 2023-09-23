package entity.trap;
import entity.MySprite;
import flash.display.BitmapData;
import help.AnimImporter;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.MyState;
/**
 * ...
 * @author Melos Han-Tani
 */

class LavaPillar extends MySprite
{

	public var VISTYPE_DARK:Int = 0;
	public var VISTYPE_LIGHT:Int = 1;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "LavaPillar");
		
		head_region = new FlxSprite();
		head_region.makeGraphic(22, 13, 0x77ffffff);
		body_region = new FlxSprite();
		body_region.makeGraphic(22, Std.int(height - head_region.height), 0x77ff00ff);
		head_region.x = body_region.x = x +(width - body_region.width) / 2;
		//is_debug = true;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic> ();
		//p.set("tmhurt", 0.25);
		p.set("spdrise", -50);
		//p.set("spddsnd", 50);
		p.set("tmhide", 1.5);
		p.set("tmactive", 2.5);
		p.set("pushvel", 35);
		p.set("pushticks", 	8);
		p.set("initlatency", 0);
		p.set("vistype", VISTYPE_DARK);
		p.set("vert_push_vel", 74);
		p.set("stick_out_px", 96);
		return p;
	
	}
	
	private var stick_out_px:Int = 96;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		
		//tm_hurt = p.get("tmhurt");
		tm_hurt = 0.13;
		p.remove("tmhurt");
		p.remove("spddsnd");
		rise_speed = p.get("spdrise");
		tm_hide = p.get("tmhide");
		tm_active = p.get("tmactive");
		pushticks = p.get("pushticks");
		push_vel = p.get("pushvel");
		init_latency = p.get("initlatency");
		vistype = p.get("vistype");
		vert_push_vel = p.get("vert_push_vel");
		stick_out_px = p.get("stick_out_px");
		if (stick_out_px < 16) stick_out_px = 16; if (stick_out_px > 96) stick_out_px = 96;
		change_visuals();
	}
	
	private var cur_bitmap:BitmapData;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case _ if (vistype == VISTYPE_DARK):
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 96, name, "dark");
			case _ if (vistype == VISTYPE_LIGHT):
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 96, name, "light");
		}
		cur_bitmap = AnimImporter.last_loaded_bitmap;
		animation.play("move", true);
	}
	
	
	public static var state_hidden:Int = 0;
	public static var state_rising:Int = 1;
	private var state_active:Int = 2;
	private var state_descending:Int = 3;
	
	private var t_hide:Float = 0;
	private var tm_hide:Float;
	private var t_active:Float = 0;
	private var tm_active:Float;
	
	private var rise_speed:Int;
	
	private var head_region:FlxSprite;
	private var body_region:FlxSprite;
	private var is_debug:Bool = false;
	
	private var t_hurt:Float = 0;
	private var tm_hurt:Float;
	private var push_vel:Int;
	private var pushticks:Int;
	private var vert_push_vel:Int;
	private var init_latency:Float;
	private var change_frame_ctr:Int = 0;
	private var no_push_ticks:Int;
	override public function update(elapsed: Float):Void 
	{
		
		if (!did_init) {
			if (is_debug) {
				
				HF.add_list_to_mysprite_layer(this, parent_state, [head_region, body_region]);
			}
		}
		// sleep
		super.update(elapsed);
		
		head_region.x = body_region.x = x + (width - body_region.width) / 2;
		
		if (init_latency > 0) {
			init_latency -= FlxG.elapsed;
			return;
		}
		switch (state) {
			case _ if (state_hidden == state):
				y = iy + 80;
				t_hide += FlxG.elapsed;
				if (t_hide > tm_hide) {
					t_hide -= tm_hide;
					state = state_rising;
				}
			case _ if (state_rising == state):
				velocity.y = rise_speed;
				change_frame_ctr++;
				if (change_frame_ctr > 9) {
					if (96 - (y - iy) > 16) {
						if (cur_bitmap == null) {
							change_visuals();
						}
						//myLoadGraphic(cur_bitmap, true, false, 32, Std.int(Math.min(stick_out_px,96 - (y - iy) + 8)));
					}
					change_frame_ctr = 0;
				}
				if (y <= iy) {
					//myLoadGraphic(cur_bitmap, true, false, 32, stick_out_px);
					y = iy;
					velocity.y = 0;
					state = state_active;
				}
			case _ if (state_active == state):
				t_active += FlxG.elapsed;
				if (t_active > tm_active) {
					t_active -= tm_active;
					state = state_descending;
				}
			case _ if (state_descending == state):
				acceleration.y = 300;
				change_frame_ctr++;
				if (change_frame_ctr > 9) {
					if (96 - (y - iy) > 16) {
						//myLoadGraphic(cur_bitmap, true, false, 32,Std.int(Math.min(stick_out_px,96 - (y - iy))));
					}
					change_frame_ctr = 0;	
				}
				if (y >= iy + 80) {
					//myLoadGraphic(cur_bitmap, true, false, 32, 16);
					acceleration.y = 0;
					y = iy + 80;
					state = state_hidden;
				}
		}
		
		var do_horizontal_pushoff:Bool = false;
		if (no_push_ticks > 0) no_push_ticks --;
		if (state != state_hidden) {
			if (R.player.is_jump_state_air()) {
				if (R.player.velocity.y < 0) {
					return;
				}
				
			}
			if (R.player.overlaps(head_region) || R.player.overlaps(body_region)) {
				if (R.player.y + R.player.height < head_region.y + head_region.height / 2) {
					if (R.input.jpA1) {
						
					} else {
						if (R.player.shield_overlaps(head_region,2) == false) {
							hurt_player_now();
							
							R.player.do_vert_push( vert_push_vel);
						} else {
							//R.player.velocity.y = 3 * vert_push_vel;	
							R.player.do_bounce();
							
							R.TEST_STATE.water_splash.dispatch(5, R.player.x + R.player.width / 2, R.player.y +R.player.height, 6, 320, -90, 80, 60, 0.5, 0.5);
							//R.player.y = (head_region.y + head_region.height / 2) - R.player.height - 1;
						}
					}
				} else {
					// If inside body, and shield is right dir, then push up but still hurt
					if (R.player.is_on_the_ground()) {
						if (R.player.shield_overlaps(body_region, 2)) {
							R.player.do_vert_push( -vert_push_vel);
						} else {
							if (parent_state.tm_bg.getTileCollisionFlags(R.player.x + 3, R.player.y + R.player.height) == FlxObject.ANY || parent_state.tm_bg2.getTileCollisionFlags(R.player.x + 3, R.player.y + R.player.height) == FlxObject.ANY) {
								no_push_ticks = 10;
							} else if (no_push_ticks <= 0) {
								R.player.do_vert_push( vert_push_vel);
							}
						}
					}
					hurt_player_now();
				}
				
				if (no_push_ticks <= 0) {
					R.player.touching |= FlxObject.DOWN;
				}
				do_horizontal_pushoff = true;
			} 
		}
		
		if (do_horizontal_pushoff) {
			var pmx:Float = R.player.x + (R.player.width / 2);
			var variance:Float = head_region.width / 2;
			var diff:Float = 0;
			if (pmx < head_region.x + variance) {
				diff = (pmx - head_region.x) / variance;
				R.player.do_hor_push( -push_vel - Std.int(0.7*diff*push_vel),false,false,pushticks);
			} else {
				diff = ((head_region.x + width) - pmx) / variance;
				R.player.do_hor_push(push_vel + Std.int(0.7*diff*push_vel), false,false,pushticks);
			}
		}
		
		if (t_hurt < tm_hurt) {
			t_hurt += FlxG.elapsed;
		}
		
	}
	
	private function do_hurt():Void {
			hurt_player_now();
	}
	private function hurt_player_now():Void {
		if (t_hurt < tm_hurt) {
			return;
		}
		t_hurt = 0;
		switch (vistype) {
			case _ if (vistype == VISTYPE_DARK):
				R.player.add_dark(5);
			case _ if (vistype == VISTYPE_LIGHT):
				R.player.add_light(5);
		}
	}
	
	override public function postUpdate(elapsed):Void 
	{
		super.postUpdate(elapsed);
		head_region.y = y + 3;
		body_region.y = y + head_region.height;
	}
	
	override public function destroy():Void 
	{
		if (is_debug) {
			HF.remove_list_from_mysprite_layer(this, parent_state,[head_region, body_region]);
		}
		super.destroy();
	}
}