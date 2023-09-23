package entity.player;
import autom.EMBED_TILEMAP;
import autom.SNDC;
import entity.MySprite;
import entity.trap.Wind;
import entity.util.LineCollider;
import entity.util.SoundZone;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.addons.tile.FlxTilemapExt;
import flixel.animation.FlxAnimationController;
import global.C;
import global.EF;
import global.Registry;
import haxe.CallStack;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import help.InputHandler;
import help.MapPrinter;
import help.SoundManager;
import help.Track;
import openfl.Assets;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.text.FlxBitmapText;
import state.MyState;
import state.GameState;
import state.TestState;

/**
 * @author Melos Han-Tani
 */

class Player extends MySprite
{
	
	// For daydream sequences
	public static var noclimb_tiles:Array<Int>;
	public static inline var VISTYPE_dream:Int = 0;
	public static inline var VISTYPE_real:Int = 1;

	public static  var player_sprite_bitmap:BitmapData;
	public var death_anim:PlayerDeathAnim;
	public static var even_sprite_bitmap:BitmapData;
	public static var player_shield_sprite:BitmapData;
	private var light_sprite:FlxSprite;
	private var dark_sprite:FlxSprite;
	public static var armor_on:Bool = false;
	public var shieldless_sprite:Bool = false;
	public var npc_interaction_bubble:FlxSprite;
	public var HurtEffects:HurtEffectGroup;
	private var over_cloud:Bool = false;
	
	private static inline var C_w:Int = 10; // Of hitbox
	private static inline var C_h:Int = 20;
	private static inline var C_frameW:Int = 32;
	private static inline var C_frameH:Int = 32;
	private static inline var C_shield_thick:Int = 8;
	private static inline var C_shield_length:Int = 26;
	private static var C_base_ay:Int = 560;
	private static inline var C_base_ax:Int = 170;
	private static inline var C_init_vx:Int = 57;
	private static var C_base_uphill_vx:Int = 75;
	private static var C_base_jump_vy:Int = -195;
	private static inline var C_terminal_v:Int = 450;
	private static inline var C_shield_frame_w:Int = 32;
	private static var C_jump_braking:Int = 9;
	private var C_AIR_ACCEL_X:Int = 488;
	private var jump_anim_y_offset:Int = 0;
	private var C_PUSH_OFF_TICKS:Int = 9;
	private var C_AIR_TURN_DAMPING:Float = 10;
	public var skip_motion_ticks:Int = 0;
	/**
	 * References to the current game state's collidable tilemaps
	 */
	public var tm_bg:FlxTilemap;
	public var tm_bg2:FlxTilemap;
	public var tm_fg:FlxTilemap;
	
	
	private var shield_dir:Int;
	public var shield_fixed:Bool;
	public var joybug_shield:Bool = false;
	private var shield_logic_up:FlxSprite;
	private var shield_logic_left:FlxSprite;
	private var shield_logic_right:FlxSprite;
	private var shield_logic_down:FlxSprite;
	public var no_shielding_till_release:Bool = false;
	private var is_sticky:Bool = false;
	public var force_sticky :Bool = false;
	
	private var invincible:Bool = false;
	public var energy_bar:EnergyBar;
	
	private var input:InputHandler;
	
	private var debug_text:FlxBitmapText;
	private var IS_DEBUG:Bool = false;
	public var dark_light_stats:Array<Int>;
	
	public var wall_hang_pt:FlxPoint;
	
	/**
	 * Applied in post-update, adds to current horizontal velocity
	 */
	public var push_xvel:Int = 0;
	private var push_yvel:Int = 0;
	public var extra_x:Float = 0;
	
	/**
	 * Applied in post-update, forces the x vlocity
	 */
	private var force_push_xvel:Int = 0;
	private var last_velx_with_wind:Float = 0;
	private var last_vely_with_wind:Float = 0;
	public var wind_velx:Float = 0;
	public var wind_vely:Float = 0;
	private var old_vel_x:Float = 0;
	private var old_vel_y:Float = 0;
	
