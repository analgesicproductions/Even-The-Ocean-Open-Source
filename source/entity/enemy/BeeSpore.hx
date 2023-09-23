package entity.enemy;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
	
import entity.MySprite;
import help.HF;
import state.MyState;

class BeeSpore extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "BeeSpore");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
			case 1:
			default:
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);

		change_visuals();
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
}