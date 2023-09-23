package entity.util;

import entity.MySprite;
import global.C;
import help.HF;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Stopper extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "Stopper");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				makeGraphic(16, 16, 0xffff2233);
		}
		// Change visuals
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		// Set default properties here
		p.set("children", "");
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		change_visuals();
		// Do stuff
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	private var mode:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			populate_parent_child_from_props();
		}
		if (mode == 0) {
			for (sink in SinkPlatform.ACTIVE_SinkPlatforms) {
				if (sink.overlaps(this)) {
					if (sink.my_recv_message(C.MSGTYPE_STOP, x, y,height) == C.RECV_STATUS_OK) {
						mode = 1;
						broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
					}
				}
			}
		} else if (mode == 1) {
			
		}
		super.update(elapsed);
	}
	
}