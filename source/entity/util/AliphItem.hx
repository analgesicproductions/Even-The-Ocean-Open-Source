package entity.util;
import autom.SNDC;
import entity.MySprite;
import entity.ui.Inventory;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class AliphItem extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "AliphItem");
		sparkles = new FlxTypedGroup<FlxSprite>();
		for (i in 0...7) {
			var sparkle:FlxSprite = new FlxSprite(0, 0);
			sparkle.makeGraphic(1, 1, 0xffffffff);
			sparkle.exists = false;
			sparkles.add(sparkle);
		}
		
	}
	
	private var inv_type:Int = 0;
	private var found:Bool = false;
	private var does_float:Bool = true;
	private var sparkles:FlxTypedGroup<FlxSprite>;
	override public function change_visuals():Void 
	{
		animation.paused = true;
		if (R.PAX_PRIME_DEMO_ON) {
			if (props.get("id") == 0) {
				myLoadGraphic(Assets.getBitmapData("assets/sprites/util/DemoItems.png"), true, false, 16, 16);
				animation.add("spin", [8,9,10,11], 8);
				animation.frameIndex = 8;
			} else if (props.get("id") == 1) {
				myLoadGraphic(Assets.getBitmapData("assets/sprites/util/DemoItems.png"), true, false, 16, 16);
				animation.add("spin", [4,5,6,7], 8);
				animation.frameIndex = 4;
			} else {
				myLoadGraphic(Assets.getBitmapData("assets/sprites/util/DemoItems.png"), true, false, 16, 16);
				animation.add("spin", [0, 1, 2, 3], 8);
				animation.frameIndex = 0;
			}
			width = height = 8;
			offset.x = offset.y = 4;
		} else {
			var d:Map < String, Dynamic > = R.inventory.get_item_data(props.get("id"));
			if (d != null) {
				myLoadGraphic(Assets.getBitmapData("assets/" + d.get("item_path")), true, false, d.get("item_w"), d.get("item_h"));
				animation.add("spin", d.get("item_anim"), d.get("item_fr"), true);
				animation.play("spin", true);
				
				if (d.exists("floats") && d.get("floats") == 0) {
					does_float = false;
				}
			} else {
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "ItemSeeds", Std.string(props.get("vis_set")));
				animprefix = "";
				switch (R.inventory.get_item_type(props.get("id"))) {
					case "plant":
						animation.play("plant_idle"); animprefix = "plant_";
					case "trivia":
						animation.play("trivia_idle"); animprefix = "trivia_";
					case "even":
						animation.play("even_idle"); animprefix = "even_";
					case "secret":
						animation.play("secret_idle"); animprefix = "secret_";
					default:
						makeGraphic(12, 12, 0xffbbbb00);
				}
			}
		}
	}
	
	private var animprefix:String = "";
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("id", -1);
		p.set("vis_set", 0);
		p.set("removes", 0);
		// Set default properties here
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		change_visuals();
		if (R.inventory.is_item_found(props.get("id"))) {
			found = true;
			alpha = 0;
		} else {
			found = false;
		}
		
		if (props.get("removes") == 1) {
			found = false;
			alpha = 1;
			flicker( -1);
		}
		// Do stuff
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	private var t_float:Float = 0;
	private var t_emit:Float = 0;
	override public function update(elapsed: Float):Void 
	{
		
		if (!did_init) {
			did_init = true;
			// Need to make this splice functionality later
			HF.remove_list_from_mysprite_layer(this, parent_state, [this]);
			HF.add_list_to_mysprite_layer(this, parent_state, [sparkles, this]);
		}
		if (false == found) {
			if (R.player.exists && R.player.overlaps(this)) {
				if (props.get("removes") == 1) {
					R.inventory.set_item_found(1, props.get("id"), false);
				} else {
					found = true;
					//animation.play(animprefix+"spin");
					R.sound_manager.play(SNDC.pew_hit_shield);
					acceleration.y = -100;
					R.inventory.set_item_found(1, props.get("id"));
				}
			}
		} else {
			if (R.editor.editor_active) {
				alpha = 1;
			} else {
				alpha -= 0.01;
			}
			for (i in 0...sparkles.length) {
				var s:FlxSprite = sparkles.members[i];
				if (s.exists) {
					s.alpha -= 0.015;
					if (s.alpha == 0) {
						s.exists = false;
					}
				}
			}
			if (animation.curAnim != null && animation.curAnim.name == animprefix+"spin" && alpha != 0) {
				t_emit += FlxG.elapsed;
				if (t_emit > 0.15) {
					t_emit -= 0.15;
					for (i in 0...sparkles.length) {
						var s:FlxSprite = sparkles.members[i];
						if (s.exists == false) {
							s.alpha = 1;
							s.y = y + width / 2;
							s.x = (x - 2) + (width + 4) * Math.random();
							s.velocity.y = 35;
							s.acceleration.y = 150;
							s.exists = true;
							break;
						}
					}
				}
			}
		}
		super.update(elapsed);
	}
	override public function draw():Void 
	{
			var aiy:Float = y;
		if (does_float) {
			t_float += FlxG.elapsed;
			if (t_float > 1.2) t_float = 0;
			var idx:Int = Std.int((t_float / 1.2) * 360);
			y = aiy + FlxX.sin_table[idx] * 4;
		}
		super.draw();
		if (does_float) {
			y = aiy;
		}
	}
}