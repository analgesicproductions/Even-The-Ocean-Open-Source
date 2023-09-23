package entity.player;

import global.Registry;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import state.MyState;
import state.TestState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Swapper extends FlxGroup
{

	private var first_grid:FlxSprite;
	private var second_grid:FlxSprite;
	
	private var gun_state:Int = 0;
	private var first_state:Int = 0;
	private var second_state:Int = 0;
	private var parent:TestState;
	private var R:Registry;
	
	private var dir:Int = 0;
	private var t_invisible:Float = 0;
	public function new(_t:TestState,_r:Registry)
	{
		super();
		
		R = _r;
		parent = _t;
		first_grid = new FlxSprite();
		second_grid = new FlxSprite();
		first_grid.makeGraphic(16, 16, 0xbbff0000);
		second_grid.makeGraphic(16, 16, 0xbbff0000);
		add(first_grid);
		add(second_grid);
		
		first_grid.exists = false;
		second_grid.exists = false;
	}
	
	
	override public function update(elapsed: Float):Void {
		
		
		if (gun_state == 0) {
			if (R.input.left || R.input.right || R.input.down || R.input.up) {
				gun_state = 1;
				first_grid.exists = second_grid.exists = true;
			}
			
		} else if (gun_state == 1 || gun_state == 2) {
			if (t_invisible > 3 && gun_state == 1) {
				t_invisible = 0;
				gun_state = 0;
				first_grid.exists = second_grid.exists = false;
			} else {
				
				if (!R.input.a2) {
					if (R.input.up) {
						dir = 0;t_invisible = 0;
					} else if (R.input.down) {
						dir = 2;t_invisible = 0;
					} else if (R.input.right) {
						dir = 1; t_invisible = 0;
					} else if (R.input.left) {
						dir = 3;t_invisible = 0;
					} 
				} else {
					if (R.input.a2) {
						
					} else if (!(R.input.left || R.input.right || R.input.down || R.input.up)) {
						t_invisible += FlxG.elapsed;
					}
				}
				
				switch (dir) {
					case 0:
						second_grid.x = R.player.x + 4;
						second_grid.y = R.player.y - 10;
					case 1:
						second_grid.x = R.player.x + 20;
						second_grid.y = R.player.y + 10;
					case 2:
						second_grid.x = R.player.x + 4;
						second_grid.y = R.player.y + R.player.height + 4;
					case 3:
						second_grid.x = R.player.x - 5;
						second_grid.y = R.player.y + 10;
				}
			
				second_grid.x = second_grid.x - (second_grid.x % 16);
				second_grid.y = second_grid.y - ( second_grid.y % 16);
				if (gun_state == 1) {
					first_grid.x = second_grid.x;
					first_grid.y = second_grid.y;
				}
				
				
				if (R.input.jpA2) {
					if (gun_state == 1) {
						gun_state = 2;
					} else {
						gun_state = 3;
					}
				}
			}
			
		} else if (gun_state == 3) {
			
			var a:Array<FlxTilemapExt> = parent.get_tilemaps();
			
			var t:FlxTilemapExt;
			for (i in 0...a.length) {
				t = a[i];
				var tt:Int = t.getTileID(first_grid.x, first_grid.y);
				t.setTile(Std.int(first_grid.x / 16), Std.int(first_grid.y / 16), t.getTileID(second_grid.x, second_grid.y));
				t.setTile(Std.int(second_grid.x / 16), Std.int(second_grid.y / 16), tt);
				
			}
			
			gun_state = 0;
		}
	}
}