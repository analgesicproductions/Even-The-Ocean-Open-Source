package help;

import autom.EMBED_TILEMAP;
import entity.player.Player;
import entity.player.Train;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.util.FlxStringUtil;
import global.Registry;
import haxe.Log;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tile.FlxTile;
import openfl.Assets;
import state.MyState;
import state.TestState;

/**
 * Ideally, eventually loaded at runtime and re-written as needed for the animated bindings, solid bindings, slope bidings, etc
 * @author Melos Han-Tani
 */

class HelpTilemap 
{
	
	public static var hard_gasdark:Array<Int>;
	public static var hard_gaslight:Array<Int>;

	public static var gasdark_lo:Array<Int>;
	public static var gasdark_hi:Array<Int>;
	public static var gaslight_lo:Array<Int>;
	public static var gaslight_hi:Array<Int>;
	public static var active_gasdark:Array<Int>;
	public static var active_gas:Array<Int>;
	public static var active_gaslight:Array<Int>;
	public static var active_sand:Array<Int>;
	
	
	
	public static var diff_easy:Array<Int>;
	public static var diff_cloud:Array<Int>;
	public static var diff_normal:Array<Int>;
	
	public static var permeable:Array<Int>;
	public static var active_water:Array<Int>;
	public static var active_surface_water:Array<Int>;
	public static var top:Array<Int>;
	public static var cloud_no_drop:Array<Int>;
	public static var l_to_r:Array<Int>;
	public static var u_to_d:Array<Int>;
	public static var r_to_l:Array<Int>;
	
	public static var floor_ice:Array<Int>;
	public static var organic:Array<Int>;
	
