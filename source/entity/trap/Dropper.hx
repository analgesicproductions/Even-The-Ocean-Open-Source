package entity.trap;
import entity.MySprite;
import haxe.Log;
import help.AnimImporter;
import help.HelpTilemap;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.MyState;
import flixel.group.FlxGroup;
/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Dropper extends MySprite
{

	
	private var drops:FlxTypedGroup<FlxSprite>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		drops = new FlxTypedGroup<FlxSprite>();
		
		super(_x, _y, _parent, "Dropper");
	}
	
	private static inline var VIS_DARK:Int = 0;
	private static inline var VIS_LIGHT:Int = 1;

	override public function change_visuals():Void 
	{
		switch (vistype) {
			case VIS_DARK:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "0");
			case VIS_LIGHT:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "1");
		}
		animation.play("base_idle", true);
		
		drops.clear();
		for (i in 0...max_drops) {
			var d:FlxSprite = new FlxSprite();
			switch (vistype) {
				case VIS_DARK:
					AnimImporter.loadGraphic_from_data_with_id(d, 16, 16, name, "0");
				case VIS_LIGHT:
					AnimImporter.loadGraphic_from_data_with_id(d, 16, 16, name, "1");
			}
			d.animation.play("invisible");
			drops.add(d);
			d.exists = false;
		}
	}
	
	private var t_drop:Float = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("max_drops", 3);
		p.set("drop_latency", 1.0);
		p.set("vistype", VIS_DARK);
		return p;
	}
	
	private var max_drops:Int = 3;
	private var drop_latency:Float = 1.0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		max_drops = props.get("max_drops");
		drop_latency = props.get("drop_latency");
		vistype = props.get("vistype");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [drops]);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [drops]);
		}
		
		
		if (animation.curAnim != null && animation.curAnim.name == "base_idle") {
			t_drop += FlxG.elapsed;
			if (t_drop > drop_latency) {
				t_drop -= drop_latency;
				animation.play("base_drop");
			}
		} else {
			if (animation.finished) {
				animation.play("base_idle");
				for (i in 0...max_drops) {
					var d:FlxSprite = drops.members[i];
					if (d.exists == false) {
						d.exists = true;
						d.x = x;
						d.y = y;
						d.acceleration.y = 200;
						d.maxVelocity.y = 200;
						d.velocity.y = 0;
						d.animation.play("drop_fall");
						break;
					}
				}
			}
		}
		
		for (i in 0...max_drops) {
			var d:FlxSprite = drops.members[i];
			if (d.animation.curAnim != null) {
				//Log.trace(d.animation.curAnim.name);
			}
			if (d.animation.finished) {
				d.exists = false;
				d.animation.play("invisible");
			}
			if (d.animation.curAnim != null && d.animation.curAnim.name == "drop_explode") {
				d.velocity.y = d.acceleration.y = 0;
			} else if (d.exists) {
				FlxObject.separate(d, parent_state.tm_bg);
				if (HF.array_contains(HelpTilemap.active_surface_water, parent_state.tm_bg.getTileID(d.x + 3, d.y + d.height)) && d.y % 16 > 8) {
					d.touching = FlxObject.DOWN;
				}
				if (d.touching != 0) {
					d.animation.play("drop_explode");
				} else if (R.player.shield_overlaps(d)) {
					//d.animation.play("drop_explode");
					d.exists = false;
					d.animation.play("invisible");
				} else if (d.overlaps(R.player)) {
					//d.animation.play("drop_explode",true);
					d.exists = false;
					d.animation.play("invisible");
					if (vistype == VIS_DARK) {
						R.player.add_dark(32); 
					} else if (vistype == VIS_LIGHT) {
						R.player.add_light(32);
					}
				}
			}
		}
		super.update(elapsed);
	}
}