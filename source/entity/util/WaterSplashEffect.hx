package entity.util;


import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import help.AnimImporter;
import openfl.Assets;

/**
 * A group held by the TestState that dispatches water droplets when effected (for things jumping into water)
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class WaterSplashEffect extends FlxTypedGroup<FlxSprite>
{

	private var size:Int;
	private var splash_effect:FlxSprite;
	public function new(size:Int) 
	{
		super();
		stay_alive_times = [];
		this.size = size;
		for (i in 0...this.size) {
			var s:FlxSprite = new FlxSprite();
			if (Math.random() < 0.80) {
				s.makeGraphic(1, 1, 0xffffffff);
			} else {
				s.makeGraphic(2, 2, 0xccffffff);
			}
			s.exists = false;
			add(s);
		}
		splash_effect = new FlxSprite();
		AnimImporter.loadGraphic_from_data_with_id(splash_effect, 16, 16, "SplashEffect");
		splash_effect.animation.play("invisible");
		add(splash_effect);
	}
	
	override public function update(elapsed: Float):Void {
		
		var s:FlxSprite;
		var nr_not_existing:Int = 0;
		for (i in 0...size) {
			s =   members[i];
			if (s.exists) {
				s.alpha -= 0.02;
				stay_alive_times[i] -= FlxG.elapsed;
				if (stay_alive_times[i] < 0) {
					s.exists = false;
				}
				s.preUpdate();
				s.update(elapsed);
				s.postUpdate(elapsed);
				
			} else {
				nr_not_existing ++;
			}
		}
		splash_effect.preUpdate();
		splash_effect.update(elapsed);
		splash_effect.postUpdate(elapsed);
		if (nr_not_existing == size) {
			exists = false;
		}
	}
	
	private var stay_alive_times:Array<Float>;
	
	public function dispatch(number:Int,init_x:Float,init_y:Float,x_spread:Float,y_accel:Float,y_vel_min:Float,y_vel_spread:Float,x_vel_spread:Float,stay_alive_time:Float,stay_alive_time_spread:Float):Void {
		var s:FlxSprite;
		for (i in 0...number) {
			for (j in 0...size) {
				s =  members[j];
				if (s.exists == false) {
					s.exists = true; // Update this one
					exists = true;// Also turn on the sprayer
					s.x = init_x - x_spread + 2 * x_spread * Math.random();
					s.y = init_y;
					s.velocity.x = -x_vel_spread + 2 * x_vel_spread * Math.random();
					s.velocity.y = y_vel_min - y_vel_spread * Math.random();
					stay_alive_times[j] = stay_alive_time + stay_alive_time_spread * Math.random();
					s.acceleration.y = y_accel;
					s.alpha = 1;
					break;
				}
			}
			
		}
		splash_effect.animation.play("splash", true);
		splash_effect.x = init_x - 6;
		splash_effect.y = init_y - 17;
	}
}