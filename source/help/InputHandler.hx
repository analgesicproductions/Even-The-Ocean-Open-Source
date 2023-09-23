package help;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadManager;
import global.Registry;
import haxe.Log;
import flixel.FlxG;
import sys.FileSystem;

/**
 * ...
 * @author Melos Han-Tani
 */

class InputHandler 
{

	inline static public var KDX_UP:Int = 0;
	inline static public var KDX_RIGHT:Int = 1;
	inline static public var KDX_DOWN:Int = 2;
	inline static public var KDX_LEFT:Int = 3;
	inline static public var KDX_A1:Int = 4;
	inline static public var KDX_A2:Int = 5;
	inline static public var KDX_PAUSE:Int = 6;
	inline static public var KDX_SIT:Int = 7;
	
	inline static public var INPUT_TYPE_KEYS:Int = 1;
	inline static public var INPUT_TYPE_TOUCH:Int = 2;
	inline static public var INPUT_TYPE_JOY:Int = 4;
	
	private var allowedInputTypes:Int;
	public var keybindings:Array<String>; 
	
	public var up:Bool;
	public var down:Bool;
	public var left:Bool;
	public var right:Bool;
	public var pause:Bool;
	public var a1:Bool;
	public var a2:Bool;
	public var sit:Bool;
	public var CONFIRM:Bool;
	
	public var jpSit:Bool;
	public var jpUp:Bool;
	public var jpDown:Bool;
	public var jpLeft:Bool;
	public var jpRight:Bool;
	/** Jump key. **/
	public var jpA1:Bool;
	/** Shield-lock key. **/
	public var jpA2:Bool;
	public var jpPause:Bool;
	/** Alias for jpA2 */
	public var jpCONFIRM:Bool;
	/** Alias for jpA1 */
	public var jpCANCEL:Bool;
	
	/**
	 * Whether to flip the jump/shield FACE buttons
	 */
	public var joy_reverse:Bool = false;
	
	private var allow_jp_up:Bool;
	private var allow_jp_down:Bool;
	private var allow_jp_left:Bool;
	private var allow_jp_right:Bool;
	private var allow_jp_a1:Bool;
	private var allow_jp_a2:Bool;
	private var allow_jp_sit:Bool;
	private var allow_jp_pause:Bool;
	
	private var allow_jp_up_joy:Bool = false;
	private var allow_jp_d_joy:Bool = false;
	private var allow_jp_r_joy:Bool = false;
	private var allow_jp_l_joy:Bool = false;
	private var allow_jp_a1_joy:Bool = false;
	private var allow_jp_a2_joy:Bool = false;
	private var allow_jp_sit_joy:Bool = false;
	private var allow_jp_pause_joy:Bool = false;
	
	private var up_joy:Bool = false;
	private var d_joy:Bool = false;
	private var r_joy:Bool = false;
	private var l_joy:Bool = false;
	public var a1_joy:Bool = false;
	private var a2_joy:Bool = false;
	private var sit_joy:Bool = false;
	private var pause_joy:Bool = false;
	
	// Defaults for ps3
	public var y_axis_id:Int = 1;
	public var x_axis_id:Int = 0;
	
	public var joy_a1_id:Int = 2; // cross
	public var joy_a2_id:Int = 3; // square
	public var joy_sit_id:Int = 0; // select
	public var joy_pause_id:Int = 11; // start
	
	public var xbox_d_u_id:Int = 0;
	public var xbox_d_d_id:Int = 1;
	public var xbox_d_l_id:Int = 2;
	public var xbox_d_r_id:Int = 3;
	
	public var is_xbox:Bool = false;
	
	public function new(_a:Int=1) 
	{
		allowedInputTypes = _a;
		setKeyProfileDefault();
	}
	
	public function setKeyProfileDefault():Void {
		keybindings = ["UP", "RIGHT", "DOWN", "LEFT", "X", "C", "ENTER", "S"];
	}
	public function setKeyProfileWASD():Void {
		keybindings = ["W", "D", "S", "A", "K", "J", "ENTER", "I"];
	}
	
