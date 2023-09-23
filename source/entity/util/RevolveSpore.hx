package entity.util;
/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import autom.SNDC;
import entity.MySprite;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.MyState;
import state.TestState;

class RevolveSpore extends MySprite
{
	
	private var indicator:FlxSprite;
	private var hand:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
			o = new FlxObject(0, 0, 1, 1);
		indicator = new FlxSprite();
		hand = new FlxSprite();
		super(_x, _y, _parent, "RevolveSpore");
	}
	
	
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case "0":
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "default");
				AnimImporter.loadGraphic_from_data_with_id(hand, 32, 32, name, "default");
				AnimImporter.loadGraphic_from_data_with_id(indicator, 32, 32, name, "default");
				dmgtype = 0;
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "default");
				AnimImporter.loadGraphic_from_data_with_id(hand, 32, 32, name, "default");
				AnimImporter.loadGraphic_from_data_with_id(indicator, 32, 32, name, "default");
				dmgtype = 1;
		}
		indicator.width = indicator.height = 2;
		indicator.offset.set(15, 15);
		indicator.animation.play("indicator");
		width = height = 16;
		hand.width = hand.height = 16;
		offset.set(8, 8);
		hand.offset.set(8, 8);
		animation.play("idle", true);
		hand.animation.play("hand");
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "2,2");
		p.set("base_vel", 420);
		p.set("hurt_ticks", 5);
		return p;
	}
	

	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = props.get("vis-dmg").split(",")[0];
		base_launch_vel = props.get("base_vel");
		hurt_ticks = props.get("hurt_ticks");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [indicator,hand]);
		super.destroy();
	}
	
	private var hurt_ticks:Int = 0;
	private var launch_angle:Int = 0;
	private var base_launch_vel:Float = 0;
	
	private var hurt_ctr:Int = 0;
	private var hold_right_ctr:Int = 0;
	private var hold_left_ctr:Int = 0;
	
	private var xscale:Float = 0;
	private var yscale:Float = 0;
	private var o:FlxObject;
	override public function update(elapsed: Float):Void 
	{
		
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [indicator,hand]);
		}
		if (state == 0) {
			hand.move(x, y);
			indicator.visible = false;
			if (R.player.overlaps(this)) {
				state = 1;
				hand.animation.play("on");
				
				
				//Log.trace(R.player.animation.curAnim);
				if (R.player.animation.curAnim != null && R.player.animation.curAnim.name.charAt(0) == "w") {
					//Log.trace(R.player.animation.curAnim.name);
					R.player.animation.play("f" + R.player.animation.curAnim.name.substr(1, 2));
					R.player.touching = 0;
					R.player.velocity.set(0, 0);
					if (R.player.facing == FlxObject.LEFT) {
						R.player.x = R.player.last.x = x + 5;
					} else {
						R.player.x = R.player.last.x = x + 3;
					}
					R.player.y = R.player.last.y =  y;
				}
				
				launch_angle = 90;
				//rad - 80
				TestState.truly_set_default_cam(parent_state.tm_bg.width, parent_state.tm_bg.height, "launcher");
				R.sound_manager.play(SNDC.menu_move);
				
				FlxG.camera.only_lerp_y = false;
			}
		} else if (state == 1) {
			
			
			indicator.visible = true;
			R.player.velocity.set(0, 0);
			R.player.x = x+3;
			if (R.player.facing == FlxObject.LEFT) {
				R.player.x = R.player.last.x = x + 5;
			} 
			R.player.y = y;
			
			if (R.input.right) {
				launch_angle-=2;
			} 
			if (R.input.left) {
				launch_angle+=2;
			}
			
			if (launch_angle < 0) {
				launch_angle = 360 + launch_angle;
			} else if (launch_angle >= 360) {
				launch_angle = launch_angle - 360;
			}
			
			//Log.trace(launch_angle);
			
			hurt_ctr++;
			if(hurt_ctr > hurt_ticks) {
				if (dmgtype == 0) {
					//R.player.add_dark(1);
				} else if (dmgtype == 1) {
					//R.player.add_light(1);
				} else {
					
				}
			hurt_ctr = 0;
			}
			
			yscale = xscale = 1;
			
			indicator.x = R.player.x + R.player.width / 2;
			indicator.y = R.player.y + R.player.height / 2;
			indicator.x += FlxX.cos_table[launch_angle] * 24 * xscale;
			indicator.y -= FlxX.sin_table[launch_angle]  * 24 * yscale;
			
			o.y = R.player.y - FlxX.sin_table[launch_angle] * 24 * yscale;
			o.x = R.player.x + FlxX.cos_table[launch_angle] * 24 * xscale;
			if (R.input.jpA1) {
				R.sound_manager.play(SNDC.rlaser_hit);				
				TestState.truly_set_default_cam(parent_state.tm_bg.width, parent_state.tm_bg.height);
				HF.scale_velocity(R.player.velocity, R.player, o, base_launch_vel);
				R.player.velocity.x *= xscale;
				R.player.velocity.y *= yscale;
				hand.velocity.set(R.player.velocity.x / 2, R.player.velocity.y / 2);
				//Log.trace(hand.velocity);
				//Log.trace(R.player.velocity);
				if (R.player.velocity.x > 0) {
					hand.acceleration.x = -100 - hand.velocity.x*6;
				} else {
					hand.acceleration.x = 100 - hand.velocity.x*6;
				}
				if (R.player.velocity.y > 0) {
					hand.acceleration.y = -100 - hand.velocity.y*6;
				} else {
					hand.acceleration.y = 100 - hand.velocity.y*6;
				}
				//Log.trace(hand.acceleration);
				FlxG.camera.followLerp = 30;
				state = 2;
				indicator.visible = false;
			} else {
				var cx:Float = 100 * FlxX.cos_table[launch_angle] + (R.player.x + R.player.width / 2) - 208;
				var cy:Float = -100 * FlxX.sin_table[launch_angle] + (R.player.y + R.player.height / 2) - 128;
				FlxG.camera.followLerp = 15;
				FlxG.camera._scrollTarget.set(cx, cy);
			}
			
		} else if (state == 2) {
			t_recover += FlxG.elapsed;
			hand.acceleration.x *= 1.1;
			hand.acceleration.y *= 1.1;
			if (hand.velocity.x != 0) {
				if (hand.acceleration.x > 0) {
					if (hand.x > x) {
						hand.x = x;
						hand.acceleration.x = 0;
						hand.velocity.x = 0;
					}
				} else if (hand.acceleration.x < 0 ) {
					if (hand.x < x) {
						hand.x = x;
						hand.acceleration.x = 0;
						hand.velocity.x = 0;
					}
				}
			}
			if (hand.velocity.y != 0) {
				if (hand.acceleration.y > 0) {
					if (hand.y > y) {
						hand.y = y;
						hand.acceleration.y = 0;
						hand.velocity.y = 0;
					}
				} else if (hand.acceleration.y < 0 ) {
					if (hand.y < y) {
						hand.y = y;
						hand.acceleration.y = 0;
						hand.velocity.y = 0;
					}
				}
			}
			if (t_recover > 1 || !R.player.overlaps(this)) {
				if (hand.velocity.x == 0 && hand.velocity.y == 0) {
					hand.animation.play("off");
					
					t_recover = 0;
					
					state = 0;
				}
			}
		}
		super.update(elapsed);
	}
	override public function draw():Void 
	{
		if (indicator.visible) {
			var ix:Float = indicator.x;
			var iy:Float = indicator.y;
			
			indicator.acceleration.y = R.player.acceleration.y;
			
			HF.scale_velocity(indicator.velocity, R.player, o, base_launch_vel);
			indicator.velocity.x *= xscale;
			indicator.velocity.y *= yscale;
			indicator.drag.x = 9 * 60;
			for (i in 0...5) {
				for (j in 0...6) {
				indicator.updateMotion(FlxG.elapsed);
				}
				indicator.draw();
			}
			indicator.velocity.set(0, 0);
			indicator.drag.x = 0;
			indicator.x = ix;
			indicator.y = iy;
			
		}
		super.draw();
	}
	private var t_recover:Float = 0;
}