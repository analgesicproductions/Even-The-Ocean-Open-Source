package help;
import flixel.FlxG;
import haxe.io.Eof;
import haxe.Log;
#if cpp
import sys.io.File;
import sys.io.FileInput;
#end

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

 ///timer 5 1 /msg $chan test
class TwitchHelper
{

	public function new() 
	{
		queue = [];
	}
	
	
	private var t_read:Float = 0;
	private var tm_read:Float = 3;
	private var cur_line_number:Int = 0;
	private var line_index:Int = 0;
	
	public var queue:Array<String>;
	public function update(elapsed: Float):Void {
		
		#if cpp
		// Read the file every tm_read seconds
		t_read += FlxG.elapsed;
		if (t_read > tm_read) {
			t_read = 0;
			//Log.trace(["try to read, cur line: ", cur_line_number]);
			var fin:FileInput = null;
			try {
				fin = File.read("D:/joke.txt");
				// will loop till EOF is reached
				while (true) {
					var line:String = fin.readLine();
					
					// the following lines will vary depending on what you want to do with the lines, in my case
					// I choose to give the username and then what they send (e.g. "han_tani x")
					var arg:String = line.split(" ")[1];
					var name:String = line.split(" ")[0];
					line_index ++;
					if (line_index >= cur_line_number) {
						// The queue only receives *new* lines that haven'tbeen added to it before
						//Log.trace(line);
						queue.push(name+" "+arg);
						cur_line_number++;
					}
				}
				
			} catch (e:Eof) { 
			
				line_index = 0;
				fin.close();
				return; 
			}	
		}
		#end
	}
	
	// call from elsewhere to do stuff with the sent commands
	public function get_queue():Array<String> {
		return queue;
	}

	public function clear_queue():Void {
		queue = [];
	}
	
	
}