package entity.npc;
/**
 * A stripped down generic npc, just idles or whatever
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import entity.MySprite;
import flash.display.BitmapData;
import flixel.FlxObject;
import flixel.FlxSprite;
import global.EF;
import haxe.Log;
import help.FlxX;
import help.HF;
import openfl.Assets;
import openfl.display.BlendMode;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import state.MyState;
import flixel.FlxG;

class SetPiece extends MySprite
{
	
	
	private var drag_box:FlxSprite;
	private var frame_obj:FlxObject;
	private var alpha_a:Array<Float>;
	private var scale_x_a:Array<Float>;
	private var scale_y_a:Array<Float>;
	private var x_a:Array<Float>;
	private var y_a:Array<Float>;
	

	private var scale_amp:Float = 0;
	private var alpha_amp:Float = 0;
	private var angle_amp:Float = 0;
	private var sin_scale_ctr:Float = 0;
	private var sin_scale_tpf:Float = 0;
	private var sin_alpha_ctr:Float = 0;
	private var sin_alpha_tpf:Float = 0;
	private var sin_angle_tpf:Float = 0;
	private var sin_angle_ctr:Float = 0;
	private var scale_start:Float = 0;
	private var alpha_start:Float = 0;
	private var angle_start:Float = 0;
	
	private var x_amp:Float = 0;
	private var sin_x_ctr:Float = 0;
	private var sin_x_tpf:Float = 0;
	private var x_start:Float = 0;
	
	private var y_amp:Float = 0;
	private var sin_y_ctr:Float = 0;
	private var sin_y_tpf:Float = 0;
	private var y_start:Float = 0;
	
	
	public var editor_drag_box:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		tile_size  = new Point();
	
		under_sprite = new FlxSprite();
		over_sprite = new FlxSprite();
		drag_box = new FlxSprite();
		drag_box.makeGraphic(16, 16, 0xffff0000);
	
		editor_drag_box = new FlxSprite();
		if (TYPES == null) {
			TYPES = GenericNPC.generic_npc_data.get("_SetPiece").get("types").get("types").split(",");
		}
		super(_x, _y, _parent, "SetPiece");
	}
	
	// Set through the editor
	public static var TYPES:Array<String>;
	public static var TYPE_INDEX:Int = 0;
	public static var ITEM_INDEX:Int = 0;
	public static var MIRRORED:Bool = false;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("TYPE", TYPES[TYPE_INDEX]);
		p.set("id", ITEM_INDEX);
		p.set("mirrored", MIRRORED ? 1 : 0);
		p.set("blend_1ad2mu3sc", -1);
		p.set("fades_when_overlap", 0);
		p.set("is_tileable", 0);
		p.set("fade_with_entire_sprite", 0);
		
		p.set("tile_size", "0,0");
		p.set("tiling_y_off", 0);
		p.set("auto_scrolls", 0);
		p.set("auto_scroll_dir", 0);
		p.set("auto_scroll_fps", 15);
		
		p.set("border_shrink", 0);
		return p;
	}

	private var is_tileable:Bool = false;
	private var tile_size:Point;
	private var tiling_y_off:Int;
	private var auto_scroll_dir:Int = 0;
	private var auto_scroll_fps:Int = 0;
	private var t_autoscroll:Float = 0;
	private var under_frame:Int = 0;
	public var under_sprite:FlxSprite;
	private var over_frame:Int = 0;
	public var over_sprite:FlxSprite;
	
	public function update_properties(type:Int, id:Int, mirror:Bool):Void {
		props.set("TYPE", TYPES[type]);
		props.set("id", id);
		props.set("mirrored", mirror ? 1 : 0);
	}
	private var set_prop_index:Int = 0;
	private var has_metadata_asf:Bool = false;
	private var fades:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		// reset scrolly animation if needed (wait will be > 0) 
		if (wait > 0) {
			FlxG.bitmap.removeByKey(graphic.key);
		}
		changevis();
		set_prop_index++;
		
		//
		auto_scroll_dir = props.get("auto_scroll_dir");
		if (auto_scroll_dir > 7 || auto_scroll_dir < 0) {
			auto_scroll_dir = 0;
		}
		if (!has_metadata_asf) auto_scroll_fps = props.get("auto_scroll_fps");
		has_metadata_asf = false;
		if (wait > 0) {
			make_loop_anim();
		}
		//
		
		
		fades = props.get("fades_when_overlap") == 1;
		tiling_y_off = props.get("tiling_y_off");
		tile_size.x = Std.parseInt(props.get("tile_size").split(",")[0]);
		tile_size.y = Std.parseInt(props.get("tile_size").split(",")[1]);
		is_tileable = props.get("is_tileable") == 1;
		autoscrolls = props.get("auto_scrolls") == 1;
		
		var bs:Int = Std.int(props.get("border_shrink") * 16);
		if (bs < 0 || bs > 640) {
			bs = 0;
			props.set("border_shrink", 0);
		}
		bshrink = bs;
		frame_obj = new FlxObject(ix + bs, iy + bs, frameWidth - bs * 2, frameHeight - bs * 2);
		if (camobj == null) camobj = new FlxObject(0, 0, 432 + 64, 256 + 64);
		if (sizeobj == null) sizeobj = new FlxObject(0, 0, 432 + 64, 256 + 64);
		
		if (R.TEST_STATE.MAP_NAME == "WF_HI_1" && R.event_state[EF.radio_depths_done] == 1 && props.get("TYPE") == "group0" && (props.get("id") == 1 || props.get("id") == 0)) {
			Log.trace("Turn off fountain in wf _hi 1 after radio depths");
			visible = false;
		}
	}
	private var bshrink:Int = 0;
	
	public var camobj:FlxObject;
	private var sizeobj:FlxObject;
	private var wait:Int = 0;
	private var autoscrolls:Bool = false;
	override public function sleep():Void 
	{
		Log.trace("sleep");
	}
	override public function update(elapsed: Float):Void 
	{
	
		
		if (under_sprite != null) {
			under_sprite.move(x, y);
		}
		if (over_sprite != null) {
			over_sprite.move(x, y);
			if (over_sprite.ID == 60) {
				over_sprite.ID = 0;
				HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [over_sprite],true);
			}
		}
		
		
		if (!did_init) {
			did_init = true;
			ID = 0;
			HF.add_list_to_mysprite_layer(this, parent_state, [drag_box]);
		}
		
			if (null != animation.curAnim) {
				if (alpha_a != null) {	
					if (animation.curAnim.curFrame + 1 <= alpha_a.length) {
						alpha = alpha_a[animation.curAnim.curFrame];
					}
				}
				if (scale_x_a != null) {
					if (animation.curAnim.curFrame + 1 <= scale_x_a.length) {
						scale.x = scale_x_a[animation.curAnim.curFrame];
					}
				}
				if (scale_y_a != null) {
					if (animation.curAnim.curFrame + 1 <= scale_y_a.length) {
						scale.y = scale_y_a[animation.curAnim.curFrame];
					}
				}
			}
		
		if (autoscrolls) {
			
			t_autoscroll += elapsed;
			if (t_autoscroll > 1.0 / auto_scroll_fps) {
				t_autoscroll -= (1.0 / auto_scroll_fps);
				if (auto_scroll_dir >= 1 && auto_scroll_dir <= 3) {
					frame.frame.x -= 2;
					if (frame.frame.x <= 0) {
						frame.frame.x += frameWidth;
					}
				}
				if (auto_scroll_dir >= 5 && auto_scroll_dir <= 7) {
					frame.frame.x += 2;
					if (frame.frame.x >= frameWidth) {
						frame.frame.x -= frameWidth;
					}
				}
				if (auto_scroll_dir >= 7 || auto_scroll_dir <= 1) {	
					frame.frame.y += 2;
					if (frame.frame.y >= frameHeight) {
						frame.frame.y -= frameHeight;
					}

				}
				if (auto_scroll_dir <=5 && auto_scroll_dir >= 3) {
					frame.frame.y -= 2;
					if (frame.frame.y <= 0) {
						frame.frame.y += frameHeight;
					}
				}
			}
			
			camobj.x = FlxG.camera.scroll.x - 32;
			camobj.y = FlxG.camera.scroll.y - 32;
			sizeobj.x = x;
			sizeobj.y = y;
			sizeobj.width = tile_size.x;
			sizeobj.height = tile_size.y;
			if (width > sizeobj.width) sizeobj.width = width;
			if (height > sizeobj.height) sizeobj.height = height;
			
			if (!asleep && camobj.overlaps(sizeobj) == false) {
				if (R.TEST_STATE.MAP_NAME == "MAP3" || R.TEST_STATE.MAP_NAME == "MAP1") {
					
				} else {
					asleep = true;
				}
				//Log.trace("sleep");
			} else {
				if (camobj.overlaps(sizeobj)) {
					asleep = false;
				}
			}
		
			//does_proximity_sleep = true;
			if (wait <2) {
				wait ++;
			} else if (wait == 2) {
				wait++;
				make_loop_anim();
			}
		}
		
		//Log.trace([x, y]);
		
		editor_drag_box.x = x;
		editor_drag_box.y = y;
		if (fades && frame_obj != null) {
			
			frame_obj.x = ix + bshrink;
			frame_obj.y = iy + bshrink;
			//Log.trace([x,y,offset.x]);
			//Log.trace([frame_obj.x, frame_obj.y, frame_obj.width]);
			// fade w/ whole sprite sometimes or not
			if ((props.get("fade_with_entire_sprite") == 0 && R.player.overlaps(editor_drag_box)) || (props.get("fade_with_entire_sprite") == 1 && R.player.overlaps(frame_obj))) {
				if (alpha > 0) {
					alpha -= 0.03;
					alpha *= 0.98;
					if (alpha < 0) alpha = 0;
 				}
			} else {
				if (alpha < 1) {
					alpha += 0.03;
					alpha *= 1.03;
					if (alpha > 1) alpha = 1;
				}
			}
		}
		
		if (is_tileable) {
			if (ID == 0) {
				drag_box.x = x + tile_size.x - drag_box.width;
				drag_box.y = y + tile_size.y - drag_box.height;
				if (FlxG.mouse.justPressed) {
					if (FlxG.mouse.inside(drag_box)) {
						ID = 1;
					}
				}
			} else if (ID == 1) {
				drag_box.x = Std.int(FlxG.mouse.x);
				drag_box.y = Std.int(FlxG.mouse.y);
				
				tile_size.x = Std.int(drag_box.x + drag_box.width - x);
				tile_size.y = Std.int(drag_box.y + drag_box.height - y);
				
				if (tile_size.x < 16) {
					tile_size.x = 16;
					drag_box.x = x + 16 - drag_box.width;
				}
				if (tile_size.y < 16) {
					tile_size.y = 16;
					drag_box.y = y + 16 - drag_box.height;
				}
				
				if (!FlxG.mouse.pressed) {
					props.set("tile_size", Std.string(tile_size.x) + "," + Std.string(tile_size.y ));
					ID = 0;
				}
			}
		}
		
		
		
		super.update(elapsed);
	}
	override public function draw():Void 
	{
		if (asleep) return;
		editor_drag_box.alpha = alpha;
		if (is_tileable) {
			var ox:Float = x;
			var oy:Float = y;
			y += tiling_y_off;
			for (i in 0...Std.int(tile_size.y / frameHeight)) {
				for (j in 0...Std.int(tile_size.x / frameWidth)) {
					super.draw();
					x += frameWidth;
				}
				y += frameHeight;
				x = ox;
			}
			y = oy;
			x = ox;
			
			
		} else {
			if (sin_scale_ctr > -1) {
				sin_scale_ctr += sin_scale_tpf;
				if (sin_scale_ctr > 360.0) {
					sin_scale_ctr -= 360.0;
				}
				scale.x = scale.y = scale_start + scale_amp * FlxX.sin_table[Std.int(sin_scale_ctr)];
			}
			if (sin_alpha_ctr > -1) {
				sin_alpha_ctr += sin_alpha_tpf;
				if (sin_alpha_ctr > 360.0) {
					sin_alpha_ctr -= 360.0;
				}
				alpha = alpha_start + alpha_amp * FlxX.sin_table[Std.int(sin_alpha_ctr)];
			}
			if (sin_angle_ctr > -1) {
				sin_angle_ctr += sin_angle_tpf;
				if (sin_angle_ctr > 360.0) {
					sin_angle_ctr -= 360.0;
				}
				angle = angle_start + angle_amp * FlxX.sin_table[Std.int(sin_angle_ctr)];
			}
			if (sin_x_ctr > -1) {
				sin_x_ctr += sin_x_tpf;
				if (sin_x_ctr > 360.0) {
					sin_x_ctr -= 360.0;
				}
				x = ix+ x_start + x_amp * FlxX.sin_table[Std.int(sin_x_ctr)];
			}
			if (sin_y_ctr > -1) {
				sin_y_ctr += sin_y_tpf;
				if (sin_y_ctr > 360.0) {
					sin_y_ctr -= 360.0;
				}
				y = iy+ y_start + y_amp * FlxX.sin_table[Std.int(sin_y_ctr)];
			}
			super.draw();
		}
		if (R.editor.editor_active) {
			editor_drag_box.draw();
			if (is_tileable) {
				drag_box.exists = true;
				var sx:Float = FlxG.camera.scroll.x;
				var sy:Float = FlxG.camera.scroll.y;
				var trigger_w:Int = Std.int(tile_size.x);
				var trigger_h:Int = Std.int(tile_size.y);
				FlxG.camera.debugLayer.graphics.lineStyle(1, 0x00ffff, 1);
				FlxG.camera.debugLayer.graphics.moveTo(x-sx,y-sy);
				FlxG.camera.debugLayer.graphics.lineTo(x-sx+trigger_w,y-sy);
				FlxG.camera.debugLayer.graphics.moveTo(x-sx+trigger_w,y-sy);
				FlxG.camera.debugLayer.graphics.lineTo(x-sx+trigger_w,y+trigger_h-sy);
				FlxG.camera.debugLayer.graphics.moveTo(x-sx+trigger_w,y+trigger_h-sy);
				FlxG.camera.debugLayer.graphics.lineTo(x-sx,y+trigger_h-sy);
				FlxG.camera.debugLayer.graphics.moveTo(x-sx,y+trigger_h-sy);
				FlxG.camera.debugLayer.graphics.lineTo(x-sx,y-sy);
			}
		} else {
			drag_box.exists = false;
		}
	}
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [drag_box]);
		HF.remove_list_from_mysprite_layer(this, parent_state, [under_sprite],MyState.ENT_LAYER_IDX_BG2);
		HF.remove_list_from_mysprite_layer(this, parent_state, [over_sprite]);
		
		if (props.get("auto_scrolls") == 1) {
			FlxG.bitmap.removeByKey(graphic.key);
		}
		super.destroy();
	}
	
	// 736 544 46 34
	
	private var av_start_zero:Bool = false;
	private var av_start_zero_val:Float= 0;
	public function changevis():Void 
	{
		var type:String = props.get("TYPE").toLowerCase();
		var _id:Int = props.get("id");
		var success:Bool = false;
		if (GenericNPC.generic_npc_data.get("_SetPiece").get(parent_state.TILESET_NAME) != null) {
			var type_map:Map < String, Dynamic > = GenericNPC.generic_npc_data.get("_SetPiece").get(parent_state.TILESET_NAME).get(type);
			//Log.trace(type);
			if (type_map != null) {
				
				var d:Map<String,Dynamic> = null;
				var key_data:Array<String> = null;
				for (key in type_map.keys()) {
					if (key.split("+")[0] == Std.string(_id)) {
						d = type_map.get(key);
						key_data = key.split("+");
						break;
					}
				}
				
		// type_map
		//{ object
		// key_data 
			//{ 0+bush.png+5,5,0,0,0,1,1	
				
				if (d != null) {
					// Either use full path
					var _info:Array<Int> = [1, 1, 0];
					if (key_data.length > 2) {
						_info = HF.string_to_int_array(key_data[2]);
					} else {
						Log.trace("info error" + Std.string(key_data));
					}
				
					var _w:Int = 16 * _info[0];
					var _h:Int = 16 * _info[1];
					var _start_frame:Int = _info[2];
					
					var path:String = key_data[1];
					var png:String = path.indexOf(".png") == -1 ? ".png" : "";
					if (path.indexOf("set/") != -1) {
						path = "assets/sprites/" + path + png;
					} else {
						path = "assets/sprites/set/" + parent_state.TILESET_NAME.toLowerCase() + "/" +path + png;
					}
					var bm:BitmapData = Assets.getBitmapData(path);
					
					scale_x_a = [];
					scale_y_a = [];
					alpha_a = [];
					x_a = [];
					y_a = [];
					if (bm != null) {
						myLoadGraphic(bm, true, false, _w, _h);
						if (d.exists("av_start_zero")) {
							if (1 == d.get("av_start_zero")) {
								av_start_zero = true;
							}
						}
						if (d.exists("angular_v")) {
							angularVelocity = d.get("angular_v");
							if (av_start_zero) {
								av_start_zero_val = angularVelocity;
								angularVelocity = 0;
							}
						} else {
							angularVelocity = 0;
						}
						
						sin_scale_ctr = -1;
						sin_alpha_ctr = -1;
						sin_angle_ctr = -1;
						sin_x_ctr = -1;
						sin_y_ctr = -1;
						
						if (d.exists("scale_amp") && d.exists("scale_period") && d.exists("scale_start")) {
							var per:Float = d.get("scale_period");
							if (per > 0.02) {
								scale_amp = d.get("scale_amp");
								sin_scale_ctr = 0;
								scale_start = d.get("scale_start");
								sin_scale_tpf = 360 / (60.0 * per);
								if (d.exists("r_period_start") && d.get("r_period_start") == 1) {
									sin_scale_ctr = Std.int(360 * Math.random());
								}
							}
							// per s * 60 ticks/s = 360 deg buddies / ? (deg buddies / tick)
							// 60 * p * x = 360
							// x (deg ticks / frame) = 360 / (60*p)
						}
						if (d.exists("alpha_amp") && d.exists("alpha_period") && d.exists("alpha_start")) {
							var per:Float = d.get("alpha_period");
							if (per > 0.02) {
								alpha_amp = d.get("alpha_amp");
								sin_alpha_ctr = 0;
								alpha_start = d.get("alpha_start");
								sin_alpha_tpf = 360 / (60.0 * per);
								if (d.exists("r_period_start") && d.get("r_period_start") == 1) {
									sin_alpha_ctr = Std.int(360 * Math.random());
								}
							}
						}
						if (d.exists("angle_amp") && d.exists("angle_period") && d.exists("angle_start")) {
							var per:Float = d.get("angle_period");
							if (per > 0.02) {
								angle_amp = d.get("angle_amp");
								sin_angle_ctr = 0;
								angle_start = d.get("angle_start");
								sin_angle_tpf = 360 / (60.0 * per);
								if (d.exists("r_period_start") && d.get("r_period_start") == 1) {
									sin_angle_ctr = Std.int(360 * Math.random());
								}
							}
						}
						
						if (d.exists("x_amp") && d.exists("x_period") && d.exists("x_start")) {
							var per:Float = d.get("x_period");
							if (per > 0.02) {
								x_amp = d.get("x_amp");
								sin_x_ctr = 0;
								x_start = d.get("x_start");
								sin_x_tpf = 360 / (60.0 * per);
								if (d.exists("r_period_start") && d.get("r_period_start") == 1) {
									sin_x_ctr = Std.int(360 * Math.random());
								}
							}
						}
						if (d.exists("y_amp") && d.exists("y_period") && d.exists("y_start")) {
							var per:Float = d.get("y_period");
							if (per > 0.02) {
								y_amp = d.get("y_amp");
								sin_y_ctr = 0;
								y_start = d.get("y_start");
								sin_y_tpf = 360 / (60.0 * per);
								if (d.exists("r_period_start") && d.get("r_period_start") == 1) {
									sin_y_ctr = Std.int(360 * Math.random());
								}
							}
						}
						
						
						if (d.exists("fr") && d.exists("anim")) {
							var animframes:Array<Int> = HF.string_to_int_array(d.get("anim"));
							// Maybe randomize the start frame
							if (d.exists("r_anim")) {
								//var rand:Int = Std.int(Math.random() * animframes.length);
								//for (i in 0...rand) {
									//var valval:Int = animframes.shift();
									//animframes.push(valval);
								//}
							}
							
							// Change scale/alpha based on frame
							if (d.exists("alpha")) {
								alpha_a = HF.string_to_float_array(d.get("alpha"));
							}
							if (d.exists("scale_x")) {
								scale_x_a = HF.string_to_float_array(d.get("scale_x"));
							}
							if (d.exists("scale_y")) {
								scale_y_a = HF.string_to_float_array(d.get("scale_y"));
							}
							if (d.exists("scale_first")) {
								scale_first = Std.parseInt(d.get("scale_first")) == 1;
							}
							
							
							if (alpha_a.length > animframes.length && animframes.length == 1) {
								for (i in 1...alpha_a.length) {
									animframes.push(animframes[0]);
								}
							} else if (scale_x_a.length > animframes.length && animframes.length == 1) {
								for (i in 1...scale_x_a.length) {
									animframes.push(animframes[0]);
								}
							}else if (scale_y_a.length > animframes.length && animframes.length == 1) {
								for (i in 1...scale_y_a.length) {
									animframes.push(animframes[0]);
								}
							}
							animation.add("a", animframes, d.get("fr"));
						} else {
							
							if (d.exists("r_frame")) {
								var a:Array<String> = d.get("r_frame").split(",");
								var iiiiii:Int = Std.int(Math.random() * a.length);
								animation.add("a", [Std.parseInt(a[iiiiii])], 10, true);
							} else {
								animation.add("a", [_start_frame], 1, true);
							}
						}
						
						if (d.exists("auto_scroll_fps")) {
							has_metadata_asf = true;
							auto_scroll_fps = d.get("auto_scroll_fps");
						}
						
						
						
						width = height = 16;
						if (_info.length > 6) {
							width = _info[5]*16;
							height = _info[6] * 16;
						}
						offset.set(_info[3] * 16, _info[4] * 16);
						
						
						if (d.exists("r_anim")) {
							animation.play("a",true,-1);
						} else {
							animation.play("a", true);
						}
						success = true;
						
						
						if (d.exists("under_anim")) {
							under_frame = Std.parseInt(d.get("under_anim"));
							HF.remove_list_from_mysprite_layer(this, parent_state, [under_sprite],MyState.ENT_LAYER_IDX_BG2);
							HF.add_list_to_mysprite_layer(this, parent_state, [under_sprite],MyState.ENT_LAYER_IDX_BG2);
							under_sprite.loadGraphic(bm, true, frameWidth, frameHeight);
							under_sprite.animation.add("a", [under_frame], 10);
							under_sprite.animation.play("a");
							under_sprite.width = width;
							under_sprite.height = height;
							under_sprite.offset.set(offset.x, offset.y);
							under_sprite.move(x, y);
							under_sprite.blend = BlendMode.NORMAL;
						} else {
							under_frame = -1;
							HF.remove_list_from_mysprite_layer(this, parent_state, [under_sprite],MyState.ENT_LAYER_IDX_BG2);
						}
						if (d.exists("over_anim")) {
							//Log.trace(["over_anim", d.get("over_anim")]);
							//Log.trace(type_map);
							over_frame = Std.parseInt(d.get("over_anim"));
							
							HF.remove_list_from_mysprite_layer(this, parent_state, [over_sprite]);
							// added in update
							over_sprite.ID = 60;
							//HF.add_list_to_mysprite_layer(this, parent_state, [over_sprite]);
							over_sprite.loadGraphic(bm, true, frameWidth, frameHeight);
							over_sprite.animation.add("a", [over_frame], 10);
							over_sprite.animation.play("a");
							over_sprite.width = width;
							over_sprite.height = height;
							over_sprite.offset.set(offset.x, offset.y);
							over_sprite.move(x, y);
							over_sprite.blend = BlendMode.NORMAL;
						} else {
							over_frame = -1;
							over_sprite.ID = -1;
							HF.remove_list_from_mysprite_layer(this, parent_state, [over_sprite]);
						}
						
						// Metadata blend overrides
						var b:Int = props.get("blend_1ad2mu3sc");
						if (b == 1) {
							blend = BlendMode.ADD;
						} else if (b == 2) {
							blend = BlendMode.MULTIPLY;
						} else if (b == 3) {
							blend = BlendMode.SCREEN;
						} else if (b == 0) {
							blend = BlendMode.NORMAL;
						}
						
						if (d.exists("blend")) {
							var bb:Int = d.get("blend");
							switch (bb) {
								case 0: blend = BlendMode.NORMAL;
								case 1: blend = BlendMode.ADD;
								case 2: blend = BlendMode.MULTIPLY;
								case 3: blend = BlendMode.SCREEN;
							}
							//Log.trace("new blend " + Std.string(blend));
						} else {
							blend = BlendMode.NORMAL;
						}
						
					} else {
						Log.trace("doesnt exist: " + path);
					}
				} else {
					//Log.trace("No id " + Std.string(_id) + " for type " + type + " in Tileset " + parent_state.TILESET_NAME);
				}
			} else {
				if (set_prop_index > 0) {
					Log.trace("No type " + type+" in Tileset " + parent_state.TILESET_NAME);
				}
			}
		} else {
			//Log.trace("No Setpiece entry for Tileset " + parent_state.TILESET_NAME);
		}
		if (!success) {
			myLoadGraphic("assets/sprites/set/test/red.png", true, false, 32, 32);
			//makeGraphic(16, 16, 0xffff0000);
		}
		if (props.get("mirrored") == 1) {
			scale.x = -1;
		} else {
			scale.x = 1;
		}
		editor_drag_box.make_rect_outline(Std.int(width), Std.int(height), 0xbb00ff00,"setpiece");
	}
	
	override public function recv_message(message_type:String):Int 
	{
		if (av_start_zero && message_type == "energize_tick_l") {
			angularVelocity = av_start_zero_val;
			return 1;
		}
		return 1;
	}
	
	
	function make_loop_anim():Void 
	{
		var ow:Float = width;
		var oh:Float = height;
		width = frameWidth;
		height = frameHeight;
	var bm:BitmapData = new BitmapData(Std.int(width * width), Std.int(height), true,0xff0000);
	var dbl:BitmapData = new BitmapData(Std.int(width * 2), Std.int(height * 2), true, 0xff0000);
	
	var atileset:BitmapData = new BitmapData(Std.int(width), Std.int(height),true, 0x00000000);
	atileset.copyPixels(graphic.bitmap, new Rectangle(0, 0,width, height), new Point(0, 0));
	
	dbl.copyPixels(graphic.bitmap, new Rectangle(0, 0, width, height), new Point(0, 0), atileset, new Point(0, 0), true);
	dbl.copyPixels(graphic.bitmap, new Rectangle(0, 0, width, height), new Point(width, 0), atileset, new Point(width, 0), true);
	dbl.copyPixels(graphic.bitmap, new Rectangle(0, 0, width, height), new Point(width,height), atileset, new Point(width, height), true);
	dbl.copyPixels(graphic.bitmap, new Rectangle(0, 0, width, height), new Point(0, height), atileset, new Point(0, height), true);
	
	
	// dbl is 2*w x 2*h
	myLoadGraphic(dbl, true, false, Std.int(width), Std.int(height),false);
	animation.add("a", [0], 60, true); // update at 60 fps (needed)
	animation.play("a");
	
	return;
	
	atileset = new BitmapData(Std.int(width*2), Std.int(height*2),true, 0x00000000);
	atileset.copyPixels(dbl, new Rectangle(0, 0, width * 2, height * 2), new Point(0, 0));
	// 0 = up, UR, ....4 = D, 6 = L, 7 = UL
	// This is 7 (up left)
	var next_x:Int = 0;
	var next_y:Int = 0;
	for (i in 0...Std.int(width)) {
		if (auto_scroll_dir == 0) { // up
			next_x = 0;
			next_y = i;
		} else if (auto_scroll_dir == 1) { // up/right
			next_x = Std.int(width) - 1 - i;
			next_y = i;
		} else if (auto_scroll_dir == 2) { // right
			next_x = Std.int(width) - 1 - i;
			next_y = 0;
		} else if (auto_scroll_dir == 3) { // down / right
			next_x = Std.int(width) - 1 - i;
			next_y = Std.int(width) - 1 - i;
		} else if (auto_scroll_dir == 4) { // down
			next_x = 0;
			next_y = Std.int(width) - 1 - i;
		} else if (auto_scroll_dir == 5) { // down left
			next_x = i;
			next_y = Std.int(width) - 1 - i;
		} else if (auto_scroll_dir == 6) { // left
			next_x = i;
			next_y = 0;
		} else if (auto_scroll_dir == 7) { // up-left
			next_x = next_y = i;
		}
		bm.copyPixels(dbl,new Rectangle(next_x,next_y, width, height), new Point(width * i, 0),atileset,new Point(width*i,0),true);
	}
	var aa:Array<Int> = [];
	for (i in 0...Std.int(width)) {
		aa.push(i);
	}
	//Log.trace(aa);
	myLoadGraphic(bm, true, false, Std.int(width), Std.int(height), false);
	//Log.trace(graphic.key);
	animation.add("b", aa, props.get("auto_scroll_fps"), true);
	animation.play("b");
	
	width = ow;
	height = oh;
	}
}