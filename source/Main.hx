package;

import flash.display.Graphics;
import haxe.Log;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
import flash.ui.Keyboard;
import flixel.FlxGame;
import help.Track;
import sys.FileSystem;

/**
 * @author Joshua Granick
 */
class Main extends Sprite 
{
	
	public static var main_ref:Main;
	public function new () 
	{
		
		super();	
		if (stage != null) 
			init();
		else 
			addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(?e:Event = null):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		

		initialize();
		
		//var m:Map<String,Dynamic> = new Map<String,Dynamic>();
		//m.set("bob", 123);
		//m.set("bob2", "awera waereawr");
		//Log.trace(m.get("bob"));
		
		var demo:FlxGame = new ProjectClass();
		addChild(demo);
		
		#if (cpp || neko)
		Lib.current.stage.addEventListener(Event.RESIZE, onRESIZE);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUP);
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onErrorEvent);
		Lib.current.stage.addEventListener(Event.DEACTIVATE, onCLOSE);
		#end
		
	}
	
	#if (cpp || neko)
	private function onErrorEvent(d:Dynamic):Void {
		Track.add_crashed();
		Track.flush();
	}
	private function onRESIZE(e:Event):Void {
		return;
	}
	
	private function onCLOSE(e:Event):Void {
		Track.add_closed();
		Track.flush();
	}
	private function onKeyUP(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.ESCAPE)
		{
			//Lib.exit();
		}
	}
	#end
	
	private function initialize():Void 
	{
		#if cpp
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.opaqueBackground = 0x000000;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		#end
		//Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
	}
	
	// Entry point
	public static function main() {
		
		Lib.current.addChild(new Main());
	}
	
}