	public static var mirror:Array < Int>;
	public static var sticky:Array < Int>;
	public static var noclimb:Array<Int>;
	public static var invishard:Array<Int>;
	public static var allow_stairs:Array<Int>;
	public static var l_floor_slopes:Array<Int>;
	public static var r_floor_slopes:Array<Int>;
	public static var fl45:Array<Int>;
	public static var fr45:Array<Int>;
	public static var l22:Array<Int>;
	public static var r22:Array<Int>;
	public static var invis_id_to_frame:Map<Int,Int>;
	public static var solid_to_invis_map:Map<Int,Int>;
	public static var invis_to_solid_map:Map<Int,Int>;
	public static var flip_map:Map<Int,Int>;
	public static function set_map_props(tileset_name:String, myState:MyState):Void {
		var maps:Array<FlxTilemapExt> = [myState.tm_bg, myState.tm_bg2, myState.tm_fg, myState.tm_fg2];
		// loop indices
		var j:Int;
		var k:Int;
		var i:Int;
		
		//Log.trace("Looking for " + tileset_name + ".tilemeta");
		var meta:String = EMBED_TILEMAP.tilebind_hash.get(tileset_name);
		var lines:Array<String> = meta.split("\n");
		var words:Array<String>;
		var solid_layers:Array<Int> = [0, 1]; // Arrays with bindings
		var s:Int = 0; // parse state
		
		Train.clear_colflag();
		solid_to_invis_map = new Map<Int,Int>();
		invis_to_solid_map = new Map<Int,Int>();
		invis_id_to_frame = new Map<Int,Int>();
		flip_map = new Map<Int,Int>();
		gasdark_hi = []; gasdark_lo = []; 
		gaslight_hi = []; gaslight_lo = [];
		hard_gasdark = [];
		hard_gaslight = [];
		active_gasdark = [];
		active_gaslight = [];
		active_gas = [];
		active_sand = [];
		sticky = [];
		permeable = [];
		active_water = [];
		active_surface_water = [];
		top  = [];
		allow_stairs = [];
		floor_ice = [];
		organic = [];
		r_floor_slopes = [];
		l_floor_slopes = [];
		cloud_no_drop = [];
		l_to_r = [];
		u_to_d = [];
		r_to_l = [];
		diff_easy = [];
		diff_normal = [];
		diff_cloud = [];
		var solid:Array<Int> = [];
		fl45 = [];
		fr45 = [];
		var cl45:Array<Int> = [];
		var cr45:Array<Int> = [];
		l22 = [];
		r22 = [];
		var active:Array<Int> = [];
		var gasdark:Array<Int> = [];
		var gaslight:Array<Int> = [];
		var water:Array<Int> = [];
		var water_surface:Array<Int> = [];
		noclimb = [];
		var curanimtilehash:Map<String,Dynamic> = null;
		invishard = [];
		mirror = [];
		var gasedge:Array<Int> = [];
		
		for (i in 0...lines.length) {
			if (lines[i].length > 0 && lines[i].charAt(0) == "#") {
				continue;
			}
			words = StringTools.rtrim(StringTools.replace(lines[i],"\t"," ")).split(" ");
			words[0] = words[0].split("\r")[0];
			// META META data like if we wnat to make a fg layer solid
			if (s == 0) {
				
				if (words[0].indexOf("START") != -1) {
					s = 1;
				} else if (words[0].indexOf("solid_invis_map") != -1) {
					for (i in 1...words.length) {
						if (words[i].indexOf(",") != -1) {
							solid_to_invis_map.set(Std.parseInt(words[i].split(",")[0]), Std.parseInt(words[i].split(",")[1]));
							invis_to_solid_map.set(Std.parseInt(words[i].split(",")[1]), Std.parseInt(words[i].split(",")[0]));
						}
					}
				} else if (words[0].indexOf("flip_map") != -1) {
					for (i in 1...words.length) {
						if (words[i].indexOf(",") != -1) {
							flip_map.set(Std.parseInt(words[i].split(",")[0]), Std.parseInt(words[i].split(",")[1]));
							flip_map.set(Std.parseInt(words[i].split(",")[1]), Std.parseInt(words[i].split(",")[0]));
						}
					}
				} else if (words[0].indexOf("ANIMS") != -1) {
					s = 2;
					if (EMBED_TILEMAP.animtileinfo_hash.exists(tileset_name) == false) {
						EMBED_TILEMAP.animtileinfo_hash.set(tileset_name, new Map<String,Dynamic> ());
					}
					curanimtilehash =  EMBED_TILEMAP.animtileinfo_hash.get(tileset_name);
				}
				if (words[0].indexOf("also")  != -1) {
					for (j in 1...words.length) {
						if (words[j] == "fg") {
							solid_layers.push(2);
						} else if (words[j] == "fg2") {
							solid_layers.push(3);
						}
					}
				}
			} else if (s == 1) {
				// Determine which tile array to push to
				switch (words[0]) {
					case "gasedge": active = gasedge;
					case "diff_easy": active = diff_easy;
					case "diff_normal": active = diff_normal;
					case "solid": active = solid;
					case "fl45": active = fl45;
					case "fr45": active = fr45;
					case "cl45": active = cl45;
					case "cr45": active = cr45;
					case "lo22l": active = l22;
					case "lo22r": active = r22;
					case "hi22r": active = r22;
					case "hi22l":  active = l22;
					case "organic": active = organic;
					case "gasdark" : active = gasdark;
					case "gaslight" : active = gaslight;
					case "water" : active = water;
					case "water_surface": active = water_surface;
					case "top": active = top;
					case "train": Train.set_collision_flags_from_tilemeta(lines[i]); continue;
					case "noclimb": active = noclimb;
					case "END": s = 0; continue;
					case "sand": active = active_sand;
					case "sticky": active = sticky;
					case "permeable": active = permeable;
					case "gasdarklo": active = gasdark_lo;
					case "gasdarkhi": active = gasdark_hi;
					case "gaslightlo": active = gaslight_lo;
					case "gaslighthi": active = gaslight_hi;
					case "floor_ice": active = floor_ice;
					case "cloud_no_drop": active = cloud_no_drop;
					case "l_to_r": active = l_to_r;
					case "u_to_d": active = u_to_d;
					case "r_to_l": active = r_to_l;
					case "mirror" : active = mirror;
					case "invishard" : active = invishard;
					case "allow_stairs" : active = allow_stairs;
					case "hard_gasdark" : active = hard_gasdark;
					case "hard_gaslight" : active = hard_gaslight;
					case "diff_cloud" : active = diff_cloud;
					default: continue;
				}
				var doneg:Bool = false;
				var dobothslope:Bool = false;
				if ("lo22l lo22r".indexOf(words[0]) != -1) {
					doneg = true;
				}
				if ("lo22l lo22r hi22r hi22l".indexOf(words[0]) != -1) {
					dobothslope = true;
				}
				

				for (j in 1...words.length) {
					var start:Int;
					var end:Int;
					if (words[j].indexOf(".") != -1) { // Multiple tiles
						start = Std.parseInt(words[j].split(".")[0]);
						end = Std.parseInt(words[j].split(".")[1]);
					} else {
						end = start = Std.parseInt(words[j]);
					}
					for (k in start...(end + 1)) {
						if (doneg) {
							active.push(-k);
						} else {
							active.push(k);
						}
						if (dobothslope) {
							if (words[0].indexOf("r") != -1) {
								fr45.push( k);
							} else {
								fl45.push(k);
							}
						}
					}
				}
			} else if (s == 2) { // animated tiles
				if (words[0] == "END") {
					continue;
				}
				// 10 DEBUG 0,1 15
				var s_tileidx:String = words[0];
				var s_tileset_anim_is_from:String = words[1];
				var s_anim_frames_raw:Array<String> = words[2].split(",");
				var s_anim_frames:Array<String> = [];
				//Log.trace(s_anim_frames_raw);
				for (framdat in s_anim_frames_raw) {
					var lp:Int = framdat.indexOf("(");
					var rp:Int = framdat.indexOf(")");
					// eg 432(4) -> 3+1 , 5-3-1
					if (lp != -1 && rp != -1) {
						var repeats:Int = Std.parseInt(framdat.substr(lp + 1, rp - lp - 1));
						for (i in 0...repeats) {
							s_anim_frames.push(framdat.split("(")[0]);
						}
					} else {
						if (s_anim_frames_raw[1] == "gas") {
							for (i in 0...32) {
								s_anim_frames.push(Std.string(Std.parseInt(s_anim_frames_raw[0]) + i));
							}
						} else {
							s_anim_frames.push(framdat);
						}
					}
				}
				//Log.trace(s_anim_frames);
				var framerate:Int = Std.parseInt(words[3]);
				var randomized:Bool = false;
				if (words.length >= 4) {
					randomized = "r" == words[4];
				}
				// Set whatever's current
				var anim_info:Array<Dynamic> = [s_tileset_anim_is_from, [], framerate,randomized];
				var anim_frames:Array<Int> = [];
				for (i in 0...s_anim_frames.length) {
					anim_frames.push(Std.parseInt(s_anim_frames[i]));
				}
				anim_info[1] = anim_frames;
				curanimtilehash.set(s_tileidx, anim_info);
				
			}
		}
		
		//var gasblend:BlendMode = BlendMode.SCREEN;
		var gasblend:BlendMode = BlendMode.ADD;
		//var gasblend:BlendMode = BlendMode.MULTIPLY;
		//var gasblend:BlendMode = BlendMode.NORMAL;
		
		// set the bindings
		Player.noclimb_tiles = noclimb;
		
		// Clear out all tiles.
		for (i in 0...maps.length) {
			for (j in 0...maps[i]._tileObjects.length) {
				maps[i].setTileProperties(j, FlxObject.NONE);
			}
		}
		for (i in 0...solid_layers.length) {
			
			// Comes before slopes b/c invishard overlays
			for (j in 0...invishard.length) {
				maps[solid_layers[i]].setTileProperties(invishard[j], FlxObject.ANY);
			}
			
			for (j in 0...mirror.length) {
				maps[solid_layers[i]].setTileProperties(mirror[j], FlxObject.ANY);
			}
			maps[solid_layers[i]].setSlopes(fl45, fr45, cl45, cr45);
			maps[solid_layers[i]].setGentleSlopeProperties(l22, r22);

			for (j in 0...solid.length) {
				maps[solid_layers[i]].setTileProperties(solid[j], FlxObject.ANY);
			}
			for (j in 0...organic.length) {
				maps[solid_layers[i]].setTileProperties(organic[j], FlxObject.NONE);
			}
			
			for (j in 0...hard_gasdark.length) {
				if (i == 0) {
					active_gasdark.push(hard_gasdark[j]);
					active_gas.push(hard_gasdark[j]);
				}
			}
			for (j in 0...hard_gaslight.length) {
				if (i == 0) {
					active_gaslight.push(hard_gaslight[j]);
					active_gas.push(hard_gaslight[j]);
				}
			}
			for (j in 0...gasdark.length) {
				if (i == 0)  {
					active_gasdark.push(gasdark[j]);
					active_gas.push(gasdark[j]);
				}
				maps[solid_layers[i]]._tileObjects[gasdark[j]].callbackFunction =  tile_callback_gasdark;
				maps[solid_layers[i]]._tileObjects[gasdark[j]].filter = Player;
				maps[solid_layers[i]]._tileObjects[gasdark[j]].blend = gasblend;
			}
			
			for (j in 0...gasdark_lo.length) {
				if (i == 0) { 
					active_gasdark.push(gasdark_lo[j]);
					active_gas.push(gasdark_lo[j]);
				}
				maps[solid_layers[i]]._tileObjects[gasdark_lo[j]].callbackFunction =  tile_callback_gasdark;
				maps[solid_layers[i]]._tileObjects[gasdark_lo[j]].filter = Player;
				maps[solid_layers[i]]._tileObjects[gasdark_lo[j]].blend = gasblend;
			}
			for (j in 0...gasdark_hi.length) {
				if (i == 0) {
					active_gasdark.push(gasdark_hi[j]);
					active_gas.push(gasdark_hi[j]);
				}
				maps[solid_layers[i]]._tileObjects[gasdark_hi[j]].callbackFunction =  tile_callback_gasdark;
				maps[solid_layers[i]]._tileObjects[gasdark_hi[j]].filter = Player;
				maps[solid_layers[i]]._tileObjects[gasdark_hi[j]].blend = gasblend;
			}
			
			for (j in 0...gaslight_lo.length) {
				if (i == 0) { 
					active_gaslight.push(gaslight_lo[j]);
					active_gas.push(gaslight_lo[j]);
				}
				maps[solid_layers[i]]._tileObjects[gaslight_lo[j]].callbackFunction =  tile_callback_gaslight;
				maps[solid_layers[i]]._tileObjects[gaslight_lo[j]].filter = Player;
				maps[solid_layers[i]]._tileObjects[gaslight_lo[j]].blend = gasblend;
			}
			for (j in 0...gaslight_hi.length) {
				if (i == 0) {
					active_gaslight.push(gaslight_hi[j]);
					active_gas.push(gaslight_hi[j]);
				}
				maps[solid_layers[i]]._tileObjects[gaslight_hi[j]].callbackFunction =  tile_callback_gaslight;
				maps[solid_layers[i]]._tileObjects[gaslight_hi[j]].filter = Player;
				maps[solid_layers[i]]._tileObjects[gaslight_hi[j]].blend = gasblend;
			}
			
			
			for (j in 0...gasedge.length) {
				maps[solid_layers[i]]._tileObjects[gasedge[j]].blend = gasblend;
			}
			for (j in 0...gaslight.length) {
				if (i == 0) {
					active_gaslight.push(gaslight[j]);
					active_gas.push(gaslight[j]);
				}
				maps[solid_layers[i]]._tileObjects[gaslight[j]].callbackFunction =  tile_callback_gaslight;
				maps[solid_layers[i]]._tileObjects[gaslight[j]].filter = Player;
				maps[solid_layers[i]]._tileObjects[gaslight[j]].blend = gasblend;
			}
			for (j in 0...water.length) {
				maps[solid_layers[i]].setTileProperties(water[j], FlxObject.NONE);
				maps[solid_layers[i]]._tileObjects[water[j]].callbackFunction =  tile_callback_water;
				maps[solid_layers[i]]._tileObjects[water[j]].filter = Player;
			}
			for (j in 0...water_surface.length) {
				maps[solid_layers[i]].setTileProperties(water_surface[j], FlxObject.NONE);
				maps[solid_layers[i]]._tileObjects[water_surface[j]].callbackFunction =  tile_callback_water_surface;
				maps[solid_layers[i]]._tileObjects[water_surface[j]].filter = Player;
			}
			for (j in 0...noclimb.length) {
				maps[solid_layers[i]].setTileProperties(noclimb[j], FlxObject.ANY);
			}
			for (j in 0...diff_easy.length) {
				maps[solid_layers[i]].setTileProperties(diff_easy[j], FlxObject.ANY);
			}
			for (j in 0...diff_normal.length) {
				maps[solid_layers[i]].setTileProperties(diff_normal[j], FlxObject.ANY);
			}
			for (j in 0...diff_cloud.length) {
				maps[solid_layers[i]].setTileProperties(diff_cloud[j], FlxObject.UP);
			}
			for (j in 0...allow_stairs.length) {
				maps[solid_layers[i]].setTileProperties(allow_stairs[j], FlxObject.ANY);
			}
			
			for (j in 0...active_sand.length) {
				maps[solid_layers[i]].setTileProperties(active_sand[j], FlxObject.NONE);
			}
			for (j in 0...sticky.length) {
				maps[solid_layers[i]].setTileProperties(sticky[j], FlxObject.NONE);
			}
			
			for (j in 0...l_to_r.length) {
				maps[solid_layers[i]].setTileProperties(l_to_r[j],FlxObject.RIGHT);
			}
			for (j in 0...r_to_l.length) {
				maps[solid_layers[i]].setTileProperties(r_to_l[j],FlxObject.LEFT);
			}
			for (j in 0...u_to_d.length) {
				maps[solid_layers[i]].setTileProperties(u_to_d[j],FlxObject.DOWN);
			}
			maps[solid_layers[i]].setClouds(top);
			maps[solid_layers[i]].setClouds(cloud_no_drop);
		}
		
		for (tm in [fl45, l22]) {
			for (j in tm) {
				l_floor_slopes.push(Std.int(Math.abs(j)));
			}
		}
		for (tm in [fr45, r22]) {
			for (j in tm) {
				r_floor_slopes.push(Std.int(Math.abs(j)));
			}
		}
		for (j in 0...water.length) {
			active_water.push(water[j]);
		}
		for (j in 0...water_surface.length) {
			active_surface_water.push(water_surface[j]);
		}
		
		for (j in 0...invishard.length) {
			invis_id_to_frame.set(invishard[j], get_invis_frame(invishard[j],maps[0]));
		}
		
		
		var ts:TestState = cast myState;
		ts.player_particles.register(active_sand);
		//Log.trace(organic);
	}
	
