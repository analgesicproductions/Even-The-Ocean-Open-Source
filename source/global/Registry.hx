package global;
import autom.EMBED_TILEMAP;
import entity.enemy.AimSpore;
import entity.enemy.BallDropper;
import entity.enemy.Dasher;
import entity.enemy.ExtendStem;
import entity.enemy.GhostLight;
import entity.enemy.Hopper;
import entity.enemy.ShockFloat;
import entity.enemy.SmashHand;
import entity.enemy.SpikeExtend;
import entity.enemy.SquishyChaser;
import entity.enemy.WalkPod;
import entity.npc.Cauliflower;
import entity.npc.Mole;
import entity.npc.MoleTile;
import entity.player.BubbleSpawner;
import entity.player.Player;
import entity.player.RealPlayer;
import entity.player.Train;
import entity.player.WorldMapPlayer;
import entity.tool.LightBox;
import entity.trap.BarbedWire;
import entity.trap.FlameBlower;
import entity.trap.Floater;
import entity.trap.FollowLaser;
import entity.trap.HurtOutlet;
import entity.trap.MiniMoveBlock;
import entity.trap.MirrorLaser;
import entity.trap.Pew;
import entity.trap.Pod;
import entity.trap.RubberLaser;
import entity.trap.SapPad;
import entity.trap.Spike;
import entity.trap.WaterCharger;
import entity.trap.Weed;
import entity.ui.ActScreen;
import entity.ui.EasyCutscene;
import entity.ui.InfoPage;
import entity.ui.Inventory;
import entity.ui.MenuMap;
import entity.ui.NameEntry;
import entity.ui.PauseMenu;
import entity.ui.TutorialGroup;
import entity.ui.WorldMapUncoverer;
import entity.util.OrbSlot;
import entity.util.PlantBlockAccepter;
import entity.util.RaiseWall;
import entity.util.SinkPlatform;
import entity.util.TrainTrigger;
import entity.util.VanishBlock;
import entity.util.WalkBlock;
import flixel.FlxSprite;
import haxe.Log;
import help.AchievementModule;
import help.CreditsModule;
import help.DialogueManager;
import help.Editor;
import help.EventHelper;
import help.HF;
import help.InputHandler;
import help.Journal;
import help.JoyModule;
import help.SaveModule;
import help.SongHelper;
import help.SoundManager;
import help.WarpModule;
import openfl.Assets;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import state.GameState;
import state.TestState;
import state.TitleState;
#if cpp
import sys.io.File;
#end

/**
 * ...
 * @author Melos Han-Tani
 */
class Registry 

{

	public function new() 
	{
		
	}
	public static var R:Registry;
	public static var did_init:Bool = false;
	// Global references
	public var player:Player;
	public var realplayer:RealPlayer;
	public var worldmapplayer:WorldMapPlayer;
	public var activePlayer:FlxSprite; 
	public var train:Train; // Deprecated name, for even world map
	public var input:InputHandler; 
	public var editor:Editor;
	public var TEST_STATE:TestState;
	public var TITLE_STATE:TitleState;
	public var song_helper:SongHelper;
	public var save_module:SaveModule;
	public var sound_manager:SoundManager;
	public var dialogue_manager:DialogueManager;
	public var inventory:Inventory;
	public var menu_map:MenuMap;
	public var tutorial_group:TutorialGroup;
	public var name_entry:NameEntry;
	public var joy_module:JoyModule;
	public var credits_module:CreditsModule;
	public var gnpc:Map<String,Dynamic>;
	public var journal:Journal;
	public var infopage:InfoPage;
	public var actscreen:ActScreen;
	public var easycutscene:EasyCutscene;
	public var warpModule:WarpModule;
	public var achv:AchievementModule;
	
