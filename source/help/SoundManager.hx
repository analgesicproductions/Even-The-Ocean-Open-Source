package help;
import autom.SNDC;
import entity.ui.NineSliceBox;
import entity.util.SoundZone;
import flixel.text.FlxBitmapText;
import flixel.FlxSprite;
import global.C;
import global.Registry;
import haxe.Log;
import openfl.Assets;	
import flash.media.Sound;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.system.FlxSound;
import flixel.math.FlxPoint;
#if cpp
import sys.io.File;
#end
import openfl.geom.Rectangle;
import sys.FileSystem;

class SoundManager 
{

	private var sound_hash:Map<String,Dynamic>;
	/**
	 * THe "SFX VOLUME" setting
	 */
	public static var volume_modifier:Float = 1;
	
	public  var accessibility_str:String = "";
	private var accessibility_bg:NineSliceBox;
	private var accessibility_text:FlxBitmapText;
	private var mode_accessibility:Int = 0;
	public function new() 
	{
		sound_hash = new Map<String,Dynamic>();
		sound_list = new List<FlxSound>();
		load_runtime_sounds();
		load_mods();
		accessibility_text = HF.init_bitmap_font(" ");
		
		accessibility_bg = new NineSliceBox(0, 0, Assets.getBitmapData("assets/sprites/ui/9slice_dialogue.png"), new Rectangle(1, 1, 300, 82), [6, 6, 7, 7], NineSliceBox.TILE_BOTH,false, "assets/sprites/ui/9slice_dialogue.png");
	}
	
	private function load_mods():Void {
		
	}
	public function set_volume_modifier(v:Float):Void {
		if (v >= 1) v = 1;
		if (v <= 0) v = 0;
		volume_modifier = v;
	}
	
	public function get_volume_modifier():Float{
		return volume_modifier;
	}
	/**
	 * 
	 * @param	from_disk whether to copy all of the ones in source to the export folder
	 */
	/**
	 * FILE FORMAT
	 * name s
	 * name g 3
	 * name rg 4 name_1 2 name_2 2
	 */
	private function load_runtime_sounds(from_disk:Bool = false):Void {
		// Does nothing now
		#if flash
		return;
		#end

		var lines:Array<String> = [];
		if (from_disk) {
			lines = Assets.getText("assets/mp3/sound.meta").split("\n");
			#if cpp
			lines = File.getContent(C.EXT_MP3 + "sound.meta").split("\n");
			#end
		} else {
			lines = Assets.getText("assets/mp3/sound.meta").split("\n");
		}

		for (i in 0...lines.length) {
			var words:Array<String> = lines[i].split(" ");
			if (lines[i].indexOf("\t") != -1) {
				Log.trace("tab found in sfx metadata line " + Std.string(i));
			}
			if (words[0].charAt(0) == "#") continue;
			switch (words[1].split("\r")[0]) {
				case "g":
					
					var size:Int = Std.parseInt(words[2]);
					var g:Array<FlxSound> = [];
					#if cpp
					if (from_disk) {
						//HF.copy(C.EXT_SFX + words[0], "assets/mp3/sfx/" + words[0]);
					}
					#end
					for (i in 0...size) {
						var gs:FlxSound = new FlxSound();
						
					var s:Sound = Assets.getSound("assets/mp3/sfx/" + words[0]);
					//var s:Sound = Assets.getSound(words[0]);
						gs.loadEmbedded(s);
						g.push(gs);
					}
					
					sound_hash.set(words[0], g);
				case "s":
					// Changing?
					var s:FlxSound = new FlxSound();
					#if cpp
					if (from_disk) {
						//HF.copy(C.EXT_SFX + words[0], "assets/mp3/sfx/" + words[0]);
					}
					#end
					
					//s.loadEmbedded(Assets.getSound(words[0]));
					s.loadEmbedded(Assets.getSound("assets/mp3/sfx/" + words[0]));
					
					sound_hash.set(words[0], s);
				case "rg":
					var rg:Array<String> = new Array<String>();
					
					var cur:String = "";
					for (i in 2...words.length) {
						if (i % 2 == 0) {
							cur = words[i];
						} else {
							for (j in 0...Std.parseInt(words[i])) {
								rg.push(cur);
							}
						}
					}
					sound_hash.set(words[0], rg);
					
					// After rg is: path name / # 
					
			}
		}

		
	}
	
