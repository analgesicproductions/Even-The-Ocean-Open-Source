package entity.player;
import entity.MySprite;
import flash.geom.Point;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import openfl.Assets;
import flixel.FlxObject;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class Train extends MySprite
{

	private var mode:Int = 0;
	private var mode_idle:Int = 0;
	private var mode_moving:Int = 1;
	private var mode_inactive:Int = 2;
	public var active_region:FlxObject;
	private static inline var MOVE_VEL:Int = 60;
	public static var tile_id_to_collision_flag_map:Map<Int,Int>;
	private var is_paused:Bool = false;
	
	public var inside_stopping_point:Bool = false;
	public var stopping_point_id:String = "";
	private var from_dir:Int = 0;
	private var do_auto_move:Bool = false;
	
	public static var VISTYPE_TRAIN:Int = 0;
	public static var VISTYPE_EVEN_MAP:Int = 1;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "Train");
		
		x = 16;
		y = 16;
		next = new Point(x, y);
		tile_id_to_collision_flag_map = new Map < Int, Int>();
		active_region = new FlxObject(0, 0, 20, 20);
		mode = mode_inactive;
		vistype = VISTYPE_TRAIN;
	
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case _ if (vistype == VISTYPE_EVEN_MAP):
				myLoadGraphic(Assets.getBitmapData("assets/sprites/player/map_even.png"), true, false, 16, 16);
				AnimImporter.addAnimations(this, "Even_map", "default");
				do_auto_move = true;
				animation.play("up");
			case _ if (vistype == VISTYPE_TRAIN):
				myLoadGraphic(Assets.getBitmapData("assets/sprites/player/train.png"),true,false,16,16);
				AnimImporter.addAnimations(this, "Train", "default");
				do_auto_move = false;
				animation.play("idle");
		}
		// Change visuals
	}
	
	public function change_vistype(new_vistype:Int):Void {
		vistype = new_vistype;
		change_visuals();
	}

	public function is_idle():Bool {
		if (mode == mode_idle) {
			return true;
		}
		return false;
	}
	public function is_even_map():Bool {
		if (vistype == VISTYPE_EVEN_MAP) return true;
		return false;
	}
	override public function set_properties(p:Map<String, Dynamic>):Void 
	{
		HF.copy_props(p, props);
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	public static function clear_colflag():Void {
		tile_id_to_collision_flag_map = new Map<Int,Int>();
	}
	public static function set_collision_flags_from_tilemeta(s:String):Void {
		var train_data:Array<String> = s.split(" ");
		// might want to clear here
		tile_id_to_collision_flag_map = new Map<Int,Int>();
		for (i in 1...train_data.length) {
			var flags:String = train_data[i].split(":")[0];
			var id:Int = Std.parseInt(train_data[i].split(":")[1]);
			var next_flags:Int = 0;
			if (flags.indexOf("u") != -1) {
				next_flags |= FlxObject.UP;
			}
			if (flags.indexOf("r") != -1) {
				next_flags |= FlxObject.RIGHT;
			}
			if (flags.indexOf("d") != -1) {
				next_flags |= FlxObject.DOWN;
			}
			if (flags.indexOf("l") != -1) {
				next_flags |= FlxObject.LEFT;
			}
			tile_id_to_collision_flag_map.set(id, next_flags);
		}
	}
	public function pause_toggle(on:Bool):Void {
		is_paused = on;
		if (is_paused) {
			velocity.x = velocity.y = 0;
		}
	}
	
	private var next:Point;
	override public function update(elapsed: Float):Void 
	{
		if (is_paused) return;
		active_region.x = x - 2;
		active_region.y = y - 2;
		if (mode == mode_moving) {
			if (velocity.x > 0) {
				if (x >= next.x) {
					x = next.x;
					become_idle();
				}
			} else if (velocity.x < 0) {
				if (x <= next.x) {
					x = next.x;
					become_idle();
				}
			} else if (velocity.y < 0) {
				if (y <= next.y) {
					y = next.y;
					become_idle();
				}
			} else if (velocity.y > 0) {
				if (y >= next.y) {
					y = next.y;
					become_idle();
				}
			}
		} else if (mode == mode_idle) {
				
			var flags:Int = 0;
			
			if (do_auto_move && from_dir != FlxObject.NONE) {
				var tile_id:Int = parent_state.tm_bg2.getTile(Std.int(x / 16), Std.int(y / 16));
				if (tile_id_to_collision_flag_map.exists(tile_id)) {
					flags = tile_id_to_collision_flag_map.get(tile_id);
					flags ^= from_dir;
					if (flags == FlxObject.LEFT) {
						R.input.left = true;
					} else if (flags == FlxObject.RIGHT) {
						R.input.right = true;
					} else if (flags == FlxObject.UP) {
						R.input.up = true;
					} else if (flags == FlxObject.DOWN) {
						R.input.down = true;
					}
				}
				from_dir = FlxObject.NONE;
			}
			
			if (R.input.up || R.input.down || R.input.left || R.input.right) {
				
				// TrainTriggers constantly check if the train is overlapping them. If so,
				// they'll set inside_stopping_point to true on each tick, and run a script
				// via their string_id to check whether or not the train can move.
				if (inside_stopping_point) {
					if (check_if_ok_to_move(stopping_point_id) == false) {
						return;
					}
				}
				var tile_id:Int = parent_state.tm_bg2.getTile(Std.int(x / 16), Std.int(y / 16));
				if (tile_id_to_collision_flag_map.exists(tile_id)) {
					flags = tile_id_to_collision_flag_map.get(tile_id);
				} else {
					flags = 0x1111;
				}
				
				
				if (R.input.up && flags & FlxObject.UP != 0) {
					next.y -= 16;
					mode = mode_moving;
					velocity.y = -MOVE_VEL;
					if (vistype == VISTYPE_EVEN_MAP) animation.play("up");
					from_dir = FlxObject.DOWN;
				} else if (R.input.down && flags & FlxObject.DOWN != 0) {
					next.y += 16;
					mode = mode_moving;
					velocity.y = MOVE_VEL;
					if (vistype == VISTYPE_EVEN_MAP) animation.play("down");
					from_dir  = FlxObject.UP;
				} else if (R.input.left && flags & FlxObject.LEFT != 0) {
					next.x -= 16;
					mode = mode_moving;
					velocity.x = -MOVE_VEL;
					if (vistype == VISTYPE_EVEN_MAP) animation.play("left");
					from_dir  = FlxObject.RIGHT;
				} else if (R.input.right && flags & FlxObject.RIGHT != 0) {
					next.x += 16;
					mode = mode_moving;
					velocity.x = MOVE_VEL;
					if (vistype == VISTYPE_EVEN_MAP) animation.play("right");
					from_dir  = FlxObject.LEFT;
				}
			}
			
			inside_stopping_point = false;
		} else if (mode == mode_inactive) {
			
		}
		super.update(elapsed);
	}
	public function check_if_ok_to_move(stop_id:String):Bool {
		if (stop_id == "none") {
			if (R.input.down) {
				
				parent_state.dialogue_box.start_dialogue("butts", "b3");
				return false;
			}
		}
		return true;
	}
	public function stop_being_inactive():Void {
		next.x = x;
		next.y = y;
		mode = mode_idle;
		animation.play("move");
	}
	public function become_inactive():Bool {
		if (mode == mode_idle) {
			mode = mode_inactive;
			animation.play("idle");
			return true;
		}
		return false;
	}
	private function become_idle():Void 
	{
		x = next.x;
		y = next.y;
		velocity.y = 0;
		velocity.x = 0;
		mode = mode_idle;
	}
	public function move_to(_x:Float, _y:Float):Void {
		x = next.x = 16 * Std.int(_x / 16);
		y = next.y = 16 * Std.int(_y / 16);
		
	}
}