package state;
import autom.EMBED_TILEMAP;
import cpp.vm.Profiler;
import flixel.text.FlxBitmapText;
import global.EF;
import global.Registry;
import haxe.Log;
import help.HF;
import help.JankSave;
import flixel.FlxG;
import flixel.FlxState;

/**
 * My own state switching code
 * @author Melos Han-Tani
 */

	class GameState extends FlxState
{

	public static var do_change_state:Bool = false;
	public static var next_state:Int = 0;
	public var cur_state_id:Int = -100;
	public var cur_mystate:MyState;
	public static inline var STATE_TEST:Int = 0;
	public static inline var STATE_TITLE:Int = 2;
	public static var EDITOR_IS_TOGGLEABLE:Bool = false;
	public var R:Registry;
	
	public static var RELEASE_MODE:Int = 0;
	public static inline var RELEASE_MODE_DEV:Int = 0;
	public static inline var RELEASE_MODE_RELEASE:Int = 1;
	
	public static var START_STATE:Int = 0;
	public function new() 
	{
		
		super();
	}
	override public function create():Void 
	{
		//HF.ENCRYPT_ENTITY();
		R = Registry.R;
		
		//RELEASE_MODE = RELEASE_MODE_DEV;
		if (START_STATE == 0) {
			next_state = STATE_TITLE;
		} else {
			next_state = STATE_TEST;
		}
		//next_state = STATE_TITLE;
		FlxG.log.redirectTraces = false;
		FlxG.log.add("Close debugger with SHIFT+\\!");
		R.TEST_STATE = new TestState();
		R.TITLE_STATE = new TitleState();
		R.TEST_STATE.create();
		R.TITLE_STATE.create();
		
		if (next_state == STATE_TEST && RELEASE_MODE == RELEASE_MODE_DEV) {
			//Log.trace("Initializing random silo coords");
			R.reload_silo_data(false);
			EF.set_flag(6, R.event_state, true); // aliph armo
			R.player.change_vistype(0);
			// In case armor is turnt off later
			TestState.truly_set_default_cam(R.TEST_STATE.tm_bg.width, R.TEST_STATE.tm_bg.height);
			
		} else if (next_state == STATE_TEST && RELEASE_MODE == RELEASE_MODE_RELEASE) {
			if (START_STATE == 1) {
				R.reload_silo_data(false);
				Log.trace("Reloading silo bc start = test, releasemode = release");
			}
			EF.set_flag(6, R.event_state, true);
			R.player.change_vistype(0);
			TestState.truly_set_default_cam(R.TEST_STATE.tm_bg.width, R.TEST_STATE.tm_bg.height);
		}
		
		do_change_state = true;
	}
	
	private var b:Bool = false;
	
	private var gamestate_debug_text:FlxBitmapText;
	override public function update(elapsed: Float):Void {
		
		
		if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.BACKSLASH) {
			FlxG.debugger.visible = !FlxG.debugger.visible;
			FlxG.log.add("Close debugger with SHIFT+\\");
		}
		
		//if (FlxG.keys.justPressed.B) {
			//var d:Map<String,Dynamic> = new Map<String,Dynamic>();
			//d.get("hello").get("4");
		//}
		
		// Update song fade-ins/fade-outs, etc.
		R.song_helper.update(elapsed);
		R.sound_manager.update(elapsed); // dunno
		
		// Determine whether to update the game timer
		if (cur_state_id != STATE_TITLE) { // Don't update it in the Title Screen
			// Don't update it when saving the game 
			if (R.save_module.is_idle() == true && 1 == 1) {
				if (R.is_the_ocean) {
					R.playtime ++;
				} else {
					R.even_playtime++;
				}
			}
		}
		
		// toggle Editor
		if (EDITOR_IS_TOGGLEABLE) {
			if ((FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.justPressed.E) || (FlxG.keys.pressed.SPACE && FlxG.keys.justPressed.E)) {
				if (cur_mystate.is_editable) {
					R.editor.toggle(cur_mystate);
				}
			}
			if (R.editor.editor_active == false && R.QA_TOOLS_ON) {
				if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.E) {
					R.player.energy_bar.frozen = !R.player.energy_bar.frozen;
					Log.trace("Energy bar frozen: " + Std.string(R.player.energy_bar.frozen));
				}
			}
		}
		if (R.editor.editor_active == false) {
			if (FlxG.mouse.visible) {
				FlxG.mouse.visible = false;
			}
		}
		
		if (do_change_state) {
			do_change_state = false;
			if (next_state != cur_state_id) {
				if (next_state == STATE_TEST) {
					R.TEST_STATE.finish_play_to_title();
				}
				remove(cur_mystate, true);
				switch (next_state) {
					case STATE_TEST:
						cur_mystate = cast(R.TEST_STATE, MyState);
						R.TEST_STATE.init_title_to_play();
					case STATE_TITLE:
						FlxG.camera.follow(null);
						FlxG.camera.scroll.x = FlxG.camera.scroll.y = 0;
						cur_mystate = cast(R.TITLE_STATE, MyState);
				}
				add(cur_mystate);
				cur_state_id = next_state;
			}
		}
		super.update(elapsed);
	}
	
	public static function go_to_title():Void {
		do_change_state = true;
		next_state = STATE_TITLE;
	}
}