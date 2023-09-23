package entity.ui;
import flixel.FlxSprite;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class MyRectSprite extends FlxSprite
{

	public var _w:Float;
	public var _h:Float;
	public function new(olor:Int,w:Int,h:Int) 
	{
		super();
		_w = w;
		_h = h;
		
		makeGraphic(2,2, olor);
		origin.set(0, 0);
	}
	public function pick_color(_olor:Int):Void {
		makeGraphic(2,2, _olor);
		origin.set(0, 0);
	}
	public function set_size(w:Int, h:Int):Void {
		_w = w;
		_h = h;
	}
	
	override public function draw():Void 
	{
		scale.set(_w/2, 1);
		super.draw();
		y += _h;
		super.draw();
		y -= _h;
		scale.set(1, _h/2);
		super.draw();
		x += _w;
		super.draw();
		x -= _w;
	}
	
}