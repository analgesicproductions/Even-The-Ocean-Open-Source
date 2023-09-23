package entity.tool;

import flixel.FlxSprite;
/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class MyParticle extends FlxSprite
{

	public var min_ixv:Float = 0;
	public var max_ixv:Float = 0;
	public var min_iyv:Float = 0;
	public var max_iyv:Float = 0;
	public var max_alpha:Float = 0;
	public var min_alpha:Float = 0;
	public var needs_light:Bool = false;
	public var movetype:Int = 0;
	/**
	 * An array of layer_anim IDs.
	 */
	public var anims:Array<String>;
	public function new() 
	{
		anims = new Array<String>();
		super();
	}
	
}