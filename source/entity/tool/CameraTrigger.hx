package entity.tool;
import entity.MySprite;
import entity.ui.MyRectSprite;
import global.C;
import haxe.Log;
import help.FlxX;
import help.HF;
import flash.geom.Point;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import state.MyState;
import state.TestState;
/**
 * ...
 * @author Melos Han-Tani
 */

class CameraTrigger  extends MySprite
{

	private var trigger_region:MyRectSprite;
	
	private var TYPE_HORIZONTAL_LOCK:Int = 0;
	private var TYPE_VERTICAL_LOCK:Int = 1;
	private var TYPE_ALL_LOCK:Int = 2;
	
	private var MODE_RETURN_TO_PLAYER:Int = 2;
	private var MODE_ACTIVE:Int = 1;
	private var MODE_INACTIVE:Int = 0;
	
	private var enter_triggers:FlxGroup;
	private var exit_triggers:FlxGroup;
	
	private var nr_enter_triggers:Int = 1;
	private var nr_exit_triggers:Int = 2;
	
	private var entry_coords:Array<Point>;
	private var exit_coords:Array<Point>;
	
	public static var IN_CAMERA_TRIGGER:Bool = false;
	public var HAS_LOCK:Bool = false;
	public static var CAM_TRIG_WITH_LOCK:CameraTrigger;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		
		trigger_region = new MyRectSprite(0xffffffff,1,1);
		enter_triggers = new FlxGroup();
		exit_triggers = new FlxGroup();
		super(_x, _y, _parent,"CameraTrigger");
		
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case _ if (vistype == TYPE_HORIZONTAL_LOCK):
				makeGraphic(32, 32, 0xffffffff);
				trigger_region.pick_color(0xff00ffff);
				trigger_region.set_size(props.get("width"), props.get("height"));
			case _ if (vistype == TYPE_VERTICAL_LOCK):
				makeGraphic(32, 32, 0xffffffff);
				trigger_region.pick_color(0xff00ff00);
				trigger_region.set_size(props.get("width"), props.get("height"));
			case _ if (vistype == TYPE_ALL_LOCK):
				makeGraphic(32, 32, 0xffffffff);
				trigger_region.pick_color(0xff0000ff);
				trigger_region.set_size(props.get("width"), props.get("height"));
		}
		trigger_region.x = x;
		trigger_region.y = y;
	}
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		var firstpt:String = Std.string(Std.int(x)) + "," + Std.string(Std.int(y));
		p.set("width", C.GAME_WIDTH);
		p.set("height", C.GAME_HEIGHT);
		p.set("exit", firstpt);
		p.set("enter", firstpt);
		p.set("vistype", TYPE_HORIZONTAL_LOCK);
		p.set("nrexit", 1);
		p.set("nrenter", 1);
		//p.set("use_w_h", 0);
		return p;
	}
	private var use_w_h:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		use_w_h = false;
		if (1 == props.get("use_w_h")) {
			use_w_h = true;
		}
		vistype = props.get("vistype");
		var entry_coords_str:String = props.get("enter");
		var exit_coords_str:String = props.get("exit");
		nr_enter_triggers = props.get("nrenter");
		nr_exit_triggers = props.get("nrexit");
		
		change_visuals();
		
		/* Using the current coord str, create an array of the points */
		entry_coords = HF.string_to_point_array(entry_coords_str);
		exit_coords = HF.string_to_point_array(exit_coords_str);
		
		enter_triggers.clear();
		exit_triggers.clear();
		
		// Now make these guys
		
		for (i in 0...nr_enter_triggers) {
			var enter_trigger:MySprite = new MySprite(x+32, y, parent_state, "EnterTrigger");
			enter_trigger.make_rect_outline(32, 32, 0xff00ff00,"EnterTrigger");
			if (i < entry_coords.length) {
				enter_trigger.x = entry_coords[i].x;
				enter_trigger.y = entry_coords[i].y;
			} else {
				entry_coords.push(new Point(x + 32, y));
			}
			enter_trigger.linked_sprite = this;
			enter_triggers.add(enter_trigger);
		}
		for (i in 0...nr_exit_triggers) {
			var exit_trigger:MySprite = new MySprite(x+32, y, parent_state, "ExitTrigger");
			exit_trigger.make_rect_outline(32, 32, 0xffff0000,"ExitTrigger");
			
			if (i < exit_coords.length) {
				exit_trigger.x = exit_coords[i].x;
				exit_trigger.y = exit_coords[i].y;
			} else {
				exit_coords.push(new Point(x+32, y));
			}
			exit_trigger.linked_sprite = this;
			exit_triggers.add(exit_trigger);
		}
	}
	// When a child is moved, update its entry coordinates, also update the
	// data string for the enter/exit cordinates
	override public function on_child_notification(m:MySprite):Void 
	{
		var i:Int = 0;
		if (m.name == "EnterTrigger") {
			i = FlxX.indexOf(enter_triggers, m);
			entry_coords[i].x = m.x;
			entry_coords[i].y = m.y;
		} else {
			i = FlxX.indexOf(exit_triggers, m);
			exit_coords[i].x = m.x;
			exit_coords[i].y = m.y;
		}
		
		props.set("enter", HF.point_array_to_string(entry_coords));
		props.set("exit", HF.point_array_to_string(exit_coords));
	}
	
	override public function destroy():Void 
	{
		
		if (HAS_LOCK && all_lock_mode == 0 && vistype == TYPE_ALL_LOCK) {
			FlxG.camera.setScrollBoundsRect(0, 0, parent_state.tm_bg.width, parent_state.tm_bg.height);
		}
		
		if (IN_CAMERA_TRIGGER) IN_CAMERA_TRIGGER = false;
		HF.remove_list_from_mysprite_layer(this, parent_state, [trigger_region, enter_triggers, exit_triggers]);
		if (HAS_LOCK) HAS_LOCK = false;
		if (CAM_TRIG_WITH_LOCK == this) CAM_TRIG_WITH_LOCK = null;
		
		super.destroy();
	}
	private var all_lock_mode:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		
		trigger_region.x = x;
		trigger_region.y = y;
		if (!did_init) {
			HF.add_list_to_mysprite_layer(this, parent_state, [trigger_region,enter_triggers,exit_triggers]);
			did_init = true;
		}
		
		if (R.editor.editor_active == true) {
			enter_triggers.exists = exit_triggers.exists = trigger_region.exists = true;
			visible = true;
		} else {
			enter_triggers.exists = exit_triggers.exists = trigger_region.exists = false;
			visible = false;
		}
		
		
		
		if (state == MODE_ACTIVE) {
			if (!HAS_LOCK) { // Only happens if another cam trig takes the lock
				state = MODE_INACTIVE;
				x = ix; y = iy; 
				return;
			}
			if (R.player.overlaps(exit_triggers)) { /////
				IN_CAMERA_TRIGGER = false;
				state = MODE_INACTIVE;
				//Log.trace("exit camtrig");
				R.TEST_STATE.expand_tilemaps(0.5);
				FlxG.camera.follow(R.player);
				FlxG.camera.followLerp = 60;
				TestState.truly_set_default_cam(parent_state.tm_bg.width, parent_state.tm_bg.height);
				var ts:TestState = cast(parent_state, TestState);
				ts.redraw_camera_debug();
				if (vistype == TYPE_ALL_LOCK) {
					FlxG.camera.setScrollBoundsRect(0, 0, parent_state.tm_bg.width, parent_state.tm_bg.height);
				}
			} else {
				var ct:Int = 0;
				// Only works if camera is following something otherwise use HF.move_camera_to
				if (vistype == TYPE_VERTICAL_LOCK || all_lock_mode == 1) {
					if (Math.abs(FlxG.camera._scrollTarget.y - y) > 1) {
						if (FlxG.camera._scrollTarget.y > y) {
							FlxG.camera._scrollTarget.y -= 2.0;
						} else {
							FlxG.camera._scrollTarget.y += 2.0;
						}
					} else {
						ct++;
						FlxG.camera._scrollTarget.y = y;
					}
				}
				if (vistype == TYPE_HORIZONTAL_LOCK || all_lock_mode == 1) {
					if (Math.abs(FlxG.camera._scrollTarget.x - x) > 1) {
						if (FlxG.camera._scrollTarget.x > x) {
							FlxG.camera._scrollTarget.x -= 2.0;
						} else {
							FlxG.camera._scrollTarget.x += 2.0;
						}
					} else {
						ct++;
						FlxG.camera._scrollTarget.x = x;
					}	
				}
				if (vistype == TYPE_ALL_LOCK) {
					if (all_lock_mode == 0) {
						if (FlxG.camera.followLerp > 15) {
							FlxG.camera.followLerp --;
						}
					} else if (all_lock_mode == 1) { 
						if (Math.abs(FlxG.camera.scroll.x - FlxG.camera._scrollTarget.x) < 1 && Math.abs(FlxG.camera.scroll.y - FlxG.camera._scrollTarget.y) < 1) {
							ct++;
						}
						if (ct == 3) {	
							// change bounds to the camera trigger region
							R.TEST_STATE.expand_tilemaps(0.5);
							FlxG.camera.follow(R.player);
							FlxG.camera.followLerp = 60;
							TestState.truly_set_default_cam(parent_state.tm_bg.width, parent_state.tm_bg.height);
							FlxG.camera.setScrollBoundsRect(ix, iy, trigger_region._w, trigger_region._h);
							x = ix; y = iy;
							all_lock_mode = 0;
						}
					}
				}
			}
			
			
		} else if (state == MODE_INACTIVE) {
			// When you enter the enter trigger, modify the deadzone
			if (R.player.overlaps(enter_triggers)) { /////////
				
				FlxG.camera.followLerp = 60;
				if (IN_CAMERA_TRIGGER == true) {
					if (CAM_TRIG_WITH_LOCK != null) {
						CAM_TRIG_WITH_LOCK.HAS_LOCK = false;
						FlxG.camera.setScrollBoundsRect(0, 0, parent_state.tm_bg.width, parent_state.tm_bg.height);
					} else {
						Log.trace("??? shouldnt be null.");
					}
				}
				CAM_TRIG_WITH_LOCK = this;
				HAS_LOCK = true;
				IN_CAMERA_TRIGGER = true;
				//Log.trace("enter camtrig");
				R.TEST_STATE.expand_tilemaps(0.5);
				switch (vistype) {
					case _ if (vistype ==TYPE_VERTICAL_LOCK): // lock y axis
						FlxG.camera.deadzone.y = -40;
						FlxG.camera.deadzone.height = FlxG.height + 80;
						state = MODE_ACTIVE;
					case _ if (vistype ==TYPE_HORIZONTAL_LOCK): // lock x axis
						FlxG.camera.deadzone.x = -40;
						FlxG.camera.deadzone.width = FlxG.width + 80;
						FlxG.camera.deadzone.height = 40;
						FlxG.camera.deadzone.y = (FlxG.height - 40) / 2;
						state = MODE_ACTIVE;
					case _ if (vistype == TYPE_ALL_LOCK):
						// Initially prevent player follow-d scrolling
						FlxG.camera.deadzone.x = FlxG.camera.deadzone.y = -40;
						FlxG.camera.deadzone.height = FlxG.height + 80;
						FlxG.camera.deadzone.width = FlxG.width + 80;
						all_lock_mode = 1;
						state = MODE_ACTIVE;
						
						var sy:Float = FlxG.camera.scroll.y;
						var ch:Float = FlxG.camera.height;
						var cw:Float = FlxG.camera.width;
						var sx:Float = FlxG.camera.scroll.x;
						if (sy + ch > iy+ trigger_region._h) {
							y = iy + trigger_region._h - ch;
						} 
						if (sx + cw > ix + trigger_region._w) {
							x = ix + trigger_region._w - cw;
						}
						//Log.trace("enter");
				}
				
				var ts:TestState = cast(parent_state, TestState);
				ts.redraw_camera_debug();
			}
			
		}
	}
}