package entity.enemy;
/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import entity.MySprite;
import help.HF;
import state.MyState;

class Inverter extends MySprite
{
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "Inverter");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(32, 32, 0xff990095);
			case 1:
			default:
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("only_once", 1);
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
		super.destroy();
	}
	
	
	public var on_player:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		if (on_player) {
			if (!R.player.overlaps(this)) {
				if (props.get("only_once") == 0) {
					on_player = false;
					alpha = 1;
				}
			}
		} else if (!on_player) {
			if (R.player.overlaps(this)) {
				R.player.energy_bar.invert();
				on_player = true;
				alpha = 0.4;
			}
		}
		super.update(elapsed);
	}
}