package autom;
import flixel.FlxG;
import global.C;
import haxe.Log;
import help.FlxX;
import help.HF;
import openfl.display.BitmapData;
import openfl.Assets;
#if cpp
import sys.io.File;
#end

/**
 * A set of useful mappings of keys to in-memory tilesets, CSV files, .ent and .tilemeta data.
 */

 // If values of the hashes ever change they should be serialized to disk.
 // If we add key-value pairs to a hash the python script should get called to re-generate this file.
class EMBED_TILEMAP 
{
	/**
	 * TILESET -> TILESET_tileset.png 
	 * */
	public static var direct_tileset_hash:Map<String,Dynamic>;
	/** MAP -> TILESET_tileset.png*/
	public static var tileset_hash:Map<String,Dynamic>;
	/** MAP -> TILESET */
	public static var tileset_name_hash:Map<String,Dynamic>;
	/** MAP_LAYER -> MAP_LAYER.csv */
	public static var csv_hash:Map<String,Dynamic>;
	/** MAP -> MAP.ent FILE*/
	public static var entity_hash:Map<String,Dynamic>;
	/** TILESET -> TILESET.tilemeta FILES */
	public static var tilebind_hash:Map<String,Dynamic>;
	/** BG_NAME -> BG_NAME.png */
	public static var direct_bg_hash:Map<String,Dynamic>;
	/** MAP -> PARALLAX_SET_NAME */
	public static var map_prlx_hash:Map<String,Dynamic>;
	/** BG_ID -> FILENAME,w,h,sx,sy,x,y */
	public static var prlx_meta_hash:Map<String,Dynamic>;
	/** MAP -> MAP_anims.png  */
	public static var animtile_hash:Map<String,Dynamic>;
	/** MAP -> { # -> [mapanimsifrom,frames,framerate] }  */
	public static var animtileinfo_hash:Map<String,Dynamic>;
	/** MAP -> REALMAPNAME */
	public static var actualname_hash:Map<String,Dynamic>;
	/** PARALLAX_SET_NAME -> [Array<String>,Array<String>] of bg/fg parallax IDs */
	public static var parallax_set_hash:Map<String,Dynamic>;
	/** MAP -> [fps,[animation]] **/
	public static var bg_anim_hash:Map<String,Dynamic>;
	
	public static var additional_bg_offset_hash:Map<String,Dynamic>;
	
	public static var NON_MOD_MAP_NAMES:Array<String>;
	