	public function new(_x:Int,_y:Int,_parent:MyState) 
	{

			dark_light_stats = [0, 0];
			noclimb_tiles = [];
			player_sprite_bitmap =  Assets.getBitmapData("assets/sprites/player/pat.png");
			even_sprite_bitmap = Assets.getBitmapData("assets/sprites/player/even.png");
			light_sprite  = new FlxSprite();
			dark_sprite = new FlxSprite();
			light_sprite.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/pat_light.png"), true, false, 32, 32);
			dark_sprite.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/pat_dark.png"), true, false, 32, 32);
			
			for (i in 0...456) {
				light_sprite.animation.add(Std.string(i), [i], 30, true);
				dark_sprite.animation.add(Std.string(i), [i], 30, true);
			}
			
			super(_x, _y,_parent,"Player");
			
			R = Registry.R;
			input = R.input;
			
			change_vistype(VISTYPE_dream);
			
			velocity.y = 150;
			acceleration.y = C_base_ay;
			
			
			shield_logic_down = new FlxSprite(0, 0);
			shield_logic_down.makeGraphic(17, 6, 0x77ffffff);
			shield_logic_left = new FlxSprite(0, 0);
			shield_logic_left.makeGraphic(8, 23, 0x77ffffff);
			shield_logic_right = new FlxSprite(0, 0);
			shield_logic_right.makeGraphic(8, 23, 0x77ffffff);
			shield_logic_up = new FlxSprite(0, 0);
			shield_logic_up.makeGraphic(20, 6, 0x77ffffff);
			shield_logic_down.immovable = shield_logic_left.immovable = shield_logic_right.immovable = shield_logic_up.immovable = true;
			set_shield_position(FlxObject.RIGHT);
			
			npc_interaction_bubble = new FlxSprite();
			AnimImporter.loadGraphic_from_data_with_id(npc_interaction_bubble, 16, 16, "npcbubble");
			npc_interaction_bubble.visible = false;
			
			energy_bar = new EnergyBar(0, 0, R.TEST_STATE);
			
			wall_hang_pt = new FlxPoint(0, 0);
			
			debug_text = HF.init_bitmap_font("x", "left", 0, 0, new FlxPoint(1, 1), C.FONT_TYPE_APPLE_WHITE);
			debug_text.visible = shield_logic_down.visible = shield_logic_left.visible = shield_logic_up.visible = shield_logic_right.visible = false;
			
			death_anim = new PlayerDeathAnim();
			death_anim.exists = false;
			
			HurtEffects = new HurtEffectGroup(this);
	}
	public function change_vistype(_type:Int,force_type:Int=-1):Void {
		//Log.trace("palyer vistype");
		//force_type = 0;
		if (_type == VISTYPE_dream) {
			vistype = _type;
			if (force_type == 0) {
				armor_on = true;
				myLoadGraphic(Assets.getBitmapData("assets/sprites/player/aliph_armor.png"), true, false, 48, 48);
			} else if (force_type ==1 || R.event_state[EF.player_intro_cave] == 1) {
				armor_on = false;
				myLoadGraphic(player_sprite_bitmap, true, false, C_frameW, C_frameH);
			} else if (force_type < 1) {
				armor_on = true;
				myLoadGraphic(Assets.getBitmapData("assets/sprites/player/aliph_armor.png"), true, false, 48, 48);
			}
			width = C_w;
			height = C_h;
			if (armor_on) height += 8;
			if (armor_on) width += 0;//marina edit
			offset.y = frameHeight - height;	
			offset.x = (C_frameW - C_w)  / 2;
			if (armor_on) offset.x = (48 - width) / 2;
			//if (!armor_on) Player.C_base_ay = 560;
		} else if (_type == VISTYPE_real) {
			
			vistype = _type;
			myLoadGraphic(even_sprite_bitmap, true, false, C_frameW, C_frameH);
			width = C_w;
			height = C_h;
			offset.y = frameHeight - height;
			offset.x = (C_frameW - C_w) / 2;
		}
		add_all_animations();
		if (shieldless_sprite) {
			animation.play("irx");
		} else {
			animation.play("irn");
		}
		if (armor_on) {
			animation.add("iln", [20], 15);
			animation.add("ilu", [20], 15);
			animation.add("ild", [20], 15);
			
			animation.add("irn", [0], 15);
			animation.add("irr", [0], 15);
			animation.add("ird", [0], 15);
			
			var frr:Int = 12;
			animation.add("wll", [30, 31, 32, 33, 34, 35, 36], frr);
			animation.add("wlr", [30, 31, 32, 33, 34, 35, 36], frr);
			animation.add("wld", [30, 31, 32, 33, 34, 35, 36], frr);
			animation.add("wlu", [30, 31, 32, 33, 34, 35, 36], frr);
			animation.add("wln", [30, 31, 32, 33, 34, 35, 36], frr);
			animation.add("wrr", [10, 11, 12, 13, 14, 15, 16], frr);
			animation.add("wrn", [10, 11, 12, 13, 14, 15, 16], frr);
			animation.add("wru", [10, 11, 12, 13, 14, 15, 16], frr);
			animation.add("wrd", [10, 11, 12, 13, 14, 15, 16], frr);
			animation.add("wrl", [10, 11, 12, 13, 14, 15, 16], frr);
			
			animation.add("jrn", [1,1,2], 16,false);
			animation.add("jru", [1,1,2], 16,false);
			animation.add("jrr", [1,1,2], 16,false);
			animation.add("jrd", [1,1,2], 16,false);
			animation.add("jrl", [1,1,2], 16,false);
			animation.add("frl", [3,3,4], 16,false);
			animation.add("fru", [3,3,4], 16,false);
			animation.add("frd", [3,3,4], 16,false);
			animation.add("frr", [3,3,4], 16,false);
			animation.add("frn", [3,3,4], 16,false);
			
			frr = 16;
			animation.add("jln", [21,21,22], frr,false);
			animation.add("jlu", [21,21,22], frr,false);
			animation.add("jlr", [21,21,22], frr,false);
			animation.add("jld", [21,21,22], frr,false);
			animation.add("jll", [21,21,22], frr,false);
			animation.add("fll", [23,23,24], frr,false);
			animation.add("flu", [23,23,24], frr,false);
			animation.add("fld", [23,23,24], frr,false);
			animation.add("flr", [23,23,24], frr,false);
			animation.add("fln", [23,23,24], frr,false);
			
			animation.add("slump", [5,6,7], 12, true);
		}
	}
	private var fr_walk_light:Float = 16;
	private var fr_walk_dark:Float = 20;
	private var fr_walk_neutral:Float = 16;
	override public function getDefaultProps():Map<String, Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("base_walk_vx", C_base_vx);
		p.set("base_slope_vx", C_base_uphill_vx);
		p.set("base_jump_vy", C_base_jump_vy);
		p.set("jump_braking", C_jump_braking);
		p.set("x_air_Accel", C_AIR_ACCEL_X);
		p.set("extra_y", C_extra_vy);
		p.set("extra_x", C_extra_vx);
		p.set("jump_anim_y_offset", 7);
		p.set("C_PUSH_OFF_TICKS", 9);
		p.set("C_AIR_TURN_DAMPING", 10);
		p.set("hor_push_drag", 12.0);
		p.set("C_phys_vx_min", C_phys_vx_min);
		p.set("walk_fr", "20,16,12");
		return p;
	}
	override public function set_properties(p:Map<String, Dynamic>):Void 
	{
		HF.copy_props(p, props);
		C_PUSH_OFF_TICKS = p.get("C_PUSH_OFF_TICKS");
		C_base_vx_const = p.get("base_walk_vx");
		C_base_uphill_vx = p.get("base_slope_vx");
		C_base_jump_vy = p.get("base_jump_vy");
		C_jump_braking = p.get("jump_braking");
		C_AIR_ACCEL_X = p.get("x_air_Accel");
		C_extra_vx = props.get("extra_x");
		C_extra_vy = props.get("extra_y");
		C_hor_push_drag = props.get("hor_push_drag");
		C_AIR_TURN_DAMPING = props.get("C_AIR_TURN_DAMPING");
		jump_anim_y_offset = props.get("jump_anim_y_offset");
		C_phys_vx_min = props.get("C_phys_vx_min");
		var a:Array<Int> = HF.string_to_int_array(props.get("walk_fr"));
		fr_walk_dark = a[0];
		fr_walk_neutral = a[1];
		fr_walk_light = a[2];
	}
	public function my_set_exists(_exists:Bool):Void {
		energy_bar.my_set_exists(_exists);
		debug_text.exists = _exists;
		shield_logic_down.exists = _exists;
		shield_logic_left.exists = _exists;
		shield_logic_right.exists = _exists;
		shield_logic_up.exists = _exists;
		exists = _exists;
		
	}
	
	public function add_pre(_state:FlxState):Void {
	}
	public function add(_state:FlxState):Void {
		//if (IS_DEBUG) {
			_state.add(shield_logic_down);
			_state.add(shield_logic_up);
			_state.add(shield_logic_left);
			_state.add(shield_logic_right);
			_state.add(debug_text);
		//}
		_state.add(HurtEffects);
	}
	
	override public function destroy():Void 
	{
		//shield = null;
		super.destroy();
	}
	
	private var fctr_no_collide:Int = 0;
	
	override public function preUpdate():Void 
	{
		
		if (HF.array_contains(HelpTilemap.allow_stairs,parent_state.tm_bg.getTileID(x + 6, y + height+1))) {
			if (R.input.up) {
				no_collide_floor_slopes = false;
			} else {
				no_collide_floor_slopes = true;
			}
		} else {
			if (no_collide_floor_slopes) no_collide_floor_slopes = false;
		}
		
		if (R.editor.editor_active) return;	
		_minslopebump = 0;
		// Set collision flags with tmp
		old_vel_x = velocity.x;
		old_vel_y = velocity.y;
		
		// Don't allow
		// what the hell is this doing
		if (is_in_wall_mode()) {
			if (facing == FlxObject.RIGHT && tm_bg.getTileCollisionFlags(x+width,y+height) != 0 && tm_bg.getTileCollisionFlags(x+1,y+height) == 0 && tm_bg2.getTileCollisionFlags(x+1,y+height) == 0) {
				if (allowCollisions & FlxObject.DOWN > 0) {
					allowCollisions ^= FlxObject.DOWN;
				} 
			} else if (facing == FlxObject.LEFT && tm_bg.getTileCollisionFlags(x+width,y+height) == 0 && tm_bg.getTileCollisionFlags(x,y+height) != 0) {
				if (allowCollisions & FlxObject.DOWN > 0) {
					allowCollisions ^= FlxObject.DOWN;
				} 
			} else {
				allowCollisions |= FlxObject.DOWN;
			}
		} else {
			allowCollisions |= FlxObject.DOWN;
		}
		
			FlxObject.separate(this, tm_bg);
			FlxObject.separate(this, tm_bg2);
			FlxObject.separate(this, tm_fg);
			
			// Handle travelling upwards into a 45 deg slope
			if (touching == 0) {
				if (velocity.x >= 0) {
					var tid:Int = tm_bg.getTileID(x + width, y + height);
					if (HF.array_contains(HelpTilemap.fl45, tid) && !HF.array_contains(HelpTilemap.l22, -tid)) { 
						//Log.trace([HelpTilemap.fl45, tid, HelpTilemap.l22]);
						// top left of tile
						var _x:Float = Std.int(x+width) - (Std.int(x+width) % 16);
						var _y:Float = Std.int(y+height) - (Std.int(y+height) % 16);
						// coordinate into tile with top left as (0,0)
						var x_off:Float = x + width - _x;
						var y_off:Float = y + height - _y;
						// Taxicab metric to get if within the slope
						if ((16 - x_off) + (16 - y_off) < 14) {
							// Bump player up
							y = _y + (16 - x_off) - height - 1;
							last.y = y;
							velocity.y = 2;
						}
					}
				} else {
					var tid:Int = tm_bg.getTileID(x , y + height);
					
					if (HF.array_contains(HelpTilemap.fr45, tid) && !HF.array_contains(HelpTilemap.r22, tid) && !HF.array_contains(HelpTilemap.r22,-tid)) { 
						//Log.trace([HelpTilemap.r22, tid]);
						var _x:Float = Std.int(x) - (Std.int(x) % 16);
						var _y:Float = Std.int(y+height) - (Std.int(y+height) % 16);
						var x_off:Float = x - _x;
						var y_off:Float = y + height - _y;
						if ((x_off) + (16 - y_off) < 14) {
							y = _y + (x_off) - height - 1;
							last.y = y;
							velocity.y = 2;
						}
					}
				}
			}
		
		if (touching & FlxObject.UP > 0) { 
			if (tm_bg.getTileCollisionFlags(x + width + 2, last.y-4) != 0 && tm_bg.getTileCollisionFlags(x + width - 2, last.y-4) == 0) {
				if (R.input.left) {
					x -= 2; velocity.y = old_vel_y;
					if (velocity.x > 0) velocity.x = -1;
					touching ^= FlxObject.UP;
				}
			} else if (tm_bg.getTileCollisionFlags(x -2, last.y - 4) != 0 && tm_bg.getTileCollisionFlags(x + 2, last.y - 4) == 0) {
				if (R.input.right) {
					x += 2; velocity.y = old_vel_y;
					if (velocity.x < 0) velocity.x = 1;
					touching ^= FlxObject.UP;
				} else if (R.input.left) {
					velocity.y = old_vel_y;
					if (velocity.x < 0) velocity.x = 1;
					x += 1;
					y = last.y;
					touching ^= FlxObject.UP;
				}
				
			}
		}
		
		//0x1100 left
		//0x0011 right
		if (did_slopes == 0x1100 && touching == 0 && jump_state == js_air && velocity.x > 0) {
			x = last.x;
		} else if (did_slopes == 0x0011 && touching == 0 && jump_state == js_air && velocity.x  < 0) {
			x = last.x;
		}
		did_slopes = 0;
		
		// preupdate sets last.x to x, so if
		// you call collide after this pont it wont do anything 
		//till updated in postUpdate
		super.preUpdate();
	}
	
	private var jump_state:Int = 0;
	private static inline var js_ground:Int = 0;
	private static inline var js_air:Int = 1;
	
	private var fctr_off_cliff:Int = 0;
	private var fctr_touch_ground:Int = 0;
	private var fctr_turn:Int = 0;
	private var fctr_prevent_enter_floating:Int = 0;
	private var no_float_till_jump_or_under:Bool = false;
	public var cant_lock_neutral:Bool = false;
	
	private var mode:Int = 0;
	private static inline var mode_main:Int = 0;
	private static inline var mode_hang:Int = 1;
	private static inline var mode_enter_door:Int = 2;
	private static inline var mode_dying:Int = 3;
	private static inline var mode_floating:Int = 4;
	private static inline var mode_cutscene:Int = 5;
	private static inline var mode_swimming:Int = 6;
	private static inline var mode_sit:Int = 7;
	private var state_hor_move:Int = 0;
	private var logic_paused:Bool = false;
	
	//private var 
	
	override public function update(elapsed: Float):Void {
		
			
		if (FlxG.keys.myJustPressed("TAB") && !R.editor.editor_active) {
			if (R.QA_TOOLS_ON) {
				energy_bar.toggle_debug();
				shield_logic_left.visible = false;
				shield_logic_down.visible = false;
				shield_logic_right.visible = false;
				shield_logic_up.visible = false;
				debug_text.visible = !debug_text.visible;
				R.TEST_STATE.camera_debug.visible = debug_text.visible;
				if (debug_text.visible) {
					IS_DEBUG = true;
				} else {
					IS_DEBUG = false;
				}
			}
		}
		if (GameState.EDITOR_IS_TOGGLEABLE) {
			if (FlxG.keys.pressed.SEMICOLON && FlxG.keys.justPressed.P) {
				R.editor.warp_player_to_editor_checkpoint(this);
			}
		}
		if (logic_paused) {
			return;
		}
		if (R.editor != null && R.editor.editor_active) {
			velocity.y = 0;
			return;
		}
		
		//Log.trace(velocity.x);
		if (facing == FlxObject.RIGHT) {
			wall_hang_pt.x = x + width + 1;
			wall_hang_pt.y = y;
		} else if (facing == FlxObject.LEFT) {
			wall_hang_pt.x = x - 1;
			wall_hang_pt.y = y;
		}
		
		
		if (FORCE_SHIELD_DIR > -1 && FORCE_SHIELD_DIR < 4) {
			shield_dir = FORCE_SHIELD_DIR;
			
		}
	
		// todo - maybe get rid of the "push into wall"
		// from velocity not being set to zero
		// if we're going to walk into a wall..
		super.update(elapsed);
		update_physics_constants();
		switch (mode) { 
			// Regular running and jumping. Switch to wall hang and crawl modes here.
			case mode_main:
				update_mode_main();
			case mode_hang:
				update_mode_hang();
			case mode_enter_door:
				update_mode_enter_door();
			case mode_dying:
				update_mode_dying();
				return;
			case mode_floating:
				update_mode_floating();
			case mode_cutscene:
				return;
			case mode_swimming:
				update_mode_swimming();
			case mode_sit:
				update_mode_sit();
		}
		
		force_wall_hang = false;

		var shieldHeld:Bool = false;
		if ((R.access_opts[13] && !input.a2) || (!R.access_opts[13] && input.a2)) shieldHeld = true;
		
		if (joybug_shield) {
			//Log.trace(123);
			if (R.input.jpA2) {
				joybug_shield = false;
			} else {
				shieldHeld = false;
			}
		}
		
		
		//Log.trace([shieldless_sprite, shieldHeld, no_shielding_till_release, npc_interaction_off]);
		
		if (!armor_on && !R.TEST_STATE.dialogue_box.IS_SCREEN_AREA && !shieldless_sprite && shieldHeld && no_shielding_till_release == false && mode != mode_sit && npc_interaction_off) {
			if (!shield_fixed && (FORCE_SHIELD_DIR != -1 || R.input.up || R.input.left|| R.input.down || R.input.right)) { // i.e., just pressed A2
				// Shield Lock anim and sound
				if (R.TEST_STATE.fade_fg_graphic.alpha == 0) R.sound_manager.play(SNDC.lock_shield,0.5);
				draw_start_lock_shield_effect = true;
			} else if (!shield_fixed && facing == FlxObject.LEFT && !cant_lock_neutral) {
				if (R.TEST_STATE.fade_fg_graphic.alpha == 0) R.sound_manager.play(SNDC.lock_shield,0.5);
				draw_start_lock_shield_effect = true;
				if (is_in_wall_mode()) {
					set_shield_position(FlxObject.RIGHT);
				} else {
					set_shield_position(FlxObject.LEFT	);
				}
			} else if (!shield_fixed && facing == FlxObject.RIGHT && !cant_lock_neutral) {
				if (R.TEST_STATE.fade_fg_graphic.alpha == 0) R.sound_manager.play(SNDC.lock_shield,0.5);
				draw_start_lock_shield_effect = true;
				if (is_in_wall_mode()) {
					set_shield_position(FlxObject.LEFT);
				} else {
					set_shield_position(FlxObject.RIGHT);
				}
			}
			shield_fixed = true;
		} else {
			if (!npc_interaction_off) {
				if (npc_interaction_bubble.animation.finished) {
					npc_interaction_off = true;
				}
			}
			shield_fixed = false;
		}
		if (no_shielding_till_release && !shieldHeld) {
			no_shielding_till_release  = false;
		}
		cant_lock_neutral = false;
		
		if (y > parent_state.tm_bg.height + 48) {
			energy_bar.add_dark(256);
		} else if (y < -height - 32) {
			energy_bar.add_dark(256);
		} else if (x < -25) {
			energy_bar.add_dark(256);
		} else if (x > parent_state.tm_bg.width + 32) {
			energy_bar.add_dark(256);
		}
		
		if (BubbleSpawner.cur_bubble != null && !solid_gassed) {
			
			if (bubble_gas_level == -900) {
				bubble_gas_level = RESET_status_gassed;
			}
			
			// Pop if opposite gas/bubble touch
			//if (BubbleSpawner.BUBBLE_DARK == BubbleSpawner.cur_bubble_type) {
				//if (RESET_status_gassed > 0) BubbleSpawner.force_pop();
			//} else {
				//if (RESET_status_gassed < 0) BubbleSpawner.force_pop();
			//}
			
			RESET_status_gassed = bubble_gas_level;
			
		} else {
			bubble_gas_level = -900;
		}
		
		if (RESET_status_gassed != 0) {
			if (ticks_continuous_gas % 95 == 0) {
				R.sound_manager.play(SNDC.gas);
			}
			ticks_continuous_gas ++;
			update_gassed_logic();
		} else {
			ticks_continuous_gas = 0;
		}
		RESET_status_gassed = 0;
		in_gas_tile = false;
		solid_gassed = false;
		
		if (fctr_prevent_enter_floating > 0) {
			fctr_prevent_enter_floating --;
		}
	}
	
	public function enter_door(info:Int=0):Void {
		mode = mode_enter_door;
		
		if (over_cloud) {
			over_cloud = false;
			activate_npc_bubble("d_off", true);
		}
		//energy_bar.map_transition(); 
		animation.pause();
		invincible = true;
		
		// play an anim?
	}
	/**
	 * Called right after we load the next map and set all the existence states of the various players. Use this to 
	 * reset motion variables of the player.
	 * @param	fromwhere
	 */
	public function enter_main_state(fromwhere:String = ""):Void {
		pause_toggle(false);
		activate_npc_bubble("off");
		alpha = 1;
		if (death_anim.exists == true) {
			death_anim.finalize();
			visible = true;
		}
		if (mode == mode_dying) {
			//Log.trace("Player entering main from dying");
			reset_motion_state();
			invincible = false;
		} else if (mode == mode_enter_door) {
			//Log.trace("Player entering main from enter_door");
			reset_motion_state();
			invincible = false;
		} else if (mode == mode_cutscene) {
			//Log.trace("PLayer entering main from cutscene");
			reset_motion_state();
			invincible = false;
		} else {
			if (fromwhere == "teststate") {
				reset_motion_state();
				invincible = false;
			}
		}
		if (R.editor.editor_active) {
			invincible = true;
		}
		mode = mode_main;
		// play an anim?
	}
	public function toggle_invincible(s:Bool=false):Void {
		invincible = s;
	}
	public function is_jump_state_air():Bool {
		return (jump_state == js_air);
	}
	public function is_in_main_mode():Bool {
		return mode == mode_main;
	}
	public function is_on_the_ground(moving_ok:Bool = false):Bool {
		if (moving_ok) {
			return (jump_state == js_ground && mode == mode_main);
		}
		return (jump_state == js_ground && mode == mode_main && state_hor_move == 0);
	}
	public function is_anim_foot_on_ground():Bool {
		if (is_on_the_ground()) {
			if (animation.curAnim != null && animation.curAnim.curIndex % 5 == 0 && animation.curAnim.curIndex >= 20 && animation.curAnim.curIndex < 140) {
				return true;
			}
		}
		return false;
	}
	public function is_in_cutscene():Bool {
		if (mode == mode_cutscene) return true;
		return false;
	}
	public function is_sitting():Bool {
		if (mode == mode_sit) return true;
		return false;
	}
	public function is_dying():Bool {
		if (mode == mode_dying) return true;
		return false;
	}
	public function is_in_water():Bool { 
		if (mode == mode_swimming || mode == mode_floating) return true;
		return false;
	}
	public function is_swimming():Bool {
		if (mode == mode_swimming) return true;
		return false;
	}
	public function enter_dying():Void {
		Track.add_death(x, y, parent_state.MAP_NAME);
		
		mode = mode_dying;
		reset_motion_state();
		allow_dying = true;
		invincible = true; // no energy hurt
		death_anim.exists = true;
		if (energy_bar.get_LIGHT_percentage() == 1) {			
			death_anim.init(x, y,true);
		} else {
			death_anim.init(x, y);
		}
	}
	public function enter_cutscene(require_ground:Bool=false):Bool {
	
		velocity.x = 0; acceleration.x = 0;
		if (require_ground) {
			if (is_on_the_ground()) {
				if (facing == FlxObject.LEFT) {
					shieldless_sprite ? animation.play("ilx",true) : animation.play("iln", true);
				} else {
					shieldless_sprite ? animation.play("irx",true) : animation.play("irn", true);
				}
			} else {
				return false;
			}
		}
		mode = mode_cutscene;
		invincible = true;
		return true;
	}
	public function player_freeze_help():Bool {
		R.input.lr_toggle(false);
		if (R.access_opts[2]) {
			y += 150 * FlxG.elapsed;
			last.y = y;
			if (parent_state.tm_bg.getTileCollisionFlags(x + 4, y + height + 2) != 0) {
				wasTouching = FlxObject.DOWN;
				y -= 3;
				last.y -= 3;
				
			}
		}
		if (wasTouching & FlxObject.DOWN != 0) {
			R.input.lr_toggle(true);
			pause_toggle(true);
			play_idle_anim();
			velocity.x = 0;
			return true;
		}
		return false;
	}
	
	public function reset_motion_state():Void {
		
		//Log.trace("reset motion");
				
		// reset to walking mode
		state_hor_move = 0;
		velocity.x = velocity.y = 0;
		acceleration.y = C_base_ay;
		jump_state = js_ground;
		try_to_enter_floating_mode = false;
		
		// Reset drag
		drag.set(0, 0);
		cancel_drag = false;
		
		// reset push
		force_push_xvel = 0;
		push_xvel = 0;
		ticks_hor_push_sustain = 0;
		push_yvel = 0;
		
		// wind
		wind_velx = 0;
		wind_vely = 0;
		fctr_no_upwards_wind = 0;
		last_drag_x_with_wind = 0;
		last_drag_y_with_wind = 0;
		ignore_y_motion = false;
		was_in_wind_last_frame = false;

		// bubble
		//has_bubble = false;
		
		
		// gas
		RESET_status_gassed = 0;
		solid_gassed = false;
		in_gas_tile = false;
		in_lo_gas_tile = false;
		in_hi_gas_tile = false;
		ticks_continuous_gas = 0;
		
		
		// jump anim
		cant_lock_neutral = false;
		no_float_till_jump_or_under = false;
		fctr_prevent_enter_floating = 0;
		fctr_turn = 0;
		fctr_touch_ground = 0;
		fctr_off_cliff = 0;
		can_anim_fall = false;
		can_anim_jump = false; 
		
		// reset wall
		hang_ignore_noclimb_tiles = false;
		push_off_ctr = 0;
		
		// etc
		skip_motion_ticks = 0;
		npc_interaction_off = true;

		
		// reset sitting
		if (sit_ctr != 0) {
			energy_bar.force_hide = false;
			energy_bar.allow_move = true;
			sit_ctr = 0;
		}
	}
	
	private var ctr_dying:Int = 0;
	private var allow_dying:Bool = false;
	private function update_mode_dying():Void {
		if (ctr_dying == 1)  {
			if (R.input.jpA1 || R.input.jpA2) {
				parent_state.DO_PLAYER_DIED = true;
				ctr_dying = 0;
				var t:TestState = cast parent_state;
				allow_dying = false;
				t.turn_on_death_text(false);
			}
		} else if (allow_dying) {
			velocity.x = velocity.y = 0;
			visible = false;
			// play dead
			if (death_anim.is_finished()) {
				ctr_dying = 1;
				var t:TestState = cast parent_state;
				var _color:Int = 0;
				if (energy_bar.get_LIGHT_percentage() == 0) {
					_color = 0xffffff;
				}
				t.turn_on_death_text(true, _color);
				return;
			}
			//death_anim.update(FlxG.elapsed);
		}
	}
	
	private function update_mode_enter_door():Void {
		velocity.x = velocity.y = 0;
		energy_bar.skip_tick = true;
		// Stop animations
	}
	
	
	
	private static var C_base_vx:Int = 126; // What's used in motion calculations with player motion code
	private static var C_base_vx_const:Int = 126; // The normal x velocity
	private static var C_phys_vx_max:Int = 180;
	private static var C_phys_vx_min:Int = 108;
	private static var C_hor_push_drag:Float = 12;
	
	private static var C_base_vy_const:Int = -195;
	private static var C_phys_vy_max:Int = -178;
	private static var C_phys_vy_min:Int = -270;
	
	private static var C_PHYS_BUFFER_PERC:Float = 0.1;
	private static var C_extra_vx:Int = 25;
	private static var C_extra_vy:Int= 30;
	
	public function set_physics_constants(type:Int):Void {
		if (type == 1) {
			C_phys_vx_max = 500;
		} else {
			C_base_vy_const = -195;
			C_phys_vy_min = -270;
			C_phys_vy_max = -178;
			
			C_phys_vx_max = 180;
			C_base_vx_const = 126;
			C_phys_vx_min = 105;
			
			C_extra_vx = 25;
			C_extra_vy = 35;
		}
	}
	
	private function update_physics_constants():Void {
		var light_percentage:Float = energy_bar.get_LIGHT_percentage();
		
		if (light_percentage <= 0.4) {
			if (light_percentage <= 0.1) {
				C_base_jump_vy = C_phys_vy_max;
				C_base_uphill_vx = 110;
				C_base_vx = C_phys_vx_max + C_extra_vx;
			} else {
				var c1:Float = (0.4 - light_percentage) / (0.4 - 0.1);
				C_base_jump_vy = Std.int(C_base_vy_const + ((C_phys_vy_max-C_base_vy_const) * c1));
				C_base_uphill_vx = Std.int(75 + (45 * c1));
				C_base_vx = Std.int(C_base_vx_const + ((C_phys_vx_max - C_base_vx_const) * c1));
			}
		} else if (light_percentage >= 0.6) {
			if (light_percentage >= 0.9) {
				C_base_jump_vy = C_phys_vy_min - C_extra_vy;
				C_base_uphill_vx = 58;
				C_base_vx = C_phys_vx_min;
			} else {
				var c2:Float = (light_percentage - 0.6) / (0.9 - 0.6);
				C_base_jump_vy = Std.int(C_base_vy_const - ((C_base_vy_const-C_phys_vy_min) * c2));
				C_base_uphill_vx = Std.int(75 - (17 * c2));
				C_base_vx = Std.int(C_base_vx_const - ((C_base_vx_const - C_phys_vx_min) * c2));
			}
		} else {
			C_base_jump_vy = C_base_vy_const;
			C_base_uphill_vx = 75;
			C_base_vx = C_base_vx_const;
		}

		if (armor_on) {
			C_base_jump_vy = -126;
			acceleration.y = 300;
			if (velocity.y > 0) acceleration.y = 680;
			C_base_vx = 80;
			C_base_uphill_vx = 45;
		}
		var tt:Int = parent_state.tm_bg2.getTileID(R.player.x + R.player.width / 2, R.player.y + R.player.height + 2);
		is_sticky = false;
		if (force_sticky || HF.array_contains(HelpTilemap.sticky, tt)) {
			is_sticky = true;
			force_sticky = false;
			C_base_jump_vy = Std.int(C_base_jump_vy * 0.8);
			C_base_vx = Std.int(C_base_vx * 0.7);
			C_base_uphill_vx = Std.int(C_base_uphill_vx * 0.8);
		}
		
		if (R.access_opts[12]) {
			C_base_vx *= 3;
			C_base_uphill_vx *= 3;
			C_base_jump_vy *= 2;
		}
		
	}
	public var RESET_status_gassed:Int = 0;
	public var solid_gassed:Bool = false;
	private var t_gas:Float = 0;
	private var tm_gas:Float = 0.25; 
	private var ticks_continuous_gas:Int = 0;
	public var in_gas_tile:Bool = false;
	public var in_lo_gas_tile:Bool = false;
	public var in_hi_gas_tile:Bool = false;
	
	public var bubble_gas_level:Int = -1;
	public var gas_effect_Timer:Int = 4;
	private function update_gassed_logic():Void {
		
		if (in_hi_gas_tile) {
			tm_gas =  0.033;
		} else if (!in_lo_gas_tile) {
			tm_gas = 0.05;
		} else {
			tm_gas = 0.1;
		}
		
		t_gas += FlxG.elapsed;
		if (t_gas > tm_gas) {
			gas_effect_Timer --;
			if (gas_effect_Timer < 0) gas_effect_Timer = 1;
			t_gas -= tm_gas;
			if (RESET_status_gassed > 0) { // light
				if (RESET_status_gassed > 2) {
					//(gas_effect_Timer == 0) ? add_light(1) : add_light(1, HurtEffectGroup.STYLE_NONE);
				}
					(gas_effect_Timer == 0) ? add_light(1) : add_light(1, HurtEffectGroup.STYLE_NONE);
			} else { // dark
				if (RESET_status_gassed < -2) {
					//(gas_effect_Timer == 0) ? add_dark(1) : add_dark(1, HurtEffectGroup.STYLE_NONE);
				}
					(gas_effect_Timer == 0) ? add_dark(1) : add_dark(1, HurtEffectGroup.STYLE_NONE);
			}
		}
		in_lo_gas_tile = in_hi_gas_tile = false;
	}
	
	private var toggled_invincibility_in_pause:Bool = false;
	public function pause_toggle(on:Bool):Void {
		
		//Log.trace(CallStack.callStack()[1]);
		if (on) {
			animation.paused= true; // PAuse animations
			logic_paused = true;
			if (invincible == false) {
				invincible = true;
				toggled_invincibility_in_pause = true;
			}
		} else {
			logic_paused = false;
			if (toggled_invincibility_in_pause) {
				toggled_invincibility_in_pause = false;
				invincible = false;
			}
		}
	}
	// also sets logical hitbox
	private function set_shield_position(dir:Int):Void {
		var snd:Bool = false;
		switch (dir) {
			case FlxObject.UP:
				if (shield_dir != 0 && R.sound_manager!=null) {
					if (!shieldless_sprite && !armor_on ) snd = true;
				}
				shield_dir = 0;
			case FlxObject.RIGHT:
				//Log.trace(2);
				if (shield_dir != 1&& R.sound_manager!=null) {
					if (!shieldless_sprite && !armor_on) snd = true;
				}
				shield_dir = 1;
			case FlxObject.DOWN:
				if (shield_dir != 2&& R.sound_manager!=null) {
					if (!shieldless_sprite && !armor_on) snd = true;
				}
				shield_dir = 2;
			case FlxObject.LEFT:
				//Log.trace(1);
				if (shield_dir != 3&& R.sound_manager!=null) {
					if (!shieldless_sprite && !armor_on) snd = true;
				}
				shield_dir = 3;
			case FlxObject.NONE:
				shield_dir = 4;
				
		}
		
		if (R.TEST_STATE.dialogue_box.IS_SCREEN_AREA || FORCE_SHIELD_DIR != -1) {
			snd = false;
		}
		if (snd) {
			if (dir == FlxObject.DOWN) R.sound_manager.play(SNDC.shield_md);
			if (dir == FlxObject.UP) R.sound_manager.play(SNDC.shield_mu);
			if (dir == FlxObject.RIGHT) R.sound_manager.play(SNDC.shield_mr);
			if (dir == FlxObject.LEFT) R.sound_manager.play(SNDC.shield_ml);
		}
		
		if (shieldless_sprite) {
			shield_dir = 4;
			dir = FlxObject.NONE;
		}
		if (FORCE_SHIELD_DIR != -1) {
			shield_dir = FORCE_SHIELD_DIR;
			if (shield_dir == 0) dir = FlxObject.UP;
			if (shield_dir == 1) dir = FlxObject.RIGHT;
			if (shield_dir == 2) dir = FlxObject.DOWN;
			if (shield_dir == 3) dir = FlxObject.LEFT;
		}
		if (IS_DEBUG) {
			shield_logic_down.visible = shield_logic_left.visible = shield_logic_right.visible = shield_logic_up.visible = false;
			switch (dir) {
				case FlxObject.UP:
					shield_logic_up.visible = true;
				case FlxObject.RIGHT:
					shield_logic_right.visible = true;
				case FlxObject.DOWN:
					shield_logic_down.visible = true;
				case FlxObject.LEFT:	
					shield_logic_left.visible = true;
			}
		}
		
	}
	
	/**
	 * Check if this object overlaps with the shield,
	 * optionally if the shield is in a certain direction (0 up, 1 right, etc)
	 * @param	o
	 * @param	dir
	 * @return
	 */
	public function shield_overlaps(o:FlxObject, dir:Int = -1):Bool {
		var overlapdir:Int = -2;
		switch (shield_dir) {
			case 0: //up
				if (o.overlaps(shield_logic_up)) overlapdir = 0;
			case 1:
				if (o.overlaps(shield_logic_right)) overlapdir = 1;
			case 2:
				if (o.overlaps(shield_logic_down)) overlapdir = 2;
			case 3:
				if (o.overlaps(shield_logic_left)) overlapdir = 3;
		}
		if (overlapdir != -2) { // Shield was touching object
			if (dir == -1 || overlapdir == dir) { // don't care on dir, or dir matches
				return true;
			} else { // do care about dir, but doesnt match
				return false;
			}
		}
		return false;
	}
	
	public function get_shield_dir():Int {
		return shield_dir;
	}
	
	public function get_active_shield_logic():FlxObject {
		switch (shield_dir) {
			case 0:
				return shield_logic_up;
			case 1:
				return shield_logic_right;
			case 2:
				return shield_logic_down;
			case 3:
				return shield_logic_left;
		}
		return null;
	}
	
	private var fctr_no_upwards_wind:Int = 0;
	private var last_drag_x_with_wind:Float = 0;
	private var last_drag_y_with_wind:Float = 0;
	public var has_bubble:Bool = false;
	private var was_in_wind_last_frame:Bool = false;
	public var ignore_y_motion:Bool = false;
	public function apply_wind(vx:Float, vy:Float,dontadd:Bool=false):Void {
		if (mode == mode_enter_door) return;
		if (dontadd) {
			if (wind_velx > 0 && vx > 0 && wind_velx >= vx) return;
			if (wind_vely > 0 && vy > 0 && wind_vely >= vy) return;
			if (wind_vely < 0 && vy < 0 && wind_vely <= vy) return;
			if (wind_velx < 0 && vx < 0 && wind_velx <= vx) return;
		}
		wind_velx += vx;
		wind_vely += vy;
	}
	override public function postUpdate(elapsed):Void 
	{
		//Log.trace(drag.x);
		if (mode == mode_dying || mode == mode_enter_door || logic_paused) {
			wind_velx = wind_vely = 0;
			postUpdateTrailStuff();
			return;
		}
		if (force_push_xvel != 0) {
			velocity.x = force_push_xvel;
			last_drag_x_with_wind = 1;
		} else if (push_xvel != 0) {
			//velocity.x += push_xvel;
			velocity.x = push_xvel;
		}
		if (0 != push_yvel) {
			velocity.y = push_yvel;
		}
		
		// Shield multiplies effect of wind
		if (has_bubble || shield_dir == 1 || shield_dir == 3) {
			wind_velx *= 2;
		}
		if (has_bubble || shield_dir == 0 || shield_dir == 2) {
			wind_vely *= 2;
		}
		
		// If being blown upwards don't let the precomputed velocity go really really high
		// This way we can get a nice floating effect if the wind velocity is high enough
		if (wind_vely < 0) {
			if (velocity.y > 500) {
				velocity.y = 500;
			}
		}
		
		// Allow wind x velocity to affect you after excitingt he wind
		if (wind_velx != 0) {
			velocity.x += wind_velx;
			last_velx_with_wind = velocity.x;
			last_drag_x_with_wind = drag.x;
		} else if (last_velx_with_wind != 0) {
			velocity.x = last_velx_with_wind;
			last_velx_with_wind = 0;
		}
		
		//Log.trace(1);
		var applied_y_wind:Bool = false;
		if (wind_vely != 0) {
			if (fctr_no_upwards_wind > 0) {
				//fctr_no_upwards_wind -- ;
				//wind_vely = 0;
			}
			if (fctr_no_upwards_wind <= 0 || velocity.y < 0) {
				var stable_vel:Float = 250 + wind_vely;
				// If when there's no jump momentum, the wind wouldn't push the player up and
				// the player is touching the ground, then let the player stand.
				if (stable_vel >= 0 && wind_vely < 0 && touching & FlxObject.DOWN != 0) {
					wind_vely = 0;
				} else {
					if (touching & FlxObject.UP > 0) {
						if (wind_vely < 0) {
							velocity.y = -wind_vely;
						}
					} else if (wind_vely < 0) { // If wind is up
						applied_y_wind = true;
						// Fal no faster than the stable_vel
						if (velocity.y + wind_vely > stable_vel || mode == mode_hang || (!was_in_wind_last_frame && velocity.y > 0 && y + height < Wind.last_y+4)) {
							velocity.y = stable_vel;
							if (mode == mode_hang) {
								velocity.y = hang_speed + (wind_vely / 2);
							}
						} else {
							velocity.y += wind_vely;
						}
					} else {
						applied_y_wind = true;
						velocity.y += wind_vely;
					}
					last_drag_y_with_wind = drag.y;
					last_vely_with_wind = velocity.y;
					// Do this so we don't shoot out of a 250 mph wind
					if (last_vely_with_wind == 0) last_vely_with_wind = 0.02; 
				}
			}
			
			was_in_wind_last_frame = true;
		} else if (last_vely_with_wind != 0) {
			
			was_in_wind_last_frame = false;
			velocity.y = last_vely_with_wind;
			if (last_vely_with_wind < 0) {
				//fctr_no_upwards_wind = 5;
			}
			last_vely_with_wind = 0;
		}
		
		/* UPDATE POSITION IF NOT IN EDITOR */
		if (R.editor != null && !R.editor.editor_active) {
			// drag only affects in wind-water when we r not holding stuff	
			if (last_drag_x_with_wind != 0 && (R.input.left || R.input.right )) {
				drag.x = 0;
			}
			if (last_drag_y_with_wind != 0 && (R.input.up || R.input.down)) {
				drag.y = 0;
			}
			if (cancel_drag) {
				drag.x = 0;
				cancel_drag = false;
			}
			
			if (energy_bar.get_LIGHT_percentage() <= 0.1) {
				acceleration.x *= 2;
			}
			
			
			if (IS_DEBUG) {
				debug_text.text = "vx: " + Std.string(Math.floor(velocity.x)) + "\nvy: " + Std.string(Math.floor(velocity.y));
				debug_text.text += "\n" + postupdate_debug_last_anim_name;
				debug_text.x = x + 32;
				debug_text.y = y;
			}
			if (ignore_y_motion) {
				velocity.y = acceleration.y = 0;
			}
			
			if (skip_motion_ticks >= 0) {
				skip_motion_ticks--;
			} else {
				var oa:Float = acceleration.y;
				if (touching == FlxObject.RIGHT | FlxObject.DOWN || touching == FlxObject.LEFT | FlxObject.DOWN ) {
					if (LineCollider.player_touching && R.player.velocity.y > 0 ) {
						//acceleration.y *= 2;
					}
					acceleration.y *= 3;
				} else if (LineCollider.player_touching && R.player.velocity.y >= 0) {
					//acceleration.y *= 2;
				}
				super.postUpdate(elapsed);
				x += extra_x;
				extra_x = 0;
				acceleration.y = oa;
			}
			if (ignore_y_motion) {
				acceleration.y = C_base_ay;
			}
			
			if (energy_bar.get_LIGHT_percentage() <= 0.1) {
				acceleration.x /= 2;
			}
			// R we bubbling 
			if (has_bubble) {
				BubbleSpawner.move_bubble(x - ((40-width) / 2), y - (40- height) + 5,velocity);
			}
			
			if (last_drag_x_with_wind != 0) {
				drag.x = last_drag_x_with_wind;
				last_drag_x_with_wind = 0;
			}
			if (last_drag_y_with_wind != 0) {
				drag.y = last_drag_y_with_wind;
				last_drag_y_with_wind = 0;
			}
			
			shield_logic_down.x = x - 4;
			
			if (animation.curAnim != null) {
				postupdate_debug_last_anim_name = animation.curAnim.name;
			}
			
			shield_logic_left.height = shield_logic_right.height = 23;
				if (postupdate_debug_last_anim_name == "wrr") {
					shield_logic_right.x = x + width +5;
				} else {
					shield_logic_right.x = x + width;
				}
				
				if (postupdate_debug_last_anim_name == "wlu") {
					shield_logic_up.x = x - 10; // to do
				} else {
					if (facing == FlxObject.RIGHT) {						
						shield_logic_up.x = x - 3;
					} else {
						shield_logic_up.x = x - 8;
					}
				}
				
				if (postupdate_debug_last_anim_name == "wll") {
					shield_logic_left.x = x - 11;
				} else {
					shield_logic_left.x = x - 6;
				}
			
			shield_logic_left.y = y - 2;
			shield_logic_right.y = y - 2;
			shield_logic_up.y = y - 6;
			shield_logic_down.y = y + height - 2;
			
			if (postupdate_debug_last_anim_name == "jrr" || postupdate_debug_last_anim_name == "frr"  ) {
				shield_logic_right.y = y - 2 + 4;
			} 
			if (postupdate_debug_last_anim_name == "jll" || postupdate_debug_last_anim_name == "fll") {
				
				shield_logic_left.y = y - 2 + 5;
			}
			
			
			if (postupdate_debug_last_anim_name == "clr" || postupdate_debug_last_anim_name == "crl") {
				shield_logic_left.y = shield_logic_right.y = y - 1;
				shield_logic_left.height = shield_logic_right.height =  26;
			}
			
		}
		
		
		// 
		LineCollider.player_touching = false;
		velocity.x -= wind_velx;
		if (applied_y_wind) velocity.y -= wind_vely;
		wind_velx = wind_vely = 0;
	
		//velocity.x -= push_xvel;
 		//velocity.y -= push_yvel;
		if (skip_motion_ticks <= 0) {
			push_yvel = 0;
			if (ticks_hor_push_sustain > 0) {
				ticks_hor_push_sustain--;
			} else {
				var old_C_hor:Float = C_hor_push_drag;
				if (ice_reduce_hor_push_drag) {
					C_hor_push_drag = 2;
				}
				var extra_c:Float = 1;
				if (push_xvel > 0) {
					if (R.input.left) {
						extra_c = 1.5;
					}
					push_xvel -= Std.int(C_hor_push_drag * extra_c);
					if (push_xvel < 0) push_xvel = 0;
				} else if (push_xvel < 0) {
					if (R.input.right) {
						extra_c = 1.5;
					}
					push_xvel += Std.int(C_hor_push_drag * extra_c);
					if (push_xvel > 0) push_xvel = 0;
				}
				if (ice_reduce_hor_push_drag) {
					C_hor_push_drag = old_C_hor;
				}
			}
		
		}
		
		
		npc_interaction_bubble.x = x - 4;
		npc_interaction_bubble.y = Math.round(y) - 20;
		postUpdateTrailStuff();
		
	}
	
	private function postUpdateTrailStuff() {
		
		// stuff with trail
		
		
		if (trail_buffer == null) {
			trail_buffer = [];
			trail_frame_buffer = [];
			for (i in 0...21) {
				trail_buffer.push(new Point(0, 0));
				trail_frame_buffer.push(0);
			}
			dark_sprite.ID = light_sprite.ID = 0;
			// alpha mode and alpha ctr
		}
		
		
		/* decide how many trail t show */
		var d_trail:Bool = false;
		var l_trail:Bool = false;
		var n:Int = 0;
		var l_percent:Float = energy_bar.get_LIGHT_percentage();
		
		if (l_percent <= 0.4) {
			// 130 to 205
			d_trail = true;
			n = 5;
		} else if (l_percent >= 0.6) {
			l_trail = true;
			if (l_percent >= 0.6) n = 2;
			if (l_percent >= 0.7) n = 3;
			if (l_percent >= 0.8) n = 4;
			if (l_percent >= 0.9) n = 5;
		} else {
			// Must have been dark
			if (dark_sprite.ID == 2 && l_percent <= 0.5) {
				n = 5;
				d_trail = true;
			}
		}
		
		// restart fade in effect if pressing jump or moeinv g left right inthe sequence
		// sort of like retrigger in a music envelope
		if (l_trail) {
			if (dark_sprite.ID > 0) {
				if (R.input.jpA1 && wasTouching != 0) {
					dark_sprite.ID = 1;
					light_sprite.ID = 0;
				}
			}
		}
		
		// only enter alpha fading when at right energy levels
		//Log.trace(dark_sprite.ID);
		//WAIT TO FADE
		if (dark_sprite.ID == 0) {
			if (l_trail && R.input.jpA1) {
				dark_sprite.ID = 1;
			}
			if (d_trail && !is_in_wall_mode() && (R.input.left || R.input.right)) {
				dark_sprite.ID = 1;
				light_sprite.ID = 0;
			}
			// FADE IN
		} else if (dark_sprite.ID == 1) {
			if (is_in_wall_mode() || (d_trail && !is_on_the_ground(true) && !R.input.left && !R.input.right)) {
				dark_sprite.ID = 3;
				light_sprite.ID = 20;
			}
			if (light_sprite.ID == 0) {
				for (i in 0...trail_buffer.length) {
					trail_buffer[i].setTo(R.player.x, R.player.y);
					trail_frame_buffer[i] = 6;
					//trail_frame_buffer[i] = frame.tileID;
				}
			}
			light_sprite.ID ++;
			if (light_sprite.ID >= 15) {
				light_sprite.ID = 0;
				if (l_trail) {
					// so light sprite fades faster
					light_sprite.ID = 20;
				}
				dark_sprite.ID = 2;
			}
			// SUSTAIN
		} else if (dark_sprite.ID == 2) {
			if (is_in_wall_mode() || (!is_on_the_ground(true) && !R.input.left && !R.input.right)) {
				dark_sprite.ID = 3;
				light_sprite.ID = 20;
			}
			light_sprite.ID ++;
			if (light_sprite.ID > 30) {
				// so dark trail fades slower
				if (d_trail) {
					light_sprite.ID = 31;
					if (velocity.x == 0 && is_on_the_ground(true) && (!R.input.left && !R.input.right)) {
						light_sprite.ID = 20;
						dark_sprite.ID = 3;
					}
					if (!is_on_the_ground(true) && (!R.input.left && !R.input.right)) {
						light_sprite.ID = 20;
						dark_sprite.ID = 3;
					}
					if (is_in_wall_mode()) {
						light_sprite.ID = 20;
						dark_sprite.ID = 3;
					}
				} else {
					light_sprite.ID = 15;
					dark_sprite.ID = 3;
				}
			}
			
		// only allow new trail to start when - in dark mode, your x vel is low enough, or in light mode, when you are touching ground or wall. if in neither, then just reset
		} else if (dark_sprite.ID == 3) {
			if (light_sprite.ID > 0) light_sprite.ID --;
			
			// if you jump right after starting to fade out on a wall then fade back in fast rather than wait
			if ((R.input.left || R.input.right) && d_trail && !is_in_wall_mode() &&!is_on_the_ground(true)) {
				dark_sprite.ID = 1;
				if (light_sprite.ID > 15) light_sprite.ID = 0;
			} else if (light_sprite.ID == 0 && l_trail && (is_in_wall_mode() || is_in_water() || is_on_the_ground(true))) {
				dark_sprite.ID = 0;
			} else if (light_sprite.ID == 0 && d_trail) {
				dark_sprite.ID = 0;
			} else if (!l_trail && !d_trail) {
				dark_sprite.ID = 0;
			}
		}
		
		/* UPDATE buffer with positions */
		var len:Int = trail_buffer.length;
		for (i in 0...len) {
			if (i == len - 1) {
				trail_buffer[0].setTo(R.player.x, R.player.y);
				if (animation.curAnim != null) {
					//trail_frame_buffer[0] = animation.curAnim.curIndex;
					trail_frame_buffer[0] = animation.getFrameIndex(frame);
				}
				
			} else {
				trail_buffer[len - i - 1].x = trail_buffer[len - i - 2].x;
				trail_buffer[len - i - 1].y = trail_buffer[len - i - 2].y;
				trail_frame_buffer[len - i - 1] = trail_frame_buffer[len - i - 2];
			}
		}
		
		
	}
	private var postupdate_debug_last_anim_name:String = "";
	/**
	 * Changes the horizontal push value
	 * @param	vel
	 * @param	additive IF not forced, does this add to some other push or not
	 * @param	force Whehter the player velocity should change to this (call-order sensitive, a later call could override)
	 * @param	length_ticks How long this should last for
	 */
	private var ticks_hor_push_sustain:Int = 0;
	private var cancel_drag:Bool = false;
	public function do_hor_push(vel:Int, additive:Bool = true, force:Bool = false,length_ticks:Int=0,cancel_drag:Bool=false):Void {
		if (false) {
			force_push_xvel = vel;
		} else if (additive) {
			push_xvel += vel;
		} else {
			push_xvel = vel;
		}
		ticks_hor_push_sustain = length_ticks;
		if (cancel_drag) {
			this.cancel_drag = true;
		}
	}
	public function do_vert_push(vel:Float,dontadd:Bool=false,constant:Bool=false):Void {
		if (R.editor.editor_active) return;
		if (constant) {
			push_yvel = Std.int(vel);
			return;
		}
		if (dontadd) {
			if (vel < 0 && push_yvel < 0 && push_yvel <= vel) return;
		}
		push_yvel += Std.int(vel);
	}
	/**
	 * Force the player to bounce upwards
	 */
	public function do_bounce(withshielddown:Bool = false, noshieldvel:Int = 0, shieldvel:Int = 0):Void {
		mode = mode_main;
		state_hor_move = 2;
		acceleration.y = C_base_ay;
		force_jump_up_ticks = 9;
		if (jump_state != js_air) {
			y -= 2;
		}
		jump_state = js_air;
		
		
		if (withshielddown) {
			if (shieldvel != 0) {
				velocity.y = shieldvel;
			} else {
				velocity.y = C_base_jump_vy;
			}
		} else {
			if (noshieldvel != 0) {
				velocity.y = noshieldvel;
			} else {
				velocity.y = C_base_jump_vy / 2;
			}
		}
	}
	
	public function add_dark(amount:Int, HurtEffects_style:Int = 0, cx:Float = 0, cy:Float = 0):Int {
		
		
		
		if (amount == 0) {
			if (HurtEffects_style == 2 || HurtEffects_style == 4) {
				HurtEffects.releaseboom(HurtEffects_style, cx, cy);
			}
			return 0;
		}
		
		if (R.access_opts[11]) {
			if (amount > 1) {
				amount = Std.int(amount / 2);
			}
		}
		if (invincible || armor_on || amount == 0) {
			if (armor_on) return amount;
			return 0;
		}
		if (HurtEffects_style == HurtEffectGroup.STYLE_NONE) {
		} else if (HurtEffects_style >= 2 && HurtEffects_style <= 7) {
			// 6/7 = dark light move pod, cx is angle
			HurtEffects.releaseboom(HurtEffects_style, cx, cy);
		} else {
			if (amount < 5) {
				HurtEffects.release(1);
			} else if (amount < 10) {
				HurtEffects.release(3);
			} else {
				HurtEffects.release(5);
			}
		}
		
		dark_light_stats[0] += amount;
		return energy_bar.add_dark(amount);
	}
	
	public function add_light(amount:Int, HurtEffects_style:Int = 0,cx:Float=0,cy:Float=0):Int {
		
		// podswitch
		if (HurtEffects_style == 6) {
			HurtEffects.releaseboom(HurtEffects_style, cx, cy);
		}
		
		if (amount == 0) {
			if (HurtEffects_style == 3 || HurtEffects_style == 5) {
				HurtEffects.releaseboom(HurtEffects_style, cx, cy);
			}
			return 0;
		}
		
		if (R.access_opts[11]) {
			if (amount > 1) {
				amount = Std.int(amount / 2);
			}
		}
		
		if (invincible || armor_on || amount == 0) {
			if (armor_on) return amount;
			return 0;
		}
		if (HurtEffects_style == HurtEffectGroup.STYLE_NONE) {
		} else if (HurtEffects_style >= 2 && HurtEffects_style <= 5) {
			HurtEffects.releaseboom(HurtEffects_style, cx, cy);
		} else {
			if (amount < 5) {
				HurtEffects.release(1,true);
			} else if (amount < 10) {
				HurtEffects.release(3,true);
			} else {
				HurtEffects.release(5,true);
			}
		}
		dark_light_stats[1] += amount;
		return energy_bar.add_light(amount);
	}
	
	
	/**
	 * Buoyancy point of the player - the top pixel of the surface equals this point's
	 * y-coord when balanced
	 */
	private var float_buoyancy_y:Int;
	/**
	 * Set when you touch a water_surface tile, tells you where to stop rising 
	 */
	private var float_surface_y:Int;
	private var float_mode:Int = 0;
	private static inline var C_float_vx:Int = 90;
	private static inline var C_water_enter_vy_dampen:Float = 0.55;
	
	private static inline var FLOAT_MODE_RISING:Int = 0;
	private static inline var FLOAT_MODE_STABLE:Int = 1;
	private static inline var FLOAT_MODE_OUT_OF_WATER:Int = 2;
	private var SWIM_MODE_TOP_LEFT_Y_WATER:Float = 0;
	private var try_to_enter_floating_mode:Bool = false;
	
	public function signal_enter_float(float_tile_top_left_y:Float):Void {
		
		if (R.access_opts[2]) return;
		if (float_tile_top_left_y < SWIM_MODE_TOP_LEFT_Y_WATER) SWIM_MODE_TOP_LEFT_Y_WATER = float_tile_top_left_y;
		try_to_enter_floating_mode = true;
	}
	public function set_float_surface_y(i:Int):Void {
		if (R.access_opts[2]) return;
		float_surface_y = i;
		SWIM_MODE_TOP_LEFT_Y_WATER = i + 8;
	}
	private function update_mode_floating():Void {
		float_buoyancy_y = Std.int(y + 4);
		acceleration.x = 0;
		
			
		if (SWIM_MODE_TOP_LEFT_Y_WATER < float_surface_y) {
			float_surface_y = Std.int(SWIM_MODE_TOP_LEFT_Y_WATER - 8);
		}
		
		SWIM_MODE_TOP_LEFT_Y_WATER = 50000;
		
		if (float_mode == FLOAT_MODE_RISING) {
			if (float_buoyancy_y >= float_surface_y) {
				shield_dir == 0 ? acceleration.y = -900 : acceleration.y = -450;
			}
			
			if (velocity.y < 0 && float_buoyancy_y < float_surface_y) {
				//velocity.y *= 1.2;
				R.TEST_STATE.water_splash.dispatch(10, x + width / 2, float_surface_y, 6, 320, -90, 20, 60, 0.5, 0.5);
				R.sound_manager.play(SNDC.splash, 0.3);

				if (boost_water_jump > 0 && velocity.y > -190) {
					velocity.y = -190;
					boost_water_jump = 0;
				}
				if (velocity.y < -90) {
					enter_main_from_float();
					can_anim_jump = true;
					//if (shield_dir != 0) {
						//velocity.y *= 0.85;
					//} else {
						//velocity.y *= (1.35 * C_water_enter_vy_dampen);
					//}
					return;
				} else {
					float_mode = FLOAT_MODE_STABLE;
					//Log.trace("Now stable");
					velocity.y = 0;
					y = float_surface_y - 8	;
				}
			}
			if (touching & (FlxObject.DOWN | FlxObject.LEFT) != 0 || touching & (FlxObject.DOWN | FlxObject.RIGHT) != 0) {
				if (y < float_surface_y && touching_floor_slope) {
					float_mode = FLOAT_MODE_STABLE; velocity.y = acceleration.y = 0; y = float_surface_y - 8;
					//Log.trace("Now stable");
				}
			}
		} else if (float_mode == FLOAT_MODE_STABLE) {
			drag.x = 100;
			if (velocity.y < 0) velocity.y = 0;
			acceleration.y = 0;
			if (touching & (FlxObject.DOWN | FlxObject.LEFT) != 0 || touching & (FlxObject.DOWN | FlxObject.RIGHT) != 0) {
				if (touching_floor_slope && y < float_surface_y) {
					mode = mode_main; /* */
					drag.x = 0;
					drag.y = 0;
					acceleration.y = C_base_ay;
					no_float_till_jump_or_under = true;
					return;
				}
			} else {
				if (y < float_surface_y - 16) {
					enter_main_from_float();
					return;
				} else if (y > float_surface_y - 8) y = float_surface_y - 8;
			}
		} else if (float_mode == FLOAT_MODE_OUT_OF_WATER) {
			if (velocity.y > 0 && float_buoyancy_y >= float_surface_y) {
				float_mode = FLOAT_MODE_RISING;
				velocity.y *= 0.9;
					//Log.trace("Now rising");
				if (shield_dir == 0) {
					velocity.y = 50;
				}
			}
		}
		
		
		// if you jump into windy water you should be swept down
		if ((wind_vely > 0 && float_mode == FLOAT_MODE_RISING && velocity.y > 50)  || (R.input.down && float_mode != FLOAT_MODE_OUT_OF_WATER)) {
			mode = mode_swimming; 
			TestState.truly_set_default_cam(parent_state.tm_bg.width, parent_state.tm_bg.height, "swim");
			acceleration.y = 0;
			drag.y = 100;
			drag.x = 100;
			y += 4;
			velocity.y = 50;
			return;
		}
		
		// If floating stable , or within a margin of error from the surface and moving up, allow jumping out of the water
		if (R.input.jpA1 && ((float_mode == FLOAT_MODE_STABLE) || (Math.abs(float_buoyancy_y - float_surface_y) <= 8 && velocity.y < 0))) {
			
			mode = mode_main; /* */
			drag.x = 0;
			velocity.y = C_base_jump_vy;
			can_anim_jump = true;
			fctr_prevent_enter_floating = 15;// Hack
			acceleration.y = C_base_ay;
			var ts:TestState = cast parent_state;
			ts.water_splash.dispatch(10, x + width / 2, float_surface_y, 6, 320, -90, 80, 60, 0.5, 0.5);
			R.sound_manager.play(SNDC.splash,0.6);
		}
		
		if (R.input.left && !R.input.right) {
			shield_dir % 2 == 1 ? velocity.x = -C_float_vx * 0.85 : velocity.x = -C_float_vx;
			facing = FlxObject.LEFT;
		} else if (R.input.right && !R.input.left) {
			shield_dir % 2 == 1 ? velocity.x = C_float_vx * 0.85 : velocity.x = C_float_vx;
			facing = FlxObject.RIGHT;
		} else {
			if (velocity.x > 0) velocity.x -= 1;
			if (velocity.x < 0) velocity.x += 1;
			if (Math.abs(velocity.x) < 2) velocity.x = 0;
			//drag.x = 20;
		}
		
		shield_position_helper();
		
		if (mode == mode_main) {
			TestState.truly_set_default_cam(parent_state.tm_bg.width, parent_state.tm_bg.height);
		}
		if (float_mode == FLOAT_MODE_OUT_OF_WATER) {
			play_jump_anim();
		} else {
			if (shield_dir == 0) { jump_anim_helper("u", "s"); }
			else if (shield_dir == 1) { jump_anim_helper("r", "s"); }
			else if (shield_dir == 2) { jump_anim_helper("d", "s"); }
			else if (shield_dir == 3) { jump_anim_helper("l", "s"); }
			else if (shield_dir == 4) { jump_anim_helper("n", "s"); }
		}
	}
	
	private static var C_swimming_sink_vel:Int = 100;
	private static var C_swimming_move_min_vel:Float = 15;
	private static var C_swimming_move_vel:Float = 80;
	private static var C_swimming_move_accel:Float = 200;
	private static var C_swimming_max_rise_vel:Int = -85;
	private static var C_swimming_rise_accel:Int = 4;
	private var swim_ignore_max_vel_ticks :Int = 0; // Press jump in water overides max rise velocity	
	private var swim_prev_float_y:Int = 0;
	private var swim_nr_ticks_same_float:Int = 0;
	private var fctr_change_swim_dirs:Int = 0;
	private var boost_water_jump:Int = 0;
	private function update_mode_swimming():Void {
		
		if (boost_water_jump > 0) boost_water_jump--;
		//Log.trace(boost_water_jump);
		if (SWIM_MODE_TOP_LEFT_Y_WATER < float_surface_y) {
			float_surface_y = Std.int(SWIM_MODE_TOP_LEFT_Y_WATER - 8);
		}
		if (y < float_surface_y && SWIM_MODE_TOP_LEFT_Y_WATER > float_surface_y) {
			fctr_change_swim_dirs = 0;
			mode = mode_floating;
			drag.x = drag.y = 0;
			swim_nr_ticks_same_float = swim_prev_float_y = 0;
			float_mode = FLOAT_MODE_RISING;

			return;
		}
		
		if (swim_prev_float_y == float_surface_y) {
			swim_nr_ticks_same_float++;
			if (swim_nr_ticks_same_float > 3) {
				swim_nr_ticks_same_float = 0;
				float_surface_y = -10;
				swim_prev_float_y = -9;
			}
		}
		swim_prev_float_y = float_surface_y;
		
		SWIM_MODE_TOP_LEFT_Y_WATER = 500000;
		
		var y_mul:Float = 1;
		var x_mul:Float = 1;
		
		var l_percent:Float = energy_bar.get_LIGHT_percentage();
		
		if (l_percent > 0.5) { // Move y faster
			y_mul = 1 + 0.5 * ((l_percent - 0.5) / 0.5);
			x_mul = 1 - 0.25 * ((l_percent - 0.5) / 0.5);
		} else if (l_percent <= 0.5) { // move x faster
			y_mul = 1 - 0.25 * ((0.5 - l_percent) / 0.5);
			x_mul = 1 + 0.5 * ((0.5 - l_percent) / 0.5);
		}
		
		
		if (swim_ignore_max_vel_ticks > 0) swim_ignore_max_vel_ticks  -- ;
		if (R.input.jpA1) {
			velocity.y = -C_swimming_sink_vel * y_mul * 1.65;
			swim_ignore_max_vel_ticks = 5;
			boost_water_jump = 15; // Boosts jumping out of surface
		}
		
		
		if (fctr_change_swim_dirs > 0) fctr_change_swim_dirs --;
		if (fctr_change_swim_dirs < 0) fctr_change_swim_dirs ++;
		if (R.input.left && !R.input.right) {
				facing = FlxObject.LEFT;
			if (acceleration.x > 0) acceleration.x = 0;
			if (fctr_change_swim_dirs <= 0) {
				fctr_change_swim_dirs = -30;
				if (velocity.x > -C_swimming_move_vel*x_mul) {
					if (velocity.x > -C_swimming_move_min_vel) {
						velocity.x = -C_swimming_move_min_vel;
					}
					acceleration.x = -C_swimming_move_accel;
				} else {
					velocity.x = -C_swimming_move_vel*x_mul;
				}
			}
		} else if (R.input.right && !R.input.left) {
				facing = FlxObject.RIGHT;
			if (acceleration.x < 0) acceleration.x = 0;
			if (fctr_change_swim_dirs >= 0) {
				fctr_change_swim_dirs = 30;
				if (velocity.x < C_swimming_move_vel*x_mul) {
					if (velocity.x < C_swimming_move_min_vel) {
						velocity.x = C_swimming_move_min_vel;
					}
					acceleration.x = C_swimming_move_accel;
				} else {
					velocity.x = C_swimming_move_vel*x_mul;
				}
			}
		} else {
			acceleration.x = 0;
			if (Math.abs(velocity.x) > 0) {
				if (velocity.x > 0) {
					velocity.x -= 0.5;
					if (velocity.x < 0) velocity.x = 0;
				} else {
					velocity.x += 0.5;
					if (velocity.x > 0) velocity.x = 0;
				}
			}
		}
		
		// Handle vertical movement
		if (R.input.down) {
			if (velocity.y < C_swimming_sink_vel*y_mul) {
				acceleration.y = C_swimming_move_accel;
			} else {
				velocity.y = C_swimming_sink_vel*y_mul;
				acceleration.y = 0;
			}
		} else {
			acceleration.y = 0;	
			if (has_bubble) {
				swim_ignore_max_vel_ticks = 2;
				velocity.y -= 2 * C_swimming_rise_accel;
			}
			if (velocity.y > C_swimming_max_rise_vel) {
				velocity.y -= C_swimming_rise_accel;
				if (velocity.y <= C_swimming_max_rise_vel && swim_ignore_max_vel_ticks <= 0) velocity.y = C_swimming_max_rise_vel;
			} else if (velocity.y < C_swimming_max_rise_vel && swim_ignore_max_vel_ticks <= 0) {
				velocity.y += 4;
				if (velocity.y > C_swimming_max_rise_vel) {
					velocity.y = C_swimming_max_rise_vel;
				}
			}
		}
		
		shield_position_helper();

		if (shield_dir == 0) { jump_anim_helper("u", "s"); }
		else if (shield_dir == 1) { jump_anim_helper("r", "s"); }
		else if (shield_dir == 2) { jump_anim_helper("d", "s"); }
		else if (shield_dir == 3) { jump_anim_helper("l", "s"); }
		else if (shield_dir == 4) { jump_anim_helper("n", "s"); }
	}
	
	public function is_in_wall_mode():Bool {
		if (mode == mode_hang) {
			return true;
		}
		return false;
	}
	public function is_wall_hang_points_in_object(o:FlxObject):Bool {
		var old:Float = wall_hang_pt.y;
		if (o.overlapsPoint(wall_hang_pt)) return true;
		wall_hang_pt.y += height / 2;
		if (o.overlapsPoint(wall_hang_pt)) return true;
		wall_hang_pt.y += height / 2;
		if (o.overlapsPoint(wall_hang_pt)) return true;
		wall_hang_pt.y = old;
		return false;
	}
	public function in_tm_bg(dir:Int,clouds_are_ok:Bool=false,bg2Too:Bool=false):Bool {
		var extend:Float = 4;
		var t_val:Int = 0x0000;
		if (clouds_are_ok) { // clouds don't 'count'
			t_val = 0x0100;
		}
		
		var a:Array<FlxTilemapExt> = [parent_state.tm_bg];
		if (bg2Too) {
			a.push(parent_state.tm_bg2);
		}
		
		for (tm in a) {
		if (dir == 0) {
			if (tm.getTileCollisionFlags(last.x, y-extend) > t_val || tm.getTileCollisionFlags(last.x + width / 2, y-extend) > t_val || tm.getTileCollisionFlags(last.x + width, y-extend) > t_val) {
				return true;
			}
		} else if (dir == 1) {
			if (tm.getTileCollisionFlags(x + width+extend, last.y+1) > t_val || tm.getTileCollisionFlags(x + width+extend, last.y + height / 2) > t_val || tm.getTileCollisionFlags(x + width+extend, last.y + height-2) > t_val) {
				return true;
			}
		} else if (dir == 2) {
			if (tm.getTileCollisionFlags(last.x, y+height+1) > t_val || tm.getTileCollisionFlags(last.x + width / 2, y+height+1) > t_val || tm.getTileCollisionFlags(last.x + width, y+height+1) > t_val) {
				return true;
			}
		} else {
			if (tm.getTileCollisionFlags(x-extend , last.y+1) > t_val || tm.getTileCollisionFlags(x-extend , last.y + height / 2) > t_val || tm.getTileCollisionFlags(x-extend , last.y + height-2) > t_val) {
				return true;
			}
			
		}
		}
		return false;
	}
	
	private var hang_speed:Int = 40;
	public var push_off_ctr:Int = 0;
	private var hang_restore:Bool = false;
	public var hang_ignore_noclimb_tiles:Bool = false;
	private var fctr_faster_air_control:Int = 0; // Makes getting two-wide lips easier
	
	private var can_anim_jump:Bool = false;
	private var can_anim_fall:Bool = false;
	private function update_mode_hang():Void {
		acceleration.y = 0;
		acceleration.x = 0;
		velocity.x = 0;
		offset.y = frameHeight - height - 5;
		// slow down when jumping up wall
		if (velocity.y > hang_speed) {
			velocity.y = hang_speed;
		} else {
			if (velocity.y < 0) {
				velocity.y += 4;
			} else {
				velocity.y += 2;
			}
		}
		
		var gas_tid:Int =  0;
		if (facing == FlxObject.LEFT) {
			gas_tid =  parent_state.tm_bg.getTileID(x - 2, y + height / 2);
		} else {
			gas_tid =  parent_state.tm_bg.getTileID(x +width+ 2, y + height / 2);
		}
		if (HF.array_contains(HelpTilemap.hard_gasdark, gas_tid)) {
			if (RESET_status_gassed > 0) {
				RESET_status_gassed = 0;
			} else {
				RESET_status_gassed--;
				solid_gassed = true;
			}
		} else if (HF.array_contains(HelpTilemap.hard_gaslight, gas_tid)) {
			if (RESET_status_gassed < 0) {
				RESET_status_gassed = 0;
			} else {
				RESET_status_gassed ++;
				
				solid_gassed = true;
			}
		}
		
		
		// Make sure shield faces away from wall?
		// Figure out transitioning up onto the wall, into a crawlspace or standing
		if (input.jpA1) {
			if (facing == FlxObject.RIGHT) {
				if (R.input.left) fctr_faster_air_control = 23;
				velocity.x = -C_base_vx*0.95;
				velocity.y = C_base_jump_vy * 1.15;
				touching  = FlxObject.RIGHT;
			} else if (facing == FlxObject.LEFT) {
				
				if (R.input.right) fctr_faster_air_control = 23;
				velocity.x = C_base_vx*0.95;
				velocity.y = C_base_jump_vy*1.15;
				touching  = FlxObject.LEFT;
			}
			if (R.access_opts[12]) {
				velocity.x *= .4;
			}	
			
			can_anim_fall = can_anim_jump = true;
			if (!armor_on) offset.y = frameHeight - height;
			mode = mode_main;
			// Want to give some wiggle room for direction
			state_hor_move = 2;
		} else {
			// Go back to "falling" if we aren't on a wall or if we toucht he ground
			if (!force_wall_hang &&
				parent_state.tm_bg.getTileCollisionFlags(wall_hang_pt.x, wall_hang_pt.y) != FlxObject.ANY && 
				parent_state.tm_bg.getTileCollisionFlags(wall_hang_pt.x, wall_hang_pt.y + height) != FlxObject.ANY &&
				parent_state.tm_bg.getTileCollisionFlags(wall_hang_pt.x, wall_hang_pt.y + height/2) != FlxObject.ANY &&
				parent_state.tm_bg2.getTileCollisionFlags(wall_hang_pt.x, wall_hang_pt.y) != FlxObject.ANY && 
				parent_state.tm_bg2.getTileCollisionFlags(wall_hang_pt.x, wall_hang_pt.y + height) != FlxObject.ANY &&
				parent_state.tm_bg2.getTileCollisionFlags(wall_hang_pt.x, wall_hang_pt.y + height/2) != FlxObject.ANY) {
					mode = mode_main;
					state_hor_move = 2;
			}
			
			for (_tm in [parent_state.tm_bg,parent_state.tm_bg2]) {
				if (HF.array_index_of(Player.noclimb_tiles, _tm.getTileID(wall_hang_pt.x, wall_hang_pt.y)) != -1 ||
						HF.array_index_of(Player.noclimb_tiles, _tm.getTileID(wall_hang_pt.x, wall_hang_pt.y + height)) != -1  ||
						HF.array_index_of(Player.noclimb_tiles, _tm.getTileID(wall_hang_pt.x, wall_hang_pt.y + height / 2)) != -1) {

					if (hang_ignore_noclimb_tiles) {
						hang_ignore_noclimb_tiles = false;
					} else {
						mode = mode_main;
						state_hor_move = 2;
						break;
					}
				}
			}
			
			if (isTouching(FlxObject.DOWN)) {
				mode = mode_main;
				state_hor_move = 0;
			}
			
			
			// "push off" the wall if we hold the opposite direction long enough
			if (facing == FlxObject.LEFT) {
				if (input.right) {
					push_off_ctr ++;
				} else {
					push_off_ctr = 0;
				}
				
			} else if (facing == FlxObject.RIGHT) {
				if (input.left) {
					push_off_ctr ++;
				} else {
					push_off_ctr = 0;
				}
			}
			if (R.speed_opts[5] && R.input.down) {
				push_off_ctr = C_PUSH_OFF_TICKS + 1;
			}
			if (push_off_ctr > C_PUSH_OFF_TICKS) {
				push_off_ctr = 0;
				if (facing == FlxObject.LEFT) {
					velocity.x = 10;
					if (R.speed_opts[5]) velocity.x = 50;
				} else if (facing == FlxObject.RIGHT) {
					velocity.x = -10;
					if (R.speed_opts[5]) velocity.x = -50;
				}
				mode = mode_main;
				state_hor_move = 2;
			}
		}
		
		// We fell off the wall
		if (mode == mode_main) {
			offset.y = frameHeight - height;
			can_anim_fall = true;
			acceleration.y = C_base_ay;
			if (touching != FlxObject.DOWN) {
				offset.y = jump_anim_y_offset;
				if (input.right) {
					facing = FlxObject.RIGHT;
					if (velocity.y < 0) {
						can_anim_jump = false; jump_anim_state = 1;
						if (R.input.up) { jump_anim_helper("u", "j"); }
						else if (R.input.down) { jump_anim_helper("d", "j"); }
						else { jump_anim_helper("r", "j"); }
					} else {
						jump_anim_helper("r", "f");
					}
				} else if (input.left) {
					facing = FlxObject.LEFT;
					
					if (velocity.y < 0) {
						can_anim_jump = false; jump_anim_state = 1;
						if (R.input.up) { jump_anim_helper("u", "j"); }
						else if (R.input.down) { jump_anim_helper("d", "j"); }
						else { jump_anim_helper("l", "j"); }
					} else {
						jump_anim_helper("l", "f");
					}
				} else {
					
					if (velocity.y < 0) {
						can_anim_jump = false; jump_anim_state = 1;
						if (R.input.up) { jump_anim_helper("u", "j"); }
						else if (R.input.down) { jump_anim_helper("d", "j"); }
						else { jump_anim_helper("n", "j"); }
					} else {
						jump_anim_helper("n", "f");
					}
				}
			} 
			
			return;
		}
		if (fctr_prevent_enter_floating <= 0 && try_to_enter_floating_mode) {
			mode = mode_floating;
			offset.y = frameHeight - height;
			float_mode = FLOAT_MODE_RISING;
			var ts:TestState = cast parent_state;
			//ts.water_splash.dispatch(10, x + width / 2, float_surface_y, 6, 320, -90, 80, 60, 0.5, 0.5);
			//ts.water_splash.dispatch(10, x + width / 2, y +height, 6, 320, -90, 80, 60, 0.5, 0.5);
			R.sound_manager.play(SNDC.splash,0.2);
		} 
		try_to_enter_floating_mode = false;
		//var fso:Int = 0; // force shield out
		//if (facing == FlxObject.LEFT) {
			//if (!R.input.left && !R.input.down && !R.input.up && !R.input.right) {
				//fso = 1;
			//}
		//} else {
			//if (!R.input.left && !R.input.down && !R.input.up && !R.input.right) {
				//fso = 2;
			//}
		//}
		/* Determine animation to play */
		if (!shield_fixed || shieldless_sprite) {
			
			if (shieldless_sprite) {
				facing == FlxObject.RIGHT ? animation.play("crx") : animation.play("clx");
			} else if (input.up) {
				facing == FlxObject.RIGHT ? animation.play("cru") : animation.play("clu");
			} else if (input.down) { 
				facing == FlxObject.RIGHT ? animation.play("crd") : animation.play("cld");
			} else if (input.right) { // new here
				facing == FlxObject.RIGHT ? animation.play("crr") : animation.play("clr");
			} else if (input.left) {
				facing == FlxObject.RIGHT ? animation.play("crl") : animation.play("cll");
			} else {
				facing == FlxObject.RIGHT ? animation.play("crn") : animation.play("cln");
			}
		} else {
			if (shield_dir == 0) {
				facing == FlxObject.RIGHT ? animation.play("cru") : animation.play("clu");
			} else if (shield_dir  == 1) {
				facing == FlxObject.RIGHT ? animation.play("crr") : animation.play("clr") ;
			} else if (shield_dir  == 2) {
				facing == FlxObject.RIGHT ? animation.play("crd") : animation.play("cld");
			} else if (shield_dir == 3) {
				facing == FlxObject.RIGHT ? animation.play("crl") : animation.play("cll");
			} else if (shield_dir  == 4) {
				facing == FlxObject.RIGHT ? animation.play("crn") : animation.play("cln");
			}
		}
		
		
		/* Set logical shield position */
		if (!shield_fixed || (FORCE_SHIELD_DIR != -1)) {
			if (input.up) {
				set_shield_position(FlxObject.UP); 
			} else if (input.down) {
				set_shield_position(FlxObject.DOWN);
			} else if (input.right) {
				set_shield_position(FlxObject.RIGHT);
			} else if (input.left) {
				set_shield_position(FlxObject.LEFT);
			} else { // Set logic shield to face away from wall
				set_shield_position(FlxObject.NONE);
			}
		}
		
	}
	
	/**
	 * Force us to be in the ground jump state, to ignore air horizontal motion, and more 
	 * importantly make the player not play a falling anim when walking down
	 * left-facing 45 slopes
	 */
	private var force_down_vel_ticks:Int = 0;
	/**
	 * Basically disables variable height jumping (used for "bouncing" player)
	 */
	private var force_jump_up_ticks:Int = 0;
	/**
	 * Doesn't let you collide with aceling, used in conjunction with pushing you off of one
	 * when you hit to stop the "sliding down a sloped ceiling" issue
	 */
	private var fctr_no_collide_ceiling:Int = 10;
	/**
	 * Gives a delay in switching diretcions in mid-air - to make jumping onto a wall easier
	 */
	private var fctr_air_hor_change_delay:Int = 0;	
	private var fctr_extra_jump_dir:Int = 0;
	private var fctr_extra_jump:Int = 0;
	private var force_wall_hang:Bool = false;
	private var fctr_drop_through_clouds:Int = 0; // Hold to drop through cloud
	
	/** Use with caution **/
	private var hang_forced_facing:Int = -1;
	
	public function activate_wall_hang():Void {
		//if (hang_forced_facing == -1) { 
		//	hang_forced_facing = facing;
		//}
		//facing = hang_forced_facing;
	
		force_wall_hang = true;
	}
	public function give_more_air_vel_change_delay(ticks:Int):Void {
		if (R.input.left) {
			fctr_air_hor_change_delay = ticks;
		} else if (R.input.right) {
			fctr_air_hor_change_delay = -ticks;
		}
	}
	
	private var ice_x_accel_factor:Float = 1.5;
	private var ice_x_drag:Float = 1;
	private var ice_max_x_vel_ext:Int = 70;
	private var ice_reduce_hor_push_drag:Bool = false;
	
	public var last_cam_y:Float = 0;
	private var cam_deadzone_offset:Int = 0;
	private var orig_cam_deadzone_offset:Int = -1;
	private function update_mode_main():Void 
	{
		
		if (R.access_opts[2]) {
			update_ACCESS_float_motion();
		} else {
			

		var gas_tid:Int = -1;
		var gas_ct:Int = 0;
		if (R.input.left) {
			if (0x1111 == parent_state.tm_bg.getTileCollisionFlags(x - 2, y + height / 2)) {
				gas_tid = parent_state.tm_bg.getTileID(x - 2, y + height / 2);
			}
		} else if (R.input.right) {
			if (0x1111 == parent_state.tm_bg.getTileCollisionFlags(x +width + 2, y + height / 2)) {
				gas_tid = parent_state.tm_bg.getTileID(x +width + 2, y + height / 2);
			}	
		}
		if (gas_tid >= 0) {
			if (HF.array_contains(HelpTilemap.hard_gasdark, gas_tid)) {
				gas_ct--;
				solid_gassed = true;
			} else if (HF.array_contains(HelpTilemap.hard_gaslight, gas_tid)) {
				gas_ct++;
				solid_gassed = true;
			}
		}
		
		var gas_tid2:Int = 0;
		gas_tid = parent_state.tm_bg.getTileID(x, y + height +2);
		gas_tid2 = parent_state.tm_bg.getTileID(x +width, y + height +2);
		
		if (HF.array_contains(HelpTilemap.hard_gasdark, gas_tid) || HF.array_contains(HelpTilemap.hard_gasdark, gas_tid2) ) {
			gas_ct--;
			
			solid_gassed = true;
		} else if (HF.array_contains(HelpTilemap.hard_gaslight, gas_tid) || HF.array_contains(HelpTilemap.hard_gaslight, gas_tid2)) {
			gas_ct++;
			solid_gassed = true;
		}
		
		if (gas_ct != 0) {
			if (gas_ct < 0 && RESET_status_gassed > 0) {
				RESET_status_gassed = 0;
			} else if (gas_ct > 0 && RESET_status_gassed < 0) {
				RESET_status_gassed = 0;
			} else {
				RESET_status_gassed = gas_ct;
			}
		}

			
			
		if (state_hor_move == 0) {
			if (R.input.jpSit && !armor_on && (energy_bar.hiddenForInactive || energy_bar.cutscene_mode == 0)) {
				if (!R.input.left && !R.input.right && velocity.x == 0) {
					mode = mode_sit;
					energy_bar.force_hide = true;
					energy_bar.dont_move_cutscene_bars = true;
					energy_bar.allow_move = false;
					return;
				}
			}
			// ICE LOGIC
			var in_ice:Bool = false;
			if (HelpTilemap.floor_ice != []) {
				var ice_1:Int = parent_state.tm_bg.getTileID(R.player.x, R.player.y + R.player.height + 1);
				var ice_2:Int = parent_state.tm_bg.getTileID(R.player.x + R.player.width, R.player.y + R.player.height + 1);
				if (HF.array_contains(HelpTilemap.floor_ice, ice_1) || HF.array_contains(HelpTilemap.floor_ice, ice_2)) {
					in_ice = true;
				}
			}
			if (in_ice) {
				ice_reduce_hor_push_drag = true;
				C_base_vx += ice_max_x_vel_ext;
			} else {
				ice_reduce_hor_push_drag = false;
			}
			
			if (fctr_turn > 0) fctr_turn --;
			if (input.left && !input.right) {
				if (facing == FlxObject.RIGHT) { // Pause when turning
					//state_hor_move = 1;
					fctr_turn = 5;
				} else if (fctr_turn <= 0) { 
					if (velocity.x > -C_init_vx) { // Accelerate to terminal x vel, by starting at a minimum vel
						if (!in_ice) {
							velocity.x = -C_init_vx;
						}
						acceleration.x = -C_base_ax;
						if (in_ice) acceleration.x /= ice_x_accel_factor;
					} else if (velocity.x <= -C_base_vx) { // Cap x_vel at a max
						if (in_ice) {
							velocity.x += 20 / ice_x_accel_factor;
						} else {
							velocity.x += 20;
							//if (energy_bar.get_LIGHT_percentage() <= 0.1) velocity.x += 15;
						}
						if (velocity.x > -C_base_vx) velocity.x = -C_base_vx;
					} else {
						acceleration.x = -C_base_ax;
						if (in_ice) acceleration.x /= ice_x_accel_factor;
					}
					
					if (!isTouching(FlxObject.DOWN)) {
						if (force_down_vel_ticks > 0) {
							force_down_vel_ticks--;
							touching |= FlxObject.DOWN;
						} else {
							state_hor_move = 2;
						}
					}
					// Walk down/up slopes
					if (isTouching(FlxObject.RIGHT) && isTouching(FlxObject.DOWN) && jump_state != js_air) {
						velocity.y = 30;
						force_down_vel_ticks = 3; //  Stop us from "falling" down a slope
						if (velocity.x <= -C_base_vx * 0.9) {
							velocity.x = -C_base_vx * 0.8;
						}
					} else if (isTouching(FlxObject.LEFT) && isTouching(FlxObject.DOWN) ) {
						if (velocity.x <= -C_base_uphill_vx && !LineCollider.player_no_slope_slow) {
							velocity.x = -C_base_uphill_vx;
						}
						LineCollider.player_no_slope_slow = false;	
					}
				} else { // fctr_turn is ticking down. decrease vel instead
					acceleration.x = -480;
				}
				facing = FlxObject.LEFT;
			} else if (input.right && !input.left) {
				
				if (facing == FlxObject.LEFT) {
					//state_hor_move = 1;
					fctr_turn = 5;
				} else if (fctr_turn <= 0) {
					if (velocity.x < C_init_vx) {
						if (!in_ice) {
							velocity.x = C_init_vx;
						}
						acceleration.x = C_base_ax;
						if (in_ice) acceleration.x /= ice_x_accel_factor;
					}else if (velocity.x >= C_base_vx) {
						if (in_ice) {
							velocity.x -= 20 / ice_x_accel_factor;
						} else {
							velocity.x -= 20;
							//if (energy_bar.get_LIGHT_percentage() <= 0.1) velocity.x -= 15;
						}
						if (velocity.x < C_base_vx) velocity.x = C_base_vx;
					} else {
						acceleration.x = C_base_ax;
						if (in_ice) acceleration.x /= ice_x_accel_factor;
					}
					if (!isTouching(FlxObject.DOWN)) {
						
						if (force_down_vel_ticks > 0) {
							force_down_vel_ticks--;
						} else {
							//Log.trace("hi");
							state_hor_move = 2;
						}
					}
					
					if (isTouching(FlxObject.LEFT) && isTouching(FlxObject.DOWN) && jump_state != js_air) {
						velocity.y = 30;
						//if (LineCollider.player_touching) {
							//velocity.y = 45;
						//}
						
						force_down_vel_ticks = 3; //  Stop us from "falling" down a slope
						if (velocity.x >= C_base_vx * 0.9) {
							velocity.x = C_base_vx * 0.8;
						}
						
					} else if (isTouching(FlxObject.RIGHT) && isTouching(FlxObject.DOWN) ) {
						if (velocity.x >= C_base_uphill_vx && !LineCollider.player_no_slope_slow) {
							velocity.x = C_base_uphill_vx;
						}
						
						LineCollider.player_no_slope_slow = false;	
					}
					
				}else { // fctr_turn is ticking down. decrease vel instead
					acceleration.x = 480;
				}
				facing = FlxObject.RIGHT;
			} else {
				acceleration.x = 0;
				if (Math.abs(velocity.x) < 15) {
					velocity.x = 0;
				} else {
					var decel_amt:Float = 13;
					if (in_ice) decel_amt = ice_x_drag;
					if (velocity.x > 0) {
						velocity.x -= decel_amt;
					} else {
						velocity.x += decel_amt;
					}
				}
			}
			
			
			//Log.trace(FlxG.camera.deadzone.y);
			// Scroll back to normal on FLAT LAND or when STANDING STILL
			if (!armor_on && !TestState.citycam_on) {
			var cam_dead_top:Int = 60;
			if (last_cam_y == FlxG.camera.scroll.y && (touching == FlxObject.DOWN || velocity.x == 0) && FlxG.camera.deadzone.y != cam_dead_top) {
				if (Std.int(FlxG.camera.deadzone.y) > cam_dead_top) {
					FlxG.camera.deadzone.y -= 1;
				} else if (Std.int(FlxG.camera.deadzone.y) < cam_dead_top) {
					FlxG.camera.deadzone.y += 1;
				} 
			} else if (LineCollider.player_touching) {
				var c_dy:Float = FlxG.camera.scroll.y - last_cam_y;
				if (c_dy > 0) { // going down. shift deadzone down.
					if (c_dy < 0.80) {
						if (FlxG.camera.deadzone.y < cam_dead_top+44) {
							FlxG.camera.deadzone.y += 3;
						}
					}
				} else if (c_dy < 0) {
					if (c_dy > -0.80) {
						if (FlxG.camera.deadzone.y > cam_dead_top-44) {
							FlxG.camera.deadzone.y -= 4;
						}
					}
				}
				
			}
			}
			last_cam_y = FlxG.camera.scroll.y;
			
			if (in_ice) {
				C_base_vx -= ice_max_x_vel_ext;
			}
		} else if (state_hor_move == 1) { // VESTIGIAL MODE!!
			state_hor_move = 2;
		} else if (state_hor_move == 2) { // AIR MOVE MODE!!!
			if (fctr_faster_air_control > 0) fctr_faster_air_control --;
			if (jump_state == js_ground) {
				state_hor_move = 0;
				fctr_faster_air_control = 0;
				acceleration.x = 0; 
			} else  { // give some air-draggyness when you want to jump up a wall
				if (input.right && !input.left) {
					if (fctr_air_hor_change_delay < 0) {
						fctr_air_hor_change_delay++;
					} else {
						facing = FlxObject.RIGHT;
						if (velocity.x < C_base_vx) {
							//Give a little more control when turning directions from max speed

							if (velocity.x < -C_base_vx  * 0.43) { // 0.43
								//velocity.x = -C_base_vx * C_AIR_TURN_DAMPING;
								velocity.x += C_AIR_TURN_DAMPING;
								if (fctr_faster_air_control > 0) velocity.x /= 2;
							}
							acceleration.x = C_AIR_ACCEL_X;
						} else {
							acceleration.x = 0;
						}
					}
				} else if (input.left && !input.right) {
					if (fctr_air_hor_change_delay > 0) {
						fctr_air_hor_change_delay --;
					} else {
						facing = FlxObject.LEFT;
						if (velocity.x > -C_base_vx) {
							if (velocity.x > C_base_vx  * 0.43) {
								//velocity.x = C_base_vx * C_AIR_TURN_DAMPING;
								velocity.x -= C_AIR_TURN_DAMPING;
								if (fctr_faster_air_control > 0) velocity.x /= 2;
							}
							acceleration.x = -C_AIR_ACCEL_X;
						} else {
							acceleration.x = 0;
						}
					}
				} else {
					air_drag();
					acceleration.x = 0;
				}
			}
		}
		
		update_mode_main_jump();
		}
		
		/* Try to enter floating mode in water */
		if (!no_float_till_jump_or_under && fctr_prevent_enter_floating <= 0 && try_to_enter_floating_mode) {
			mode = mode_floating;
			offset.y = frameHeight - height;
			float_mode = FLOAT_MODE_RISING;
			velocity.y *= C_water_enter_vy_dampen;
			if (velocity.y > 225) {
				velocity.y = 225;
			}
			if (shield_dir == 2) {
				velocity.y = 50;
			}
			acceleration.y *= 0.8;
			
			var ts:TestState = cast parent_state;
			//ts.water_splash.dispatch(10, x + width / 2, y +height, 6, 320, -90, 80, 60, 0.5, 0.5);
			if (velocity.y > 60 || shield_dir == 2) {
				ts.water_splash.dispatch(10, x + width / 2, float_surface_y, 6, 320, -90, 80, 60, 0.5, 0.5);
				R.sound_manager.play(SNDC.splash);
			} else {
				float_mode = FLOAT_MODE_STABLE;
			}
			
		} else if (try_to_enter_floating_mode) { 
			
			if (y + 8 > float_surface_y) { 
				no_float_till_jump_or_under = false;
			}
			try_to_enter_floating_mode = false;
		} else { // Not overlapping a water tile, so allow entering water with normal coditions
			no_float_till_jump_or_under = false;
		}
		
		
		/* Figure out animation to play*/
		shield_position_helper();
		
		
		if (jump_state == js_ground) {
			if (!shield_fixed) {
				if (armor_on) {
					ground_anim_helper("n");
				} else {
					if (input.up) {
						ground_anim_helper("u");
					} else if (input.down) {
						ground_anim_helper("d");
					} else if (input.right && !input.left) {
						ground_anim_helper("r");
					} else if (input.left && !input.right) {
						ground_anim_helper("l");
					} else {
						ground_anim_helper("n");
					} 
				}
			} else { // shield if xied
				fixed_shield_ground_anim_helper(0, "u");
				fixed_shield_ground_anim_helper(1, "r");
				fixed_shield_ground_anim_helper(2, "d");
				fixed_shield_ground_anim_helper(3, "l");
				fixed_shield_ground_anim_helper(4, "n");
			}
			
			if (!armor_on && animation.curAnim != null && animation.curAnim.name.charAt(0) == "w") {
				
				var lp:Float = energy_bar.get_LIGHT_percentage();
				if (lp >= 0.4 && lp <= 0.6) {
					animation.curAnim.frameRate = Std.int(fr_walk_neutral);
				} else if (lp < 0.4) {
					if (lp < 0.1) lp = 0.1;
					var p:Float = 1 - ((lp - 0.1) / 0.3);
					if (p == 1) p = 0.99;		
					animation.curAnim.frameRate = Std.int(fr_walk_neutral + 1 + Std.int(p * (fr_walk_dark - fr_walk_neutral)));
				} else if (lp > 0.6) {
					if (lp > 0.9) lp = 0.9;
					lp = 1 - ((0.9 - lp) / 0.3);
					if (lp == 1) lp = 0.99;
					animation.curAnim.frameRate = Std.int(fr_walk_neutral - 1 - Std.int(lp * (fr_walk_neutral - fr_walk_light)));
				}
			}
		} else if (jump_state == js_air) {
			
			if (over_cloud) {
				over_cloud = false;
				activate_npc_bubble("d_off", true);
			}
			
			if (animation.curAnim != null) {
				var c:String = animation.curAnim.name.charAt(0);
				if (c != "j" && c != "f") {
					jump_anim_state = 0;
				}
			}
			if (jump_anim_state == 0) {
				if (can_anim_jump && velocity.y < 0) {
					play_jump_anim();
					can_anim_jump = false;
					jump_anim_state = 1;
				} else if (can_anim_fall && velocity.y > 0) {
					play_jump_anim();
					can_anim_fall = false;
					jump_anim_state = 1;
				}
			} else if (jump_anim_state == 1) {
				// In the middle of jump transition anim
				
				if (animation.curAnim != null) {
					
					if ("r" == animation.curAnim.name.charAt(1)) {
						if (R.input.left) {
							play_jump_anim();
							jump_anim_state = 2;
						} else if (R.input.down || R.input.up) {
							play_jump_anim();
							jump_anim_state = 2;
						}
					} else {
						if (R.input.right) {
							play_jump_anim();
							jump_anim_state = 2;
						} else if (R.input.down || R.input.up) {
							play_jump_anim();
							jump_anim_state = 2;
						}
					}
				}
				if ((animation.curAnim != null && animation.curAnim.finished) || (animation.curAnim == null)) { // wait for initial to finish...
					jump_anim_state = 2;
					
				}
			} else if (jump_anim_state == 2) {
				
				play_jump_anim();
				if (velocity.y > 0 && can_anim_fall) {
					can_anim_fall = false;
					
					jump_anim_state = 1;
				} else if (velocity.y < 0 && can_anim_jump) {
					can_anim_jump = false;
					jump_anim_state = 1;
				} else { // Go immediately to the end of each anim
					if (animation.curAnim != null) {
						animation.frameIndex = animation.curAnim._frames[animation.curAnim.numFrames - 1];
					}
				}
			}
		} 
		
	}
	
	private var jump_anim_state:Int = 0;
	
	public var FORCE_FALL_THROUGH_TOP:Bool = false;
	private var fctr_push_into_ceiling:Int = 0;
	public var force_no_var_jump:Bool = false;
	function update_mode_main_jump():Void 
	{
		/* Handle jump states */
		
		if (fctr_no_collide_ceiling > 0) {
			no_collide_ceil_slopes = true;
			fctr_no_collide_ceiling --;
		} else {
			no_collide_ceil_slopes = false;
		}
		if (jump_state == js_ground) {
			if (!armor_on) height = C_h;
			var do_down:Bool = false;
			if (R.input.down) {
				if (R.input.jpA1 || fctr_touch_ground > 0) {
					fctr_drop_through_clouds = 20;
					if (fctr_touch_ground > 0) {
						fctr_touch_ground = 0;
					}
				} else {
					fctr_drop_through_clouds  = 0;
				}
				
				// Check if slope below us, if running in right dir, go through the top tile
				var slope_id:Int = tm_bg.getTileID(x + width / 2, y + height + 2);
				if (touching == FlxObject.DOWN && HF.array_contains(HelpTilemap.top, tm_bg2.getTileID(x+width/2,y+height+5))) {
					if (velocity.x > 35 && HF.array_contains(HelpTilemap.r_floor_slopes, slope_id)) {
						y += 4;
						last.y = y + 3.6;
					} else if (velocity.x < -35 && HF.array_contains(HelpTilemap.l_floor_slopes, slope_id)) {
						y += 4;
						last.y = y + 3.6;
					}
				} 
			} else {
				fctr_drop_through_clouds = 0;
			}
			
			//0x10011  b/c 0x10000 = slopes , 0x11 = left/right. So don't fall if it's a slope or solid tile.
			// Check if a top tile is beneath us
			var has_top:Bool = false;
			for (__tm in [tm_bg,tm_bg2,tm_fg]) {
				if (HF.array_contains(HelpTilemap.top, __tm.getTileID(x, y + height + 2)) || HF.array_contains(HelpTilemap.top, __tm.getTileID(x + width, y + height + 2))) {
					has_top = true;
					if (!over_cloud) {
						over_cloud = true;
						activate_npc_bubble("d_on", true);
					}
				}
			}
			// If so, don't fall through if below us is a solid or a slope tile. otherwise fall
			if (has_top) {
				for (__tm in [tm_bg,tm_bg2,tm_fg]) {
					if (__tm.getTileCollisionFlags(x+1, y + height + 2) & 0x10011 == 0 && __tm.getTileCollisionFlags(x + width-1, y + height + 2) & 0x10011  == 0 ) {
						do_down = true;
					} else {
						do_down = false;
						break;
					}
				}
			} else {
				if (over_cloud) {
					over_cloud = false;
					activate_npc_bubble("d_off", true);
				}
			}
			
			
			
			if ((FORCE_FALL_THROUGH_TOP && do_down) || (R.input.down && fctr_drop_through_clouds >= 20 && do_down)) {
				fctr_drop_through_clouds = 0;
				y += 4; last.y = y + 7;
				jump_state = js_air;
				can_anim_fall = true;
				touching = FlxObject.NONE;
				
				if (FORCE_FALL_THROUGH_TOP )
				velocity.y = 150;
				
			} else if (input.jpA1 && isTouching(FlxObject.DOWN)) {
				velocity.y = C_base_jump_vy;
				touching  = FlxObject.DOWN;
				if (no_float_till_jump_or_under) { // Jump a little slower if we're jumping from the water
					velocity.y *= 0.8;
				}
				if (velocity.y > -224 && touching_floor_slope && !is_sticky) {
					if (!armor_on) velocity.y = -224; // Fixes falling through slopes -_- WHY
				}
				can_anim_fall = can_anim_jump = true;
				jump_state = js_air;
				fctr_off_cliff = 0;
				force_down_vel_ticks = 0; // Ignore the "force us to be in ground state" if we jumped.
				if (armor_on) {
					R.sound_manager.play(SNDC.shield_md);
				}
			/* Falling off of things or being pushed upw ithout jumping */
			} else if (!isTouching(FlxObject.DOWN)) {
				jump_state = js_air;
				if (velocity.y >= 0 && last.y <= y && push_yvel >= 0) {
					can_anim_fall = true;
				} else {
					fctr_off_cliff = 0;
					can_anim_jump = true;
				}
			} else {
				fctr_off_cliff = 5;
			}
			FORCE_FALL_THROUGH_TOP = false;	
			
			if (fctr_touch_ground > 0) {
				velocity.y = C_base_jump_vy;
				jump_state = js_air;
				can_anim_fall = can_anim_jump = true;
			}
			
	
			
			if (jump_state == js_air) {
				// Moving down a left-slope sets force_down_vel_ticks because of some weird slope collision issue
				// when we start falling (but were holding right before the +x velocity kicks in) we can
				// enter this if block before force_down_vel_ticks is < 0, thus getting us stuck in this 
				// "walking on the ground in the air" situation. this fixes it. holy fucking hsit.
				if (((!R.input.right && !R.input.left) || R.input.right || R.input.left)) {
					force_down_vel_ticks = 0;
				}
				state_hor_move = 2;
			}
			
	
		} else if (jump_state == js_air) {
			
			if (!armor_on) { 
			if (height != C_h + 3) {
				height = C_h + 3;
				y -= 3;
				last.y = y;
			}
			
			height = C_h + 3;
			width = C_w - 2;
			offset.x = (C_frameW - width) / 2;
			}
			
			if (touching == FlxObject.UP) {
				if (fctr_push_into_ceiling > 0 && wind_vely == 0) {
					velocity.y = -10;
					fctr_push_into_ceiling--;
					if (R.input.left && velocity.x > 0) {
						velocity.x /= 2;
					} else if (R.input.right && velocity.x < 0) {
						velocity.x /= 2;
					}
				}
			} else {
				fctr_push_into_ceiling = 8;
			}
			
			if (!armor_on) offset.y = jump_anim_y_offset;
			
			if (fctr_extra_jump > 0 && fctr_extra_jump_dir != facing && R.input.jpA1) {
				if (!armor_on) velocity.y = C_base_jump_vy * 1.1;
				if (facing == FlxObject.RIGHT) {
					velocity.x = C_base_vx * 0.95;
				} else {
					velocity.x = -C_base_vx * 0.95;
				}
				fctr_extra_jump = -2;
			} 
			//if (!force_wall_hang) {
				//hang_forced_facing = -1;
			//}
			
			if (fctr_extra_jump > 0) fctr_extra_jump--;
			
			// Hit the ground after a jump
			if (isTouching(FlxObject.DOWN) && velocity.y >= 0) {
				jump_state = js_ground;
				if (!armor_on) {
				height = C_h; y += 3;
				width = C_w; offset.x = (C_frameW - C_w) / 2;
				}
				if (velocity.x == 0) velocity.x = 4; // bump you out of wall on right
				// Avoid issue where walking down a slope causes this section of code to fire
				if (fctr_off_cliff == 0) {
					
					if (in_tm_bg(2) || LineCollider.player_touching) {
						var spec:Int = 0;
						if (SoundZone.active_floor_sound == SNDC.player_jump_down && armor_on) {
							
						} else {
							if (old_vel_y > 20 && R.sound_manager.tickssincemapchange > 10) {
								var tidd:Int = parent_state.tm_bg.getTileID(x + 4, y + height + 2);
								if (HF.array_contains(HelpTilemap.floor_ice, tidd)) {
									R.sound_manager.play(SNDC.step_tile);
									spec = 1;
								} else {
									R.sound_manager.play(SoundZone.active_floor_sound);
								}
							}
						}
						if (old_vel_y > 20  && R.sound_manager.tickssincemapchange > 20) {
							R.TEST_STATE.player_particles.hit_dust(velocity.y, spec);
						}
					}
				}
				fctr_off_cliff = 0;
			// Variable jump height
			} else if ((!force_no_var_jump && !input.a1) && velocity.y > C_base_jump_vy / 1.1 && velocity.y < C_base_jump_vy / 6.0) {
				if (force_jump_up_ticks > 0) {
					force_jump_up_ticks --;
				} else {
					if (velocity.y < 0) {
						velocity.y += C_jump_braking;
					}
					//velocity.y = 0;
				}
			// Transition to wall hang - change offset??
			} else if (velocity.y >= -108 && (force_wall_hang || isTouching(FlxObject.LEFT) || isTouching(FlxObject.RIGHT))) {
				for (_tm in [parent_state.tm_bg2,parent_state.tm_bg]) {
					if (force_wall_hang || 
						_tm.getTileCollisionFlags(wall_hang_pt.x, wall_hang_pt.y) == FlxObject.ANY || 
						_tm.getTileCollisionFlags(wall_hang_pt.x, wall_hang_pt.y + height) == FlxObject.ANY ||
						_tm.getTileCollisionFlags(wall_hang_pt.x, wall_hang_pt.y + height / 2) == FlxObject.ANY ) {
					
						if (!hang_ignore_noclimb_tiles && (HF.array_index_of(Player.noclimb_tiles, _tm.getTileID(wall_hang_pt.x, wall_hang_pt.y)) != -1 ||
						HF.array_index_of(Player.noclimb_tiles, _tm.getTileID(wall_hang_pt.x, wall_hang_pt.y + height)) != -1  ||
						HF.array_index_of(Player.noclimb_tiles, _tm.getTileID(wall_hang_pt.x, wall_hang_pt.y + height / 2)) != -1 )) {
							if (fctr_extra_jump == -2) {
								if ( Math.abs(old_vel_x) > 80) {
									R.sound_manager.play(SNDC.step_tile, 0.6);
									//velocity.y = 0;
									FlxG.camera.shake(0.005, 0.03);
								}
									if (wall_hang_pt.x> x) {
										R.TEST_STATE.player_particles.hit_slime(false);
									} else {
										R.TEST_STATE.player_particles.hit_slime(true);
									}
									//skip_motion_ticks = 6;
								fctr_extra_jump = 7;
								fctr_extra_jump_dir = facing;
							}
							break;
						} else  {
							hang_ignore_noclimb_tiles = false;
							if (false == armor_on) {
								mode = mode_hang;
								R.player.velocity.x = 0;
								if (touching == FlxObject.LEFT) facing = FlxObject.LEFT;
								if (touching == FlxObject.RIGHT) facing = FlxObject.RIGHT;
								R.player.acceleration.x = 0;
								R.sound_manager.play(SoundZone.active_wall_sound);
								
								if (force_wall_hang) break;
								//R.sound_manager.play(SNDC.player_jump_down, 0.7);
							}
						}
					}
				}
			// Safety window when jumping from ledge
			} else {
				if (fctr_off_cliff > 0) {
					fctr_off_cliff --;
					if (input.jpA1) {
						fctr_off_cliff = 0;
						can_anim_jump = true;
						velocity.y = C_base_jump_vy;
					}
				}
			}
			// this is this way b/c i cant figure out how to fix it well 5-18-14
			if ((touching == (FlxObject.UP | FlxX.SLOPE_LEFT) && facing == FlxObject.RIGHT && R.input.right)||
				 (touching == (FlxObject.UP | FlxX.SLOPE_RIGHT) && facing == FlxObject.LEFT && R.input.left)) {
			//if ((touching == (FlxObject.UP | FlxX.SLOPE_LEFT))||
				 //(touching == (FlxObject.UP | FlxX.SLOPE_RIGHT))) {
				//y += 2;
				
				fctr_no_collide_ceiling = 12;
				//if ((facing == FlxObject.LEFT && R.input.left && (touching == (FlxObject.UP | FlxX.SLOPE_RIGHT))) || (facing == FlxObject.RIGHT && R.input.right && (touching == (FlxObject.UP | FlxX.SLOPE_LEFT)))) {
					velocity.y = 32;
					velocity.x *= 0.4;
				//}  
			}
			
			if (jump_state != js_air || mode != mode_main) {
				if (!armor_on) offset.y = frameHeight - height;
			}
			// Safety window when jumping before hitting ground
			if (input.jpA1) {
				fctr_touch_ground = 4;
			}
			if (fctr_touch_ground > 0) {
				fctr_touch_ground --;
			}
		}
		
		
		// If walking DOWN a slope and "falling" then make us not fall
		if (jump_state == js_air) {
			if (force_down_vel_ticks > 0) {
				
				jump_state = js_ground;
			}
			if (mode == mode_hang) {
				force_no_var_jump = false;
			}
		} else {
			if (jump_state != js_air) {
				force_no_var_jump = false;
			}
		}
		if (jump_state != js_air || mode != mode_main) {
			fctr_extra_jump = -2;
		}
	}
		
	public function play_idle_anim():Void {
		if (facing == FlxObject.RIGHT) {
			shieldless_sprite ? animation.play("irx",true) : animation.play("irn");
		} else {
			shieldless_sprite ? animation.play("ilx",true) : animation.play("iln");
		}
	}
	private function play_jump_anim():Void {
		// TODO: subtle bug with jumping in wind
		if (velocity.y < 0) {
			if (!shield_fixed) {
				if (input.up) {
					jump_anim_helper("u");
				} else if (input.down) {
					jump_anim_helper("d");
				} else if (input.right) {
					jump_anim_helper("r");
				} else if (input.left) {
					jump_anim_helper("l");
				} else {
					jump_anim_helper("n");
				} 
			} else {
				if (shield_dir == 0) {
					jump_anim_helper("u");
				} else if (shield_dir == 1) {
					jump_anim_helper("r");
				} else if (shield_dir == 2) {
					jump_anim_helper("d");
				} else if (shield_dir == 3) {
					jump_anim_helper("l");
				} else if (shield_dir == 4) {
					jump_anim_helper("n");
				}
			}
			if (animation.curAnim != null && animation.curAnim.name.indexOf("j") != -1) {
				
				// do something
			}
		} else {
			// from walking off a slope?? don't play falling anim
			if (!armor_on && tm_bg.getTileCollisionFlags(x+3, y + height + 2) == FlxObject.ANY && tm_bg.getTileCollisionFlags(x-3, y + height + 2) == FlxObject.ANY) {
				//Log.trace("oops");
			} else {
			if (!shield_fixed) {
				if (input.up) {
					jump_anim_helper("u","f");
				} else if (input.down) {
					jump_anim_helper("d","f");
				} else if (input.right) {
					jump_anim_helper("r","f");
				} else if (input.left) {
					jump_anim_helper("l", "f");
				} else {
					jump_anim_helper("n","f");
				} 
			} else {
				if (shield_dir == 0) {
					jump_anim_helper("u","f");
				} else if (shield_dir == 1) {
					jump_anim_helper("r","f");
				} else if (shield_dir == 2) {
					jump_anim_helper("d","f");
				} else if (shield_dir == 3) {
					jump_anim_helper("l","f");
				} else if (shield_dir == 4) {
					jump_anim_helper("n","f");
				}
			}
			}
		}
	}
	private function jump_anim_helper (s:String, prefix:String = "j"):Void { 
		if (shieldless_sprite) {
			facing == FlxObject.RIGHT ? animation.play(prefix + "rx") : animation.play(prefix + "lx");
			return;
		}
		var shield_dir:String = s;
		if (FORCE_SHIELD_DIR != -1 || shield_fixed) {
			var si:Int = 0;
			if (FORCE_SHIELD_DIR != -1) {
				si = FORCE_SHIELD_DIR;
			} else if (shield_fixed) {
				si = get_shield_dir();
			}
			switch (si) {
				case 0:
					shield_dir = "u";
				case 1:
					shield_dir = "r";
				case 2:
					shield_dir = "d";
				case 3:
					shield_dir = "l";
			}
		}
		//Log.trace(prefix + "l" + shield_dir);
		var f_idx:Int = 0;
		var old_el:Float = 0;
		if (animation.curAnim != null && animation.curAnim.name.charAt(0) == "s" && prefix == "s") {
			f_idx = animation.curAnim.curFrame;
			old_el = animation.curAnim._frameTimer;
		}
		facing == FlxObject.RIGHT ? animation.play(prefix + "r" + shield_dir, false, false, f_idx) : animation.play(prefix + "l" + shield_dir, false, false, f_idx);
		if (old_el != 0) {
			animation.curAnim._frameTimer = old_el;
		}
		
	}
	private function ground_anim_helper( s:String):Void {
		var shield_dir:String = s;
		if (FORCE_SHIELD_DIR != -1) {
			switch (FORCE_SHIELD_DIR) {
				case 0:
					shield_dir = "u";
				case 1:
					shield_dir = "r";
				case 2:
					shield_dir = "d";
				case 3:
					shield_dir = "l";
			}
		}
		if ((input.left && input.right) || (!input.left && !input.right)) {
			if (shieldless_sprite) {
				facing == FlxObject.LEFT ? animation.play("ilx") : animation.play("irx");
			} else {
				facing == FlxObject.LEFT ? animation.play("il" + shield_dir) : animation.play("ir" + shield_dir);
			}
		} else {
			
			
			// Code added so you can run in one dir, flip shield dirs, and keep the 'walk cycle' in sync
			// Also added above for swimming
			var f_idx:Int = 0;
			var old_el:Float = 0;
			if (animation.curAnim != null && animation.curAnim.name.charAt(0) == "w" && (input.left || input.right)) {
				f_idx = animation.curAnim.curFrame;
				old_el = animation.curAnim._frameTimer;
			}
			
			if (input.left) {
				
				shieldless_sprite ? animation.play("wln") : animation.play("wl"+ shield_dir, false, false, f_idx);
			} else if (input.right) {
				shieldless_sprite ? animation.play("wrn") : animation.play("wr" + shield_dir, false, false, f_idx);
			}
			
			if (old_el != 0) {
				animation.curAnim._frameTimer = old_el;
			}
			
		}
	}
	public var FORCE_SHIELD_DIR:Int = -1;
	private function fixed_shield_ground_anim_helper(_shield_dir:Int, dir:String):Void {
		if (shield_dir == _shield_dir) {
			if ((input.left && input.right) || (!input.left && !input.right)) {
				facing == FlxObject.LEFT ? animation.play("il"+dir) : animation.play("ir"+dir);
			} else {
				facing == FlxObject.LEFT ? animation.play("wl"+dir) : animation.play("wr"+dir);
			}
		}
	}
	
	/**
	 * Applied when you don't hold a direction while jumping - to decelerate you to 0.
	 */
	private function air_drag():Void 
	{
		if (Math.abs(velocity.x) > 5) {
			if (velocity.x > 0 ) {
				velocity.x -= 5;
			} else {
				velocity.x += 5;
			}
		} else {
			velocity.x = 0;
		}
	}
	
	private function add_all_animations():Void 
	{
		FlxAnimationController.frame_splice_in_add_is_on = false;
		// walk, jump, fall, idle, climb
		// Walk Right Shield Up, etc
		//wrsu jrsu frsu irsu crsu
		// player facing (right or left)
		// shield dir = urdl, or n for none
		
		// Walk					
		//						   Jump
		animation.add("wru", [30,31,32,33,34,35,36,37],16); animation.add("jru", [150,151,152],16,false);
		animation.add("wrr", [40,41,42,43,44,45,46,47],16); animation.add("jrr", [160,161,162],16,false);
		animation.add("wrd", [50,51,52,53,54,55,56,57],16); animation.add("jrd", [170,171,172],16,false);
		animation.add("wrl", [60,61,62,63,64,65,66,67],16); animation.add("jrl", [180,181,182],16,false);
		animation.add("wrn", [20,21,22,23,24,25,26,27],16); animation.add("jrn", [190,191,192],16,false);
		
		animation.add("wlu", [90,91,92,93,94,95,96,97],16); animation.add("jlu", [210,211,212],16,false);
		animation.add("wlr", [100,101,102,103,104,105,106,107],16); animation.add("jlr", [220,221,222],16,false);
		animation.add("wld", [110,111,112,113,114,115,116,117],16); animation.add("jld", [230,231,232],16,false);
		animation.add("wll", [120,121,122,123,124,125,126,127],16); animation.add("jll", [240,241,242],16,false);
		animation.add("wln", [80, 81, 82, 83, 84, 85, 86, 87], 16); animation.add("jln", [250, 251, 252], 16, false);
		
		// Fall					   			Idle
		animation.add("fru", [153,154,155],16,false); animation.add("iru", [1]);
		animation.add("frr", [163,164,165],16,false); animation.add("irr", [2]);
		animation.add("frd", [173,174,175],16,false); animation.add("ird", [3]);
		animation.add("frl", [183,184,185],16,false); animation.add("irl", [4]);
		animation.add("frn", [193,194,195],16,false); animation.add("irn", [5]);
		
		animation.add("flu", [213,214,215],16,false); animation.add("ilu", [11]);
		animation.add("flr", [223,224,225],16,false); animation.add("ilr", [12]);
		animation.add("fld", [233,234,235],16,false); animation.add("ild", [13]);
		animation.add("fll", [243,244,245],16,false); animation.add("ill", [14]);
		animation.add("fln", [253,254,255],16,false); animation.add("iln", [15]);
		
		animation.add("irx", [0]);
		animation.add("ilx", [10]);
		animation.add("jrx", [140, 141, 142], 16, false);
		animation.add("frx", [143, 144, 145], 16, false);
		animation.add("jlx", [200, 201, 202], 16, false);
		animation.add("flx", [203,204,205], 16, false);
		animation.add("clx", [270]);
		animation.add("crx", [260]);
		// Climb (slide on wall)
		
		animation.add("cru", [261]);
		animation.add("crr", [262]);
		animation.add("crd", [263]); 
		animation.add("crl", [264]); 
		animation.add("crn", [265]); 
		
		animation.add("clu", [271]);
		animation.add("clr", [272]);
		animation.add("cld", [273]);
		animation.add("cll", [274]); 
		animation.add("cln", [275]);
		
		// Paddle (floating mode)
		//animation.add("pru", [0]);		animation.add("plu", [0]);
		//animation.add("prr", [0]); 		animation.add("plr", [0]);
		//animation.add("prd", [0]); 		animation.add("pld", [0]);
		//animation.add("prl", [0]); 		animation.add("pll", [0]);
		//animation.add("prn", [0]);		animation.add("pln", [0]);
		
		
		animation.add("sru", [370,371,372,373,374,375],8); 
		animation.add("srr", [380,381,382,383,384,385],8); 
		animation.add("srd", [390,391,392,393,394,395],8); 
		animation.add("srl", [400,401,402,403,404,405],8); 
		animation.add("srn", [360,361,362,363,364,365],8); 
		
		
		
		animation.add("slu", [420,421,422,423,424,425],8); 
		animation.add("slr", [450,451,452,453,454,455],8); 
		animation.add("sll", [430,431,432,433,434,435],8); 
		animation.add("sld", [440,441,442,443,444,445],8); 
		animation.add("sln", [410,411,412,413,414,415],8); 
		
		//animation.add("sru", [30,31,32,33,34,35,36,37],15); 
		//animation.add("srr", [40,41,42,43,44,45,46,47],15); 
		//animation.add("srd", [50,51,52,53,54,55,56,57],15);
		//animation.add("srl", [60,61,62,63,64,65,66,67],15);
		//animation.add("srn", [20,21,22,23,24,25,26,27], 15);
		
		
		
		//animation.add("slu", [90,91,92,93,94,95,96,97],15); 
		//animation.add("slr", [100,101,102,103,104,105,106,107],15);
		//animation.add("sld", [110,111,112,113,114,115,116,117],15); 
		//animation.add("sll", [120,121,122,123,124,125,126,127],15); 
		//animation.add("sln", [80,81,82,83,84,85,86,87],15);
		
		animation.add("sit_down_r", [310, 311, 312], 8,false);
		animation.add("sit_up_r", [312, 311, 310], 8,false);
		animation.add("sit_down_l", [320, 321, 322], 8,false);
		animation.add("sit_up_l", [322, 321, 320], 8,false);
		
		FlxAnimationController.frame_splice_in_add_is_on = false;
	}
	
	private function shield_position_helper():Void 
	{
		if (FORCE_SHIELD_DIR != -1) {
			input.cache_dirs();
			input.unset_dirs();
			switch (FORCE_SHIELD_DIR) {
				case 0:
					input.up = true;
				case 1:
					input.right = true;
				case 2:
					input.down = true;
				case 3:
					input.left = true;
			}
		}
		if (!shield_fixed) {
			if (input.up) {
				set_shield_position(FlxObject.UP); 
			} else if (input.down) {
				set_shield_position(FlxObject.DOWN);
			} else if (input.right && !input.left) {
				set_shield_position(FlxObject.RIGHT);
			} else if (input.left && !input.right) {
				set_shield_position(FlxObject.LEFT);
			} else {
				set_shield_position(FlxObject.NONE);
			}
		} else {
			if (shield_dir == 4) { // ??? 
				if (input.up) {
					set_shield_position(FlxObject.UP); 
				} else if (input.down) {
					set_shield_position(FlxObject.DOWN);
				} else if (input.right) {
					set_shield_position(FlxObject.RIGHT);
				} else if (input.left) {
					set_shield_position(FlxObject.LEFT);
				} 
			}
		}
		if (FORCE_SHIELD_DIR != -1) {
			input.uncache_dirs();
		}
	}
	
	// accessibility
	function update_ACCESS_float_motion():Void 
	{
		
			if (R.input.right) {
				velocity.x = C_base_vx;
			}else if (R.input.left) {
				velocity.x = -C_base_vx;
			} else {
				velocity.x = 0;
			}
			if (R.input.a1) {
				velocity.x *= 0.5;
			}
		
		//if (R.TEST_STATE.MAP_NAME.substr(0,3) == "WF_") {
		if (false) {
			acceleration.y = 350;
			if (R.input.jpUp && touching == FlxObject.DOWN) {
				velocity.y = -250;
			}
			
		} else {
		
			acceleration.y = 0;
			if (R.input.up) {
				velocity.y = C_base_jump_vy * .6;
			} else if (R.input.down) {
				velocity.y = -C_base_jump_vy*.6;
			} else {
				velocity.y = 0;
			}
			if (R.input.a1) {
				velocity.y *= 0.5;
			}
		}
		if (touching & FlxObject.DOWN != 0) {
			for (tm in [tm_bg,tm_bg2]) {
			if (HF.array_contains(HelpTilemap.top, tm.getTileID(x+ 5, y + height))) {
				y += 7;
				last.y = y;
				touching = FlxObject.NONE;
				break;
			}
			}
		}
		
	}
	
	function enter_main_from_float():Void 
	{
		mode = mode_main; /* */
		acceleration.y = C_base_ay;
		jump_state = js_air;
		state_hor_move = 2;
		drag.x = drag.y = 0;
		fctr_prevent_enter_floating = 15;
		force_jump_up_ticks = 10;
	}

	// better to be called "is not over an npc"..ugh
	public var npc_interaction_off:Bool = false;
	public function activate_npc_bubble(anim:String, allow_npc:Bool = false):Void {
		
		if (anim == "d_off" || anim == "d_on") {
			if (R.access_opts[14] == false) {
				return;
			}
		}
		
		if (npc_interaction_bubble.animation.name != anim) {
			npc_interaction_bubble.animation.play(anim);
		}
		if (anim.indexOf("disappear") != -1 ||anim.indexOf("d_off") != -1 ) {
			npc_interaction_off = false;
		} else {
			npc_interaction_off = false;
		}
		if (allow_npc) npc_interaction_off = allow_npc;
		
		npc_interaction_bubble.visible = true;
		
		
	}
	
	/**
	 * Get the player's base jump velocity. This takes energy scaling into acount.
	 * @return
	 */
	public function get_base_jump_vel():Float {
		return C_base_jump_vy;
	}
	
	public var draw_start_lock_shield_effect:Bool = false;
	private var draw_started_lock_shield_effect:Bool = false;
	private var draw_lock_shield_effect_scale:Float = 0;
	
	private var draw_hurt_effect_toggle:Bool = false;
	
	private var draw_hurt_light_transposition:Map<Int,Int>;
	private var draw_hurt_dark_transposition:Map<Int,Int>;
	private var _test:FlxSprite;
	
	public var randomize_draw_pos:Bool = false;
	public var randomize_draw_range:Int = 4;
	
	private var shader_ctr:Int = 0;
	
	private var trail_buffer:Array<Point>;
	private var trail_frame_buffer:Array<Int>;
	private var trail_ctr:Int =  0;
	
	override public function draw():Void 
	{
		/* Start trail effect */
		

		// only do this if framerate = 60
		// NOTE: this is duplicated code (oops) look at end of postupdate as well if making changes
		if (FlxG.drawFramerate > 0) {
		if (trail_buffer == null) {
			trail_buffer = [];
			trail_frame_buffer = [];
			for (i in 0...21) {
				trail_buffer.push(new Point(0, 0));
				trail_frame_buffer.push(0);
			}
			dark_sprite.ID = light_sprite.ID = 0;
			// alpha mode and alpha ctr
		}
		
		
		// NOTE: this is duplicated code (oops) look at end of postupdate as well if making changes
		/* decide how many trail t show */
		var d_trail:Bool = false;
		var l_trail:Bool = false;
		var n:Int = 0;
		var l_percent:Float = energy_bar.get_LIGHT_percentage();
		
		if (l_percent <= 0.4) {
			// 130 to 205
			d_trail = true;
			n = 5;
		} else if (l_percent >= 0.6) {
			l_trail = true;
			if (l_percent >= 0.6) n = 2;
			if (l_percent >= 0.7) n = 3;
			if (l_percent >= 0.8) n = 4;
			if (l_percent >= 0.9) n = 5;
		} else {
			// Must have been dark
			if (dark_sprite.ID == 2 && l_percent <= 0.5) {
				n = 5;
				d_trail = true;
			}
		}
		
		
		
		var len:Int = trail_buffer.length;
		// start non-frame rate dep part 
		if (n != 0) {
			for (i in 0...len) {
				if (i + 1 > n) {
					// dont draw
				} else {
					
					var a_mul:Float = 0;
					if (dark_sprite.ID == 0) {
						a_mul = 0;
					} else if (dark_sprite.ID == 1) {
						a_mul = light_sprite.ID / 15.0;
					} else if (dark_sprite.ID == 2) {
						a_mul = 1;
					} else if (dark_sprite.ID == 3) {
						a_mul = light_sprite.ID / 15.0;
						if (d_trail) a_mul = light_sprite.ID  / 20.0;
					}
					
					var _idx:Int = (n - (i)) * 4; // 20, 16, 12, 8, 4
					if (d_trail) {
						// draw farthest first, with least alpha.
						dark_sprite.animation.play(Std.string(trail_frame_buffer[_idx]), true);
						dark_sprite.move(trail_buffer[_idx].x - offset.x, trail_buffer[_idx].y - offset.y);
						
						dark_sprite.alpha = 1 - (_idx) * (1 / (n * 4)) * 0.8; // 0.2 ... .84 ?
						dark_sprite.alpha *= a_mul;
						// fad emore if slow
						
						//Log.trace([dark_sprite.alpha, dark_sprite.velocity.x]);
						if (is_on_the_ground(true) || dark_sprite.velocity.x == 0) {
							
							// If slowing down, and on the ground, slowly progress towards zero (or zero alpha)
							if (dark_sprite.velocity.x > Math.abs(velocity.x)) {
								dark_sprite.velocity.x -= 0.5 * (-Math.abs(velocity.x) + dark_sprite.velocity.x);
								if (Math.abs(dark_sprite.velocity.x) < 20) {
									dark_sprite.velocity.x = 0;
								}
							} else {
								dark_sprite.velocity.x = Math.abs(velocity.x);
							}
							
						} else if (!is_on_the_ground(true)) { 
							// If in the air, try to fade in the sprite. dont fade out though.
							if (dark_sprite.velocity.x < Math.abs(velocity.x)) {
								dark_sprite.velocity.x = Math.abs(velocity.x);
							}
						}
						dark_sprite.alpha *= (0.5 - ((4 - i) * 0.1) + ((dark_sprite.velocity.x) / (2 * 205.0)));
						
						// between 40 and 50% light make the darks disappear
						if (l_percent > 0.4) {
							dark_sprite.alpha *= 1 + -1.2 * ((l_percent - 0.4)/(0.1));
						}
						if (!energy_bar.OFF) dark_sprite.draw();
					} else {
						light_sprite.animation.play(Std.string(trail_frame_buffer[_idx]), true);
						light_sprite.move(trail_buffer[_idx].x - offset.x, trail_buffer[_idx].y - offset.y);
						light_sprite.alpha = 1 - (_idx) * (1 / (n*4)) * 0.8;
						light_sprite.alpha *= a_mul;
						if (!energy_bar.OFF) light_sprite.draw();
					}
				}
			}
		}
		// End non-framerate dep part
		
	}
		
		/* End trail effect */
		
		if (draw_start_lock_shield_effect) {
			draw_start_lock_shield_effect = false;
			draw_started_lock_shield_effect = true;
			draw_lock_shield_effect_scale = 1.5;
		}
		if (draw_started_lock_shield_effect) {
			var oldalpha:Float = alpha;
			alpha = 0.5;
			scale.x = scale.y = draw_lock_shield_effect_scale;
			
			super.draw();
			scale.x = scale.y = 1;
			alpha = oldalpha;
			draw_lock_shield_effect_scale -= 1.0 / 10;
			if (draw_lock_shield_effect_scale < 1) {
				draw_started_lock_shield_effect = false;
			}
			
		}
		
		if (randomize_draw_pos) {
			var ox:Float = x;
			var oy:Float = y;
			x = x - randomize_draw_range + (Math.random() * 2 * randomize_draw_range);
			y = y - randomize_draw_range + (Math.random() * 2 * randomize_draw_range);
			super.draw();
			x = ox;
			y = oy;
			randomize_draw_pos = false;
		} else {
			// Fix weird bug when talking to things and you dont calculate the moving into tilemap and you are pixel offset from ground
			if (jump_state == js_ground){
				var oy:Float = y;
				y = Math.fround(y);
				ID = 69;
				super.draw();
				y = oy;
			} else {
				super.draw();
			}
		}
		
		if (ticks_continuous_gas > 0) {
			
			energy_bar.player_shade_timer = 0.15;
		}
		//Log.trace([energy_bar.player_shade_timer, energy_bar.status]);
		// i use this id variable bc i was lazy to make a new counter -_-
		if (energy_bar.status != 0 && alpha == 1) {
			if (!armor_on) {
			if (energy_bar.status == 1) { // Light gas
				if (animation.curAnim != null) {
					light_sprite.animation.play(Std.string(animation.getFrameIndex(frame)), true);
				}
				if (jump_state == js_ground) {
					light_sprite.move(x - offset.x, Math.fround(y) - offset.y);
				} else {
					light_sprite.move(x - offset.x, y - offset.y);
				}
				shader_ctr++;
				if (ticks_continuous_gas > 0) {
					shader_ctr+=6;
					if (shader_ctr >= 360) shader_ctr = 0;
					light_sprite.alpha = (FlxX.sin_table[shader_ctr] + 1.0) / 2.0;
					light_sprite.alpha /= 2;
					light_sprite.alpha += 0.5;
				} else {
					var cm:Int = shader_ctr % 10;
					if (cm < 5) {
						light_sprite.alpha = 1;
					} else {
						light_sprite.alpha = 0.5;
					}
				}
				light_sprite.draw();
			} else if (energy_bar.status == -1) { // dark gas
				if (animation.curAnim != null) {
					dark_sprite.animation.play(Std.string(animation.getFrameIndex(frame)), true);
				}
				
				if (jump_state == js_ground) {
					dark_sprite.move(x - offset.x, Math.fround(y) - offset.y);
				} else {
					dark_sprite.move(x - offset.x, y - offset.y);
				}
				shader_ctr++;
				if (ticks_continuous_gas > 0) {
					shader_ctr+=6;
					if (shader_ctr >= 360) shader_ctr = 0;
					dark_sprite.alpha = (FlxX.sin_table[shader_ctr] + 1.0) / 2.0;
					dark_sprite.alpha /= 2;
					dark_sprite.alpha += 0.5;
				} else {
					var cm:Int = shader_ctr % 10;
					if (cm < 5) {
						dark_sprite.alpha = 1;
					} else {
						dark_sprite.alpha = 0.4;
					}
				}
				dark_sprite.draw();
			}
			}
			
			if (energy_bar.player_shade_timer > 0) {
				energy_bar.player_shade_timer -= FlxG.elapsed;
				if (energy_bar.player_shade_timer < 0) {
					energy_bar.player_shade_timer = 0;
					energy_bar.status = 0;
				}
			}
			
		} else {
			shader_ctr = 270;
		}
		
		
 		
	}
	
	private var sit_ctr:Int = 0;
	private function update_mode_sit():Void {
		if (sit_ctr == 0) {
			if (facing == FlxObject.RIGHT) {
				animation.play("sit_down_r", true);
			} else {
				animation.play("sit_down_l", true);
			}
			sit_ctr = 1;
			FlxG.camera.follow(null);
			
			//var setname:String = EMBED_TILEMAP.tileset_name_hash.get(R.TEST_STATE.MAP_NAME);
			//var tbmap:BitmapData = Assets.getBitmapData("assets/tileset/" + setname+"_tileset.png");
			//MapPrinter.eto_print_png(cast parent_state, Std.int(tbmap.width/16), "photoTest",tbmap );
			
		} else if (sit_ctr == 1 && animation.finished) {
			if (R.input.jpSit) {
				if (facing == FlxObject.RIGHT) {
					animation.play("sit_up_r", true);
				} else {
					animation.play("sit_up_l", true);
				}
				sit_ctr = 2;
				
				FlxG.camera.follow(R.player);
				FlxG.camera.followLerp = 60;
				TestState.truly_set_default_cam(parent_state.tm_bg.width, parent_state.tm_bg.height);
			} else {
			
				if (0 == R.dialogue_manager.get_scene_state_var("ui", "sitflag", 1)) {
					R.dialogue_manager.change_scene_state_var("ui", "sitflag", 1, 1);
					parent_state.dialogue_box.start_dialogue("ui", "sitflag", 0);
				}
				
				var ocx:Float = FlxG.camera.scroll.x;
				var ocy:Float = FlxG.camera.scroll.y;
				
				if (R.input.right) {
					FlxG.camera.scroll.x ++;
				}
				if (R.input.left) {
					FlxG.camera.scroll.x --;
				}
				if (R.input.down) {
					FlxG.camera.scroll.y ++;
				}
				if (R.input.up) {
					FlxG.camera.scroll.y --;
				}
				var s:FlxSprite = R.player;
				
				if (s.x  < FlxG.camera.scroll.x || s.x +s.width> FlxG.camera.scroll.x + FlxG.camera.width || s.y < FlxG.camera.scroll.y || s.y + s.height > FlxG.camera.scroll.y + FlxG.camera.height) {
					FlxG.camera.scroll.set(ocx, ocy);
				}
				
			}
		} else if (sit_ctr == 2 && animation.finished) {
			mode = mode_main;
			sit_ctr = 0;
			energy_bar.force_hide = false;
			energy_bar.allow_move = true;
		} else if (sit_ctr == 10) {
			if (parent_state.dialogue_box.is_active() == false && parent_state.dialogue_box.last_yn == 0) {
				parent_state.add(R.name_entry);
				R.name_entry.turn_on(R.dialogue_manager.lookup_sentence("ui", "photograph_comment", 1));
				sit_ctr = 11;
			} else if (parent_state.dialogue_box.is_active() == false) {
				sit_ctr = 1;
			}
		} else if (sit_ctr == 11) {
			if (R.name_entry.is_done()) {
				var _photoname:String = "";
				_photoname = Date.now().toString() + "_" + R.name_entry.returnword;
				_photoname = StringTools.replace(_photoname, "-", "_");
				_photoname = StringTools.replace(_photoname, " ", "_");
				_photoname = StringTools.replace(_photoname, ":", "");
				//MapPrinter.eto_print_png(cast parent_state,Std.int(parent_state.tm_bg.graphic.bitmap.width/16),_photoname);
				parent_state.remove(R.name_entry, true);
				sit_ctr = 1;
			}
		}
	}
	
}