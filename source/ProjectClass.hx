package;

import autom.EMBED_TILEMAP;
import entity.MySprite;
import entity.npc.GenericNPC;
import entity.ui.Inventory;
import entity.ui.MenuMap;
import entity.ui.NameEntry;
import flixel.animation.FlxAnimationController;
import flixel.system.frontEnds.SoundFrontEnd;
import global.C;
import global.Registry;
import haxe.Log;
import help.AnimImporter;
import help.DialogueManager;
import help.Editor;
import help.FlxX;
import help.JankSave;
import help.SaveModule;
import help.SoundManager;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.geom.Point;
import flash.Lib;
import help.Track;
import help.TwitchHelper;
import flash.system.Capabilities;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxSave;
import flixel.system.FlxSound;
import state.GameState;
import state.MyState;
import state.TestState;
import state.TitleState;
#if cpp
import sys.io.File;
import sys.FileSystem;
#end
	
/**
 * Melos Han-Tani wrote all of this code in the source folder.
 * He used HaXe Flixel and NME too.
 * @author Melos Han-Tani (2013)
 */
class ProjectClass extends FlxGame
{	
	
	public static var DEV_MODE_ON:Bool = false;
	public static var FORCE_FULLSCREEN_FLIP:Bool = false;
	
	public static var twitch_helper:TwitchHelper;
	public var R:Registry;
	public var did_init:Bool = false;
	
	/**
	 * Default width of windowed game - baed on dims in shieldhaxe.nmml
	 */
	public var real_width:Int = 0;
	public var real_height:Int = 0;
	public var fs_dim:Point;
	public function new()
	{
	
		
		// Do this here or else uh... some bitmaptexts will load with rendertile = false and that crashes stuff
		FlxG.renderTile = true;
		FlxG.renderBlit = false;
		FlxG.debugger.toggleKeys = null;
		
		
		var sx:Float = Capabilities.screenResolutionX / 832.0;
		var sy:Float = Capabilities.screenResolutionY / 512.0;
		sx *= 2;
		sy *= 2;
		max_int_scale = Std.int(Math.min(Math.floor(sx), Math.floor(sy)));
		scale_type = "0," + Std.string(max_int_scale);
			
		
		if (Capabilities.language == "en") {
			Log.trace("initLang=English.");
			//C.init_jp();
		} else if (Capabilities.language == "ja" || Capabilities.language == "jp") {
			Log.trace("initLang=English.");
			//Log.trace("initLang=Japanese.");
			//DialogueManager.CUR_LANGTYPE = DialogueManager.LANGTYPE_JP;	
		} else if (Capabilities.language == "zh" || Capabilities.language == "zh-Hans"  || Capabilities.language == "zh-CN") {
			Log.trace("initLang=simplified chinese");
			DialogueManager.CUR_LANGTYPE = DialogueManager.LANGTYPE_ZH_SIMP;
		} else if (Capabilities.language == "de") {
			Log.trace("initlang=german");
			DialogueManager.CUR_LANGTYPE = DialogueManager.LANGTYPE_DE;
		} else if (Capabilities.language == "ru") {
			Log.trace("initlang=russian");
			DialogueManager.CUR_LANGTYPE = DialogueManager.LANGTYPE_RU;
		}  else if (Capabilities.language == "es") {
			Log.trace("initlang=spanish");
			DialogueManager.CUR_LANGTYPE = DialogueManager.LANGTYPE_ES;
		} else if (Capabilities.language == "zh-Hant" || Capabilities.language == "zh-TW") {
			Log.trace("initLang=traditional chinese");
			Log.trace("Falling back on simplified though");
			DialogueManager.CUR_LANGTYPE = DialogueManager.LANGTYPE_ZH_SIMP;
		} else {
			Log.trace(Capabilities.language);
		}
		
			//Log.trace("initlang=russian");
			//DialogueManager.CUR_LANGTYPE = DialogueManager.LANGTYPE_RU;
		// These two vars are set in shieldhaxe.nmml
		JankSave.init();
		Track.init();
		twitch_helper = new TwitchHelper();
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		C.GAME_WIDTH = 416;
		C.GAME_HEIGHT = 256;
		var ratioX:Float = stageWidth / C.GAME_WIDTH;
		var ratioY:Float = stageHeight / C.GAME_HEIGHT;
		// Will be an integer by default
		var ratio:Float = Math.min(ratioX, ratioY);
		C.init();
		FlxX.make_sin_cos_table();
		GenericNPC.load_generic_npc_data(false);
		AnimImporter.import_anims();
		EMBED_TILEMAP.init();
		Registry.init();
		R = Registry.R;
		R.gnpc = GenericNPC.generic_npc_data;
		//R.reload_build_vars(); // now done inside init
		var ismelosismelos:Bool = false;
		var drawfr:Int = 60;
		#if cpp
		if (FileSystem.exists("../../../../txt/.melos")) {
			ismelosismelos = true;
		} else {
			if (DEV_MODE_ON) {
			}
		}
		#end
		super(C.GAME_WIDTH, C.GAME_HEIGHT, GameState, Math.floor(ratio), 60,drawfr);
	
		
		FlxG.sound.muteKeys = [];
		FlxG.autoPause = false;
		FlxG.keys.enabled = true;
		
		FlxAnimationController.frame_splice_in_add_is_on = false;
		FlxAnimationController.frame_splice_warn_in_add_is_on = false;
		
		real_height = C.GAME_HEIGHT  * Math.floor(ratio);
		real_width = C.GAME_WIDTH * Math.floor(ratio);
		
		FlxG.sound.volume = 1.0;
		fs_dim = new Point(Capabilities.screenResolutionX, Capabilities.screenResolutionY);
		
		
		// Update build log if dev mode
		#if cpp
		if (DEV_MODE_ON) {
			// don't do this in open source version
			/*
			if (FileSystem.exists("../../../../txt/.melos")) {
				var devlog_content:String = File.getContent("../../../../txt/BUILD_LOG.txt");
				var devlog_chunk:String = devlog_content.split("\n")[0];
				var nr:Int = Std.parseInt(devlog_chunk.split(" ")[0]);
				nr++;
				var d:Date = Date.now();
				File.saveContent("../../../../txt/BUILD_LOG.txt", Std.string(nr) + " " + d.toString() + "\r\n" + devlog_content);
				//Log.trace("Build " + Std.string(nr) + ": " + d.toString());
				Log.trace("Build " + Std.string(nr));
			}
			*/
		}
		#end
	}
	
