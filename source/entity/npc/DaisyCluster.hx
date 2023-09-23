package entity.npc;
import entity.MySprite;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.group.FlxGroup;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class DaisyCluster extends MySprite
{

	private var daisies:Array<MySprite>;
	private var groupthing:FlxGroup;
	private var nr_daisies:Int;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		groupthing = new FlxGroup();	
		daisies = [];
		super(_x, _y, _parent, "DaisyCluster");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "normal");
				animation.play("idle");
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("nr_daisies", 1);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		nr_daisies = props.get("nr_daisies");
		change_visuals();
		if (daisies != []) {
			HF.remove_list_from_mysprite_layer(this, parent_state, [groupthing]);
			did_init = false;
		}
		daisies = [];
		for (i in 0...nr_daisies) {
			var daisy:MySprite = new MySprite(x + 16 + 16 * i, y, parent_state, "Daisy");
			AnimImporter.loadGraphic_from_data_with_id(daisy, 16, 16, name, "normal");
			daisy.animation.play("idle");
			daisies.push(daisy);
			groupthing.add(daisy);
		}
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [groupthing]);
		super.destroy();
	}
	
	private var distance:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, daisies);
		}
		
		if (distance == 0) {
			animation.play("bloom");
		}
		distance ++;
		for (i in 0...nr_daisies) {
			if (FlxX.l1_norm_from_mid(this, daisies[i]) < distance && daisies[i].animation.curAnim != null && daisies[i].animation.curAnim.name != "bloom") {
				daisies[i].animation.play("bloom");
			}
		}
		if (distance > 120) {
			distance = 0;
			for (i in 0...nr_daisies) {
				if (daisies[i].animation.finished) {
					daisies[i].animation.play("idle");
				}
			}
		}
		super.update(elapsed);
	}
}