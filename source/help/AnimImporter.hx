package help;
import entity.npc.GenericNPC;
import flash.display.BitmapData;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxBitmapDataUtil;
import global.C;
import haxe.Log;
import openfl.Assets;
import flixel.FlxSprite;
#if cpp
import sys.io.File;
#end
import openfl.display.BlendMode;

/**
 * Imports anims from assets/misc/animations.txt 
 * Helper functions for adding animations and hot-loading spriteshets
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class AnimImporter 
{

	private static var anims:Map<String,Dynamic>;
	
	public static function import_anims(from_dev:Bool=false):Void {
		anims = new Map<String,Dynamic>();
		var s:String = "";
		#if cpp
		if (from_dev) {
			//Log.trace("Importing anims from dev assets misc/animations.txt");
			s = File.getContent(C.EXT_ASSETS +"misc/animations.txt");
		} else {
			//Log.trace("Importing anims from build assets misc/animations.txt");
			s = Assets.getText("assets/misc/animations.txt");
		}
		#end
		#if flash
		s = Assets.getText("assets/misc/animations.txt");
		#end
		
		var lines:Array<String> = s.split("\n");
		var words:Array<String> = [];
		
		var mode:Int = 0;
		var MODE_OUT:Int = 0;
		var MODE_NAME:Int = 1;
		var MODE_BEHAVIOR:Int = 2;
		
		var cur_entity_name:String = "";
		var cur_behavior_name:String = "";
		
		for (line in lines) {
			words = line.split(" ");
			words[words.length - 1] = words[words.length - 1].split("\r")[0];
			if (mode == MODE_OUT) {
				if (words[0] == "{") {
					cur_entity_name = words[1];
					mode = MODE_NAME;
					anims.set(cur_entity_name, new Map<String,Dynamic>());
				}
			} else if (mode == MODE_NAME) {
				if (words[0] == "{") {
					cur_behavior_name = words[1];
					mode = MODE_BEHAVIOR;
					anims.get(cur_entity_name).set(cur_behavior_name, new Map<String,Dynamic>());
				} else if (words[0].charAt(0) == "}") {
					mode = MODE_OUT;
				}
			} else if (mode == MODE_BEHAVIOR) {
				if (words[0].charAt(0) == "}") {
					mode = MODE_NAME;
				} else  {
					var name:String = words[0];
					var frame_rate:Int = Std.parseInt(words[1]);
					var frames:Array<Int> = [];
					for (idx in words[2].split(",")) {
						frames.push(Std.parseInt(idx));
					}
					
					var frameinfo:Map<String,Dynamic> = new Map<String,Dynamic> ();
					if (words.length > 3) {
						if (words[3] == "false") {
							frameinfo.set("looped", false);
						}
					}
					
					frameinfo.set("fr", frame_rate);
					frameinfo.set("frames", frames);
					anims.get(cur_entity_name).get(cur_behavior_name).set(name, frameinfo);
				}
			}
		}
	}
	
	public static function get_Animations_array(class_name:String, behavior_name:String,exclude:String=""):Array<String> {
		var hash:Map<String,Dynamic>  = anims.get(class_name).get(behavior_name);
		if (hash == null) {
			Log.trace("No anim set \"" + behavior_name + "\" for " + class_name);
			return [];
		}
		var a:Array<String> = [];
		for (key in hash.keys()) {
			if (exclude != "") {
				if (key.indexOf(exclude) == 0) {
					continue;
				}
			}
			a.push(key);
		}
		return a;
	}
	public static function addAnimations(entity:FlxSprite, class_name:String, behavior_name:String):Void {
		var hash:Map<String,Dynamic>  = anims.get(class_name).get(behavior_name);
		if (hash == null) {
			Log.trace("No anim set \"" + behavior_name + "\" for " + class_name);
			return;
		}
		for (key in hash.keys()) {
			var looped:Bool = true;
			if (hash.get(key).exists("looped")) {
				looped = false;
			}
			if (key == "blend") {
				var b:Int = hash.get(key).get("frames")[0];
				if (b == 1) {
					entity.blend = BlendMode.ADD;
				} else if (b == 2) {
					entity.blend = BlendMode.MULTIPLY;
				} else if (b == 3) {
					entity.blend = BlendMode.SCREEN;
				} else if (b == 0) {
					entity.blend = BlendMode.NORMAL;
				}
				//Log.trace("Blend set: " + Std.string(entity.blend));
			} else {
				entity.animation.add(key, hash.get(key).get("frames"), hash.get(key).get("fr"), looped);
			}
		}
	}
	
	public static function get_animdata(clas_name:String, behavior:String, anim:String):Map<String,Dynamic> {
		return anims.get(clas_name).get(behavior).get(anim);
	}
	
	/**
	 * This function lets you load both a data-defined spritesheet (based on "class_name") and animation set (based on "id").
	 * @param	entity 
	 * @param	frame_width
	 * @param	frame_height
	 * @param	path relative to "assets/"
	 * @param	reference Optional, a reference to a bitmapdata object
	 */
	public static var last_loaded_bitmap:BitmapData;
	public static function loadGraphic_from_data_with_id(ent:FlxSprite, frame_width:Int, frame_height:Int,class_name:String, id:Dynamic="0",has_spaces:Bool=false):Void {
	#if cpp
	//if (ProjectClass.DEV_MODE_ON) 
		// bad for memoery.../?
		//ent.myLoadGraphic(File.getContent(C.EXT_ASSETS+path), true, false, frame_width, frame_height, );
		//return;
	//} 
	#end
		if (ent == null) {
			Log.trace("You passed a null entity: " + class_name + ":" + id);
			return;
		}
		
		
		
		
		var str_id:String = "default";
		if (id != "0") str_id = Std.string(id);
		var _data:Map<String,Dynamic> = GenericNPC.entity_spritesheet_data.get(class_name);
		if (_data == null) {
			Log.trace("Entity entry \""+class_name+"\"" +" not found.");
			return;
		}
		_data = _data.get(str_id);
		if (_data == null) {
			Log.trace("Entity entry \"" + class_name + "\"" + "'s type " + str_id + " not found.");
			return;
		}
		
		if (_data.get("w") != null && _data.get("h") != null) {
			frame_width = _data.get("w");
			frame_height = _data.get("h");
		}
		last_loaded_bitmap = Assets.getBitmapData("assets/" + _data.get("path"));
		
		
			
		
		if (last_loaded_bitmap == null) {
			Log.trace("No bitmap " + "assets/" + _data.get("path"));
			if (frame_width <= 0 || frame_height <= 0) { frame_width = 16; frame_height = 16; }
			ent.makeGraphic(frame_width, frame_height, 0xff303030);
			return;
		}
		ent.myLoadGraphic(last_loaded_bitmap, true, false, frame_width, frame_height,false,null,has_spaces);
		//ent.myLoadGraphic(FlxBitmapDataUtil.addSpacesAndBorders(last_loaded_bitmap, new FlxPoint(frame_width, frame_height), new FlxPoint(1,1),new FlxPoint(1,1)), true, false, frame_width, frame_height);
		if (_data.get("alpha") != null) {
			ent.alpha = _data.get("alpha");
		}
		addAnimations(ent, class_name, _data.get("anim_set"));
	}
}