	/**
	 * A list of sounds that need to be update()'d
	 */
	var sound_list:List<FlxSound>;
	
	private var attach_to_player:Bool = false;
	private var on_screen_only:Bool = true;
	public function set_next_call_properties(on_screen_only:Bool = false, attach_to_player:Bool = false) {
		this.on_screen_only = on_screen_only;
		this.attach_to_player = attach_to_player;
	}
	private var _pan:Float = 0;
	private var _sx:Float = 0;
	private var _sy:Float = 0;
	private var _rad:Float = 0;
	private var _target:FlxObject;
	private var do_target:Bool = false;
	public var tickssincemapchange:Int = 0;
	
	public function set_pan_for_next_play(p:Float):Void {
		_pan = p;
	}
	public function set_target_for_next_play( target:FlxObject = null, radius:Float = 4, src_x:Float = 0, src_y:Float=0):Void {
		_target = target;
		_rad = radius;
		_sx = src_x;
		_sy = src_y;
		do_target = true;
	}
	public function fadeout(name:String):Void {
		var d:Dynamic = sound_hash.get(name);
		if (d != null && Std.is(d, FlxSound)) {
			var s:FlxSound = cast d;
			if (s.playing) {
				s.volume -= 0.05;
			}
		}
	}
	
	public function play(name:String, volume:Float = 1, only_on_screen:Bool = false, caller:FlxObject = null):Void {
		//
		//Log.trace([name,volume]);
		if (fade_all) { // no new sounds while fading out between maps
			return;
		}
		if (sound_hash.exists(name) == false) {
			//Log.trace("No such sound \"" + name + "\"");
			//Log.trace(sound_hash);
			return;
		}
		if (only_on_screen) {
			if (caller != null) {
				if (FlxG.camera.scroll.x <= caller.x + caller.width && FlxG.camera.scroll.x + FlxG.width >= caller.x) {
					if (caller.y + caller.height >= FlxG.camera.scroll.y && caller.y <= FlxG.camera.scroll.y + FlxG.height) {
						
					} else {
						return;
					}
				} else {
					return;
				}
			}
		}
		
		// For a random sound get one
		var pan:Float = _pan;
		var d:Dynamic = sound_hash.get(name);
		var is_array:Bool = false;
		if (Std.is(d, Array)) {
			is_array = true;
			if (Std.is(d[0], String)) {
				var rand_list:Array<String> = d;
				var len:Int = rand_list.length;
				var new_name:String = rand_list[Std.int(Math.random() * len)];
				d = sound_hash.get(new_name);
				if (d == null) return;
				if (Std.is(d, FlxSound)) {
					is_array = false;
				}
			}
		}
		if (is_array) {
			
			for (i in 0...d.length) {
				if (false == d[i].playing) {
					
					for (sound in sound_list.iterator()) {
						if (sound == d[i]) continue;
					}
					
					d[i].set_volume(volume * volume_modifier);
					if (pan != 0) {
						if (pan > 1) pan = 1;
						if (pan < -1) pan = -1;
						d[i]._transform.pan = pan;
					}
					d[i].play();
					
					sound_list.add(d[i]);
					_pan = 0;
					var snd:FlxSound = cast d.shift();
					d.push(snd);
					return;
				}
			}
		} else {
			if (!d.playing) {
				d.set_volume(volume * volume_modifier);
				if (pan != 0) { 
					if (pan > 1) pan = 1;
					if (pan < -1) pan = -1;
					d._transform.pan = pan;
				}
				d.play();
				if (do_target) {
					d.set_volume(volume * volume_modifier);
					d.proximity(_sx, _sy,_target, _rad, true);
				} 
				sound_list.add(d);
				_pan = 0;
				do_target = false;
			}
		}
	}
	public var fade_all:Bool = false;
	public var allow_fade_all:Bool = true;
	private var remove:Array<Dynamic> = [];
	public function stop_all():Void {
		for (sound in sound_list.iterator()) {
			sound.stop();
			remove.push(sound);
		}
		for (s in remove) {
			sound_list.remove(cast s);
		}
		remove = [];
		fade_all = false;
	}
	public function update(elapsed: Float):Void {
		
		if (tickssincemapchange < 60) tickssincemapchange++;
		if (FlxG.keys.myJustPressed("L")) {
			//load_runtime_sounds(true);
		}
		
		//if (fade_all) {
			//Log.trace([fade_all, sound_list.length]);
		//}
		for (sound in sound_list.iterator()) {
			if (fade_all) {
				sound.volume += -0.025;
			}
			if (sound.playing == false) {
				remove.push(sound);
			} else {
				sound.update(elapsed);
			}
		}
		
		if (remove != []) {
			for (s in remove) {
				sound_list.remove(s);
			}
			remove = [];
		}
		
		if (mode_accessibility == 0) {
			if (accessibility_str != "" && accessibility_str != " ") {
				if (Registry.R.access_opts[8] == false) {
					accessibility_str = "";
					return;
				}
				//R.sound_manager.accessibility_str = Registry.R.dialogue_manager.lookup_sentence("ui", "sound_labels", 1);
				accessibility_str = Registry.R.dialogue_manager.lookup_sentence("ui", "sound_labels", 0) + " " + accessibility_str;
				accessibility_text.text = accessibility_str;
				accessibility_bg.resize(16 + accessibility_text.width, 16 + accessibility_text.height + 12);
				accessibility_text.scrollFactor.set(0, 0);
				accessibility_bg.scrollFactor.set(0, 0);
				accessibility_bg.x = (C.GAME_WIDTH - accessibility_bg.width) / 2;
				accessibility_bg.y = C.GAME_HEIGHT - accessibility_bg.height - 20;
				accessibility_text.move(accessibility_bg.x + 8, accessibility_bg.y + 8);
				Registry.R.TEST_STATE.add(accessibility_bg);
				Registry.R.TEST_STATE.add(accessibility_text);
				mode_accessibility = 1;
			}
		} else if (mode_accessibility > 0 && mode_accessibility < 180) {
			mode_accessibility++;
			
		} else {
			mode_accessibility = 0;
			accessibility_str = "";
			Registry.R.TEST_STATE.remove(accessibility_bg);
			Registry.R.TEST_STATE.remove(accessibility_text);
		}
		
	}
	
