package flixel.system.ui;

#if !FLX_NO_SOUND_SYSTEM
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.Lib;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 */
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;
	
	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	private var _timer:Float;
	/**
	 * Helps display the volume bars on the sound tray.
	 */
	private var _bars:Array<Bitmap>;
	/**
	 * How wide the sound tray background is.
	 */
	private var _width:Int = 80;
	
	private var _defaultScale:Float = 2.0;
	
	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	public function new()
	{
		super();
		
		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		var tmp:Bitmap = new Bitmap(new BitmapData(_width, 30, true, 0x7F000000));
		screenCenter();
		addChild(tmp);
		
		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;
		
		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		
		#end
		var dtf:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 8, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "VOLUME";
		text.y = 16;
		
		var bx:Int = 10;
		var by:Int = 14;
		_bars = new Array();
		
		for (i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(4, i + 1, false, FlxColor.WHITE));
			tmp.x = bx;
			tmp.y = by;
			addChild(tmp);
			_bars.push(tmp);
			bx += 6;
			by--;
		}
		
		y = -height;
		x = -300;
		visible = false;
	}
	
	/**
	 * This function just updates the soundtray object.
	 */
	public function update(MS:Float):Void
	{
		y = -height;
		x = -300;
		visible = false;
		// Animate stupid sound tray thing
		FlxG.sound.volume = 1;
		if (_timer > 0)
		{
			_timer -= MS / 1000;
		}
		else if (y > - height)
		{
			y -= (MS / 1000) * FlxG.height * 2;
			
			if (y <= -height)
			{
				visible = false;
				active = false;
				
				// Save sound preferences
				//FlxG.save.data.mute = FlxG.sound.muted;
				//FlxG.save.data.volume = FlxG.sound.volume; 
				//FlxG.save.flush(); 
			}
		}
	}
	
	/**
	 * Makes the little volume tray slide out.
	 * 
	 * @param	Silent	Whether or not it should beep.
	 */
	public function show(Silent:Bool = false):Void
	{
		if (!Silent)
		{
			//FlxG.sound.load(BeepSound).play();
		}
		
		_timer = 1;
		y = 0;
		visible = true;
		active = true;
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);
		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}
		
		for (i in 0..._bars.length)
		{
			if (i < globalVolume) 
			{
				_bars[i].alpha = 1;
			}
			else 
			{
				_bars[i].alpha = 0.5;
			}
		}
	}
	
	public function screenCenter():Void
	{
		scaleX = _defaultScale / FlxG.game.scaleX;
		scaleY = _defaultScale / FlxG.game.scaleY;
		
		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x) / FlxG.game.scaleX;
	}
}
#end