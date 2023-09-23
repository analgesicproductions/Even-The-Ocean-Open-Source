package entity.enemy;

import autom.SNDC;
import entity.MySprite;
import help.HF;
import state.MyState;
import global.C;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class ShoreSpore extends MySprite
{

	// how to balance a spore 
	// spore came on somehwat attaching
	
	private var sprite_cover:FlxSprite;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		sprite_cover = new FlxSprite();
		super(_x, _y, _parent, "ShoreSpore");
		immovable = true;
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				makeGraphic(16, 16, 0xff33cc33);
				sprite_cover.makeGraphic(16, 16, 0xaaff00ff);
		}
	}
	
	private var VIS_DARK:Int = 0;
	private var VIS_LIGHT:Int = 1;
	private var energy:Int = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", 0);
		p.set("energy", 64);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		vistype = props.get("vistype");
		
		energy = props.get("energy");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [sprite_cover]);
		super.destroy();
	}
	
	private var mode:Int = 0;
	private var wall_mode:Int = 0;
	
	override public function update(elapsed: Float):Void 
	{
		
		sprite_cover.x = x;
		sprite_cover.y = y;
		FlxObject.separate(this, R.player);
		
		if (wall_mode == 0) {
			if (touching & FlxObject.LEFT != 0) {
				R.player.activate_wall_hang();
				wall_mode = 1;
			} else if (touching & FlxObject.RIGHT != 0) {
				R.player.activate_wall_hang();
				wall_mode = 1;
			}
		} else {
			R.player.activate_wall_hang();
			touching = FlxObject.ANY;
			if (R.player.is_wall_hang_points_in_object(this) == false) {
				wall_mode = 0;
			}
		}
		
		if (!did_init) {
			populate_parent_child_from_props();
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [sprite_cover]);
		}
		
		if (mode == 1) {
			
		} else if (mode == 0) {
			if (touching != 0) {
				if (vistype == VIS_DARK) {
					R.player.add_dark(1);
				} else if (vistype == VIS_LIGHT) {
					R.player.add_light(1);
				}
				energy--;
				sprite_cover.alpha = (energy * 1.0) / props.get("energy");
				if (energy == 0) {
					mode = 1;
					broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
					R.sound_manager.play(SNDC.lock_shield);
					flicker(0.25);
				}
			}
		}
		
		
		
		super.update(elapsed);
	}
	
	
	
}