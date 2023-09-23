package entity.trap;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

import autom.SNDC;
import entity.MySprite;
import help.HF;
import state.MyState;
import help.AnimImporter;
import flixel.FlxG;
import flash.display.BlendMode;
import flixel.FlxSprite;

class FlameOn extends MySprite
{

	private var wind:FlxSprite;
	private var windbox:FlxSprite;
	private var vel:Float = 0;
	private var init_dmg:Int;
	private var t_dmg:Float = 0;
	private var tm_dmg:Float = 0;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		wind = new FlxSprite();
		windbox = new FlxSprite();
		super(_x, _y, _parent, "FlameOn");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(32, 16, 0xffff00ff);
			case 1:
				makeGraphic(32, 16, 0xffffffff);
			default:
				makeGraphic(32, 16, 0xffffffff);
		}
		
		width = 32 - 10;
		height = 16 - 3;
		offset.set(5,3);
		
		AnimImporter.loadGraphic_from_data_with_id(wind, 16, 16, "Wind");
		wind.animation.play("u");
		//wind.animation.curAnim.frameRate = Std.int(Math.min(30, vel / 11));
		wind.blend = BlendMode.ADD; 
		windbox.makeGraphic(32, 32, 0xff123123);
		
			wind.exists = true;
		// Change visuals
		
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("tm_dmg", 0.018);
		p.set("dmg", 36);
		p.set("vel", 100);
		return p;
	}
	
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		init_dmg = props.get("dmg");
		tm_dmg = props.get("tm_dmg");
		vel = props.get("vel");
		t_dmg = 0;
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		//HF.remove_list_from_mysprite_layer(this, parent_state, []);
		super.destroy();
	}
	
	private var mode:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		
		x += offset.x;
		y += offset.y;
		
		wind.x = x;
		wind.y = y - 32;
		windbox.move(wind.x, wind.y);
		//if (!did_init) {
			//did_init = true;
			//HF.add_list_to_mysprite_layer(this, parent_state, []);
		//}
		if (R.player.overlaps(windbox)) {
			R.player.apply_wind(0, -vel);
			Wind.last_y = y;
		}
		wind.update(elapsed);
		
		if (mode == 0) {
			if (R.player.overlaps(this)) {
				mode = 1;
				R.sound_manager.play(SNDC.splash);
				R.player.skip_motion_ticks = 12;
				if (dmgtype == 0) {
					R.player.add_dark(init_dmg);
				} else {
					R.player.add_light(init_dmg);
				}
			} 
		} else if (mode == 1) {
			if (R.player.overlaps(this)) {
				t_dmg += FlxG.elapsed;
				if (t_dmg > tm_dmg) {
					t_dmg -= tm_dmg;
					if (dmgtype == 0) {
						R.player.add_dark(1);
					} else {
						R.player.add_light(1);
					}
				}
			} else {
				mode = 0;
			}
		}
		super.update(elapsed);
		
		x -= offset.x;
		y -= offset.y;
		
		
	}
	override public function draw():Void 
	{
		
		
		x += offset.x;
		y += offset.y;
		
		super.draw();
		
		x -= offset.x;
		y -= offset.y;
		
		for (i in 0...2) {
			for (j in 0...2) {
				wind.x = x + 16 * j;
				wind.y = (y -32) + 16 * i;
				wind.draw();
			}
		}
	}
}