	public static function difficulty_tiles_on(ms:MyState, force_on:Bool = false):Void {
		//Log.trace(force_on);
		if (Registry.R.access_opts[9] || force_on) {
			for (tm in [ms.tm_bg, ms.tm_bg2]) {
				for (tt in diff_normal) {
					tm._tileObjects[tt].visible = true;
					tm.setTileProperties(tt, 0x1111);
				}
				for (tt in diff_cloud) {
					tm._tileObjects[tt].visible = true;
					tm.setTileProperties(tt, FlxObject.UP);
					if (-1 == top.indexOf(tt)) {
						top.push(tt);
					}
					//Log.trace(top);
				}
			}
		} else {
				for (tm in [ms.tm_bg, ms.tm_bg2]) {
			for (tt in diff_normal) {
					tm._tileObjects[tt].visible = false;
					tm.setTileProperties(tt, 0);
				}
			for (tt in diff_cloud) {
					tm._tileObjects[tt].visible = false;
					tm.setTileProperties(tt, 0);
					var top_idx:Int = top.indexOf(tt);
					if (top_idx != -1) {
						top.splice(top_idx, 1);
					}
					//Log.trace(top);
				}
			}
		}
		//if (Registry.R.access_opts[9] || force_on) {
			//for (tt in diff_normal) {
				//for (tm in [ms.tm_bg, ms.tm_bg2]) {
					//tm._tileObjects[tt].visible = true;
					//tm.setTileProperties(tt, 0x1111);
				//}
			//}
		//} else {
			//for (tt in diff_normal) {
				//for (tm in [ms.tm_bg, ms.tm_bg2]) {
					//tm._tileObjects[tt].visible = false;
					//tm.setTileProperties(tt, 0);
				//}
			//}
		//}
	}
	
