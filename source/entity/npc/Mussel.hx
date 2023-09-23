package entity.npc;
import entity.MySprite;
import help.HF;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Mussel extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "Mussel");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
		}
		// Change visuals
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		// Set default properties here
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
		
		//HF.remove_list_from_mysprite_layer(this, parent_state, []);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		//if (!did_init) {
			//did_init = true;
			//HF.add_list_to_mysprite_layer(this, parent_state, []);
		//}
		super.update(elapsed);
	}
	
	// Sleep?
	// Wakeup?
	// Broadcast to children?
	// Receive Messages?
	
}