	// Global state
	public var story_mode:Bool = false;
	public var gauntlet_mode:Bool = false;
	public var there_is_a_cutscene_running:Bool = false;
	public var PAX_PRIME_DEMO_ON:Bool = false;
	public var MOTION_DEMO_1_ON:Bool = false;
	public var PAX_CONTEST_2014:Bool = false;
	public var TGS2015:Bool = false;
	public var QA_TOOLS_ON:Bool = false;
	public var PREVIEW_BUILD_ON:Bool = false;
	public var NEW_GAME_COORDS:String = "";
	public var PLAYER_NAME:String = "Player";
	public var is_the_ocean:Bool = true;
	public var speed_opts:Array<Bool>; //Fast Text, Screen Transitions, Death Anim, autosave off
	public var access_opts:Array<Bool>; //Fast Text, Screen Transitions, Death Anim, Gauntlet Display
	public var nr_saves:Int;
	public var nr_deaths:Int;
	public var savepoint_X:Int = 0;
	public var savepoint_Y:Int = 0;
	public var savepoint_mapName:String = "TEST";
	public var playtime:Int = 0;
	public var even_playtime:Int = 0;
	public var tempx:Int = 0; // Quicksaving
	public var tempy:Int = 0;
	public var tempmap:String = "";
	public var temp_energy:Int = 0;
	public var event_state:Array<Int>;
	public var silo_coords:Map<String,Dynamic>;
	public var x_______1__55:Int = 0;
	public var used_codes:Array<String>;
	public var farthestact:Int = 0;
	public var visitedmuseum:Int = 0;
	public var visitedlibrary:Int = 0;
	public var inwarpmode:Int = 0;
	/**
	 * If ignore_door = true, then all doors you need otinteract with won't do anything. Instead they'll just change attempted_door to whatever their dest_map is - use a script to do whatever at this point.
	 * ignore_door is set to false in the destroy() method of Door entities.
	 */
	public var attempted_door:String = "";
	public var ignore_door:Bool = false;
	//csv of okay doors to use
	public var ok_doors:String = "";
	/**
	 * Global state for GNPC
	 */
	public var gs1:Int = 0; 
	
	
	/* Deprecated I think */
	public var scratch_state:Array<Bool>;
	public var last_worldmap_X:Int = 0; // not used!?
	public var last_worldmap_Y:Int = 0;
	public var last_worldmap_name:String = "MAPONE";
	public var train_x:Int = 0; // not used..?
	public var train_y:Int = 0;
	public var last_aliph_save_x:Int = 0; // not used...?
	public var last_aliph_save_y:Int = 0;
	public var last_aliph_save_map:String = "TEST";
	
	
	
