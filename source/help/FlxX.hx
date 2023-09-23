package help;
import flash.geom.Point;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import haxe.Log;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * Flx Xtra
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class FlxX 
{

	public static var SLOPE_LEFT:Int = 0x10000;
	public static var SLOPE_RIGHT:Int = 0x100000;
	public static var sin_table:Array<Float>;
	public static var cos_table:Array<Float>;

	public static function is_on_screen(o:FlxObject):Bool {
		if (o.x +o.width > FlxG.camera.scroll.x && o.x < FlxG.camera.scroll.x + FlxG.camera.width && o.y < FlxG.camera.scroll.y + FlxG.camera.height && o.y + o.height > FlxG.camera.scroll.y) {
			return true;
		}
		return false;
	}
	
	
	/**
	 * Checks from the point at (x1,y1) if the path to (x2,y2) has no solid tiles. increments by 16 px
	 * @param	x1
	 * @param	x2
	 * @param	y1
	 * @param	y2
	 * @param	tm
	 * @param	max
	 * @return
	 */
	public static function path_is_clear_hor(x1:Float, x2:Float, y1:Float, y2:Float, tm:FlxTilemapExt, max:Float = 300):Bool {	
		var d:Float = 0;
		if (max > 5000) max = 5000;
		while (d < max) {
			if (x1 > x2) {
				x1 -= 16;
				if (x1 < x2) {
					x1 = x2;
				}
			} else {
				x1 += 16;
				if (x1 > x2) {
					x1 = x2;
				}
			}
			if (0 != tm.getTileCollisionFlags(x1, y1)) {
				return false;
			}
			d += 16;
			if (x1 == x2) {
				return true;
			}
		}
		return true;
	}
	
	
	public static function path_is_clear_vert(x1:Float, x2:Float, y1:Float, y2:Float, tm:FlxTilemapExt, max:Float = 300):Bool {	
		var d:Float = 0;
		if (max > 5000) max = 5000;
		while (d < max) {
			if (y1 > y2) {
				y1 -= 16;
				if (y1 < y2) {
					y1 = y2;
				}
			} else {
				y1 += 16;
				if (y1 > y2) {
					y1 = y2;
				}
			}
			if (0 != tm.getTileCollisionFlags(x1, y1)) {
				return false;
			}
			d += 16;
			if (y1 == y2) {
				return true;
			}
		}
		return true;
	}
	
	/**
	 * Given an array of points, return array of points [p1,p2] where p1 is the min x/y vals, p2 ia max
	 * @param	a
	 * @return laaae
	 */
	public static function max_min_point_array(a:Array<Point>):Array<Point> {
		var out_a:Array<Point> = [new Point(), new Point()];
		var init:Bool = false;
		for (i in 0...a.length) {
			if (!init) {
				init = true;
				out_a[0].x = a[0].x; out_a[0].y = a[0].y;
				out_a[1].x = a[0].x; out_a[1].y = a[0].y;
			}
			
			if (a[i].x < out_a[0].x) {
				out_a[0].x = a[i].x;
			}
			if (a[i].x > out_a[1].x) {
				out_a[1].x = a[i].x;
			}
			if (a[i].y < out_a[0].y) {
				out_a[0].y = a[i].y;
			}
			if (a[i].y > out_a[1].y) {
				out_a[1].y = a[i].y;
			}
		}
		return out_a;
	}
	
	public static function l1_norm_from_mid(o1:FlxObject, o2:FlxObject):Float {
		return Math.abs((o1.x + o1.width / 2) - (o2.x + o2.width / 2)) + Math.abs((o1.y + o1.height / 2) - (o2.y + o2.height / 2));
	}
	
	public static function circle_flx_obj_overlap(cx:Float, cy:Float, cr:Float, o:FlxObject):Bool {
		var half_rect_width:Float = o.width / 2;
		var half_rect_height:Float = o.height / 2;
		var cdx:Float = Math.abs(cx - (o.x + o.width/2));
		var cdy:Float = Math.abs(cy - (o.y + o.height/2));
		if (cdx > half_rect_width + cr) return false;
		if (cdy > half_rect_height + cr) return false;
		if (cdx <= half_rect_width) return true;
		if (cdy <= half_rect_height) return true;
		var cds:Float = (cdx - half_rect_width) * (cdx - half_rect_width) + (cdy - half_rect_height) * (cdy - half_rect_height);
		return (cds <= cr * cr);
	}
	/**
	 * Adds new_obj before existing in g , does the bookkeeping for the flxgroup
	 * @param	g
	 * @param	new_obj
	 * @param	existing
	 */
	public static function group_insert_before_Existing(g:FlxGroup, new_obj:FlxObject, existing:FlxObject):Void {
		// FlxGroup bookkeeping
	}
	public static function make_sin_cos_table():Void {
		if (sin_table == null) {
			sin_table = [];
			cos_table = [];
			var rad:Float = 0;
			var radslice:Float = (Math.PI * 2) / 360.0;
			for (i in 0...360) {
				sin_table.push(Math.sin(rad));
				cos_table.push(Math.cos(rad));
				rad += (radslice);
			}
		}
	}
	public static function point_inside_group_member(_x:Float, _y:Float, group:Dynamic):Bool {
		var o:FlxObject = null;
		for (i in 0...group.length) {
			o = group.members[i];
			if (o != null) {
				if ((_x > o.x) && (_x < o.x + o.width) && (_y > o.y) && (_y < o.y + o.height)) {
					return true;
				}
			}
		}
		return false;
	}
	public static function point_inside_list_member(_x:Float, _y:Float, _list:List<Dynamic>):Bool {
		for (o in _list.iterator()) {
			if ((_x > o.x) && (_x < o.x + o.width) && (_y > o.y) && (_y < o.y + o.height)) {
				return true;
			}
		}
		return false;
	}
	public static function point_inside(_x:Float, _y:Float, o:FlxObject):Bool {
		if ((_x > o.x) && (_x < o.x + o.width) && (_y > o.y) && (_y < o.y + o.height)) {
			return true;
		}
		return false;
	}
	public static function indexOf(g:Dynamic,b:Dynamic):Int {
		for (i in 0...g.members.length) {
			if (g.members[i] == b) {
				return i;
			}
		}
		return -1;
	}
	
	public static function align_group_to_object(g:FlxTypedGroup<FlxSprite>,x:Int,y:Int):Void {
		
		for (i in 0...g.length) {
			if (g.members[i] != null) {
				g.members[i].x += x;
				g.members[i].y += y;
			}
		}
	}
	
		static public function createEmptyCSV(width:Int, height:Int,data:Int=0):String {
var i:Int = 0;
var j:Int = 0;
var s:String = "";
var d:String = Std.string(data);
var row:String = "";
var nlrow:String = "";
for (j in 0...width) {
	row += d;
	if (j != width - 1) {
		row += ",";
	}
}
nlrow = row;
nlrow += "\n";
//Log.trace(width);
//Log.trace(height);
for (i in 0...height) {
	if (i != height - 1) {
		s += nlrow;
	} else {
		s += row;
	}
}
return s;
}
	
}