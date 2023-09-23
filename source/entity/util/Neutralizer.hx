package entity.util;
import autom.SNDC;
import entity.MySprite;
import entity.player.BubbleSpawner;
import flixel.FlxSprite;
import help.AnimImporter;
import help.HF;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Neutralizer extends MySprite
{

	private var swirl:FlxSprite;
	private var the_frame:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		swirl = new FlxSprite();
		the_frame = new FlxSprite();
		super(_x, _y, _parent, "Neutralizer");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "default");
				AnimImporter.loadGraphic_from_data_with_id(swirl, 32, 32, name, "default");
				AnimImporter.loadGraphic_from_data_with_id(the_frame, 32, 32, name, "default");
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, Std.string(vistype));
				AnimImporter.loadGraphic_from_data_with_id(swirl, 32, 32, name, Std.string(vistype));
				AnimImporter.loadGraphic_from_data_with_id(the_frame, 32, 32, name, Std.string(vistype));
		}
		the_frame.animation.play("frame");
		swirl.animation.play("swirl");
		animation.play("bg_off");
		alpha = 0.6;
		
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		change_visuals();
	}
	
	override public function destroy():Void 
	{
			HF.remove_list_from_mysprite_layer(this, parent_state, [the_frame, swirl]);
		super.destroy();
	}
	
	private var mode:Int = 0;
	
	override public function update(elapsed: Float):Void 
	{
		
		the_frame.x = swirl.x = x;
		the_frame.y = swirl.y = y;
		
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [the_frame, swirl]);
		}
		if (mode == 0) {
			if (R.player.overlaps(this)) {
				mode = 1;
				animation.play("bg_flash",true);
				R.player.energy_bar.balance_energy();
				BubbleSpawner.force_pop();
				R.sound_manager.play(SNDC.checkpoint);
			 }
		} else if (mode == 1) {
			if (R.player.overlaps(this) == false) {
				mode = 0;
			}
		
		}
		super.update(elapsed);
	}
}