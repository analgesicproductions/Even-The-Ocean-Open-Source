package entity.ui;
import entity.player.BubbleSpawner;
import global.Registry;
import help.FlxX;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class PixelTest extends FlxGroup
{
	
	public function new() 
	{
		super();
		for (i in 0...6*6) {
			var s:FlxSprite = new FlxSprite(0, 0);
			s.makeGraphic(4,4, 0xffff0000);
			add(s);
		}
	}
	
	override public function update(elapsed: Float):Void {
		
			var s:FlxSprite;
		if (FlxG.keys.myJustPressed("SPACE")) {
			for (i in 0...members.length) {
				s =  cast members[i];
				s.x = Registry.R.player.x + 4*(i % 6);
				s.y = Registry.R.player.y + 4*Std.int(i / 6);
			}
		}
		
		if (BubbleSpawner.cur_bubble != null) {
		for (i in 0...members.length) {
			s = cast members[i];
			if (FlxX.circle_flx_obj_overlap(BubbleSpawner.circle[0], BubbleSpawner.circle[1], BubbleSpawner.circle[2], s)) {
				s.makeGraphic(4,4, 0xff00ff00);
			} else {
				s.makeGraphic(4,4, 0xffff0000);
			}
		}
		}
		
		super.update(elapsed);
	}
	
}