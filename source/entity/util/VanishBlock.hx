package entity.util;
import entity.MySprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class VanishBlock extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "VanishBlock");
		immovable = true;
	}
	
	private  static var VIS_DEBUG_DARK:Int = 0;
	private static var VIS_DEBUG_LIGHT:Int = 1;
	public static var ACTIVE_VanishBlocks:List<VanishBlock>;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "dark");
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "light");
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, Std.string(vistype));
			
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", VIS_DEBUG_DARK);
		return p;
	}
	
	//private var needed_en:Int = 32;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		
		vistype = props.get("vistype");
		change_visuals();

	}
	
	override public function destroy():Void 
	{
		//HF.remove_list_from_mysprite_layer(this, parent_state, [energy_indicator]);
		ACTIVE_VanishBlocks.remove(this);
		super.destroy();
	}
	
	private var energy:Int;
	public var is_open:Bool = false;
	public function is_active():Bool {
		return !is_open;
	}
	private var played_On:Bool = false;
	public static var light_on:Bool = true;
	public var old_light_on:Bool = false;
	public var did_init_2:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		
		//if (FlxG.keys.myJustPressed("Q")) {
			//if (light_on == old_light_on) {
				//light_on = !light_on;
			//}
		//}
		
		if (did_init && !did_init_2) {
			did_init_2 = true;
			if (allowCollisions != 0) {
				var vb:VanishBlock;
				var ct:Int = 0;
				var outerbreak:Bool = false;
				// Eliminate blocks that are underneat blocks
				for (vb in ACTIVE_VanishBlocks) {
					if (vb.x == x && vb.y == y - 16 && vb.vistype == vistype) {
						allowCollisions = 0;
						outerbreak = true;
						break;
					}
				}
				var safety:Int = 0;
				if (!outerbreak) {
					while (true) {
						safety++;
						if (safety == 50) {
							Log.trace("oops!");
							break;
						}
						for (vb in ACTIVE_VanishBlocks) {
							if (vb.x == x && vb.y == y + height && vb.vistype == vistype) {
								height += 16;
								ct = 1;
							}
						}
						
						if (ct == 0) {
							break;
						}
						ct = 0;
					}
				}
			}
		}
		
		if (!did_init) {
			
			ACTIVE_VanishBlocks.add(this);
			did_init = true;
			allowCollisions = FlxObject.ANY;
			if (vistype == VIS_DEBUG_DARK) {
				is_open = light_on;
			} else {
				is_open = !light_on;
			}
			old_light_on = light_on;
			ID = 0;
			//HF.add_list_to_mysprite_layer(this, parent_state, [energy_indicator]);
		}
		//if (energy >= needed_en || props.get("s_open") == 1 ) {
		
		
		if (is_open) {
			if (ID == 0) {
				animation.play("turn_off", true);
				ID = 1;
			} else if (ID == 1) {
				if (old_light_on != light_on) {
					old_light_on = light_on;
					ID = 0;
					is_open = false;
				}
			}
		} else {
			if (ID == 0) {
				animation.play("turn_on", true);
				ID = 1;
			} else if (ID == 1) {
				if (allowCollisions != 0) {
					var res:Bool = false;
					res = FlxObject.separateY(this, R.player);
					if (!res) {
						// no clue why the above doesnt work, this is needed when sliding down a left-facing wall onto a vanishblock
						if (R.player.is_in_wall_mode()) {
							if (R.player.x < x + width && R.player.x + R.player.width > x+4) {
								if (R.player.y + R.player.height <= y && R.player.y +R.player.height + R.player.velocity.y * elapsed > y) {
									R.player.touching = FlxObject.DOWN;
								}
							}
						}
					}
				}
				if (old_light_on != light_on) {
					old_light_on = light_on;
					ID = 0;
					is_open = true;
					wall_mode = 0;	
				}
			}
		}
		
		if (!is_open && allowCollisions != 0) {
		if (wall_mode == 0) {
			var ov:Float = R.player.velocity.x;
			var ovy:Float = R.player.velocity.y;
			var ot:Int = R.player.touching;
			var b:Bool = FlxObject.separateX(this, R.player);
			if (b) {
				playerinone = true;
				if (Math.abs(R.player.y + R.player.height - y) <= 1) {
					R.player.y -= 1;
					R.player.last.y -= 1;
					R.player.touching = ot;
					R.player.velocity.x = ov;
					//Log.trace("top");
				} else if (Math.abs(y + height - R.player.y) <= 1) {
					R.player.y -= 3;
					R.player.last.y -= 3;
					//R.player.touching = ot;
					//R.player.velocity.x = ov;
					//R.player.velocity.y = ovy;
					if (R.player.touching & FlxObject.UP != 0) {
						R.player.velocity.y = -100;
					}
					
					//Log.trace("bottom");
					
					if (R.player.touching & FlxObject.RIGHT > 0) {
						wall_mode = 1;
						R.player.activate_wall_hang();
					} else if (R.player.touching & FlxObject.LEFT > 0) {
						wall_mode = 2;
						R.player.activate_wall_hang();
					}
				} else {
					if (R.player.touching & FlxObject.RIGHT > 0) {
						wall_mode = 1;
						R.player.activate_wall_hang();
					} else if (R.player.touching & FlxObject.LEFT > 0) {
						wall_mode = 2;
						R.player.activate_wall_hang();
					}
				}
			} else {
				if (this.overlapsPoint(new FlxPoint(R.player.x + R.player.width, R.player.y + 8)) || this.overlapsPoint(new FlxPoint(R.player.x, R.player.y + 8))) {
					playerinone = true;
				}
			}
		} else {
			playerinone = true;
			if (wall_mode == 1) {
				if (ticks < 10) {
					R.player.x = x - R.player.width + 1;
					R.player.activate_wall_hang();
				}
				if (R.input.jpA1) {
					R.player.velocity.x = -120;
					R.player.x -=2;
					R.player.last.x -=2;
				}
				if (R.input.left) {
					ticks++;
				} else {
					ticks = 0;
				}
			} else if (wall_mode == 2) {	
				if (ticks < 10) {
					R.player.x = x + width - 1;
					R.player.activate_wall_hang();
				}
				
				if (R.input.jpA1) {
					R.player.velocity.x = 120;
					R.player.x+=2;
					R.player.last.x+=2;
				}
				if (R.input.right) {
					ticks++;
				} else {
					ticks = 0;
				}
			}
			if (!R.player.is_wall_hang_points_in_object(this)) {
				wall_mode = 0;
			}
		}
		}
		
		super.update(elapsed);
	}
	
	public static var playerinone:Bool = false;
	private var wall_mode:Int = 0;
	private var ticks:Int = 0;
	private var ignore_init_msg:Bool = false;
	override public function recv_message(message_type:String):Int 
	{
		return C.RECV_STATUS_OK;
	}
	
	
}