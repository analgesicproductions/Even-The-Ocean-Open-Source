package entity.trap;
import entity.MySprite;
import state.MyState;
/**
 * 
 * @author Melos Han-Tani
 */

class EnergyGate  extends MySprite
{
	
	private var does_regenerate:Bool = false;
	private var energy_cost:Int = 100;
	
	private var VISTYPE_DARK_DEBUG:Int = 0;
	private var VISTYPE_LIGHT_DEBUG:Int = 1;
	private var VISTYPE_DARKSTRONG_DEBUG:Int = 2;
	private var VISTYPE_LIGHTSTRONG_DEBUG:Int = 3;
	
	private var DMG_TYPE_100:Int = 96;
	private var DMG_TYPE_200:Int = 192;
	
	private var MODE_ACTIVE:Int = 0;
	private var MODE_INACTIVE:Int = 1;
	
	
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "EnergyGate");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case _ if (VISTYPE_DARK_DEBUG == vistype):
				makeGraphic(8, 32, 0xff000000);
				energy_cost = DMG_TYPE_100; 	
			case _ if (VISTYPE_LIGHT_DEBUG == vistype):
				makeGraphic(8, 32, 0xffffffff);
				energy_cost = DMG_TYPE_100;
			case _ if (VISTYPE_DARKSTRONG_DEBUG == vistype):
				makeGraphic(16, 32, 0xff000000);
				energy_cost = DMG_TYPE_200;
			case _ if (VISTYPE_LIGHTSTRONG_DEBUG == vistype):
				makeGraphic(16, 32, 0xffffffff);
				energy_cost = DMG_TYPE_200;
				
		}
		flicker( -1);
		
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		//p.set("cost", DMG_TYPE_100);
		p.set("vistype", VISTYPE_DARK_DEBUG);
		return p;
		
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		vistype = props.get("vistype");
		change_visuals();
		//energy_cost = props.get("cost");
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	override public function update(elapsed: Float):Void 
	{
		
		if (MODE_ACTIVE == state) {
			if (R.player.overlaps(this)) {
				angularVelocity = 200;
				velocity.x = 300;
				velocity.y = -100;
				
				if (vistype == VISTYPE_DARK_DEBUG || vistype == VISTYPE_DARKSTRONG_DEBUG) {
					R.player.add_dark(energy_cost);
				} else if (vistype == VISTYPE_LIGHT_DEBUG || vistype == VISTYPE_LIGHTSTRONG_DEBUG) {
					R.player.add_light(energy_cost);
				}
				
				state = MODE_INACTIVE;
			}
		} else if (MODE_INACTIVE == state) {
			alpha -= 0.01;
			if (alpha == 0) {
				exists = false;
			}
		}
		super.update(elapsed);
		
		
	}
}