	public var wallfloor_info:String = "";
	public function set_wall_floor(mapname:String):Void {
		if (Registry.R.editor.editor_active || wallfloor_info.length < 3) {
			if (FileSystem.exists(C.EXT_MP3+"wallfloor.txt")) {
				wallfloor_info = File.getContent(C.EXT_MP3 + "wallfloor.txt");
			} else {
				wallfloor_info = Assets.getText("assets/mp3/wallfloor.txt");
			}
		}
		var lines:Array<String> = wallfloor_info.split("\n");
		var suffix:String = "";
		var floor:String = "";
		var wall:String = "";
		//Log.trace("Resetting in_gauntlet state for energyBar");
		Registry.R.player.energy_bar.in_gauntlet = false;
		if (mapname == "ROUGE_4" || mapname == "ROUGE_5" || mapname == "WF_JH" || mapname == "WF_JS" || mapname == "WF_JC" ) {
			Registry.R.player.energy_bar.in_gauntlet = true;
		}
		for (i in 0...lines.length) {
			var line:String = StringTools.trim(lines[i]);
			if (line.indexOf("//") != -1 || line.indexOf("#") != -1) {
				continue;
			}
			var parts:Array<String> = line.split(" ");
			suffix = parts[0];
			floor = parts[1];
			wall= parts[2];
			if (mapname.indexOf(suffix) != -1) {
				Registry.R.player.energy_bar.in_gauntlet = true;
				SoundZone.active_floor_sound = floor;
				SoundZone.active_wall_sound = wall;
				SoundZone.default_floor_sound = floor;
				SoundZone.default_wall_sound = wall;
				//Log.trace([floor, wall]);
				return;
			}
		}
		// last line is "deafult" sounds
		SoundZone.active_floor_sound= floor; // Always reset to generic
		SoundZone.active_wall_sound= wall; // Always reset to generic		
		SoundZone.default_floor_sound = floor;
		SoundZone.default_wall_sound = wall;
		//Log.trace([floor, wall]);
	}
}