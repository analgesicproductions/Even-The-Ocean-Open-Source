package entity.ui;
import flixel.text.FlxBitmapText;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import global.C;
import global.Registry;
import haxe.Log;
import help.HF;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class LyricsPlayer extends FlxGroup
{

	public function new() 
	{
		super();
		
	}
	
	var music_notes:FlxSprite;
	var lyrics:FlxBitmapText;
	public function activate(map:String, scene:String):Void {
		// get lines
		
		ctr = 0;
		if (music_notes == null) {
			music_notes = new FlxSprite();
			music_notes.makeGraphic(16, 16, 0xff123123);
			//add(music_notes);
			music_notes.scrollFactor.set(0, 0);
		}
		
		if (lyrics == null) {
			lyrics = HF.init_bitmap_font(" ", "left", 0, 0,null,C.FONT_TYPE_ALIPH_WHITE);
			lyrics.double_draw  = true;
			lyrics.scrollFactor.set(0, 0);
			add(lyrics);
		} else {
			var bm:FlxBitmapText = null;
			var i:Int = 0;
			bm = HF.init_bitmap_font(" ", "left", 0, 0, null, C.FONT_TYPE_ALIPH_WHITE); bm.double_draw = true; i = members.indexOf(lyrics); members[i] = bm; lyrics.destroy(); lyrics = cast members[i];
		}
		
		lyrics.x = 100;
		lyrics.y = 32;
		lyrics.lineSpacing = 2;
		
		lines = [];
		times = [];
		added = [];
		var nr_lines:Int = Std.parseInt(Registry.R.dialogue_manager.lookup_sentence(map, scene, 0, true, true));
		
		for (i in 1...nr_lines+1) {
			var raw:String = Registry.R.dialogue_manager.lookup_sentence(map, scene, i, true, true);
			times.push(Std.parseInt(raw.split(" ")[1]) + 60 * Std.parseInt(raw.split(" ")[0]));
			lines.push(raw.split("$")[1]);
			lyrics.text += lines[i - 1];
			added.push(false);
		}
		
		usesongtiming = true;
		if (scene == "endquote") {
			//Log.trace(lyrics.text);
			//Log.trace(lyrics.x);
			lyrics.x = (C.GAME_WIDTH / 2) - (lyrics.width / 2);
			//Log.trace(lyrics.x);
			usesongtiming = false;
			lyrics.alpha = 0;
		}
		lyrics.text = "";
		//Log.trace(lines);
		//Log.trace(times);
		mode = 1;
		
	}
	public var lines:Array<String>;
	public var times:Array<Int>;
	public var added:Array<Bool>;
	
	public function deactivate():Void {
	}
	public function is_done():Bool {
		if (mode == 0) return true;
		return false;
	}
	
	var ctr:Int = 0;
	var mode:Int = 0;
	public var usesongtiming:Bool = true;
	
	override public function update(elapsed: Float):Void 
	{
		if (mode == 0) return;
		
		var stime:Float = 0;
		if (usesongtiming && Registry.R.song_helper.cur_song.playing) {
			stime = Registry.R.song_helper.cur_song._channel.position / 1000.0;
		}
		
		
		for (i in 0...times.length) {
			
			if ((usesongtiming && times[i] / 60.0 < stime && added[i] == false) || (!usesongtiming && times[i] == ctr)) {
				if (lines[i] == "clear") {
					if (!usesongtiming) {
						lyrics.alpha -= 0.007;
						if (lyrics.alpha <= 0) {
							added[i] = true;
							lyrics.text = " ";
						} else {
							ctr--;
							continue;
						}
					} else {
						added[i] = true;
						lyrics.text = " ";
					}
				} else {
					// bad hack to get end quote to work
					if (!usesongtiming) {
						if (lyrics.alpha == 0) {
							lyrics.text = lines[i];
						}
						lyrics.alpha += 0.008;
						if (lyrics.alpha >= 1) {
							added[i] = true;
						} else {
							ctr--;
							continue;
						}
					} else {
						added[i] = true;
						if (lyrics.text == " ") {
							lyrics.text = lines[i];
						} else {
							lyrics.text += lines[i];
						}
					}
				}
				if (i == times.length - 1) {
					mode = 0;
				}
			}
		}
		ctr++;
		super.update(elapsed);
	}
	
}