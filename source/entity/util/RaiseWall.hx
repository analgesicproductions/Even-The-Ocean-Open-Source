package entity.util;
import autom.SNDC;
import entity.MySprite;
import entity.trap.Pew;
import global.C;
import haxe.Log;
import help.HF;

import help.AnimImporter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import state.MyState;
import flixel.group.FlxGroup;

/**
 * A wall that can be energized to rise
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class RaiseWall extends MySprite
{

	public static var ACTIVE_RaiseWalls:FlxTypedGroup<RaiseWall>;
	private var energy_indicator:FlxSprite;
	public var energy:Int = 0;
	public var needed_energy:Int = 64;
	private var track:FlxSprite;
	private var node:FlxSprite;
	
	private var VIS_DARK_DEBUG:Int = 0;
	private var VIS_LIGHT_DEBUG:Int = 1;
	//private var energy_bg:FlxSprite;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		energy_indicator = new FlxSprite(x, y);
		track = new FlxSprite();
		node = new FlxSprite();
		super(_x, _y, _parent, "RaiseWall");
		immovable = true;
		//energy_bg = new FlxSprite(x, y);
		//energy_bg.makeGraphic(4, 1, 0xffff0000);
		//energy_bg.scale.y = 16;
		//energy_indicator.makeGraphic(4, 1, 0xffffff22);
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case _ if (VIS_DARK_DEBUG == vistype):
				if (props.get("is_wide") == 1) {
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, name, "default_w");
					AnimImporter.loadGraphic_from_data_with_id(energy_indicator, 32, 16	, name, "dark_bar_w");
				} else {
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 32, name, "default");
					AnimImporter.loadGraphic_from_data_with_id(energy_indicator, 16, 32, name, "dark_bar");
					
				}
				
				AnimImporter.loadGraphic_from_data_with_id(track, 16, 32, name, "default");
				AnimImporter.loadGraphic_from_data_with_id(node, 16, 32, name, "default");
				
				energy_indicator.animation.play("idle",true);
				dmgtype = VIS_DARK_DEBUG;
			case _ if ( VIS_LIGHT_DEBUG == vistype):
				if (props.get("is_wide") == 1) {
					AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, name, "1_w");
					AnimImporter.loadGraphic_from_data_with_id(energy_indicator, 32, 16, name, "light_bar_w");
				} else {
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 32, name, "1");
					AnimImporter.loadGraphic_from_data_with_id(energy_indicator, 16, 32, name, "light_bar");
				}
				AnimImporter.loadGraphic_from_data_with_id(track, 16, 32, name, "default");
				AnimImporter.loadGraphic_from_data_with_id(node, 16, 32, name, "default");
				
				energy_indicator.animation.play("idle",true);
				dmgtype = VIS_LIGHT_DEBUG;
		}
		node.animation.play("node");
		track.animation.play("track");
		track.origin.set(0, 0);
		

	}
	private var dir:Int = 0;
	private var is_wide:Bool = false;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("needed_en", 64);
		p.set("energy", 0);
		p.set("vistype", VIS_LIGHT_DEBUG);
		p.set("s_open", 0);
		p.set("permanent_open", 1); // if = 1, this doesn't reset to state = s_open on entity load
		p.set("is_wide", 0); 
		p.set("raise_dir", 0); // urdl
		p.set("raise_distance", 32);
		p.set("init_state", 0); // -1 = not in a gauntlet (uses s_open / permanent_open ) , else, 0 = "open", 1 = "closed"
		p.set("children", "");
		// Set default properties here
		
		// In a gauntlet or not
		
		// If in a gauntlet (init_state > -1)
		// If the gauntlet is active, pick state from s_open and permanent_open
		// If on map, and no gauntlet active, you should become init_State
		// If not on map, and no gauntlet active, call change_props()
		
		
		// If not in a gauntlet (init_state = -1) 
		// Just use s_open/permanent open
		return p;
		
	}

	override public function on_clicked_for_edit():Void 
	{
		super.on_clicked_for_edit();
	}
	private var raise_dis:Int = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		//if (p.exists("children")) props.remove("children");
		if (p.exists("post_leg")) props.remove("post_leg");
		if (p.exists("leg")) props.remove("leg");
		if (p.exists("leg_end_data")) props.remove("leg_end_data");
		if (p.exists("gauntlet_final_en")) props.remove("gauntlet_final_en");
		raise_dis = props.get("raise_distance");
		needed_energy = p.get("needed_en");
		energy = p.get("energy");
		vistype = p.get("vistype");
		change_visuals();
		if (animation != null) animation.play("idle_closed");
		dir = props.get("raise_dir");
		is_wide = props.get("is_wide") == 1;
		if (props.get("permanent_open") == 0) {
			props.set("s_open", 0);
			//props.set("energy", 0);
		}
		
		//if (props.get("init_state") > -1 && R.gauntlet _manager.active_gauntlet_id == "") {
		if (props.get("init_state") > -1) {
			props.set("s_open", props.get("init_state"));
			if (props.get("init_state") == 0) {
				props.set("energy", 0);
			} else {
				props.set("energy", props.get("needed_en"));
			}
		}
		energy = props.get("energy");
		
		if (props.get("s_open") == 1 || energy >= needed_energy) {
			state = MODE_RISEN;	
			props.set("s_open", 1);
			if (animation != null) animation.play("idle_open");
			energy = needed_energy;
			//energy_indicator.scale.y = (energy / (1.0 * needed_energy)) * 16;

			if (dir == 0) {
				y = iy - raise_dis; 
			} else if (dir == 1) {
				x = ix + raise_dis; 
			} else if (dir == 2) {
				y = iy + raise_dis;
			} else {
				x = ix - raise_dis;
			}
		}
	}
	
	override public function destroy():Void 
	{
		ACTIVE_RaiseWalls.remove(this, true);
		HF.remove_list_from_mysprite_layer(this, parent_state, [track,energy_indicator]);
		HF.remove_list_from_mysprite_layer(this, parent_state, [track],MyState.ENT_LAYER_IDX_BG2);
		HF.remove_list_from_mysprite_layer(this, parent_state, [node]);
		track.destroy();
		energy_indicator.destroy();
		node.destroy();
		super.destroy();
	}
	
	private static inline var MODE_GROUNDED:Int = 0;
	private static inline var MODE_RISING:Int = 1;
	private static inline var MODE_RISEN:Int = 2;
	private static inline var MODE_FALLING:Int = 3;
	
	private var startticks:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		
		if (startticks < 5) {
			startticks++;
		}
		

		var _off:Bool = false;
		if (R.access_opts[5]) {
			alpha = 0.35;
			_off = true;
		} else {
			if (alpha == 0.35) {
				alpha = 1;
			}
		}
		if (is_wide) {
			energy_indicator.scale.y = 1;
			energy_indicator.scale.x = (energy / (1.0 * needed_energy));
		} else {
			energy_indicator.scale.x = 1;
			energy_indicator.scale.y = (energy / (1.0 * needed_energy));
		}
	
		energy_indicator.x = x;
		energy_indicator.y = y;
		if (!did_init) {
			did_init = true;
			ACTIVE_RaiseWalls.add(this);
			populate_parent_child_from_props();
			if (cur_layer == MyState.ENT_LAYER_IDX_FG2) {
				HF.add_list_to_mysprite_layer(this, parent_state, [track],MyState.ENT_LAYER_IDX_BG2);
			} else {
				HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [track]);
			}
			HF.add_list_to_mysprite_layer(this, parent_state, [energy_indicator]);
			HF.add_list_to_mysprite_layer(this, parent_state, [node]);
			track.move(ix, iy);
			if (is_wide) {
				track.angle = 90;
				track.x += 32;
			}
			switch (props.get("raise_dir")) {
				case 0: node.move(ix, iy + height);
				case 1:node.move(ix-16,iy);
				case 2:node.move(ix, iy -16);
				case 3:node.move(ix+width, iy);
			}
			
			if (state == MODE_RISEN) {
				broadcast_to_children(C.MSGTYPE_ENERGIZE);
			}
		}
		
		switch (state) {
			case MODE_GROUNDED:
				if (energy >= needed_energy) {
					state = MODE_RISING;
					energy_indicator.visible = false;
					broadcast_to_children(C.MSGTYPE_ENERGIZE);
					if (startticks >= 5) R.sound_manager.play(SNDC.raisewall);
					props.set("s_open", 1);
				}
			case MODE_RISING:
				var done:Bool = false;
				
				if (dir == 0) {
					velocity.y = -27;
					if (iy - y > raise_dis) { y = iy - raise_dis; done = true; }
				} else if (dir == 1) {
					velocity.x = 27; 
					if (x - ix > raise_dis) { x = ix + raise_dis; done = true; }
				} else if (dir == 2) {
					velocity.y = 27;
					if (y - iy > raise_dis) { y = iy + raise_dis; done = true; }
				} else {
					velocity.x = -27;
					if (ix - x > raise_dis) { x = ix - raise_dis; done = true; }
				}
				
				if (done == true) {
					state = MODE_RISEN;
					animation.play("idle_open");
					velocity.y = 0;
					velocity.x = 0;
				}
				if (energy < needed_energy) {
					state = MODE_FALLING;
					props.set("s_open", 0);
					broadcast_to_children(C.MSGTYPE_DEENERGIZE);
				}
			case MODE_FALLING:
				var done:Bool = false;
				if (dir == 0) {
					velocity.y = 18;
					if (iy - y < 0) { y = iy; done = true; }
				} else if (dir == 1) {
					velocity.x = -18; 
					if (x - ix < 0) { x = ix; done = true; }
				} else if (dir == 2) {
					velocity.y = -18;
					if (y - iy < 0) { y = iy; done = true; }
				} else {
					velocity.x = 18;
					if (ix - x < 0) { x = ix; done = true; }
				}
				
				if (done) {
					energy_indicator.visible = true;
					state = MODE_GROUNDED;
					animation.play("idle_closed");
					velocity.y = 0;
					velocity.x = 0;
				}
			case MODE_RISEN:
				if (energy < needed_energy) {
					state = MODE_FALLING;
					if (startticks >= 5) R.sound_manager.play(SNDC.raisewall_fall);
					broadcast_to_children(C.MSGTYPE_DEENERGIZE);
					animation.play("idle_open");
					props.set("s_open", 0);
				}
				
		}
		//Log.trace([R.player.x+R.player.width, x ]);
		var do_player_hang:Bool = false;
		if (!hanging && !_off) {
			if (R.player.is_wall_hang_points_in_object(this) && !R.player.is_on_the_ground()) {
				var o:FlxObject = new FlxObject(x, y + height - 2, width, height);
				if (o.overlapsPoint(new FlxPoint(R.player.x+R.player.width/2,R.player.y)) == false ){
					if (R.player.facing == FlxObject.RIGHT) {
						if (R.input.right) do_player_hang = true;
					} else {
						if (R.input.left) do_player_hang = true;
					}
				}
			}
		}
		
		var oldallowcol:Int = R.player.allowCollisions;
		R.player.allowCollisions |= FlxObject.DOWN;
		if (((!_off && FlxObject.separate(this, R.player)) && !hanging && !R.player.is_on_the_ground()) || do_player_hang) {
			var b:Bool = false;
			if 	(R.player.touching == FlxObject.RIGHT ) { 
				R.player.x = x - R.player.width + 1;
				b = true;
			} else if (R.player.touching == FlxObject.LEFT) {
				R.player.x = x + width - 1;
				b = true;
			}
			if (b) {
				R.player.hang_ignore_noclimb_tiles = true;
				R.player.activate_wall_hang();
				R.player.velocity.x = 0;
				hanging = true;
			}
		}
		R.player.allowCollisions = oldallowcol;
		
		if (state == MODE_RISING || state == MODE_FALLING) {
			if (R.player.overlaps(this)) {
				var _x:Float = R.player.x + R.player.width / 2;
				var _y:Float = R.player.y + R.player.height/ 2;
				if (dir == 0 || dir == 2) {
					if (_x > x + width / 2) {
						R.player.do_hor_push(30);
					} else {
						R.player.do_hor_push( -30);
					}
				} else if (dir == 1 || dir == 3) {
					if (_y > y + height / 2) {
						R.player.do_vert_push( 20);
					} else {
						R.player.do_vert_push( -40);
					}
				}
			}
		}
		
		if (hanging) {
			//Log.trace("hi");
			if (!R.player.is_wall_hang_points_in_object(this)) {
				hanging = false;
			} else {
				R.player.activate_wall_hang();
				R.player.hang_ignore_noclimb_tiles = true;
				if 	(R.player.touching == FlxObject.RIGHT ) { 
					R.player.x = x - R.player.width;
				} else if (R.player.touching == FlxObject.LEFT) {
					R.player.x = x + width;
				}
			}
			
		}
		
		for (pew in Pew.ACTIVE_Pews.members) {
			if (pew == null) continue;
			pew.generic_overlap(this, -1);
		}
		
		
		
		super.update(elapsed);
	}
	
	private var hanging:Bool = false;
	override public function recv_message(message_type:String):Int 
	{
		switch (message_type) {
			case C.MSGTYPE_ENERGIZE:
				energy = needed_energy;
			case C.MSGTYPE_ENERGIZE_DARK:
				if (dmgtype == VIS_DARK_DEBUG) {
					energy = needed_energy;
				} else {
					energy = 0;
				}
			case C.MSGTYPE_ENERGIZE_LIGHT:
				if (dmgtype == VIS_LIGHT_DEBUG) {
					energy = needed_energy;
				} else {
					energy = 0;
				}
			case C.MSGTYPE_ENERGIZE_TICK_DARK:
				if (dmgtype == VIS_DARK_DEBUG) {
					if (energy < needed_energy) energy++;
				} else if (dmgtype == VIS_LIGHT_DEBUG) {
					if (energy > 0) energy--;
				}
			case C.MSGTYPE_ENERGIZE_TICK_LIGHT:
				if (dmgtype == VIS_DARK_DEBUG) {
					if (energy > 0) energy --;
				} else if (dmgtype == VIS_LIGHT_DEBUG) {
					if (energy < needed_energy) energy++;
				}
				
		}
		if (energy != needed_energy) {
			if (state != MODE_RISEN && state != MODE_FALLING) {
				animation.play("charging");
			}
		} else {
			animation.play("idle_open");
		}
		props.set("energy", energy);
		return C.RECV_STATUS_OK;
	}
	
	public static function reinit(ent_line:String):String {
		var init_state:Int = HF.get_int_prop_in_ent_line(ent_line, "init_state");
		if (init_state > -1) {
			if (init_state == 0) {
				ent_line = HF.replace_prop_in_ent_line(ent_line, 1, "permanent_open");
				ent_line = HF.replace_prop_in_ent_line(ent_line, 0, "energy");
				return HF.replace_prop_in_ent_line(ent_line, 0, "s_open");
			} else {
				ent_line = HF.replace_prop_in_ent_line(ent_line, 1, "permanent_open");
				return HF.replace_prop_in_ent_line(ent_line, 1, "s_open");
			}
		}
		return ent_line;
	}
	
	
}