	public function update():Void {
		
		if (allowedInputTypes & INPUT_TYPE_KEYS > 0) {
			setInputFromKeys();
		}
	}
	
	private var lr_input_on:Bool = true;
	public function lr_toggle(b:Bool = false ):Void {
		lr_input_on = b;
	}
	
	public var force_dir:Int = -1;
	public var force_shield:Int = -1;
	public var force_shield_off:Bool = false;
	
	public var gamepad:FlxGamepad;
	
	
	private function setInputFromKeys():Void {
		
		//FlxG.keys.myPressed(
		
		//Log.trace(keybindings[KDX_RIGHT] + " " + Std.string(right) + " " + keybindings[KDX_LEFT] + " " + Std.string(left));
		up = FlxG.keys.myPressed(keybindings[KDX_UP]);
		right = FlxG.keys.myPressed(keybindings[KDX_RIGHT]);
		down = FlxG.keys.myPressed(keybindings[KDX_DOWN]);
		left = FlxG.keys.myPressed(keybindings[KDX_LEFT]);
		a2 = FlxG.keys.myPressed(keybindings[KDX_A2]);
		CONFIRM = FlxG.keys.myPressed(keybindings[KDX_A2]);
		a1 = FlxG.keys.myPressed(keybindings[KDX_A1]);
		pause = FlxG.keys.myPressed(keybindings[KDX_PAUSE]);
		sit = FlxG.keys.myPressed(keybindings[KDX_SIT]);
		
		
		
			//FlxG.log.clear();
		// Check for held inputs without overriding button state (in case controller+keys are in)
		if (FlxG.gamepads.lastActive != null && !Registry.R.speed_opts[6]) {
			gamepad = FlxG.gamepads.lastActive;
			//FlxG.log.clear();
			//FlxG.log.add("controler");
			//FlxG.log.add(gamepad.analog.value.LEFT_TRIGGER);
			
			// If joypad not holding a certain key from last check,
			// then it is okay to allow a Just pressed input.
			if (!up_joy) allow_jp_up_joy = true;
			if (!r_joy) allow_jp_r_joy = true;
			if (!d_joy) allow_jp_d_joy = true;
			if (!l_joy) allow_jp_l_joy = true;
			if (!a1_joy) allow_jp_a1_joy = true;
			if (!a2_joy) allow_jp_a2_joy = true;
			if (!sit_joy) allow_jp_sit_joy = true;
			if (!pause_joy) allow_jp_pause_joy = true;
			
			
			up_joy = gamepad.analog.value.LEFT_STICK_Y < -0.6;
			r_joy = gamepad.analog.value.LEFT_STICK_X > 0.6;
			d_joy = gamepad.analog.value.LEFT_STICK_Y > 0.6;
			l_joy = gamepad.analog.value.LEFT_STICK_X < -0.6;
			
			
			d_joy = d_joy || gamepad.pressed.DPAD_DOWN;
			up_joy = up_joy || gamepad.pressed.DPAD_UP;
			r_joy = r_joy || gamepad.pressed.DPAD_RIGHT;
			l_joy  = l_joy || gamepad.pressed.DPAD_LEFT;
				
			// Check to see if any buttons are held down
			pause_joy = gamepad.pressed.START;
			
			// Reverse face inuputs 
			if (joy_reverse) {
				a2_joy = gamepad.pressed.A;
				a1_joy = gamepad.pressed.B || gamepad.pressed.X;
			} else {
				a1_joy = gamepad.pressed.A;
				a2_joy = gamepad.pressed.B || gamepad.pressed.X;
			}
			
			a2_joy = a2_joy || gamepad.pressed.RIGHT_SHOULDER || gamepad.pressed.LEFT_SHOULDER || gamepad.analog.value.RIGHT_TRIGGER > 0.6 || gamepad.analog.value.LEFT_TRIGGER > 0.6;
			sit_joy = gamepad.pressed.Y;
			
			//Log.trace([a2, a2_joy,jpA2,allow_jp_a2,allow_jp_a2_joy]);
			
			// [OR] them with keyboard inputs
			up = up || up_joy;
			right = right || r_joy;
			down = down || d_joy;
			left = left || l_joy;
			a1 = a1 || a1_joy;
			a2 = a2 || a2_joy;
			sit = sit || sit_joy;
			pause = pause || pause_joy;
			
			CONFIRM = a2;
			
		}
		
		
		// Enforce one just-pressed event per keypress, independent of the event handlers
		allow_jp_up = up && jpUp ? false : true;
		allow_jp_right = right && jpRight ? false : true;
		allow_jp_down = down && jpDown ? false : true;
		allow_jp_left = left && jpLeft ? false : true;
		allow_jp_pause = pause && jpPause ? false : true;
		allow_jp_a1 = a1 && jpA1 ? false : true;
		allow_jp_a2 = a2 && jpA2 ? false : true;
		allow_jp_sit = sit && jpSit ? false : true;
		jpUp = allow_jp_up ? FlxG.keys.myJustPressed(keybindings[KDX_UP]) : false;
		jpRight = allow_jp_right ? FlxG.keys.myJustPressed(keybindings[KDX_RIGHT]) : false;
		jpDown = allow_jp_down ? FlxG.keys.myJustPressed(keybindings[KDX_DOWN]) : false;
		jpLeft = allow_jp_left ? FlxG.keys.myJustPressed(keybindings[KDX_LEFT]) : false;
		jpA2 = allow_jp_a2 ? FlxG.keys.myJustPressed(keybindings[KDX_A2]) : false;
		jpA1 = allow_jp_a1 ? FlxG.keys.myJustPressed(keybindings[KDX_A1]) : false;
		jpPause = allow_jp_pause ? FlxG.keys.myJustPressed(keybindings[KDX_PAUSE]) : false;
		jpSit = allow_jp_sit ? FlxG.keys.myJustPressed(keybindings[KDX_SIT]) : false;
		
		
		// If the joypad just pressed a key, make note of that here.
		// Don't need to check for active controller, b/c allow_jp_up_joy etc
		// are only true if there is an active controller to beginw ith.
		if (allow_jp_up_joy) { allow_jp_up_joy = false; jpUp = jpUp || up_joy; }
		if (allow_jp_r_joy) { allow_jp_r_joy= false; jpRight= jpRight|| r_joy; }
		if (allow_jp_d_joy) { allow_jp_d_joy= false; jpDown= jpDown || d_joy; }
		if (allow_jp_l_joy) { allow_jp_l_joy= false; jpLeft= jpLeft|| l_joy; }
		if (allow_jp_a1_joy) { allow_jp_a1_joy= false; jpA1= jpA1|| a1_joy; }
		if (allow_jp_a2_joy) { allow_jp_a2_joy= false; jpA2= jpA2|| a2_joy; }
		if (allow_jp_sit_joy) { allow_jp_sit_joy = false; jpSit= jpSit || sit_joy; }
		if (allow_jp_pause_joy) { allow_jp_pause_joy = false; jpPause = jpPause || pause_joy; }
		
		jpCONFIRM = jpA2;
		jpCANCEL = jpA1;
		
		if (FlxG.gamepads.lastActive != null) {
			//gamepad = FlxG.gamepads.lastActive;
			//var s:String = "";
			//s += Std.string(a2_joy) + ","; // 
			//s += Std.string(a2) + ","; // this one??
			//s += Std.string(gamepad.pressed.X) + ","; 
			//s += Std.string(gamepad.pressed.B) + ","; // 
			//s += Std.string(FlxG.keys.myPressed(keybindings[KDX_A2])) + ","; // this one??
			//s += Std.string(gamepad.analog.value.RIGHT_TRIGGER) + ",";
			//s += Std.string(gamepad.analog.value.LEFT_TRIGGER) + ",";
			//s += Std.string(gamepad.pressed.RIGHT_SHOULDER) + ",";
			//s += Std.string(gamepad.pressed.LEFT_SHOULDER) + ",";
			//s += Std.string(jpA2) + ",";
			//s += Std.string(force_shield) + ",";
			//s += Std.string(force_dir) + ",";
			//s += Std.string(force_shield_off) + ",";
			
			//s += Std.string("ID: " + gamepad.id) + "\n";
			//for (i in 0...25) {
				//s += Std.string(gamepad.getAxis(i)); 
				 ////hor 0, vert 1 /// =1. 1, -1 1
			//}
			//s += "\n";
			//for (i in 0...32) {
				//s += Std.string(gamepad.getButton(i).current);
			//}
			//s += "\n";
			//s += Std.string(gamepad.get_dpadUp());
			//s += Std.string(gamepad.get_dpadRight());
			//s += Std.string(gamepad.get_dpadDown());
			//s += Std.string(gamepad.get_dpadLeft());
			//FlxG.log.clear();
			//FlxG.log.add(s);
			//Log.trace(s);
			//if (allow_jp_a1) jpA1 = gamepad.justPressed(PS3ButtonID.X_BUTTON);
			//if (allow_jp_a2) jpA2 = gamepad.justPressed(PS3ButtonID.SQUARE_BUTTON);
			//if (allow_jp_pause) jpPause = gamepad.justPressed(PS3ButtonID.START_BUTTON);
			//if (allow_jp_sit) jpSit = gamepad.justPressed(PS3ButtonID.TRIANGLE_BUTTON);
			//if (allow_jp_a1) jpA1 = gamepad.justPressed(2);
			//if (allow_jp_a2) jpA2 = gamepad.justPressed(3);
			//if (allow_jp_pause) jpPause = gamepad.justPressed(9);
			//if (allow_jp_sit) jpSit = gamepad.justPressed(0);
		}
		
		if (lr_input_on == false) {
			jpLeft = jpRight = right = left = false;
			jpPause = pause = false;
			sit = jpSit = false;
		}
		
		if (force_dir != -1) {
			up = right = down = left = false;
			jpUp = jpRight = jpDown = jpLeft = false;
			switch (force_dir) {
				case 0:
					up = true;
				case 1:
					right = true;
				case 2:
					down = true;
				case 3:
					left = true;
			}
			force_dir = -1;
		}
		if (force_shield_off) {
			jpA2 = a2 = CONFIRM = jpCONFIRM = false;
			force_shield_off = false;
		}
		if (force_shield != -1) {
			a2 = CONFIRM = true;
			force_shield = -1;
		}
	}
	