	public static function init():Void {
		if (!did_init) {
			//Log.trace("Hi");
			did_init = true;
			R = new Registry();
			R.reload_build_vars();
			R.scratch_state = [false];
			R.input = new InputHandler();
			R.song_helper = new SongHelper();
			R.menu_map = new MenuMap();
			R.inventory = new Inventory();
			//R. gauntlet_manager = new GauntletManager();
			R.speed_opts = [false, false, false, false,false,false,false,false,false,false];
			R.access_opts = [false, false, false, false, false, false, false, false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]; // 22 atm
			R.event_state = HF.array_init_with(R.event_state, 0, EF.number_of_event_flags);
			R.tutorial_group = new TutorialGroup();
			R.joy_module = new JoyModule();
			R.credits_module = new CreditsModule();
			R.journal = new Journal();
			R.infopage = new InfoPage();
			R.actscreen = new ActScreen();
			R.easycutscene = new EasyCutscene();
			R.warpModule = new WarpModule();
			R.achv = new AchievementModule();
			EventHelper.init();
			
			// Initialize these here because some entities will references this before perhaps any of
			// hte said entities exist
			ShockFloat.ACTIVE_ShockFloats = new List<ShockFloat>();
			Pod.ACTIVE_Pods = new List<Pod>();
			OrbSlot.ACTIVE_OrbSlots = new FlxGroup(0, "ACTIVE_OrbSlots");
			RaiseWall.ACTIVE_RaiseWalls = new FlxTypedGroup<RaiseWall>();
			FollowLaser.ACTIVE_FollowLasers = new FlxTypedGroup<FollowLaser>();
			Pew.ACTIVE_Pews = new FlxTypedGroup<Pew>();
			Spike.ACTIVE_Spikes = new FlxTypedGroup<Spike>();
			Weed.ACTIVE_Weeds = new List<Weed>();
			HurtOutlet.ACTIVE_HurtOutlets = new List<HurtOutlet>();
			SinkPlatform.ACTIVE_SinkPlatforms = new List<SinkPlatform>();
			RubberLaser.ACTIVE_RubberLasers = new List<RubberLaser>();
			SapPad.ACTIVE_REVERSE_SapPads = new List<SapPad>();
			SapPad.ACTIVE_NORMAL_SapPads = new List<SapPad>();
			MoleTile.ACTIVE_MoleTiles = new List<MoleTile>();
			Mole.ACTIVE_Mole = new List<Mole>();
			Cauliflower.ACTIVE_Cauliflowers = new List<Cauliflower>();
			PlantBlockAccepter.ACTIVE_PlantBlockAccepters = new List<PlantBlockAccepter>();
			VanishBlock.ACTIVE_VanishBlocks = new List<VanishBlock>();
			AimSpore.ACTIVE_AimSpores = new List<AimSpore>();
			BallDropper.ACTIVE_BallDroppers = new List<BallDropper>();
			MiniMoveBlock.ACTIVE_MiniMoveBlocks = new List<MiniMoveBlock>();
			Hopper.ACTIVE_Hoppers = new List<Hopper>();
			MirrorLaser.ACTIVE_MirrorLasers = new List<MirrorLaser>();
			SpikeExtend.ACTIVE_SpikeExtends = new List<SpikeExtend>();
			FlameBlower.ACTIVE_FlameBlowers = new List<FlameBlower>();
			WaterCharger.ACTIVE_WaterChargers = new List<WaterCharger>();
			SquishyChaser.ACTIVE_SquishyChasers = new List<SquishyChaser>();
			SmashHand.ACTIVE_SmashHands = new List<SmashHand>();
			TrainTrigger.ACTIVE_TrainTriggers = new List<TrainTrigger>();
			Dasher.ACTIVE_Dashers = new List<Dasher>();
			LightBox.ACTIVE_LightBoxes = new List<LightBox>();
			LightBox.NONSLEEPING_LightBoxes = new List<LightBox>();
			GhostLight.ACTIVE_GhostLights = new List<GhostLight>();
			WalkBlock.ACTIVE_WalkBlocks = new List<WalkBlock>();
			Pod.ACTIVE_PodSwitches = new List<Pod>();
			BarbedWire.ACTIVE_BarbedWires = new List<BarbedWire>();
			Floater.ACTIVE_Floaters = new List<Floater>();
			WalkPod.ACTIVE_WalkPods = new List<WalkPod>();
			ExtendStem.ACTIVE_ExtendStems = new List<ExtendStem>();
		}
	}
	
	public function reset_global_state():Void {
		Log.trace("Resetting Global State");
		R.story_mode = false;
		R.gauntlet_mode = false;
		R.worldmapplayer.equipped_map_id = -1;
		playtime = 0;
		R.train_x = 0;
		R.train_y = 0;
		R.dialogue_manager.skip_updating_with_sss = true;
		R.TEST_STATE.train.x = R.train_x;
		R.TEST_STATE.train.y = R.train_y;
		R.song_helper.set_volume_modifier(1);
		R.sound_manager.set_volume_modifier(1);
		x_______1__55 = 0;
		used_codes = new Array<String>();
		EMBED_TILEMAP.init(false);
		R.inventory.reset();
		WorldMapUncoverer.reset_strings();
		// Start over silo_rects
		reload_silo_data(false);
		R.access_opts[12] = false;
		R.access_opts[16] = false;
		
		R.event_state = HF.array_init_with(R.event_state, 0, EF.number_of_event_flags);
	}
	
