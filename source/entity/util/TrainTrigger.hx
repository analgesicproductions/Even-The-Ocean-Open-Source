package entity.util;
import entity.MySprite;
import flixel.text.FlxBitmapText;
import help.HF;
import flixel.FlxObject;
import state.MyState;

/**
 * Triggers things for trains - can get scripts to run on a train
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class TrainTrigger extends MySprite
{

	public var event_id:String;
	public var active_region:FlxObject;
	public var text:FlxBitmapText;
	public static var ACTIVE_TrainTriggers:List<TrainTrigger>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		text = HF.init_bitmap_font();
		text.scrollFactor.set(1, 1);
		super(_x, _y, _parent, "TrainTrigger");
		active_region = new FlxObject(0, 0, 10, 10);
			ACTIVE_TrainTriggers.add(this);
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				makeGraphic(16, 16, 0xbbff0000);
		}
		// Change visuals
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		// Set default properties here
		p.set("event_id", "none");
		p.set("id", 0);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		change_visuals();
		
	}
	
	override public function destroy():Void 
	{
		ACTIVE_TrainTriggers.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [text]);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [text]);
		}
		active_region.x = x + 3;
		active_region.y = y + 3;
		if (R.editor.editor_active) {
			visible = true;
			text.visible = true;
			text.text = Std.string(props.get("id"));
			text.x = x;
			text.y = y;
		} else {
			visible = false;
			text.visible = false;
		}
		
		if (R.TEST_STATE.train.overlaps(active_region)) {
			R.TEST_STATE.train.inside_stopping_point = true;
			R.TEST_STATE.train.stopping_point_id = props.get("event_id");
		}
		
		
		super.update(elapsed);
	}
}