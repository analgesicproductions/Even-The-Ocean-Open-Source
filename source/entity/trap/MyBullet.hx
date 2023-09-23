package entity.trap;
import flixel.FlxSprite;
import haxe.Log;
import help.AnimImporter;

/**
 * Helper class, with properties like is_dark etc
 * @author Melos Han-Tani
 */

class MyBullet extends FlxSprite
{
	
	public var is_dark:Bool = false;
	public var is_light:Bool = false;
	public var timers:Array<Float>;
	public var pos:Array<Float>;
	private var t_trail:Int = 0;
	private var tm_trail:Int = 0;
	private var fr:Int = 0;
	private var frms:Array<Int>;
	private var t_idx:Int = 0;
	public var trail:FlxSprite;
	public var nohittile:Int = 0;
	public function new(_x:Float,_y:Float,_is_dark:Bool)
	{
		super(_x, _y);
		trail = new FlxSprite();
		
		var dat:Map<String,Dynamic> = null;
		if (_is_dark) {
			is_dark = true;
			AnimImporter.loadGraphic_from_data_with_id(trail, 16, 16, "PewBullet", "2");
			dat = AnimImporter.get_animdata("PewBullet", "2", "trail");
		} else {
			is_light = true;
			AnimImporter.loadGraphic_from_data_with_id(trail, 16, 16, "PewBullet","1");
			dat = AnimImporter.get_animdata("PewBullet", "1", "trail");
		}
		frms = [];
		var _frms:Array<Int> = dat.get("frames");
		for (i in 0..._frms.length) {
			frms.push(_frms[i]);
			trail.animation.add(Std.string(_frms[i]), [_frms[i]], 1, true);
		}
		fr = dat.get("fr");
		tm_trail = fr*frms.length;
		
		timers = [ -1, -1, -1,-1,-1];
		pos = [0, 0, 0, 0, 0, 0,0,0,0,0];
	}
	
	// only called when exists is true
	override public function draw():Void 
	{
		t_trail += 1;
		if (t_trail >= 2) {
			t_trail = 0;
			
			pos[t_idx * 2] = x;
			pos[1 + t_idx * 2] = y;
			timers[t_idx] = 0;
			t_idx ++;
			if (t_idx == 5) {
				t_idx = 0;
			}
		}
		
		var act_t_idx:Int = t_idx;
		trail.alpha = 0.6;
		for (i in 0...5) {
			if (timers[act_t_idx] != -1) {
				timers[act_t_idx] ++;
				trail.width = width;
				trail.height = height;
				trail.offset.set(offset.x, offset.y);
				trail.x = pos[act_t_idx * 2];
				trail.y = pos[1 + act_t_idx * 2];
				if (Std.int(timers[act_t_idx] / fr) >= frms.length) {
					timers[act_t_idx] = -1;
				} else {
					trail.animation.play(Std.string(frms[Std.int(timers[act_t_idx] / fr)]), true);
					trail.draw();
				}
			}
			trail.alpha += 0.1;
			act_t_idx ++;
			if (act_t_idx == 5) {
				act_t_idx = 0;
			}
		}
		super.draw();
	}
}