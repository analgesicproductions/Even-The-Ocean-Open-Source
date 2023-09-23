package help;
import flash.media.SoundChannel;
import global.C;
import global.Registry;
import haxe.Log;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.Assets;
import flash.media.Sound;
import flixel.FlxG;
import flixel.system.FlxSound;
#if cpp
import sys.io.File;
#end

/**
 * Parses 
 */
class SongHelper 
{


	
	public var stop_song_changes:Bool = false;
	private var did_init:Bool = false;
	private var cur_script:String = "";
	
	private var script_hash:Map<String,Dynamic>;
	private var song_cache:Map<String,Dynamic>;
	public var cur_song:FlxSound;
	public var cur_song_name:String = "";
	public var next_song_name:String = "";
	private var R:Registry;
	
	private var DO_FADE_TO_NEXT_SONG:Bool = false;
	public var FADE_OUT_SLOW:Bool = false;
	public var FADE_OUT_FAST:Bool = false;
	private static inline var FADE_OUT_FAST_RATE:Float = 1 / 20;
	private static inline var FADE_OUT_SLOW_RATE:Float = 1 / (30*3);
	
	private var mode:Int = 0;
	private var MODE_NORMAL:Int = 0;
	private var MODE_FADE_OUT:Int = 1;
	private var MODE_FADE_IN:Int = 2;
	
	public static inline var _SONG_TITLE:String = "_title"; // ID in songtriggers
	/**
	 * The "Volume" setting of the user.
	 */
	public static var song_volume_modifier:Float = 1;
	/**
	 * The base volume that is modified by fading in and out.
	 */
	public var base_song_volume:Float = 1;
	public function new() 
	{
		song_cache = new Map<String,Dynamic>();
		
		load_script(false);
		cur_song = new FlxSound();
		R = Registry.R;
	}
	
	public function set_volume_modifier(v:Float):Void {
		if (v >= 1) v = 1;
		if (v <= 0) v = 0;
		song_volume_modifier = v;
		cur_song.volume = base_song_volume * song_volume_modifier;
	}
	public function get_volume_modifier():Float {
		return song_volume_modifier;
	}
	
	public function load_script(from_dev:Bool=false):Void {
		
		script_hash = null;
		script_hash = new Map<String,Dynamic> ();
		#if cpp
		if (from_dev) {
			cur_script =  File.getContent(C.EXT_MP3 + "songtriggers.txt");
		} else {
			cur_script = Assets.getText("assets/mp3/songtriggers.txt");
		}
		#end
		
		#if flash
		if (from_dev) from_dev = false;
		cur_script = Assets.getText("assets/mp3/songtriggers.txt");
		return;
		#end
		
		var curmap:String = "";
		var mapscript:Array<String> = null;
		var lines:Array<String> = cur_script.split("\n");
		for (i in 0...lines.length) {
			var line:String = lines[i];
			if (line.length <= 2) continue;
			if (line.charAt(0) == "#") continue;
			line = StringTools.rtrim(line);
			var words:Array<String> = line.split(" ");
			var KEYWORD:String = words[0].split("\r")[0];
			
			switch (KEYWORD) {	
				
				case "list":
					var songnames:Array<String> = words[1].split(",");
					for (i in 0...songnames.length) {
						if (from_dev) {
							song_cache.set(songnames[i], Assets.getMusic(songnames[i],true));
						} else {
							//song_cache.set(songnames[i], Assets.getSound("assets/mp3/song/" + songnames[i]));
							//song_cache.set(songnames[i], Assets.getSound(songnames[i]));
							song_cache.set(songnames[i], Assets.getMusic(songnames[i],true));
						}
					}
				case "map":
					curmap = words[1].split("\r")[0];
					mapscript = new Array<String>();
				case "end":
					script_hash.set(curmap, mapscript);
				default:
					mapscript.push(line.split("\r")[0]);
			}
		}
	}
	private var wait_ticks:Int = 3;
	private static var MAX_WAIT_TICKS:Int = 3;
	public function update(elapsed: Float):Void {	
		
		//var chnl:SoundChannel = cast Reflect.getProperty(cur_song, "_channel");
		//if (chnl != null) {
			//Log.trace(chnl.position);
			// Seems to give the time in milliseconds (17657 = 17.6 seconds)
		//}
		switch (mode) {
			case _ if (MODE_NORMAL == mode):
				if (DO_FADE_TO_NEXT_SONG) {
					mode = MODE_FADE_OUT;
				} else if (next_song_if_single != "") {
					if (INSTANT_FADE) {
						// Wait for the song to start playing before trying to stop it
						if (cur_song.playing == true) {
							INSTANT_FADE = false;
						} else {
							Log.trace("waiting to start playing..");
						}
					} else {
						if (cur_song.playing == false) {
							fade_to_this_song(next_song_if_single);
						}
					}
				}
			case _ if (MODE_FADE_IN == mode):
				if (INSTANT_FADE) {
					base_song_volume = 1;
				}
				base_song_volume += FADE_OUT_FAST_RATE;
				cur_song.volume = base_song_volume * song_volume_modifier;
				if (base_song_volume >= 1) {
					base_song_volume = 1;
					mode = MODE_NORMAL;
					if (DO_FADE_TO_NEXT_SONG) {
						
						DO_FADE_TO_NEXT_SONG = false;
					}
				}
			case _ if (MODE_FADE_OUT == mode):
				if (INSTANT_FADE) {
					base_song_volume = 0;
				} else if (FADE_OUT_FAST) {
					base_song_volume -= FADE_OUT_FAST_RATE;
				} else if (FADE_OUT_SLOW) {
					base_song_volume -= FADE_OUT_SLOW_RATE;
				} 
				cur_song.volume = base_song_volume * song_volume_modifier;
				if (base_song_volume <= 0) {
					if (DO_FADE_TO_NEXT_SONG) {
						if (INSTANT_FADE && wait_ticks > MAX_WAIT_TICKS) {
							wait_ticks = MAX_WAIT_TICKS;
						}
						// wait_ticks starts at 3 on game startup. not sure why.
						if (wait_ticks > 0) {
							if (wait_ticks == MAX_WAIT_TICKS) {
								cur_song.stop();
							} else if (wait_ticks == 2) {
								var next_song_data:Sound = song_cache.get(next_song_name);
								if (next_song_data == null) {
									mode = MODE_NORMAL;
									DO_FADE_TO_NEXT_SONG = false;
									wait_ticks = MAX_WAIT_TICKS;
								}  else {
									if (next_song_if_single != "") {
										cur_song.loadEmbedded(next_song_data,false);
									} else {
										cur_song.loadEmbedded(next_song_data, true);
									}
								}
							} else if (wait_ticks == 1) {
								cur_song.play();
							}
							wait_ticks--;
							return;
						}
						
						cur_song_name = next_song_name;
						mode = MODE_FADE_IN;
						wait_ticks = 25; // ???
					} else {
						mode = MODE_NORMAL;
					}
					FADE_OUT_FAST = FADE_OUT_SLOW = false;
				}
		}
	}
	
