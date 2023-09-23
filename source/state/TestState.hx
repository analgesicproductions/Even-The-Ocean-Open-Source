package state;

import autom.EMBED_TILEMAP;
import autom.SNDC;
import cpp.vm.Thread;
import entity.npc.GenericNPC;
import entity.player.BubbleSpawner;
import entity.player.Player;
import entity.player.PlayerParticleGroup;
import entity.player.RealPlayer;
import entity.player.Swapper;
import entity.player.Train;
import entity.player.WorldMapPlayer;
import entity.tool.CameraTrigger;
import entity.tool.Door;
import entity.tool.SavePoint;
import entity.ui.AreaMap;
import entity.ui.BlendTest;
import entity.ui.EnterAreaEffect;
import entity.ui.EvenWorldBar;
import entity.ui.LaserGame;
import entity.ui.NameEntry;
import entity.ui.PauseMenu;
import entity.ui.PixelTest;
import entity.ui.TutorialGroup;
import entity.ui.WorldMapUncoverer;
import entity.util.Checkpoint;
import entity.util.NewCamTrig;
import entity.util.TrainTrigger;
import entity.util.WaterSplashEffect;
import flash.geom.Point;
import flixel.FlxCamera;
import flixel.input.FlxInput;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import global.C;
import global.EF;
import global.Registry;
import haxe.io.Bytes;
import haxe.Log;
import haxe.zip.Entry;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import help.InitShortcut;
import help.JankSave;
import help.ParticleSystem;
import help.Track;
import help.WMDrawSprite;
import openfl.Assets;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.addons.tile.FlxTilemapExt;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.util.FlxPath;
import flixel.text.FlxBitmapText;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxSave;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import openfl.display.BlendMode;
import openfl.system.Capabilities;
import sys.FileSystem;
import sys.io.File;
class TestState extends MyState

{
	
	public var mode:Int = 0;
	public static var mod_name:String = ""; 
	private static inline var MODE_PLAY:Int = 0;
	private static inline var MODE_CHANGE_MAP:Int = 1;
	private static inline var MODE_PLAYER_DIED:Int = 2;
	
	private var bg:FlxSprite;
	public var fade_fg_graphic:FlxSprite;
	private var R:Registry;
	
	
	public var player:Player;
	public var swapper:Swapper;
	public var player_particles:PlayerParticleGroup;
	public var train:Train;
	public var realplayer:RealPlayer;
	public var worldmapplayer:WorldMapPlayer;
	public var worldmapuncoverer:WorldMapUncoverer;
	public var is_debug:Bool = false;
	private var death_message:FlxBitmapText;
	public var water_splash:WaterSplashEffect;
	public var insta_d:String = "";
	
	public var camera_debug:FlxSprite;
	public var next_cam_offset:Point;
	public var area_map:AreaMap;
	public var ignore_lerp_reducing:Bool = false;
	
	public var pause_menu:PauseMenu;
	public var particle_system:ParticleSystem;
	public var evenworldbar:EvenWorldBar;
	public var title_text:FlxBitmapText;
	public var gauntlet_text:FlxBitmapText;
	public var eae:EnterAreaEffect;
	private var maps_since_last_entity_hash_update:Array<String>;
	
	
	public var cur_world_mode:Int = 0;
	public var next_world_mode:Int = 0;
	public static inline var WORLD_MODE_DREAM:Int = 0;
	public static inline var WORLD_MODE_REAL:Int = 1;
	public static inline var WORLD_MODE_MAP:Int = 2;
	public var DO_PAUSE_TO_TITLE:Bool = false;
	public var DO_TITLE_TO_PLAY:Bool = false;
	public static var USE_COMPILED_COORDS:Bool = false;
	public static var FORCE_COORDS:String = "";
	private var SKIP_DO_TITLE_TO_PLAY:Bool = false;
	
	private var vert_sway_bg:Bool = false;
	private var vert_sway_ctr:Float = 0;
	
	public function new() {
		super();
	}
	
	// CREATE IS ALWAYS CALLED!!!
	override public function create():Void
	{
		R = Registry.R;
		if (USE_COMPILED_COORDS) {
			//InitShortcut.npcforest(this); // Set world mode and map name
				//InitShortcut.rouge1(this);
				InitShortcut.npccity(this);
				MAP_NAME = "CAMTEST";
				next_player_x = 140;
				next_player_y = 150;
			if (R.MOTION_DEMO_1_ON || R.PAX_CONTEST_2014) {
				InitShortcut.motiondemo1(this);
			}
		} else if (FORCE_COORDS != "") {
			MAP_NAME = FORCE_COORDS.split(",")[0];
			next_player_x = Std.parseInt(FORCE_COORDS.split(",")[1]);
			next_player_y = Std.parseInt(FORCE_COORDS.split(",")[2]);
		} else if (GameState.START_STATE == 1 && !ProjectClass.DEV_MODE_ON) {
			if (JankSave.load_recent(true)) {
				Log.trace("Changing starting map/x/y to recent save b/c NOT starting in dev mode and starting with test state");
				MAP_NAME = R.savepoint_mapName; next_player_x = R.savepoint_X; next_player_y = R.savepoint_Y;	
			}
		}
		R.savepoint_mapName = MAP_NAME;
		R.savepoint_X = next_player_x;
		R.savepoint_Y = next_player_y;
		//FlxG.console.registerObject("R", Registry.R);
		TILESET_NAME = EMBED_TILEMAP.tileset_name_hash.get(MAP_NAME);
		is_editable = true; // You can edit this state with editor
		
		if (GameState.next_state == GameState.STATE_TEST) {
			R.song_helper.fade_to_next_song(MAP_NAME);
		}
		malloc();	
		init_sprites();
		do_add_sprites();
		clean_on_world_transition(); // Set existence states
		
		set_default_camera();
		
		is_debug = true;
		camera_debug = new FlxSprite();
		camera_debug.scrollFactor.set(0, 0);
		redraw_camera_debug();
		camera_debug.visible = false;
		add(camera_debug);
		
		
		//worldmap_effectcam = new FlxCamera(0, 0,FlxG.width, 48,2);
		//FlxG.cameras.add(worldmap_effectcam);
		//worldmap_effectcam.setScale(2, 0.8);
		
	}
	public var worldmap_grp:FlxTypedGroup<WMDrawSprite>;
	private var worldmap_effectcam:FlxCamera;

