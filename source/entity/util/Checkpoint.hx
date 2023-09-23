package entity.util;
import autom.SNDC;
import entity.MySprite;
import help.AnimImporter;
import help.HF;
import help.JankSave;
import flixel.FlxG;
import state.MyState;

class Checkpoint extends MySprite
{
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "Checkpoint");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 32, name);
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 32, name, Std.string(vistype));
		}
		
		if (ix == tempx && iy == tempy && R.TEST_STATE.MAP_NAME == tempmap) {
			animation.play("on");
			on = true;
		} else {
			animation.play("idle");
		}
		
		
		//if (R. gauntlet _manager.active_gauntlet_id == gid && R. gauntlet_ manager.active_leg_id == lid) {
			//animation.play("on");
			//on = true;
		//}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", 0);
		p.set("gauntlet_id", -1); // Which gauntlet is this in
		p.set("leg_id", -1); // What leg of the gauntlet does this begin
		return p;
	}
	
	private var is_valid:Bool = false;
	private var is_final:Bool = false;
	private var gid:String = "0";
	private var lid:Int = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		gid = Std.string(props.get("gauntlet_id"));
		lid = props.get("leg_id");
		//if (R.gauntl et_manager.is_valid_gauntlet(gid,lid)) {
			//is_valid = true;
			//if (R.gaunt let_manager.is_end_of_leg(gid, lid)) {
				//is_final = true;
			//}
		//}
		// Check if this is the final , change visuals appropriately
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		//HF.remove_list_from_mysprite_layer(this, parent_state, []);
		super.destroy();
	}
	
	public static var tempmap:String = "";
	public static var tempx:Int = 0;
	public static var tempy:Int = 0;
	private var on:Bool = false;
	
	override public function update(elapsed: Float):Void 
	{
		//if (!did_init) {
			//did_init = true;
			//HF.add_list_to_mysprite_layer(this, parent_state, []);
		//}
		super.update(elapsed);
		
		
		
		if (R.player.overlaps(this) && !on) {
			animation.play("on");
			R.sound_manager.play(SNDC.checkpoint);
			on = true;
			tempmap = R.TEST_STATE.MAP_NAME;
			tempx = ix;
			tempy = iy;
			JankSave.force_checkpoint_things = true; // turned off in gnpc at end of guanltets
			if (is_valid) {
				//R.gauntlet_manager.update(gid, lid);
				//if (lid == 0) {
					//R.gauntlet_manager.set_init_chk_coords(tempmap, ix, iy);
				//}
				//R.gauntlet_manager.cache_gauntlet_entity_data();
			}
		} else {
			//if (on && R.gauntlet _manager.active_gauntlet_id == gid && R.gauntlet _manager.active_leg_id == lid) {
				//animation.play("on");
			//} else if (!R.player.overlaps(this)) {
				//if (tempx != ix || tempy != iy) {
					//on = false;
					//animation.play("idle");
				//}
			//}
		}

	}
	
}