	public function mouse_clicked():Bool {
		return FlxG.mouse.justPressed && FlxG.mouse.pressed;
	}
	
	public function jp_any():Bool{
		return (jpUp || jpRight || jpLeft || jpDown || jpA1 || jpA2 || jpPause || jpSit);
	}
	public function any_dir_down():Bool {
		return (up || down || left || right);
	}
	
	private var ou:Bool;
	private var or:Bool;
	private var od:Bool;
	private var ol:Bool;
	public function cache_dirs():Void {
		 ou =  up;
		 or =  right;
		 od =  down;
		 ol =  left;
	}
	public function uncache_dirs():Void {
		 right = or;  down = od;  left = ol;  up = ou;
	}
	public function unset_dirs():Void {
		up = down = left = right = false;
	}
	
	public function get_joy_save_string():String {
		return Std.string(joy_a1_id) + "," + Std.string(joy_a2_id) + "," + Std.string(joy_pause_id) + "," + Std.string(joy_sit_id);
	}
	
	public function set_joykeys_from_save_string(s:String):Void {
		var a:Array<String> = s.split(",");
		Log.trace("Joy config set: " + Std.string(a));
		joy_a1_id = Std.parseInt(a[0]);
		joy_a2_id = Std.parseInt(a[1]);
		joy_pause_id = Std.parseInt(a[2]);
		joy_sit_id = Std.parseInt(a[3]);
	}
}