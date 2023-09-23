package entity.trap;
import autom.SNDC;
import entity.MySprite;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxSprite;
import state.MyState;
import flixel.group.FlxGroup;
/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Weed extends MySprite
{

	public static var ACTIVE_Weeds:List<Weed>;
	var front_sprite:FlxSprite;
	var effect_timer:Int = 4;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		
		if (ACTIVE_Weeds == null) ACTIVE_Weeds = new List<Weed>();
		front_sprite = new FlxSprite(0, 0);
		super(_x, _y, _parent, "Weed");
	}
	
	private var prefix:String = "_u";
	override public function change_visuals():Void 
	{
		AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, Std.string(vistype));
		AnimImporter.loadGraphic_from_data_with_id(front_sprite, 16, 16, name, Std.string(vistype));
		
		switch (props.get("dir")) {
			case 0:
				prefix = "_u";
			case 1:
				prefix = "_r";
			case 2:
				prefix = "_d";
			case 3:
				prefix = "_l";
		}
		
		animation.play("idle_back"+prefix,true);
		front_sprite.animation.play("idle_front"+prefix,true);
		front_sprite.width = width = 12;
		front_sprite.height = height = 14;
		front_sprite.offset.y = offset.y = 2;
		front_sprite.offset.x = offset.x = 2;	
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", 0);
		p.set("dir", 0);// urdl
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		vistype = props.get("vistype");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		parent_state.fg2_sprites.remove(front_sprite, true);
		front_sprite.destroy();
		ACTIVE_Weeds.remove(this);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		front_sprite.x = x = ix + offset.x;
		front_sprite.y = y = iy + offset.y;
		if (!did_init) {
			ACTIVE_Weeds.add(this);
			did_init = true;
			parent_state.fg2_sprites.add(front_sprite);
		}
		
		if (R.player.overlaps(this)) {
			if (R.player.velocity.x != 0) {
				front_sprite.animation.play("move_front"+prefix);
				R.sound_manager.play(SNDC.touch_weed);
			} else {
				front_sprite.animation.paused = true;
			}
			if (vistype == 0) { // Light
				R.player.RESET_status_gassed+=2;
				R.player.in_gas_tile = true;
			} else if (vistype == 1) { // Dark
				R.player.RESET_status_gassed-=2;
				R.player.in_gas_tile = true;
			}
		} else { 
			front_sprite.animation.play("idle_front"+prefix);
		}
		front_sprite.x = x;
		front_sprite.y = y;
		
		super.update(elapsed);
	}
	
	public function circle_overlap(cx:Float, cy:Float, cr:Float, dmgtype:Int):Bool {
		if (FlxX.circle_flx_obj_overlap(cx, cy, cr, front_sprite)) {
			if (dmgtype == 0 && vistype == 1) {
				return true;
			} else if (dmgtype == 1 && vistype == 0) {
				return true;
			}
		}
		return false;
	}
	
}