package entity.trap;

import entity.player.BubbleSpawner;
import entity.util.VanishBlock;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import haxe.Log;
import help.FlxX;
import state.MyState;
import entity.MySprite;
import help.HF;

class FlameBlower extends MySprite
{

	public static var ACTIVE_FlameBlowers:List<FlameBlower>;
	private var flames:FlxTypedGroup<FlxSprite>;
	private var blow_vel:Float;
	private var flame_distance:Float;
	private var dir:Int;
	private var tm_hurt:Float = 0;
	private var tm_on:Float = 0;
	private var tm_off:Float = 0;
	private var t_on:Float = 0;
	private var t_off:Float = 0;
	private var tm_new_flame:Float = -1;
	private var t_hurt:Float = 0;
	private var t_new_flame:Float = 0;
	private var nr_flames:Int = 0;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		flames = new FlxTypedGroup<FlxSprite>();
		super(_x, _y, _parent, "FlameBlower");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(16, 16, 0xffff00ff);
				for (i in 0...nr_flames) {
					flames.members[i].makeGraphic(16, 16, 0xffdd00dd);
					//flames.members[i].width = 10;
					//flames.members[i].height = 13;
					//flames.members[i].offset.set(3, 3);
				}
			case 1:
				makeGraphic(16, 16, 0xffffffff);
				for (i in 0...nr_flames) {
					flames.members[i].makeGraphic(16, 16, 0xffdddddd);
					//flames.members[i].width = 10;
					//flames.members[i].height = 13;
					//flames.members[i].offset.set(3, 3);
				}
			default:
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("blow_vel", 120);
		p.set("flame_distance", 60);
		p.set("tm_hurt", 0.033);
		p.set("tm_on", -1);
		p.set("tm_off", -1);
		p.set("tm_new_flame", 0.12);
		p.set("nr_flames", 4);
		p.set("dir", 0);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		blow_vel = props.get("blow_vel");
		flame_distance = props.get("flame_distance");
		tm_hurt = props.get("tm_hurt");
		tm_on = props.get("tm_on");
		tm_off = props.get("tm_off");
		tm_new_flame = props.get("tm_new_flame");
		nr_flames = props.get("nr_flames");
		dir = props.get("dir");
		
		flames.clear();
		for (i in 0...nr_flames) {
			var flame:FlxSprite = new FlxSprite();
			flames.add(flame);
			flame.visible = false;
		}
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		ACTIVE_FlameBlowers.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [flames]);
		super.destroy();
	}
	
	public function generic_overlap(o:FlxObject):Bool {
		
		for (flame in flames.members) {
			if (flame != null) {
				if (flame.overlaps(o)) {
					return true;
				}
			}
		}
		return false;
	}
	
	public function generic_circle_overlap(cx:Float,cy:Float,cr:Float,only_dmgtype:Int):Bool {
		if (this.dmgtype != only_dmgtype) { //1 only light breaks
			return false;
		} 
		
		for (flame in flames.members) {
			if (flame != null) {
				if (FlxX.circle_flx_obj_overlap(cx, cy, cr, flame)) {
					return true;
				}
			}
		}
		return false;
	}
	
	private var is_on:Bool = true;
	private var offsets_idx:Int = 0;
	private static var offsets:Array<Float> = [ -15, 15, 5, 0, -10, 10, 5, 10, -18, 2, -4];
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_FlameBlowers.add(this);
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [flames]);
		}
		
		if (is_on) {
			if (t_new_flame < tm_new_flame) {
				t_new_flame += FlxG.elapsed;
			} else {
				for (i in 0...nr_flames) {
					if (flames.members[i].visible == false) {
						t_new_flame = 0;
						offsets_idx++;
						if (offsets_idx == offsets.length) offsets_idx = 0;
						var f:FlxSprite = flames.members[i];
						f.visible = true;					
						f.move(ix, iy);
						if (dir == 0) {
							f.velocity.y = -blow_vel;
							f.velocity.x = offsets[offsets_idx];
						} else if (dir == 1) {
							f.velocity.x = blow_vel;
							f.velocity.y = offsets[offsets_idx];
						} else if (dir == 2) {
							f.velocity.y = blow_vel;
							f.velocity.x = offsets[offsets_idx];
						} else if (dir == 3) {
							f.velocity.x = -blow_vel;
							f.velocity.y = offsets[offsets_idx];
						}
						break;
					}
				}
			}
		}
		
		
		if (tm_off != -1 && tm_on != -1) {
			if (is_on) {
				t_on += FlxG.elapsed;
				if (t_on > tm_on) {
					t_on = 0;
					is_on = false;
				}
			} else {
				t_off += FlxG.elapsed;
				if (t_off > tm_off) {
					t_off = 0;
					is_on = true;
				}
			}
		}
		
		var b:Bool = false;
		for (i in 0...nr_flames) {
			var f:FlxSprite = flames.members[i];
			if (f.visible) {
				if (HF.get_midpoint_distance(f, this) > flame_distance) {
					f.velocity.set(0, 0);
					f.visible = false;
				} else {
					
					for (vb in VanishBlock.ACTIVE_VanishBlocks) {
						if (vb.is_open == false) {
							if (f.overlaps(vb)) {
								f.velocity.set(0, 0);
								f.visible = false;
								break;	
							}
						}
					}
					
					if (f.overlaps(R.player)) {
						b = true;
					}
				}
			}
		}
		
		if (b == true) {
			t_hurt += FlxG.elapsed;
			if (t_hurt > tm_hurt) {
				t_hurt -= tm_hurt;
				
				if (BubbleSpawner.cur_bubble == null) {
					if (dmgtype == 0) {
						R.player.add_dark(1);
					} else {
						R.player.add_light(1);
					}
				}
			}
			var vy:Float = R.player.velocity.y;
			var vx:Float = R.player.velocity.x;
			if (dir == 0 && vy < 0 && vy < -350) {
			
			} else if (dir == 1 && vx > 0 && vx > 350) {
			} else if (dir == 3 && vx < 0 && vx < -350) {
				
			} else if (R.player.wind_velx == 0 && R.player.wind_vely == 0) {
				if (dir == 0) {
					if (R.player.is_on_the_ground(true)) {
						R.player.do_vert_push( -160,true);
					} else {
						R.player.apply_wind(0, -blow_vel,true);
					}
				} else if (dir == 1) {
					R.player.apply_wind(blow_vel,0,true);
				} else if (dir == 2) {
					R.player.apply_wind(0, blow_vel,true);
				} else if (dir == 3) {
					R.player.apply_wind(-blow_vel,0,true);
				}
			}
		}
		super.update(elapsed);
	}
}