package entity.player;

import flash.display.BlendMode;
import haxe.Log;
import help.AnimImporter;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class HurtEffectGroup extends FlxGroup
{

	
	/**
	 * The things will release normally.
	 */
	static public var STYLE_NORMAL:Int = 0;
	/**
	 * Nothing will be released.
	 */
	static public var STYLE_NONE:Int = 1;
	// 2 3 4 5 = pod d/l pew d/l
	
	public var energies:FlxGroup;
	public var booms:FlxGroup;
	public var release_object:FlxObject;
	public var timer_array:Array<Float>;
	public function new(release_object:FlxObject) 
	{
		
		super();
		this.release_object = release_object;
		energies = new FlxGroup();
		booms = new FlxGroup();
		add(energies);
		add(booms);
	}
	
	private var did_init:Bool = false;
	override public function update(elapsed: Float):Void {
		super.update(elapsed);
		if (!did_init) {
			did_init = true;
			timer_array = [];
			for (i in 0...30) {
				var energy:FlxSprite = new FlxSprite();
				AnimImporter.loadGraphic_from_data_with_id(energy, 16, 16, "HurtEffectGroup","0");
				energies.add(energy);
				energy.exists = false;
				timer_array.push(0);
			}
			for (i in 0...5) {
				var boom:FlxSprite = new FlxSprite();
				AnimImporter.loadGraphic_from_data_with_id(boom, 64, 64, "HurtEffectGroup","boom");
				booms.add(boom);
				boom.exists = false;
			}
		}
		for (i in 0...booms.length) {
			var boom:FlxSprite = cast booms.members[i];
			if (boom != null && boom.exists) {
				if (boom.animation.finished) {
					boom.exists = false;
				}
			}
		}
		for (i in 0...energies.length) {
			var energy:FlxSprite = cast energies.members[i];
			if (energy != null && energy.exists) {
				timer_array[i] += FlxG.elapsed;
				if (timer_array[i] > 1 || energy.animation.finished) {
					timer_array[i] = 0;
					energy.exists = false;
				}
			}
		}
	}
	
	// centering pt
	public function releaseboom(anim:Int,cx:Float,cy:Float):Void {
		if (!did_init) return;
		var nr_left:Int = 1;
		
		for (i in 0...booms.length) {
			var energy:FlxSprite = cast booms.members[i];
			if (nr_left == 0) break;
			if (energy != null && energy.exists == false) {
				nr_left --;
				energy.exists = true;
				energy.x = cx - energy.width / 2;
				energy.y = cy - energy.height / 2;
				energy.alpha = 1;
				switch (anim) {
					case 2:
						energy.blend = BlendMode.NORMAL;
						energy.animation.play("pod_d", true);
					case 3:
						energy.blend = BlendMode.NORMAL;
						energy.animation.play("pod_l", true);
					case 4:
						energy.blend = BlendMode.SCREEN;
						energy.animation.play("pew_d", true);
					case 5:
						energy.blend = BlendMode.SCREEN;
						energy.animation.play("pew_l", true);
					case 6: // vanish switch
						energy.blend = BlendMode.NORMAL;
						energy.animation.play("podswitch", true);
						
				}
			}
		}
	}
	public function release(nr:Int, light:Bool = false,cx:Float=-1,cy:Float=-1):Void {
		if (!did_init) return;
		var nr_left:Int = nr;
		var mp:FlxPoint = release_object.getMidpoint();
		
		
		for (i in 0...energies.length) {
			var energy:FlxSprite = cast energies.members[i];
			if (nr_left == 0) break;
			if (energy != null && energy.exists == false) {
				nr_left --;
				energy.exists = true;
				if (cx != -1) {
					energy.move(cx, cy);
				} else{
					energy.x = mp.x - 9 + 18 * Math.random() - 8;
					energy.y = mp.y - 12 + 24 * Math.random() - energy.height - 1;
				}
				energy.acceleration.y = -50 - 50 * Math.random();
				energy.velocity.y = 0;
				energy.alpha = 1;
				
				var r:String = Std.string(Std.int(5 * Math.random()));
				if (light) {
					energy.animation.play("l"+r);
				} else  {
					energy.animation.play("d"+r);
				}
			}
		}
	}
}