package entity.npc;
import entity.MySprite;
import flash.geom.Point;
import help.HelpTilemap;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.MyState;

class Fish extends MySprite
{

	private var target:FlxSprite;
	private var behavior:Int;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		last_target = new Point();
		target = new FlxSprite(); target.makeGraphic(4, 4, 0xffff0000);
		super(_x, _y, _parent, "Fish");
	}
	
	private static inline var BEHAVIOR_DRUNK:Int = 0;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				makeGraphic(8, 4, 0xff00ffff);
		}
	}
	override public function preUpdate():Void 
	{
		FlxObject.separate(this, parent_state.tm_bg);
		super.preUpdate();
	}
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("behavior", 0);
		p.set("t_behave", 0.4);
		p.set("vel_range", "20,60");
		return p;
	}
	
	private var vel_range:Point;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		behavior = props.get("behavior");
		change_visuals();
		vel_range = HF.string_to_point_array(props.get("vel_range"))[0];
		vel_range.y = vel_range.y - vel_range.x;
	
		set_next_target();
	}
	
	override public function destroy():Void 
	{
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [target]);
		super.destroy();
	}
	
	private var t_behave:Float = 0;
	private var last_target:Point;
	override public function update(elapsed: Float):Void 
	{
		
		t_behave += FlxG.elapsed;
		if (t_behave > props.get("t_behave")) {
			t_behave -= props.get("t_behave");
			set_next_target();
		}
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [target]);
		}
		var tt:Int = parent_state.tm_bg.getTileID(x,y);
		if (!HF.array_contains(HelpTilemap.active_water, tt)) {
			velocity.y = Math.abs(velocity.y);
		}
		
		if (R.editor.editor_active) {
			target.visible = true;
			if (FlxG.keys.myPressed("SPACE")) {
				velocity.x = velocity.y = 0;
			}
		} else {
			target.visible = false;
		}
		
		super.update(elapsed);
	}
	
	function set_next_target():Void 
	{
		var bump:Float = 1;
		var old_tx:Float = target.x;
		var old_ty:Float = target.y;
		switch (behavior) {
			case BEHAVIOR_DRUNK:
				for (i in 0...5) {
					// When a fish tries to swim out (upwards) of the water we want to push them downwards more
					target.x = x - 10 + 20 * Math.random();
					target.y = y - 10 + 20 * bump * Math.random();
					
					if (i == 4) {
						target.x = old_tx; target.y = old_ty;
					}
					HF.scale_velocity(this.velocity, this, target, vel_range.x + vel_range.y * Math.random());
					
					var tt:Int = parent_state.tm_bg.getTileID(target.x, target.y);
					if (!HF.array_contains(HelpTilemap.active_water, tt)) {
						bump += 0.2; 
						continue;
					}
					break;
				}
		}
		
		
	}
}