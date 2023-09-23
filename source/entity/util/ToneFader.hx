package entity.util;
import entity.MySprite;
import haxe.Log;
import help.HF;
import openfl.Assets;
import openfl.display.BitmapData;
import state.MyState;
import help.AnimImporter;
import flixel.FlxG;
import flixel.FlxSprite;

import openfl.display.BlendMode;
class ToneFader extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		sprite = new FlxSprite();
		super(_x, _y, _parent, "ToneFader");
	}
	
	override public function change_visuals():Void 
	{
		var bm:BitmapData = Assets.getBitmapData("assets/sprites/bg/map/fade/" + props.get("id").toLowerCase() + ".png");
		if (bm == null) {
			
			sprite.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/map/fade/test.png"), true, false,256,192);
		} else {
			//Log.trace(2);
			sprite.myLoadGraphic(bm, true, false,256,192);
		}
		sprite.alpha = 0;
		sprite.scrollFactor.set(0, 0);
		sprite.move(80, 32);
		makeGraphic(16, 16, 0xfff73562);
		
		switch (props.get("blend")) {
			case 0:
				sprite.blend = BlendMode.NORMAL;
			case 1:
				sprite.blend = BlendMode.ADD;
			case 2:
				sprite.blend = BlendMode.MULTIPLY;
			case 3:
				sprite.blend = BlendMode.SCREEN;
				
		}
		
		if (props.get("custom_color") != "OXRRGGBB") {
			var cc:Int = Std.parseInt(props.get("custom_color"));
			sprite.makeGraphic(Std.int(sprite.width), Std.int(sprite.height), 0xffffffff);
			target_color = cc;
		}
		
			//target_color = 0x00148c;
	}
	
	private var sprite:FlxSprite;
	private var inner_r2:Float;
	private var outer_r2:Float;
	private var target_color:Int = 0;
	private var mul_base_alpha:Float = 0;
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("id", "test");
		p.set("inner_r", 64);
		p.set("outer_r", 128);
		p.set("blend", 0);
		p.set("mul_base_alpha", 0.56);
		p.set("custom_color", "OXRRGGBB");
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		change_visuals();
		inner_r2 = Math.pow(props.get("inner_r"), 2);
		outer_r2 = Math.pow(props.get("outer_r"), 2);
		mul_base_alpha = props.get("mul_base_alpha");
		
	}
	
	override public function destroy():Void 
	{
		sprite.destroy();
		HF.remove_list_from_mysprite_layer(this, parent_state, [sprite]);
		super.destroy();
	}
	
	private var waitTicks:Int = 1; // to 'beat' wmscale sprite
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			if (waitTicks > 0) {
				waitTicks--;
				return;
			}
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [sprite]);
		}
		if (R.editor.editor_active) {
			//visible = true;
			
		} else {
			//visible = false;
		}
		
		var cx:Int = Std.int(x + width / 2);
		var cy:Int  = Std.int(y + width / 2);
		var px:Int = Std.int(R.activePlayer.x + R.activePlayer.width / 2);
		var py:Int = Std.int(R.activePlayer.y + R.activePlayer.height / 2);
		
		var d:Float = Math.pow(cx - px, 2) + Math.pow(cy - py, 2);
		var ff:Float = 0;
		sprite.alpha = 1;
		if (d < outer_r2 && sprite.blend != BlendMode.MULTIPLY)  {
			if (d > inner_r2) {
				sprite.alpha = 1 - ((d - inner_r2) / (outer_r2 - inner_r2));
			} else {
				sprite.alpha = 1;
			}
		} else if (d < outer_r2) {
			if (d > inner_r2) {
				ff = 1 - ((d - inner_r2) / (outer_r2 - inner_r2));
			} else {
				ff = 1;
			}
			ff *= mul_base_alpha;
		} else {
			sprite.alpha = 0;
			ff = 0;
		}
		
		
		
		
		if (FlxG.keys.pressed.SHIFT) {
			//dshift = true;
			//Log.trace("hi");
		} else {
			dshift = false;
		}
		
		if (sprite.blend == BlendMode.MULTIPLY) {
			// scale from 0xff to target's channel, based n alpha.
			// alpha = 0, you would get 0xff. alpha = 1, you would get the target.
			//var nextRed:Int = (0xff - Std.int(sprite.alpha * (0xff - ((target_color & 0x00ff0000) >> 16)))) << 16;
			//var nextGreen:Int = (0xff - Std.int(sprite.alpha * (0xff - ((target_color & 0x00ff00) >> 8)))) << 8;
			//var nextBlue:Int = (0xff - Std.int(sprite.alpha * (0xff - ((target_color & 0x00ff)))));
			var nextRed:Int = (0xff - Std.int(ff * (0xff - ((target_color & 0x00ff0000) >> 16)))) << 16;
			var nextGreen:Int = (0xff - Std.int(ff * (0xff - ((target_color & 0x00ff00) >> 8)))) << 8;
			var nextBlue:Int = (0xff - Std.int(ff  * (0xff - ((target_color & 0x00ff)))));
			//Log.trace([nextRed >> 16, nextGreen >> 8, nextBlue]);
			sprite.color = nextRed + nextGreen + nextBlue;
		}
		
		super.update(elapsed);
	}
	
	private var dshift:Bool = false;
	override public function draw():Void 
	{
		
		if (R.editor.editor_active) {
			super.draw();
		}
		
		//Log.trace(dshift);
		if (R.editor.editor_active || dshift) {
			FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff5533, 0.8);
			FlxG.camera.debugLayer.graphics.drawCircle(x + width/2- FlxG.camera.scroll.x, y + height/2- FlxG.camera.scroll.y,Math.sqrt(inner_r2));
			FlxG.camera.debugLayer.graphics.drawCircle(x + width / 2 - FlxG.camera.scroll.x, y + height / 2 - FlxG.camera.scroll.y, Math.sqrt(outer_r2));
		}
	}
}