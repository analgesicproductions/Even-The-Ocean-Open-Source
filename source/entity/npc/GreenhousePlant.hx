package entity.npc;
import entity.MySprite;
import help.HF;
import openfl.Assets;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class GreenhousePlant extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "GreenhousePlant");
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("id", -1);
		return p;
	}
	
	private var is_planted:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		
		
		animation.paused = true;
		if (props.get("id") != -1 && R.inventory.is_planted(props.get("id"))) {
			var d:Map < String, Dynamic > = R.inventory.get_plant_data(props.get("id"));
			if (d != null) {
				myLoadGraphic(Assets.getBitmapData("assets/" + d.get("path")), true, false, d.get("w"), d.get("h"));
				animation.add("a", d.get("anim"), d.get("fr"), true);
				animation.play("a", true);
				is_planted = true;
			} else {
				makeGraphic(16, 16, 0xff00ff00);
			}
		} else {
			makeGraphic(16, 16, 0xff00ff00);
		}
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	
	override public function update(elapsed: Float):Void 
	{
		if (is_planted) {
			visible = true;
			
			if (R.input.jpCONFIRM && !R.input.any_dir_down() && this.overlaps(R.player) && parent_state.dialogue_box.is_active() == false) {
				parent_state.dialogue_box.start_dialogue("ui", "items", props.get("id"));
				
			}
			if (this.overlaps(R.player)) {
				R.player.cant_lock_neutral = true;
			}
		} else {
			if (R.editor.editor_active) {
				visible = true;
			} else {
				visible = false;
			}
		}
		// If overlappign and you player talks, show description
		super.update(elapsed);
	}
}