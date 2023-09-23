package state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tile.FlxTilemap;
import global.C;
import openfl.Assets;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class EmptyGameState extends FlxState
{

	public function new() 
	{
		super();
		
	}

	
	var s:FlxSprite;
	var txt:FlxBitmapText;
	override public function create():Void 
	{
		var tt:FlxTilemap = new FlxTilemap();
		var a:Array<Int> = [];
		//txt = new FlxBitmapText(FlxBitmapFont.fromMonospace(Assets.getBitmapData("assets/sprites/font/font-white-apple-7x8.png"), C.C_FONT_APPLE_WHITE_STRING, new FlxPoint(C.APPLE_FONT_w, C.APPLE_FONT_h), null, new FlxPoint(0, 0)));
		txt = new FlxBitmapText(FlxBitmapFont.fromMonospace(Assets.getBitmapData("assets/sprites/font/aliph_script2_white.png"), C.C_FONT_ALIPH_STRING, new FlxPoint(C.ALIPH_FONT_w, C.ALIPH_FONT_h), null, new FlxPoint(0, 0)));
		for (i in 0...480) {
			a.push(i);
		}
		//tt.widthInTiles = 20;
		//tt.heightInTiles = 24;
		//tt.loadMap(a, Assets.getBitmapData("assets/tileset/SHOREPLACE_tileset.png"), 16, 16);
		tt.loadMapFromArray(a,20,24,Assets.getBitmapData("assets/tileset/SHOREPLACE_tileset.png"), 16, 16);
		add(tt);
		
		s = new FlxSprite();
	
		FlxG.camera.setScrollBoundsRect(0, 0, 1000, 1000, true);
		FlxG.camera.follow(s);
		s.makeGraphic(32, 32, 0xff123123);
		add(s);
		txt.text = "Hello World";
		txt.double_draw = true;
		add(txt);
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (FlxG.keys.pressed.DOWN) {
			s.velocity.y = 200;
			txt.text = "DOWN";
		} else if (FlxG.keys.pressed.UP) {
			s.velocity.y = -200;
			txt.text = "UP\nallala";
		}
		super.update(elapsed);
	}
	
}