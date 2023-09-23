package help;
import haxe.Log;
import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class AnimTileEngine
{

	public function new() 
	{
		
	}
	
	public function reset():Void {
		bg_ts = [];
		bg_tms = [];
		bg_originals = [];
		bg_indices = [];
		bg_lengths = [];
		bg_anims = [];
		bg_cur_anim_indices = [];
		nr_bg_tiles = 0;
		layer_ids = [];
	}
	
	public function load_maps(_tm_bg:FlxTilemapExt,_tm_bg2:FlxTilemapExt):Void {
		tm_bg = _tm_bg;
		tm_bg2 = _tm_bg2;
		
	}
	
	public function add_tile(index:Int, anim:Array<Int>, frame_rate:Int,layer_id:Int,is_random:Bool=false):Void {
	
		if (is_random) {
			var r:Int = Std.int(anim.length * Math.random());
			bg_cur_anim_indices.push(r);
		} else {
			bg_cur_anim_indices.push(0);
		}
		if (HF.array_contains(bg_indices, layer_id) ) {
			remove_tile(index,layer_id);
		}
		bg_indices.push(index);
		if (layer_id == MyState.LDX_BG) {
			bg_originals.push(tm_bg.getTileByIndex(index));
		} else if (layer_id == MyState.LDX_BG2) {
			bg_originals.push(tm_bg2.getTileByIndex(index));
		}
		bg_lengths.push(anim.length);
		bg_tms.push(1.0 / frame_rate);
		bg_ts.push(-1);
		bg_anims.push(anim);
		layer_ids.push(layer_id);
		nr_bg_tiles ++;
	}
	
	public function remove_tile(index:Int,layer_id:Int=-1) {
		for (i in 0...nr_bg_tiles) {
			if (bg_indices[i] == index) {
				if (layer_id == layer_ids[i]) {
					bg_indices.splice(i, 1);
					bg_lengths.splice(i, 1);
					bg_tms.splice(i, 1);
					bg_originals.splice(i, 1);
					bg_ts.splice(i, 1);
					bg_cur_anim_indices.splice(i, 1);
					bg_anims.splice(i, 1);
					layer_ids.splice(i, 1);
					nr_bg_tiles --;
				}
			}
		}
	}
	
	public function get_anim_tile_ID_if_exists(index:Int, layer_id:Int = -1):Int {
		for (i in 0...nr_bg_tiles) {
			if (bg_indices[i] == index) {
				if (layer_id == layer_ids[i]) {
					return bg_originals[i];
				}
			}
		}
		return -1;
	}
	
	/**
	 * Set animated tiles back to their original state, so when you save, you don't
	 * get some mucked up tiles
	 */
	public function re_init_maps():Void {
		for (i in 0...nr_bg_tiles) {
			if (layer_ids[i] == MyState.LDX_BG) {
				tm_bg.setTileByIndex(bg_indices[i], bg_originals[i], true);
			} else if (layer_ids[i] == MyState.LDX_BG2) {
				tm_bg2.setTileByIndex(bg_indices[i], bg_originals[i], true);
			}
		}
	}
	private var tm_bg:FlxTilemapExt;
	private var tm_bg2:FlxTilemapExt;
	private var bg_originals:Array<Int>;
	private var bg_anims:Array<Array<Int>>;
	private var bg_lengths:Array<Int>;
	private var bg_cur_anim_indices:Array<Int>;
	private var bg_indices:Array<Int>;
	private var bg_ts:Array<Float>;
	private var bg_tms:Array<Float>;
	private var nr_bg_tiles:Int;
	private var layer_ids:Array<Int>;
	public var pls_wait:Int = 0;
	public var do_nothing:Bool = false;
	public function update(elapsed: Float):Void {
		if (do_nothing) return;
		if (pls_wait > 0) {
			pls_wait --;
			return;
		}
		var step:Float = FlxG.elapsed;
		for (i in 0...nr_bg_tiles) {
			bg_ts[i] -= step;
			if (bg_ts[i] < 0) {
				bg_ts[i] = bg_tms[i];
				if (bg_cur_anim_indices[i] == bg_lengths[i] - 1) {
					bg_cur_anim_indices[i] = 0;
				} else {
					bg_cur_anim_indices[i] ++;
				}
				
				if (layer_ids[i] == MyState.LDX_BG) {
					tm_bg.setTileByIndex(bg_indices[i], bg_anims[i][bg_cur_anim_indices[i]], true);
				} else if (layer_ids[i] == MyState.LDX_BG2) {
					tm_bg2.setTileByIndex(bg_indices[i], bg_anims[i][bg_cur_anim_indices[i]], true);
				}
			}
		}
	}
}