	private var did_malloc:Bool = false;
	private function malloc():Bool {
		if (did_malloc) return false;
	
		R.TEST_STATE = this;
		pause_menu = new PauseMenu();
		bg = new FlxSprite(0, 0);
		if (R.player == null) {
			player = new Player(next_player_x, next_player_y,cast(this,MyState));
			R.player = player;
			R.player.last.set(next_player_x, next_player_y);
			player_particles = new PlayerParticleGroup();
		}
		if (R.realplayer == null) {
			realplayer = new RealPlayer(next_player_x, next_player_y, cast(this, MyState));
			R.realplayer = realplayer;
		}
		if (R.worldmapplayer == null) {
			worldmapplayer = new WorldMapPlayer(next_player_x, next_player_y, cast(this, MyState));
			R.worldmapplayer = worldmapplayer;
		}
		if (train == null){
			train = new Train(R.train_x, R.train_y, this);
			R.train = train;	
		}
		fade_fg_graphic = new FlxSprite(0, 0);
		fade_fg_graphic.scrollFactor.set(0, 0);
		fade_fg_graphic.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		
		area_map = new AreaMap();
		area_map.turn_off();
		evenworldbar = new EvenWorldBar();
		title_text = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_APPLE_WHITE);
		title_text.alpha = 0;
		death_message = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_APPLE_WHITE);
		water_splash = new WaterSplashEffect(15);
		gauntlet_text = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_APPLE_WHITE);
		
		swapper = new Swapper(this, R);
		eae = new EnterAreaEffect();
		particle_system = new ParticleSystem();
		worldmap_grp = new FlxTypedGroup<WMDrawSprite>();
		
		did_malloc = true;
		return true;
	}
	
	public function turn_on_death_text(on:Bool=true,color:Int=0x000000):Void {
		death_message.text = R.dialogue_manager.lookup_sentence("ui", "death", 0);
		death_message.x = (C.GAME_WIDTH - death_message.width) / 2;
		death_message.y = 40;
		if (on) {
			death_message.visible = true;
		} else {
			death_message.visible = false;
		}
		death_message.color = color;
	}
	private function init_sprites():Void {
		
		load_next_map_data();
		
		player.tm_bg = tm_bg;
		player.tm_bg2 = tm_bg2;
		player.tm_fg = tm_fg;
	}
	
	private function do_add_sprites():Void {
		
		// NEED B_BG_PARALLAX_LAYERS
		add(particle_system);
		add(b_bg_parallax_layers);
		add(particle_system.bg_draw_layer);
		
		add(below_bg_sprites);
		add(bg_parallax_layers);
		add(worldmap_grp);
		add(tm_bg);
		//add(animtiles_bg);
		add(bg1_sprites);
		add(tm_bg2);
		add(bg2_sprites);
		
		//var pixtest:PixelTest = new PixelTest();
		//add(pixtest);
		//
		add(player_particles.bg);
		player.add_pre(cast(this, FlxState));
		add(player);
		//add(swapper);
		player.add(cast(this, FlxState));
		add(water_splash);
		add(player_particles);
		add(train);
		add(realplayer);
		add(worldmapplayer);
		add(worldmapplayer.search_bar);
		add(worldmapplayer.npc_interaction_bubble);
		add(particle_system.bfg_draw_layer);
		add(fg1_parallax_layers);
		
		add(tm_fg);
		add(fg2_sprites);
		add(worldmapplayer.equipped_map);
		add(worldmapplayer.checkmarks);
		add(player.npc_interaction_bubble);
		add(fg2_parallax_layers);
		add(tm_fg2);
		
		
		add(particle_system.fg_draw_layer);
		
		add(gui_sprites);
		
		player.energy_bar.add_to(gui_sprites);
		
		add(evenworldbar); evenworldbar.exists = false;
		add(dialogue_box);
		add(decision_box); decision_box.exists = false;
		add(gauntlet_text); gauntlet_text.visible = false; gauntlet_text.scrollFactor.set(0, 0);
		gauntlet_text.x = FlxG.width - 58; gauntlet_text.y = FlxG.height - 22;
		
		add(area_map);
		
		add(player.energy_bar.death_fade);
		add(player.death_anim);
		//add(death_message);
		add(eae);
		//
		//var blend_Test:BlendTest = new BlendTest();
		//add(blend_Test);
		
		
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}
	override public function draw():Void 
	{
		
		
		super.draw();
		
		//if (FlxG.keys.justPressed.S) {
			//tm_bg2._tileObjects[25].blend = BlendMode.SCREEN;
		//}
	
		//if (FlxG.camera.angle < 90) {
			//FlxG.camera.angle++;
		//}
		//if (FlxG.camera.height < 416) {
			//FlxG.camera.height ++;
		//}	
		//if (R.player.angle > -90) {
			//R.player.angle --;
		//}
		// Update moving backgrounds
		for (bg_group in [bg_parallax_layers,b_bg_parallax_layers,fg2_parallax_layers]) {
		for (i in 0...bg_group.length) {
			var s:FlxSprite = cast bg_group.members[i];
			if (s != null) {
				if (s.velocity.x > 0) {
					if (s.x - FlxG.camera.x*s.scrollFactor.x > 0) {
						s.x = -s.width / 2;
					}
				} else if (s.velocity.x < 0) {
					if (s.x - FlxG.camera.x*s.scrollFactor.x < -s.width / 2) {
						s.x = 0;
					}
				} 
				if (s.velocity.y > 0) {
					if (s.y > 0) {
						s.y = -s.height / 2;
					}
				} else if (s.velocity.y < 0) {
					if (s.y < -s.height / 2) {
						s.y = 0;
					}
				} 
			}
		}
		}
	}

	private var expand_tilemaps_to_hide_tearing_mode:Int = 0;
	public static var expand_tilemaps_change:Bool = false;
	public static var expand_tilemaps_duration:Float = 0;
	
	public function expand_tilemaps(d:Float):Void {
		expand_tilemaps_to_hide_tearing_mode = 1;
		expand_tilemaps_duration = d;
	}
	public var turn_on_tutorial:Bool = false;
	private var tutorial_mode:Int = 0;
	
	private var camera_x_state:Int = 0;
	private var camera_y_state:Int = 0;
	override public function update(elapsed: Float):Void
	{
		
		//if (FlxG.keys.justPressed.Q) {
			//R.credits_module.activate();
			//add(R.credits_module);
		//}
		
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SPACE && FlxG.keys.justPressed.C) {
			R.sound_manager.play(SNDC.clam_3);
			var debugstr:String = "";
			debugstr = MAP_NAME+" " + Std.string(Std.int(R.player.x)) + "," + Std.string(Std.int(R.player.y)) + " " + Std.string(FlxG.drawFramerate) + " FPS\n" + Std.string(Capabilities.os);
			FlxG.log.clear();
			FlxG.log.add(debugstr);
			FlxG.log.add("Please give the above info + detailed OS number with your bug report.\nClose debugger with SHIFT+\\");
			FlxG.debugger.visible = true;
		}
		
		if (R.QA_TOOLS_ON) {
			if (ProjectClass.DEV_MODE_ON && FlxG.keys.myJustPressed("W") && R.editor.editor_active==false) {
				if (area_map.is_visible()) {
					area_map.turn_off();
				} else {
					area_map.turn_on(this);
				}
			}
			if (!R.editor.editor_active) {
				if (FlxG.keys.myPressed("TWO")) {
					R.player.energy_bar.add_light(2);
				} else if (FlxG.keys.myPressed("ONE")) {
					R.player.energy_bar.add_dark(2);
				}
			}
		}
		
		if (ProjectClass.DEV_MODE_ON) {
			if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.Q) {
				var tttttid:String = "";
				var extracut:String = "";
				#if mac
				extracut = "../../../";
				#end
				if (FileSystem.exists(extracut+"../../../../txt/.melos")) {
					tttttid = StringTools.rtrim(File.getContent(extracut+"../../../../assets/script/cutscene/easy/S_TEST_ID").split("\n")[0]);
				} else {
					tttttid = StringTools.rtrim(File.getContent(extracut+"../../../../assets/script/cutscene/easy/J_TEST_ID").split("\n")[0]);
				}
				Log.trace(tttttid);
				
				if (FlxG.keys.pressed.R) {
					R.easycutscene.activate(tttttid, this,true,true);
				} else {
					R.easycutscene.activate(tttttid, this,false,true);
				}
				
				
			} else if (FlxG.keys.pressed.SPACE && FlxG.keys.justPressed.Q) {
				if (R.editor.editor_active == false) {
					Log.trace("working");
					R.editor.editor_active = true;
					HF.get_program_from_script_wrapper("cutscene/easy/j_cutscene.hx");
					R.editor.editor_active = false;
					var gnpc:GenericNPC = new GenericNPC(0, 0, this);
					var genp:Map < String, Dynamic> = gnpc.getDefaultProps();
					genp.set("id", "scripttester");
					genp.set("always_scripted", 1);
					gnpc.set_properties(genp);
					gnpc.update(elapsed);
				}
			}
			if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.H) {
				R.access_opts[9] = !R.access_opts[9];
				HelpTilemap.difficulty_tiles_on(this);
			}
		
		
			
			
			if (ProjectClass.DEV_MODE_ON && FlxG.keys.pressed.ONE && FlxG.keys.pressed.TWO && FlxG.keys.justPressed.SPACE) {
				if (R.warpModule.is_idle()) {
					add(R.warpModule);
					R.warpModule.init();
					R.warpModule.activate(false);
				} else if (R.warpModule.is_done()) {
					R.warpModule.deactivate();
					remove(R.warpModule, true);
				}
			}
		}
		//if (FlxG.keys.pressed.ONE && FlxG.keys.justPressed.SPACE) {
			//for (i in 0...bg2_sprites.members.length) {
				//Log.trace(Std.string(i) + Type.getClassName(Type.getClass(bg2_sprites.members[i])));
			//}
		//}

		
		
		if (turn_on_tutorial) {
			if (tutorial_mode == 0) {
				tutorial_mode = 1;
				add (R.tutorial_group);
				R.tutorial_group.start(dialogue_box);// requested tut is set in genericnpc or elsehwere
				remove(dialogue_box, true);
				add(dialogue_box);
			} else if (tutorial_mode == 1) {
				R.tutorial_group.update(elapsed);
				dialogue_box.update(elapsed);
				if (R.tutorial_group.is_done()) {
					tutorial_mode = 0;
					turn_on_tutorial = false;
					remove(R.tutorial_group, true);
				}
			}
			return;
		}
		
		//Log.trace(FlxG.camera.target);
		//Log.trace(FlxG.camera.deadzone);
		//Log.trace(FlxG.camera.scroll);
		//Log.trace(FlxG.camera._scrollTarget);
		/* Camera Logic for jumping on wall/dealing with Camera Triggers affecting this */
		if (cur_world_mode == WORLD_MODE_DREAM) {
			//Log.trace([FlxG.camera.followLerp, camera_y_state, FlxG.camera.only_lerp_y,FlxG.camera.scroll.y, FlxG.camera._scrollTarget.y,ignore_lerp_reducing]);
			if (camera_y_state == 0) {
				var b:Bool = FlxG.camera._scrollTarget.y < 0 || FlxG.camera._scrollTarget.y + FlxG.height > tm_bg.height;
				// i guess bc scrolltarget can stay dif ffrom scroll even w/ newcamtrigs...
				if (NewCamTrig.active_cam != null) {
					b = b || (FlxG.camera._scrollTarget.y + 256 > NewCamTrig.active_cam.y + NewCamTrig.active_cam.trigger_h || FlxG.camera._scrollTarget.y < NewCamTrig.active_cam.y);
				}
				if ((b || Math.abs(FlxG.camera.scroll.y - FlxG.camera._scrollTarget.y) < 4) && FlxG.camera.followLerp == 12) {
					ignore_lerp_reducing = false;
					FlxG.camera.only_lerp_y = false;
					FlxG.camera.followLerp = 8;
				}
				if (FlxG.camera.followLerp > 12) {
					ignore_lerp_reducing = false;
				}
				
				//Log.trace(FlxG.camera.followLerp);
				
				if (player.is_in_wall_mode() && FlxG.camera.followLerp <= 1) {
					camera_y_state = 1;
					//Log.trace("To camera y_state 1");
					FlxG.camera.only_lerp_y = true;
					ignore_lerp_reducing = true;
					FlxG.camera.followLerp = 30;
					truly_set_default_cam(tm_bg.width, tm_bg.height, "wall_climb");
					redraw_camera_debug();
				} 
				
				/* Used to go to falling-off-cliff mode, is broken */
				//else if (FlxG.camera.followLerp == 0 && R.player.velocity.y > 150) {
					//camera_y_state = 2;
					//FlxG.camera.only_lerp_y = true;
					//ignore_lerp_reducing = true;
					//FlxG.camera.followLerp = 8;
					//truly_set_default_cam(tm_bg.width, tm_bg.height, "wall_climb");
				//}
				
			} else if (camera_y_state == 1) {
				
				//var b:Bool = Math.abs(R.player.velocity.y) > 200;
				if (R.player.velocity.y > 200 && R.player.touching == FlxObject.NONE) {
					ignore_lerp_reducing = false;
					FlxG.camera.followLerp = 4;
				} else {
					ignore_lerp_reducing = true;
					FlxG.camera.followLerp = 30;
				}
				
				//if ((Math.abs(FlxG.camera.scroll.y - FlxG.camera._scrollTarget.y ) < 4 && FlxG.camera.followLerp == 30)) {
				if (Math.abs(FlxG.camera.scroll.y - FlxG.camera._scrollTarget.y ) < 4 && R.player.velocity.y < -50) {
					//ignore_lerp_reducing = false;
					ignore_lerp_reducing = true;
					FlxG.camera.followLerp = 30;
				}
				//Log.trace(FlxG.camera.followLerp);
	
				if (player.wasTouching & FlxObject.DOWN != 0) {
					camera_y_state = 0;
						//Log.trace("To camera y_state 0");
					//FlxG.camera.followLerp = 12;
						//if (FlxG.keys.pressed.SHIFT) {
						//FlxG.camera.followLerp = 25;	
					//} else {
						FlxG.camera.followLerp = 12;	
					//}
					ignore_lerp_reducing = true;
					truly_set_default_cam(tm_bg.width, tm_bg.height, "");
					redraw_camera_debug();
					// problem wi player walk?
				}
			} else if (camera_y_state == 2) {
				if (player.wasTouching & FlxObject.DOWN != 0) {
					camera_y_state = 0;
					//if (FlxG.keys.pressed.SHIFT) {
						//FlxG.camera.followLerp = 15;	
					//} else {
						FlxG.camera.followLerp = 25;	
					//}
					ignore_lerp_reducing = true;
					
					truly_set_default_cam(tm_bg.width, tm_bg.height, "");
					
					redraw_camera_debug();
				} 
			}
		}
	

		if (expand_tilemaps_to_hide_tearing_mode == 1) {
			expand_tilemaps_duration -= FlxG.elapsed;
 			if (expand_tilemaps_duration<= 0) {
				expand_tilemaps_to_hide_tearing_mode = 0;
			}
		} else {
			if (expand_tilemaps_change) {
				expand_tilemaps_to_hide_tearing_mode = 1;
				expand_tilemaps_change = false;
			}
		}
		
		anim_tile_engine.update(elapsed);
		
		// Don't update anything when the game is PAUSED
		if (R.save_module.is_idle() == false) {
			R.save_module.update(elapsed);
			// might need to pause anims too?
			return;
		}
		
		if (do_title_from_credits) {
			fade_fg_graphic.alpha += 0.008;
			if (fade_fg_graphic.alpha  == 1) {
				R.song_helper.permanent_song_name = "";
				//R.song_helper.fade_to_next_song("_title", 1);
				GameState.go_to_title();
				// This is set to true in the ending when fading in before humus talks
				SKIP_DO_TITLE_TO_PLAY = false;
				do_title_from_credits = false;
			}
			return;
		}
		
		// Update pause menu
		if (pause_menu.is_idle() == false) {
			pause_menu.update(elapsed);
			
			// Called 2nd
			if (DO_PAUSE_TO_TITLE) {
				if (R.input.jpCONFIRM) {
					fade_fg_graphic.alpha = 1;
				}
				fade_fg_graphic.alpha += 0.008;
				if (fade_fg_graphic.alpha == 1) {
					pause_menu.deactivate(this);
					GameState.go_to_title();
					DO_PAUSE_TO_TITLE = false;
				}
				return;
			}
			if (pause_menu.is_ready_to_exit()) {
				pause_menu.deactivate(this);
			} else if (pause_menu.is_ready_to_exit_to_title()) {
				DO_PAUSE_TO_TITLE = true;
				SKIP_DO_TITLE_TO_PLAY = false; //unset this bc it's always set when using fade-in cutscene trigger... uh... yeah lol
				go_to_title();
			}
			return;
		}
		
		
		if (DO_TITLE_TO_PLAY) {
			if (fade_fg_graphic.alpha == 1) {
				super.update(elapsed);
			}
			//basicall only called in fayrouge wakeup
			if (skip_fade_darken) {
				skip_fade_darken = false;
				DO_TITLE_TO_PLAY = false;
				return;
			}
			if (SKIP_DO_TITLE_TO_PLAY && !R.editor.editor_active) {
				DO_TITLE_TO_PLAY = SKIP_DO_TITLE_TO_PLAY = false;
			}
			fade_fg_graphic.alpha -= 0.02;
			if (fade_fg_graphic.alpha == 0) {
				remove(fade_fg_graphic, true);
				DO_TITLE_TO_PLAY = false;
			}
			if (fade_fg_graphic.alpha <= 0.9) {
				super.update(elapsed);
			} 
			return;
		}
		if (DO_CHANGE_MAP) {
			DO_CHANGE_MAP = false;
			if (fade_fg_graphic.color == 0x000000) {
				fade_fg_graphic.alpha = 0;
			}	
			mode_change_ctr = 0;				

			add(fade_fg_graphic);
			R.song_helper.fade_to_next_song(next_map_name);
			mode = MODE_CHANGE_MAP;
			if (R.worldmapplayer.exists) {
				
			//Log.trace("toggle");
				R.worldmapplayer.pause_toggle(true);
				train.pause_toggle(true);
			} 
			R.realplayer.pause_toggle(true);
		}
		if (DO_PLAYER_DIED) {
			DO_PLAYER_DIED = false;
			mode = MODE_PLAYER_DIED;
		}
		
		cutscene_update_signals();
		
		switch (mode) {
			case MODE_CHANGE_MAP:
				update_mode_change();
				super.update(elapsed);
				return;
			case MODE_PLAYER_DIED:
				update_mode_player_died();
				super.update(elapsed);
				return;
			case MODE_PLAY:
				update_mode_play();
				
		}
		// Game looks like shit with camera LERP (Except when refocusing)
		//Log.trace([FlxG.camera.followLerp, ignore_lerp_reducing]);
		if (FlxG.camera.followLerp > 0 && !ignore_lerp_reducing) {
			expand_tilemaps_change = true;
			expand_tilemaps_duration = 0.5;
			FlxG.camera.followLerp --;
		}
		
		super.update(elapsed);
		
		if (record_mode == 0) {
			if (false && FlxG.keys.myJustPressed("R")) {
				if (record_info == null) {
					record_info = new Array<Array<Int>>(); //x,y,frame
				}
				record_info = [[], [], [], [Std.int(R.player.x)], [Std.int(R.player.y)]];
				record_mode = 1;
				//Log.trace(1);
			}
		} else if (record_mode == 1) {
			record_info[0].push(Std.int(R.player.x) - record_info[3][0]);
			record_info[1].push(Std.int(R.player.y) - record_info[4][0]);
			record_info[2].push(R.player.animation.getFrameIndex(R.player.frame));
			if (FlxG.keys.myJustPressed("R")) {
				record_mode = 0;
				
				//Log.trace(2);
				var _s:String = "";
				for (j in 0...3) {
					for (i in 0...record_info[0].length) {
						_s += Std.string(record_info[j][i]);
						if (i != record_info[0].length - 1) {
							_s += ",";
						}
					}
					if (j != 2) _s += "\n";
				}
				File.saveContent(C.EXT_NONCRYPTASSETS+"record", _s);
			}
		}
		
		if (vert_sway_bg) {
			vert_sway_ctr += 60.0 * FlxG.elapsed;
			if (vert_sway_ctr > 359) vert_sway_ctr = 0;
			var s:FlxSprite = cast bg_parallax_layers.members[0];
			s.y = -14 + FlxX.sin_table[Std.int(vert_sway_ctr)] * 14.0;
		}
	}	
	private var is_recording:Bool = false;
	private var record_mode:Int = 0;
	private var record_info:Array<Array<Int>>;
	
	public function init_title_to_play():Void {
		add(fade_fg_graphic);
		fade_fg_graphic.alpha = 1;
		DO_TITLE_TO_PLAY = true;
	}
	/**
	 * Called from GameState right before the TestState is removed.
	 */
	public function finish_play_to_title():Void {
		remove(fade_fg_graphic, true);
		
	}
	private var t_camera_pan:Float = 0;
	private var tm_camera_pan:Float = 0.2;
	
	private function update_mode_play():Void {
	
		
		if (dialogue_box.is_active() == false && R.activePlayer != R.worldmapplayer) {
			
			var allow_panning:Bool = false;
			if (R.player == R.activePlayer) {
				if (R.player.is_on_the_ground()) {
					allow_panning = true;
				}
			} else {
				allow_panning = true;
			}
			
			//if (R.gauntlet_manager.tick()) {
				//gauntlet_text.text = R.gauntlet_manager.get_time_text();
				//if (R.speed_opts[3]) gauntlet_text.visible = true;
			//} else {
				//gauntlet_text.visible = false;
			//}
			
			//if (allow_panning) {
				//if (R.input.up && !R.input.left && !R.input.right && !R.input.a1) {
					//t_camera_pan += FlxG.elapsed;
					//if (t_camera_pan > tm_camera_pan) {
						//FlxG.camera._scrollTarget.y -= 1;
					//}
				//} else if (R.input.down && !R.input.left && !R.input.right && !R.input.a1) {
					//t_camera_pan += FlxG.elapsed;
					//if (t_camera_pan > tm_camera_pan) {
						//FlxG.camera._scrollTarget.y += 1;
					//}
				//} else {
					//t_camera_pan = 0;
				//}
			//}
			
		}
		
		//if (cur_world_mode == WORLD_MODE_MAP && !R.train.is_even_map()) {
			//if (R.input.jpCANCEL) {
				//if (worldmapuncoverer.rect_cover.visible) {
					//worldmapuncoverer.make_invisible();
				//} else {
					//worldmapuncoverer.make_visible();
				//}
			//}
		//}
		
		if (!R.editor.editor_active) {
			/**
			 * You can't pause if:
				 * An on-screen cutscene is running
				 * An alternate-map invisible player cutscene is running
				 * Dialogue is occuring
				 * The player is dying.
			 */
			if (R.input.jpPause && !dialogue_box.IS_SCREEN_AREA && !SavePoint.overlapping_savept && R.name_entry.is_done() && !player.is_in_cutscene() && !R.there_is_a_cutscene_running && !cuts_p_invis_on &&  dialogue_box.is_active() == false && R.player.is_dying() == false && !R.player.is_sitting()) {
				R.sound_manager.play(SNDC.menu_open);
				pause_menu.activate(this);
			}
		}	
		
		if (is_dialogue_panning) {
			if (dialogue_panning_mode == 0 ) {
				FlxG.camera.follow(null);
				dialogue_panning_mode = 1;
			} else if (dialogue_panning_mode == 1) {
				
				if (dia_pan_cam_move()) {
					dialogue_panning_t -= FlxG.elapsed;
					if (R.speed_opts[0]) {
						dialogue_panning_t -= 3*FlxG.elapsed;
					}
					if (dialogue_panning_t < 0) {
						if (di_pan_dontret) {
							if (di_pan_wait_for_return_signal) {
								di_pan_waiting_for_return_signal = true;
							} else {
								di_pan_dontret = false;
								is_dialogue_panning = false;
							}
						} else {
							dialogue_panning_mode = 2;
							// switch dirs, switch vel and go back
							dialogue_pan_destx = dpox;
							dialogue_pan_desty = dpoy;
							dialogue_vel.x *= -1;
							dialogue_vel.y *= -1;
						}
					}
				} 
			} else if (dialogue_panning_mode == 2) {
				if (dia_pan_cam_move()) {
					set_default_camera();
					is_dialogue_panning = false;
				}
			}
		}
	}
	
	public function dia_pan_cam_move():Bool {
		var xdone:Bool = false;
		var ydone:Bool = false;
		if (FlxG.camera.scroll.y == dialogue_pan_desty) {
			ydone = true;
		} else {
			FlxG.camera.scroll.y += dialogue_vel.y / 60.0;
			if (R.speed_opts[0]) FlxG.camera.scroll.y += 6*dialogue_vel.y / 60.0;
		}
		
		if (FlxG.camera.scroll.x == dialogue_pan_destx) {
			xdone = true;
		} else {
			FlxG.camera.scroll.x += dialogue_vel.x / 60.0;
			if (R.speed_opts[0]) FlxG.camera.scroll.x += 6*dialogue_vel.x / 60.0;
		}
		
		if (dialogue_vel.x > 0) {
			if (FlxG.camera.scroll.x > dialogue_pan_destx) {
				FlxG.camera.scroll.x = dialogue_pan_destx;
			}
		} else if (dialogue_vel.x < 0) {
			if (FlxG.camera.scroll.x < dialogue_pan_destx) {
				FlxG.camera.scroll.x = dialogue_pan_destx;
			}
		} 
		
		if (dialogue_vel.y > 0) {
			if (FlxG.camera.scroll.y > dialogue_pan_desty ) {
				FlxG.camera.scroll.y = dialogue_pan_desty;
			}
		} else if (dialogue_vel.y < 0) {
			if (FlxG.camera.scroll.y < dialogue_pan_desty ) {
				FlxG.camera.scroll.y = dialogue_pan_desty;
			}
		} 
		if (ydone && xdone) {
			return true;
		}
		return false;
	}
	// if onlymove = true, only moves the camera
	public function set_panning(id:Int, t:Float, vi:Float, vo:Float,onlymove:Bool=false):Void {
		dialogue_panning_t = t;
		dialogue_panning_id_vel_in = vi;
		dialogue_panning_id_vel_out = vo;
		dialogue_vel = new FlxPoint(0, 0);
		
		for (tt in TrainTrigger.ACTIVE_TrainTriggers) {
			if (tt.props.get("id") == id) {
				dialogue_pan_destx = tt.x - tt.width / 2;
				dialogue_pan_desty = tt.y - tt.height / 2;
			}
		}
		
		
		dpox = FlxG.camera.scroll.x;
		dpoy = FlxG.camera.scroll.y;
		
		// Bound destination to the possible scroll of the camera region
		if (dialogue_pan_destx < 0) {
			dialogue_pan_destx = 0;
		} else if (dialogue_pan_destx > tm_bg.width - FlxG.camera.width) {
			dialogue_pan_destx = tm_bg.width - FlxG.camera.width;
		}
		if (dialogue_pan_desty < 0) {
			dialogue_pan_desty = 0;
		} else if (dialogue_pan_desty > tm_bg.height - FlxG.camera.height) {
			dialogue_pan_desty = tm_bg.height - FlxG.camera.height;
		}
		
		// Exit early if onlymove
		if (onlymove) {
			FlxG.camera.follow(null);
			FlxG.camera.scroll.x = FlxG.camera._scrollTarget.x = dialogue_pan_destx;
			FlxG.camera.scroll.y = FlxG.camera._scrollTarget.y = dialogue_pan_desty;
			return;
		}
		
		HF.scale_velocity(dialogue_vel, new FlxObject(FlxG.camera.scroll.x, FlxG.camera.scroll.y, 1, 1), new FlxObject(dialogue_pan_destx, dialogue_pan_desty, 1, 1), vi);
		is_dialogue_panning = true;
		dialogue_panning_mode = 0;
	}
	public var is_dialogue_panning:Bool = false;
	public static var di_pan_dontret:Bool = false;
	public static var di_pan_wait_for_return_signal:Bool = false;
	public static var di_pan_waiting_for_return_signal:Bool = false;
	public static var dialogue_panning_t:Float = 0;
	public static var dialogue_panning_id_vel_in:Float = 0;
	public static var dialogue_panning_id_vel_out:Float = 0;
	public static var dialogue_pan_destx:Float = 0;
	public static var dialogue_pan_desty:Float = 0; 
	public static var dialogue_vel:FlxPoint;
	public static var dpox:Float = 0;
	public static var dpoy:Float = 0;
	private var dialogue_panning_mode:Int = 0;
	/**
	 * Resets position to last save point, resets energy bar,
	 * loads entity data on disk,
	 * etc. if dream-player dies.
	 */
	
	public static var noSaveLoadOnDeath:Bool = false;
	private var do_reset_energy_bar_on_next_map_load:Bool = false;
	private function update_mode_player_died():Void {
		// Post stuff. 
		// playtime carries over deaths
		// Load previous data
		var nr_deaths:Int = R.nr_deaths + 1;
		var save_time:Int = R.playtime;
		var save_even_time:Int = R.even_playtime;
		if (!noSaveLoadOnDeath) {
			JankSave.load_recent(true, true); // Don't load config
		} else {
			Log.trace("Not loading save from disk b/c nosaveloadondeath=true");
		}
		R.playtime = save_time;
		R.even_playtime = save_even_time;
		R.nr_deaths = nr_deaths;
		
		next_player_x = R.savepoint_X;
		next_player_y = R.savepoint_Y;
		next_map_name = R.savepoint_mapName;
		R.inventory.uncache_state();
		if (JankSave.force_checkpoint_things) {
			next_player_x = Checkpoint.tempx;
			next_player_y = Checkpoint.tempy;
			next_map_name = Checkpoint.tempmap;
		}
		
		do_reset_energy_bar_on_next_map_load = true;
		mode = MODE_PLAY;
		DO_CHANGE_MAP = true;
	}
	
	
	/**
	 * The update loop for transitioning maps.
	 * Change player position, load new map data,
	 * and do transition effects here.
	 */
	
	/**
	 * If set to true, then the player won't appear in the next map and you can't pause the game
	 * use with GNPC
	 */
	public var cuts_p_invis_on:Bool = false;
	public var cpix:Float = 0;
	public var cpiy:Float = 0;
	public var mode_change_DO_INSTANT:Bool = false;
	public var mode_change_save_cur_map_ent:Bool = false;
	public var mode_change_ctr:Int = 0;
	public var skip_fade_darken:Bool = false;
	public var skip_fade_lighten:Bool = false;
	private function update_mode_change():Void {
		
		if (mode_change_DO_INSTANT) {
			mode_change_ctr = 1;
		}
		
		switch (mode_change_ctr) {
			case 0:
				vert_sway_bg = false;
				if (R.sound_manager.allow_fade_all) R.sound_manager.fade_all = true;
				if (R.input.jpCONFIRM || R.speed_opts[1]) {
					fade_fg_graphic.alpha = 1;
				}
				fade_fg_graphic.alpha += 0.02;
				if (R.editor.editor_active) fade_fg_graphic.alpha = 1;
				if (fade_fg_graphic.alpha >= 1) {
					if (R.easycutscene.ping_last) { // Means that the easycutscene faded to black, then blocked while an event switches maps
						R.easycutscene.update(FlxG.elapsed);
					}
					mode_change_ctr = 1;
				}
			case 1:
				// This ode runs once per map change
				
				if (R.player.energy_bar.wait_for_death_to_finish) {
					R.player.energy_bar.reset_after_death();
				}
				
				mode_change_ctr = 2;
				fade_fg_graphic.ID = 1; // to undo controller btns
				
				if (R.player.is_dying() == false && mode_change_save_cur_map_ent) {
					HF.save_map_entities(MAP_NAME, this, true);	
					mode_change_save_cur_map_ent = false;
				}
				
				/* If we are leaving an Aliph World map, save its mini-map string */
				//if (worldmapuncoverer != null) {
					//worldmapuncoverer.temp_save_save_string(MAP_NAME);
				//}
				
				prev_map_name = MAP_NAME;
				MAP_NAME = next_map_name;
				if (next_map_name == "OLD_ENTER") {
					R.achv.unlock(R.achv.findPostgame);
				}
				TILESET_NAME = EMBED_TILEMAP.tileset_name_hash.get(MAP_NAME);
				Door.NEXT_AUTO_INDEX = 0;
				// Get new entities blah etc
				
				// Called in screen areas
				if (R.player.energy_bar.OFF) {
					R.player.energy_bar.OFF = false;
					R.player.energy_bar.toggle_bar(false, true);
				}
				dialogue_box.IS_SCREEN_AREA = false;
				
				if (R.sound_manager.allow_fade_all) R.sound_manager.stop_all();
				R.sound_manager.allow_fade_all = true; // This is only set to false in the tran script for the cross-map trian sound
				
				FlxInput.nopresses = true;
				load_next_map_data(true);
				if (R.input.a2 && FlxG.gamepads.lastActive != null) {
					//R.player.joybug_shield = true;
				}
				R.sound_manager.tickssincemapchange = 0;
				// Update area map
				if (R.access_opts[16]) {
					area_map.turn_on(this);
				} else if (area_map.is_visible()) {
					area_map.turn_off();
				}
				
				R.editor.invishard_coords_initialized = false;
				is_dialogue_panning = false;
				R.sound_manager.set_wall_floor(MAP_NAME);
				
				if (Door.USE_AUTO) {
					Door.USE_AUTO = false;
					var door_infos:Array<Array<String>> = HF.get_entity_query(MAP_NAME, ["Door", "x", "y", "AUTO_INDEX","type"]);
					for (door_info in door_infos) {
						if (Std.parseInt(door_info[2]) == Door.INDEX_FOR_USE_AUTO) {
							//Log.trace("Found auto door...");
							next_player_x = Std.parseInt(door_info[0]);
							next_player_y = Std.parseInt(door_info[1]);
							next_player_x += Door.AUTO_X_OFF;
							if (Door.AUTO_X_OFF > 0) {
								R.player.facing = FlxObject.RIGHT;
							} else {
								R.player.facing = FlxObject.LEFT;
							}
							if (Door.NEXT_SNAP_TO_BOTTOM && Std.parseInt(door_info[3]) == 2) {
								next_player_y += 256;
								next_player_y -= Std.int(R.player.height - 1);
							} else {
								//Log.trace([next_player_x, next_player_y, Door.AUTO_X_OFF, Door.AUTO_Y_OFF]);
								next_player_y += Door.AUTO_Y_OFF;
							}
							
							Door.NEXT_SNAP_TO_BOTTOM = false;
							break;
						}
					}
				}
				
				// This Fixes bizarre collision bug
				clean_on_world_transition();
				if (!cuts_p_invis_on) {
					R.player.x = R.activePlayer.last.x = next_player_x;
					R.player.y = R.activePlayer.last.y = next_player_y;
				}
				
				if (next_cam_offset != null) {
					FlxG.camera._scrollTarget.x = R.player.x + R.player.width / 2;
					FlxG.camera._scrollTarget.y = R.player.y + R.player.height / 2;
					FlxG.camera._scrollTarget.x -= FlxG.camera.width / 2;
					FlxG.camera._scrollTarget.y -= FlxG.camera.height / 2;
					FlxG.camera._scrollTarget.x += next_cam_offset.x;
					FlxG.camera._scrollTarget.y += next_cam_offset.y;
					next_cam_offset.x = next_cam_offset.y = 0;
				}
				
				if (mode_change_DO_INSTANT) {
					mode = MODE_PLAY;
					FlxInput.nopresses = false;
					mode_change_DO_INSTANT = false;
				}
				
				if (R.player.exists) {
					R.player.enter_main_state("teststate");
					R.player.npc_interaction_off = true; // So the shield bug doesn' happe lol
				}
				
				if (cuts_p_invis_on) {
					R.player.my_set_exists(false);
					FlxG.camera.follow(null);
					FlxG.camera._scrollTarget.x = cpix;
					FlxG.camera._scrollTarget.y = cpiy;
					FlxG.camera.scroll.x = cpix;
					FlxG.camera.scroll.y = cpiy;
					//Log.trace("hi");
				}
				FlxG.camera.scroll.x = FlxG.camera._scrollTarget.x;
				FlxG.camera.scroll.y = FlxG.camera._scrollTarget.y;
				FlxG.camera.followLerp = 0;
				
				if (R.editor.editor_active) {
					HelpTilemap.difficulty_tiles_on(cast this, true);
				}
				
				if (R.easycutscene.ping_last) {
					R.easycutscene.ping_last = false;
					FlxG.camera.scroll.y = FlxG.camera._scrollTarget.y = R.activePlayer.y - .66 * C.GAME_HEIGHT;
					FlxG.camera.scroll.x = FlxG.camera._scrollTarget.x = R.activePlayer.x - .4 * C.GAME_WIDTH;
				}
				
			// wait for bitmap thread to be done
			// note: doesnt ever run (skipped bc couldnt get to work)
			case 10:
				if (bg_thread_done) {
					bg_thread_done = false;
					b_bg_parallax_layers.exists = b_bg_parallax_layers.visible = true;
					bg_parallax_layers.exists = bg_parallax_layers.visible = true;
					fg1_parallax_layers.exists = fg1_parallax_layers.visible = true;
					fg2_parallax_layers.exists = fg2_parallax_layers.visible = true;
					worldmap_grp.exists = worldmap_grp.visible = true;
					
					mode_change_ctr = 2;
				}
			case 2:
				
				if (fade_fg_graphic.ID == 1) {
					FlxInput.nopresses = false;
					fade_fg_graphic.ID = 0;
				}
				
				if (!skip_fade_lighten) {
					//if (R.input.jpCONFIRM || R.speed_opts[1]) {
					if (R.speed_opts[1] || (R.input.jpCONFIRM && ProjectClass.DEV_MODE_ON)) {
						fade_fg_graphic.alpha = 0;
					}
				}
				fade_fg_graphic.alpha -= 0.02;
				if (R.editor.editor_active) fade_fg_graphic.alpha = 0;
				if (fade_fg_graphic.alpha == 0 || skip_fade_lighten ) {
					// Restore control when we finish fading itn
					if (R.editor != null && R.editor.editor_active) {
						FlxG.camera.follow(null);
					}
					mode = MODE_PLAY;
					Track.add_load_map(MAP_NAME, R.player.x, R.player.y);
					
					
					
						
					// Reset the fade's color to black if it was changed in a script UNLESS we are skkipping the fade lighten
					if (fade_fg_graphic.color != 0x000000 && !skip_fade_lighten) {
						fade_fg_graphic.makeGraphic(C.GAME_WIDTH, C.GAME_HEIGHT, 0xff000000);
					}	
					
					// Starst a dialogue right away if signaled
					if (insta_d != null && insta_d.length > 3) {
						var a:Array<String> = insta_d.split(",");
						dialogue_box.start_dialogue(a[0], a[1], Std.parseInt(a[2]));
						insta_d = " ";
					}
				}
		}
		
		if (mode == MODE_PLAY && !skip_fade_lighten ) {
			remove(fade_fg_graphic, true);
		} else if (mode == MODE_PLAY) {
			skip_fade_lighten = false;
		}
	}
	
	/**
	 * Load the next maps' CSV data, then its tileset, then set the tile bindings, then loads the
	 * entities
	 */
	private function load_next_map_data(thread_bgs:Bool=false):Void 
	{
		if (EMBED_TILEMAP.entity_hash.exists(MAP_NAME) == false) {
			Log.trace("Warning, no map \"" + MAP_NAME + "\"");
			MAP_NAME = "TEST";
		}
		HelpTilemap.set_map_csv(MAP_NAME, [tm_bg, tm_bg2, tm_fg, tm_fg2]);
		
		
			tm_bg.visible = tm_bg2.visible = tm_fg.visible = tm_fg2.visible = true;
		if (MAP_NAME == "MAP1" || MAP_NAME == "MAP2" || MAP_NAME == "MAP3" ) {
			Log.trace("tiles off by default in MAP1");
			tm_bg.visible = tm_bg2.visible = tm_fg.visible = tm_fg2.visible = false;
		}
		
		HelpTilemap.set_map_props(TILESET_NAME, cast(this, MyState));
		HelpTilemap.load_animtiles(TILESET_NAME, cast(this, MyState));
		HelpTilemap.difficulty_tiles_on(this);
		HF.load_map_entities(MAP_NAME, this);
		
		load_bgs();
		bg_thread_done = true;
		particle_system.load_system(MAP_NAME);
	}
	
	private var bg_thread_done:Bool = false;
	public function load_bgs():Void {
		var prlx_set_name:String = EMBED_TILEMAP.map_prlx_hash.get(MAP_NAME);
		
		// all this alt city bgs only after finishing i2
		if (R.event_state[EF.radio_depths_done] == 1) {
			if (prlx_set_name == "SET_WFLO_1") { 
				// after I2
				if (Registry.R.dialogue_manager.get_scene_state_var("ending", "outside_wf", 1) == 0) {
					prlx_set_name = "SET_DAMAGED_WFLO_1"; // Needs to change to alt with no dark bg.
				// ending
				} else {
					prlx_set_name = "SET_SUNSET_WFLO_1";
				}
			}
			if (prlx_set_name == "SET_WFLO_0") { 
				// During i2
				if (Registry.R.dialogue_manager.get_scene_state_var("ending", "outside_wf", 1) == 0) {
					prlx_set_name = "SET_DAMAGED_WFLO_0";  // Need to change to not dark bg
				} else {
					prlx_set_name = "SET_RAIN_WFLO_0"; 
				}
			}
			// DIfferent patio BG after i2
			if (prlx_set_name == "SET_WFHI_3") {
				prlx_set_name = "SET_DAMAGED_WFHI_3"; // This is okay
			}
			if (prlx_set_name == "SET_WFHI_1") { 
				// Beat radio, before ending.
				if (Registry.R.event_state[EF.radio_tower_done] == 1 && Registry.R.dialogue_manager.get_scene_state_var("ending", "init_yara", 1) == 0) {
					prlx_set_name = "SET_SUNSET_WFHI_1";
				// During I2 
				} else if (Registry.R.dialogue_manager.get_scene_state_var("ending", "outside_wf", 1) == 0) {
					prlx_set_name = "SET_DAMAGED_WFHI_1"; // NEEDS TO NOT BE DARK
				// After returning from WF but before beating radio (Mayor gun scene - raining)
				} else {
					prlx_set_name = "SET_RAIN_WFHI_1";
				}
			}
			
			// NEED DARK BG FOR CEMETARY
		}
		// Change map1
		if (R.event_state[EF.air_done] == 1) {
			if (prlx_set_name == "SET_CAMTEST") { 
				// Change MAP1 and MAP3 to flood, if during flood scene (after that first yara talk,b efore credits)
				if (Registry.R.dialogue_manager.get_scene_state_var("ending", "init_yara", 1) == 1 && Registry.R.event_state[EF.credits_watched] == 0) {
					prlx_set_name = "SET_ALT_CAMTEST_FLOOD";
				} else {
					prlx_set_name = "SET_ALT_CAMTEST";
				}
			}
			if (prlx_set_name == "SET_MAP_NORTHMAP") { 
				if (Registry.R.dialogue_manager.get_scene_state_var("ending", "init_yara", 1) == 1 && Registry.R.event_state[EF.credits_watched] == 0) {
					prlx_set_name = "SET_MAP_NORTHMAP_FLOOD";
				}
			}
		}
		
		var b_bg_prlx_set:Array<String> = []; // The list of BG ids - test2,test_anim, etc
		var bg_prlx_set:Array<String> = []; // The list of BG ids - test2,test_anim, etc
		var bg1_prlx_set:Array<String> = []; 
		var fg2_prlx_set:Array<String> = [];
		if (prlx_set_name == "script") {
			// uh TODO
			bg_prlx_set = EMBED_TILEMAP.parallax_set_hash.get("TEST_1")[0];
		} else {
			bg_prlx_set = EMBED_TILEMAP.parallax_set_hash.get(prlx_set_name)[0];
			bg1_prlx_set = EMBED_TILEMAP.parallax_set_hash.get(prlx_set_name)[1];
			b_bg_prlx_set = EMBED_TILEMAP.parallax_set_hash.get(prlx_set_name)[2];
			fg2_prlx_set = EMBED_TILEMAP.parallax_set_hash.get(prlx_set_name)[3];
		}
		
		if (prev_map_name.indexOf("MAP") == 0	) {
			//Log.trace("Don't uncache");
		} else {
			for (layers in [b_bg_parallax_layers,bg_parallax_layers,fg1_parallax_layers,fg2_parallax_layers]) {
				for (i in 0...layers.length) {
					if (layers.members[i] != null) {
						var fs:FlxSprite = cast(layers.members[i], FlxSprite);
						//HF.uncache_bitmap(fs.graphic.bitmap);
						
						// IDK IF WORKS - check MEMORY
						FlxG.bitmap.remove(fs.graphic);
						fs.destroy(); fs = null;
					}
				}
			}
		}
		
		b_bg_parallax_layers.clear();
		bg_parallax_layers.clear();
		fg1_parallax_layers.clear();
		fg2_parallax_layers.clear();
		
		
		update_bg_layers(b_bg_parallax_layers, b_bg_prlx_set);
		update_bg_layers(bg_parallax_layers, bg_prlx_set);
		update_bg_layers(fg1_parallax_layers, bg1_prlx_set);
		update_bg_layers(fg2_parallax_layers, fg2_prlx_set);
		
			
		if (MAP_NAME == "MAP1" || MAP_NAME == "MAP2" || MAP_NAME == "MAP3") {
			//if (fg1_parallax_layers.members[0] != null) {
				//var sss:FlxSprite = cast fg1_parallax_layers.members[0];
				//sss.blend = BlendMode.NORMAL; 
				//sss.blend = BlendMode.ADD;
				//sss.blend = BlendMode.SCREEN; // broken?
				//sss.blend = BlendMode.MULTIPLY; // broken?
				//sss.alpha = 1;
			//}
			var s:WMDrawSprite;
			var chunk_h:Int = 1;
			var sa:Array<String> = [];
			
			var nrparts:Int = 0;
			if (MAP_NAME == "MAP1") {
				//nrparts = 180*16;
				nrparts = 2878;
			} else if (MAP_NAME == "MAP2") {
				nrparts = 2556;
			} else {
				nrparts = 1534;
				
			}
			for (i in 0...nrparts) {
				sa.push(Std.string(i));
			}
			//for (i in 0...Std.int(256/chunk_h)) {
			for (i in 0...1) {
				if (worldmap_grp.length <= i) {
					s = new WMDrawSprite();
				
				} else {
					s = worldmap_grp.members[0];
					//s.destroy();
					//s = new WMDrawSprite();
					//worldmap_grp.members[0] = s;
				}
				
				var layer:FlxSprite = cast bg_parallax_layers.members[0];
				s.myLoadGraphic(layer.graphic.bitmap, true, false, layer.graphic.bitmap.width, chunk_h);
				
				
				for (j in 0...nrparts) {
					s.animation.add(sa[j], [j],0, false);
				}
				s.max_anim_idx = nrparts-1;
				// load something else
				s.scrollFactor.set(1, 0);
				s.x = 0;
				s.y = i * chunk_h;
				// need anims or bad stuff happens
				
				//if (worldmap_grp.length < Std.int(256/chunk_h)) {
				if (worldmap_grp.length < 1) {
					worldmap_grp.add(s);
				}
			}
			worldmap_grp.exists = true;
		}  else {
			worldmap_grp.exists = false;
			if (worldmap_grp.members.length > 0) {
				//HF.uncache_bitmap(worldmap_grp.members[0].graphic.bitmap);
			}
		}
		
		bg_thread_done = true;
	}
	
	private function update_bg_layers(layers:FlxGroup,bg_prlx_set:Array<String>):Void {
		//layers.setAll("exists", false);
		var metadata:Array<String> = [];
		// bg_prlx_set is a list of BG_LIST entries from world.map
		for (i in 0...bg_prlx_set.length) {
			if (bg_prlx_set[i] == "none") break; /* none is a special keyword = no bg*/
			bgColor = 0x00ffffff;
			FlxG.camera.bgColor = 0x00ffffff;
			if (EMBED_TILEMAP.prlx_meta_hash.exists(bg_prlx_set[i]) == false) {
				Log.trace(bg_prlx_set[i] + " is not a valid bg");
				continue;
			}
			metadata = EMBED_TILEMAP.prlx_meta_hash.get(bg_prlx_set[i]).split(",");
			var fs:FlxSprite;
			//if (i < layers.length - 1) { // recycle
				//fs = cast(layers.members[i], FlxSprite);
			//} else { // new
				fs = new FlxSprite();
				layers.add(fs);
			//}
			
			if (MAP_NAME != "MAP1" && MAP_NAME != "MAP2"  && MAP_NAME != "MAP3" ) {
			if (R.access_opts[4] && metadata[0].indexOf("BG") == -1) {
				Log.trace(metadata[0]);
				if (fg1_parallax_layers == layers || fg2_parallax_layers == layers) {
					fs.alpha = 0;
					Log.trace("FG OFF");
				} else {
					
					if (EMBED_TILEMAP.additional_bg_offset_hash.exists(MAP_NAME)) {
						fs.makeGraphic(416, 256, Std.parseInt(EMBED_TILEMAP.additional_bg_offset_hash.get(MAP_NAME)));
					} else {
						fs.makeGraphic(416, 256, 0xff000000);
					}
					fs.scrollFactor.set(0, 0);
				}
				continue;
			}
			}
			// FILENAME [0], width, height, scroll x, scroll y, x, y, velx, vely
			
			//Assets.getBitmapData("assets/sprites/bg/" + words[1] + ".png")
			
			fs.myLoadGraphic(Assets.getBitmapData(EMBED_TILEMAP.direct_bg_hash.get(metadata[0])), false, false, Std.parseInt(metadata[1]), Std.parseInt(metadata[2]));
			fs.scrollFactor.set(Std.parseFloat(metadata[3]), Std.parseFloat(metadata[4]));
			fs.x = Std.parseInt(metadata[5]);
			fs.y = Std.parseInt(metadata[6]);
			// This offsets based on if our camera was capturing at X,Y when we're standing at 0,0 - thus we shift over layers
			//if (EMBED_TILEMAP.additional_bg_offset_hash.exists(MAP_NAME)) {
				//fs.x -= Std.parseInt(EMBED_TILEMAP.additional_bg_offset_hash.get(MAP_NAME).split(",")[0]) * fs.scrollFactor.x;
				//fs.y -= Std.parseInt(EMBED_TILEMAP.additional_bg_offset_hash.get(MAP_NAME).split(",")[1]) * fs.scrollFactor.y;
			//}
			if (metadata.length >= 10) {
				fs.alpha = Std.parseFloat(metadata[9]);
			}
			fs.blend = BlendMode.NORMAL;
			if (metadata.length >= 11) {
				if (Std.parseInt(metadata[10]) == 1) {
					fs.blend = BlendMode.ADD;
				} else if (Std.parseInt(metadata[10]) == 2) {
					fs.blend = BlendMode.MULTIPLY;
				} else if (Std.parseInt(metadata[10]) == 3) {
					fs.blend = BlendMode.SCREEN;
				}
			}
			if (metadata.length >= 12) {
				vert_sway_bg = true;
			}
			fs.velocity.x = fs.velocity.y = 0;
			if (metadata.length > 8) {
				if (metadata.length >= 9) {
					fs.velocity.x = Std.parseInt(metadata[7]);
					fs.velocity.y = Std.parseInt(metadata[8]);
				}
				
				if (fs.velocity.x > 0) {
					fs.x = -fs.width / 2;
				} else if (fs.velocity.x < 0) {
					fs.x = 0;
				}
				if (fs.velocity.y > 0) {
					fs.y = -fs.height / 2;
				} else if (fs.velocity.y < 0) {
					fs.y = 0;
				}
			}
			//if (fs.y == 0) fs.y = -0.25;
			
			if (EMBED_TILEMAP.bg_anim_hash.exists(bg_prlx_set[i])) {
				//Log.trace([ EMBED_TILEMAP.bg_anim_hash.get(bg_prlx_set[i])[1], EMBED_TILEMAP.bg_anim_hash.get(bg_prlx_set[i])[0]]);
				fs.animation.add("a", EMBED_TILEMAP.bg_anim_hash.get(bg_prlx_set[i])[1], EMBED_TILEMAP.bg_anim_hash.get(bg_prlx_set[i])[0]);
				fs.animation.play("a",true);
			} else {
				fs.animation.paused = true;
			}
			fs.exists = true;
		}
	}
	
	/**
	 * Set various existence states of the player/other GUI
	 * elements based on the state
	 */
	private function clean_on_world_transition():Void 
	{
		R.menu_map.load_map(MAP_NAME, cast(this, MyState));
		
		R.is_the_ocean = true;
		if (MAP_NAME.indexOf("REAL") == 0 || MAP_NAME.indexOf("E_") == 0) {
			next_world_mode = WORLD_MODE_REAL;
			R.is_the_ocean = false;
		} else if (MAP_NAME.indexOf("MAP") == 0) {
			next_world_mode = WORLD_MODE_MAP;
			//R.gauntlet_manager.reset_status();
			train.change_vistype(Train.VISTYPE_TRAIN);
		} else if (MAP_NAME.indexOf("EM_") == 0) {
			next_world_mode = WORLD_MODE_MAP;
			R.is_the_ocean = false;
			train.change_vistype(Train.VISTYPE_EVEN_MAP);
		} else if (MAP_NAME.indexOf("ED_") == 0) {
			R.is_the_ocean = false;
			next_world_mode = WORLD_MODE_DREAM;
			player.change_vistype(Player.VISTYPE_real);
			player.set_physics_constants(1);
		} else {
			next_world_mode = WORLD_MODE_DREAM;
			player.change_vistype(Player.VISTYPE_dream);
			player.set_physics_constants(0);
		}
		
		
		player.my_set_exists(false);
		realplayer.exists = false;
		worldmapplayer.exists = false;
		worldmapplayer.set_sprites_exists(false);
		worldmapplayer.set_to_normal();
		evenworldbar.exists = false;
		train.exists = false;
		train.become_inactive();
		if (cur_world_mode == WORLD_MODE_MAP) {
			if (false == train.is_even_map()) {
				R.train_x = Std.int(train.x);
				R.train_y = Std.int(train.y);
				// add lOGIC FOR aliph  TRAIN NOT APPEARING EVERYWHRE?
			}
			train.pause_toggle(false);
			//Log.trace("toggle");
			worldmapplayer.pause_toggle(false);
		}
		realplayer.pause_toggle(false);
		switch (next_world_mode) {
			case WORLD_MODE_DREAM:
				player.my_set_exists(true);
				R.activePlayer = player;
				player.drag.x = 0;
				// If there's a cutscene with Aliph invisibile, don't move the player.
				if (cuts_p_invis_on == false) {
					R.player.x = next_player_x;
					R.player.y = next_player_y;
				}
			case WORLD_MODE_REAL:
				realplayer.exists = true;
				R.activePlayer = realplayer;
				R.realplayer.x = next_player_x;
				R.realplayer.y = next_player_y;
			case WORLD_MODE_MAP:
				R.activePlayer = worldmapplayer;
				worldmapplayer.exists = true;
				worldmapplayer.set_sprites_exists(true);
				worldmapplayer.equipped_map.alpha = 0;
				worldmapplayer.animation.play("idle_d");
				worldmapplayer.facing = FlxObject.DOWN;
				
				
			//Log.trace("toggle");
			worldmapplayer.pause_toggle(false);
				if (train.is_even_map()) {
					train.exists = true;
				}
				R.worldmapplayer.x = R.worldmapplayer.last.x = next_player_x;
				R.worldmapplayer.y = R.worldmapplayer.last.y = next_player_y;
				if (train.is_even_map()) {
					evenworldbar.exists = true;
					evenworldbar.reset_for_entering_worldmap();
					train.move_to(next_player_x, next_player_y);
				} else {
					//train.move_to(R.train_x, R.train_y);
				}
				
				if (train.is_even_map()) {
					worldmapplayer.FORCE_TO_GIVE_CONTROL_TO_TRAIN();
				}
				
		}
		cur_world_mode = next_world_mode;
		set_default_camera();
		FlxG.camera.scroll.x = FlxG.camera._scrollTarget.x;
		FlxG.camera.scroll.y = FlxG.camera._scrollTarget.y;
	}
	
	public function redraw_camera_debug():Void 
	{
		if (camera_debug == null) return;
		if (is_debug) {
			camera_debug.x = FlxG.camera.deadzone.x;
			camera_debug.y = FlxG.camera.deadzone.y;
			camera_debug.make_rect_outline(Math.floor(FlxG.camera.deadzone.width), Math.floor(FlxG.camera.deadzone.height), 0x55ffffff,"camdebug");
		} else {
			camera_debug.visible = false;
		}
	}
	
	public  function set_default_camera(special:String=""):Void 
	{
		if (special == "train") {
			FlxG.camera.follow(train);
		} else if (next_world_mode == WORLD_MODE_DREAM) {
			FlxG.camera.follow(player);
		} else if (next_world_mode == WORLD_MODE_REAL) {
			FlxG.camera.follow(realplayer);
		} else if (next_world_mode == WORLD_MODE_MAP) {
			FlxG.camera.follow(worldmapplayer);
		}
		truly_set_default_cam(tm_bg.width, tm_bg.height,special);
	}
	public var DEFAULT_DEADZONE_HEIGHT:Int = 96+32;
	public static var _DEFAULT_DEADZONE_HEIGHT:Int = 96 + 32;
	public static var citycam_on:Bool = false;
	public static function truly_set_default_cam(w:Float, h:Float, special:String = "" ):Void {
		//Log.trace(special);
		citycam_on = false;
		if (special == "" && (Registry.R.TEST_STATE.MAP_NAME == "WF_HI_1" || Registry.R.TEST_STATE.MAP_NAME == "WF_HI_2")) {
			citycam_on = true;
			//Log.trace("WF_HI special cam");
			var shrink:Int = 48;
			FlxG.camera.deadzone = new FlxRect(180, 80 - 20 + shrink, FlxG.width - 360, _DEFAULT_DEADZONE_HEIGHT - shrink);
			Registry.R.TEST_STATE.redraw_camera_debug();
		} else if (Registry.R.TEST_STATE.cur_world_mode == 2) {
			FlxG.camera.deadzone = new FlxRect(210, 122, 12,12);	
		} else if (Player.armor_on) {
			// broken because of thing with walking i guess in player
			FlxG.camera.deadzone = new FlxRect(180, 80 - 20 + 90, FlxG.width - 360, _DEFAULT_DEADZONE_HEIGHT - 90);
		} else if (special == "launcher") {
			var aa:Int = 100;
			FlxG.camera.deadzone = new FlxRect(208 - aa, 128 - aa, aa * 2, aa * 2);
		} else if (special == "swim") {
			FlxG.camera.deadzone = new FlxRect(180, 90, FlxG.width - 360, FlxG.height - 180);
			FlxG.camera.followLerp = 15;
		} else if (special == "x_extend") {
			FlxG.camera.deadzone = new FlxRect(90, 80, FlxG.width - 180, FlxG.height - 160);
		} else if (special == "wall_climb") {
			//FlxG.camera.deadzone = new FlxRect(180, 48, FlxG.width - 360, 64);
			FlxG.camera.deadzone = new FlxRect(180, FlxG.height /2 - 8, FlxG.width - 360, 16);
		} else {
			//FlxG.camera.deadzone = new FlxRect(180, 80, FlxG.width - 360, FlxG.height - 160);
			FlxG.camera.deadzone = new FlxRect(180, 80-20, FlxG.width - 360, _DEFAULT_DEADZONE_HEIGHT);
		}
		FlxG.camera.setScrollBoundsRect(0, 0, w, h, true);
		
			Registry.R.TEST_STATE.redraw_camera_debug();
		if (NewCamTrig.active_cam != null) {
			FlxG.camera.setScrollBoundsRect(NewCamTrig.active_cam.x, NewCamTrig.active_cam.y, NewCamTrig.active_cam.trigger_w, NewCamTrig.active_cam.trigger_h);
		}
	}
	
	
	
	public function cutscene_handle_signal(sig:Int,args:Array<Dynamic>=null,noskiptitle:Bool=false):Void {
		if (sig == TSC.SIG_FADE_IN_OVERLAY) {
			remove(fade_fg_graphic, true);
			add(fade_fg_graphic);
			remove(dialogue_box, true); add(dialogue_box);
			if (noskiptitle == false) {
				SKIP_DO_TITLE_TO_PLAY = true;
			}
			if (args == null || args[0] <= 0) {
				Log.trace("Bad arg for cutscene signal FADE IN OVERLAY");
				TSC.fade_overlay_rate = 0.01;
			} else {
				TSC.fade_overlay_rate = args[0];
				if (args.length > 1) {
					fade_fg_graphic.makeGraphic(C.GAME_WIDTH, C.GAME_HEIGHT, args[1]);
				}
			}
			TSC.do_fade_in_overlay = true;
		} else if (sig == TSC.SIG_FADE_IN_TITLE_TEXT) {
			remove(title_text, true);
			add(title_text);
			TSC.fade_title_text_rate = args[0];
			title_text.text = args[1];
			title_text.x = (C.GAME_WIDTH - title_text.width) / 2;
			title_text.y = (C.GAME_HEIGHT / 2 - title_text.height) / 2;
			TSC.do_fade_in_title_text = true;
		} else if (sig == TSC.SIG_FADE_OUT_OVERLAY) {
			TSC.fade_overlay_rate = args[0];
			TSC.do_fade_out_overlay = true;
			SKIP_DO_TITLE_TO_PLAY = false;
		} else if (sig == TSC.SIG_FADE_OUT_TITLE_TEXT) {
			TSC.fade_title_text_rate = args[0];
			TSC.do_fade_out_title_text = true;
		} else if (sig == TSC.SIG_CHANGE_COLOR) {
			fade_fg_graphic.makeGraphic(C.GAME_WIDTH, C.GAME_HEIGHT, args[0]);
		}else if (sig == TSC.SIG_DIALOGUE_BOX_ON_TOP) {
			remove(dialogue_box, true);
			add(dialogue_box);
		}
	}
	
	
	private function cutscene_update_signals():Void {
		TSC.reset_just_finished();
		
		if (TSC.do_fade_in_overlay) {
			fade_fg_graphic.alpha += TSC.fade_overlay_rate;
			if (fade_fg_graphic.alpha >= 1) {
				TSC.JF_fade_in_overlay = true;
				TSC.do_fade_in_overlay = false;
			}
		} 
		
		if (TSC.do_fade_in_title_text) {
			title_text.alpha += TSC.fade_title_text_rate;
			if (title_text.alpha >= 1) {
				TSC.JF_fade_in_title_text = true;
				TSC.do_fade_in_title_text = false;
			}
		}
		
		if (TSC.do_fade_out_overlay) {
			fade_fg_graphic.alpha -= TSC.fade_overlay_rate;
			if (fade_fg_graphic.alpha <= 0) {
				TSC.JF_fade_out_overlay = true;
				TSC.do_fade_out_overlay = false;
			}
		}
		
		if (TSC.do_fade_out_title_text) {
			title_text.alpha -= TSC.fade_title_text_rate;
			if (title_text.alpha <= 0) {
				TSC.JF_fade_out_title_text = true;
				TSC.do_fade_out_title_text = false;
			}
		}
	}
	public function cutscene_just_finished(sig:Int):Bool {
		if (sig == TSC.SIG_FADE_IN_OVERLAY) {
			return TSC.JF_fade_in_overlay;
		} else if (sig == TSC.SIG_FADE_IN_TITLE_TEXT) {
			return TSC.JF_fade_in_title_text;
		} else if (sig == TSC.SIG_FADE_OUT_OVERLAY) {
			if (TSC.JF_fade_out_overlay) {
				remove(fade_fg_graphic, true);
			}
			return TSC.JF_fade_out_overlay;
		} else if (sig == TSC.SIG_FADE_OUT_TITLE_TEXT) {
			return TSC.JF_fade_out_title_text;
		}
		return false;
	}
	
	private var twitch_target_sprite:FlxSprite;
	private var twitch_text:FlxBitmapText;
	private var twitch_text_bg:FlxSprite;
	private var twitch_log:Array<String>;
	private function handle_twitch_helper():Void {
		if (twitch_target_sprite == null) {
			twitch_target_sprite = new FlxSprite();
			twitch_target_sprite.makeGraphic(16, 16, 0x88994433);
			add(twitch_target_sprite);
			
			twitch_text = HF.init_bitmap_font(" ", "left", 0, 0, C.FONT_TYPE_APPLE_WHITE);
			
			twitch_text_bg = new FlxSprite();
			twitch_text_bg.makeGraphic(130, 130, 0x88000000);
			add(twitch_text_bg);
			twitch_text_bg.scrollFactor.set(0, 0);
			
			add(twitch_text);
			
			twitch_log = [];
		}
		var aa:Array<String> = ProjectClass.twitch_helper.get_queue();
		var a:FlxSprite = twitch_target_sprite;
		while (aa.length > 0) {
			
			var cmds:String = aa.splice(0, 1)[0];	
			var nick:String = cmds.split(" ")[0];
			var cmd:String = cmds.split(" ")[1];
			
			
			if (twitch_log.length > 10) {
				twitch_log.splice(0, 1);
				twitch_log.push(nick + " " + cmd);
			} else {
				twitch_log.push(nick + " " + cmd);
			}
			
			
			if (cmd == "u") {
				a.y -= 16;
			} else if (cmd == "r") {
				a.x += 16;
			}else if (cmd == "d") {
				a.y += 16;
			}else if (cmd == "l") {
				a.x -= 16;
			}else if (cmd == "x") {
				var tx:Int = Std.int(a.x / 16);
				var ty:Int = Std.int(a.y / 16);
				if (tm_bg.getTile(tx, ty) == 0) {
					tm_bg.setTile(tx, ty, 11, true);
				} else {
					tm_bg.setTile(tx, ty, 0, true);
				}
			}
			if (a.x < 0) a.x = 0;
			if (a.x >= tm_bg.widthInTiles * 16) a.x = tm_bg.widthInTiles * 16 - 16;
			if (a.y < 0) a.y = 0;
			if (a.y >= tm_bg.heightInTiles * 16) a.y = tm_bg.heightInTiles * 16 - 16;
			
		}
		twitch_text.text = twitch_log.join("\n");
		ProjectClass.twitch_helper.clear_queue();
	}
	
	function undobuttons():Void 
	{
		if (FlxG.gamepads.lastActive != null) {
			var button:FlxGamepadButton = null;
			
			var rawleftID:Int = FlxG.gamepads.lastActive.mapping.getRawID(FlxGamepadInputID.DPAD_LEFT);
			var rawrightID:Int = FlxG.gamepads.lastActive.mapping.getRawID(FlxGamepadInputID.DPAD_RIGHT);
			
			for (i in 0...FlxG.gamepads.lastActive.buttons.length) {
				button = FlxG.gamepads.lastActive.buttons[i];
				if (button != null) {
					if (button.ID == rawleftID || button.ID == rawrightID) {
						continue;
					}
					//button.release();
				}
			}
		}
	}
	
	public var do_title_from_credits :Bool = false;
	public function go_to_title():Void 
	{
		R.song_helper.permanent_song_name = "";
		//R.song_helper.fade_to_next_song("_title", 1);
		add(fade_fg_graphic);
		fade_fg_graphic.alpha = 0;
		player.energy_bar.status = 0;
		player.energy_bar.set_energy(128);
		player.energy_bar.death_fade.alpha = 0;
		player.energy_bar.player_shade_timer = 0;
	}
	

}