	private static function get_invis_frame(_tid:Int, tm:FlxTilemapExt):Int {
		var found:Bool = false;
		var j:Int = 0;
		for (i in [tm.gentleSlopeFloorLeft, tm.gentleSlopeFloorRight, tm._slopeNorthwest, tm._slopeNortheast, tm._slopeSouthwest, tm._slopeSoutheast]) {
			if (i == tm.gentleSlopeFloorLeft) {
				for (k in 0...tm.gentleSlopeFloorLeft.length) {
					if (tm.gentleSlopeFloorLeft[k] > 0) { // high
						if (Math.abs(tm.gentleSlopeFloorLeft[k]) == _tid) {
							return 7;
						}
					} else {
						if (Math.abs(tm.gentleSlopeFloorLeft[k]) == _tid) { // lo left
							return 0;
						}
					}
					if (found) break;
				}
			} else if (i == tm.gentleSlopeFloorRight) {
				for (k in 0...tm.gentleSlopeFloorRight.length) {
					if (tm.gentleSlopeFloorRight[k] > 0) { // high
						if (Math.abs(tm.gentleSlopeFloorRight[k]) == _tid) {
							return 8;
						}
					} else {
						if (Math.abs(tm.gentleSlopeFloorRight[k]) == _tid) { // lo left
							return 1;
						}
					}
					if (found) break;
				}
			} else {
				if (HF.array_contains(i, _tid)) {
					return j;
				}
			}
			if (found) {
				break;
			}
			j++;
		}
		
		if (HF.array_contains(HelpTilemap.cloud_no_drop, _tid)) {
			return 23;
		}
		if (HF.array_contains(HelpTilemap.l_to_r, _tid)) {
			return 24;
		}
		if (HF.array_contains(HelpTilemap.u_to_d, _tid)) {
			return 25;
		}
		if (HF.array_contains(HelpTilemap.r_to_l, _tid)) {
			return 26;
		}
		if (HF.array_contains(HelpTilemap.organic, _tid)) {
			return 18;
		}
		if (HF.array_contains(HelpTilemap.mirror, _tid)) {
			return 19;
		}
		
		if (HF.array_contains(HelpTilemap.top, _tid)) {
			return 10;
		}
		if (HF.array_contains(HelpTilemap.noclimb, _tid)) {
			return 11;
		}
		if (HF.array_contains(HelpTilemap.active_surface_water, _tid)) {
			return 12;
		}
		if (HF.array_contains(HelpTilemap.active_water, _tid)) {
			return 13;
		}
		if (HF.array_contains(HelpTilemap.allow_stairs, _tid)) {
			return 14;
		}
		if (HF.array_contains(HelpTilemap.active_sand, _tid)) {
			return 15;
		}
		if (HF.array_contains(HelpTilemap.sticky, _tid)) {
			return 16;
		}
		
		if (HF.array_contains(HelpTilemap.permeable, _tid)) {
			return 17;
		}
		if (HF.array_contains(HelpTilemap.hard_gasdark, _tid)) {
			return 20;
		}
		if (HF.array_contains(HelpTilemap.floor_ice, _tid)) {
			return 21;
		}
		if (HF.array_contains(HelpTilemap.hard_gaslight, _tid)) {
			return 22;
		}
		
		return 6;
	}
	
