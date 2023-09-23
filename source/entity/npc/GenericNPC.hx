package entity.npc;
import entity.MySprite;
import entity.tool.Door;
import entity.ui.LaserGame;
import entity.util.Checkpoint;
import entity.util.PlantBlockAccepter;
import entity.util.VanishBlock;
import entity.util.WMScaleSprite;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flixel.system.FlxSound;
import flixel.text.FlxBitmapText;
import flixel.animation.FlxAnimation;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import global.C;
import global.EF;
import global.Registry;
import haxe.Log;
import help.AnimImporter;
import help.EventHelper;
import help.FlxX;
import help.HF;
import help.JankSave;
import help.Track;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.Assets;
import flash.geom.Point;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import openfl.media.Sound;
import state.MyState;
import state.TestState;
#if cpp
import sys.io.File;
#end

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */class GenericNPC extends MySprite
{
	

	public static var global_npc_lock:Bool = false;
	public static var generic_npc_data:Map<String,Dynamic>;
	public static var entity_spritesheet_data:Map<String,Dynamic>;
	
	private var cur_data:Map<String,Dynamic>;
	
	private var DOES_COLLIDE:Bool = false;
	private var context_values:Array<Int>;
	private var always_scripted:Bool = false;
	private var has_script:Bool = false;
	
	private var expand_px:Int = 0;
	private var nr_ENERGIZE_received:Int;
	private var nr_LIGHT_received:Int;
	private var made_program:Bool = false;
	private var my_interp:Interp;
	private var my_program:Expr;
	private var laser_game:LaserGame;
	
	// script helper
	private var child_init:Bool = false;
	public var sprites:FlxTypedGroup<MySprite>;
	private var bg_sprites:FlxTypedGroup<MySprite>;
	private var fg_sprites:FlxTypedGroup<MySprite>;
	private var state_1:Int = 0;
	private var state_2:Int = 0;
	private var sf1:Float = 0;
	private var s1:Int = 0;
	private var s2:Int = 0;
	private var s3:Int = 0;
	private var t_1:Int = 0;
	private var t_2:Int = 0;
	private var tm_1:Int = 0;
	private var tm_2:Int = 0;
	private var wall_climbable:Bool = false;
	private var wall_mode:Int = 0;
	private var turned_on_bubble:Bool = false;
	public static var sin_table:Array<Float>;
	private var has_trigger:Bool = false;
	private var trigger:FlxSprite;
	private var debug_name:FlxBitmapText;
	private var prevent_shield_lock:Bool = true;
	private var SCRIPT_OFF:Bool = false;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		// Init sprites here
		if (sin_table == null) {
			sin_table = FlxX.sin_table;
		}
		
		sprites = new FlxTypedGroup();
		bg_sprites = new FlxTypedGroup();
		fg_sprites = new FlxTypedGroup();
		fg_sprites.exists = bg_sprites.exists = false;
		debug_name = HF.init_bitmap_font(" ","center",0,0,new FlxPoint(1,1),"english",true);
		debug_name.exists = false;
		super(_x, _y, _parent, "GenericNPC");
		
		// Change visuals or add things here
	}
	
	public static function load_generic_npc_data(from_dev:Bool = false):Void {
		if (from_dev) {
			#if cpp
			generic_npc_data = HF.parse_SON(File.getContent(C.EXT_ASSETS + "misc/generic_npc.son"));
			entity_spritesheet_data = HF.parse_SON(File.getContent(C.EXT_ASSETS + "misc/entity_spritesheets.son"));
			#end
		} else {
			generic_npc_data = HF.parse_SON(Assets.getText("assets/misc/generic_npc.son"));
			entity_spritesheet_data = HF.parse_SON(Assets.getText("assets/misc/entity_spritesheets.son"));
		}
		if (Registry.R != null) {
			Registry.R.gnpc = generic_npc_data;
		}
		
	}
	
	override public function change_visuals():Void 
	{
		cur_data = load_visuals(this, Std.string(props.get("id")));
	}
	
	public static function load_visuals(entity:FlxSprite,GNPC_ID:String):Map<String,Dynamic> {
		var GNPC_data:Map<String,Dynamic> = null;
		GNPC_data = generic_npc_data.get(GNPC_ID);
		if (GNPC_data == null) {
			Log.trace("No generic NPC Data for " + GNPC_ID + ", falling back on \"sign1\"");
			GNPC_data = generic_npc_data.get("sign1");
			Log.trace(GNPC_data);
		}
		
		var bm:BitmapData = null;
		if (GNPC_data.exists("path")) {
			bm = Assets.getBitmapData("assets/sprites/" + GNPC_data.get("path"));
		}
		if (bm == null) {
			if (GNPC_data.exists("path")) Log.trace("Warning! No such spritesheet assets/sprites/" + GNPC_data.get("path"));
			bm = Assets.getBitmapData("assets/sprites/npc/junk/Signpost.png");
			entity.myLoadGraphic(bm, true, false, 16, 32);
			entity.animation.add("idle", [0]);
		} else {
			//Log.trace(GNPC_ID);
			//Log.trace([GNPC_data.get("w"), GNPC_data.get("h")]);
			entity.myLoadGraphic(bm, true, false, GNPC_data.get("w"), GNPC_data.get("h"));
		}
		if (GNPC_data.exists("o")) {
			var a:Array < String >= GNPC_data.get("o").split(",");
			entity.width = Std.parseInt(a[0]);
			entity.height = Std.parseInt(a[1]);
			entity.offset.set(Std.parseInt(a[2]), Std.parseInt(a[3]));
		}
		if (GNPC_data.exists("angular_v")) {
			entity.angularVelocity = GNPC_data.get("angular_v");
		}
		if (GNPC_data.exists("anim_set")) {
			AnimImporter.addAnimations(entity, "GenericNPC", GNPC_data.get("anim_set"));
			if (GNPC_data.exists("start_anim")) {
				entity.animation.play(GNPC_data.get("start_anim"));
			}
		} else {
			entity.frame = GNPC_data.get("start_frame");
		}
		
		return GNPC_data;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		// Set default properties here
		p.set("id", "sign1");
		p.set("has_dialogue", 1);
		p.set("always_scripted", 0);
		p.set("context_int_csv", "0,0");// maybe used
		p.set("children", "");
		p.set("map-scene-pos", "");
		p.set("debug_name", "");
		return p;
	}
	
	public function get_ss(map:String, scene:String, state_id:Int):Int{
		return R.dialogue_manager.get_scene_state_var(map, scene, state_id);	
	}
	public function get_scene_state(map:String, scene:String, state_id:Int):Int{
		return R.dialogue_manager.get_scene_state_var(map, scene, state_id);	
	}
	public function set_scene_state(map:String, scene:String, state_id:Int, val:Int):Void {
		R.dialogue_manager.change_scene_state_var(map, scene, state_id, val);
	}
	public function set_ss(map:String, scene:String, state_id:Int, val:Int):Void {
		R.dialogue_manager.change_scene_state_var(map, scene, state_id, val);
	}
	
	override public function preUpdate():Void 
	{
		if (DOES_COLLIDE) {
			FlxObject.separate(this, parent_state.tm_bg);
			FlxObject.separate(this, parent_state.tm_bg2);
		}
		super.preUpdate();
	}
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		props.set("id", props.get("id").toLowerCase());
	
		if (props.get("always_scripted") == 1) {
			always_scripted = true;
			made_program = false;
		} else {
			always_scripted = false;
		}
		
		context_values = HF.string_to_int_array(props.get("context_int_csv"));
		// Load script
		// Figure out behaviors
		change_visuals();
		has_script = false;
		if (cur_data.exists("script")) {
			has_script = true;
		}
		if (cur_data.exists("map") == false && cur_data.exists("scene") == false) {
			if (props.get("map-scene-pos").length < 3) {
				props.set("has_dialogue", 0);
			}
		}
		if (cur_data.exists("expand")) {
			expand_px = cur_data.get("expand");
		}
		var s:String;
		if (props.get("debug_name").length > 1) {
			debug_name.text = props.get("debug_name");
			if (props.get("has_dialogue") == 2) {
				debug_name.text = debug_name.text.substr(0, 15);
			}
			debug_name.exists = true;
		} else {
			debug_name.exists = false;
		}
		
		noMapDraw = false;
		if (R.TEST_STATE.MAP_NAME == "MAPONE" || R.TEST_STATE.MAP_NAME == "MAPTWO" || R.TEST_STATE.MAP_NAME == "MAPTHREE"  || R.TEST_STATE.MAP_NAME == "MAPFOUR") {
			noMapDraw = true;
		}
	}
	
	override public function destroy():Void 
	{
		if (laser_game != null) {
			laser_game.destroy();
			R.TEST_STATE.remove(laser_game, true);
		}
		if (try_to_talk_lock_sprite != null) {
			try_to_talk_lock_sprite = null;
		}
		if (parent_state.dialogue_box.external_speaker_entity == this) {
			parent_state.dialogue_box.external_speaker_entity = null;
		}
		if (trigger != null) {
			HF.remove_list_from_mysprite_layer(this, parent_state, [trigger]);
		}
		HF.remove_list_from_mysprite_layer(this, parent_state, [sprites, bg_sprites, debug_name]);
		HF.remove_list_from_mysprite_layer(this, parent_state, [fg_sprites], MyState.ENT_LAYER_IDX_FG2);
		
		if (loopsound != null) {
			if (loopsound.playing) loopsound.stop();
			loopsound.destroy();
			loopsound = null;
		}
		if (loopsound2 != null) {
			if (loopsound2.playing) loopsound2.stop();
			loopsound2.destroy();
			loopsound2 = null;
		}
		super.destroy();
	}
	
	private var recent_recv_msg:String = "";
	override public function recv_message(message_type:String):Int 
	{
		var storymodeskip:Bool = false;
		if (message_type == "RESTORE_PLANTBLOCK" && R.story_mode) {
			var a:Array<String> = ["ROUGE_B", "SHORE_B", "CANYON_B", "HILL_B", "BASIN_B", "WOODS_B", "RIVER_B", "PASS_B", "CLIFF_B", "RADIO_B", "FALLS_B","RADIO_B"];
			if (HF.array_contains(a, R.TEST_STATE.MAP_NAME)) {
				storymodeskip = true;
			}
		}
		/* This works by having a plantblockaccepter send a message to the parent gnpc ("GNPC geid")
		 * Then the GNPC updates a dialogue state using bitwise flags.
		 * Then if you save the game, this state gets saved.
		 * So if you die, then the GNPC will call "RESTORE PLANTBLOCK" on itself, which
		 * turns on its parent if it's a plantblockaccepter and if its flag is set.
		 * The flag is reset later at the end of a boss room sequence in the script. */
		if (message_type == "RESTORE_PLANTBLOCK") {
			var oldflag:Int = get_ss("test", "gstate", 1);
			//Log.trace("Restoring plantblocks..."+Std.string(oldflag));
			for (i in 0...parents.length) {
				//Log.trace("...");
				if (oldflag & (1 << i) > 0 || storymodeskip) {
					if (Std.is(parents[i],PlantBlockAccepter)) {
						//Log.trace("Restored " + Std.string(i));
						var pb:PlantBlockAccepter = cast parents[i];
						pb.activate(0, true, true, false);
					}
					
				}
			}
			return -1;
		}
		if (message_type.indexOf(" ") != -1) {
			// Received when a plantblock is accepted.
			if (message_type.split(" ")[0] == "GNPC") {
				//Log.trace(message_type);
				var gggg:Int = Std.parseInt(message_type.split(" ")[1]);
				// Find the index fo the parent with this. set the corresponding bitmap  to test/gstate
				for (i in 0...parents.length) {
					// lenght check ensures this isn't the console light
					if (parents[i].geid == gggg && parents.length > 2) {
						var oldflag:Int = get_ss("test", "gstate", 1);
						oldflag |= (1 << i);
						set_ss("test", "gstate", 1,oldflag);
						break;
						// E.g. 2nd activated, 0b00000 -> 0b00010 
						// This state is reset at the end of a gauntlet.
					}
				}
				return -1;
			}
		}
		if (message_type == C.MSGTYPE_ENERGIZE) {
			nr_ENERGIZE_received ++;
		} else if (message_type == C.MSGTYPE_ENERGIZE_TICK_DARK) {
			nr_ENERGIZE_received++;
		} else if (message_type == C.MSGTYPE_ENERGIZE_TICK_LIGHT) {
			nr_ENERGIZE_received++;
			nr_LIGHT_received++;
		} else if (message_type == C.MSGTYPE_ENERGIZE_DARK) {
			nr_ENERGIZE_received++;
		} else if (message_type == C.MSGTYPE_ENERGIZE_LIGHT) {
			nr_ENERGIZE_received++;
		} else {
			recent_recv_msg = message_type;
		}
		return C.RECV_STATUS_OK;
	}
	private function make_child(ent_id:String,bg:Bool=false,start_anim:String="",fg:Bool=false,ptcolor:Int=-2):Void {
		var c:MySprite = new MySprite();
		
		if (ptcolor != -2) {
			c.makeGraphic(1, 1, ptcolor);
		} else {
			load_visuals(c, ent_id);
		}
		c.exists = false;
		if (fg) {
			fg_sprites.add(c);
			fg_sprites.exists = true;
			//Log.trace("hi");
		} else if (bg) {
			bg_sprites.add(c);
			bg_sprites.exists = true;
		} else {
			sprites.add(c);
		}
		
		if (ptcolor != -2) {
			return;
		}
		
		if (start_anim !=  "") {
			c.animation.play(start_anim);
		}
	}
	private function play_music(ID:String,instant:Bool=true):Void {
		R.song_helper.fade_to_this_song(ID,instant);
	}
	private function fade_out_music(fast:Bool = true) {
		if (fast) {
			R.song_helper.fade_to_this_song("null");
		}
	}
	private function play_sound(ID:String,vol:Float=1):Void {
		R.sound_manager.play(ID,vol);
	}	
	private function shake(i:Float,d:Float):Void {
		FlxG.cameras.shake(i, d);
	}
	
	private function syntax():Void {
		
		
		
		
		
	}
	
	private function make_trigger(_x:Float, _y:Float, w:Int, h:Int):Void {
		if (trigger == null) {
			trigger = new FlxSprite();
			trigger.makeGraphic(w, h, 0xffff5522);
			trigger.alpha = 0.7;
			trigger.x = _x;
			trigger.y = _y;
			HF.add_list_to_mysprite_layer(this, parent_state, [trigger]);
		}
		
	}
	
	/**
	 * called after you stop moving 
	 */
	private function reg_talk_final():Void {
		var _map:String = props.get("map-scene-pos").split(",")[0];
		var _scene:String = props.get("map-scene-pos").split(",")[1];
		var _pos:Int = -1;
		if (props.get("map-scene-pos").split(",").length > 2) {
			_pos = Std.parseInt(props.get("map-scene-pos").split(",")[2]);
		}
		dialogue(_map, _scene, _pos);
	}
	
	private  var generic_move_first_dir_default:Int = 17;
	private  var genmov_force_facedir:String = "";
	private  var genmov_distance:Float = -1;
	private var genmov_cango:Bool = false;
	private function update_generic_move():Bool {
		
			if (dont_walk_on_talk) {
				return true;
			}
			var g:Int = generic_move_first_dir_default;
			R.input.force_shield_off = true;
			if (generic_move_mode == 0) {
				//if (R.activePlayer.facing == FlxObject.RIGHT) {
				generic_move_mode = 1; // go left to face right
				//} else {
					//generic_move_mode = 2;
				//}
				
				// Use external data to override which way to move
				if (cur_data.exists("pw_facedir")) {
					genmov_force_facedir = cur_data.get("pw_facedir");
				}
				
				if (genmov_force_facedir == "r") {
					generic_move_mode = 1;
				} else if (genmov_force_facedir == "l") {
					generic_move_mode = 2;
				}
				genmov_force_facedir = "";
				
				// Specify distance to move
				genmov_distance = 1;
				if (cur_data.exists("pw_dis")) {
					genmov_distance = cur_data.get("pw_dis");
				}
				
				if (R.worldmapplayer == R.activePlayer) {
					generic_move_mode = 4;
				}
				
			} else if (generic_move_mode == 1) { // moving l to face r
				t_generic_move++;
				// Don't let player turn around till they go far enough
				if (genmov_distance > 0 && !genmov_cango) {
					var xpos:Float = 0;
					if (try_to_talk_lock_sprite == null) {
						xpos = x;
					} else {
						xpos = try_to_talk_lock_sprite.x;
					}
					if (xpos- (R.activePlayer.x + R.activePlayer.width) > genmov_distance-11) {
						genmov_cango = true;
						t_generic_move = g + 5;
					}
				} else {
					genmov_cango = true;
				}
				
				if (genmov_cango && t_generic_move > g) {
					if (t_generic_move > g + 4) {
						if (R.player.velocity.x < 0) {
							
							R.input.force_dir = 1;
						}
						generic_move_mode = 3;	
					} else {
						R.input.force_dir = 1;
					}
				} else {
					R.input.force_dir = 3;
				}
			} else if (generic_move_mode == 2) { // moving  r to face l
				t_generic_move++;
				
				
				// Don't let player turn around till they go far enough
				if (genmov_distance > 0 && !genmov_cango) {
					if (R.activePlayer.x - (x + width) > genmov_distance-11) {
						genmov_cango = true;
						t_generic_move = g + 1;
					}
				} else {
					genmov_cango = true;
				}
				
				if (genmov_cango && t_generic_move > g) {
					R.input.force_dir = 3;
					if (t_generic_move > g + 4) {
						generic_move_mode = 3;
					}
				} else {
					R.input.force_dir = 1; // Go right
				}
			} else if (generic_move_mode == 3) {
				R.input.force_dir = -1;
				t_generic_move++;
				if (t_generic_move > g+8) {
					generic_move_mode = 4;
				}
			} else {
				if (R.activePlayer == R.player && !R.player.is_on_the_ground(true)) {
					
				} else {
				R.activePlayer.velocity.x = 0;
				t_generic_move = 0;
				do_generic_move = false;
				generic_move_mode = 0;
				genmov_distance = -1;
				genmov_cango = false;
				return true;
				}
			}
		return false;
	}
	private function separate(o:FlxObject):Void {
		FlxObject.separate(o, parent_state.tm_bg);
	}
	private function set_event(id:Int, on:Bool = true, val:Int = -100):Void {
		if (val != -100 ) {
			R.set_flag(id, val);
		} else {
			R.set_flag(id, on);
		}
	}
	private function get_event_state(id:Int, exact:Bool = false):Dynamic {
		if (exact) {
			return R.event_state[id];
		}
		return (R.event_state[id] == 1);
	}
	private function get_event(id:Int, exact:Bool = false):Dynamic {
		return get_event_state(id, exact);
	}
	private function event(id:Int, off:Bool = false):Bool {
		if (R.event_state[id] == 1 && !off) {
			return true;
		} else if (R.event_state[id] == 0 && off) {
			return true;
		}
		return false;
	}
	private var do_generic_move:Bool = false;
	private var generic_move_mode:Int = 0;
	private var t_generic_move:Int = 0;
	private var only_visible_in_editor:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		
		
		if (R.editor.editor_active) {
			debug_name.visible = true;
		} else {
			debug_name.visible = false;
		}
		if (only_visible_in_editor) {
			if (R.editor.editor_active) {
				visible = true;
			} else {
				visible = false;
			}
		}
		if (do_generic_move) {
			if (update_generic_move()) {
				reg_talk_final();
			}
		}
		if (has_trigger) {
			if (trigger != null) {
				if (R.editor.editor_active) {
					trigger.exists = true;
				} else {
					trigger.exists = false;
				}
			}
		}
		
		// If holding shield and walk over an NPC, don't unshield, but still show the bubble.
		var bubdub:Bool = R.access_opts[13] || (!R.access_opts[13] && R.player.shield_fixed && R.player.FORCE_SHIELD_DIR == -1);
		
		
		if (debug_name.exists) {
			debug_name.x = x + width/2 - debug_name.width / 2;
			debug_name.y = y - debug_name.height;
		}
		if (!did_init) {
			did_init = true;
			populate_parent_child_from_props();
			HF.add_list_to_mysprite_layer(this, parent_state, [sprites,debug_name]);
			HF.add_list_to_mysprite_layer(this, parent_state, [fg_sprites],MyState.ENT_LAYER_IDX_FG2);
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [bg_sprites]);
		}
		expand_hitbox(expand_px);
		if (!always_scripted && props.get("has_dialogue") >= 1 && R.activePlayer.overlaps(this) && (R.activePlayer == R.worldmapplayer || R.player.is_on_the_ground()) && R.input.jpCONFIRM && parent_state.dialogue_box.is_active() == false) {
			if (!R.input.left && !R.input.right && !R.input.down && !R.input.up) {
				player_play_idle_and_zero_xvel();
				if (has_script) {
					var program = HF.get_program_from_script_wrapper(cur_data.get("script"));
					var interpreter:Interp = new Interp();
					interpreter.variables.set("R", R);
					interpreter.variables.set("cur_data", cur_data);
					var retvals:Array<String> = interpreter.execute(program);
					dialogue(retvals[0], retvals[1]);
					program = null;
					interpreter = null;
				} else if (props.get("has_dialogue") >= 1) {
					if (props.get("map-scene-pos").length > 3) {
						do_generic_move = true;
					} else {
						if (cur_data.exists("map") == true && cur_data.exists("scene") == true) {
							//props.set("has_dialogue", 0);
							var p:Int = -1;
							if (cur_data.exists("pos")) {
								p = cur_data.get("pos");
							}
							if (props.get("has_dialogue") == 2) {
								R.dialogue_manager.in_game_force_dialogue = props.get("debug_name");
							}
							dialogue(cur_data.get("map"), cur_data.get("scene"), p);
							if (turned_on_bubble) {
								turned_on_bubble = false;
								if (R.activePlayer == R.player) R.player.activate_npc_bubble("speech_disappear");
								if (R.activePlayer == R.worldmapplayer) R.worldmapplayer.activate_npc_bubble("speech_disappear");
							}
						} else if (props.get("has_dialogue") == 2) {
							//parent_state.dialogue_box.
						}
					}			
				}
			}
		}
		
		if (props.get("has_dialogue") == 1 && !always_scripted) {
			if (R.activePlayer.overlaps(this)) {
				if (turned_on_bubble == false && parent_state.dialogue_box.is_active() == false) {
					if (R.activePlayer == R.player) R.player.activate_npc_bubble("speech_appear",bubdub);
					if (R.worldmapplayer == R.activePlayer) R.worldmapplayer.activate_npc_bubble("speech_appear");
					turned_on_bubble = true;
				}
				if (turned_on_bubble && parent_state.dialogue_box.is_active()) {
					turned_on_bubble = false;
					if (R.activePlayer == R.player) R.player.activate_npc_bubble("speech_disappear",bubdub);
					if (R.worldmapplayer == R.activePlayer) R.worldmapplayer.activate_npc_bubble("speech_disappear");
				}
			} else {
				if (turned_on_bubble == true) {
					turned_on_bubble = false;
					if (R.activePlayer == R.player) R.player.activate_npc_bubble("speech_disappear",bubdub);
					if (R.worldmapplayer == R.activePlayer) R.worldmapplayer.activate_npc_bubble("speech_disappear");
				}
			}
		} 
		
		
		if (R.player.overlaps(this) && prevent_shield_lock && !only_visible_in_editor) {
			R.player.cant_lock_neutral = true;
		}
		if (always_scripted) {
			if (made_program == false ) { 
				made_program = true;
				my_program = HF.get_program_from_script_wrapper(cur_data.get("script"));
				my_interp = new Interp();
				my_interp.variables.set("this", this);
				my_interp.variables.set("R", R);
				my_interp.variables.set("EF", EF);
				
			}
			if (R.editor.editor_active == false && !SCRIPT_OFF && !global_npc_lock) {
				my_interp.execute(my_program);
			}
		}
				
		
		expand_hitbox( -expand_px);
		
		if (wall_climbable) {
			FlxObject.separateY(this, R.player);
			if (wall_mode == 0) {
				var b:Bool = FlxObject.separateX(this, R.player);
				if (b) {
					if (R.player.touching & FlxObject.RIGHT > 0) {
						wall_mode = 1;
						R.player.activate_wall_hang();
					} else if (R.player.touching & FlxObject.LEFT > 0) {
						wall_mode = 2;
						R.player.activate_wall_hang();
					}
				}
			} else {
				if (wall_mode == 1 && R.input.right) {
					R.player.x = x - R.player.width + 1;
					R.player.activate_wall_hang();
				} else if (wall_mode == 2 && R.input.left) {	
					R.player.x = x + width - 1;
					R.player.activate_wall_hang();
				}
				if (!R.player.is_wall_hang_points_in_object(this)) {
					wall_mode = 0;
				}
			}
		}
		
		if (start_loopsound) {
			if (loop_idx == 0) {
				if (loopsound.playing == false || loopsound._channel.position >= loop_time) {
					loopsound2.play();
					loop_idx = 1;
				}
			} else if (loop_idx == 1) {
				if (loopsound2.playing == false || loopsound2._channel.position >= loop_time) {
					loopsound.play();
					loop_idx = 0;
				}
			} else if (loop_idx == 2) {
				if (loopsound.playing == false && loopsound2.playing == false) {
					loopsound.play();
					loopsound2.volume = loopsound.volume = 1;
					loop_idx = 0;
				}
			} else { // fade out
				if (loopsound.playing) {
					loopsound.volume -= 0.01;
					if (loopsound.volume <= 0) {
						loopsound.stop();
					}
				}
				if (loopsound2.playing) {
					loopsound2.volume -= 0.01;
					if (loopsound2.volume <= 0) {
						loopsound2.stop();
					}
				}
			}
		}
		super.update(elapsed);
	}
	
	
	private function midpoint_touching_right_on_tilemap():Bool {
		if (parent_state.tm_bg.getTileCollisionFlags(this.x +this.width, this.y + this.height / 2) != 0) {
			return true;
		}
		return false;
	}	
	private function midpoint_touching_left_on_tilemap():Bool {
		if (parent_state.tm_bg.getTileCollisionFlags(this.x, this.y + this.height / 2) != 0) {
			return true;
		}
		return false;
	}
	private function is_near_floor_gap(is_right:Bool=false):Bool {
		if (parent_state.tm_bg.getTileCollisionFlags(x - 1, y + height) == 0  && !is_right) {
			return true;
		}  else if (parent_state.tm_bg.getTileCollisionFlags(x +width + 1, y + height) == 0 && is_right) {
			return true;
		}
		return false;
	}
	
	private function expand_hitbox(px:Int):Void {
		width += px * 2;
		height += 2 * px;
		x -= px;
		y -= px;
	}
	
	// If you overlap a sprite and the bubble pops up, no other sprites can do anything with try_to_talk
	// until this sprite becomes null or you unoverlap it
	
	private function set_try_to_talk_lock_sprite(s:FlxSprite):Void {
		try_to_talk_lock_sprite = s;
	}
	
	private var try_to_talk_do_generic_walk:Bool = false;
	private static var try_to_talk_lock_sprite:FlxSprite = null;
	private var dont_walk_on_talk:Bool = false;
	private function try_to_talk(extend_size_px:Int = 0,o:FlxObject=null,no_walk:Bool=false):Bool {
		
		if (try_to_talk_do_generic_walk) {
			// If one entity signalled to do the walking thingy thne dont let any other entities return true (stops 
			// side effect when calling try_to_talk multiple times in one script
			if (o == null) {
				if (try_to_talk_lock_sprite != this) {
					return false;
				}
			} else {
				if (try_to_talk_lock_sprite != o) {
					return false;
				}
			}
			dont_walk_on_talk = no_walk;
			if (update_generic_move()) {
				try_to_talk_do_generic_walk = false;
				try_to_talk_lock_sprite = null;
				return true;
			}
		}

		if (try_to_talk_lock_sprite != null) {
			if (o != null) {
				if (try_to_talk_lock_sprite != o) {
					return false;
				}
			} else {
				if (try_to_talk_lock_sprite != this ) {
					return false;
				}
			}
		}
		
		if (try_to_talk_do_generic_walk) {
			
			return false;
		}
		
		var s:FlxObject = null;
		if (o != null) {
			s = o;
		} else {
			s = this;
		}
		if (extend_size_px != 0) {
			s.width += 2*extend_size_px;
			s.height += 2*extend_size_px;
			s.x -= extend_size_px;
			s.y -= extend_size_px;
		}
		
		
		// If holding shield and walk over an NPC, don't unshield, but still show the bubble.
		var b:Bool = R.access_opts[13] || (!R.access_opts[13] && R.player.shield_fixed && R.player.FORCE_SHIELD_DIR == -1);
		
		var r:Bool = false;
		if (turned_on_bubble && R.activePlayer.overlaps(s) && (R.worldmapplayer == R.activePlayer || R.player.is_on_the_ground()) && R.input.jpCONFIRM && parent_state.dialogue_box.is_active() == false) {
			if (R.worldmapplayer == R.activePlayer || (!R.input.left && !R.input.right && !R.input.down && !R.input.up)) {
				player_play_idle_and_zero_xvel();
				if (R.activePlayer == R.player) R.player.activate_npc_bubble("speech_disappear");
				if (R.worldmapplayer == R.activePlayer) {
					R.worldmapplayer.activate_npc_bubble("speech_disappear");
					R.worldmapplayer.idleanim();
				}
				turned_on_bubble = false;
				//try_to_talk_lock_sprite = null;
				//r = true;
				try_to_talk_do_generic_walk = true;
				r = false;
			}
		} else if (R.activePlayer.overlaps(s)) {
			
			
			if (!turned_on_bubble && parent_state.dialogue_box.is_active() == false	) {
				if (R.activePlayer == R.player) {
					R.player.activate_npc_bubble("speech_appear",b);
				}
				if (R.worldmapplayer == R.activePlayer) R.worldmapplayer.activate_npc_bubble("speech_appear");
				turned_on_bubble = true;
				try_to_talk_lock_sprite = cast s;
			}
		} else {
			if (turned_on_bubble) {
				try_to_talk_lock_sprite = null;
				turned_on_bubble = false;
				if (R.activePlayer == R.player) {
					R.player.activate_npc_bubble("speech_disappear",b);
				}
				if (R.worldmapplayer == R.activePlayer) R.worldmapplayer.activate_npc_bubble("speech_disappear");
			}
		}
		
		
		if (extend_size_px != 0) {
			s.width -= 2*extend_size_px;
			s.height -= 2*extend_size_px;
			s.x += extend_size_px;
			s.y += extend_size_px;
		}
		return r;
	}
	private var ignore_parent_dialogue:Bool = false;
	
	private function d_last_yn():Int {
		return R.TEST_STATE.dialogue_box.last_yn;
	}
	private function dialogue(map:String, scene:String, pos:Int = -1,unpause:Bool=true,fuckwithenergybar:Bool=true):Void {
		
		if (parents.length == 1 && children.length == 0 && !ignore_parent_dialogue) {
			R.TEST_STATE.dialogue_box.external_speaker_entity = parents[0];
			Log.trace("ignore parent dialogue aybe");
		} else {
			R.TEST_STATE.dialogue_box.external_speaker_entity = this;
		}
		parent_state.dialogue_box.start_dialogue(map, scene, pos);
		parent_state.dialogue_box.unpause_player_after_cleanup = unpause;
		
		if (unpause) {
			R.there_is_a_cutscene_running = false;
			if (fuckwithenergybar) energy_bar_move_set(true);
		} else {
			R.there_is_a_cutscene_running = true;
			if (fuckwithenergybar) energy_bar_move_set(false);
		}
	}
	
	private function fade_out(o:Dynamic, constant:Float = 0.01, mult:Float = 0.95, target:Float = 0.05,final_:Float=0):Bool {
		return fade_help(true, o, constant, mult, target,final_);
	}
	
	private function fade_in(o:Dynamic, constant:Float = 0.01, mult:Float = 1.05, target:Float =0.95,final_:Float=1):Bool {
		return fade_help(false, o, constant, mult, target, final_);
	}
	
	private function fade_help(fade_out:Bool,o:Dynamic, constant:Float, mult:Float, target:Float,final_:Float):Bool {
		var a:Array<FlxSprite> = [];
		if (Std.is(o, FlxSprite)) {
			a.push(o);
		} else {
			a = cast o;
		}
		if (target > 1) target = 1;
		if (target < 0) target = 0;
		if (final_ < 0) final_ = 0;
		if (final_ > 1) final_ = 1;
		var amt_done:Int = 0;
		for (sprite in a) {
			if (fade_out) {
				sprite.alpha -= constant;
				sprite.alpha *= mult;
				if (sprite.alpha <= target) {
					sprite.alpha = final_;
					amt_done ++;
				}
			} else {
				sprite.alpha += constant;
				sprite.alpha *= mult;
				if (sprite.alpha >= target) {
					sprite.alpha = final_;
					amt_done ++;
				}
			}
		}
		if (amt_done == a.length) {
			return true;
		}
		return false;
	}
	private function dialogue_is_on():Bool {
		return parent_state.dialogue_box.is_active();
	}
	private function doff():Bool {
		return !dialogue_is_on();
	}
	private function energy_bar_move_set(b:Bool, force:Bool = false):Void {
		if (force) {
			R.player.energy_bar.force_hide = force;
		}
		R.player.energy_bar.allow_move = b;
	}
	private function random():Float {
		return Math.random();
	}
	private function string(d:Dynamic):String {
		return Std.string(d);
	}
	private function _trace(d:Dynamic):Void {
		Log.trace(d);
	}
	
	private function touching_down():Bool {
		return this.touching & FlxObject.DOWN != 0;
	}
	
	private function rand_int(min:Int, max:Int):Int {
		return Std.int((max - min) * Math.random()) + min;
	}
	private function play_anim(name:String):Void {
		animation.play(name, true);
	}
	private function player_taxicab():Int {
		return Std.int(FlxX.l1_norm_from_mid(this, R.activePlayer));
	}
	private function player_separate(o:FlxObject):Bool {
		return FlxObject.separate(o, R.activePlayer);
	}
	private function times_scene_played(map:String, scene:String):Int {
		return R.dialogue_manager.get_times_a_scene_is_played(map, scene);
	}
	private function broadcast_tick(dark:Bool = false):Void {
		if (dark) {
			broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_DARK);
		} else {
			broadcast_to_children(C.MSGTYPE_ENERGIZE_TICK_LIGHT);
		}
	}
	private function is_offscreen(d:Dynamic):Bool {
		var a:Array<FlxSprite>;
		if (Std.is(d, FlxSprite)) {
			a = [d];
		} else {
			a = cast d;
		}
		var c = 0;
		for (s in a) {
			//Log.trace([s.x, s.width, FlxG.camera.scroll.x, FlxG.camera.width]);
			if (s.x + s.width < FlxG.camera.scroll.x || s.x > FlxG.camera.scroll.x + FlxG.camera.width || s.y + s.height < FlxG.camera.scroll.y || s.y > FlxG.camera.scroll.y + FlxG.camera.height) {
				c++;
			}
		}
		if (c == a.length) {
			return true;
		}
		return false;
	}
	
	private function set_Myblend(o:FlxSprite, b:Int):Void {
		if (b == 1) {
			o.blend = BlendMode.ADD;
		} else if (b == 2) {
			o.blend = BlendMode.MULTIPLY;
		} else if (b == 3) {
			o.blend = BlendMode.SCREEN;
		} else if (b == 0) {
			o.blend = BlendMode.NORMAL;
		}
	}
	
	private function set_vars(o:FlxSprite,x:Float, y:Float, alpha:Float=1.0, exists:Bool = true):Void {
		o.x = x;
		o.y = y;
		o.last.x = x;
		o.last.y = y;
		o.alpha = alpha;
		o.exists = exists;
	}
	
	private function set_wh(o:FlxSprite, w:Int, h:Int, center_h:Bool = true, flush_bottom:Bool = true):Void {
		o.width = w;
		o.height = h;
		if (center_h) {
			o.offset.x = (o.frameWidth - w) / 2;
		}
		
		if (flush_bottom) {
			o.offset.y = (o.frameHeight - h);
		}
	}
	private function center_in_screen(o:FlxSprite):Void {
		o.x = (C.GAME_WIDTH - o.width ) / 2;
		o.y = (C.GAME_HEIGHT - o.height) / 2;
	}
	
	/**
	 * Always stops left/right inputs until the player touches the ground.
	 * When the player touches the ground, sets x-vel to 0, pauses all player input, and puts player in idle anim, unable to continue anims till pause toggle turned off...also stops player update() from running.
	 * @return Whether player was frozen.
	 */
	private function player_freeze_help():Bool {
		var res = R.player.player_freeze_help();
		return res;
	}
	private function player_play_idle_and_zero_xvel():Void {
		R.player.play_idle_anim();
		R.player.velocity.x = 0;
	}
	private function camera_edge(is_x:Bool = true, is_y:Bool = false, LU:Bool = false, RD:Bool = true):Float {
		if (is_x && !is_y) {
			if (RD && !LU) {
				return (FlxG.camera.scroll.x + FlxG.camera.width);
			} else {
				return (FlxG.camera.scroll.x);
			}
		} else {
			if (LU) {
				return (FlxG.camera.scroll.y);
			} else {
				return (FlxG.camera.scroll.y + FlxG.camera.height);
			}
		}
		return 0;
	}
	/**
	 * 
	 * @param	next_map
	 * @param	tlx
	 * @param	tly
	 * @param	is_aliph_and_tiles tlx/tly are in tiles, player will be at the right height to be on ground
	 */
	private function change_map(next_map:String, tlx:Float, tly:Float,is_aliph_and_tiles:Bool=false):Void {
		var ts:TestState = cast parent_state;
		//if (R.player == R.activePlayer) {
			//R.player.enter_door();
		//}
		ts.DO_CHANGE_MAP = true;
		ts.next_map_name = next_map;
		if (is_aliph_and_tiles) {
			ts.next_player_x = Std.int(tlx) * 16;
			ts.next_player_y = Std.int(tly * 16 - R.player.height + 1);
		} else {
			ts.next_player_x = Std.int(tlx);
			ts.next_player_y = Std.int(tly);
		}
	}
	/**
	 * Signals the TestState to transition the map, and also marks the camera to not follow the player and the player to be invisible. Also prevents pausing. Also sets the next camera to tlx/tly.
	 * @param	next_map
	 * @param	tlx
	 * @param	tly
	 */
	private static var cut_cache_player_x:Float = -1;
	private static var cut_cache_player_y:Float = -1;
	private function start_invisible_player_cutscene(next_map:String, tlx:Float, tly:Float,cache_player:Bool=false):Void {
		var ts:TestState = cast parent_state;
		if (R.player == R.activePlayer) {
			R.player.enter_door();
		}
		ts.cuts_p_invis_on = true;
		ts.DO_CHANGE_MAP = true;
		ts.next_map_name = next_map;
		ts.cpix = tlx;
		ts.cpiy = tly;
		if (cache_player) {
			GenericNPC.cut_cache_player_x = R.activePlayer.x;
			GenericNPC.cut_cache_player_y = R.activePlayer.y;
		}
	}
	private function stop_invisible_player_cutscene(next_map:String, tlx:Float=-1, tly:Float=-1):Void {
		var ts:TestState = cast parent_state;
		ts.cuts_p_invis_on = false;
		ts.DO_CHANGE_MAP = true;
		ts.next_map_name = next_map;
		if (cut_cache_player_x != -1) {
			ts.next_player_x = Std.int(cut_cache_player_x);
			ts.next_player_y = Std.int(cut_cache_player_y);
			cut_cache_player_y = cut_cache_player_x = -1;
		}
		// ???
		if (tlx == -1 && tly == -1) {
			// Don't do nothing
		} else {
			//ts.next
		}
	}
	
	private function move_cam(x:Float, y:Float):Void {
		FlxG.camera.scroll.x = FlxG.camera._scrollTarget.x = x;
		FlxG.camera.scroll.y = FlxG.camera._scrollTarget.y = y;
	}
	
	private function cam_to_id(c_id:Int, alt:Int=0):Void {
		if (alt > 0) {
			FlxG.camera.scroll.y -= 2;
			FlxG.camera._scrollTarget.y -= 2;
			return;
		}
		R.TEST_STATE.set_panning(c_id, 0, 0, 0, true);
	}
	
	private function camera_to_player(smooth:Bool = false):Void {
		
		var ox:Float = FlxG.camera.scroll.x;
		var oy:Float = FlxG.camera.scroll.y;
		FlxG.camera.scroll.y = FlxG.camera._scrollTarget.y = R.activePlayer.y - .66 * C.GAME_HEIGHT;
		FlxG.camera.scroll.x = FlxG.camera._scrollTarget.x = R.activePlayer.x - .4 * C.GAME_WIDTH;
		if (FlxG.camera._scrollTarget.y < 0) FlxG.camera.scroll.y = FlxG.camera._scrollTarget.y = 0;
		if (FlxG.camera._scrollTarget.x < 0) FlxG.camera.scroll.x = FlxG.camera._scrollTarget.x = 0;
		if (smooth) {
			R.TEST_STATE.set_default_camera();
			FlxG.camera.followLerp = 30;
			FlxG.camera.scroll.set(ox, oy);
		}
		
	}
	private function camera_off():Void {
		FlxG.camera.follow(null);
	}
	private function run_tutorial(id:Int):Void {
		R.TEST_STATE.turn_on_tutorial = true;
		R.tutorial_group.requested_id = id;
	}
	private function tutorial_done():Bool {
		return R.TEST_STATE.turn_on_tutorial == false;
	}
	/**
	 * 
	 * @param	id ID of the train trigger to move to
	 * @param	t How long the camera waits at the destination IF dontreturn=tre=ue
	 * @param	vi initial velocity
	 * @param	vo doesnt do aynthign?
	 * @param	dontreturn if true, the camera only moves in, not back out
	 * @param wait_for_return_signal - if true, the camera waits for you to send pan_camera_send_return() to return;
	 */
	private function pan_camera(id:Int, t:Float, vi:Float, vo:Float, dontreturn:Bool = true,wait_for_return_signal:Bool=false):Void {
		var ts:TestState = cast parent_state;
		ts.set_panning(id, t, vi, vo);
		TestState.di_pan_dontret = dontreturn;
		TestState.di_pan_wait_for_return_signal = wait_for_return_signal;
	}
	private function pan_done():Bool {
		return !R.TEST_STATE.is_dialogue_panning;
	}
	private function pan_camera_try_send_return():Bool {
		
		if (TestState.di_pan_waiting_for_return_signal) {
			TestState.di_pan_dontret = false;
			TestState.di_pan_wait_for_return_signal = false;
			TestState.di_pan_waiting_for_return_signal = false;
			return true;
		}
		return false;
	}
	
	/**
	 * turns off returning to most recent checkpoint - useful after a gauntlet is finished
	 */
	private function checkpoint_off():Void {
		JankSave.force_checkpoint_things = false;
	}
	
	private function checkpoint_on(cx:Int, cy:Int, mn:String):Void {
		Checkpoint.tempmap = mn;
		Checkpoint.tempx= cx;
		Checkpoint.tempy= cy;
		JankSave.force_checkpoint_things = true;
	}
	
	/**
	 * Hardcoded locations of important map names that might change - in generic_npc.important_maps
	 * @return
	 */
	private function get_map(s:String):String {
		var s:String = GenericNPC.generic_npc_data.get("important_maps").get(s);
		if (s == null) {
			Log.trace("ooops");
			return "TEST";
		}
		return s;
	}
	// what the fuck?
	private function my_set_angle(s:FlxSprite,a:Float):Void {
		s.angle = a;
	}
	
	private var record_data:Array<Array<Array<Int>>>;
	private function init_record(s:FlxSprite, record_name:String,init_x:Float,init_y:Float,spritepath:String="assets/sprites/player/woods_sprite.png",w:Int=32,h:Int=32,nr_frames:Int=323):Void {
		//"assets/sprites/player/pat.png"
		if (record_data == null) {
			record_data = new Array<Array<Array<Int>>>();
		}
		if (Assets.exists("assets/misc/record/" + record_name) == false) {
			Log.trace("No such record in build: " + record_name);
			return;
		}
		var _s:String = Assets.getText("assets/misc/record/" + record_name);
		var parts:Array<String> = _s.split("\n");
		// x y frame
		var new_data:Array<Array<Int>> = [[], [], [], [], [],[Std.int(init_x)],[Std.int(init_y)],[0]];
		new_data[0] = HF.string_to_int_array(parts[0]);
		new_data[1] = HF.string_to_int_array(parts[1]);
		new_data[2] = HF.string_to_int_array(parts[2]);
		new_data[3] = [new_data[0].length];
		new_data[4] = [0];
		record_data.push(new_data);
		
		s.myLoadGraphic(Assets.getBitmapData(spritepath), true, false, w, h);
		for (i in 0...nr_frames) {
			s.animation.add(Std.string(i), [i], 1, false);
		}
		s.alpha = 0;
	}
	
	private function update_record(s:FlxSprite, record_id:Int):Void {
		
	
		// xpos, ypos, frames, num info entries, cur info index, init x init y, alpha fade mode
		var d:Array<Array<Int>> = record_data[record_id];
		var alpha_mode:Int = d[7][0];
		if (alpha_mode == 0) {
			s.animation.play(Std.string(d[2][0]), true);
			if (fade_in(s)) {
				d[7][0] = 1;
				record_data[record_id][4][0] = 0;
			}
		} else if (alpha_mode == 1) {
			var cur_info_index:Int = d[4][0];
			var _ix:Int = d[5][0];
			var _iy:Int = d[6][0];
			
			s.x = _ix + d[0][cur_info_index];
			s.y = _iy + d[1][cur_info_index];
			s.animation.play(Std.string(d[2][cur_info_index]), true);
			
			if (d[3][0] - 1 == d[4][0]) {
				d[7][0] = 2;
			} else {
				record_data[record_id][4][0]++;
			}
		} else if (alpha_mode == 2) {
			if (fade_out(s)) {
				d[7][0] = 0;
				s.x = d[5][0] + d[0][0];
				s.y = d[6][0] + d[1][0];
			}
		}
		//if (
		
	}
	
	// To get R.name_entry.returnword
	private function name_entry_on(start_text:String):Void {
		parent_state.add(R.name_entry);
		R.name_entry.turn_on(start_text);
	}
	private function name_entry_off():Void {
		parent_state.remove(R.name_entry, true);
	}
	private function set_vanish_block_state(s:Bool = false):Void {
		VanishBlock.light_on = s;
	}
	
	private function credits_on():Void {
		R.credits_module.activate();
		parent_state.add(R.credits_module);
	}
	private function credits_off():Void {
		parent_state.remove(R.credits_module, true);
	}
	
	private function do_laser_game(t:Int,customname:String=""):Bool {
		if (t == 0) {
			if (customname != "" && customname.length > 3) {
				laser_game = new LaserGame(0, "", customname);
			} else {
				laser_game = new LaserGame(0, "", R.TEST_STATE.MAP_NAME);
			}
			R.TEST_STATE.add(laser_game);
			laser_game.activate();
			return true;
		} else if (t == 1) {
			if (laser_game.is_done()) {
				return true;
			}
		} else if (t == 2) {
			R.TEST_STATE.remove(laser_game,true);
			laser_game.destroy();
		}
		return false;
	}
	
	private function door_search_and_open(dest:String):Void {
		if (children.length > 0) {
			for (i in 0...children.length) {
				if (children[i].name == "Door") {
					var d:Door = cast children[i];
					if (d.dest_map == dest) {
						d.behavior_to_open();
						return;
					}
				}
			}
		}
	}
	
	
	// Creates an array of all the completed gauntlets, then returns the gauntlet id at position i
	// more or less used for when there's 6 choices and not all of them might show
	// which is only for the library now heh...
	private function huhgauntlets(i:Int):Int {
		var a:Array<Int> = [];
		if (event(EF.shore_done)) a.push(EF.shore_done);
		if (event(EF.canyon_done)) a.push(EF.canyon_done);
		if (event(EF.hill_done)) a.push(EF.hill_done);
		if (event(EF.river_done)) a.push(EF.river_done);
		if (event(EF.woods_done)) a.push(EF.woods_done);
		if (event(EF.forest_done)) a.push(EF.forest_done);
		
		if (i + 1 > a.length) return -1;
		return a[i];
	}
	
	private var help_array:Array<Dynamic>;
	private function af(idx:Int, val:Dynamic, set:Bool = true, init:Bool = false):Dynamic {
		if (init) {
			help_array = [];
			for (i in 0...idx) {
				help_array.push(val);
			}
			return null;
		}
		
		if (set) {
			help_array[idx] = val;
		} else {
			return help_array[idx];
		}
		return null;
	}	
	
	public var noMapDraw:Bool = false;
	override public function draw():Void 
	{
		if (R.worldmapplayer == R.activePlayer && !R.access_opts[15] && !noMapDraw) {
			var ox:Float = x;
			var oy:Float = y;
			var oix:Int = ix;
			var oiy:Int= iy;
			ix = Std.int(x);
			iy = Std.int(y);
			if (R.editor.editor_active == false) {
				var ts:TestState = cast parent_state;
				if (ts.worldmap_grp.members[0] != null) {
					WMScaleSprite.set_wmscale(this, ts.worldmap_grp.members[0], true);
					for (i in 0...sprites.members.length) {
						var s:MySprite = null;
						if (sprites.members[i] != null) {
							s = sprites.members[i];
							WMScaleSprite.set_wmscale(s, ts.worldmap_grp.members[0], true);
						}
					}
				}
			}
			super.draw();
			x = ox;
			y = oy;
			ix = oix;
			iy = oiy;
				
		} else {
			super.draw();
		}
	}
	
	private function gmode_set_events(gid:Int):Void {
		
	}
	
	
	public var has_loopsound:Bool = false;
	public var loopsound:FlxSound;
	public var loopsound2:FlxSound;
	public var loop_time:Float;
	public var loop_idx:Int;
	public var start_loopsound:Bool = false;
	
	private function init_loopsound(path:String,_looptime:Float):Void {
		var s:Sound = Assets.getSound("assets/mp3/sfx/" + path);
		loop_time = _looptime;
		loopsound = new FlxSound();
		loopsound2 = new FlxSound();
		loopsound.loadEmbedded(s, false);
		loopsound2.loadEmbedded(s, false);
	}
	
	private function stop_loopsound():Void {
		loop_idx = 3;
	}
	private function begin_loopsound():Void {
		start_loopsound = true;
		loop_idx = 2;
	}
	private function get_sin(i:Float):Float {
		return sin_table[Std.int(i)];
	}
}