	public static var is_first:Bool = true;
	/**
	 * 
	 * @param	load_mappings_from_disk
	 * @param	skip_reading_embedded_ent_csv Whether we shouldn't re-load the csv/entity hashes with the RUNTIME EMBEDDED data files. Set to true when switching maps in the editor
	 */
	public static function init(load_mappings_from_disk:Bool = false, skip_reading_embedded_ent_csv:Bool = false):Void {
		
		
		if (is_first) {
			tileset_hash = new Map<String,Dynamic> ();
			tileset_name_hash = new Map<String,Dynamic> ();
			csv_hash = new Map<String,Dynamic> ();
			entity_hash = new Map<String,Dynamic> ();
			direct_tileset_hash = new Map<String,Dynamic> ();
			tilebind_hash = new Map<String,Dynamic> ();
			direct_bg_hash = new Map<String,Dynamic> ();
			map_prlx_hash = new Map<String,Dynamic> ();
			prlx_meta_hash = new Map<String,Dynamic> ();
			animtile_hash = new Map<String,Dynamic> ();
			animtileinfo_hash = new Map<String,Dynamic> ();
			actualname_hash = new Map<String,Dynamic> ();
			parallax_set_hash = new Map<String,Dynamic> ();
			bg_anim_hash = new Map<String,Dynamic> ();
			additional_bg_offset_hash = new Map<String,Dynamic> ();
			NON_MOD_MAP_NAMES = [];
			is_first = false;
		}
		
		//Log.trace("Loading bg/tileset metadata from world.map...");	
		if (!skip_reading_embedded_ent_csv) {
			//Log.trace("also reloading ENT/CSV files from build assets");
		}
		var s:String = Assets.getText("assets/world.map");
		
		if (load_mappings_from_disk) {
			#if cpp
			s = File.getContent(C.EXT_MAPPINGS + "world.map");
			#end
		}
		
		var lines:Array<String> = s.split("\n");
		var words:Array<String> = [];
		var i:Int;
		var mode:Int = 0;
		for (i in 0...lines.length) {
			lines[i] = StringTools.rtrim(lines[i]);
			lines[i] = StringTools.replace(lines[i], "\t", " ");
			words = lines[i].split(" ");
			
			if (words[0].indexOf("#") != -1 || lines[i].length <= 2) continue;
			
			if (words[0] == "BG_LIST") {
				mode = 3;
				continue;
			}
			if (mode == 1) {
				if (words[0] == "ANIMTILES_LIST") {
					mode = 5;
					continue;
				} else {
					// EG DEBUG
					// Tileset listing, create tilebind and direct_tileset hashes
					direct_tileset_hash.set(words[0], Assets.getBitmapData("assets/tileset/" + words[0] + "_tileset.png"));
					tilebind_hash.set(words[0], Assets.getText("assets/tile_meta/" + words[0] + ".tilemeta"));
				}
			} else if (mode == 3) {
				// BG_LIST
				// Listing of BG assets
				// ID [0], filename [1], parallax/position [2], anim [3]
				if (words[0] == "BG_HASH") {
					mode = 4;
				} else {
					if (lines[i].indexOf("(") != -1) {
						var l_paren:Int = lines[i].indexOf("(");
						var r_paren:Int = lines[i].indexOf(")");
						
						var non_anim_data:String = lines[i].substr(l_paren + 1, r_paren - l_paren - 1);
						var anim_data:String = "";
						if (lines[i].indexOf("(", r_paren) != -1) {
							l_paren = lines[i].indexOf("(", r_paren);
							r_paren = lines[i].indexOf(")", l_paren);
							anim_data =  lines[i].substr(l_paren + 1, r_paren - l_paren - 1);
							anim_data = StringTools.replace(anim_data, " ", "");
							words[3] = anim_data.split(",")[0];
							var comma:Int = anim_data.indexOf(",");
							words[4] = anim_data.substr(comma + 1);
						} else {
							words[3] = "";
							words[4] = "";
						}
						
						non_anim_data = StringTools.replace(non_anim_data, " ", "");
						words[2] = non_anim_data;
						
						//Log.trace("--");
						//Log.trace(words[2]);
						//Log.trace(words[3]);
						//Log.trace(words[4]);
						//Log.trace("--");
					} else {
						//Log.trace("%%");
						//Log.trace(words[2]);
						//Log.trace(words[3]);
						//Log.trace(words[4]);
						//Log.trace("%%");
					}
					direct_bg_hash.set(words[1], "assets/sprites/bg/" + words[1] + ".png");
					prlx_meta_hash.set(words[0], words[1] + "," + words[2]);
					if (words.length > 4 && words[4].length > 2) {
						bg_anim_hash.set(words[0], [Std.parseInt(words[3]), HF.string_to_int_array(words[4])]);
					}
					
				}
			} else if (mode == 4) { 
				if (words[0] == "TILESET_LIST") {
					mode = 1;
				} else {
					// parsing bg_hash
					// FindMap name -> parallax set name
					// mapname -> csv file
					// mapname -> entity file
					// mapname -> tileset for map
					map_prlx_hash.set(words[0], words[1]);
					
					tileset_hash.set(words[0], Assets.getBitmapData("assets/tileset/" + words[2] + "_tileset.png"));
					//tileset_hash.set(words[0], FlxG.bitmap.add("assets/tileset/"+words[2]+"_tileset.png"));
					tileset_name_hash.set(words[0], words[2]);
					
					if (skip_reading_embedded_ent_csv == false) {
						entity_hash.set(words[0], Assets.getText("assets/map_ent/" + words[0]+ ".ent"));
					}
					
					if (words.length > 3 && words[3].indexOf(",") == -1) {
						additional_bg_offset_hash.set(words[0], "0xff"+words[3]);
					}
					
				}
			} else if (mode == 5) { // animtiles HASSSH
				if (words[0] == "PARALLAX_SETS") {
					mode = 6;
				} else {
					animtile_hash.set(words[0], Assets.getBitmapData("assets/tileset/" + words[0] + "_anims.png"));
				}
			} else if (mode == 6) {
				if (words.length < 4) {
					words.push("none");
				}
				if (words.length < 5) {
					words.push("none");
				}
				parallax_set_hash.set(words[0], [words[1].split(","), words[2].split(","),words[3].split(","),words[4].split(",")]);
			}
		}
	}
	
	public static function get_csv_from_disk(map:String):Void {
		var words:Array<String> = [map];
		if (Assets.exists("assets/csv/" + words[0] + ".bcsv")) {
			var a:Array<String> = HF.disk_bcsv_to_csv_array(Assets.getText("assets/csv/" + words[0] + ".bcsv"));
			csv_hash.set(words[0] + "_BG", a[0]);
			csv_hash.set(words[0] + "_BG2", a[1]);
			csv_hash.set(words[0] + "_FG", a[2]);
			csv_hash.set(words[0] + "_FG2", a[3]);
		} else {
			csv_hash.set(words[0] + "_BG", Assets.getText("assets/csv/" + words[0] + "_BG.csv"));
			csv_hash.set(words[0] + "_BG2", Assets.getText("assets/csv/" + words[0] + "_BG2.csv"));
			csv_hash.set(words[0] + "_FG", Assets.getText("assets/csv/" + words[0] + "_FG.csv"));
			csv_hash.set(words[0] + "_FG2", Assets.getText("assets/csv/" + words[0] + "_FG2.csv"));
		}
	}
	/**
	 * Reads an entity file content from the embedded assets, or from the decrypted dev files. 
	 * Update the entity hash entry for MAP_NAME with this data in its encrypted form.
	 */
	public static function set_entity_hash_with_file_content(map_name:String,from_noncrypt:Bool):Void {
		
		#if cpp
		var path:String = "";
		if (from_noncrypt) {
			// these do th same thing?	
			path = C.EXT_ASSETS + "map_ent/" + map_name + ".ent";
		} else {
			path = C.EXT_MAP_ENT + map_name + ".ent";
		}
		if (from_noncrypt) {
			entity_hash.set(map_name, File.getContent(path));
			Log.trace("Updated entity_hash." + map_name + " with _noncrypt form.");
		} else {
			entity_hash.set(map_name, File.getContent(path));
			Log.trace("Updated entity_hash." + map_name + " with embedded-asset form.");
		}
		#end
	}
	
	
}
	