	public static function tile_callback_water_surface(tile:FlxObject, player:FlxObject):Void {
		var p:Player = cast player;
		var ft:FlxTile = cast tile;
		var buoy_y:Int = 8 + Std.int(ft.mapIndex / ft.tilemap.widthInTiles) * 16;
		p.set_float_surface_y(buoy_y);
	}
	
	public static function tile_callback_water(tile:FlxObject, player:FlxObject):Void {
		
		var ft:FlxTile = cast tile;
		tile.x = Std.int(ft.mapIndex % ft.tilemap.widthInTiles) * 16;
		tile.y = Std.int(ft.mapIndex / ft.tilemap.widthInTiles) * 16;
		if (tile.overlaps(player)) {		
			var p:Player = cast player;
			p.signal_enter_float(tile.y);
			
			if (HF.array_contains(active_gasdark, ft.index)) {
				p.RESET_status_gassed--;
				p.in_gas_tile = true;
			} else if (HF.array_contains(active_gaslight, ft.index)) {
				p.RESET_status_gassed++;
				p.in_gas_tile = true;				
			}
		}
	}
	
	public static function tile_callback_gasdark(tile:FlxObject, player:FlxObject):Void {
		
		var ft:FlxTile = cast tile;
		tile.x = Std.int(ft.mapIndex % ft.tilemap.widthInTiles) * 16;
		tile.y = Std.int(ft.mapIndex / ft.tilemap.widthInTiles) * 16;
		if (tile.overlaps(player)) {
			var p:Player = cast player;
			if (tile.y - p.y >= p.height - 1) return;
			p.RESET_status_gassed--;
			p.in_gas_tile = true;
			if (HF.array_contains(gasdark_lo, ft.index)) {
				p.in_lo_gas_tile = true;
			} else if (HF.array_contains(gasdark_hi, ft.index)) {
				p.in_hi_gas_tile = true;
			}
		}
	}
	
