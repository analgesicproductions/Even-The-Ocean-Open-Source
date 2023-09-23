package entity.npc;
import autom.SNDC;
import entity.MySprite;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.MyState;
import flixel.group.FlxGroup;
class Cauliflower extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		stalks = new FlxTypedGroup<FlxSprite>();
		super(_x, _y, _parent, "Cauliflower");
	}
	public static var ACTIVE_Cauliflowers:List<Cauliflower>;
	
	private static var VISTYPE_LIGHT:Int = 0;
	private static var VISTYPE_DARK:Int = 1;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				//makeGraphic(32, 32, 0xffffffff);
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "light");
				animation.play("idle");
				dmgtype = VISTYPE_LIGHT;
			case 1:
				//makeGraphic(32, 32, 0xffff00ff);
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "dark");
				animation.play("idle");
				dmgtype = VISTYPE_DARK;
		}
	}
	
	public function generic_overlap(o:FlxObject, dmgtype:Int = -1):Bool {
		if (o.overlaps(this)) {
			if (dmgtype == -1) {
				return true;
			}
		}
		return false;
	}
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		
		p.set("is_self_aware",0);
		//p.set("tm_regrowth", 300);
		p.set("tm_damage", 0.06);
		p.set("nr_stalks", 3);
		p.set("tm_shoot", 10);
		p.set("max_babies", 5);
		p.set("vistype", 0);
		p.set("sink_vel", 25);
		p.set("move_vel", 40);
		
		return p;
	}
	
	private var stalks:FlxTypedGroup<FlxSprite>;
	
	private var is_self_aware:Int = 0;
	private var max_babies:Int = 0;
	private var nr_stalks:Int = 0;
	private var tm_damage:Float = 0;
	private var tm_shoot:Float = 0;
	private var t_regrowth:Float = 0;
	private var t_shoot:Float = 0;
	
	private var root_y:Float = 0;
	private var root_ix:Float = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		if (props.exists("tm_regrowth")) props.remove("tm_regrowth");
		
		vistype = props.get("vistype");
		is_self_aware = props.get("is_self_aware");
		tm_shoot = props.get("tm_shoot");
		tm_damage = props.get("tm_damage");
		
		stalks.clear();
		for (i in 0...4) {
			var stalk:FlxSprite = new FlxSprite();
			//stalk.makeGraphic(16, 8, 0xff00ff00);
			AnimImporter.loadGraphic_from_data_with_id(stalk, 16, 16, name, "stalk");
			stalk.animation.play("idle");
			stalks.add(stalk);
		}
		
		if (0 == is_self_aware) {
			//stalks.visible = false;	
		}
		
		
		max_babies = props.get("max_babies");
		
		change_visuals();
		
		
		for (i in 0...30) {
			var colide_y:Float = (y + height + i * 16);
			if (parent_state.tm_bg.getTileCollisionFlags(x + width / 2, colide_y) != 0) {
				root_y = colide_y - (colide_y % 16);
				break;
			}
		}
		
		root_ix = ix + ((width - stalks.members[0].width) / 2 );
	}
	
	override public function destroy():Void 
	{
		if (1 == is_self_aware) HF.remove_list_from_mysprite_layer(this, parent_state, [stalks]);
		ACTIVE_Cauliflowers.remove(this);
		super.destroy();
	}
	
	override public function preUpdate():Void 
	{
		FlxObject.separateY(this, R.player);
		super.preUpdate();
	}
	
	private var mode:Int = 0;
	
	private var wall_mode:Int = 0;
	private var slow_damage:Bool = false;
	private var player_wall_dir:Int = 0;
	
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_Cauliflowers.add(this);
			immovable = true;
			if (1 == is_self_aware) HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [stalks]);
		}
		
		
		if (0 == is_self_aware) {
			wallhelp();
			if (touching == FlxObject.UP) {
				hurt_player();
			}
			return;
		}
		
		var d:Float = root_y - (y + height) - stalks.members[0].height;
		var dy:Float = d / (stalks.length - 1);
		var dx:Float = (ix - x) / (stalks.length - 1);
		
		for (i in 0...stalks.length) {
			stalks.members[i].x = root_ix + (stalks.length - 1  - i) * -1 * dx;
			stalks.members[i].y = (y + height) + dy * i;
		}
		
		if (1 == 	is_self_aware) {
			if (mode == 0) {
				// Stop moving when returnig hope
				if (FlxX.l1_norm_from_mid(this, new FlxObject(ix+width/2, iy+width/2, 1, 1)) < 2) {
					velocity.x = velocity.y = 0;
					x = ix;
					y = iy;
				}
				
				
			wallhelp();		
				
				// tuoching player
				if (touching != 0) {
					if (R.player.touching & FlxObject.DOWN != 0) {
						R.player.velocity.y = 30;
						mode = 2;
						velocity.x = velocity.y = 0;
					}
				}
			} else if (mode == 1) {
			} else { // MODE 2
				if (touching != 0 && R.player.touching & FlxObject.DOWN != 0) { // stnading on top
					if (R.player.get_shield_dir() == 2) {
						//slow_damage = true;
					}
					velocity.y = R.player.velocity.y = props.get("sink_vel");
				}  else if (touching != 0 && R.player.touching & FlxObject.UP != 0) {
					if (R.player.get_shield_dir() == 0) {
						//slow_damage = true;
					}
				}
				
				height += 2; y -= 2;
				if (touching == 0 && overlaps(R.player) == false && y > iy) { // go back home if not touching player
					HF.scale_velocity(this.velocity, this, new FlxObject(ix, iy, 1, 1), 30);
					mode = 0;
					drag.x = 0;
				} else {
					if (overlaps(R.player) && parent_state.tm_bg.getTileCollisionFlags(R.player.x, R.player.y + R.player.height + 1) != 0) {
						velocity.y = 0;
					}
					hurt_player();
				}
				height -= 2; y += 2;
			}
		} else { // on the ground, idle.
			if (touching != 0) {
				hurt_player();
			}
		}
		
		if (touching != FlxObject.NONE) {
			if (R.player.touching != FlxObject.DOWN) {
				//R.player.touching = FlxObject.NONE;
			}
			
		}
		
		super.update(elapsed);
	}
	
	private function hurt_player():Void 
	{
		
			R.player.force_sticky = true;
		t_regrowth += FlxG.elapsed;
		if (slow_damage) {
			tm_damage *= 2;
			if (tm_damage == 0) tm_damage = 0.03502;
		}
		if (t_regrowth > tm_damage) {
			t_regrowth -= tm_damage;
			R.sound_manager.play(SNDC.touch_weed);
			if (dmgtype == VISTYPE_DARK) {
				R.player.add_dark(1);
			} else if (dmgtype == VISTYPE_LIGHT) {
				R.player.add_light(1);
			}
		}
		if (slow_damage) {
			tm_damage *= 0.5;
			if (tm_damage == 0.03502) tm_damage = 0;
			slow_damage = false;
		}
	}
	
	private var ticks_dontfall:Int = 0;
	function wallhelp():Void 
	{
		if (wall_mode == 0) {
			var b:Bool = FlxObject.separateX(this, R.player);
			if (b) {
				if (R.player.touching & FlxObject.RIGHT > 0) {
					wall_mode = 1;
					R.player.activate_wall_hang();
				} else if (R.player.touching & FlxObject.LEFT > 0) {
					wall_mode = 2;
					R.player.activate_wall_hang();
				}
			}
		} else {
			hurt_player();
			if (wall_mode == 1 && (ticks_dontfall < 10 || R.input.right)) {
				R.player.x = x - R.player.width + 1;
				R.player.activate_wall_hang();
				if (R.input.right == false ) {
					ticks_dontfall++;
				} else {
					ticks_dontfall = 0;
				}
			} else if (wall_mode == 2 && (ticks_dontfall < 10 || R.input.left)) {	
				R.player.x = x + width - 1;
				R.player.activate_wall_hang();
				if (R.input.left == false ) {
					ticks_dontfall++;
				} else {
					ticks_dontfall = 0;
				}
			} else {
				ticks_dontfall++;
			}
			if (!R.player.is_wall_hang_points_in_object(this)) {
				wall_mode = 0;
			}
		}
	
	}
}