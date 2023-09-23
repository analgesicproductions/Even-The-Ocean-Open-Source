package entity.ui;
import global.C;
import haxe.Log;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import openfl.display.BlendMode;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class BlendTest extends FlxGroup
{
	public var black_layer:FlxSprite;
	public var light:FlxSprite;
	public function new() 
	{
		super();
		black_layer = new FlxSprite(0, 0);
		black_layer.scrollFactor.set(0, 0);
		//black_layer.makeGraphic(C.GAME_WIDTH, C.GAME_HEIGHT, 0xff000000 	);
		black_layer.myLoadGraphic(Assets.getBitmapData("assets/sprites/test/blend_Bg.png"), false, false, 230, 229);
		
		//black_layer.blend = BlendMode.SCREEN;
		
		light = new FlxSprite(0, 0);
		light.scrollFactor.set(0, 0);
		light.myLoadGraphic(Assets.getBitmapData("assets/sprites/test/blend_fg.png"), false, false, 230, 229);
		light.blend = BlendMode.OVERLAY;
		//light.makeGraphic(5, 5, 0xffffffff);
		light.visible = true;
		//add(black_layer);
		add(light);
		
		blend_modes = [BlendMode.OVERLAY, BlendMode.MULTIPLY, BlendMode.ADD];
		blend_idx = 0;
	}
	public var blend_idx = 0;
	public var blend_idxs = 0;
	public var blend_modes:Array<BlendMode>;
	
	public var t:Float = 0;
	override public function update(elapsed: Float):Void {
		
		if (light.velocity.x <= 0) {
			if (light.x < 0) {
				//light.velocity.x = 40;
			}
		} else {
			if (light.x + light.width > C.GAME_WIDTH) {
				light.velocity.x = -40;
			}
		}
		
		if (FlxG.keys.myJustPressed("TAB")) {
			blend_idx = (blend_idx + 1) % blend_modes.length;
			light.blend = blend_modes[blend_idx];
			//blac	k_layer.blend = blend_modes[blend_idx];
			Log.trace("New blend mode for fg: " + light.blend);
		}
		if (FlxG.keys.myJustPressed("A")) {
			
			blend_idxs = (blend_idxs + 1) % blend_modes.length;
			black_layer.blend = blend_modes[blend_idxs];
			Log.trace("New blend mode for bg: " + black_layer.blend);
		}
		if (FlxG.keys.myJustPressed("UP")) {
			 black_layer.alpha += 0.1;
			 Log.trace("black layer alpha: " +Std.string(black_layer.alpha));
		}else if (FlxG.keys.myJustPressed("DOWN")) {
			black_layer.alpha -= 0.1;
			 Log.trace("black layer alpha: " +Std.string(black_layer.alpha));
		}
		
		light.alpha = Math.sin((t / 3.0) * 3.14);
		t += FlxG.elapsed;
		if (t > 3.0) t = 0;
		//black_layer.fill(0xaa000000);
		//black_layer.stamp(light, Std.int(light.x),Std.int(light.y));
		super.update(elapsed);
	}
	
	
	
}