	public static function tile_callback_gaslight(tile:FlxObject, player:FlxObject):Void {
		
		var ft:FlxTile = cast tile;
		tile.x = Std.int(ft.mapIndex % ft.tilemap.widthInTiles) * 16;
		tile.y = Std.int(ft.mapIndex / ft.tilemap.widthInTiles) * 16;
		if (tile.overlaps(player)) {
			var p:Player = cast player;
			p.RESET_status_gassed++;
			p.in_gas_tile = true;
			
			if (HF.array_contains(gaslight_lo, ft.index)) {
				p.in_lo_gas_tile = true;
			} else if (HF.array_contains(gaslight_hi, ft.index)) {
				p.in_hi_gas_tile = true;
			}
		}
	}
	/**
	 * This doesn't do anything yet
	 */
	public static function save_map_props(tileset_name:String,myState:MyState):Void {
		
	}
	
	/**
	 * Using the current hashes with animated tilesheet bitmap data,
	 * and animted tile info (set in set_map_props),
	 * creates the animated tile objects and adds them. yay
	 * @param	tileset_name
	 * @param	myState
	 */
	public static function load_animtiles(tileset_name:String, myState:MyState):Void {
		myState.anim_tile_engine.reset();
		var animtile_info:Map<String,Dynamic> = EMBED_TILEMAP.animtileinfo_hash.get(tileset_name);
		if (animtile_info == null) {
			Log.trace("No animated tiles in tileset " + tileset_name + ", not adding animated tiles.");
			return;
		}
		// Clear animated tiles
		//myState.animtiles_bg.clear();
		myState.anim_tile_engine.load_maps(myState.tm_bg,myState.tm_bg2);
		
		var layers:Array<FlxTilemapExt> = [myState.tm_bg,myState.tm_bg2];
		var anim_tile:FlxSprite;
		var info:Array<Dynamic>;
		//var cur_tilegroup:FlxGroup = null;
		
		var active_layer:Int = 0;
		for (i in 0...layers.length) {
			if (layers[i] == myState.tm_bg) {
				active_layer = MyState.LDX_BG;
			} else if (layers[i] == myState.tm_bg2) {
				active_layer = MyState.LDX_BG2;
			}
			//if (i == 0) {
				//cur_tilegroup = myState.animtiles_bg;
			//}
			for (y in 0...layers[i].heightInTiles) {
				for (x in 0...layers[i].widthInTiles) {
					var s:String = Std.string(layers[i].getTile(x, y));
					if (animtile_info.exists(s)) {
						info = animtile_info.get(s);
						// 0		1		2
						// tileset, frames, framerate
					
						myState.anim_tile_engine.add_tile(y * layers[i].widthInTiles + x, info[1], info[2],active_layer,info[3]);
						//anim_tile = new FlxSprite(x * 16, y * 16);
						//anim_tile.myLoadGraphic(EMBED_TILEMAP.animtile_hash.get(info[0]), true, false, 16, 16);
						//anim_tile.animation.add("a", info[1], info[2], true);
						//anim_tile.animation.play("a");
						//layers[i].setTile(x, y, 0, true);
						//cur_tilegroup.add(anim_tile);
					}
				}
			}
		}
	}
	
	
	/**
	 * Expects every map  in BG, BG2, FG, FG2 order
	 * @param	name
	 * @param	maps
	 */
	public static var current_tileset_bitmap:BitmapData;
	public static function set_map_csv(name:String, maps:Array<FlxTilemapExt>, w:Int = 16):Void {
		if (EMBED_TILEMAP.tileset_hash.exists(name) == false) {
			name = "DEBUG3";
			Log.trace("Warning! No tileset ID " + name + " exists!");
		}
		
		if (EMBED_TILEMAP.csv_hash.exists(name + "_BG") == false) {
			EMBED_TILEMAP.get_csv_from_disk(name);
		}
		
		// this is 0,0 sometimes which is why things crash. not sure why, but getting the bitmapdata from assets.getbitmap data again fixes things *shrug*
		//var tset:BitmapData = EMBED_TILEMAP.tileset_hash.get(name);
		//Log.trace([tset.width, tset.height]);
		
		var tset:BitmapData = Assets.getBitmapData("assets/tileset/" + EMBED_TILEMAP.tileset_name_hash.get(name) + "_tileset.png");
		
		
		maps[0].loadMapFromCSV(EMBED_TILEMAP.csv_hash.get(name+"_BG"), FlxTileFrames.fromBitmapAddSpacesAndBorders(tset, new FlxPoint(16, 16), new FlxPoint(1, 1), new FlxPoint(1, 1)),w, 16,null,0,1,100000);
		maps[1].loadMapFromCSV(EMBED_TILEMAP.csv_hash.get(name+"_BG2"), FlxTileFrames.fromBitmapAddSpacesAndBorders(tset, new FlxPoint(16, 16), new FlxPoint(1, 1), new FlxPoint(1, 1)),w, 16,null,0,1,100000);
		//maps[0].loadMapFromCSV(EMBED_TILEMAP.csv_hash.get(name+"_BG"), tset,w, 16,null,0,1,100000);
		//maps[1].loadMapFromCSV(EMBED_TILEMAP.csv_hash.get(name+"_BG2"), tset, w, 16,null,0,1,100000);
		maps[2].loadMapFromCSV(EMBED_TILEMAP.csv_hash.get(name+"_FG"), tset, w, 16,null,0,1,100000);
		maps[3].loadMapFromCSV(EMBED_TILEMAP.csv_hash.get(name + "_FG2"), tset, w, 16,null,0,1,100000);
		current_tileset_bitmap = tset;
		//current_tileset_bitmap = EMBED_TILEMAP.tileset_hash.get(name);
		//Log.trace(maps[2]._tileObjects[25].blend);
		//maps[2]._tileObjects[25].blend = BlendMode.SCREEN;
		//Log.trace(maps[2]._tileObjects[25].blend);
		//Log.trace(maps[1].widthInTiles);
		//Log.trace(maps[1].heightInTiles);
		//Log.trace(maps[2].widthInTiles);
		//Log.trace(maps[2].heightInTiles);
		//Log.trace(maps[3].widthInTiles);
		//Log.trace(maps[3].heightInTiles);
	}
	
