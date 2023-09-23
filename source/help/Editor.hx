package help;
import autom.EMBED_TILEMAP;
import autom.SNDC;
import entity.npc.SetPiece;
import entity.player.Player;
import entity.tool.CameraTrigger;
import entity.tool.Door;
import entity.util.NewCamTrig;
import entity.util.SoundZone;
import flash.geom.Point;
import flixel.FlxObject;
#if cpp
import cpp.vm.Thread;
#end
import entity.npc.GenericNPC;
import entity.ui.MenuMap;
import flixel.util.FlxStringUtil;
import openfl.Assets;
import flash.display.BitmapData;
import entity.MySprite;
import entity.trap.Pew;
import global.C;
import global.Registry;
import haxe.Log;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.text.FlxBitmapText;
import state.MyState;
import state.TestState;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

/**
 * @author Melos Han-Tani
 */

class Editor extends FlxGroup
{

	
	
	private var setpiece:SetPiece;
	private var setpiece_bg:FlxSprite;
	private var R:Registry;
	
	public var editor_active:Bool = false;
	private var current_tilemap_name:String = "DEBUG";
	
	public var add_highlighter:FlxSprite;
	public var instructions_text:FlxBitmapText;
	public var current_mode_text:FlxBitmapText;
	public var extra_text:FlxBitmapText;
	public var mouse_text:FlxBitmapText;
	public var status_text:FlxBitmapText;
	public var entity_depth:FlxBitmapText;
	public var selected_entity_sprite:FlxSprite;
	
	public static inline var C_INSTRUCTIONS:String = "Add Tile_edit Edit_attrs Change_map";
	
	private var mode:Int = 0;
	private static inline var MODE_MOVE_ENTITY:Int = 0;
	private static inline var MODE_TILE_EDIT:Int = 1;
	private static inline var MODE_ADD_ENTITY:Int = 2;
	private static inline var MODE_EDIT_ENTITY:Int = 3;
	private static inline var MODE_DELETE_ENTITY:Int = 4;
	private static inline var MODE_CHANGE_MAPS:Int = 5;
	private static inline var MODE_ASK_TO_SAVE_ON_CLOSE:Int = 6;
	private static inline var MODE_BUFFER:Int = 7;
	
	private var copiable_entity:Dynamic;
	private var tileset_selector:FlxSprite;
	private var tileset_selected:FlxSprite;
	private var tilemap_selector:FlxSprite;
	private var tilemap_arrowed_selector:FlxSprite;
	private var editable_tmap:FlxTilemapExt;
	private var tileset:FlxTilemap;
	private var tileset_bg:FlxSprite;
	private var active_tile_id:Int = 0;
	private var active_layer_id:Int = 0;
	private var npc_lock:FlxSprite;
	private var death_energy_lock:FlxSprite;
	public var death_lock_on:Bool = false;
	private var t_death_lock_click:Float = 0;
	private var ent_icons:FlxGroup;
	private var init_color_type:Int = 0;
	private var init_color_sprite:FlxSprite;
	
	private var editor_checkpoint_icon:FlxSprite;
	public var editor_checkpoint_sprite:FlxSprite;
	
	private var invishard_marker:FlxSprite;
	private var cur_invishard_coords:Map<Int,FlxPoint>;
	private var cur_invishard_coords_bg2:Map<Int,FlxPoint>;
	public var invishard_coords_initialized:Bool = false;
	
	private var cur_state:MyState;
	
	private var last_mouse_x:Float;
	private var last_mouse_y:Float;
	
	public function new() 
	{
		
		super();
		R = Registry.R;
		
	
		malloc();
		do_init();
		do_add();
		
		if (ProjectClass.DEV_MODE_ON && (FileSystem.exists(".npclock") || FileSystem.exists(C.EXT_ASSETS + "../txt/.npclock"))) {
			GenericNPC.global_npc_lock = true;
			npc_lock.makeGraphic(16, 16, 0xff00ff00);
			Log.trace("Global NPC lock on");
		}
		if (ProjectClass.DEV_MODE_ON && !FileSystem.exists(C.EXT_ASSETS + "../txt/.melos")) {
			Log.trace("death lock default to on");
			death_lock_on = true;
			death_energy_lock.animation.play("on");
		}
	}
	public function warp_player_to_editor_checkpoint(p:Player):Void {
		p.x = editor_checkpoint_sprite.x;
		p.y = editor_checkpoint_sprite.y;
		p.last.x = p.x;
		p.last.y = p.y;
	}
	private function malloc():Void {
		ent_icons = new FlxGroup();
		add_highlighter = new FlxSprite();
		instructions_text = HF.init_bitmap_font(C_INSTRUCTIONS, "left", 1, 1, null, C.FONT_TYPE_EDITOR);
		instructions_text.lineSpacing = 0;
		current_mode_text = HF.init_bitmap_font("Mode: MOVE", "left", 1, 1, null, C.FONT_TYPE_EDITOR);
		current_mode_text.lineSpacing = 0;
		extra_text = HF.init_bitmap_font("N/A", "left", 1, 9, null, C.FONT_TYPE_EDITOR);
		extra_text.lineSpacing = 2;
		mouse_text = HF.init_bitmap_font(" ", "left", 1, FlxG.height - 10, null, C.FONT_TYPE_EDITOR);
		status_text = HF.init_bitmap_font(" ", "left", 1, FlxG.height - 19, null, C.FONT_TYPE_EDITOR);
		editable_tmap = new FlxTilemapExt ();
		tileset_selector = new FlxSprite ();
		tileset_selected = new FlxSprite ();
		tilemap_selector = new FlxSprite ();
		tilemap_arrowed_selector = new FlxSprite();
		tileset = new FlxTilemap ();
		tileset_bg = new FlxSprite ();
		npc_lock = new FlxSprite();
		death_energy_lock = new FlxSprite();
		editor_checkpoint_icon = new FlxSprite();
		editor_checkpoint_sprite = new FlxSprite();
		
		entity_depth = HF.init_bitmap_font(" ", "center", 1, 1,new FlxPoint(1,1), C.FONT_TYPE_EDITOR);
		selected_entity_sprite = new FlxSprite();
		
		big_select_ed = new FlxSprite();
		big_select_ed.makeGraphic(1, 1, 0x77ff0000);
		big_select_or = new FlxSprite();
		big_select_or.makeGraphic(1, 1, 0x7700ffff);
		big_select_or.visible = big_select_ed.visible = false;
		big_select_or.origin.set(0, 0);
		big_select_ed.origin.set(0, 0);
		
		setpiece_bg = new FlxSprite();
		
		init_color_sprite = new FlxSprite();
	}
	private function do_init():Void {
		for (i in 0...10) {
			var enticon:FlxSprite = new FlxSprite();
			enticon.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/ent_icons.png"), true, false, 16, 16);
			ent_icons.add(enticon);
			enticon.x = 0;
			enticon.y = extra_text.y + 6 + 20 * i;
			enticon.scrollFactor.set(0, 0);
		}
		ent_icons.visible = false;
		
		tileset_selector.makeGraphic(18, 18, 0xffff0000);
		tileset_selected.makeGraphic(18, 18, 0xbbff0000);
		tilemap_selector.makeGraphic(18, 18, 0xff00ff00);
		tilemap_arrowed_selector.makeGraphic(18, 18, 0xff33ff33);
		var i:Int;
		var j:Int;
		for (i in 1...17){
			for (j in 1...17){
				tileset_selector.pixels.setPixel32(j, i, 0x00000000);
				tileset_selected.pixels.setPixel32(j, i, 0x00000000);
				tilemap_selector.pixels.setPixel32(j, i, 0x00000000);
				tilemap_arrowed_selector.pixels.setPixel32(j, i, 0x00000000);
			}
		}
		tileset_selector.dirty = tileset_selected.dirty = tilemap_selector.dirty = tilemap_arrowed_selector.dirty = true;
		tileset_selected.scrollFactor.x = tileset_selector.scrollFactor.x = tileset_bg.scrollFactor.x = tileset.scrollFactor.x = 0;
		tileset_selected.scrollFactor.y = tileset_selector.scrollFactor.y = tileset_bg.scrollFactor.y = tileset.scrollFactor.y = 0;
		//tilemap_arrowed_selector.scrollFactor.set(0, 0);
		tilemap_arrowed_selector.visible = false;
		tilemap_selector.visible = tileset_selected.visible = tileset_selector.visible = tileset_bg.visible = tileset.visible = false;
		
	
		tileset_bg.alpha = 0.95;
		
		
		death_energy_lock.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/editor_icons.png"), true, false, 16, 16);
		death_energy_lock.animation.add("on", [0]);
		death_energy_lock.animation.add("off", [1]);
		death_energy_lock.animation.play("off");
		death_energy_lock.scrollFactor.set(0, 0);
		death_energy_lock.x = FlxG.width - 18; death_energy_lock.y =  2; 
		death_energy_lock.alpha = 0.6;
		
		editor_checkpoint_sprite.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/editor_icons.png"), true, false, 16, 16);
		editor_checkpoint_icon.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/editor_icons.png"), true, false, 16, 16);
		editor_checkpoint_sprite.animation.add("on", [2]);
		editor_checkpoint_icon.animation.add("on", [2]);
		editor_checkpoint_icon.animation.play("on");
		editor_checkpoint_sprite.animation.play("on");
		editor_checkpoint_icon.scrollFactor.set(0, 0);
		editor_checkpoint_icon.x = death_energy_lock.x - 17;
		editor_checkpoint_icon.y = death_energy_lock.y;
		editor_checkpoint_icon.alpha = 0.6;
		editor_checkpoint_sprite.visible = false;
		
		init_color_sprite.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/editor_icons.png"), true, false, 16, 16);
		init_color_sprite.animation.add("dark", [4], 1);
		init_color_sprite.animation.add("light", [3], 1);
		init_color_sprite.animation.play("dark");
		init_color_sprite.alpha = 0.6;
		init_color_sprite.scrollFactor.set(0, 0);
		init_color_sprite.x = editor_checkpoint_icon.x - 17;
		init_color_sprite.y = editor_checkpoint_icon.y;
		
		npc_lock.makeGraphic(16, 16, 0xffff0000);
		if (GenericNPC.global_npc_lock) {
			npc_lock.makeGraphic(16, 16, 0xff00ff00); 
		}
		 npc_lock.alpha = 0.5;
		npc_lock.scrollFactor.set(0, 0);
		npc_lock.move(init_color_sprite.x - 16, init_color_sprite.y );
		
		add_highlighter.makeGraphic(100, 10, 0xa0ff4444);
		add_highlighter.visible = false;
		
		invishard_marker = new FlxSprite();
		invishard_marker.myLoadGraphic(Assets.getBitmapData("assets/tileset/invishard.png"), true, false, 16, 16);
		for (i in 0...30) {
			invishard_marker.animation.add(Std.string(i), [i], 1);
		}
		invishard_marker.animation.play("6");
	}
	
	private function do_add():Void {
		//add(instructions_text);
		add(current_mode_text);
		add(extra_text);
		add(add_highlighter); add_highlighter.scrollFactor.set(0, 0);
		add(ent_icons);
		add(mouse_text);
		add(status_text);
		
		add(tilemap_selector);
		add(tilemap_arrowed_selector);
		add(tileset_bg);
		add(tileset);
		add(tileset_selector);
		add(tileset_selected);
		//add(invishard_marker);
		
		add(selected_entity_sprite);
		add(entity_depth);
		add(death_energy_lock);
		add(npc_lock);
		add(editor_checkpoint_sprite);
		add(editor_checkpoint_icon);
		add(init_color_sprite);
		
		add(big_select_ed); add(big_select_or);
		
	}
	
	
	private var asked_to_save:Bool = false;
	private var is_melos:Bool = false;
	private var cam_data:Array<Dynamic>;
	private var cam_stashed:Bool = false;
	public function toggle(ms:MyState):Void {
		
		#if cpp
			if (FileSystem.exists(C.EXT_ASSETS + "../txt/.melos")) {
				is_melos = true;
			}
			
		#end
		
		if (most_things_hidden) {
			return;
		}
		if (editor_active) {
			
			#if cpp
			if (FileSystem.exists(C.EXT_ASSETS + "../txt/.melos")) {
				asked_to_save = true;
			}
			#end
			
			if (false == asked_to_save) {
				extra_text.text = "Save ent and tile data? (y/n)";
				mode = MODE_ASK_TO_SAVE_ON_CLOSE;
				return;
			}
			

			make_everything_invisible();
			asked_to_save = false;
			FlxG.mouse.visible = false;
			
			if (R.player.exists) {
				FlxG.camera.follow(R.player);
			} else if (R.realplayer.exists) {
				FlxG.camera.follow(R.realplayer);
			} else if (R.worldmapplayer.exists) {
				FlxG.camera.follow(R.worldmapplayer);
			}
			
			
			TestState.truly_set_default_cam(cur_state.tm_bg.width, cur_state.tm_bg.height);
			if (cam_stashed) {
				//Log.trace("get cam data");
				// Don't keep camera lock if you changed maps
				if (cam_data[6] == ms.MAP_NAME) {
					cam_stashed = false;
					FlxG.camera.scroll.set(cam_data[0], cam_data[1]);
					FlxG.camera._scrollTarget.set(cam_data[2], cam_data[3]);
					FlxG.camera.followLerp = cam_data[4];
					FlxG.camera.deadzone.copyFrom(cam_data[5]);
					//FlxG.camera.bounds.copyFrom(cam_data[7]);
					FlxG.camera.setScrollBoundsRect(cam_data[7].x, cam_data[7].y, cam_data[7].width, cam_data[7].height);
				}
			}
			
			deactivate();
			ms.remove(this, true);
		} else {
			
			if (CameraTrigger.IN_CAMERA_TRIGGER) {
				//Log.trace("stash cam data"); 
				cam_stashed = true;
				cam_data = [FlxG.camera.scroll.x, FlxG.camera.scroll.y, FlxG.camera._scrollTarget.x, FlxG.camera._scrollTarget.y, FlxG.camera.followLerp, FlxG.camera.deadzone.copyTo(new FlxRect()), ms.MAP_NAME, new FlxRect(FlxG.camera.minScrollX,FlxG.camera.minScrollY,FlxG.camera.maxScrollX - FlxG.camera.minScrollX,FlxG.camera.maxScrollY-FlxG.camera.minScrollY)];
				FlxG.camera.setScrollBoundsRect(-64, -64, ms.tm_bg.width+128, ms.tm_bg.height+128);
			}
			if (NewCamTrig.active_cam != null) {
				FlxG.camera.setScrollBoundsRect(-64, -64, ms.tm_bg.width+128, ms.tm_bg.height+128);
			}
			
		
			FlxG.mouse.visible = true;
			FlxG.camera.follow(null);
			
				FlxG.camera.setScrollBoundsRect(-64, -64, ms.tm_bg.width+128, ms.tm_bg.height+128);
					
			if (setpiece == null) {
				setpiece = new SetPiece(0, 0, ms);
				setpiece.visible = false;
				setpiece_bg.makeGraphic(1, 1, 0xff000000);
				setpiece_bg.visible = false;
				setpiece.scrollFactor.set(0, 0);
				setpiece.editor_drag_box.scrollFactor.set(0, 0);
				setpiece_bg.scrollFactor.set(0, 0);
				add(setpiece_bg);
				add(setpiece);
			}

			cur_state = ms;
			activate();
			ms.add(this);
		} 
		editor_active = !editor_active;
	}
	
	private function activate():Void {
		instructions_text.visible = true;
		R.player.energy_bar.reset_after_death();
		R.player.pause_toggle(true);
		R.realplayer.pause_toggle(true);
		R.worldmapplayer.pause_toggle(true);
		R.train.pause_toggle(true);
		HelpTilemap.difficulty_tiles_on(cur_state, true);
		
	}
	
	private function deactivate():Void {
		HelpTilemap.difficulty_tiles_on(cur_state);
		instructions_text.visible = false;
		R.player.pause_toggle(false);
		R.player.velocity.x = R.player.velocity.y = 0;
		R.player.toggle_invincible(false);
		R.realplayer.pause_toggle(false);
		R.worldmapplayer.pause_toggle(false);
		R.train.pause_toggle(false);
		mode_change_state = 0;

		tile_is_big_select = false;
		add_is_big_select = false;
		big_select_ed.visible = big_select_or.visible = false;
	}
	
	private var most_things_hidden:Bool = false;
	public var hide_zones:Bool = false;
	override public function update(elapsed: Float):Void {
		
		var fuck:Bool = FlxG.keys.pressed.CONTROL;
		if (b_active_ent_layers == null) {
			b_active_ent_layers = [true, true, true, false, true];
			b_active_tile_layers = [true, true, true, true];
		}
		
		
		if (false == invishard_coords_initialized) {
			invishard_coords_initialized = true;
			cur_invishard_coords = new Map<Int,FlxPoint>();
			cur_invishard_coords_bg2 = new Map<Int,FlxPoint>();
			for (tm in [cur_state.tm_bg, cur_state.tm_bg2]) {
				// For every invishard id
				for (tid in HelpTilemap.invishard) {
					// Get the tile map (bg or BG2s) list of tile coord with this iDS
					var a:Array<FlxPoint> = tm.getTileCoords(tid,false);
					if (a != null) {
						var fp:FlxPoint;
						for (fp in a) {
							// set the proper Int-Point map
							if (tm == cur_state.tm_bg) {
								cur_invishard_coords.set(Std.int(fp.y / 16) * tm.widthInTiles + Std.int(fp.x / 16), fp);
							} else {
								cur_invishard_coords_bg2.set(Std.int(fp.y / 16) * tm.widthInTiles + Std.int(fp.x / 16), fp);
							}
						}
					}
				}
			}
		}
		
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.ALT && FlxG.keys.justPressed.P) {
			var setname:String = EMBED_TILEMAP.tileset_name_hash.get(cur_state.MAP_NAME);
			var tbmap:BitmapData = Assets.getBitmapData("assets/tileset/" + setname+"_tileset.png");
			MapPrinter.eto_print_png(cast cur_state ,Std.int(tbmap.width/16),"",tbmap);
		}
		