	public function reload_silo_data(from_dev:Bool = false):Void {
		R.silo_coords = new Map<String,Dynamic>();
		var s:String = "";
		if (from_dev) {
			s = File.getContent(C.EXT_ASSETS + "sprites/bg/map/silo_rects.txt");
		} else {
			s = Assets.getText("assets/sprites/bg/map/silo_rects.txt");
		}
		
		
		if (EMBED_TILEMAP.csv_hash.exists("MAP2" + "_BG") == false) {
			EMBED_TILEMAP.get_csv_from_disk("MAP2");
		}
		
		if (EMBED_TILEMAP.csv_hash.exists("MAP3" + "_BG") == false) {
			EMBED_TILEMAP.get_csv_from_disk("MAP3");
		}
		
		var son:Map<String,Dynamic> = HF.parse_SON(s).get("data");
		//var cutout_w:Int = Std.parseInt(son.get("rand_map_size").split(" ")[0]);
		//var cutout_h:Int = Std.parseInt(son.get("rand_map_size").split(" ")[1]);
		var cutout_w:Int = 80;
		var cutout_h:Int = 80;
		
		var map2_bg2:String = EMBED_TILEMAP.csv_hash.get("MAP2_BG2");
		// 5 for organic (Air, map3) , 73 for sand (Sea map3 and earth map2)
		
		var xs:Array<Int> = [];
		var ys:Array<Int> = [];
		var rows:Array<String> = map2_bg2.split("\n");
		var tilevals:Array<String> = [];
		for (_y in 0...rows.length) {
			tilevals = rows[_y].split(",");
			for (_x in 0...tilevals.length) {
				if ("73" == tilevals[_x]) {
					xs.push(_x);
					ys.push(_y);
				}
			}
		}
		var r_idx:Int = Std.int(Math.random() * xs.length);
		
		if (xs.length == 0) {
			xs.push(50); ys.push(90);
		}
		
		var toff:Int = 8 - Std.int(cutout_w / 2); // Offset from the tile coord to where the bitmap should be cut
		
		
		get_silo_bitmap(16 * xs[r_idx] + toff, 16 * ys[r_idx] + toff, cutout_w, cutout_h, "earth_");
		
		var map3_bg2:String = EMBED_TILEMAP.csv_hash.get("MAP3_BG2");
		rows = map3_bg2.split("\n");
		tilevals = [];
		for (i in 0...2) {
			xs = [];
			ys = [];
			for (_y in 0...rows.length) {
				tilevals = rows[_y].split(",");
				for (_x in 0...tilevals.length) {
					if (i == 0 && "2" == tilevals[_x]) {  // organic, air
						xs.push(_x);
						ys.push(_y);
					} else if (i == 1 && "73" == tilevals[_x]) {
						xs.push(_x);
						ys.push(_y);
					}
				}
			}
			var r_idx:Int = Std.int(Math.random() * xs.length);
			if (xs.length == 0) {
				if (i == 1) {
					xs.push(24); ys.push(37);
				} else {
					xs.push(37); ys.push(56);
				}
			}
			if (i == 0) {
				get_silo_bitmap(16 * xs[r_idx] + toff, 16 * ys[r_idx] + toff, cutout_w, cutout_h, "air_");
			} else if (i == 1) {
				get_silo_bitmap(16 * xs[r_idx] + toff, 16 * ys[r_idx] + toff, cutout_w, cutout_h, "sea_");
			}
		}
		
		//Log.trace(R.silo_coords.get("earth_door_pt"));
		//Log.trace(R.silo_coords.get("earth_save_pt"));
		//Log.trace(R.silo_coords.get("air_door_pt"));
		//Log.trace(R.silo_coords.get("air_save_pt"));
		//Log.trace(R.silo_coords.get("sea_door_pt"));
		//Log.trace(R.silo_coords.get("sea_save_pt"));
		
	}
	