	public static var TOGGLE_LETTERBOXING:Bool = false;
	public static var max_int_scale:Int = 0;
	private var fs_queued:Bool = false;
	private var win_to_fs:Bool = false;
	private var t_mac:Int = 0;
	
	// automatically set based on max int scaling above
	public static var scale_type:String = "0,0";
	public static var window_scale_type:Int = 2;
	
	override private function update():Void 
	{
		
		#if !FLX_NO_KEYBOARD


		if (fs_queued) {
			
			// Set to true below, ensures that no matter the delay between asking the game to
			// go fullscreen, and actually changing the displayState var,
			// I'll always be able to make sure the fullscreened game is correctly sized 
			// (This was an issue on mac...) - 10/21
			if (win_to_fs) {
				//Log.trace(t_mac);
				#if mac
				t_mac--;
				#end
				if (t_mac <= 0 && Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
					win_to_fs = false;
					set_scaling(scale_type);
					fs_queued = false;
				}
			} else {
				fs_queued = false;
				if (Lib.current.stage.displayState == StageDisplayState.NORMAL) {
					scaleX = 1;
					scaleY = 1;
					x = 0;
					y = 0;
					FlxG.resizeWindow(window_scale_type * 416, window_scale_type * 256);
					FlxG.resizeWindow(window_scale_type * 416, window_scale_type * 256);
				} else {
					set_scaling(scale_type);
				}
			}
		}
		if (TOGGLE_LETTERBOXING) {
			// Don't allow adjusting letterboxing when windowed
			if (Lib.current.stage.displayState == StageDisplayState.NORMAL) {
				TOGGLE_LETTERBOXING = false;
			} else {
				set_scaling(scale_type);
				TOGGLE_LETTERBOXING = false;
			}
		}
		if (FORCE_FULLSCREEN_FLIP || (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ENTER && R.input.jpPause)) {
			FORCE_FULLSCREEN_FLIP = false;
			if (Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
				Lib.current.stage.displayState = StageDisplayState.NORMAL;
				fs_queued = true;
			} else {
				// maybe fixes bug - ordering
				// other bug is tied to old lime (fml)
				Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				fs_queued = true;
				win_to_fs = true;
				#if mac
				t_mac = 15;
				#end
			}
		}
		// oh whatever maybe not perfect
		if (FlxG.keys.justPressed.ENTER && FlxG.keys.pressed.ALT) {
			if (Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
				fs_queued = true;
			} else {
				fs_queued = true;
			}
		}
		
		#end


		R.input.update();
		
		// Initialize registry objects that required the atlas to be created (via the constructor)
		if (false == did_init) {
			did_init = true;
			
		FlxG.camera.pixelPerfectRender = true;
		
			R.name_entry = new NameEntry();
			R.editor = new Editor();
			R.sound_manager = new SoundManager();
			MySprite.presets = MySprite.initialize_entity_presets("entity_presets.son");
			
			// Get most recent save's controls, window settings, blah blah blah
			if (DEV_MODE_ON == false) {
				Log.trace("Dev mode OFF:\n\tloading recent settings.");
				JankSave.dontdolang = true;
				JankSave.load_recent(true);
				JankSave.dontdolang = false;
				
				
			} else {
				Log.trace("Dev mode ON:\n\tNOT loading recent settings.");
			}
			
			// These initializations rely on something from the save maybe
			R.dialogue_manager = new DialogueManager();
			// These initializations rely on labels provided via the dilogue manager
			R.save_module = new SaveModule();
			
			//x = (Lib.current.stage.stageWidth - real_width ) / 2;
			//y = (Lib.current.stage.stageHeight - real_height) / 2;
			
			
			if (DEV_MODE_ON == false) {
				// Rlease mode but starting in Test, i.e. tester build
				if (GameState.START_STATE == 1) {
					Log.trace("resetting gauntlet lenses bc test builds might turn off the consoles at gauntlet ends that would reset stuff");
					R.dialogue_manager.change_scene_state_var("test", "gstate", 1, 0);
				}
			}
			//Log.trace("debug set world map 18");
			//R.inventory.set_item_found(0, 18);
		}
		
		super.update();
	}
	
	
	function set_scaling(info:String):Void {
		
		var type:Int = Std.parseInt(info.split(",")[0]);
		if (type == 0) {
			var target_int_scale:Int = Std.parseInt(info.split(",")[1]);
			
			var sx:Float = Capabilities.screenResolutionX / 832.0;
			var sy:Float = Capabilities.screenResolutionY / 512.0;
			sx *= 2;
			sy *= 2;
			
			// idk why this would happen but you never fuckin' know
			if (target_int_scale > max_int_scale || target_int_scale <= 0) {
				Log.trace("Nice try kid " + Std.string(target_int_scale));
				target_int_scale = max_int_scale;
			}
			
			
			//Lib.application.window.resize(100, 100);
			
			var int_ratio:Float = 0;
			// need to reduce a dimension . find the next lowest multiple of 0.5 and bring both to it.
			var default_fs_px_h:Int = 0;
			var default_fs_px_w:Int = 0;
			if (sy <= sx) {
				// undouble before resizing
				sy /= 2;
				default_fs_px_h = Std.int(sy * 512.0);
				default_fs_px_w = Std.int(sy * 832.0); // sy not a typo
			} else {
				sx /= 2;
				default_fs_px_h = Std.int(sx * 512.0);
				default_fs_px_w = Std.int(sx * 832.0); 
			}
			// Find how big the screen is without adjustments. This (default_fs_px_w, etc) is our "scale = 1".
			// Then using this value, readjust.
			scaleX = (416.0 * target_int_scale) / default_fs_px_w;
			scaleY = (256.0 * target_int_scale) / default_fs_px_h;
			x = (Capabilities.screenResolutionX - (416.0 * target_int_scale)) / 2;
			y = (Capabilities.screenResolutionY - (256.0 * target_int_scale)) / 2;
			
			// MAx proportionate/ stretch
		} else if (type == 1 || type == 2) {  
			
			// FSinteractive will scale proportionately till one dimension 'maxes out', which is what scale =1,1 means.
		
			// These are the max possible scalings relative to normal size fitting on screen
			// if the gme has these scalings it will max-stretch onto the screen.
			var sx:Float = Capabilities.screenResolutionX / 832.0;
			var sy:Float = Capabilities.screenResolutionY / 512.0;
		
			// automatically centered by the engine.
			var default_fs_px_h:Int = 0;
			var default_fs_px_w:Int = 0;
		
			// If so, then y is maxed out by default
			if (sy <= sx) {
				// Max proportionate
				if (type == 1 ) {
					scaleX = scaleY = 1;
					y = 0;
					x = (Capabilities.screenResolutionX - sy * 832.0) / 2;
				// Max stretch
				} else {
					default_fs_px_h = Std.int(sy * 512.0);
					default_fs_px_w = Std.int(sy * 832.0); // sy not a typo
					var new_sx:Float = Capabilities.screenResolutionX / default_fs_px_w;
					scaleX = new_sx;
					x = 0;
					y = 0;
				}
			} else {
				if (type == 1) {
					scaleX = scaleY = 1;
					x = 0;
					y = (Capabilities.screenResolutionY - sx * 532.0) / 2;
				} else {
				// This is full-stretch sizing 
					default_fs_px_h = Std.int(sx * 512.0);
					default_fs_px_w = Std.int(sx * 832.0); // should be sx
					var new_sy:Float = Capabilities.screenResolutionY/ default_fs_px_h;
					scaleY = new_sy;
					y = 0;
					x = 0;
				}
			}
			//Log.trace([x, y, scaleX, scaleY, fs_dim.x, fs_dim.y, real_width, real_height]);
		}
	}
}
