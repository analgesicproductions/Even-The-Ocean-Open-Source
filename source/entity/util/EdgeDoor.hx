package entity.util;
import autom.SNDC;
import entity.MySprite;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import flixel.FlxObject;
import state.MyState;

class EdgeDoor extends MySprite
{

	private var down_sensor:FlxObject;
	private var sensor:FlxObject;
	private var up_sensor:FlxObject;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "EdgeDoor");
		immovable = true;
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				if (props.get("is_wide") == 1) {
					AnimImporter.loadGraphic_from_data_with_id(this,32,16,name,"wide");
				} else {
					AnimImporter.loadGraphic_from_data_with_id(this,32,16,name,"tall");
				}
				animation.play("closed"+anim_pref,true);
		}
	}
	
	private var only_open_dir:Int = 0;
	private var anim_pref:String = "";
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", 0);
		p.set("is_wide", 0);
		p.set("only_open_dir", -1); // URDL (0123), only opens from that dir
		
		down_sensor = new FlxObject(x, y, 32, 32);
		up_sensor = new FlxObject(x, y, 32, 32);
		sensor = new FlxObject(x, y, 80, 32);
		return p;
	}
	
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		
		
		anim_pref = "";
		if (props.get("only_open_dir") == 1) {
			anim_pref = "_l";
		} else if (props.get("only_open_dir") == 3) { 
			anim_pref = "_r";
		}
		if (props.get("only_open_dir") == 0) {
			anim_pref = "_d";
		} else if (props.get("only_open_dir") == 2) { 
			anim_pref = "_u";
		}
		
		change_visuals();
		only_open_dir = props.get("only_open_dir");
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	private var mode:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (mode == 0) {
			FlxObject.separate(R.player, this);
		} else {
			if (animation.curAnim != null && animation.curAnim.name.indexOf("open") == 0 && animation.curAnim.name.indexOf("opened") == -1) {
				if (animation.curAnim.curIndex  ==0) {
					FlxObject.separate(R.player, this);
				}
			}
		}
		up_sensor.x = x; up_sensor.y = y - up_sensor.height;
		down_sensor.x = x; down_sensor.y = y + height;
		sensor.x = x - 32; sensor.y = y;
		if (props.get("is_wide") == 0) {
			if (mode == 0) {
				if (R.player.overlaps(sensor) && animation.curAnim != null && animation.curAnim._frames.length -1 == animation.curAnim.curFrame) {
					if (only_open_dir == 1 && R.player.x + R.player.width < x+2) { // Do nothing
						animation.play("lock" + anim_pref);
						R.sound_manager.play(SNDC.edgedoor_locked);
					} else if (only_open_dir == 3 && R.player.x > x + width - 2) {
						animation.play("lock" + anim_pref);
						R.sound_manager.play(SNDC.edgedoor_locked);
					} else {
						animation.play("open" + anim_pref);
						
						R.sound_manager.play(SNDC.edgedoor_open);
						mode = 1;
						if (!did_init) {
							animation.play("opened"+anim_pref);
						}
					}
				}
			} else {
				if (!R.player.overlaps(sensor)  && animation.finished) {
					animation.play("close"+anim_pref);
						R.sound_manager.play(SNDC.edgedoor_close);
					mode = 0;
				}
			}
		} else {
			if (mode == 0) {
				if (R.player.overlaps(up_sensor) && !bubble_on) {
					bubble_on = true;	
					R.player.activate_npc_bubble("speech_appear");
				} else if (!R.player.overlaps(up_sensor) && bubble_on) {
					bubble_on = false;
					R.player.activate_npc_bubble("speech_disappear");
				}
				if (R.player.overlaps(down_sensor)  && animation.curAnim != null && animation.curAnim._frames.length -1 == animation.curAnim.curFrame) {
					if (only_open_dir == 2 || only_open_dir == -1) {
						animation.play("open"+anim_pref);
						R.sound_manager.play(SNDC.edgedoor_open);
						if (!did_init) {
							animation.play("opened"+anim_pref);
						}
						mode = 1;
					} else if (only_open_dir == 0) {
						R.sound_manager.play(SNDC.edgedoor_locked);
						animation.play("lock"+anim_pref);
					}
				} else if (R.player.overlaps(up_sensor) && R.input.jpA2) {
					if (only_open_dir == 0 || only_open_dir == -1) {
						animation.play("open"+anim_pref);
						R.sound_manager.play(SNDC.edgedoor_open);
						mode = 1;
						R.player.activate_npc_bubble("speech_disappear");
					} else if (only_open_dir == 2) {
						animation.play("lock"+anim_pref);
						R.sound_manager.play(SNDC.edgedoor_locked);
					}
				}
			} else {
				if (!R.player.overlaps(down_sensor) && !R.player.overlaps(up_sensor)  && animation.finished) {
					animation.play("close"+anim_pref);
						R.sound_manager.play(SNDC.edgedoor_close);
					mode = 0;
				}
			}
		}
		
		if (!did_init) {
			did_init = true;
		}
		super.update(elapsed);
	}
	
	private var bubble_on:Bool = false;
}