	//called from loading to initialize the bitmaps and door pts
	public function get_silo_bitmap(cutout_x:Int, cutout_y:Int, cutout_w:Int, cutout_h:Int, prefix:String):Void {
		var full_map:BitmapData;
		if (prefix == "earth_") {
			full_map= Assets.getBitmapData("assets/sprites/bg/map/southmap.png");
		} else {
			full_map= Assets.getBitmapData("assets/sprites/bg/map/northmap.png");
		}
		var frame:BitmapData = Assets.getBitmapData("assets/sprites/npc/map/frame.png");
		var frame_margin:Int = Std.int((frame.width - cutout_w) / 2);
		
		var map_bitmap:BitmapData = new BitmapData(cutout_w+2*frame_margin, cutout_h+2*frame_margin,true,0x00ffffff);
		map_bitmap.copyPixels(full_map, new Rectangle(cutout_x, cutout_y, cutout_w, cutout_h), new Point(frame_margin, frame_margin));
		map_bitmap.copyPixels(frame, new Rectangle(0, 0, frame.width, frame.height), new Point(0, 0), frame, new Point(0, 0));
		
		R.silo_coords.set(prefix + "bitmap", map_bitmap);
		
		// Thsi si used when showing the bitmap in the menu, and when positioning the doors in the silo script.
		R.silo_coords.set(prefix + "door_pt", new Point(cutout_x, cutout_y));
		
		// This is used as the top-left of the cutout generated when loading a game.
		R.silo_coords.set(prefix + "save_pt", new Point(cutout_x, cutout_y));
	}
	
	public function get_silo_bitmap_in_menu(item:Int):BitmapData {
		var s:String = "";
		
		var prefix:String = "";
		var cutout_w:Int = 80;
		var cutout_h:Int = 80;
		var frame:BitmapData = Assets.getBitmapData("assets/sprites/npc/map/frame.png");
		var frame_margin:Int = Std.int((frame.width - cutout_w) / 2);
		var cutout:BitmapData = new BitmapData(cutout_w+2*frame_margin, 2*frame_margin+cutout_h,true,0x00ffffff);
		var full_map:BitmapData;
		if (item == 19) {
			full_map =  Assets.getBitmapData("assets/sprites/bg/map/southmap.png");
		} else {
			full_map =  Assets.getBitmapData("assets/sprites/bg/map/northmap.png");
		}
		switch (item) {
			case 19: // earth
				prefix = "earth_";
			case 20: // air
				prefix = "air_";
			case 21: // sea
				prefix = "sea_";
		}
		
		var cutout_x:Float = 0;
		var cutout_y:Float = 0;
		
		
		
		var p:Point = cast R.silo_coords.get(prefix + "door_pt");
		cutout_x = p.x;
		cutout_y = p.y;
		cutout.copyPixels(full_map, new Rectangle(cutout_x, cutout_y, cutout_w, cutout_h), new Point(frame_margin, frame_margin));
		cutout.copyPixels(frame, new Rectangle(0, 0, frame.width, frame.height), new Point(0, 0), frame, new Point(0, 0),true);
		
		return cutout;
	}
	