	public static function transform_to_debug(cur_state:MyState):Void {
		var a:Array<FlxTilemapExt> = [cur_state.tm_bg, cur_state.tm_bg2, cur_state.tm_fg, cur_state.tm_fg2];
		
		var tm:FlxTilemapExt = null;
		var mirrored:Bool = false;
		var invis:Bool = false;
		var tt:Int = -1;
		cur_state.anim_tile_engine.reset();
		for (j in a) {
			tm = cast j;
			for (_y in 0...tm.heightInTiles) {
				for (_x in 0...tm.widthInTiles) {
					tt = tm.getTile(_x, _y);
					if (tt == 0) continue;
					mirrored = HF.array_contains(mirror, tt);
					invis = HF.array_contains(invishard, tt);
					
					if (HF.array_contains(tm._slopeSouthwest, tt)) {
						if (mirrored) {
							tm.setTile(_x, _y, 124);
						} else if (invis) {
							tm.setTile(_x, _y, 49);
						} else {
							tm.setTile(_x, _y, 2);
						}
						continue;
					}
					if (HF.array_contains(tm._slopeSoutheast, tt)) {
						if (mirrored) {
							tm.setTile(_x, _y, 125);
						} else if (invis) {
							tm.setTile(_x, _y, 65);
						} else {
							tm.setTile(_x, _y, 7);
						}
						continue;
					}
					if (HF.array_contains(tm._slopeNorthwest, tt)) {
						if (mirrored) {
							tm.setTile(_x, _y, 126);
						} else { // hi is positive
							if (HF.array_contains(tm.gentleSlopeFloorLeft, tt * -1)) { // lo
								if (invis) {
									tm.setTile(_x, _y, 47);
								} else {
									tm.setTile(_x, _y, 13);
								}
							} else if (HF.array_contains(tm.gentleSlopeFloorLeft, tt)) { // hi
								if (invis) {
									tm.setTile(_x, _y, 66);
								} else {
									tm.setTile(_x, _y, 14);
								}
							} else { // 45 deg
								if (invis) {
									tm.setTile(_x, _y, 45);
								} else {
									tm.setTile(_x, _y, 12);
								}
							}
						}
						continue;
					}
					if (HF.array_contains(tm._slopeNortheast, tt)) {
						if (mirrored) {
							tm.setTile(_x, _y, 127);
						} else { // hi is positive
							if (HF.array_contains(tm.gentleSlopeFloorRight, tt * -1)) { // lo
								if (invis) {
									tm.setTile(_x, _y, 48);
								} else {
									tm.setTile(_x, _y, 16);
								}
							} else if (HF.array_contains(tm.gentleSlopeFloorRight, tt)) { // hi
								if (invis) {
									tm.setTile(_x, _y, 67);
								} else {
									tm.setTile(_x, _y, 15);
								}
							} else { // 45 deg
								if (invis) {
									tm.setTile(_x, _y, 46);
								} else {
									tm.setTile(_x, _y, 17);
								}
							}
						}
						continue;
					}
					
					if (HF.array_contains(permeable, tt)) {
						tm.setTile(_x, _y, 4);
						continue;
					}
					if (HF.array_contains(floor_ice, tt)) {
						tm.setTile(_x, _y, 35);
						continue;
					}
					if (HF.array_contains(cloud_no_drop, tt)) {
						tm.setTile(_x, _y, 128);
						continue;
					}
					if (HF.array_contains(mirror, tt)) {
						tm.setTile(_x, _y, 31);
						continue;
					}
					if (HF.array_contains(organic, tt)) {
						tm.setTile(_x, _y, 36);
						continue;
					}
					if (HF.array_contains(top, tt)) {
						tm.setTile(_x, _y, 8);
						continue;
					}
					if (HF.array_contains(active_surface_water, tt)) {
						tm.setTile(_x, _y, 30);
						continue;
					}
					if (HF.array_contains(active_water, tt)) {
						tm.setTile(_x, _y, 40);
						continue;
					}
					if (HF.array_contains(noclimb, tt)) {
						tm.setTile(_x, _y, 25);
						continue;
					}
					if (Train.tile_id_to_collision_flag_map.exists(tt)) {
						var num:Int = Train.tile_id_to_collision_flag_map.get(tt);
						if (num == FlxObject.DOWN) {
							tm.setTile(_x, _y, 122);
						} else if (num == FlxObject.LEFT) {
							tm.setTile(_x, _y, 123);
						}else if (num == FlxObject.UP) {
							tm.setTile(_x, _y, 120);
						}else if (num == FlxObject.RIGHT) {
							tm.setTile(_x, _y, 121);
						}
						continue;
					}
					
					if (HF.array_contains(active_gasdark,tt)) {
						if (HF.array_contains(gasdark_lo,tt)) {
							tm.setTile(_x, _y, 23);
						} else if (HF.array_contains(gasdark_hi,tt)) {
							tm.setTile(_x, _y, 43);
						} else {
							tm.setTile(_x, _y, 33);
						}
						continue;
					}
					if (HF.array_contains(active_gaslight,tt)) {
						if (HF.array_contains(gaslight_lo,tt)) {
							tm.setTile(_x, _y, 24);
						} else if (HF.array_contains(gaslight_hi,tt)) {
							tm.setTile(_x, _y, 44);
						} else {
							tm.setTile(_x, _y, 34);
						}
						continue;
					}
					
					if (invis) {
						tm.setTile(_x, _y, 37);
						continue;
					} else {
						if (tm.getTileCollisionFlags(16 * _x, 16 * _y) == 0) {
							tm.setTile(_x, _y, 3);
						} else {
							tm.setTile(_x, _y, 11);
						}
						continue;
					}
					Log.trace(tt);
				}
			}
			tm.loadMapFromCSV(FlxStringUtil.arrayToCSV(tm.getData(), tm.widthInTiles), EMBED_TILEMAP.direct_tileset_hash.get("DEBUG3"), 16, 16);
			
		}
		set_map_props("DEBUG3", cur_state);
	}
	
	
}