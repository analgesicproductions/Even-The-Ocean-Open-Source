package entity.util;
import entity.MySprite;
import flash.geom.Point;
import flixel.addons.tile.FlxTilemapExt;
import haxe.Log;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import flixel.FlxObject;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class TileFader extends MySprite
{

	private var tilemap:FlxTilemapExt;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		tilemap = new FlxTilemapExt();
		super(_x, _y, _parent, "TileFader");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				makeGraphic(16, 16, 0xff993402);
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		//p.set("data", "_");
		return p;
	}

	
	private var coords:Array<Point>;
	private var bound_obj:FlxObject;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		
		coords = [];
		HF.copy_props(p, props);
		
		//Log.trace(coords);
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		// If in a fading mode set the tilemap back to normal
		if (mode != 0) {
			for (i in 0...coords.length) {
				var p:Point = coords[i];
				parent_state.tm_fg.setTile(Std.int((x + p.x * 16) / 16), Std.int((y + p.y * 16) / 16), tilemap.getTile(Std.int(p.x - min_max[0].x), Std.int(p.y - min_max[0].y)), true);
			}
		}
		HF.remove_list_from_mysprite_layer(this, parent_state, [tilemap]);
		super.destroy();
	}
	
	private var mode:Int = 0;
	private var min_max:Array<Point>;
	override public function update(elapsed: Float):Void 
	{
		
		
		if (!did_init) {
			did_init = true;
			
			var queue:Array<String> = [];
			var startstr:String = Std.string(Std.int(x / 16)) + "," + Std.string(Std.int(y / 16));
			queue.push(startstr);
			var checked:Array<String> = [startstr];
			var tmap:FlxTilemapExt = parent_state.tm_fg;
			
			while (queue.length > 0) {
				var next:String = queue.pop();
				var sx:Int = Std.parseInt(next.split(",")[0]);
				var sy:Int = Std.parseInt(next.split(",")[1]);
				var tile_id:Int;
				var might_push:String = "";
				if (sx + 1 < tmap.widthInTiles) {
					tile_id = tmap.getTile(sx + 1, sy);
					if (tile_id != 0) {
						might_push = Std.string(sx + 1) + "," + Std.string(sy);
						if (HF.array_contains(checked, might_push) == false) {
							queue.push(might_push);	
							checked.push(might_push);
						}
					}
				}
				if (sx - 1 >= 0) {
					tile_id = tmap.getTile(sx -1, sy);
					if (tile_id != 0) {
						might_push = Std.string(sx - 1) + "," + Std.string(sy);
						if (HF.array_contains(checked, might_push) == false) {
							queue.push(might_push);	
							checked.push(might_push);
						}
					}
				}
				if (sy + 1 < tmap.heightInTiles) {
					tile_id = tmap.getTile(sx, sy+1);
					if (tile_id != 0) {
						might_push = Std.string(sx) + "," + Std.string(sy + 1);
						if (HF.array_contains(checked, might_push) == false) {
							queue.push(might_push);	
							checked.push(might_push);
						}
					}
				}
				if (sy - 1 >= 0) {
					tile_id = tmap.getTile(sx , sy-1);
					if (tile_id != 0) {
						might_push = Std.string(sx) + "," + Std.string(sy - 1);
						if (HF.array_contains(checked, might_push) == false) {
							queue.push(might_push);	
							checked.push(might_push);
						}
					}
				}
			}
			var coords_str:String = "";
			var start_x:Int = Std.int(x / 16);
			var start_y:Int  = Std.int(y / 16);
			for (i in 0...checked.length) {
				
				if (i == checked.length - 1) {
					coords_str += Std.string(Std.parseInt(checked[i].split(",")[0]) - start_x) + "," + Std.string(Std.parseInt(checked[i].split(",")[1]) - start_y);
				} else {
					coords_str += Std.string(Std.parseInt(checked[i].split(",")[0]) - start_x) + "," + Std.string(Std.parseInt(checked[i].split(",")[1]) - start_y) + ",";
				}
			}
			coords = HF.string_to_point_array(coords_str);
			min_max = FlxX.max_min_point_array(coords);
			var w:Int = Std.int(min_max[1].x - min_max[0].x) + 1;
			var h:Int = Std.int(min_max[1].y - min_max[0].y) + 1;
			tilemap.loadMapFromCSV(FlxX.createEmptyCSV(w, h), HelpTilemap.current_tileset_bitmap, 16, 16);
			tilemap.x = x + min_max[0].x * 16;
			tilemap.y = y + min_max[0].y * 16;
			bound_obj = new FlxObject(tilemap.x, tilemap.y, w * 16, h * 16);
			HF.add_list_to_mysprite_layer(this, parent_state, [tilemap]);
			bound_obj.x = tilemap.x;
			bound_obj.y = tilemap.y;
		}
		
		if (R.editor.editor_active) {
			visible = true;
			// Prevent saving the "faded" map data
			if (mode == 2 || mode ==1)  {
				for (i in 0...coords.length) {
					var p:Point = coords[i];
					parent_state.tm_fg.setTile(Std.int((x + p.x * 16) / 16), Std.int((y + p.y * 16) / 16), tilemap.getTile(Std.int(p.x - min_max[0].x), Std.int(p.y - min_max[0].y)), true);
				}
				tilemap.alpha = 1;
				mode = 0;
			}
			super.update(elapsed);
			return;
		} else {
			visible = false;
		}
		if (mode == 0) {
			//tilemap.alpha = Math.min(1, tilemap.alpha + 0.01);
			//tilemap.alpha = 0;
			if (bound_obj.overlaps(R.player)) {
				mode = 1;
				tilemap.visible = true;
				for (i in 0...coords.length) {
					var p:Point = coords[i];
					// tilemap coords are shifted
					// points are relative to the tilefade ix,iy
					tilemap.setTile(Std.int(p.x - min_max[0].x), Std.int(p.y - min_max[0].y), parent_state.tm_fg.getTileID(x + p.x * 16, y + p.y * 16), true);
					parent_state.tm_fg.setTile(Std.int((x + p.x * 16) / 16), Std.int((y + p.y * 16) / 16), 0, true);
				}
			}
		} else if (mode == 1) {
			tilemap.alpha = Math.max(tilemap.alpha - 0.025, 0);
			if (bound_obj.overlaps(R.player) == false) {
				mode = 2;
				
			}
		} else if (mode == 2) {
			tilemap.alpha = Math.min(1, tilemap.alpha + 0.025);
			if (bound_obj.overlaps(R.player)) {
				mode = 1;
			} else if (tilemap.alpha == 1) {
				tilemap.visible = false;
				for (i in 0...coords.length) {
					var p:Point = coords[i];
					parent_state.tm_fg.setTile(Std.int((x + p.x * 16) / 16), Std.int((y + p.y * 16) / 16), tilemap.getTile(Std.int(p.x - min_max[0].x), Std.int((p.y)- min_max[0].y)), true);
				}
				mode = 0;
			}
		}
		super.update(elapsed);
	}
}