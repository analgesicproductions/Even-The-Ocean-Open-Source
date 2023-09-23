package help;

import flixel.FlxG;
import flixel.FlxSprite;
import global.Registry;
import haxe.Log;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class WMDrawSprite extends FlxSprite
{

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		R = Registry.R;
	}
	
	
	override public function update(elapsed: Float):Void 
	{
		if (ProjectClass.DEV_MODE_ON && FlxG.keys.pressed.SHIFT && !R.editor.editor_active) {
		if (FlxG.keys.justPressed.THREE) {
			turnedoff = !turnedoff;
		}
		if (FlxG.keys.justPressed.FOUR) {
			R.TEST_STATE.fg2_parallax_layers.visible = !R.TEST_STATE.fg2_parallax_layers.visible;
		}
		if (FlxG.keys.justPressed.FIVE) {
			R.TEST_STATE.tm_bg.visible = !R.TEST_STATE.tm_bg.visible;
			R.TEST_STATE.tm_bg2.visible = !R.TEST_STATE.tm_bg2.visible;
			R.TEST_STATE.tm_fg.visible = !R.TEST_STATE.tm_fg.visible;
			R.TEST_STATE.tm_fg2.visible = !R.TEST_STATE.tm_fg2.visible;
		}
		if (FlxG.keys.justPressed.SIX) {
			R.worldmapplayer.visible = !R.worldmapplayer.visible;
		}
		
		if (false) {
		if (FlxG.keys.justPressed.S) {
			pxpx -= 0.005;
			wm_sx_init = false;
			wm_sx_a = [];
			Log.trace(pxpx);
		} else if (FlxG.keys.justPressed.W) {
			pxpx += 0.005;
			wm_sx_init = false;
			wm_sx_a = [];
			Log.trace(pxpx);
		}
		
		if (FlxG.keys.justPressed.A) {
			
			Log.trace("top scrunch DOWN");
			Log.trace(sc);
			sc -= 0.03;
			wm_sx_a = [];
			wm_sx_init = false;
		} else if (FlxG.keys.justPressed.Q) {
			Log.trace("top scrunch UP");
			sc += 0.03;
			Log.trace(sc);
			wm_sx_a = [];
			wm_sx_init = false;
		}
		if (FlxG.keys.justPressed.E) {
			Log.trace("bottom stretch UP");
			Log.trace(sc_lo);
			sc_lo -= .03;
			wm_sx_a = [];
			wm_sx_init = false;
		} else if (FlxG.keys.justPressed.D) {
			
			Log.trace("bottom stretch DOWN");
			sc_lo += .03;
			Log.trace(sc_lo);
			wm_sx_a = [];
			wm_sx_init = false;
		}
		}
		
		}
		super.update(elapsed);
	}
	private var R:Registry;
	public var wm_sx_a:Array<Float>;
	private var wm_sx_init:Bool = false;
	private var pxpx:Float = 0.405;
	private var sc:Float = 2.34;
	private var sc_lo:Float = 0.542;
	public var xs:Array<Float>;
	private var turnedoff:Bool = false;
	public var max_anim_idx:Int = 0;
	override public function draw():Void 
	{
		
		if (turnedoff || (wm_sx_init && R.access_opts[15])) {
			return;
		}
		//super.draw();
		var cy:Int = Std.int(FlxG.camera.scroll.y);
		var ch:Int = 1;
		//var len:Int = worldmap_grp.length;
		var len:Int = 256;
		//for (i in 0...worldmap_grp.length) {
		for (i in 0...256) {
			
			
			if (wm_sx_init == false) {
				//worldmap_grp.members[i].scale.x = (1.287 - (pxpx * Math.pow((len - i) / len, 1.8)));	
				//worldmap_grp.members[i].scale.x = 1+pxpx - 2*pxpx * ((len - i) / len);
				
				if (wm_sx_a == null || wm_sx_a.length == 0) {
					wm_sx_a = [];
					xs = [];
					Log.trace(xs.length);
				}
					xs.push(1 + pxpx - 2 * pxpx * ((len - i) / len));
				
				if (i == 0) {
					
				//Log.trace(Std.string(100 * (1.0 - sc_lo) / (sc - sc_lo))+ "% from bottom is no-distort line");
					// first get the "distances" from next closest one
					var start:Int = 128;
					
					wm_sx_a.push(0.0);
					for (j in 1...len) {
						//if (j < 128) {
							//var jj:Float = (128 - j) * sc + j;
							//wm_sx_a.push(Math.pow((jj / 128.0), 2));
						//} else {
							//
							//var jj:Float = (j - 128) * sc + j;
							//wm_sx_a.push(Math.pow((jj / 128.0), 2));
						//}
						//wm_sx_a.push(1 + 2*sc - 3 * sc * ((256.0 - j) / 256.0));
						//if (j < 128) {
							//wm_sx_a.push(sc * (j / 256.0) + sc_lo *sc*((128-j)/256.0));
						//} else {
							//wm_sx_a.push(sc * (j / 256.0));
						//}
						// old sc lo: .69
						
						wm_sx_a.push(sc_lo + (sc-sc_lo) * (j / 256.0));
						
						//min: .69, 2.7 ,
						// .69 * 2.7 * .5
						// .93 
						// mid: 1.35
						// max: 2.7
						wm_sx_a[j] += wm_sx_a[j - 1];
					}
					
					for (j in 0...len) {
						if (j != 128) {
						wm_sx_a[j] = wm_sx_a[128] - wm_sx_a[j];
						}
					}
					wm_sx_a[128] = 0;
					
					for (j in 0...len) {
						//if (j < 128) {
							//wm_sx_a[j] *= 1.25;
						//}
						wm_sx_a[j] = Math.round(wm_sx_a[j]);
					}
					
					wm_sx_a.reverse();
					
					//for (j in 128...len-1) {
						//if (wm_sx_a[j] == -2 + wm_sx_a[j + 1]) {
							//for (k in (j + 1)...(len - 1)) {
								//wm_sx_a[k] -= 1;
							//}
						//}
					//}
					
					//Log.trace(wm_sx_a);
					
				}
				
				if (i == len - 1) {
					wm_sx_init = true;
					//Log.trace(xs);
					//Log.trace("wm_sx_ set");
				}
				//worldmap_grp.members[i].y = (ch * i);
				
			}
			
			// 5 5 4 3 2 2 1 1 0 0..
			var a:Int = Std.int(wm_sx_a[i] + cy + 128);
			
			if (i <= 31 || i >= 225) continue;
			
			if (a >= 0 && a <= max_anim_idx) {
				if (cy % 3 == 0 && i%2 == 0 && R.worldmapplayer.velocity.y != 0 && (R.input.up || R.input.down)) {
					//worldmap_grp.members[i].animation.play(Std.string(a+1), true);
					if (a +1 <= max_anim_idx) {
						animation.play(Std.string(a + 1), true);
					}
				} else {
					animation.play(Std.string(a), true);
				}
			}
			origin.x = FlxG.camera.scroll.x + (FlxG.width / 2);
			y = i;
			scale.x = xs[i];	
			super.draw();
		}
	}
}