	public function reload_build_vars(from_dev:Bool = false):Void {
		var son:Map<String,Dynamic> = null;
		if (from_dev) {
			#if cpp
			son = HF.parse_SON(File.getContent(C.EXT_ASSETS + "misc/build_vars.son")).get("state");
			#end
			#if !cpp
			son = HF.parse_SON(Assets.getText("assets/misc/build_vars.son")).get("state");
			#end
		} else {
			son = HF.parse_SON(Assets.getText("assets/misc/build_vars.son")).get("state");
		}
		//R.PAX_PRIME_DEMO_ON = son.get("PAX_PRIME_DEMO_ON") == 1;
		//R.MOTION_DEMO_1_ON = son.get("DEMO_1_ON") == 1;
		//R.PAX_CONTEST_2014 = son.get("PAX_CONTEST_2014") == 1;
		R.NEW_GAME_COORDS = son.get("NEW_GAME_COORDS");
		R.TGS2015 = son.get("TGS2015");
		R.QA_TOOLS_ON = son.get("QA_TOOLS") == 1;
		
		if (R.TGS2015) {
			Log.trace("TGS2015 on");
		}
		ProjectClass.DEV_MODE_ON = son.get("DEV_MODE_ON") == 1;
		
		GameState.RELEASE_MODE = son.get("RELEASE_MODE");
		TestState.USE_COMPILED_COORDS = son.get("USE_COMPILED_COORDS") == 1;
		TestState.FORCE_COORDS = son.get("FORCE_COORDS");
		GameState.START_STATE = son.get("START_STATE");
		R.PREVIEW_BUILD_ON = son.get("PREVIEW_BUILD_ON") == 1;
		if (R.PREVIEW_BUILD_ON) {
			Log.trace("Press prevew on!");
			TitleState.version = "Press Preview, " + TitleState.version;
		}
		GameState.EDITOR_IS_TOGGLEABLE = son.get("EDITOR_IS_TOGGLEABLE") == 1;
		PauseMenu.NO_EXIT_TO_TITLE = son.get("NO_EXIT_TO_TITLE") == 1;
		BubbleSpawner.BUBBLE_DEBUG_MESSAGES_ON = son.get("BUBBLE_DEBUG") == 1;
		TestState.noSaveLoadOnDeath = son.get("noSaveLoadOnDeath") == 1;
		if (TestState.noSaveLoadOnDeath == true) Log.trace("noSaveLoadOnDeath on");
	}
	
	public function set_flag(i:Int, val:Dynamic=1):Void {
		EF.set_flag(i, event_state, val);
	}
	
	public function set_flag_bitwise(i:Int, val:Int, unset:Bool = false):Void {
		Log.trace("Bitwise event " + Std.string(i) + " set to " + Std.string(val));
		EF.set_flag(i, event_state, event_state[i] | val);
	}
	public function get_event_state_save_string():String {
		var s:String = "";
		for (i in 0...event_state.length) {
			s += Std.string(event_state[i]);
			if (i != event_state.length - 1) {
				s += ",";
			}
		}
		Log.trace("Event State:\n"+s);
		return s;
	}
	public function load_event_state_save_string(s:String):Void {
		var a:Array<String>= s.split(",");
		for (i in 0...event_state.length) {
			EF.set_flag(i, event_state,Std.parseInt(a[i]),true);
		}
		Log.trace("Read event state: " + event_state.toString());
		return;
	}
	public function toggle_players_pause(on:Bool = false):Void {
		player.pause_toggle(on);
		worldmapplayer.pause_toggle(on);
		realplayer.pause_toggle(on);
		train.pause_toggle(on);
	}
	
	// called from oceanbucks
	public function init_bucks():Void {
		if (x_______1__55 == 0) {
			x_______1__55 = 5;
		}
	}
	
	public function add_bucks(code:String):Int {
		Log.trace("trying to add " + code);
		
		// ignore duplicates
		if (used_codes == null) used_codes = new Array<String>();
		if (used_codes.indexOf(code) != -1) {
			return -1;
		}
		if (code == "t") {
			x_______1__55 += 10;
			used_codes.push(code);
			return 1;
		} 
		
		// convert code to number
		var n:Int = 0;
		var do_add:Int = 0;
		if (code.charAt(0) == "a") {
			do_add = 10; 
		}
		
		// check valid
		if (n == 2) {
			do_add = 10;
		}
		
		// update
		if (do_add > 0) {
			Log.trace("added " + Std.string(do_add) + " with " + code);
			x_______1__55 += do_add;
			used_codes.push(code);
			return 1;
		}
		
		return -1;
	}
	//x_______1__55
}