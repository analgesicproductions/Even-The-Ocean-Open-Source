package entity.util;
import entity.MySprite;
import flash.geom.Point;
import global.C;
import global.EF;
import haxe.Log;
import help.HF;
import help.JankSave;
import hscript.Interp;
import openfl.Assets;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import state.MyState;
import state.TestState;

/**
 * When triggered, this modifies a layer of the world map
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class PathUnlocker extends MySprite
{
	
	private var mode:Int = 0;
	private static inline var mode_locked:Int = 0;
	private static inline var mode_UNLOCKING:Int = 1;
	private static inline var mode_UNLOCKED:Int = 2;
	private static inline var mode_try_to_unlock:Int = 3;
	private static inline var mode_pan_camera_to_point:Int = 4;
	private static inline var mode_pan_camera_to_player:Int = 5;
	private var tile_coords:Point;
	private var unlock_path:Array<Point>;
	private var unlock_path_vals:Array<Int>;
	private var tm_layer:Int;
	private var node_stamp:FlxSprite;
	private var cur_unlocking_idx:Int = 0;
	
	private var t_latency:Float = 0;
	private var tm_latency:Float = 0;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		// Init sprites here
		super(_x, _y, _parent, "PathUnlocker");
		node_stamp = new FlxSprite();
		node_stamp.makeGraphic(16, 16, 0xaaff0000);
		mode = mode_try_to_unlock;
		// Change visuals or add things here
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				myLoadGraphic(Assets.getBitmapData("assets/sprites/util/PathUnlocker.png"), true, false, 16, 16);
		}
		visible = false;
		// Change visuals
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		// Set default properties here
		p.set("s_unlocked", 0);
		p.set("layer", MyState.LDX_BG2);
		p.set("nodes", "0,0,0,1,1,0,1,1");
		p.set("values", "4,4,4,4");
		p.set("latency", 0.2);
		p.set("script", "evenpath_script.hx");
		p.set("type", "");
		p.set("sig_number", 1); // What value this must receive to instant-activate in a cutscene
		return p;
	}
	
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == "instant_" + Std.string(props.get("sig_number"))) {
			unlock_all(parent_state, props.get("layer"), unlock_path, unlock_path_vals);
			return C.RECV_STATUS_OK;
		}
		return C.RECV_STATUS_NOGOOD;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		change_visuals();
		
		tm_latency = props.get("latency");
		unlock_path = HF.string_to_point_array(props.get("nodes"));
		unlock_path_vals = HF.string_to_int_array(props.get("values"));
		if (props.get("s_unlocked") == 1) {
			unlock_all(parent_state,props.get("layer"),unlock_path,unlock_path_vals);
		}
	}
	
	override public function destroy():Void 
	{
		node_stamp.destroy();
		super.destroy();
	}
	
	private function unlock_all(ms:MyState, ldx:Int, nodes:Array<Point>, vals:Array<Int>,FORCE_IDX:Int=-1):Void {
		var tm:FlxTilemapExt = null;
		if (ldx == MyState.LDX_BG2) {
			tm = ms.tm_bg2;
		} else if (ldx == MyState.LDX_BG) {
			tm = ms.tm_bg;
		}
		var tx:Int = Std.int(x / 16);
		var ty:Int = Std.int(y / 16);
		if (FORCE_IDX != -1) {
			if (FORCE_IDX >= nodes.length) return;
			tm.setTile(tx + Std.int(nodes[FORCE_IDX].x), ty + Std.int(nodes[FORCE_IDX].y), vals[FORCE_IDX], true);
			return;
		}
		for (i in 0...nodes.length) {
			tm.setTile(tx + Std.int(nodes[i].x), ty + Std.int(nodes[i].y), vals[i],true);
		}
		props.set("s_unlocked", 1);
	}
	
	private static var pathunlocker_locked:Bool = false;
	private static var pathunlocker_lock:Int = 1;
	private var pan_dest:Point;
	private var old_cam_coord:Point;
	override public function update(elapsed: Float):Void 
	{
		
		if (R.editor.editor_active) {
			visible = true;
		} else {
			visible = false;
		}
		
		if (mode == mode_try_to_unlock && pathunlocker_lock == 1) {
			pathunlocker_lock = 0;
			if (condition()) {
				R.toggle_players_pause(true);
				mode = mode_pan_camera_to_point;
				pan_dest = new Point(x - (C.GAME_WIDTH / 2), y - (C.GAME_HEIGHT / 2));
				old_cam_coord = new Point(FlxG.camera.scroll.x, FlxG.camera.scroll.y);
				// uncommented, breaking
				//if (pan_dest.x > FlxG.camera.bounds.width - FlxG.camera.width) pan_dest.x = FlxG.camera.bounds.width - FlxG.camera.width;
				if (pan_dest.x < 0) pan_dest.x = 0;
				//if (pan_dest.y > FlxG.camera.bounds.height - FlxG.camera.height) pan_dest.y = FlxG.camera.bounds.height - FlxG.camera.height;
				if (pan_dest.y < 0) pan_dest.y = 0;
				FlxG.camera.follow(null);
				props.set("s_unlocked", 1);
			} else {
				mode = mode_locked;
				pathunlocker_lock = 1;
			}
		} else if (mode == mode_pan_camera_to_point) {
			
			if (HF.move_camera_to(pan_dest.x, pan_dest.y, 1, 2)) {
				mode = mode_UNLOCKING;
			}
		} else if (mode == mode_pan_camera_to_player) {
				if (HF.move_camera_to(old_cam_coord.x,old_cam_coord.y,1,2)) {
					mode = mode_UNLOCKED;
					var ts:TestState = cast(parent_state, TestState); 
					ts.set_default_camera(); // maybe need to test for train
					pathunlocker_lock = 1;
					R.toggle_players_pause(false);
				}
		} else if (mode == mode_locked) {
		} else if (mode == mode_UNLOCKING) {
			t_latency += FlxG.elapsed;
			if (t_latency > tm_latency) {
				t_latency -= tm_latency;
				
				unlock_all(parent_state, props.get("layer"), unlock_path, unlock_path_vals, cur_unlocking_idx);
				
				cur_unlocking_idx ++;
				if (cur_unlocking_idx >= unlock_path.length) {
					mode = mode_pan_camera_to_player;
					cur_unlocking_idx = 0;
				}
			}
		} else if (mode == mode_UNLOCKED) {
		}
		super.update(elapsed);
		
		if (FlxG.keys.myJustPressed("SPACE")) {
			EF.set_flag(EF.even_world_test, R.event_state, true);
		}
		if (FlxG.keys.myJustPressed("Z")) {
			mode = mode_try_to_unlock;
		}
	}
	
	private function condition():Bool {
		if (props.get("script") != "") {
			
			var program = HF.get_program_from_script_wrapper(props.get("script"));
			var interpreter:Interp = new Interp();
			interpreter.variables.set("R", R);
			interpreter.variables.set("EF", EF);
			interpreter.variables.set("type", props.get("type"));
			var retval:Dynamic = interpreter.execute(program);
			return retval;
		}
		return false;
	}
	override public function draw():Void 
	{
		if (R.editor.editor_active) {
			for (point in unlock_path) {
				node_stamp.x = x + point.x * 16;
				node_stamp.y = y + point.y * 16;
				node_stamp.draw();
			}
		}
		super.draw();
	}
}