		if (FlxG.keys.myJustPressed("TAB")) {
			
			if (most_things_hidden) {
				current_mode_text.visible = extra_text.visible = instructions_text.visible = mouse_text.visible = death_energy_lock.visible = editor_checkpoint_icon.visible = status_text.visible = true;
				npc_lock.visible = true;
				if (mode == MODE_ADD_ENTITY) {
					add_highlighter.visible = true;
					ent_icons.visible = true;
				}
				most_things_hidden = false;
				R.player.energy_bar.toggle_bar();
			} else {
				current_mode_text.visible = extra_text.visible = instructions_text.visible = mouse_text.visible = death_energy_lock.visible = editor_checkpoint_icon.visible = status_text.visible = add_highlighter.visible = false;
				ent_icons.visible = false;
				
				npc_lock.visible = false;
				R.player.energy_bar.toggle_bar();
				most_things_hidden = true;
				if (mode == MODE_ADD_ENTITY) {
					status_text.visible = true;
				}
			}
			instructions_text.text = C_INSTRUCTIONS;
		}
		
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.M) {
			if (R.song_helper.get_volume_modifier() != 0) {
				R.song_helper.set_volume_modifier(0);
				R.sound_manager.set_volume_modifier(0);
			} else {
				R.song_helper.set_volume_modifier(1);
				R.sound_manager.set_volume_modifier(1);
			}
		}
		if (FlxG.keys.pressed.CONTROL && !FlxG.keys.pressed.ALT && (!most_things_hidden || is_melos)) {
		if (FlxG.keys.myJustPressed("A")  || FlxG.keys.myJustPressed("T") || FlxG.keys.myJustPressed("E") || FlxG.keys.myJustPressed("C") || FlxG.keys.myJustPressed("B") ) {
				cleanup_on_mode_switch();
			}
		}
		
		if (FlxG.keys.myJustPressed("Z") && !FlxG.keys.pressed.CONTROL) {
			if (FlxG.camera.zoom != 1) {
				FlxG.camera.zoom = 1;
				FlxG.camera.width *= 2;
				FlxG.camera.height *= 2;
				FlxG.camera.x = -416;
				FlxG.camera.y = -256;
 			} else {
				FlxG.camera.x = 0;
				FlxG.camera.y = 0;
				FlxG.camera.zoom = 2;
				FlxG.camera.width = Math.floor(FlxG.camera.width / 2);
				FlxG.camera.height = Math.floor(FlxG.camera.height / 2);
			}
			// force a remake of the tileset buffermapbuffermap
			mode_tile_single_vis = false;
			cur_state.tm_bg.visible = cur_state.tm_bg2.visible = cur_state.tm_fg.visible = cur_state.tm_fg2.visible = tileset.visible = true;
			cur_state.tm_bg._buffers[0] = null;
			cur_state.tm_fg._buffers[0] = null;
			cur_state.tm_fg2._buffers[0] = null;
			cur_state.tm_bg2._buffers[0] = null;
			tileset.updateBuffers();
			tileset.visible = false;
			tileset_bg.visible = false;
			cur_state.anim_tile_engine.pls_wait = 4;
		} else if (FlxG.keys.myJustPressed("Z")) {
			hide_zones = !hide_zones;
		}
		
		switch (mode) {
			case MODE_EDIT_ENTITY:
				update_mode_edit_entity();
			case MODE_ADD_ENTITY:
				update_mode_add_entity();
			case MODE_TILE_EDIT:
				update_mode_tile();
			case MODE_CHANGE_MAPS:
				update_mode_change_maps();
			case MODE_ASK_TO_SAVE_ON_CLOSE:
				update_mode_ask_to_save();
			case MODE_BUFFER:
				update_mode_buffer();
		}
		
		mouse_text.text = Std.string(Math.floor(FlxG.mouse.x)) + "," + Std.string(Math.floor(FlxG.mouse.y)) + " " + Std.string(Math.floor(FlxG.mouse.x / 16)) + "," + Std.string(Math.floor(FlxG.mouse.y / 16)) + " " + cur_state.MAP_NAME + " " + Std.string(cur_state.tm_bg.widthInTiles) + " " + Std.string(cur_state.tm_bg.heightInTiles);
		if (mode == MODE_TILE_EDIT) {
			mouse_text.text += " "+Std.string(active_tile_id);
		}
		
		if (mode == MODE_TILE_EDIT) {
			mouse_text.text += " " + extra_text.text;
		}
		
		if (t_death_lock_click > 0) t_death_lock_click -= FlxG.elapsed;
		if (FlxG.mouse.justPressed) {
			
			if (FlxG.mouse.inside(npc_lock)) {
				GenericNPC.global_npc_lock = !GenericNPC.global_npc_lock;
				if (GenericNPC.global_npc_lock) {
					npc_lock.makeGraphic(16, 16, 0xff00ff00);
				} else {
					npc_lock.makeGraphic(16, 16, 0xffff0000);
				}
				npc_lock.alpha = 0.5;
			}
			
			t_death_lock_click += 0.5;
			if (t_death_lock_click > 0.55) {
				if (FlxG.mouse.inside(death_energy_lock)) {
					death_lock_on = !death_lock_on;
					if (death_lock_on) {
						death_energy_lock.animation.play("on");
					} else {
						death_energy_lock.animation.play("off");
					}
				} else if (FlxG.mouse.inside(editor_checkpoint_icon)) {
					editor_checkpoint_sprite.x = R.player.x;
					editor_checkpoint_sprite.y = R.player.y;
					editor_checkpoint_sprite.visible = true;
				}
			}
		}
		
		if (Math.abs(FlxG.mouse.screenX - last_mouse_screen_x) > 1 || Math.abs(FlxG.mouse.screenY - last_mouse_screen_y) > 1) {
			dont_track_mouse = false;
		}
		
		if (FlxG.keys.pressed.SHIFT ) {
			
			if (!dont_track_mouse) {
				track_mouse();
			}
			if (mode != MODE_CHANGE_MAPS) {
				if (FlxG.keys.myPressed("RIGHT")) {
					dont_track_mouse = true;
					FlxG.camera.scroll.x += 15;
					if (FlxG.keys.pressed.CONTROL) FlxG.camera.scroll.x += 15;
				} else if (FlxG.keys.myPressed("LEFT")) {
					dont_track_mouse = true;
					FlxG.camera.scroll.x -= 15;
					if (FlxG.keys.pressed.CONTROL) FlxG.camera.scroll.x -= 15;
				} 
				if (FlxG.keys.myPressed("UP")) {
					dont_track_mouse = true;
					FlxG.camera.scroll.y -= 15;
					if (FlxG.keys.pressed.CONTROL) FlxG.camera.scroll.y -= 15;
				} else if (FlxG.keys.myPressed("DOWN")) {
					dont_track_mouse = true;
					FlxG.camera.scroll.y += 15;
					if (FlxG.keys.pressed.CONTROL) FlxG.camera.scroll.y += 15;
				}
			}
		}
		
		super.update(elapsed);
		last_mouse_screen_x = FlxG.mouse.screenX;
		last_mouse_screen_y = FlxG.mouse.screenY;
		last_mouse_x = FlxG.mouse.x;
		last_mouse_y = FlxG.mouse.y;
	}
	private var last_mouse_screen_x:Int = 0;
	private var last_mouse_screen_y:Int = 0;
	private var dont_track_mouse:Bool = false;
	private var mode_edit_ctr:Int = 0;
	private var editable_ent:MySprite = null;
	private var mode_edit_attrs:Array<String> = null;
	private var mode_edit_active_attr:String = "";
	private var mode_edit_new_val:String = "";
	private var MODE_EDIT_USE_PRESET:Int = 100;
	private var mode_edit_active_entity_preset_set:Map<String,Dynamic>;
	private var do_add_child_in_edit:Bool = false;
	private var mode_edit_max_pages:Int = 1;
	private var mode_edit_cur_page:Int = 0;

	private function update_mode_edit_entity():Void {
		
		// Establish child-parent relationship, update child string of parent
		if (do_add_child_in_edit) {
			var d:Dynamic = null;
			d = find_entity_with_click(false);
			if (d != null && editable_ent != null) {
				if (d.geid != editable_ent.geid) {
					//d.parents.push(editable_ent);
					d.add_parent(editable_ent);
					editable_ent.children.push(d);
					editable_ent.props.set("children", editable_ent.get_children_string());
					flash(true);
				} else {
					flash(false);
					Log.trace("geid collision: " + Std.string(editable_ent.geid));
				}
				editable_ent = null;
				do_add_child_in_edit = false;
			}
		}
		
		/* Choose preset, then set it on the entity */
		if (mode_edit_ctr == MODE_EDIT_USE_PRESET) {
			if (HF.read_number("") != "") {
				var entity_presets:Map<String,Dynamic> = mode_edit_active_entity_preset_set.get(HF.read_number(""));
				if (entity_presets == null) {
					// ok
					flash(false);
				} else {
					flash(true);
					
					var presetcopy:Map<String,Dynamic> = new Map<String,Dynamic>();
					HF.copy_props(entity_presets, presetcopy, true); // skip "_name"  
					editable_ent.set_properties(presetcopy);
					
					editable_ent = null;
					mode_edit_ctr = 0;
					mode_edit_active_entity_preset_set = null;
					extra_text.text = "set preset";
				}
			}
			return;
		}
		
		/* Display list of presets for this entity, if they exist, enter preset mode ^ */
		if (FlxG.keys.myJustPressed("P") && mode_edit_ctr != 2) {
			var d:Dynamic = find_entity_with_click(false, true);
			if (d != null) {
				var name:String = d.name;
				var entity_preset_set:Map<String,Dynamic> = MySprite.presets.get(name);
				if (entity_preset_set == null) {
					extra_text.text = "No presets for " + name;
				} else {
					extra_text.text = " ";
					for (key in entity_preset_set.keys()) {
						extra_text.text += key + ": " + entity_preset_set.get(key).get("_name") + "\n";
					}
					editable_ent = cast(d,MySprite);
					mode_edit_active_entity_preset_set = entity_preset_set;
					mode_edit_ctr = MODE_EDIT_USE_PRESET;
				}
			}
		}
		var d:Dynamic = null;
		d = find_entity_with_click(false);
		if (d == null) {
			if (R.player.exists && FlxG.mouse.justPressed && FlxG.mouse.inside(R.player)) {
				d = R.player;
			} else if (R.worldmapplayer.exists  && FlxG.mouse.justPressed && FlxG.mouse.inside(R.worldmapplayer)) {
				d = R.worldmapplayer;
			}
		}
		if (d != null) {
			mode_edit_ctr = 0;
			if (FlxG.keys.pressed.C) {
				do_add_child_in_edit = true;
				flash(true);
				extra_text.text = "Now click the child";
				editable_ent = d;
				return;
			}
			mode_edit_attrs = null;
			mode_edit_new_val = "";
			editable_ent = d;
			if (editable_ent.props == null) {
				editable_ent = null;
				return;
			}
			editable_ent.on_clicked_for_edit();
			mode_edit_cur_page = 0;
			mode_entity_set_attrs(editable_ent);
			if (mode_edit_attrs[0] == "") { // Then this MySprite had no editable atribuets so ignore it IGNORE IT
				editable_ent = null;
				return;
			}
			mode_edit_ctr = 1;
			flash(true);
		}
		
		switch (mode_edit_ctr) {
			case 0:
			case 1:
				if (R.input.jpRight) {
					if (mode_edit_cur_page < mode_edit_max_pages - 1) {
						mode_edit_cur_page++;
						mode_entity_set_attrs(editable_ent);
					}
				} else if (R.input.jpLeft) {
					if (mode_edit_cur_page > 0) {
						mode_edit_cur_page = 0;
						mode_entity_set_attrs(editable_ent);
					}
				}
				var nr:String = HF.read_number("");
				if (nr != "") {
					var nrint:Int = Std.parseInt(nr);
					if (mode_edit_attrs[nrint] != "") {
						mode_edit_active_attr = mode_edit_attrs[nrint];
						mode_edit_ctr = 2;
						// Or add a different functionality, then return tos omewhere (For setting links, etc)
						flash(true);
					} else {
						flash(false);
					}
				}
			case 2:
				status_text.text = "New value for " + mode_edit_active_attr + " : " + mode_edit_new_val;
				mode_edit_new_val = HF.read_number(mode_edit_new_val);
				mode_edit_new_val = HF.read_letter(mode_edit_new_val);
				if (FlxG.keys.myJustPressed("ESCAPE")) {
					status_text.text = "cancelled";
					mode_edit_ctr = 1;
					mode_edit_new_val = "";
					return;
				}
				if (FlxG.keys.myJustPressed("PERIOD")) {
					mode_edit_new_val += ".";
				}
				if (FlxG.keys.myJustPressed("COMMA")) {
					mode_edit_new_val += ",";
				}
				if (FlxG.keys.myJustPressed("SPACE")) {
					mode_edit_new_val += "_";
				}
				if (FlxG.keys.myJustPressed("BACKSPACE")) {
					mode_edit_new_val = mode_edit_new_val.substring(0, mode_edit_new_val.length - 1);
					
				}
				if (FlxG.keys.myJustPressed("ENTER")) {
					if (mode_edit_new_val == "") {
						flash(false);
						return;
					}
					flash(true);
					if (mode_edit_new_val.indexOf(",") == -1 && mode_edit_new_val.indexOf(".") != -1 && mode_edit_new_val.indexOf("HX") == -1) {
						var newvalfloat:Float = Std.parseFloat(mode_edit_new_val);
						editable_ent.props.set(mode_edit_active_attr, newvalfloat);
					} else if (true == HF.has_letter(mode_edit_new_val) || mode_edit_new_val.indexOf(",") != -1) {
						var newvalstring:String = mode_edit_new_val;
						editable_ent.props.set(mode_edit_active_attr, newvalstring);
					} else {
						var newvalint:Int = Std.parseInt(mode_edit_new_val);
						editable_ent.props.set(mode_edit_active_attr, newvalint);
					}
					editable_ent.set_properties(editable_ent.props);
					mode_entity_set_attrs(editable_ent); // Update visual stuff
					//editable_ent = null;
					status_text.text = " ";
					mode_edit_new_val = "";
					mode_edit_ctr = 1;
				}
				
		}
		
		
	}
	private function flash(good:Bool = false) { 
		if (good) {
			FlxG.cameras.flash(0xff11ee11, 0.2);
		} else {
			FlxG.cameras.flash(0xffff2222, 0.2);
		}
	}
	private function mode_entity_set_attrs(editable_ent:MySprite):Void {
		
		var i:Int = 0;
		mode_edit_attrs = ["", "", "", "", "", "", "", "", "",""];
		extra_text.text = "";
		for (k in editable_ent.props.keys()) {
			if (i >= mode_edit_cur_page*10 && i < (mode_edit_cur_page+1)*10) {
				extra_text.text += Std.string(i%10) + ": " + k + " = " + Std.string(editable_ent.props.get(k)) + "\n";
				mode_edit_attrs[i%10] = k;
			}
			i++;
		}
		extra_text.text = editable_ent.name + " " + Std.string(editable_ent.geid) + "\n" + extra_text.text;
		mode_edit_max_pages = Std.int((i - 1) / 10) + 1;
		if (mode_edit_max_pages > 1) {
			extra_text.text += "press arrowkeys for more";
		}
	}
	// Only finds MySprites
	private function find_entity_with_click(del:Bool=false,skip_click_check:Bool=false,only_this_group:Int=-1):Dynamic {
		if (FlxG.mouse.justPressed || skip_click_check) {
			var d:Dynamic = null;
			var ag:FlxGroup;
			var groups:Array<FlxGroup> = cur_state.get_entity_sprite_layers();
			for (i in 0...groups.length) {
				ag = groups[groups.length - i - 1];
				
				if (only_this_group != -1) {
					if (only_this_group == MyState.ENT_LAYER_IDX_BELOW_BG) {
						if (ag != cur_state.below_bg_sprites) continue;
					} else if (only_this_group == MyState.ENT_LAYER_IDX_BG1) {
						if (ag != cur_state.bg1_sprites) continue;
					} else if (only_this_group == MyState.ENT_LAYER_IDX_BG2) {
						if (ag != cur_state.bg2_sprites) continue;
					} else if (only_this_group == MyState.ENT_LAYER_IDX_FG2) {
						if (ag != cur_state.fg2_sprites) continue;
					}
				}
				
				for (j in 0...ag.members.length) {
					d = ag.members[ag.members.length - j - 1];
					if (d != null && Std.is(d, MySprite) && FlxG.mouse.inside(d)) {
						if (del && d.linked_sprite == null) { // Only delete if this is an independent mysprite (i.e. not camera trigger regions0
							ag.remove(d, true);
							d.CUT_CHILD_RELATIONSHIPS(d.children);
							d.CUT_PARENT_RELATIONSHIPS(d.parents);
							d.destroy();
						}
						
						if (hide_zones) {
							if (Std.is(d, SoundZone) || Std.is(d, NewCamTrig)) {
								//Log.trace("ehllo?");
								continue;
							}
						}
						
						return d;
					/* If a FlxGroup, iterate through its members  - no more depth after this (Dear god WHY?) */
					} else if (d != null && Std.is(d, FlxGroup)) {
						var group_member:Dynamic = null;
						if (d.members != null) {
						for (k in 0...d.members.length) {
							group_member = d.members[k];
							if (group_member != null && Std.is(group_member, MySprite) && FlxG.mouse.inside(group_member)) {
								if (del && group_member.linked_sprite == null) {
									ag.remove(group_member, true);
									group_member.destroy();
								}
								return group_member;
							} // else fuck me
						}
						}
					}
				}
			}
		}
		return null;
	}
	private var mode_change_state:Int = 0;
	private var mode_change_ctr:Int = 0;
	private var input_string:String = "";
	private var mode_change_next_width:Int;
	private var mode_change_next_height:Int;
	private var mode_change_next_name:String;
	private var mode_change_next_tileset_name:String;
	
	private function update_mode_change_maps():Void {
				
		if (FlxG.keys.myJustPressed("BACKSPACE")) {
			if (input_string.length > 0) {
				input_string = input_string.substring(0, input_string.length - 1);
			}
		}
		
		if (mode_change_state == 0 && FlxG.keys.justPressed.F) {
			if (FlxG.drawFramerate == 30) {
				Log.trace("draw framerate: now 60");
				FlxG.drawFramerate = 60;
			} else {
				Log.trace("draw framerate: now 30");
				FlxG.drawFramerate = 30;
			}
		}
		/**
		 * Creating a new map.
		 */
		if (mode_change_state == 1) {
			if (mode_change_ctr == 0) {
				extra_text.text = "ENTER WIDTH IN TILES\n" + input_string;
				if (input_string.length < 3) input_string = HF.read_number(input_string);
				if (FlxG.keys.myJustPressed("ENTER")) {
					mode_change_next_width = Std.parseInt(input_string);
					if (mode_change_next_width < 300) {
						mode_change_ctr ++;
					}
					input_string = "";
				}
			} else if (mode_change_ctr == 1) {
				extra_text.text = "ENTER HEIGHT IN TILES\n" + input_string;
				if (input_string.length < 3) input_string = HF.read_number(input_string);
				if (FlxG.keys.myJustPressed("ENTER")) {
					mode_change_next_height = Std.parseInt(input_string);
					if (mode_change_next_height < 300) {
						mode_change_ctr ++;
					}
					input_string = "";
				}
			} else if (mode_change_ctr == 2) {
				extra_text.text = "Enter new NONEXISTANT map name\n" + input_string;
				if (input_string.length < 24) input_string = HF.read_letter_number(input_string);
				if (FlxG.keys.myJustPressed("ENTER") && input_string.length > 3) {
					#if cpp
					if (FileSystem.exists(C.EXT_CSV + input_string + "_BG.csv")) {
						FlxG.cameras.flash(0xffff0000, 0.3);
						input_string = "";
					} else {
						mode_change_next_name = input_string;
						mode_change_ctr ++;
						input_string = "";
					}
					#end
				}
			} else if (mode_change_ctr == 3) {
				extra_text.text = "Enter EXISTING tileset prefix\n" + input_string;
				if (input_string.length < 24) input_string = HF.read_letter_number(input_string);
				if (FlxG.keys.myJustPressed("ENTER")) {
					#if cpp
					if (!FileSystem.exists(C.EXT_TILESET + input_string + "_tileset.png")) {
						FlxG.cameras.flash(0xffff0000, 0.3);
						input_string = "";
					} else {
						mode_change_next_tileset_name = input_string;
						mode_change_ctr ++;
						extra_text.text = "CONFIRM (y/n): " + mode_change_next_name + "\n" +  Std.string(mode_change_next_width) + "x" + Std.string(mode_change_next_height) + "\n" + mode_change_next_tileset_name + " Tiles";
					}
					#end
				}
				
			} else if (mode_change_ctr == 4) {
				if (FlxG.keys.myJustPressed("N")) {
					mode_change_ctr = 0;
					input_string = "";
				} else if (FlxG.keys.myJustPressed("Y")) {
					// Update the tileset hash, entity hash
					EMBED_TILEMAP.tileset_hash.set(mode_change_next_name, EMBED_TILEMAP.direct_tileset_hash.get(mode_change_next_tileset_name));
					EMBED_TILEMAP.tileset_name_hash.set(mode_change_next_name, mode_change_next_tileset_name);	
					EMBED_TILEMAP.entity_hash.set(mode_change_next_name, "");
					
					// Clear out tilemaps and update the csv hash.
					var csv:String = FlxX.createEmptyCSV(mode_change_next_width, mode_change_next_height);
					var maps:Array<FlxTilemapExt> = [cur_state.tm_bg, cur_state.tm_bg2, cur_state.tm_fg, cur_state.tm_fg2];
					update_csv_hash(mode_change_next_name, maps, [csv, csv, csv, csv]);
					HelpTilemap.set_map_csv(mode_change_next_name, maps);
					HelpTilemap.set_map_props(mode_change_next_tileset_name,cur_state);
					
					// Reset entities
					HF.clear_entities_from_mystate(cur_state);
					HF.save_map_entities(mode_change_next_name, cur_state);
					
					// Write our new map CSVs to disk.
					cur_state.MAP_NAME = mode_change_next_name;
					cur_state.TILESET_NAME = mode_change_next_tileset_name;
					HF.write_map_csv(cur_state.MAP_NAME, cur_state);
					
					// Finally reset the camera bounds
					FlxG.camera.setScrollBoundsRect(0, 0, cur_state.tm_bg.width, cur_state.tm_bg.height);
					invishard_coords_initialized = false;
				}
			}
		} else if (mode_change_state == 2) {
			extra_text.text = "Enter map name to load." + input_string;
			input_string = HF.read_letter_number(input_string);
			if (FlxG.keys.myJustPressed("SPACE")) {
				input_string += "_";
			}
			if (FlxG.keys.myJustPressed("ENTER")) {
				#if cpp
				if (ProjectClass.DEV_MODE_ON == false) {
					if (FileSystem.exists("assets/csv/" + input_string + ".bcsv")) {
						change_instant(input_string);
						input_string = "$$$";
					}
				} else if (FileSystem.exists(C.EXT_CSV + input_string + ".bcsv") || FileSystem.exists(C.EXT_CSV + input_string + "_BG.csv")) {
					change_instant(input_string);
					input_string = "$$$";
				}
				#end
			}
		} else if (mode_change_state == 0) {
			//Log.trace(input_string);
			if (input_string == "$$$") {
				input_string = "$$";
			} else 	if (input_string == "$$") {
				var ms:MyState = cast cur_state;
				
				FlxG.camera.setScrollBoundsRect( -64, -64, ms.tm_bg.width + 128, ms.tm_bg.height + 128);
				input_string = "";
				//Log.trace("hi");
			}
			if (FlxG.keys.myJustPressed("N")) {
				mode_change_state = 1;
				input_string = "";
			} else if (FlxG.keys.myJustPressed("L")) {
				mode_change_state = 2;
				input_string = "";
				// Resize
			} else if (FlxG.keys.myJustPressed("S")) {
				mode_change_ctr = 0;
				mode_change_state = 3;
				input_string = "";
			}
		} else if (mode_change_state == 3) {
			switch (mode_change_ctr) {
				case 0:
					extra_text.text = "Change map dimensions? (y/n)\n";
					if (FlxG.keys.myJustPressed("Y")) {
						mode_change_ctr = 1;
					}
				case 1:
					extra_text.text = "Enter new width:\n" + input_string;
					input_string = HF.read_number(input_string);
					if (FlxG.keys.myJustPressed("ENTER")) {
						
						mode_change_next_width = Std.parseInt(input_string);
						input_string = "";
						if (mode_change_next_width < 300) {
							mode_change_ctr = 2;
						}
					}
				case 2:
					extra_text.text = "Enter new height:\n" + input_string;
					input_string = HF.read_number(input_string);
					if (FlxG.keys.myJustPressed("ENTER")) {
						mode_change_next_height = Std.parseInt(input_string);
						if (mode_change_next_height < 300) {
							mode_change_ctr = 3;
						}
						input_string = "";
					}
				case 3:
					extra_text.text = "Confirm: " + Std.string(mode_change_next_width) + " by " + Std.string(mode_change_next_height) + " (y/n)";
					if (FlxG.keys.myJustPressed("Y")) {
						var tg:BitmapData = EMBED_TILEMAP.tileset_hash.get(cur_state.MAP_NAME);
						cur_state.tm_bg.change_dimensions(mode_change_next_width, mode_change_next_height, tg);
						cur_state.tm_bg2.change_dimensions(mode_change_next_width, mode_change_next_height, tg);
						cur_state.tm_fg.change_dimensions(mode_change_next_width, mode_change_next_height, tg);
						cur_state.tm_fg2.change_dimensions(mode_change_next_width, mode_change_next_height, tg);
					}
					HelpTilemap.set_map_props(R.TEST_STATE.TILESET_NAME, R.TEST_STATE);
					// reload
			}
		}
		
		
		if (FlxG.keys.pressed.ALT) {
			for (i in 0...C.NR_WORD_ARRAY.length) {
				if (FlxG.keys.myJustPressed(C.NR_WORD_ARRAY[i])) {
					var keykeykey:String = Std.string(i+1);
					if (i == 9) keykeykey = "0";
					var key:String = "";
					var gg:Map < String, Dynamic > = GenericNPC.generic_npc_data.get("editor_fast");
					for (key in gg.keys()) {
						var break_here:Bool = false;
						var g:Map < String, Dynamic > = cast GenericNPC.generic_npc_data.get("editor_fast").get(key);
						for (_key in g.keys()) {
							if (g.get(_key) == R.TEST_STATE.MAP_NAME) {
								if (g.exists(keykeykey)) {
									change_instant(g.get(keykeykey));
									break_here = true;
									break;
								}
							}
						}
						if (break_here) break;
					}
				}
			}
		}
		
		if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.B) {
			in_bg_move_mode = !in_bg_move_mode;
			FlxG.cameras.shake(0.01, 0.1);
			status_text.text = "BG MOVE IS ON: "+Std.string(in_bg_move_mode);
		}
		if (in_bg_move_mode) {
			if (FlxG.keys.justPressed.ONE) {
				status_text.text = "Moving BG layers";
				in_bg_move_set_idx = 0;
				in_bg_move_idx = 0;
			} else if (FlxG.keys.justPressed.TWO) {
				status_text.text = "moving bg1 layers";
				in_bg_move_set_idx = 1;
				in_bg_move_idx = 0;
			}
			if (FlxG.keys.justPressed.Q) {
				if (in_bg_move_idx > 0) {
					in_bg_move_idx --;
				status_text.text = "moving layer " + Std.string(in_bg_move_idx);
				}
			} else if (FlxG.keys.justPressed.W) {
				if (in_bg_move_set_idx == 0 && in_bg_move_idx  < cur_state.bg_parallax_layers.length - 1) {
					in_bg_move_idx++;
				status_text.text = "moving layer " + Std.string(in_bg_move_idx);
				} else if (in_bg_move_set_idx == 1 && in_bg_move_idx < cur_state.fg1_parallax_layers.length - 1) {
					in_bg_move_idx++;
				status_text.text = "moving layer " + Std.string(in_bg_move_idx);
				}
			}
			
			var cur_layer:FlxSprite = null;
			if (in_bg_move_set_idx == 0) {
				if (cur_state.bg_parallax_layers.length != 0) {
					cur_layer = cast cur_state.bg_parallax_layers.members[in_bg_move_idx];
				}
			} else if (in_bg_move_set_idx == 1) {
				if (cur_state.fg1_parallax_layers.length != 0) {
					cur_layer = cast cur_state.fg1_parallax_layers.members[in_bg_move_idx];
				}
			}
			if (cur_layer != null) {
				var s:String = " ";
				var mul:Int = 1;
				var bbbb:Bool = false;
				if (FlxG.keys.pressed.SHIFT) {
					mul = 16;
				}
				if (FlxG.keys.justPressed.RIGHT) {
					bbbb = true;
					if (FlxG.keys.pressed.ALT) cur_layer.scrollFactor.x += 0.01 * mul;
					if (!FlxG.keys.pressed.ALT) cur_layer.x += mul;
				} else if (FlxG.keys.justPressed.LEFT) {
					bbbb = true;
					if (FlxG.keys.pressed.ALT) cur_layer.scrollFactor.x -= 0.01 * mul;
					if (!FlxG.keys.pressed.ALT) cur_layer.x -= mul;
				} else if (FlxG.keys.justPressed.UP) {
					bbbb = true;
					if (FlxG.keys.pressed.ALT) cur_layer.scrollFactor.y -= 0.01 * mul;
					if (!FlxG.keys.pressed.ALT) cur_layer.y -= mul;
				} else if (FlxG.keys.justPressed.DOWN) {
					bbbb = true;
					if (FlxG.keys.pressed.ALT) cur_layer.scrollFactor.y += 0.01 * mul;
					if (!FlxG.keys.pressed.ALT) cur_layer.y += mul;
				}
				if (cur_layer.scrollFactor.x < 0) cur_layer.scrollFactor.x = 0;
				if (cur_layer.scrollFactor.y < 0) cur_layer.scrollFactor.y = 0;
				
				if (bbbb) {
					s = "set " + Std.string(in_bg_move_set_idx) + " layer " + Std.string(in_bg_move_idx) + " sx/sy/x/y: " + Std.string([cur_layer.scrollFactor.x, cur_layer.scrollFactor.y, cur_layer.x, cur_layer.y]);
					Log.trace(s);
					status_text.text = s;
				}
			}
		}
		
	}
	
	private function change_instant(input_string:String):Void {
		//FlxG.cameras.flash(0xff00ff00, 0.3);
		cur_state.DO_CHANGE_MAP = true;
		cur_state.next_map_name = input_string;
		mode_change_state = 0;
		extra_text.text = "L = load, N = new";
		
		// Reload BG mapping data from the dev folder
		if (ProjectClass.DEV_MODE_ON) {
			EMBED_TILEMAP.init(true, true);
		}
		cur_state.next_tileset_name = EMBED_TILEMAP.tileset_name_hash.get(input_string);
		R.player.reset_motion_state();
	}
	
	private var mode_move_state:Int = 0;
	public var movable_sprite:MySprite;
	private var depth_changeable_sprite:MySprite;
	
	// 2 = bg2_sprites, 4 = fg2_sprites
	public var mode_add_cur_group_idx:Int = 2;
	private var mode_add_cur_entity_set:Int = 0;
	private var mode_add_cur_entity_idx:Int = 0;
	private var moving_in_add:Bool = false;
	private static inline var MAX_ENTITY_SETS:Int = 10;
	private static inline var MAX_ENTITY_SET_SIZE:Int = 10;
	private static  var ENTITY_NAMES:Array<Array<String>> = 
	[ 
		["Pew", "Door", "SavePoint", "GasCloud", "RubberLaser", "LavaPillar", "Pod", "EnergyGate", "CameraTrigger","SongTrigger"], 
		["EnergyOrb", "OrbSlot", "RaiseWall", "SapPad", "GenericNPC", "TrainTrigger", "AliphItem", "PathUnlocker", "FollowLaser", "HelpTip"] ,
		["Cutscene", "Wind", "HurtOutlet", "NearCannon", "ShoreBot", "NewWaterShooter", "Weed", "AmbiencePlayer", "BugSwarm", "Dropper"],
		["SinkPlatform", "BubbleSpawner", "BubbleSwitch", "Spike", "VanishBlock", "GreenhousePlant", "Checkpoint", "PushField", "LaunchBug", "TileFader"],
		["Dasher", "ExtendStem", "Neutralizer", "DaisyCluster", "Fish", "Stopper", "WirePoint", "BarbedWire", "EdgeDoor", "Cauliflower"],
		["StickySlime", "Bouncer", "Button", "ShockFloat", "Mole", "MoleTile", "ShoreSpore", "RevolveSpore", "Broadcaster", "TriggeredLaser"],
		["ClimbSpore", "WallBouncer", "SquishyChaser", "AimSpore", "SquishBounce", "PlantBlock", "PlantBlockAccepter", "BallDropper", "Hopper", "MoveBlock"],
		["FlameBlower", "Inverter", "MiniMoveBlock", "SmashHand", "Pendulum", "MirrorLaser", "SpikeExtend", "WaterCharger", "Floater", "BatThing"],
		["SetPiece","OuchOutlet","ArmLocker","MovePod","LaserBlock","LightBox","WaterShooter","WaterGlider","GhostLight","WalkPod"],
		["WalkBlock","Elevator","FlameOn","FloatWall","NewCamTrig","LineCollider","SoundZone","ToneFader","WMScaleSprite","FloatPod"]
	];
	
	/**
	 * Recursively calls this function until the passed sprite
	 * doesn't have a geid that matches any others in the group
	 * @param	g
	 * @param	ms
	 */
	private function check_for_dup_geid(parent_state:MyState, ms:MySprite):Void {
		var a:Array<FlxGroup> = parent_state.get_entity_sprite_layers();
		var try_again:Bool = false;
		while (true) {
			for (j in 0...a.length) {
				var g:FlxGroup = a[j];
				for (i in 0...g.members.length) {
					if (g.members[i] != null &&  Std.is(g.members[i], MySprite) && ms.geid == cast(g.members[i], MySprite).geid) {
						ms.geid = Math.floor(1000000.0 * Math.random());
						try_again = true;
						break;
					}
				}
				if (try_again) {
					break;
				}
			}
			if (try_again) {
				try_again = false;
				continue;
			}
			break;
		}
	}
	
	private var big_select_ed:FlxSprite;
	private var big_select_or:FlxSprite;
	private var big_ent_select_mode:Int = 0;
	private var big_ent_sub:Int = 0;
	private var rect_select_start:Point;
	private var big_ent_array:Array<Array<MySprite>>;
	private var mousecontact:Point;
	
	private function get_big_entity_array(r:FlxObject):Array<Array<MySprite>> {
		var g:FlxGroup = null;
		var a:Array<Array<MySprite>> = [[],[],[],[],[]];
		for (g in cur_state.get_entity_sprite_layers()) {
			var idx:Int = 0;
			if (g == cur_state.below_bg_sprites) {
				idx = 0;
			} else if (g == cur_state.bg2_sprites) {
				idx = 2;
			} else if (g == cur_state.bg1_sprites) {
				idx = 1;
			} else if (g == cur_state.fg2_sprites) {
				idx = 4;
			} else {
				idx = -1;
				continue;
			}
			
			for (e in g.members) {
				if (e != null && Std.is(e, MySprite) && r.overlaps(e)) {
					a[idx].push(cast e);
				}
			}
		}
		return a;
		
	}
	private function snap16(f:Float):Float {
		return Std.int(f) - Std.int(f) % 16;
	}
	private function rect_select_is_started():Bool {
		if (FlxG.mouse.justPressed) {
			rect_select_start = new Point(FlxG.mouse.x, FlxG.mouse.y);
			big_select_or.move(rect_select_start.x, rect_select_start.y);
			if (!FlxG.keys.pressed.SHIFT) {
				big_select_or.x = Std.int(big_select_or.x) - Std.int(big_select_or.x) % 16;
				big_select_or.y = Std.int(big_select_or.y) - Std.int(big_select_or.y) % 16;
			}
			return true;
		}
		return false;
	}
	private function rect_select_finish():Bool {
		var mx:Float = FlxG.mouse.x;
		var my:Float = FlxG.mouse.y;
		if (!FlxG.keys.pressed.SHIFT) {
			mx = snap16(mx);
			my = snap16(my);
		}
		
		if (mx - big_select_or.x < 16) mx = big_select_or.x + 16;
		if (my - big_select_or.y < 16) my = big_select_or.y + 16;
		
		big_select_or.scale.set(mx - big_select_or.x, my- big_select_or.y);
		if (FlxG.mouse.justPressed) {
			if (mx < rect_select_start.x) {
				big_select_or.scale.x *= -1;
				big_select_or.x = mx;
			}
			if (my < rect_select_start.y) {
				big_select_or.scale.y *= -1;
				big_select_or.y	 = my;
			}
			return true;
		}
		return false;
	}
	
	
	private function get_big_tile_array(o:FlxObject):Array<Array<Array<Int>>> {
		var _big_tile_array:Array<Array<Array<Int>>> = [];
		var ltx:Int = Std.int(o.x / 16);
		var lty:Int = Std.int(o.y / 16);
		var h:Int = Std.int(o.height / 16);
		var w:Int = Std.int(o.width / 16);
		var res:Int = 0;
		for (i in 0...4) {
			_big_tile_array.push([]);
			if (b_active_tile_layers[i]) {
				var tm:FlxTilemapExt = cur_state.get_tilemaps()[i];
				for (y in 0...h) {
					_big_tile_array[i].push([]);
					for (x in 0...w) {
						res = get_anim_tile_ID_if_exists(x + ltx, y + lty, tm);
						if (res != -1) {
							// push original tile data of anim
							_big_tile_array[i][y].push(res);
						} else {
							_big_tile_array[i][y].push(tm.getTile(x + ltx, y + lty));
						}
					}
				}
			}
		}
		return _big_tile_array;
	}

	private var big_tile_array:Array<Array<Array<Int>>>;
	private var big_tile_select_mode:Int = 0;
	private var big_tile_sub:Int = 0;
	
	private var bt_previews_added:Bool = false;
	
	private function update_big_tile_select():Void {
		switch (big_tile_select_mode) {
			case 0:
				if (big_tile_sub == 0) {
					if (rect_select_is_started()) {
						big_tile_sub = 1;
					}
				} else if (big_tile_sub == 1) {
					if (rect_select_finish()) {
						big_tile_array = get_big_tile_array(new FlxObject(big_select_or.x, big_select_or.y, big_select_or.scale.x, big_select_or.scale.y));
						big_tile_sub = 0;
						big_tile_select_mode = 1;
					}
				}
			case 1:
				if (FlxG.mouse.justPressed) {
					if (FlxG.mouse.inside(new FlxObject(big_select_or.x, big_select_or.y, big_select_or.scale.x, big_select_or.scale.y))) {
						// mouse contact coords are relative to the offset from big_select_ed
						mousecontact = new Point(snap16(FlxG.mouse.x) - big_select_or.x, snap16(FlxG.mouse.y) - big_select_or.y);
						big_select_ed.scale.set(big_select_or.scale.x, big_select_or.scale.y);
						big_tile_select_mode = 2;
					} else {
						big_tile_select_mode = 0;
						big_tile_array = [];
						big_select_or.scale.set(1, 1);
						big_select_or.move(0, 0);
					}
				}
			case 2:
				if (!bt_previews_added) {
					bt_previews_added = true;
					bt_add_previews(big_tile_array, cur_state.tm_bg.graphic.bitmap);
				}
				
				
				big_select_ed.x = snap16(FlxG.mouse.x) - mousecontact.x;
				big_select_ed.y = snap16(FlxG.mouse.y) - mousecontact.y;
				
				
				if (big_select_ed.x < 0) big_select_ed.x = 0;
				if (big_select_ed.y < 0) big_select_ed.y = 0;
				if (big_select_ed.x + big_select_ed.scale.x > cur_state.tm_bg.width) big_select_ed.x = cur_state.tm_bg.width - big_select_ed.scale.x;
				if (big_select_ed.y + big_select_ed.scale.y > cur_state.tm_bg.height) big_select_ed.y = cur_state.tm_bg.height - big_select_ed.scale.y;
				
				bt_bg2.move(big_select_ed.x, big_select_ed.y);
				bt_bg1.move(big_select_ed.x, big_select_ed.y);
				bt_fg2.move(big_select_ed.x, big_select_ed.y);
				bt_fg1.move(big_select_ed.x, big_select_ed.y);
				
				var tlx:Int = Std.int(big_select_ed.x / 16);
				var tly:Int = Std.int(big_select_ed.y / 16);
				var old_tlx:Int = Std.int(big_select_or.x / 16);
				var old_tly:Int = Std.int(big_select_or.y / 16);
				var j:Int = 0;
				if (FlxG.mouse.justPressed || FlxG.keys.justPressed.V || FlxG.keys.justPressed.D || FlxG.keys.justPressed.P) {
					for (i in 0...4) {
						if (b_active_tile_layers[i]) {
							var tm:FlxTilemapExt = cur_state.get_tilemaps()[i];
							
							j = 0;
							for (row in big_tile_array[i]) {
								if (buf_no_tile_delete) {
									buf_no_tile_delete = false;
									break;
								}
								// If not copy/pasting and not in buf load mode -> delete old tiles
								// (You shouldn't need to delete stuff when you load a buffer)
								if (!FlxG.keys.justPressed.V && !FlxG.keys.justPressed.P && mode_b != BUF_LOAD) {
									for (k in 0...row.length) {
										tm.setTile(old_tlx + k, old_tly + j, 0, true);
										if (i == 0) {
											cur_invishard_coords.remove((old_tly + j) * tm.widthInTiles + old_tlx + k);
											remove_animated_tile(old_tlx + k, old_tly + j, tm);
										} else if (i == 1) {
											cur_invishard_coords_bg2.remove((old_tly + j) * tm.widthInTiles + old_tlx + k);
											remove_animated_tile(old_tlx + k, old_tly + j, tm);
										}
									}
								}
								j++;
							}
							j = 0;
							for (row in big_tile_array[i]) {
								// If not deleting -> move the tiles
								if (!FlxG.keys.justPressed.D) {
									for (k in 0...row.length) {
										tm.setTile(tlx + k, tly + j, row[k], true);
										// add_anim must come after setTile
										if (i == 0 || i == 1) {
											add_animated_tile(tlx + k, tly + j, tm);
										}
										if (i == 0) {
											if (HelpTilemap.invishard.indexOf(row[k]) != -1) {
												cur_invishard_coords.set((tly + j) * tm.widthInTiles + tlx + k, new FlxPoint(16 * (tlx + k), 16 * (tly + j)));
											}
										} else if (i == 1) {
											if (HelpTilemap.invishard.indexOf(row[k]) != -1) {
												cur_invishard_coords_bg2.set((tly + j) * tm.widthInTiles + tlx + k, new FlxPoint(16 * (tlx + k), 16 * (tly + j)));
											}
										}
									}
								}
								j++;
							}
						}
					}
				} 
				
				if (FlxG.keys.justPressed.ONE) {
					for (i in 0...4) {
						if (b_active_tile_layers[i]) {
							j = 0;
							for (row in big_tile_array[i]) {
								row.reverse(); // thank god for api
							}
						}
						var tm:FlxTilemapExt = cur_state.get_tilemaps()[i];
						for (row in big_tile_array[i]) {
							for (k in 0...row.length) {
								tm.setTile(tlx + k, tly + j, row[k], true);
							}
							j++;
						}
					}
				}
				
				// add "2" for paste and exit
				// Cut + Paste or Delete. IF just copy paste (V) , continue going.
				if (FlxG.mouse.justPressed || FlxG.keys.justPressed.ONE || FlxG.keys.justPressed.D || FlxG.keys.justPressed.P) {
					big_select_ed.scale.set(1, 1); big_select_or.scale.set(1, 1);
					big_tile_array = [];
					big_tile_select_mode = 0;
					bt_previews_added = false;
					remove_bt_previews();
				}
		}
	}
	private function update_big_entity_select():Void {
		
			switch (big_ent_select_mode) {
				case 0:
					if (big_ent_sub == 0) {
						if (rect_select_is_started()) {
							big_ent_sub = 1;
						}
					} else if (big_ent_sub == 1) {
						if (rect_select_finish()) {
							big_ent_array = get_big_entity_array(new FlxObject(big_select_or.x, big_select_or.y, big_select_or.scale.x, big_select_or.scale.y));
							big_ent_sub = 0;
							big_ent_select_mode = 1;
						}
					}
				case 1:
					if (FlxG.mouse.justPressed) {
						if (FlxG.mouse.inside(new FlxObject(big_select_or.x, big_select_or.y, big_select_or.scale.x, big_select_or.scale.y))) {
							// mouse contact coords are relative to the offset from big_select_ed
							if (!FlxG.keys.pressed.SHIFT) {
								mousecontact = new Point(snap16(FlxG.mouse.x) - big_select_or.x, snap16(FlxG.mouse.y) - big_select_or.y);
							} else {
								mousecontact = new Point(FlxG.mouse.x - big_select_or.x, FlxG.mouse.y - big_select_or.y);
							}
							big_select_ed.scale.set(big_select_or.scale.x, big_select_or.scale.y);
							big_ent_select_mode = 2;
						} else {
							big_ent_select_mode = 0;
							big_ent_array = [];
							big_select_or.scale.set(1, 1);
							big_select_or.move(0, 0);
						}
					}
				case 2: // if attached
					big_select_ed.x = snap16(FlxG.mouse.x) - mousecontact.x;
					big_select_ed.y = snap16(FlxG.mouse.y) - mousecontact.y;
					
					
					if (big_select_ed.x < 0) big_select_ed.x = 0;
					if (big_select_ed.y < 0) big_select_ed.y = 0;
					if (big_select_ed.x + big_select_ed.scale.x > cur_state.tm_bg.width) big_select_ed.x = cur_state.tm_bg.width - big_select_ed.scale.x;
					if (big_select_ed.y + big_select_ed.scale.y > cur_state.tm_bg.height) big_select_ed.y = cur_state.tm_bg.height - big_select_ed.scale.y;
					
					
					if (FlxG.keys.myJustPressed("ONE")) {
						var selection_origin:Point = new Point(big_select_ed.x, big_select_ed.y);
						for (a in big_ent_array) {
							for (i in 0...a.length) {
								a[i].x = a[i].ix  = Std.int((big_select_ed.x + big_select_ed.scale.x) - a[i].width - (a[i].ix - big_select_ed.x));
								//a[i].y = a[i].iy = Std.int((big_select_ed.y + big_select_ed.scale.y) - a[i].height - (a[i].iy - big_select_ed.y));
							}
						}
					}
					
					if (FlxG.mouse.justPressed || FlxG.keys.justPressed.ONE || FlxG.keys.justPressed.V || FlxG.keys.justPressed.P) {
						
						if (FlxG.mouse.justPressed || FlxG.keys.justPressed.ONE || FlxG.keys.justPressed.P) {
							big_ent_select_mode = 0;
							big_select_ed.scale.set(1, 1);
							big_select_or.scale.set(1, 1);
						}
						var j:Int = 0;
						for (a in big_ent_array) {
							for (i in 0...a.length) {
								if (FlxG.keys.justPressed.V || FlxG.keys.justPressed.P) {
									var m:Dynamic = SpriteFactory.make(a[i].name, a[i].ix + Std.int((big_select_ed.x - big_select_or.x)), a[i].iy +  Std.int((big_select_ed.y - big_select_or.y)), cur_state);
									check_for_dup_geid(cur_state, cast m);
									m.set_properties(a[i].props);
									if (m.props.exists("children")) {
										m.props.set("children", "");
									}
									if (j == 0) cur_state.below_bg_sprites.add(m);
									if (j == 1) cur_state.bg1_sprites.add(m);
									if (j == 2) cur_state.bg2_sprites.add(m);
									if (j == 4) cur_state.fg2_sprites.add(m);
								} else {
									a[i].ix += Std.int((big_select_ed.x - big_select_or.x));
									a[i].iy += Std.int((big_select_ed.y - big_select_or.y));
									a[i].x = a[i].ix;
									a[i].y = a[i].iy;
								}
							}
							j++;
						}
						if (!FlxG.keys.justPressed.V) {
							clear_big_ent_array();
						}
					} else if (FlxG.keys.justPressed.D) {
						big_ent_select_mode = 0;
						big_select_ed.scale.set(1, 1);
						big_select_or.scale.set(1, 1);
						var j:Int = 0;
						for (a in big_ent_array) {
							for (i in 0...a.length) {
								if (j == 0) {
									cur_state.below_bg_sprites.remove(a[i], true);
								} else if (j == 1) {
									cur_state.bg1_sprites.remove(a[i], true);
								} else if (j == 2) {
									cur_state.bg2_sprites.remove(a[i], true);
								} else if (j == 4) {
									cur_state.fg2_sprites.remove(a[i], true);
								}
							}
							j++;
						}
						big_ent_array = destroy_big_ent_array(big_ent_array);
					}
			}
			return;
	}
	
	private var add_remove_Alt:Bool = false;
	private var add_is_big_select:Bool = false;
	private var doorhelper_on:Bool = false;
	private var doorhelper_props:Map<String,Dynamic>;
	
	private function door_helper_update(s:Dynamic):Void {
		var d:Door = cast s;
		if (doorhelper_props == null) { // Get source
			doorhelper_props = new Map<String,Dynamic>();
			HF.copy_props(d.props, doorhelper_props);
			doorhelper_props.set("_CUR_MAP", cur_state.MAP_NAME);
			doorhelper_props.set("_geid", d.geid);
			status("Door selected. Save ent data!! then choose or add next Door.");
		} else {
			var dst_auto_index:Int = d.props.get("AUTO_INDEX");
			var src_map:String = doorhelper_props.get("_CUR_MAP");
			var src_geid_string:String = Std.string(doorhelper_props.get("_geid"));
			
			// Update destination door to link to source door
			d.props.set("index", doorhelper_props.get("AUTO_INDEX"));
			d.props.set("dest_map", src_map);
			
			
			if (cur_state.MAP_NAME != src_map) {
				var s:String = EMBED_TILEMAP.entity_hash.get(src_map);
				s = JankSave.replace_prop(s.split("\n"),src_geid_string, "index=" + Std.string(dst_auto_index)).join("\n");
				s = JankSave.replace_prop(s.split("\n"), src_geid_string, "dest_map=\"" + cur_state.MAP_NAME+"\"").join("\n");
				EMBED_TILEMAP.entity_hash.set(src_map, s);
			} else {
				var _m:MySprite =  HF.get_entity_from_state_by_geid(cur_state, Std.parseInt(doorhelper_props.get("_geid")));
				if (_m == null) {
					Log.trace("Failed!...?");
				} else {
					var src_door:Door = cast _m;
					src_door.props.set("index", dst_auto_index);
					src_door.props.set("dest_map", cur_state.MAP_NAME);
				}
			}
			status("Doors linked b/w " + cur_state.MAP_NAME + " & " + src_map+". save ent data in both maps!");
			
			doorhelper_on = false;
		}
		sound_menu_confirm();
		
	}
	private function sound_menu_confirm():Void {
		R.sound_manager.play(SNDC.menu_confirm);
	}
	private function sound_menu_open():Void {
		R.sound_manager.play(SNDC.menu_open);
	}
	private function status(s:String):Void {
		status_text.text = s;
	}
	private function update_mode_add_entity():Void {
		
		if (FlxG.keys.justPressed.E) {
			sound_menu_confirm();
			init_color_type = (init_color_type + 1) % 2;
			if (init_color_type == 0) {
				init_color_sprite.animation.play("dark");
				status_text.text = "Init color is now dark";
			} else {
				init_color_sprite.animation.play("light");
				status_text.text = "Init color is now light";
			}
		}
		if (FlxG.keys.justPressed.R) {
			sound_menu_confirm();
			status_text.text = "Toggled Big Add mode";
			add_is_big_select = !add_is_big_select;
			big_select_ed.visible = big_select_or.visible = add_is_big_select;
		}
		
		if (add_is_big_select) {
			update_big_entity_select();
			return;
		}

		if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.D) {
			doorhelper_on = !doorhelper_on;
			sound_menu_open();
			if (doorhelper_on) {
				doorhelper_props = null;
				status("DoorHelper on. Click on door or add new one.");
			} else {
				status("DoorHelper off.");
			}
		}
		
		if (moving_in_add) {
			if (!FlxG.mouse.pressed) {
				// Report position to parent since this probably matters
				if (movable_sprite != null) {
					if (movable_sprite.x < 0) movable_sprite.x = 0;
					if (movable_sprite.x > cur_state.tm_bg.width) movable_sprite.x = cur_state.tm_bg.width - 4;
					if (movable_sprite.y < 0) movable_sprite.y = 0;
					if (movable_sprite.y > cur_state.tm_bg.height) movable_sprite.y = cur_state.tm_bg.height - 4;
					if (movable_sprite.linked_sprite != null) {
						movable_sprite.linked_sprite.on_child_notification(movable_sprite);
					}
					movable_sprite.recv_message(C.MSGTYPE_MOVED_BY_EDITOR);
					movable_sprite = null;
				}
				moving_in_add = false;
			} else {
				if (movable_sprite != null) {
					movable_sprite.x = movable_sprite.ix =  !FlxG.keys.pressed.SHIFT ? 16 * Math.floor(FlxG.mouse.x / 16) : Math.floor(FlxG.mouse.x);
					movable_sprite.y = movable_sprite.iy = !FlxG.keys.pressed.SHIFT ? 16 * Math.floor(FlxG.mouse.y / 16) : Math.floor(FlxG.mouse.y);
					
					movable_sprite.last.x = movable_sprite.x;
					movable_sprite.last.y = movable_sprite.y;
					if (movable_sprite == R.train) {
						R.train.move_to(movable_sprite.x, movable_sprite.y);
					}
				}
			}
		}
		if (FlxG.keys.myJustPressed("P")) {
			R.activePlayer.last.x = R.activePlayer.x = FlxG.mouse.x;
			R.activePlayer.last.y = R.activePlayer.y = FlxG.mouse.y;
			
			if (R.train.is_even_map()) {
				R.train.move_to(FlxG.mouse.x, FlxG.mouse.y);
			}
		}
		// Generate active entity type at mouse position
		// This should also guarantee there are no geid collisions
		if (R.input.mouse_clicked()) {
			
			// Delete shortcut
			if (FlxG.keys.pressed.D || FlxG.keys.pressed.Q) {
				clear_big_ent_array();
				depth_changeable_sprite = null;
				selected_entity_sprite.visible = entity_depth.visible = false;
				find_entity_with_click(true,false,mode_add_cur_group_idx);
				return;
			// move shotcut
			} else if (FlxG.keys.pressed.CONTROL) {
				if (FlxG.mouse.inside(R.activePlayer) && FlxG.mouse.justPressed) {
					if (R.activePlayer == R.worldmapplayer) {
						movable_sprite = cast(R.train, MySprite);
					} else {
						movable_sprite = cast(R.activePlayer, MySprite);
					}
					moving_in_add = true;
					return;
				} 
				movable_sprite = find_entity_with_click(false,false,mode_add_cur_group_idx);
				if (movable_sprite != null) {
					moving_in_add = true;
				}
				return;
			} else if (FlxG.keys.pressed.ALT) {
				var _d:Dynamic = create_and_add_sprite(16 * Math.floor(FlxG.mouse.x / 16), 16 * Math.floor(FlxG.mouse.y / 16), ENTITY_NAMES[mode_add_cur_entity_set][mode_add_cur_entity_idx], cur_state);
				//
				var m:Map<String,Dynamic> = new Map<String,Dynamic>();
				HF.copy_props(_d.props, m);
				if (m.exists("vis-dmg")) {
					if (init_color_type == 1 && m.get("vis-dmg") == "0,0") {
						m.set("vis-dmg", "1,1");
						var _ms:MySprite = cast _d;
						_ms.set_properties(m);
					}
				}
			} else {
			/* Higlight enttiy and show its depth within its current layer */
				depth_changeable_sprite = cast find_entity_with_click(false, false, mode_add_cur_group_idx);
				if (depth_changeable_sprite != null) {
					if (doorhelper_on && Std.is(depth_changeable_sprite, Door)) {
						door_helper_update(depth_changeable_sprite);
					}
				 	selected_entity_sprite.make_rect_outline(Std.int(4+depth_changeable_sprite.width), Std.int(4+depth_changeable_sprite.height), 0xddf6407b,"dcs");
					selected_entity_sprite.x = depth_changeable_sprite.x - 2;
					selected_entity_sprite.y = depth_changeable_sprite.y - 2;
					selected_entity_sprite.visible = true;
					entity_depth.visible = true;
					
					entity_depth.x = selected_entity_sprite.x;
					entity_depth.y = selected_entity_sprite.y;
					if (mode_add_cur_group_idx == MyState.ENT_LAYER_IDX_BELOW_BG) entity_depth.text = Std.string(FlxX.indexOf(cur_state.below_bg_sprites, depth_changeable_sprite));
					if (mode_add_cur_group_idx == MyState.ENT_LAYER_IDX_BG1) entity_depth.text = Std.string(FlxX.indexOf(cur_state.bg1_sprites, depth_changeable_sprite));
					if (mode_add_cur_group_idx == MyState.ENT_LAYER_IDX_BG2) entity_depth.text = Std.string(FlxX.indexOf(cur_state.bg2_sprites, depth_changeable_sprite));
					if (mode_add_cur_group_idx == MyState.ENT_LAYER_IDX_FG2) entity_depth.text = Std.string(FlxX.indexOf(cur_state.fg2_sprites, depth_changeable_sprite));
					
				} else {
					selected_entity_sprite.visible = false;
				}
			}
		}
		
		/* Depth switching of selected entity*/
		if (depth_changeable_sprite != null && (FlxG.keys.myJustPressed("PLUS") || FlxG.keys.myJustPressed("MINUS")))  {
			// Depth switch within groups
			if (FlxG.keys.pressed.CONTROL) {
				var curspridx:Int = -1;
				if (cur_state.below_bg_sprites.members.indexOf(depth_changeable_sprite) != -1) curspridx = MyState.ENT_LAYER_IDX_BELOW_BG;
				if (cur_state.bg1_sprites.members.indexOf(depth_changeable_sprite) != -1) curspridx = MyState.ENT_LAYER_IDX_BG1;
				if (cur_state.bg2_sprites.members.indexOf(depth_changeable_sprite) != -1) curspridx = MyState.ENT_LAYER_IDX_BG2;
				if (cur_state.fg2_sprites.members.indexOf(depth_changeable_sprite) != -1) curspridx = MyState.ENT_LAYER_IDX_FG2;
				//Log.trace([cur_state.below_bg_sprites.members.indexOf(depth_changeable_sprite), cur_state.bg1_sprites.members.indexOf(depth_changeable_sprite), cur_state.bg2_sprites.members.indexOf(depth_changeable_sprite), cur_state.fg2_sprites.members.indexOf(depth_changeable_sprite)]);
				if (FlxG.keys.myJustPressed("PLUS")) {
					if (curspridx== MyState.ENT_LAYER_IDX_BELOW_BG) { cur_state.below_bg_sprites.remove(depth_changeable_sprite, true); cur_state.bg1_sprites.add(depth_changeable_sprite); }
					if (curspridx== MyState.ENT_LAYER_IDX_BG1) { cur_state.bg1_sprites.remove(depth_changeable_sprite, true); cur_state.bg2_sprites.add(depth_changeable_sprite); }
					if (curspridx== MyState.ENT_LAYER_IDX_BG2) { cur_state.bg2_sprites.remove(depth_changeable_sprite, true); cur_state.fg2_sprites.add(depth_changeable_sprite); }
				} else {
					if (curspridx== MyState.ENT_LAYER_IDX_BG1) { cur_state.bg1_sprites.remove(depth_changeable_sprite, true); cur_state.below_bg_sprites.add(depth_changeable_sprite); }
					if (curspridx== MyState.ENT_LAYER_IDX_BG2) { cur_state.bg2_sprites.remove(depth_changeable_sprite, true); cur_state.bg1_sprites.add(depth_changeable_sprite); }
					if (curspridx== MyState.ENT_LAYER_IDX_FG2) { cur_state.fg2_sprites.remove(depth_changeable_sprite, true); cur_state.bg2_sprites.add(depth_changeable_sprite); }
					
				}
				//Log.trace([cur_state.below_bg_sprites.members.indexOf(depth_changeable_sprite), cur_state.bg1_sprites.members.indexOf(depth_changeable_sprite), cur_state.bg2_sprites.members.indexOf(depth_changeable_sprite), cur_state.fg2_sprites.members.indexOf(depth_changeable_sprite)]);
			} else {
			var changing_group:FlxGroup = null;
			if (mode_add_cur_group_idx == MyState.ENT_LAYER_IDX_BELOW_BG) changing_group   = cur_state.below_bg_sprites;
			if (mode_add_cur_group_idx == MyState.ENT_LAYER_IDX_BG1) changing_group   = cur_state.bg1_sprites;
			if (mode_add_cur_group_idx == MyState.ENT_LAYER_IDX_BG2) changing_group   = cur_state.bg2_sprites;
			if (mode_add_cur_group_idx == MyState.ENT_LAYER_IDX_FG2) changing_group   = cur_state.fg2_sprites;
			
			var cur_depth_idx:Int = FlxX.indexOf(changing_group, depth_changeable_sprite);
			if (cur_depth_idx != -1) {
				if (FlxG.keys.myJustPressed("PLUS")) {
					if (cur_depth_idx + 1 == changing_group.length) {
						flash(false);
					} else {
						var thing_to_swap_with:Dynamic = changing_group.members[cur_depth_idx + 1];
						changing_group.members[cur_depth_idx] = thing_to_swap_with;
						changing_group.members[cur_depth_idx + 1] = depth_changeable_sprite;
						entity_depth.text = Std.string(cur_depth_idx + 1);
					}
				} else if (FlxG.keys.myJustPressed("MINUS")) {
					if (cur_depth_idx - 1 < 0) {
						flash(false);
					} else {
						var thing_to_swap_with:Dynamic = changing_group.members[cur_depth_idx - 1];
						changing_group.members[cur_depth_idx] = thing_to_swap_with;
						changing_group.members[cur_depth_idx - 1] = depth_changeable_sprite;
						entity_depth.text = Std.string(cur_depth_idx - 1);
					}
				}
			} else {
				flash(false);
			}
			}
		}
		/* Per-pixel moving on selected entity*/
		if (depth_changeable_sprite != null && depth_changeable_sprite.last != null) {
			if (FlxG.keys.myJustPressed("UP")) {
				if (FlxG.keys.pressed.ALT) depth_changeable_sprite.iy -= 15;
				depth_changeable_sprite.iy --;
			} else if (FlxG.keys.myJustPressed("DOWN")) {
				if (FlxG.keys.pressed.ALT) depth_changeable_sprite.iy += 15;
				depth_changeable_sprite.iy ++;
			} else if (FlxG.keys.myJustPressed("LEFT")) {
				if (FlxG.keys.pressed.ALT) depth_changeable_sprite.ix -= 15;
				depth_changeable_sprite.ix --;
			} else if (FlxG.keys.myJustPressed("RIGHT")) {
				if (FlxG.keys.pressed.ALT) depth_changeable_sprite.ix += 15;
				depth_changeable_sprite.ix ++;
			}
			depth_changeable_sprite.last.x = depth_changeable_sprite.x = depth_changeable_sprite.ix;
			depth_changeable_sprite.last.y = depth_changeable_sprite.y = depth_changeable_sprite.iy;
			if (depth_changeable_sprite.linked_sprite != null) {
				depth_changeable_sprite.linked_sprite.on_child_notification(depth_changeable_sprite);
			}
		}
		
		
		
		if (!FlxG.keys.pressed.SHIFT) {
			if (SetPiece.TYPES != null) {
				//c hange set
				if (FlxG.keys.justPressed.X) {
					if (SetPiece.ITEM_INDEX > 0) SetPiece.ITEM_INDEX--;
				} else if (FlxG.keys.justPressed.C) {
					SetPiece.ITEM_INDEX++;
				}
				// change tpye
				if (FlxG.keys.justPressed.V) {
					SetPiece.ITEM_INDEX = 0;
					if (SetPiece.TYPE_INDEX > 0) SetPiece.TYPE_INDEX--;
				} else if (FlxG.keys.justPressed.B) {
					SetPiece.ITEM_INDEX = 0;
					if (SetPiece.TYPE_INDEX < SetPiece.TYPES.length-1) SetPiece.TYPE_INDEX++;
				}
				// Mirror
				if (FlxG.keys.justPressed.M) {
					SetPiece.MIRRORED = !SetPiece.MIRRORED;
				}
				
				if (FlxG.keys.anyJustPressed(["X", "V", "B", "C", "M"])) {
					
					status_text.text = "Type V/B: " + SetPiece.TYPES[SetPiece.TYPE_INDEX] + " Index X/C: " + Std.string(SetPiece.ITEM_INDEX);
					R.sound_manager.play(SNDC.menu_move);
					
					setpiece.update_properties(SetPiece.TYPE_INDEX, SetPiece.ITEM_INDEX, SetPiece.MIRRORED);
					setpiece.changevis();
					setpiece.visible = setpiece_bg.visible = true;
					setpiece.alpha = 1;
					setpiece.x = (FlxG.width - setpiece.frameWidth ) / 2 + setpiece.offset.x;
					setpiece.y = (FlxG.height - setpiece.frameHeight) / 2 + setpiece.offset.y;
					setpiece_bg.makeGraphic(setpiece.frameWidth, setpiece.frameHeight, 0xff000000);
					setpiece_bg.x = setpiece.x - setpiece.offset.x;
					setpiece_bg.y = setpiece.y - setpiece.offset.y;
				}
				setpiece.alpha -= 0.003;
				setpiece.alpha *= 0.99;
				setpiece_bg.alpha = setpiece.alpha;
				setpiece.under_sprite.alpha = setpiece.over_sprite.alpha = setpiece.alpha;
				
				
			}
		}
		/************/
		/* SHIFT + **/
		/* *        */
		if (FlxG.keys.pressed.SHIFT && FlxG.keys.myJustPressed("S")) {
			FlxG.cameras.flash(0xffffffff, 0.2);
			status_text.text = "Saved entity data to " + cur_state.MAP_NAME + ".ent";
			HF.save_map_entities(cur_state.MAP_NAME, cur_state);
			//R.gauntlet _manager.maybe_overwrite_cache_with_cur_editor_map(cur_state.MAP_NAME);
		}
		
		// Load
		if (FlxG.keys.pressed.SHIFT && FlxG.keys.myJustPressed("L")) {
			FlxG.cameras.flash(0xff000000, 0.2);
			
			status_text.text = "Loaded entity data from " + cur_state.MAP_NAME + ".ent";
			#if cpp
			// Get the latest from disk
			EMBED_TILEMAP.set_entity_hash_with_file_content(cur_state.MAP_NAME,true);
			// Reload the animations too
			R.reload_build_vars(true);
			if (FlxG.keys.pressed.CONTROL) {
				Log.trace("CTRL held so skipping reload dialogue");
			} else {
				R.dialogue_manager.first_time = true; // Set this so that the fonts don't reload and take time
				R.dialogue_manager.reload(true);
			}
			
			R.song_helper.load_script(true);
			R.inventory.reload_item_metadata(true);
			R.journal.get_viewable_journal_ids();
			R.journal.get_viewable_ent_ids();
			AnimImporter.import_anims(true);
			MenuMap.load_maprects_son(true);
			GenericNPC.load_generic_npc_data(true);
			R.TEST_STATE.player_particles.reload_anims();
			MySprite.presets = MySprite.initialize_entity_presets("entity_presets.son", true);
			//R.gauntlet_ manager.reload(true);
			R.menu_map.load_map(cur_state.MAP_NAME, cur_state);
			
			EMBED_TILEMAP.init(true, true);
			var t:TestState = cast cur_state;
			t.load_bgs();
			t.particle_system.init_maps(true);
			t.particle_system.load_system(cur_state.MAP_NAME);
			#end
			HF.load_map_entities(cur_state.MAP_NAME, cur_state);
			// When reloading re-make these so no crashes happen when trying to adjust them later
			
			setpiece.under_sprite = new FlxSprite();
			setpiece.over_sprite = new FlxSprite();
			R.sound_manager.set_wall_floor(cur_state.MAP_NAME);
		}
		
		if (FlxG.keys.pressed.SHIFT && FlxG.keys.myJustPressed("C")) {
			// copy
			copiable_entity = find_entity_with_click(false, true);
			if (copiable_entity != null) {
				flash(true);
			}
		}
		if (FlxG.keys.pressed.SHIFT && FlxG.keys.myJustPressed("V")) {
			// pasta
			if (copiable_entity != null && copiable_entity.props != null) {
				var newsprite:MySprite = create_and_add_sprite(Std.int(FlxG.mouse.x), Std.int(FlxG.mouse.y), copiable_entity.name, cur_state);
				if (newsprite != null) {
					HF.copy_props_to_mysprite(copiable_entity.props, newsprite);
				}
				
				flash(true);
			}
		}
		
		var i:Int = 0;
		/* ALT + * */
		//if (FlxG.keys.myJustPressed("Q")) {
			//add_remove_Alt = !add_remove_Alt;
			//status_text.text = add_remove_Alt ? "Numbers switch sets" : "Numbers switch entity";
		//}
		
		add_highlighter.x = extra_text.x;
		add_highlighter.y = extra_text.y + 10 + 20 * mode_add_cur_entity_idx;
		
		// Choose entity within a set
		if (!FlxG.keys.pressed.ALT && !FlxG.keys.pressed.CONTROL && !add_remove_Alt) {
			for (i in 0...MAX_ENTITY_SET_SIZE) {
				if (FlxG.keys.myJustPressed(C.NR_WORD_ARRAY[i])) {
					mode_add_cur_entity_idx = i;
					set_mode_add_extra_text();
					break;
				}
			}
		// Choose set.
		} else if (FlxG.keys.pressed.ALT || add_remove_Alt) {
			for (i in 0...MAX_ENTITY_SETS) {
				if (FlxG.keys.myJustPressed(C.NR_WORD_ARRAY[i])) {
					mode_add_cur_entity_set = i;
					set_mode_add_extra_text();
					break;
				}
			}
		/* CTRL + * */
		} else if (FlxG.keys.myPressed("CONTROL")) {
			if (FlxG.keys.myJustPressed("TWO")) {
				mode_add_cur_group_idx = 2;
				set_mode_add_extra_text();
			} else if (FlxG.keys.myJustPressed("FOUR")) {
				mode_add_cur_group_idx = 4;	
				set_mode_add_extra_text();
			} else if (FlxG.keys.myJustPressed("ZERO")) {
				mode_add_cur_group_idx = 0;
				set_mode_add_extra_text();
			} else if (FlxG.keys.myJustPressed("ONE")) {
				mode_add_cur_group_idx = 1;
				set_mode_add_extra_text();
			}
		}
		
		if (!FlxG.keys.pressed.SHIFT && !FlxG.keys.pressed.CONTROL && !FlxG.keys.pressed.ALT) {
		if (FlxG.keys.justPressed.D) {
			if (mode_add_cur_entity_set < MAX_ENTITY_SETS -1) {
				mode_add_cur_entity_set++;
			} else {
				mode_add_cur_entity_set = 0;
			}
			set_mode_add_extra_text();
		} else if (FlxG.keys.justPressed.S) {
			if (mode_add_cur_entity_idx < 9) {
				mode_add_cur_entity_idx++;
			} else {
				mode_add_cur_entity_idx = 0;
			}
			set_mode_add_extra_text();
		} else if (FlxG.keys.justPressed.A) {
			if (mode_add_cur_entity_set > 0) {
				mode_add_cur_entity_set--;
			} else {
				mode_add_cur_entity_set = MAX_ENTITY_SETS - 1;
			}
			set_mode_add_extra_text();
		} else if (FlxG.keys.justPressed.W) {
			if (mode_add_cur_entity_idx > 0) {
				mode_add_cur_entity_idx --;
			} else {
				mode_add_cur_entity_idx = 9;
			}
			set_mode_add_extra_text();	
		}
	
		}
		
	}
	
	private function set_mode_add_extra_text():Void {
		extra_text.text = " ";
		switch (mode_add_cur_group_idx) {
			case 0:
				extra_text.text += "Active: BBG ";
			case 1:
				extra_text.text += "Active: BG-1 ";
			case 2:
				extra_text.text += "Active: BG-2 ";
			case 4:
				extra_text.text += "Active: FG-2 ";
		}		
		
		extra_text.text += "Set "+Std.string(mode_add_cur_entity_set+1)+" of " + Std.string(MAX_ENTITY_SETS) ;
		extra_text.text += " Active: " + ENTITY_NAMES[mode_add_cur_entity_set][mode_add_cur_entity_idx] +"\n";
		
		var i:Int = 0;
		var si:Int = 0;
		var enticon:FlxSprite;
		for (i in 0...MAX_ENTITY_SET_SIZE) {
			enticon = cast ent_icons.members[i];
			enticon.animation.add("a", [mode_add_cur_entity_set * 10 + i], 1);
			enticon.animation.play("a");
			si = i + 1;
			if (si == 10) {
				extra_text.text += "0. " + ENTITY_NAMES[mode_add_cur_entity_set][i];
			} else {
				extra_text.text = extra_text.text + Std.string(si) + ". " + ENTITY_NAMES[mode_add_cur_entity_set][i] + "\n\n";
			}
		}
	}
	
	private var tile_saving_locked:Bool = false;
	private function save_tile_routine():Void {
		cur_state.anim_tile_engine.do_nothing = true;
		cur_state.anim_tile_engine.re_init_maps();
		update_csv_hash(cur_state.MAP_NAME, [cur_state.tm_bg, cur_state.tm_bg2, cur_state.tm_fg, cur_state.tm_fg2]);
		status_text.text = "Saved tilemap data to " + cur_state.MAP_NAME + "{BG,BG2,FG,FG2}.csv";
		HF.write_map_csv(cur_state.MAP_NAME, cur_state,true);
		HelpTilemap.save_map_props(cur_state.TILESET_NAME, cur_state);
		FlxG.cameras.flash(0xffffffff, 0.2);
		tile_saving_locked = false;
		cur_state.anim_tile_engine.do_nothing = false;
	}
	public var mode_tile_single_vis:Bool = false;
	public var moving_tileset:Bool = false;
	public var selecting_rect:Bool = false;
	public var select_rect_coords:Array<Int>;
	public var in_bg_move_mode:Bool = false;
	public var in_bg_move_idx:Int = 0;
	public var in_bg_move_set_idx:Int = 0;
	public var tile_cur_top_row:Int = 0;
	public var tile_max_rows:Int = 0;
	public var tileset_expanded:Bool = false;
	public var TILE_SMALLVIEWHEIGHT:Int = 2;
	
	private var tile_force_just_pressed:Bool = false;
	private var t_arrow_held:Int = 20;
	private var rect_is_mouse:Bool = false;
	private var eyedrop_is_mouse:Bool = false;
	
	private var tile_pre_expand_pt:Point;
	
	private var tile_is_big_select:Bool = false;
	private function update_mode_tile():Void {
		
		if (FlxG.keys.pressed.SHIFT) {
			if (FlxG.keys.justPressed.A) {
				var tm:FlxTilemapExt = cur_state.tm_bg;
				var bg:Int = 0;
				var tid:Int = 0;
				for (bg in 0...3) {
					if (bg == 1) tm = cur_state.tm_bg2;
					if (bg == 2) tm = cur_state.tm_fg;
					for (y in 0...tm.heightInTiles) {
						for (x in 0...tm.widthInTiles) {
							tid = tm.getTile(x, y);
							if (bg == 2 && (tid != 292 && tid != 293)) continue; // only flip special clouds
							if (tid != 0) {
								if (bg != 2 && HelpTilemap.invis_to_solid_map.exists(tid)) { 
									if (bg == 0) cur_invishard_coords.remove(y * tm.widthInTiles + x);
									if (bg == 1) cur_invishard_coords_bg2.remove(y * tm.widthInTiles + x);
									tm.setTile(x, y, HelpTilemap.invis_to_solid_map.get(tid), true);
									// todo anim tiles?
									//add_animated_tile(j, i, editable_tmap);
								} else if (bg != 2 && HelpTilemap.solid_to_invis_map.exists(tid)) {
									cur_invishard_coords.set(y * tm.widthInTiles + x,new FlxPoint(x*16,y*16));
									cur_invishard_coords_bg2.set(y * tm.widthInTiles + x, new FlxPoint(x * 16, y * 16));
									tm.setTile(x, y, HelpTilemap.solid_to_invis_map.get(tid), true);
								} else if (HelpTilemap.flip_map.exists(tid)) {
									tm.setTile(x, y, HelpTilemap.flip_map.get(tid), true);
								}
							}
						}
					}
				}
				return;
			}
		}
		
		
		if (FlxG.keys.pressed.O) {
			if (FlxG.keys.justPressed.O) {
				status_text.text = "Toggle OLD/draft mode (S or L + #)";
				sound_menu_confirm();
			}
			if (FlxG.keys.pressed.S) {
				if (HF.read_number("") != "") {
					#if cpp
					var m:String = cur_state.MAP_NAME;
					// SHORE_BG#0#SHOREPLACE.csv
					cur_state.anim_tile_engine.re_init_maps();
					HF.write_csv_draft(m, cur_state, Std.parseInt(HF.read_number("")), cur_state.TILESET_NAME);
					Log.trace("Saved draft #" + HF.read_number("") + " for " + m);
					status_text.text = "Saved draft #" + HF.read_number("") + " for " + m;
					sound_menu_confirm();
					#end
				}
			} else if (FlxG.keys.pressed.L) {
				if (HF.read_number("") != "") {
					#if cpp
					var p:String = C.EXT_NONCRYPTASSETS + "csv_drafts/" + cur_state.MAP_NAME + "/";
					if (FileSystem.exists(p) && FileSystem.exists(p + HF.read_number(""))) {
						HF.load_map_csv(cur_state.MAP_NAME, cur_state, null, true, Std.parseInt(HF.read_number("")));
						status_text.text = "hok";
					}
					#end
				}
			} else if (FlxG.keys.pressed.D) {
				if (FlxG.keys.justPressed.PLUS) {
					HelpTilemap.transform_to_debug(cur_state);
				}
			}
			return;
		}

		if (FlxG.keys.justPressed.R) {
			sound_menu_confirm();
			
			tile_is_big_select = !tile_is_big_select;
			big_select_ed.visible = big_select_or.visible = tile_is_big_select;
			if (tile_is_big_select) {
				status_text.text = "BIG TILE ON ON ON ON";
			} else {
				status_text.text = "BIG TILE OFF OFF OFF";
				
			}
		}
		
		if (tile_is_big_select) {
			update_big_tile_select();
			return;
		}

		
		// move tilemap_arrowed_selector with arrow_keys
		
		if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.UP || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT) {
			eyedrop_is_mouse = false;
			if (FlxX.is_on_screen(tilemap_arrowed_selector) == false) {
				tilemap_arrowed_selector.x = FlxG.camera.scroll.x + C.GAME_WIDTH / 2;
				tilemap_arrowed_selector.y = FlxG.camera.scroll.y + C.GAME_HEIGHT / 2;
				tilemap_arrowed_selector.x = Std.int(tilemap_arrowed_selector.x);
				tilemap_arrowed_selector.y = Std.int(tilemap_arrowed_selector.y);
				tilemap_arrowed_selector.x -= tilemap_arrowed_selector.x % 16;
				tilemap_arrowed_selector.y -= tilemap_arrowed_selector.y % 16;
				tilemap_arrowed_selector.x--;
				tilemap_arrowed_selector.y--;
			}
		}
		
		if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.UP || FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.W || FlxG.keys.pressed.A || FlxG.keys.pressed.S || FlxG.keys.pressed.D) {
			t_arrow_held ++;
			if (t_arrow_held > 29) {
				tile_force_just_pressed = true;
				t_arrow_held = 27	;
			} else {
				tile_force_just_pressed = false;
			}
		} else {
			tile_force_just_pressed = false;
			t_arrow_held = 0;
		}
		
		
		if (FlxG.keys.pressed.DOWN) {
			if (FlxG.keys.justPressed.DOWN || tile_force_just_pressed) {
				if (tilemap_arrowed_selector.y + 18 + 1 >= editable_tmap.height) {
				} else {
					tilemap_arrowed_selector.y += 16;
					if (tilemap_arrowed_selector.y + tilemap_arrowed_selector.height > FlxG.camera.scroll.y + FlxG.camera.height ) {
						FlxG.camera.scroll.y += 16;
					}
				}
			}
		} else if (FlxG.keys.pressed.UP) {
			if (FlxG.keys.justPressed.UP || tile_force_just_pressed) {
				if (tilemap_arrowed_selector.y - 16 + 3 < 0) {
				} else {
					tilemap_arrowed_selector.y -= 16;
					if (tilemap_arrowed_selector.y  < FlxG.camera.scroll.y ) {
						FlxG.camera.scroll.y -= 16;
					}
					
				}
			}
		}
		if (FlxG.keys.pressed.LEFT) {
			if (FlxG.keys.justPressed.LEFT || tile_force_just_pressed) {
				if (tilemap_arrowed_selector.x - 16 + 3 < 0) {
				} else {
					tilemap_arrowed_selector.x -= 16;
					if (tilemap_arrowed_selector.x  < FlxG.camera.scroll.x ) {
						FlxG.camera.scroll.x -= 16;
					}
				}
			}
		} else if (FlxG.keys.pressed.RIGHT) {
			if (FlxG.keys.justPressed.RIGHT || tile_force_just_pressed) {
				if (tilemap_arrowed_selector.x + 18 + 1 >= editable_tmap.width) {
				} else {
					tilemap_arrowed_selector.x += 16;
					if (tilemap_arrowed_selector.x + tilemap_arrowed_selector.width > FlxG.camera.scroll.x + FlxG.camera.width ) {
						FlxG.camera.scroll.x += 16;
					}
				}
			}
		}
		
		
		
		
		if (moving_tileset) {
			tileset.x = FlxG.mouse.screenX;
			tileset.y = FlxG.mouse.screenY;
			tileset_bg.x = tileset.x - 8;
			tileset_bg.y = tileset.y - 8;
			if (!FlxG.mouse.pressed) {
				moving_tileset = false;
			} 
			return;
		} else if (FlxG.keys.pressed.CONTROL && (FlxG.keys.justPressed.Q || FlxG.keys.justPressed.F || FlxG.mouse.justPressed)) {
			
			if (FlxG.mouse.x < 0 || FlxG.mouse.y < 0 || FlxG.mouse.x > cur_state.tm_bg.width || FlxG.mouse.y > cur_state.tm_bg.height) {
				R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
			} else {
				selecting_rect = true;
				if (FlxG.mouse.justPressed) {
					rect_is_mouse = true;
				} else {
					rect_is_mouse = false;
				}
				if (select_rect_coords == null) {
					select_rect_coords = [0, 0, 0, 0];
				}
				if (rect_is_mouse) {
					select_rect_coords[0] = Math.floor(FlxG.mouse.x / 16);
					select_rect_coords[1] = Math.floor(FlxG.mouse.y / 16);
				} else {
					select_rect_coords[0] = Math.floor((tilemap_arrowed_selector.x+1) / 16);
					select_rect_coords[1] = Math.floor((tilemap_arrowed_selector.y + 1) / 16);
				}
			}
		}
		
		if (selecting_rect == true) {
			if ((rect_is_mouse && !FlxG.mouse.pressed) || (rect_is_mouse == false && !FlxG.keys.pressed.F && !FlxG.keys.pressed.Q)) {
				selecting_rect = false;
				if (rect_is_mouse) {
					select_rect_coords[2] = Math.floor(FlxG.mouse.x / 16);
					select_rect_coords[3] = Math.floor(FlxG.mouse.y / 16);
				} else {
					select_rect_coords[2] = Math.floor((tilemap_arrowed_selector.x+1) / 16);
					select_rect_coords[3] = Math.floor((tilemap_arrowed_selector.y+1)/ 16);
				}
				if (select_rect_coords[2] < select_rect_coords[0] || select_rect_coords[3] < select_rect_coords[1]) {
					return;
				}
				// Add / remove tiles with rectangle
				for (i in  select_rect_coords[1]...select_rect_coords[3] + 1) {
					for (j in select_rect_coords[0]...select_rect_coords[2] + 1) {
						if (FlxG.keys.myPressed("SHIFT")) {
							remove_animated_tile(j, i, editable_tmap);
							
							var del_id:Int = editable_tmap.getTile(j,i);
							if (HF.array_contains(HelpTilemap.invishard, del_id)) {
								if (editable_tmap ==cur_state.tm_bg) {
									cur_invishard_coords.remove(i * editable_tmap.widthInTiles + j);
								} else if (editable_tmap == cur_state.tm_bg2) {
									cur_invishard_coords_bg2.remove(i * editable_tmap.widthInTiles + j);
								}
							}
							editable_tmap.setTile(j, i, 0, true);
						} else {
							
							remove_animated_tile(j, i, editable_tmap);
							editable_tmap.setTile(j, i, active_tile_id, true);
							add_animated_tile(j, i, editable_tmap);
							// Try to add invis tiles
							if (HF.array_contains(HelpTilemap.invishard, active_tile_id)) {
								if (editable_tmap ==cur_state.tm_bg) {
									cur_invishard_coords.set(i * editable_tmap.widthInTiles + j, new FlxPoint(j * 16, 16*i));
								} else if (editable_tmap == cur_state.tm_bg2) {
									cur_invishard_coords_bg2.set(i * editable_tmap.widthInTiles + j, new FlxPoint(j * 16, 16*i));
								}
								
							// else try to remove
							} else {
							
								if (editable_tmap == cur_state.tm_bg && cur_invishard_coords.exists(i * editable_tmap.widthInTiles + j)) {
									cur_invishard_coords.remove(i * editable_tmap.widthInTiles + j);
								} else if (editable_tmap == cur_state.tm_bg2 && cur_invishard_coords_bg2.exists(i * editable_tmap.widthInTiles + j)) {
									cur_invishard_coords_bg2.remove(i * editable_tmap.widthInTiles + j);
									
								}
							}
						}
					}
				}
			}
			return;
		}
		
		var xoff:Int;
		var yoff:Int;
		
		// Move tileset selector with WASD
		if (FlxG.keys.pressed.D) {
			if (FlxG.keys.justPressed.D || tile_force_just_pressed) {
				if (active_tile_id % tileset.widthInTiles == tileset.widthInTiles - 1) {
					active_tile_id -= (tileset.widthInTiles - 1);
					tileset_selected.x -= 16 * (tileset.widthInTiles - 1);
				} else {
					tileset_selected.x += 16;
					active_tile_id ++;
				}
			}
		} else if (FlxG.keys.pressed.A) {
			if (FlxG.keys.justPressed.A || tile_force_just_pressed) {
				if (active_tile_id % tileset.widthInTiles == 0) {
					tileset_selected.x += 16 * (tileset.widthInTiles - 1);
					active_tile_id += (tileset.widthInTiles - 1);
				} else {
					tileset_selected.x -= 16;
					active_tile_id--;
				}
			}
		} else if (FlxG.keys.pressed.W) {
			if (FlxG.keys.justPressed.W || tile_force_just_pressed) {
				active_tile_id -= tileset.widthInTiles;
				tileset_selected.y -= 16;
			}
		} else if (!FlxG.keys.pressed.SHIFT && FlxG.keys.pressed.S) {
			if (FlxG.keys.justPressed.S || tile_force_just_pressed) {
				active_tile_id += tileset.widthInTiles;
			}
		}
		
		if (FlxG.keys.justPressed.E) { 
			tileset_expanded = !tileset_expanded;
			if (tileset_expanded) {
				
				tile_pre_expand_pt = new Point(tileset.x, tileset.y);
				if (tile_max_rows <= 16) {
					tile_cur_top_row = 0;
				} else if (tile_max_rows - 16 < tile_cur_top_row) {
					tile_cur_top_row -= (tile_cur_top_row - (tile_max_rows - 16));
				}
				
				
				set_tileset_row(tile_cur_top_row, cur_state.tm_bg, true);
				
				tileset.x = (FlxG.width - tileset.width) / 2;
				tileset.y = 0;
				tileset_bg.x = tileset.x - 8;
				tileset_bg.y = tileset.y - 8;
			} else {
				
				tile_cur_top_row = Std.int(active_tile_id / 20);
				if (tile_cur_top_row == tile_max_rows - 1) tile_cur_top_row--;
				set_tileset_row(tile_cur_top_row, cur_state.tm_bg, false);
				
				
				if (tile_pre_expand_pt != null) {
					tileset.x = tile_pre_expand_pt.x; tileset.y = tile_pre_expand_pt.y;
				}
				
				tileset_bg.x = tileset.x - 8;
				tileset_bg.y = tileset.y - 8;
			}
		}
		

		// Check if active_tile_id is within ghte bounds. if not, shift the tileset view
		var oofaweoifowaejfwaeioj:Int = TILE_SMALLVIEWHEIGHT;
		if (tileset_expanded) {
			TILE_SMALLVIEWHEIGHT = 16;
			if (tile_max_rows < 16) TILE_SMALLVIEWHEIGHT = tile_max_rows;
		}
		if (active_tile_id >= tileset.widthInTiles * tile_cur_top_row + TILE_SMALLVIEWHEIGHT * tileset.widthInTiles) {
			if (active_tile_id >= tileset.widthInTiles * tile_max_rows) {
				tile_cur_top_row = 0;
				set_tileset_row(0, editable_tmap,tileset_expanded);
				active_tile_id = active_tile_id % 20;
			} else {
				tile_cur_top_row ++;
				set_tileset_row(tile_cur_top_row, editable_tmap, tileset_expanded);
			}
		}
		if (active_tile_id < tileset.widthInTiles*tile_cur_top_row) {
			if (active_tile_id < 0) {
				tile_cur_top_row = tile_max_rows  - TILE_SMALLVIEWHEIGHT;
				active_tile_id = (tileset.widthInTiles * (tile_max_rows -1));
				set_tileset_row(tile_cur_top_row, editable_tmap, tileset_expanded);
			} else {
				tile_cur_top_row--;
				set_tileset_row(tile_cur_top_row, editable_tmap, tileset_expanded);
			}
		}
		if (tileset_expanded) {
			TILE_SMALLVIEWHEIGHT = oofaweoifowaejfwaeioj;
		}
		if (active_tile_id < 0) active_tile_id = 0;
		// Now, active_tile_id is within the visible stuff. On every frame make sure it's in the right position
		
		tileset_selected.x = tileset.x + (16 * (active_tile_id % 20) - 1);
		tileset_selected.y = tileset.y + (16 * (Std.int(active_tile_id / 20) - tile_cur_top_row) - 1);
		
		
		// Select tile
		if (FlxG.mouse.inside(tileset) && tileset.visible) {
			xoff = Math.floor( (FlxG.mouse.screenX - tileset.x) / 16);
			yoff = Math.floor((FlxG.mouse.screenY - tileset.y) / 16);
			tileset_selector.x = tileset.x + 16 * xoff -1;
			tileset_selector.y = tileset.y + 16 * yoff -1;
			
			if (FlxG.mouse.justPressed) {
				active_tile_id = xoff + yoff * tileset.widthInTiles;
				active_tile_id += 20 * tile_cur_top_row;
				tileset_selected.x = tileset_selector.x;
				tileset_selected.y = tileset_selector.y;
			}
			// Allow moving the tileset around
		} else if (FlxG.mouse.inside(tileset_bg) && tileset_bg.visible) {
			if (FlxG.mouse.justPressed) {
				moving_tileset = true;
			}
		} else {
			// Tile the tilemap
			if (FlxG.mouse.x < 0 || FlxG.mouse.y < 0 || FlxG.mouse.x > cur_state.tm_bg.width || FlxG.mouse.y > cur_state.tm_bg.height) {
				
			} else {
			xoff = Math.floor(FlxG.mouse.x / 16);
			yoff = Math.floor(FlxG.mouse.y / 16);
						
			tilemap_selector.x = xoff * 16 - 1;
			tilemap_selector.y = yoff * 16 - 1;
			
			if (FlxG.mouse.pressed || FlxG.keys.pressed.F || FlxG.keys.pressed.Q) {
				
				if (FlxG.mouse.pressed) {
					eyedrop_is_mouse = true;
					tilemap_arrowed_selector.x = xoff * 16 - 1;
					tilemap_arrowed_selector.y = yoff * 16 - 1;
				}
				
				if (FlxG.keys.pressed.F || FlxG.keys.pressed.Q) {
					if (!eyedrop_is_mouse) {
						xoff = Math.floor((tilemap_arrowed_selector.x + 1) / 16);
						yoff = Math.floor((tilemap_arrowed_selector.y + 1) / 16);
					}
				}
				
				
				// Add or remove tiles with click
				if (FlxG.keys.pressed.B) {
					if (FlxG.mouse.justPressed) {
						if (FlxG.keys.pressed.SHIFT) {
							replace_all_of_one_type(editable_tmap);
						} else {
							flood_fill(editable_tmap);
						}
					}
				} else if (FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.Q) {
					remove_animated_tile(xoff, yoff, editable_tmap);
					var del_id:Int = editable_tmap.getTile(xoff, yoff);
					if (HF.array_contains(HelpTilemap.invishard, del_id)) {
						
						
						if (editable_tmap == cur_state.tm_bg) {
							cur_invishard_coords.remove(yoff * editable_tmap.widthInTiles + xoff);
						} else if (editable_tmap == cur_state.tm_bg2) {
							cur_invishard_coords_bg2.remove(yoff * editable_tmap.widthInTiles + xoff);
						}
					}
					editable_tmap.setTile(xoff, yoff, 0, true);
				} else {
					
					remove_animated_tile(xoff, yoff, editable_tmap);
					editable_tmap.setTile(xoff, yoff, active_tile_id, true);
					add_animated_tile(xoff, yoff, editable_tmap);
					if (HF.array_contains(HelpTilemap.invishard, active_tile_id)) {
						if (editable_tmap == cur_state.tm_bg) {
							cur_invishard_coords.set(yoff * editable_tmap.widthInTiles + xoff, new FlxPoint(xoff * 16, 16 * yoff));
						} else if (editable_tmap == cur_state.tm_bg2) {
							cur_invishard_coords_bg2.set(yoff * editable_tmap.widthInTiles + xoff, new FlxPoint(xoff * 16, 16 * yoff));
						}
					} else {
						
						// If tiling a non-invishard, remove the coordinates from cur_invihsard 
						cur_invishard_coords.remove(yoff * editable_tmap.widthInTiles + xoff);
						cur_invishard_coords_bg2.remove(yoff * editable_tmap.widthInTiles + xoff);
					}
				}
			}
			}
		}
		
		if (Math.abs(FlxG.mouse.x - last_mouse_x) > 1 || Math.abs(FlxG.mouse.y - last_mouse_y) > 1) {
			eyedrop_is_mouse = true;
		}
		
			
		// Toggle active layer only visible
		if (FlxG.keys.myJustPressed("V")) {
			if (mode_tile_single_vis) {
				mode_tile_single_vis = false;
				cur_state.tm_bg.visible = cur_state.tm_bg2.visible = cur_state.tm_fg.visible = cur_state.tm_fg2.visible = true;
			} else {
				mode_tile_single_vis = true;
				cur_state.tm_bg.visible = cur_state.tm_bg2.visible = cur_state.tm_fg.visible = cur_state.tm_fg2.visible = false;
				editable_tmap.visible = true;
			}
		}
		if (FlxG.keys.pressed.SHIFT && FlxG.keys.myJustPressed("S")) {
			if (tile_saving_locked == false) {
				#if cpp
				tile_saving_locked = true;
				Thread.create(save_tile_routine);
				#else
				save_tile_routine();
				tile_saving_locked = false;
				#end
			}
		}
		if (FlxG.keys.pressed.SHIFT && FlxG.keys.myJustPressed("L")) {
			FlxG.cameras.flash(0xff000000, 0.2);
			status_text.text = "Loaded tilemap data from " + cur_state.MAP_NAME + "{BG,BG2,FG,FG2}.csv";
			var tset:BitmapData = Assets.getBitmapData("assets/tileset/" + EMBED_TILEMAP.tileset_name_hash.get(cur_state.MAP_NAME) + "_tileset.png");
			HF.load_map_csv(cur_state.MAP_NAME,cur_state,tset);
			HelpTilemap.load_animtiles(cur_state.TILESET_NAME, cast(cur_state, MyState));
			invishard_coords_initialized = false;
		}
		
		// Eyedropper
		if (FlxG.keys.myJustPressed("SPACE")) {
			
			if (eyedrop_is_mouse) {
				xoff = Math.floor(FlxG.mouse.x / 16);
				yoff = Math.floor(FlxG.mouse.y / 16);
			} else {
				xoff = Math.floor((tilemap_arrowed_selector.x+1) / 16);
				yoff = Math.floor((tilemap_arrowed_selector.y+1) / 16);
			}
			
			active_tile_id = editable_tmap.getTile(xoff, yoff);
			
			tileset_selected.x = tileset.x + Math.floor(active_tile_id % tileset.widthInTiles) * 16;
			tileset_selected.y = tileset.y + Math.floor(active_tile_id / tileset.widthInTiles) * 16;
		}
		
		// Switch layers
		if (FlxG.keys.myJustPressed("ONE")) {
			editable_tmap = cur_state.tm_bg;
			extra_text.text = "Active: BG-1";
		} else if (FlxG.keys.myJustPressed("TWO")) {
			editable_tmap = cur_state.tm_bg2;
			extra_text.text = "Active: BG-2";
		} else if (FlxG.keys.myJustPressed("THREE")) {
			editable_tmap = cur_state.tm_fg;
			extra_text.text = "Active: FG-1";
		} else if (FlxG.keys.myJustPressed("FOUR")) {
			editable_tmap = cur_state.tm_fg2;
			extra_text.text = "Active: FG-2";
		}
		
	
		if (FlxG.keys.myJustPressed("TAB")) {
			if (most_things_hidden) {
				tileset.visible = tileset_bg.visible = tileset_selected.visible = tileset_selector.visible = false;
			} else {
				tileset.visible = tileset_bg.visible = tileset_selected.visible = tileset_selector.visible = true;
			}
		}
	}
	
	/**
	 * Note, MUST come after a call to changing the tile to the base anim tile!
	 * @param	_x
	 * @param	_y
	 * @param	tmap
	 */
	private function add_animated_tile(_x:Int, _y:Int, tmap:FlxTilemapExt):Void {
		// Don't bothe rmaking multiple tiles
		var tt:Int = tmap.getTile(_x, _y);
		// Make sure this tileset has animated tiles
		if (EMBED_TILEMAP.animtileinfo_hash.exists(cur_state.TILESET_NAME)) {
			// Make sure the tile index maps to an animated tile
			if (EMBED_TILEMAP.animtileinfo_hash.get(cur_state.TILESET_NAME).exists(Std.string(tt))) {
				var info:Array<Dynamic> = EMBED_TILEMAP.animtileinfo_hash.get(cur_state.TILESET_NAME).get(Std.string(tt));
				if (tmap == cur_state.tm_bg) {
					R.TEST_STATE.anim_tile_engine.add_tile(_y * tmap.widthInTiles + _x, info[1], info[2],MyState.LDX_BG);
				} else if (tmap == cur_state.tm_bg2) {
					R.TEST_STATE.anim_tile_engine.add_tile(_y * tmap.widthInTiles + _x, info[1], info[2],MyState.LDX_BG2);
				}
			}
		}
	}
	
	private function remove_animated_tile(_x:Int, _y:Int, tmap:FlxTilemapExt):Void {
		if (tmap == cur_state.tm_bg) {
			R.TEST_STATE.anim_tile_engine.remove_tile(_x + _y * tmap.widthInTiles,MyState.LDX_BG);
		} else {			
			R.TEST_STATE.anim_tile_engine.remove_tile(_x + _y * tmap.widthInTiles,MyState.LDX_BG2);
		}
		
	}
	
	private function update_mode_ask_to_save():Void {
		if (FlxG.keys.myJustPressed("Y")) {
			asked_to_save = true;
			HF.save_map_entities(cur_state.MAP_NAME, cur_state);
			cur_state.anim_tile_engine.re_init_maps();
			update_csv_hash(cur_state.MAP_NAME, [cur_state.tm_bg, cur_state.tm_bg2, cur_state.tm_fg, cur_state.tm_fg2]);
			HF.write_map_csv(cur_state.MAP_NAME, cur_state);
			HelpTilemap.save_map_props(cur_state.TILESET_NAME, cur_state);
			
			toggle(cur_state);
			mode = MODE_ADD_ENTITY;
			cleanup_on_mode_switch();
			// save
			FlxG.cameras.flash(0xff123123, 1);
		} else if (FlxG.keys.myJustPressed("N")) {
			asked_to_save = true;
			toggle(cur_state);
			mode = MODE_ADD_ENTITY;
			cleanup_on_mode_switch();
		}
	}
	
	private function clear_big_ent_array():Void {
		big_ent_array = [[], [], [], [], []];
	}
	private function make_everything_invisible():Void {
		selected_entity_sprite.visible = entity_depth.visible = false;
		tilemap_arrowed_selector.visible = tilemap_selector.visible = tileset.visible = tileset_bg.visible = tileset_selected.visible = tileset_selector.visible = false;
	}
	private function cleanup_on_mode_switch():Void {
		switch (mode) {
			case MODE_ADD_ENTITY:
				depth_changeable_sprite = null;
				movable_sprite = null;
				setpiece.visible = false;
				add_highlighter.visible = false;
				selected_entity_sprite.visible = entity_depth.visible = ent_icons.visible= false;
				moving_in_add = false;
				
				
				add_is_big_select = false;
				big_select_ed.visible = big_select_or.visible = false;
			case MODE_EDIT_ENTITY:
				mode_edit_ctr = 0;
				editable_ent = null;
			case MODE_TILE_EDIT:
				tilemap_arrowed_selector.visible = tilemap_selector.visible = tileset.visible = tileset_bg.visible = tileset_selected.visible = tileset_selector.visible = false;
				tile_is_big_select = false;
				big_select_ed.visible = big_select_or.visible = false;
			case MODE_CHANGE_MAPS:
				mode_change_state = 0;
			case MODE_BUFFER:
				b_init = false;
				clear_big_ent_array();
				status_text.text = " ";
		}
		extra_text.text = " ";
		current_mode_text.text = " ";
		extra_text.x = 0;
		if (FlxG.keys.myJustPressed("A")) {
			//current_mode_text.text += " ADD (0,1,2,4), shf+c/v copypaste\nSHF+S/L sav/ld ALT+clk add, ALTDclICK del, CTRLclk move";
			set_mode_add_extra_text();
			add_highlighter.visible = ent_icons.visible = true;
			extra_text.x = 16;
			mode = MODE_ADD_ENTITY;
		} else if (FlxG.keys.myJustPressed("E")) {
			current_mode_text.text += " EDIT - C+click to add child. P while hover for preset";
			mode = MODE_EDIT_ENTITY;
		} else if (FlxG.keys.myJustPressed("T")) {
			current_mode_text.text += " TILE (1/2/3/4 to switch layers)\nSHIFT+click to delete, A for toggle vis, SPACE=eyedropper";
			mode = MODE_TILE_EDIT;
			extra_text.text = "Active: BG-1";
			extra_text.y = 16;
			editable_tmap = cur_state.tm_bg;
			
			// Uses current BG's tilemap to generate the tileset palette
			set_tileset_row(0, editable_tmap, false);
			tile_cur_top_row = 0;
			center_tileset();
			tileset.visible = tileset_bg.visible = true;
			tilemap_arrowed_selector.visible = tileset_selected.visible = tileset_selector.visible = tilemap_selector.visible = true;
			
			
		} else if (FlxG.keys.myJustPressed("C")) {
			current_mode_text.text += "CHANGE MAPS N=New map, L=load existing, S=change dimensions";
			mode = MODE_CHANGE_MAPS;
		} else if (FlxG.keys.myJustPressed("B")) {
			current_mode_text.text = "Buffer Mode";
			mode = MODE_BUFFER;
		}
		
	}
	private function center_tileset():Void {
		tileset.x = (FlxG.width - tileset.width) / 2;
		tileset.y = 8;
		tileset_bg.x = tileset.x - 8;
		tileset_bg.y = tileset.y - 8;
	}
	
	private function set_tileset_row(row_index:Int, ts:FlxTilemapExt, expanded:Bool = false) {
		var tileData:Array<Int> = get_editor_array(ts);
		tile_max_rows = Math.ceil(tileData.length / 20.0);
			var tset:BitmapData = Assets.getBitmapData("assets/tileset/" + EMBED_TILEMAP.tileset_name_hash.get(cur_state.MAP_NAME) + "_tileset.png");
		if (expanded) {
			//if (tile_max_rows < 16) {
				//row_index = 0;
			//} else if (tile_max_rows - row_index <= 15) {
				//row_index -= (15 - (tile_max_rows - row_index));
			//}
		 	tileData = get_editor_array(ts, row_index, Std.int(Math.min(tile_max_rows, 16)));
			tileset.loadMapFromCSV(FlxStringUtil.arrayToCSV(tileData, 20), tset, C.TS, C.TS);
			
		} else {
			//if (tile_max_rows < TILE_SMALLVIEWHEIGHT) {
				//row_index = 0;
			//} else if (tile_max_rows - row_index <= TILE_SMALLVIEWHEIGHT - 1) {
				//row_index -= ((TILE_SMALLVIEWHEIGHT - 1) - (tile_max_rows - row_index));
			//}
			tileData = get_editor_array(ts,row_index,TILE_SMALLVIEWHEIGHT);
			tileset.loadMapFromCSV(FlxStringUtil.arrayToCSV(tileData, 20), tset, C.TS, C.TS);
		}
	
		tileset_bg.makeGraphic(cast(tileset.width,Int) + 16, cast(tileset.height,Int) + 16, 0xff123123);
		tileset.updateBuffers();
	}
	/**
	 * Get an array that will turn into a tilemap 
	 * of each tile in some tileset
	 */
	 
	private function get_editor_array(editable_tmap:FlxTilemapExt,row_index:Int=-1,nr_rows:Int=-1):Array<Int> {
		var a:Array<Int> = [];
		//var w:Float = editable_tmap.graphic.bitmap.width / C.TS;
		var w:Float = 20;
		var h:Float = editable_tmap.graphic.bitmap.height / C.TS;
		if (editable_tmap.graphic.bitmap.width / C.TS <= 10) h /= 2;
		var i:Int;
		//Log.trace([w, h]);
		if (row_index == -1) {
			for (i in 0...(Math.floor(w * h)))
			{
				a.push(i);
				
			}
		} else {
			for (i in (Math.floor(w * row_index))...Math.floor(w*(row_index+nr_rows))) {
				a.push(i);
			}
		}
		return a;
		
	}
	
	/**
	 * Updates the csv hash. Updates it with specific CSVs is csvs is not null,
	 * otherwise updates it with the current map's data.
	 * @param	mapName
	 * @param	maps
	 * @param	csvs
	 */
	public static var cache_bg_csv:String;
	public static var cache_bg2_csv:String;
	public static var cache_fg_csv:String;
	public static var cache_fg2_csv:String;
	
	private function update_csv_hash(mapName:String,maps:Array<FlxTilemapExt>,csvs:Array<String>=null):Void 
	{
		// Data already exists.
		if (csvs == null) {
			cache_bg_csv = FlxStringUtil.arrayToCSV(maps[0].getData(), maps[0].widthInTiles);
			cache_bg2_csv = FlxStringUtil.arrayToCSV(maps[1].getData(), maps[1].widthInTiles);
			cache_fg_csv = FlxStringUtil.arrayToCSV(maps[2].getData(), maps[2].widthInTiles);
			cache_fg2_csv = FlxStringUtil.arrayToCSV(maps[3].getData(), maps[3].widthInTiles);
			EMBED_TILEMAP.csv_hash.set(mode_change_next_name + "_BG",cache_bg_csv );
			EMBED_TILEMAP.csv_hash.set(mode_change_next_name + "_BG2", cache_bg2_csv);
			EMBED_TILEMAP.csv_hash.set(mode_change_next_name + "_FG", cache_fg_csv);
			EMBED_TILEMAP.csv_hash.set(mode_change_next_name + "_FG2", cache_fg2_csv);
		} else {
			EMBED_TILEMAP.csv_hash.set(mode_change_next_name + "_BG", csvs[0]);
			EMBED_TILEMAP.csv_hash.set(mode_change_next_name + "_BG2", csvs[1]);
			EMBED_TILEMAP.csv_hash.set(mode_change_next_name + "_FG", csvs[2]);
			EMBED_TILEMAP.csv_hash.set(mode_change_next_name + "_FG2", csvs[3]);
		}
	}
	private function track_mouse():Void {
		var x:Int = FlxG.mouse.screenX;
		var y:Int = FlxG.mouse.screenY;
		var w:Int = FlxG.camera.width;
		var h:Int = FlxG.camera.height;
		if (x < 12 && x != 0) {
			FlxG.camera.scroll.x -= 5;
		} else if (x > w - 12) {
			FlxG.camera.scroll.x += 5; 
		}
		
		if (y < 12) {
			FlxG.camera.scroll.y -= 5;
			
		} else if (y > h - 12) {
			FlxG.camera.scroll.y += 5;
		}
	}
	
	/**
	 * Creates a sprite at the coordinate by calling SpriteFactory.make.
	 * Also gives it a GEID that is unique to this map.
	 * Then, adds it to the current active entity group.
	 */
	private function create_and_add_sprite(mx:Int,my:Int,name:String,_state:MyState):Dynamic 
	{
		
		var p:Dynamic = SpriteFactory.make(name,mx,my,_state);
		if (p == null) return null;
		check_for_dup_geid(_state, p);
		switch (mode_add_cur_group_idx) {
			case 0:
				p.cur_layer = 0;
				_state.below_bg_sprites.add(p);
			case 1:
				p.cur_layer = 1;
				_state.bg1_sprites.add(p);
			case 2:
				p.cur_layer = 2;
				_state.bg2_sprites.add(p);
			case 4:
				p.cur_layer = 4;
				_state.fg2_sprites.add(p);
		}
		

			if (Std.is(p,Door)) {
				if (doorhelper_on) {
					door_helper_update(p);
				}
				p.door_offset_autoset();
			}

		return p;
	}
	
	override public function draw():Void 
	{
		
		if (big_ent_select_mode == 2) {
			var ms:MySprite;
			for (a in big_ent_array) {
				for (i in 0...a.length) {
					ms = a[i];
					ms.x = ms.ix + (big_select_ed.x - big_select_or.x);
					ms.y = ms.iy + (big_select_ed.y - big_select_or.y);
					var oa:Float = ms.alpha;
					ms.alpha = 0.5;
					ms.draw();
					ms.alpha = oa;
					ms.x -= (big_select_ed.x - big_select_or.x);
					ms.y -= (big_select_ed.y - big_select_or.y);
				}
			}
		}
		
		invishard_marker.scrollFactor.set(1, 1);
		
		// Draw invishard marker on the map
		if (cur_invishard_coords != null) {
			var fp:FlxPoint = null;
			var tm:FlxTilemapExt = cur_state.tm_bg;
			var tmbg2:FlxTilemapExt = cur_state.tm_bg2;
			var imap:Map<Int,Int> = HelpTilemap.invis_id_to_frame;
			for (cic in [cur_invishard_coords,cur_invishard_coords_bg2]) {
				for (key in cic.keys()) {
					fp = cic.get(key);
					var _tid:Int = -1;
					if (cic == cur_invishard_coords) {
						_tid= tm.getTileID(fp.x, fp.y);
					} else if (cic == cur_invishard_coords_bg2) {
						_tid= tmbg2.getTileID(fp.x, fp.y);
					}
					
					var animf:Dynamic = Std.string(imap.get(_tid));
					if (animf != "null") {
						invishard_marker.animation.play(animf, true);
						invishard_marker.x = fp.x;
						invishard_marker.y = fp.y;
						invishard_marker.draw();
					}
				}
			}
		}
		
		
		FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
		FlxG.camera.debugLayer.graphics.moveTo(-1 - FlxG.camera.scroll.x, -1 - FlxG.camera.scroll.y);
		FlxG.camera.debugLayer.graphics.lineTo((1+cur_state.tm_bg.width) - FlxG.camera.scroll.x, -1 - FlxG.camera.scroll.y);
		FlxG.camera.debugLayer.graphics.moveTo((1+cur_state.tm_bg.width) - FlxG.camera.scroll.x, -1 - FlxG.camera.scroll.y);
		FlxG.camera.debugLayer.graphics.lineTo((1+cur_state.tm_bg.width) - FlxG.camera.scroll.x, 1+cur_state.tm_bg.height - FlxG.camera.scroll.y);
		FlxG.camera.debugLayer.graphics.moveTo((1+cur_state.tm_bg.width) - FlxG.camera.scroll.x, 1+cur_state.tm_bg.height - FlxG.camera.scroll.y);
		FlxG.camera.debugLayer.graphics.lineTo(-1 - FlxG.camera.scroll.x, 1+cur_state.tm_bg.height - FlxG.camera.scroll.y);
		FlxG.camera.debugLayer.graphics.moveTo(-1 - FlxG.camera.scroll.x, 1+cur_state.tm_bg.height - FlxG.camera.scroll.y);
		FlxG.camera.debugLayer.graphics.lineTo(-1 - FlxG.camera.scroll.x, -1 - FlxG.camera.scroll.y);
		
		
		super.draw();
		
		
		// Tileset Invishard go OVER the tileset - draw this after everything else
		invishard_marker.scrollFactor.set(0, 0);
		for (_y in 0...tileset.heightInTiles) {
			if (!tileset.visible) break;
			for (_x in 0...tileset.widthInTiles) {
				var tid:Int = tileset.getTile(_x, _y);
				if (HF.array_contains(HelpTilemap.invishard, tid) == false) continue;
				var tm:FlxTilemapExt = cur_state.tm_bg;
				invishard_marker.x = tileset.x + _x * 16;
				invishard_marker.y = tileset.y + _y * 16;
				var animf:Dynamic = HelpTilemap.invis_id_to_frame.get(tid);
				if (animf != "null") {
					invishard_marker.animation.play(Std.string(HelpTilemap.invis_id_to_frame.get(tid)), true);
					invishard_marker.draw();
				}
			}
		}
		
	}

	private var mode_b:Int = 0;
	private var state_b:Int = 0;
	private var BUF_SAVE:Int = 1;
	private var BUF_LOAD:Int = 2;
	private var BUF_SELECT:Int = 0;
	private var BUF_CHANGE:Int = 3;
	private var b_ent_on:Bool = true;
	private var b_tile_on:Bool = true;
	private var b_active_tile_layers:Array<Bool>;
	private var b_active_ent_layers:Array<Bool>;
	private var b_slot:Int = 0;
	private var b_init:Bool = false;
	private var BUFFER_ACTIVE_SET:String = "NPC";
	private var buf_no_tile_delete :Bool = false;
	private function set_buffer_extra_text():Void {
		var s:String = "";
		s += "Set: " + BUFFER_ACTIVE_SET + " ";
		s += "Tile: ";
		b_tile_on ? s += "ON|" : s += "OFF|";
		for (b in b_active_tile_layers) {
			b ? s += "1" : s += "0";
		}
		s += " Ent: ";
		for (b in b_active_ent_layers) {
			b ? s += "1" : s += "0";
		}
		b_ent_on ? s += "ON " : s += "OFF ";
		extra_text.text = s;
	}
	private function update_mode_buffer():Void {
		
		if (FlxG.keys.myJustPressed("ESCAPE")) {
			b_init = false;
			big_tile_select_mode = 0;
			big_ent_select_mode = 0;
		}
		
		if (!b_init) {
			b_init = true;
			if (BUFFER_ACTIVE_SET == "") {
				auto_set_buffer_set();
			}
			mode_b = BUF_SELECT;
			state_b = 0;
			big_ent_select_mode = 0;
			big_ent_sub = 0;
			big_select_ed.visible = big_select_or.visible = true;
			big_select_ed.scale.set(1, 1); big_select_or.scale.set(0, 0);
			big_tile_sub = 0;
			status_text.text = "Pick submode. (L)oad (S)ave (C)hange buf set";
			set_buffer_extra_text();
			
		}
		
		
		if (mode_b == BUF_SELECT) {
			if (FlxG.keys.pressed.T) {
				if (FlxG.keys.justPressed.ONE) b_active_tile_layers[0] = !b_active_tile_layers[0];
				if (FlxG.keys.justPressed.TWO) b_active_tile_layers[1] = !b_active_tile_layers[1];
				if (FlxG.keys.justPressed.THREE) b_active_tile_layers[2] = !b_active_tile_layers[2];
				if (FlxG.keys.justPressed.FOUR) b_active_tile_layers[3] = !b_active_tile_layers[3];
				
				if (FlxG.keys.justPressed.FOUR || FlxG.keys.justPressed.THREE || FlxG.keys.justPressed.TWO || FlxG.keys.justPressed.ONE) {
					R.sound_manager.play(SNDC.menu_confirm);
					set_buffer_extra_text();
				}
			} else if (FlxG.keys.pressed.E) {
				
			}
			if (FlxG.keys.pressed.ALT && !FlxG.keys.pressed.CONTROL) {
				if (FlxG.keys.justPressed.E) {
					b_ent_on = !b_ent_on;
					R.sound_manager.play(SNDC.menu_confirm);
					set_buffer_extra_text();
				} else if (FlxG.keys.justPressed.T) {
					b_tile_on = !b_tile_on;
					set_buffer_extra_text();
					R.sound_manager.play(SNDC.menu_confirm);
				}
			}
			
			var nr_selected:Int = 0;
			if (b_ent_on) {
				update_big_entity_select();
				if (big_ent_select_mode == 2) {
					nr_selected++;
				}
			}
			if (b_tile_on) {
				update_big_tile_select();
				if (big_tile_select_mode == 2) {
					nr_selected++;
				}
			}
			
			if (FlxG.keys.justPressed.S && nr_selected > 0) {
				mode_b = BUF_SAVE;
				big_select_ed.move(big_select_or.x, big_select_or.y);
				status_text.text = "SAVE mode. Slot: "+Std.string(b_slot)+" WASD to change slot.";
			} else if (FlxG.keys.justPressed.S) {
				status_text.text = "Select something before saving! L = Load, S = Save.";
				R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
			}
			if (FlxG.keys.justPressed.L) {
				mode_b = BUF_LOAD;
				status_text.text = "LOAD mode. Slot: "+Std.string(b_slot)+" WASD to change slot.";
			}
			if (FlxG.keys.justPressed.C) {
				mode_b = BUF_CHANGE;
				status_text.text = "CHANGE mode. (C)hange manually, auto(S)et.";
			}
			if (mode_b != BUF_SELECT) {
				state_b = 0;
				R.sound_manager.play(SNDC.menu_open);
				big_ent_select_mode = 0;
			}
				
				
		} else if (mode_b == BUF_LOAD) {
			if (state_b == 0) {
				if (FlxG.keys.justPressed.BACKSPACE) {
					R.sound_manager.play(SNDC.menu_cancel);
					mode_b = BUF_SELECT;
					status_text.text = "Select submode. L to load, S to save.";
					return;
				}
			}
			if (state_b == 0) {
				if (buf_set_change()) {
					state_b = 1;
				}
			} else if (state_b == 1) {
				#if cpp
				var dir:String = C.EXT_NONCRYPTASSETS + "buf/" + BUFFER_ACTIVE_SET + "/" + Std.string(b_slot);
				var s:String = File.getContent(dir);
				var size_line:String = s.split("\n")[0];
				var w:Float = Std.parseInt(size_line.split(" ")[1]);
				var h:Float = Std.parseInt(size_line.split(" ")[2]);
				var original_x:Float = Std.parseInt(size_line.split(" ")[3]);
				var original_y:Float = Std.parseInt(size_line.split(" ")[4]);
				big_select_ed.move(FlxG.camera.scroll.x + FlxG.camera.width / 2 - w / 2, FlxG.camera.scroll.y + FlxG.camera.height / 2 - h / 2);
				big_select_ed.x = snap16(big_select_ed.x);
				big_select_ed.y = snap16(big_select_ed.y);
				big_select_or.move(big_select_ed.x, big_select_ed.y);
				big_select_ed.scale.set(w, h);
				big_select_or.scale.set(w, h);
				mousecontact = new Point(snap16(w / 2), snap16(h / 2));
				if (b_ent_on) {
					big_ent_array = HF.get_entities_from_string(s.split("##MIDDLE##")[1], cur_state);
					// Shift the arrays to correct offset with new thing
					for (a in big_ent_array) {
						for (ms in a) {
							var dx:Float = ms.ix - original_x;
							var dy:Float = ms.iy - original_y;
							ms.y = ms.ix = Std.int(big_select_ed.x + dx);
							ms.x = ms.iy = Std.int(big_select_ed.y + dy);
						}
					}
				}
				if (b_tile_on) {
					big_tile_array = buf_parse_tilepart_string(s);
					bt_add_previews(big_tile_array, cur_state.tm_bg.graphic.bitmap);
					bt_bg1.x = bt_bg2.x = bt_fg1.x = bt_fg2.x = big_select_ed.x;
					bt_bg1.y = bt_bg2.y = bt_fg1.y = bt_fg2.y = big_select_ed.y;
				}
				// Make temp tilemaps
				bt_previews_added = true;
				// Now the things should be drawing
				#end
				state_b = 2;
				big_ent_select_mode = 2;
				big_tile_select_mode = 2;
				status_text.text = "Preview shown. ENTER to confirm, BACK to cancel.";
			} else if (state_b == 2) {
				if (FlxG.keys.justPressed.ENTER) {
					// This starts us just in the right place
					R.sound_manager.play(SNDC.menu_confirm);
					buf_no_tile_delete = true;
					status_text.text = "LOAD mode. WASD to change slot. BACK to exit.";
					if (b_ent_on) {
						var i:Int = 0;
						for (a in big_ent_array) {
							for (ms in a) {
								check_for_dup_geid(cur_state, ms);
								if (i == 0) cur_state.below_bg_sprites.add(ms);
								if (i == 1) cur_state.bg1_sprites.add(ms);
								if (i == 2) cur_state.bg2_sprites.add(ms);
								if (i == 3) continue;
								if (i == 4) cur_state.fg2_sprites.add(ms);
							}
							i++;
						}
					}
					state_b = 0;
					mode_b = BUF_SELECT;
				} else if (FlxG.keys.justPressed.BACKSPACE) {
					R.sound_manager.play(SNDC.menu_cancel);
					remove_bt_previews();
					bt_previews_added = false;
					status_text.text = "LOAD mode. WASD to change slot. BACK to exit.";
					if (b_ent_on){
						big_ent_array = destroy_big_ent_array(big_ent_array);
					}
					big_ent_select_mode  = 0;
					big_ent_sub = 0;
					if (b_tile_on) {
						big_tile_array = [];
					}
					big_tile_select_mode = 0;
					big_tile_sub = 0;
					big_select_ed.scale.set(1, 1);
					big_select_or.scale.set(1, 1);
					state_b = 0;
				}
			}
			
		} else if (mode_b == BUF_SAVE) {
			if (state_b == 0) {
				
				if (FlxG.keys.justPressed.L) {
					mode_b = BUF_LOAD;
					status_text.text = "LOAD mode. Slot: " + Std.string(b_slot) + " WASD to change slot.";
					return;
				}
				if (FlxG.keys.justPressed.BACKSPACE) {
					R.sound_manager.play(SNDC.menu_cancel);
					mode_b = BUF_SELECT;
					status_text.text = "Select submode. L to load, S to save.";
					return;
				}
			}
			if (state_b == 0) {
				if (buf_set_change()) {
					state_b = 1;
				}
			} else if (state_b == 1) {
				if (FlxG.keys.justPressed.ENTER) {
					
					#if cpp
					var tilepart:String = "";
					var s:String = "";
					
					if (b_ent_on) {
						s = HF.save_map_ent_construct_string(sorrymom(big_ent_array));
					}
					if (b_tile_on) {
						tilepart = buf_get_tilepart_string(big_tile_array);
					}
					var dir:String = C.EXT_NONCRYPTASSETS + "buf/"+BUFFER_ACTIVE_SET + "/";
					if (FileSystem.exists(dir) == false) {
						FileSystem.createDirectory(dir);
					}
					var sizepart:String = "SIZE " + Std.string(Std.int(big_select_ed.scale.x)) + " " + Std.string(Std.int(big_select_ed.scale.y)) + " " + Std.string(Std.int(big_select_ed.x)) + " "+ Std.string(Std.int(big_select_ed.y));
					File.saveContent(dir + Std.string(b_slot),sizepart+"\n"+tilepart+"##MIDDLE##\n"+s);
					#end
					state_b = 0;
					
					//buf_no_tile_delete = true;
					//status_text.text = "Saved! SAVE mode: WASD to choose slot. BACKSPACE to exit.";
					R.sound_manager.play(SNDC.menu_confirm);
							
					mode_b = BUF_SELECT;
					b_init = false;
					
					big_tile_array = [];
					big_tile_select_mode = 0;
					bt_previews_added = false;
					remove_bt_previews();
					
					big_ent_select_mode = 0;
					
				} else if (FlxG.keys.justPressed.BACKSPACE) {
					status_text.text = "SAVE mode: WASD to choose slot. BACKSPACE to exit.";
					R.sound_manager.play(SNDC.menu_cancel);
					state_b = 0;
				}
			}
		} else if (mode_b == BUF_CHANGE) {
			if (state_b == 0) {
				state_b = 1;
				status_text.text = "S sets buf set to cur map. C to change";
			} else if (state_b == 1) {
				if (FlxG.keys.justPressed.C) {
					status_text.text = "Type in name of buffer set to use and press ENTER.";
					input_string = "";
					R.sound_manager.play(SNDC.menu_confirm);
					state_b = 2;
				} else if (FlxG.keys.justPressed.S) {
					auto_set_buffer_set();
					set_buffer_extra_text();
					mode_b = BUF_SELECT;
					state_b = 0;
				} else if (FlxG.keys.justPressed.BACKSPACE) {
					mode_b = BUF_SELECT;
					state_b = 0;
					R.sound_manager.play(SNDC.menu_cancel);
				}
			} else if (state_b == 2) {
				input_string = HF.read_letter(input_string);
				input_backspace();
				extra_text.text = input_string;
				if (FlxG.keys.justPressed.ENTER) {
					if (GenericNPC.generic_npc_data.get("editor_fast").exists(input_string)) {
						BUFFER_ACTIVE_SET = input_string;
						state_b = 0;
						mode_b = BUF_SELECT;
						R.sound_manager.play(SNDC.menu_confirm);
					} else {
						R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
					}
				}
			}
			if (mode_b == BUF_SELECT) {
				status_text.text = "Pick submode. Buf Set now " + BUFFER_ACTIVE_SET + ". (S/L/C)";
			}
		}
	}
	
	private function auto_set_buffer_set():Void {
		var m:String = cur_state.MAP_NAME;
		
		var g:Map < String, Dynamic > = GenericNPC.generic_npc_data.get("editor_fast");
		for (key in g.keys()) {
			var gg:Map<String,Dynamic> = g.get(key);
			var b:Bool = false;
			for (_key in gg.keys()) {
				if (gg.get(_key) == m) {
					BUFFER_ACTIVE_SET = key;
					b = true;
					break;
				}
			}
			if (b) break;
		}
		R.sound_manager.play(SNDC.menu_confirm);
	}
	private function input_backspace():Void {
		if (FlxG.keys.myJustPressed("BACKSPACE")) {
			if (input_string.length > 0) {
				input_string = input_string.substring(0, input_string.length - 1);
			}
		}
	}
	/**
	 * Takes entire buffer string
	 * @param	s
	 * @return  the tilepart_array
	 */
	private function buf_parse_tilepart_string(s:String):Array<Array<Array<Int>>> {
		var parts:Array<String> = s.split("#TILE#");
		var a:Array<Array<Array<Int>>> = [];
		for (i in 1...5) {
			a.push([]);
			if (parts[i].length < 3) {
				continue;
			} else {
				parts[i] = StringTools.trim(parts[i]);
				var string_rows:Array<String> = parts[i].split("\n");
				var j:Int = 0;
				for (string_row in string_rows) {
					a[i-1].push([]);
					string_row = StringTools.trim(string_row);
					var vals:Array<String> = string_row.split(",");
					for (val in vals) {
						a[i-1][j].push(Std.parseInt(val));
					}
					j++;
				}
			}
		}
		return a;
	}
	private function buf_get_tilepart_string(a:Array<Array<Array<Int>>>):String {
		var s:String = "#TILE#\n";
		for (tm_data in a) {
			if (tm_data == []) {
				
			} else {
				for (row in tm_data) {
					s += HF.int_array_to_string(row) + "\n";
				}
			}
			s += "#TILE#\n";
		}
		return s;
		//###TILE###bg1###TILE###
	}
	
	private function destroy_big_ent_array(_a:Array<Array<MySprite>>):Array<Array<MySprite>> {
		for (a in _a) {
			if (a == null) continue;
			for (ms in a) {
				if (ms == null) continue;
				ms.destroy();
				ms = null;
			}
			a = [];
		}
		return [[], [], [], [], []];
	}
	private function buf_set_change():Bool {
		if (FlxG.keys.justPressed.W) {
			if (b_slot > 9) b_slot -= 10;
		} else if (FlxG.keys.justPressed.S) {
			if (b_slot < 10) b_slot += 10;
		} else if (FlxG.keys.justPressed.A) {
			if (b_slot % 10 != 0) b_slot --;
		} else if (FlxG.keys.justPressed.D) {
			if (b_slot % 10 != 9) b_slot ++;
		}
		if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.A || FlxG.keys.justPressed.S || FlxG.keys.justPressed.D) {
			var e:Bool = false;
			if (FileSystem.exists(C.EXT_NONCRYPTASSETS + "buf/" + BUFFER_ACTIVE_SET + "/" + Std.string(b_slot))) e = true;
			var _s:String = e ? "x" : " ";
			if (mode_b == BUF_SAVE) {
				status_text.text = "Save slot " + Std.string(b_slot) +"["+_s+"]. ENTER confirm, BACKSPACE cancel";
			} else {
				status_text.text = "Load slot " + Std.string(b_slot)+". ENTER confirm, BACKSPACE cancel";
			}
			R.sound_manager.play(SNDC.menu_move);
		}
		if (FlxG.keys.justPressed.ENTER) {
			if (mode_b == BUF_LOAD) {
				var dir:String = C.EXT_NONCRYPTASSETS + "buf/" + BUFFER_ACTIVE_SET + "/" + Std.string(b_slot);
				if (FileSystem.exists(dir) == false) {
					R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
					status_text.text = "No such buffer for " + BUFFER_ACTIVE_SET + " #" + Std.string(b_slot) +". WASD/BACKSPACE/ENTER";
				} else {
					R.sound_manager.play(SNDC.menu_confirm);
					status_text.text = "Press ENTER to confirm loading. BACKSPACE to cancel.";
					return true;
				}
			} else {
				R.sound_manager.play(SNDC.menu_confirm);
				status_text.text = "Press ENTER to confirm saving. BACKSPACE to cancel.";
				return true;
			}
		}
		return false;
	}
	private function sorrymom(a:Array<Array<MySprite>>):Array<FlxGroup> {
		var ar:Array<FlxGroup> = [];
		for (arg in a) {
			var g:FlxGroup = new FlxGroup();
			for (ms in arg) {
				g.add(ms);
			}
			ar.push(g);
		}
		ar[3] = null;
		return ar;
	}
	
	
	private var bt_bg2:FlxTilemapExt;
	private var bt_bg1:FlxTilemapExt;
	private var bt_fg1:FlxTilemapExt;
	private var bt_fg2:FlxTilemapExt;
	private function bt_add_previews(bta:Array<Array<Array<Int>>>,tileset_bitmap:BitmapData):Void 
	{
		if (bt_bg1 == null) bt_bg1 = new FlxTilemapExt();
		if (bt_bg2 == null) bt_bg2 = new FlxTilemapExt();
		if (bt_fg1 == null) bt_fg1 = new FlxTilemapExt();
		if (bt_fg2 == null) bt_fg2 = new FlxTilemapExt();
		add(bt_bg2);
		add(bt_bg1);
		add(bt_fg2);
		add(bt_fg1);
		var bg2_Data:String = HF.double_int_array_to_tilemap_string(bta[1]);
		bt_bg2.loadMapFromCSV(bg2_Data, tileset_bitmap, 16, 16);
		bg2_Data = HF.double_int_array_to_tilemap_string(bta[0]);
		bt_bg1.loadMapFromCSV(bg2_Data, tileset_bitmap, 16, 16);
		bg2_Data = HF.double_int_array_to_tilemap_string(bta[2]);
		bt_fg1.loadMapFromCSV(bg2_Data, tileset_bitmap, 16, 16);
		bg2_Data = HF.double_int_array_to_tilemap_string(bta[3]);
		bt_fg2.loadMapFromCSV(bg2_Data, tileset_bitmap, 16, 16);
	}
	
	function remove_bt_previews():Void 
	{
		remove(bt_bg2, true);
		remove(bt_bg1, true);
		remove(bt_fg1, true);
		remove(bt_fg2, true);
	}
	
	public function in_buffer():Bool {
		return (mode == MODE_BUFFER);
	}
	public function in_add():Bool {
		return mode == MODE_ADD_ENTITY;
	}

	private function get_anim_tile_ID_if_exists(_x:Int, _y:Int, tmap:FlxTilemapExt):Int {
		var res:Int = -1;
		if (tmap == cur_state.tm_bg) {
			res = R.TEST_STATE.anim_tile_engine.get_anim_tile_ID_if_exists(_x + _y * tmap.widthInTiles,MyState.LDX_BG);
		} else if (tmap == cur_state.tm_bg2) {			
			res = R.TEST_STATE.anim_tile_engine.get_anim_tile_ID_if_exists(_x + _y * tmap.widthInTiles,MyState.LDX_BG2);
		}
		return res;
	}
	private function replace_all_of_one_type(tmap:FlxTilemapExt):Void {
		
		
		var rep:Int = get_anim_tile_ID_if_exists(Std.int(FlxG.mouse.x / 16), Std.int(FlxG.mouse.y / 16), tmap);
		if (rep == -1) {
			rep = tmap.getTileID(FlxG.mouse.x, FlxG.mouse.y);
		}
		var act:Int = active_tile_id;
		
		for (_y in 0...tmap.heightInTiles) {
			for (_x in 0...tmap.widthInTiles) {
				var do_replace:Bool = false;
				var animID:Int = -1;
				
				// check if animated tile, and get the base index of the tile.
				animID = get_anim_tile_ID_if_exists(_x, _y, tmap);
				if (animID != -1) {
				 	if (animID == rep) {
						do_replace = true;
					}
				// wasn't animated
				} else {
					var tid:Int = tmap.getTile(_x, _y);
					if (tid == rep) {
						do_replace = true;
					}
				}
				
				if (do_replace) {
					try_remove_invishard_coords(_x, _y, tmap);
					remove_animated_tile(_x, _y, tmap);
					tmap.setTile(_x, _y, act, true);
					add_animated_tile(_x, _y, tmap);
					try_add_invishard_coords(act, _x, _y, tmap);
				}
				
			}
		}
		// Replace all 'rep' with 'act'
	}
	
	private function flood_fill(tmap:FlxTilemapExt):Void {
		var queue:Array<String>;
		var replace_tile_id:Int = tmap.getTileID(FlxG.mouse.x, FlxG.mouse.y);
		if (replace_tile_id == active_tile_id) {
			return;
		}
		queue = [];
		var startstr:String = Std.string(Std.int(FlxG.mouse.x/ 16)) + "," + Std.string(Std.int(FlxG.mouse.y/ 16));
		queue.push(startstr);
		var invis:Bool = false;
		if (tmap == cur_state.tm_bg2 || tmap == cur_state.tm_bg) {
			if (HF.array_contains(HelpTilemap.invishard, active_tile_id)) {
				invis = true;
			}
		}
		
		// Will exit because queue is only extended when a replacement is made
		while (queue.length > 0) {
			var next:String = queue.pop();
			var sx:Int = Std.parseInt(next.split(",")[0]);
			var sy:Int = Std.parseInt(next.split(",")[1]);
			
			var ret:String = "";
			if (sx + 1 < tmap.widthInTiles) {
				ret = floodfill_help(sx + 1, sy, replace_tile_id,tmap,invis);
				if (ret != "") {
					queue.push(ret);
				}
			}
			if (sx - 1 >= 0) {
				ret = floodfill_help(sx - 1, sy, replace_tile_id,tmap,invis);
				if (ret != "") {
					queue.push(ret);
				}
			}
			if (sy + 1 < tmap.heightInTiles) {
				ret = floodfill_help(sx , sy+1, replace_tile_id,tmap,invis);
				if (ret != "") {
					queue.push(ret);
				}
			}
			if (sy - 1 >= 0) {
				ret = floodfill_help(sx , sy-1, replace_tile_id,tmap,invis);
				if (ret != "") {
					queue.push(ret);
				}
			}
		}
	}
	
	public function floodfill_help(tx:Int, ty:Int,replace_tile_id:Int,tmap:FlxTilemapExt,invis:Bool=false):String {
		var tile_id:Int = tmap.getTile(tx, ty);
		var ret_str:String = "";
		
		// allow the next tile to be added to the queue if it's a solid tile
		// that cn be replaced by invis
		var allow_replace_if_invis:Bool = false;
		var repl_invis_id:Int = -1;
		if (invis) {
			// If the tile to be filled can be converted to invis..
			if (HelpTilemap.solid_to_invis_map.exists(tile_id)) {
				allow_replace_if_invis = true;
				repl_invis_id = HelpTilemap.solid_to_invis_map.get(tile_id);
			}
		}
		
		if (allow_replace_if_invis || tmap.getTile(tx, ty) == replace_tile_id) {
			ret_str = Std.string(tx) + "," + Std.string(ty);
			if (allow_replace_if_invis) {
				// Should be set to its nivis version
				tmap.setTile(tx, ty, repl_invis_id, true);
			} else {
				tmap.setTile(tx, ty, active_tile_id, true);
			}
			
			if (HF.array_contains(HelpTilemap.invishard, replace_tile_id)) {
				// remove 
				remove_animated_tile(tx, ty, tmap);
				if (tmap == cur_state.tm_bg) {
					cur_invishard_coords.remove((ty) * tmap.widthInTiles + tx);
				} else if (tmap == cur_state.tm_bg2) {
					cur_invishard_coords_bg2.remove((ty) * tmap.widthInTiles + tx);
				}
			}
			
			add_animated_tile(tx, ty, tmap);
			try_add_invishard_coords(active_tile_id, tx, ty, tmap);
			//if (HF.array_contains(HelpTilemap.invishard, active_tile_id)) {
				 //add invis
				//if (tmap == cur_state.tm_bg) {
					//cur_invishard_coords.set((ty) * tmap.widthInTiles + tx, new FlxPoint((tx) * 16, 16 * ty));
				//} else if (tmap == cur_state.tm_bg2) {
					//cur_invishard_coords_bg2.set((ty) * tmap.widthInTiles + tx, new FlxPoint((tx) * 16, 16 * ty));
				//}
			//}
		}
		return ret_str;
	}
	
	private function try_remove_invishard_coords(tx:Int, ty:Int, tmap:FlxTilemapExt):Void {
		var tid:Int = tmap.getTile(tx, ty);
		if (HF.array_contains(HelpTilemap.invishard, tid)) {
			if (tmap == cur_state.tm_bg) {
				cur_invishard_coords.remove((ty) * tmap.widthInTiles + tx);
			} else if (tmap == cur_state.tm_bg2) {
				cur_invishard_coords_bg2.remove((ty) * tmap.widthInTiles + tx);
			}
		}
	}
	private function try_add_invishard_coords(active_tile_id:Int, tx:Int, ty:Int, tmap:FlxTilemapExt):Void {
		if (HF.array_contains(HelpTilemap.invishard, active_tile_id)) {
			if (tmap == cur_state.tm_bg) {
				cur_invishard_coords.set((ty) * tmap.widthInTiles + tx, new FlxPoint((tx) * 16, 16 * ty));
			} else if (tmap == cur_state.tm_bg2) {
				cur_invishard_coords_bg2.set((ty) * tmap.widthInTiles + tx, new FlxPoint((tx) * 16, 16 * ty));
			}
		}
	}
	
	
}
