package entity.npc;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import entity.MySprite;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import flixel.FlxSprite;
import state.MyState;

class MoleTile extends MySprite
{

	public static var ACTIVE_MoleTiles:List<MoleTile>;
	public var outline:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		outline = new FlxSprite();
		super(_x, _y, _parent, "MoleTile");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "MoleTile", "default");
				AnimImporter.loadGraphic_from_data_with_id(outline, 16, 16, "MoleTile", "default");
		}
		
		outline.exists = true;
		if (light_only) {
			outline.animation.play("light_border");
		} else if (dark_only) {
			outline.animation.play("dark_border");
		} else {
			outline.exists = false;
		}
	}
	
	public var dir:Int = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("dir", 0);
		p.set("off", 0);
		p.set("behavior", -1); //0  =dark 1 = light only
		return p;
	}
	
	public var light_only:Bool = false;
	public var dark_only:Bool = false;
	public var is_off:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dir = props.get("dir");
		is_off = props.get("off") == 1;
		light_only = dark_only = false;
		if (props.get("behavior") == 0) {
			dark_only = true;
		} else if (props.get("behavior") == 1) {
			light_only = true;
		}
		change_visuals();
		play_anim();
		
	}
	
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == C.MSGTYPE_ENERGIZE) {
			is_off = false;
			props.set("off", 0);
			play_anim();
		} else if (message_type == C.MSGTYPE_DEENERGIZE) {
			is_off = true;
			props.set("off", 1);
			play_anim();
		}
		return C.RECV_STATUS_OK;
	}
	
	override public function destroy():Void 
	{
		
		ACTIVE_MoleTiles.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [outline]);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		if (R.editor.editor_active) {
			visible = true;
		} else {
			visible = false;
		}
		outline.x = x;
		outline.y = y;
			if (!did_init) {
				did_init = true;
				HF.add_list_to_mysprite_layer(this, parent_state, [outline]);
				ACTIVE_MoleTiles.add(this);
			}
		super.update(elapsed);
	}
	
	private function play_anim():Void 
	{
		var s:String = is_off ? "_off" : "";
	
		if (dir == 0) {
			animation.play("ur"+s);
		} else if (dir == 1) {
			animation.play("dr"+s);
		} else if (dir == 2) {
			animation.play("dl"+s);
		} else if (dir == 3) {
			animation.play("ul"+s);
		}
	}
}