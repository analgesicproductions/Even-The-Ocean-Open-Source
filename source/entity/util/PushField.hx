package entity.util;
import entity.MySprite;
import help.HF;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class PushField extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "PushField");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				makeGraphic(props.get("w"),props.get("h"), 0xff123ff0);
		}
	}
	
	private var hor_push:Int = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("hor_push", 40);
		p.set("w", 64);
		p.set("h", 64);
		return p;
	}
	
	
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == "energize_tick_l") {
			ID = 20;
			return 1;
		}
		return 1;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		hor_push = props.get("hor_push");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		
		if (R.editor.editor_active) {
			visible = true;
		} else {
			visible = false;
		}
		
		if (R.player.overlaps(this) && ID != 20) {
			//R.player.velocity.x = 0;
			R.player.do_hor_push(hor_push, false,false,2,true);
		}
		super.update(elapsed);
	}
}