package entity.util;
import entity.MySprite;
import flixel.FlxObject;
import global.EF;
import haxe.Log;
import help.FlxX;
import help.HF;
import help.WMDrawSprite;
import state.MyState;
import help.AnimImporter;
import flixel.FlxG;
import flixel.FlxSprite;
import state.TestState;

class WMScaleSprite extends MySprite
{

	
	private var name_id:String = "";
	private var fg_sprite:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		fg_sprite = new FlxSprite();
		super(_x, _y, _parent, "WMScaleSprite");
		
	}
	
	override public function change_visuals():Void 
	{
		AnimImporter.loadGraphic_from_data_with_id(this, -1, -1, "WMScaleSprite", name_id);
		AnimImporter.loadGraphic_from_data_with_id(fg_sprite, -1, -1, "WMScaleSprite", name_id);
		animation.play("0");
		fg_sprite.animation.play("0");
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("name_id", "test");
		p.set("bottom", 1);
		p.set("h", 20);
		p.set("collidable", 1);
		p.set("oscillate", 0);
		return p;
	}
	
	private var t_osc:Float = -1;
	private var ctr_osc:Int = 0;
	public var is_bottom:Bool = false;
	private var collides:Bool = false;
	
	private var dontdraw:Bool = false;
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		name_id = props.get("name_id");
		name_id = name_id.toLowerCase();
		is_bottom = props.get("bottom") == 1;
		change_visuals();
		height = props.get("h");
		if (props.get("oscillate") > 0) {
			t_osc = 0;
		}
		
		if (name_id == "earth_geome") {
			if (R.TEST_STATE.MAP_NAME == "MAP1") {
				visible = false;
				if (R.event_state[EF.g2_1_ID] > 3) visible = true;
				if (0 != R.event_state[EF.river_done]) visible = false;
			} else {
				if (1 == R.event_state[EF.earth_done]) visible = false;
			}
		}
		if (name_id == "sea_geome") {
			if (R.TEST_STATE.MAP_NAME == "MAP1") {
				visible = false;
				if (R.event_state[EF.g2_1_ID] > 3) visible = true;
				if (0 != R.event_state[EF.forest_done]) visible = false;
			} else {
				if (1 == R.event_state[EF.sea_done]) visible = false;
			}
		}	
		if (name_id == "air_geome") {
			if (R.TEST_STATE.MAP_NAME == "MAP1") {
				visible = false;
				if (R.event_state[EF.g2_1_ID] > 3) visible = true;
				if (0 != R.event_state[EF.woods_done]) visible = false;
			} else {
				if (1 == R.event_state[EF.air_done]) visible = false;
			}
		}
		dontdraw = !visible; // need two vars for handling editor debug view
		visible = true;
		
		if (is_bottom) {
			offset.y = frameHeight - height;
		} else {
			offset.y = 0;
		}
		
		if (is_bottom) {
			origin.set(width / 2, frameHeight);
		} else {
			origin.set(width / 2, 0);
		}
		
		
		fg_sprite.height = height;
		fg_sprite.offset.y = offset.y;
		fg_sprite.origin.set(origin.x, origin.y);
		
		collides = props.get("collidable") == 1;
		
		immovable = true;
	}
	
	override public function destroy():Void 
	{
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [fg_sprite],4);
		super.destroy();
	}
	
	private var mode:Int = 0;
	private var wm:WMDrawSprite;
	override public function update(elapsed: Float):Void 
	{
		if (t_osc > -1) {
			t_osc += elapsed;
			if (t_osc > 0.033) {
				t_osc -= 0.033;
				ctr_osc += 3;
				if (ctr_osc >= 360) ctr_osc = 0;
			}
		}
		
		if (!did_init) {
			did_init = true;
			fg_sprite.visible = false;
			HF.add_list_to_mysprite_layer(this, parent_state, [fg_sprite], 4);
		}
		
		if (mode == 0) {
			var ts:TestState = cast parent_state;
			if (ts.worldmap_grp.members[0] != null) {
				wm = ts.worldmap_grp.members[0];
				if (wm.wm_sx_a != null && wm.wm_sx_a.length > 0) {
					mode = 1;
				}
			}
		}
		if (collides) {
			FlxObject.separate(this, R.worldmapplayer);
		}
		super.update(elapsed);
	}
	override public function draw():Void 
	{
		if (dontdraw && !R.editor.editor_active) {
			return;
		}
		if (mode == 0 || R.editor.editor_active || R.access_opts[15]) {
			super.draw();
			if (R.access_opts[15]) {
				if (fg_sprite != null) fg_sprite.visible = false;
			}
		} else if (mode == 1) {
			
			var oiy:Float = iy;
			if (t_osc > -1){
				y = iy + props.get("oscillate") * FlxX.sin_table[ctr_osc];
				iy = Std.int(y);
			}
			
			var oy:Float = y;
			var ox:Float = x;
			
			
				set_wmscale(this, wm, is_bottom);
				//Log.trace(wm.xs[idx]);
				//Log.trace(x);
			//}
			// wont work with other sprtes..
			if (R.gs1 != 245 && is_bottom && R.worldmapplayer.y + R.worldmapplayer.height < y + height) {
				fg_sprite.y = y;
				fg_sprite.x = x;
				fg_sprite.scale.set(scale.x, scale.y);
				fg_sprite.visible = true;
			} else {
				fg_sprite.visible = false;
				super.draw();
			}
			y = oy;
			x = ox;
			iy = Std.int(oiy);
			scale.set(1, 1);
		}
	}
	
	//if is not is bottom e, then as it moves towards the BOTTOM it should get *bigger*
	public static function set_wmscale(s:MySprite, wm:WMDrawSprite, is_bottom:Bool = true):Void {
			//if (is_bottom) {
				s.y = s.iy;
				var by:Float = s.y + s.height;
				if (!is_bottom) by = s.y;
				var cy:Float = FlxG.camera.scroll.y;
				var idx:Int = 128;
				var hi_idx:Int = 255;
				var lo_idx:Int  = 0;
				// Don't draw if out of the bounds
				if (by < cy + wm.wm_sx_a[0] + 128) { // doesnt work for all !is_bottom
					idx = 0;
				} else if (is_bottom && by - s.frameHeight > cy + wm.wm_sx_a[255] + 128) {
					idx = 255;
				} else if (!is_bottom && by > cy + wm.wm_sx_a[255] + 128) {
					idx = 255;
				// figure out how to deal when the bottom is past the bottom of the array but sprite still on scren
				} else if (is_bottom && by > cy + wm.wm_sx_a[255] + 128) {
					
					idx = 255;
				// find where the obttom corresponds to in the array and draw from there
				} else {
					for (i in 0...9) {
						if (by < cy + wm.wm_sx_a[idx] + 128) {
							hi_idx = idx;
							idx = Std.int(lo_idx + (idx - lo_idx) / 2);
						} else {
							lo_idx = idx;
							idx = Std.int(idx + (hi_idx - idx) / 2);
						}
					}
					if (!is_bottom) {
						s.y = cy + idx;
					} else {
						s.y = cy + idx - s.height;
					}
				}
				s.scale.set(1 + 0.35 * ((idx - 128) / 128.0), 1 + 0.35 * ((idx - 128) / 128.0));
				
				if (!is_bottom) {
					s.scale.x = wm.xs[idx] + 0.01;
					s.scale.y = s.scale.x;
					//Log.trace(s.scale.x);
				}
				// wm.xs is how much each row is scaled
				s.x = FlxG.camera.scroll.x + 208 + (((s.ix + s.width / 2) - (FlxG.camera.scroll.x + 208)) * wm.xs[idx]);
				s.x -= s.width / 2;
				
				//if bottom out of map, then keep the sprite moving/scaling so things don't lok weird
				if (is_bottom && by > cy + wm.wm_sx_a[255] + 128 && by - s.frameHeight <= cy + wm.wm_sx_a[255] + 150) {
					var a:Float = (by - (cy + wm.wm_sx_a[255] + 128));
					s.y = cy + 255 - s.height + 1.05*a; //mb scael last factor
					s.scale.x += a * 0.001;
					s.scale.y += a * 0.001;
					
					// increase the x-position scaling here by an arbitrary amt (0.1 *...)
					var coeff:Float = 1 + 0.1 * (a / 100.0);
					s.x = FlxG.camera.scroll.x + 208 + (((s.ix + s.width / 2) - (FlxG.camera.scroll.x + 208)) * coeff*wm.xs[idx]);
					s.x -= s.width / 2;
				}
	}
	
}