package help;
import global.C;
import global.Registry;
import haxe.CallStack;
import haxe.Log;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Track
{

	private static var data:Array<String>;
	private static var start_time:Int = 0;
	public static function init():Void {
		data = [];
		
		var d:Date = Date.now();
		start_time = Std.int(d.getTime());
		
		add_start_session();
	}
	
	private static function relative_timestamp():String {
		var now_time:Int = Std.int(Date.now().getTime());
		var diff:Int = Std.int((now_time - start_time) / 1000);
		return "[" + HF.get_time_string(diff) + "]";
	}
	public static function flush():Void {
		
		#if cpp
		if (FileSystem.exists(JankSave.SAVE_DIR + "../eventlog") == false) {
			File.saveContent(JankSave.SAVE_DIR + "../eventlog", "\n");
		}
		
		var s:String = data.join("\n");
		var _s:String = File.getContent(JankSave.SAVE_DIR + "../eventlog");
		File.saveContent(JankSave.SAVE_DIR + "../eventlog", _s +"\n"+ s);
		
		#end
		data = [];
	}
	
	public static function get_stacktrace(notexception:Bool=false):String {
		var stackTrace:String = "";
		var stack:Array<StackItem> = null;
		if (notexception) {
			stack = CallStack.callStack();
		} else {
			stack = CallStack.exceptionStack();
		}
		stack.reverse();
		var item:StackItem;
		for (item in stack)
		{
			stackTrace += printStackItem(item) + "\n";
		}
		return stackTrace;
	}
	public static function add_crashed():Void {
		
		var stackTrace:String = get_stacktrace();
		var csd:CrashSystemData = new CrashSystemData();
		Log.trace(stackTrace);
		
		append("Game crashed", "\n"+csd.summary()+"\n"+stackTrace);
	}
	
	public static function add_closed():Void {
		var csd:CrashSystemData = new CrashSystemData();
		Log.trace(get_stacktrace());
		append("Closed game", "");
	}
	private static function add_start_session():Void {
		append("Started Session", Date.now().toString());
	}
	public static function add_new_game(id:Int):Void {
		append("New Game", "#" + _s(id));
	}
	public static function add_load_map(map:String, start_x:Float, start_y:Float):Void {
		Log.trace("Entered Map "+ map + " at " + xy(start_x, start_y));
		
		append("Entered Map", map + " at "+xy(start_x,start_y));
	}
	public static function add_saved_game(id:Int, map:String,x:Float, y:Float):Void {
		append("Saved Game", "#" + _s(id) + " at " + map + " " + xy(x, y));
	}
	public static function add_deleted(id:Int):Void {
		append("Deleted Game", "#" + _s(id));
	}
	public static function add_loaded(id:Int):Void {
		append("Loaded Game", "#" + _s(id));
	}
	public static function add_event_flag(id:Int, old:Int, _new:Int):Void {
		append("Event Flag Set", "#" + _s(id) + " Old: " + _s(old) + " to New: " + _s(_new));
	}
	public static function add_item(id:Int, old_val:Int,new_val:Int):Void {
		append("Item", "#" + _s(id) + " Old: "+_s(old_val)+" New: " + _s(new_val) + " (" + Registry.R.dialogue_manager.lookup_sentence("ui", "item_labels", id) + ")");
	}
	public static function add_death(x:Float, y:Float, map:String):Void {
		append("Died!", map + " at " + xy(x, y));
	}
	public static function add_dialogue_state(s:String):Void {
		append("Dialogue", s);
	}
	private static function _s(d:Dynamic):String {
		return Std.string(d);
	}
	private static function xy(x:Float, y:Float):String {
		return "(" + Std.string(Std.int(x)) + "," + Std.string(Std.int(y)) + ")";
	}
	public static function append(type:String,s:String):Void {
		data.push(relative_timestamp() + "\t[" + type + "]\t" + s);
		
	}
	
	public static function printStackItem(itm:StackItem):String
	{
		var str:String = "";
		switch( itm ) {
			case CFunction:
				str = "a C function";
			case Module(m):
				str = "module " + m;
			case FilePos(itm,file,line):
				if( itm != null ) {
					str = printStackItem(itm) + " (";
				}
				str += file;
				str += " line ";
				str += line;
				if (itm != null) str += ")";
			case Method(cname,meth):
				str += (cname);
				str += (".");
				str += (meth);
			case LocalFunction(n):
				str += ("local function #");
				str += (n);
		}
		return str;
	}
	
	
	
}