	/**
	 * fade to the next map's song based on its script
	 * speed > 0 for fast
	 * @param	next_map
	 * @param	speed
	 */
	private var interp:Interp;
	private var parser:Parser;
	private var expr:Expr;
	public function fade_to_next_song(next_map:String, speed:Int = 0):Void {
		
		if (stop_song_changes) {
			return;
		}
		INSTANT_FADE = false;
		next_map = next_map.toLowerCase();
		if (script_hash.exists(next_map) == false) {
			Log.trace("No song script for " + next_map);
			return;
		}
		var mapscript:Array<String> = script_hash.get(next_map);
		if (mapscript[0].indexOf("script") == 0) {
			mapscript.splice(0, 1);
			var the_script:String = mapscript.join("\r\n");
			mapscript.insert(0, "script");
			if (interp == null) {
				interp = new Interp();
				parser = new Parser();
			}
			interp.variables.set("R", R);
			var expr:Expr = parser.parseString(the_script);
			next_song_name = interp.execute(expr);
		} else {
			for (i in 0...mapscript.length) {
				var words:Array<String> = mapscript[i].split(" ");
				if (words.length == 1) { // Play this song
					next_song_name = words[0].split("\r")[0];
					//Log.trace("Next song will be " + next_song_name);
				} else { // If statemnt or sometin
					
				}
			}
		}
		
		if (permanent_song_name == null) {
			permanent_song_name = "";
		}
		if (permanent_song_name != "") {
			next_song_name = permanent_song_name;
		}
		
		// Don't change songs if the song is the same
		if (next_song_name == cur_song_name) {
			if (base_song_volume == 0) {
				mode = MODE_FADE_IN;
				return;
			}
			Log.trace(next_song_name + " alraeady playing, ignoring song change cue");
			return;
		}
		if (speed == 0) {
			FADE_OUT_SLOW = true;
		} else {
			FADE_OUT_FAST = true;
		}
		
		mode = MODE_NORMAL; // Reset SongHelper state so that if we run between triggers we get the most recent song
		DO_FADE_TO_NEXT_SONG = true;
	}
	public var INSTANT_FADE:Bool = false;
	/**
	 * 
	 * @param	song_name
	 * @param	instant
	 * @param	next if != "", this given song will play once then start the next one
	 */
	private var next_song_if_single:String = "";
	public var permanent_song_name:String = ""; // if nonempty, this song always plays. seralized
	public function fade_to_this_song(song_name:String, instant:Bool = false, next:String = ""):Void {
		if (permanent_song_name == null) {
			permanent_song_name = "";
		}
		if (permanent_song_name != "") {
			song_name = permanent_song_name;
		}
		if (cur_song_name == song_name) {
			if (cur_song_name == next_song_if_single) {
				next_song_if_single = "";
			}
			Log.trace(next_song_name+" alread plaing");
			return;
		}
		if (song_cache.exists(song_name)) {
			Log.trace("Trying to fade to " + song_name);
			next_song_name = song_name;
			
			mode = MODE_NORMAL;
			DO_FADE_TO_NEXT_SONG = true;
			FADE_OUT_FAST = true;
			INSTANT_FADE = instant;
			next_song_if_single = next;
		} else {
			Log.trace("No song \"" + song_name + "\"" + " . Maybe you forgot to add it to the nmml or songtriggers.txt?");
		}
	}
}