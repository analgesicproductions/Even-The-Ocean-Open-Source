package entity.trap;
import autom.SNDC;
import entity.MySprite;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import openfl.geom.Point;
import state.MyState;

class BarbedWire extends MySprite
{

	
	private var is_dream:Bool = false;
	private var wire_sprite:FlxSprite;
	private var wire_tile_width:Int = 0;
	private var spark:FlxSprite;
	private var is_ring:Bool = false;
	public static var ACTIVE_BarbedWires:List<BarbedWire>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		wire_sprite = new FlxSprite();
		spark = new FlxSprite();
		child_colors = [];
		super(_x, _y, _parent, "BarbedWire");
	}

	public var energy:Int;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name + "Pole", "dark");
				if (is_ring) {
					AnimImporter.loadGraphic_from_data_with_id(wire_sprite, 48, 48, name, "darkb");
					wire_sprite.width = wire_sprite.height = 48;
					wire_sprite.offset.set(0, 0);
				} else {
					AnimImporter.loadGraphic_from_data_with_id(wire_sprite, 16, 16, name, "dark");
					
					if (props.get("is_dream") == 1) {
						AnimImporter.loadGraphic_from_data_with_id(wire_sprite, 16, 16, name, "darkdream");
						AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "darkdream");
					}
						
					wire_sprite.width = wire_sprite.height = 2;
					wire_sprite.offset.set( 7, 7);
				}
				animation.play("on", true);
				wire_sprite.animation.play("on", true);
				AnimImporter.loadGraphic_from_data_with_id(spark, 16, 16, "HurtEffectGroup", 0);
				

				props.set("dmgtype", 0);
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name + "Pole", "light");
				
					if (is_ring) {
						AnimImporter.loadGraphic_from_data_with_id(wire_sprite, 48, 48, name, "lightb");
						
						wire_sprite.width = wire_sprite.height = 48;
						wire_sprite.offset.set(0, 0);
					} else {
						AnimImporter.loadGraphic_from_data_with_id(wire_sprite, 16, 16, name, "light");
						
						
						if (props.get("is_dream") == 1) {
							AnimImporter.loadGraphic_from_data_with_id(wire_sprite, 16, 16, name, "lightdream");
							AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "lightdream");
						}
						
						wire_sprite.width = wire_sprite.height = 2;
						wire_sprite.offset.set( 7, 7);
					}
				
				AnimImporter.loadGraphic_from_data_with_id(spark, 16, 16, "HurtEffectGroup", 0);
				wire_sprite.animation.play("on",true);
				animation.play("on",true);
				props.set("dmgtype", 1);
			default:
				
		}
		
		if (wire_sprite.animation.getByName("on_dim") != null) {
			animData = wire_sprite.animation.getByName("on_dim")._frames;
			animFPS = wire_sprite.animation.getByName("on_dim").frameRate;
		} else {
			animData = [0, 1];
			animFPS = 20;
		}
		
		spark.visible = false;
	}
	
	private var animData:Array<Int>;
	private var animFPS:Int  = 0;
	private var animIndices:Array<Array<Int>>;
	private var animTime:Array<Array<Float>>;
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", 0);
		p.set("dmgtype", 0);
		p.set("wire_tile_width", 3);
		p.set("children", "");
		//p.set("child_colors", "");
		p.set("max_energy", 32);
		p.set("is_gauntlet", 1); // does gauntlet saving behavior
		p.set("s_save", 0);
		p.set("start_state", 0); // On, dark off, light off
		p.set("saves_state", 0);
		p.set("is_ring", 0);
		p.set("is_dream", 0);
		return p;
	}
	public var max_energy:Int = 32;
	private var save_state:Int = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		props.remove("child_colors");
		vistype = props.get("vistype");
		wire_tile_width = props.get("wire_tile_width");
		energy = 0;
		max_energy = props.get("max_energy");
		is_ring = false;
		if (props.get("is_ring") == 1) {
			is_ring = true;
			//wire_sprite.scale.set(3, 3);
		}
		// Doesn't save, always start in specified state
		if (props.get("saves_state") == 0) {
			save_state = props.get("start_state"); 
		} else { // Do save, load the last saved state
			save_state = props.get("s_save");
		}
		
		is_dream = 1 == props.get("is_dream");
		// If it is a gauntlet and you're not in a gauntlet then just re-init
		//if (props.get("is_gauntlet") == 1 && R.gauntlet _manager.active_gauntlet_id == "") {
			// read start_state
			save_state = props.get("start_state");
			props.set("s_save", props.get("start_state"));
		//} else if (props.get("is_gauntlet") == 1) {
			//save_state = props.get("s_save");
		//}
		
		if (save_state == 0) {
			
		} else if (save_state == 1) {
			dark_off = true;
			energy = max_energy;
			animation.play("off");
			wire_sprite.animation.play("off");
		} else if (save_state == 2) {
			light_off = true;
			energy = -max_energy;
			animation.play("off");
			wire_sprite.animation.play("off");
		}
		
		change_visuals();
		dmgtype = props.get("dmgtype");
	}
	
	private var light_off:Bool = false;
	private var dark_off:Bool = false;
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == C.MSGTYPE_ENERGIZE_TICK_DARK || message_type == C.MSGTYPE_ENERGIZE_DARK) {
			if (energy == -max_energy + 1) {
				light_off = true;
				if (can_send) broadcast_to_children("light_off");
				can_send = false;
				props.set("s_save", 2);
				if (dmgtype == 1) { animation.play("off"); wire_sprite.animation.play("off"); }
			}
			energy = Std.int(Math.max( -max_energy, energy - 1));
			
			if (energy == 0 && can_send)  {
				can_send = false;
				light_off = dark_off = false;
				broadcast_to_children("back_on");
				props.set("s_save", 0);
				animation.play("on"); wire_sprite.animation.play("on");
			}
		} else if (message_type == C.MSGTYPE_ENERGIZE_TICK_LIGHT || message_type == C.MSGTYPE_ENERGIZE_LIGHT) {
			if (energy == max_energy - 1) {
				if (can_send) broadcast_to_children("dark_off");
				dark_off = true;
				can_send = false;
				props.set("s_save", 1);
				if (dmgtype == 0) { animation.play("off"); wire_sprite.animation.play("off"); }
			}
			energy = Std.int(Math.min(max_energy, energy + 1));
			
			if (energy == 0 && can_send)  {
				can_send = false;
				light_off = dark_off = false;
				broadcast_to_children("back_on");
				props.set("s_save", 0);
				animation.play("on"); wire_sprite.animation.play("on");
			}
		} else if (message_type == "dark_off") {
			dark_off = true;
			props.set("s_save", 1);
			if (can_send)  broadcast_to_children("dark_off");
			can_send = false;
			if (dmgtype == 0) { animation.play("off"); wire_sprite.animation.play("off"); }
		} else if (message_type == "light_off") {
			light_off = true;
			props.set("s_save", 2);
			if (can_send) broadcast_to_children("light_off");
			can_send = false;
			if (dmgtype == 1) { animation.play("off"); wire_sprite.animation.play("off"); }
		} else if (message_type == "back_on") {
			if (can_send)  broadcast_to_children("back_on");
			light_off = dark_off = false;
			props.set("s_save", 0);				
			animation.play("on"); wire_sprite.animation.play("on");
		}
		
		return 0;
	}
	override public function destroy():Void 
	{
		ACTIVE_BarbedWires.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [wire_sprite,spark],4);
		super.destroy();
	}
	
	private var t_osc:Float = 0;
	private var ctr_osc:Int = 0;
	private var child_colors:Array<Int>;
	private var can_send:Bool = true;
	private var killpt:Point;
	private var killpt2:Point;
	
	private var killwat:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		can_send = true;
		
		if (props.get("is_ring") == 1) {
			if (FlxX.circle_flx_obj_overlap(x + 8, y + 8, 24, R.player)) {
				if (R.player.facing == FlxObject.RIGHT) {
					R.player.do_hor_push( -100, false, true, 5);
				} else {
					R.player.do_hor_push( 100, false, true, 5);
				}
				R.player.do_vert_push(200);
				
				R.sound_manager.play(SNDC.OuchOutlet_Shock);
				if (dmgtype == 0) {
					R.player.add_dark(8);
				} else {
					R.player.add_light(8);
				}
			}
		}
		
		t_osc += FlxG.elapsed;
		if (t_osc > 0.1) {
			t_osc -= 0.1;
			ctr_osc += 6; 
			if (ctr_osc >= 360) ctr_osc = 0;
		}
		this.y = iy + 3.0 * FlxX.sin_table[ctr_osc];
		if (killwat > 0) {
			killwat --;
		}
		
		for (child in children) {
			if (is_dream) break;
			if ((dark_off && dmgtype == 0) || (light_off && dmgtype == 1)) {
				break;
			} else 
			
						R.player.width += 64; R.player.height += 64; R.player.y -= 32; R.player.x -= 32;
						if (HF.ray_intersects_box(x + width / 2, y + 2, (child.x + child.width / 2) - (x + width / 2), child.y - y, R.player, 1, 0.01)) {
							if (ID == 0) {
								R.sound_manager.play(SNDC.followLaserNear);
							}
							ID ++;
							if (ID == 30) ID = 0;
						} else { ID = 0; }	
						R.player.width -= 64; R.player.height -= 64; R.player.y += 32; R.player.x += 32;
			
			
			if (HF.ray_intersects_box(x + width / 2, y + 2, (child.x + child.width / 2) - (x + width / 2), child.y - y, R.player, 1, 0.01)) {
				if (killwat > 0) {
					break;
				}
				killplayer = true;
				killwat = 5;
				R.sound_manager.play(SNDC.OuchOutlet_Shock);
				//R.player.skip_motion_ticks = 5;
				killpt = new Point(child.x + child.width / 2, child.y);
				killpt2 = new Point(x + width / 2, y + 2);
					
				if (dmgtype == 0) { // dark
					R.player.add_dark(64);
				} else {
					R.player.add_light(64);
				}
				break;
			}
		}
		if (killplayer) {
			
			var on_pos_side:Bool = false;
			//here M(X,Y) is the query point:

//position = sign( (Bx-Ax)*(Y-Ay) - (By-Ay)*(X-Ax)

			var det:Float = (killpt2.x - killpt.x) * ((R.player.y + 5) - killpt.y) - ((killpt2.y - killpt.y) * (R.player.x + 4 - killpt.x));
			if (det > 0) {
				on_pos_side = true;
			}
			
			// now find side of perp vector rotating - 90 deg
			var vec:Point = new Point();
			var vecadd:Point = new Point();
			vec.setTo(killpt2.x - killpt.x, killpt2.y - killpt.y);
			vecadd.setTo( -vec.y + killpt.x, vec.x+killpt.y);
			
			
			
			det = (killpt2.x - killpt.x) * (vecadd.y - killpt.y) - (killpt2.y - killpt.y) * (vecadd.x - killpt.x);
			vec.setTo(vecadd.x - killpt.x, vecadd.y - killpt.y);
			if (det >= 0 && on_pos_side) {
				HF.scale_velocity(R.player.velocity, new FlxObject(0, 0, 1, 1), new FlxObject(vec.x, vec.y, 1, 1), 300);
				//Log.trace("pos");
				R.player.do_vert_push(R.player.velocity.y);
				R.player.do_hor_push(Std.int(R.player.velocity.x), false, true, 3);
			} else {
				HF.scale_velocity(R.player.velocity, new FlxObject(0, 0, 1, 1), new FlxObject( -vec.x, -vec.y, 1, 1), 300);
				R.player.do_vert_push(R.player.velocity.y);
				R.player.do_hor_push(Std.int(R.player.velocity.x), false, true, 3);
				//Log.trace("neg");
			}
			
			

			//R.player.velocity.y = 0;
			//R.player.velocity.x = 0;
			
			
			
		}
		killplayer = false;
		
		if (!did_init) {
			did_init = true;
			ACTIVE_BarbedWires.add(this);
			populate_parent_child_from_props();
			animIndices = [];
			animTime = [];
			for (child in children) {
				animIndices.push([]);
				animTime.push([]);
			}
			HF.add_list_to_mysprite_layer(this, parent_state, [wire_sprite,spark],4);
		}
		super.update(elapsed);
	}
	
	
	public function generic_overlap(o:FlxObject):Bool {
		
		for (child in children) {
			if ((dark_off && dmgtype == 0) || (light_off && dmgtype == 1)) {
				return false;
			} else {
				if (HF.ray_intersects_box(x + width / 2, y + 2, (child.x + child.width / 2) - (x + width / 2), child.y - y, o, 1, 0.01)) {
					return true;	
				}
			}
		}
		return false;
	}
	
	private var killplayer:Bool = false;
	
	private var dim_array:Array<Array<Int>>;
	
	private var t_spark:Float = 0;
	private var tm_spark:Float = 0;
	private var spark_idx:Int = 0;
	private var spark_child_idx:Int = 0;
	override public function draw():Void 
	{
		
		if (is_dream) {
			if (parents.length > 0 && parents[0].width > 32) {
				move(parents[0].x - 6 + parents[0].width/2, parents[0].y + parents[0].height);
			}
		}
		
		if (dim_array == null) {
			dim_array = [];
			tm_spark = 0.2 + 0.4 * Math.random();
			spark.offset.y = 0;
		}
		
		
		
		while (children.length > dim_array.length) {
			dim_array.push([]);
		}
		wire_sprite.visible = true;
		wire_sprite.x = this.x - 1 + this.width / 2;
		wire_sprite.y = this.y - 1 	+ this.height / 2;
		var ox:Float = wire_sprite.x;
		var oy:Float = wire_sprite.y;
		
		if (is_ring) {
			wire_sprite.visible = true;
			wire_sprite.x = x - 16;
			wire_sprite.y = y - 16;
			wire_sprite.draw();
		}
		
		spark.visible = true;
		
		var idx:Int = 0;
		for (child in children) {
			var dis:Float = HF.get_midpoint_distance(child, this);
			var nr_dots:Int = Std.int(dis / 12 ) + 1;
			
			
			if (is_dream) {
				nr_dots = Std.int(dis / 22) + 1;
				if (parents.length > 0) {
					nr_dots = 11;
				}
			}
			
			if (dim_array[idx].length < nr_dots) {
				dim_array[idx] = [];
				for (i in 0...nr_dots) {
					dim_array[idx].push(0);
				}
			}
			
			if (animTime != null) {
				if (animTime.length < idx + 1) {
					animTime.push([]);
					animIndices.push([]);
				}
				if (animTime[idx].length <= 0) {
					for (i in 0...nr_dots) {
						animTime[idx].push(0);
						animIndices[idx].push(-1);
					}
				}
			}
			
			
			if (spark.animation.finished) {
				t_spark += (FlxG.elapsed / children.length);
				if (t_spark > tm_spark) {
					if (dmgtype == 0) {
						spark.animation.play("d"+Std.string(Std.int(5*Math.random())), true);	
					} else {
						spark.animation.play("l"+Std.string(Std.int(5*Math.random())), true);
					}
					t_spark = 0;
					spark_idx = Std.int(Math.random() * dim_array[idx].length);
					spark_child_idx = idx;
					var ranx:Float = 8 * Math.random();
					var rany:Float = Math.sqrt(64 - ranx * ranx);
					if (Math.random() > 0.5) rany *= -1;
					if (Math.random() > 0.5) ranx *= -1;
					spark.x = ranx;
					spark.y = rany;
					//spark.angle = Math.random() * 360;
				} 
			} 
			
			var x_space:Float = (child.x - x) / (nr_dots + 1);
			var y_space:Float = (child.y - y) / (nr_dots + 1);
			
			if (is_dream) {
				wire_sprite.alpha = 0.4;
			}
			
			
			wire_sprite.x = ox + x_space * (nr_dots+1);
			wire_sprite.y = oy + y_space * (nr_dots + 1); 	
			
			var dont_be_on:Bool = false;
			if ((dark_off && dmgtype == 0) || (light_off && dmgtype == 1)) {
				dont_be_on = true;
			}
			
			for (i in 0...nr_dots) {
				if (is_dream) {
					if (R.inventory.is_item_found(12)) {
						wire_sprite.alpha *= 1.1;
					} else {
						wire_sprite.alpha *= 1.02;
					}
				}
				
				if (animIndices != null) {
					if (!dont_be_on) {
						
						if (animIndices[idx][i] != -1) {
							animTime[idx][i] += 1.0 / FlxG.drawFramerate;
							if (animTime[idx][i] > 1.0 / animFPS) {
								animTime[idx][i] -= (1.0 / animFPS);
								animIndices[idx][i] ++;
								if (animIndices[idx][i] == animData.length) {
									animIndices[idx][i] = -1;
									animTime[idx][i] = 0;
								}
							}
							wire_sprite.animation.play("on_dim", true);
							wire_sprite.animation.curAnim.curFrame = animIndices[idx][i];
						} else {
							wire_sprite.animation.play("on", true);
							
						}
					}
					if (Math.random() < 0.012 && animIndices[idx][i] == -1) {
						animIndices[idx][i] = 0;
					}
				}
				wire_sprite.x -= x_space;
				wire_sprite.y -= y_space;
				wire_sprite.draw();
				
				
				if (!dont_be_on && i == spark_idx && spark_child_idx == idx && !spark.animation.finished) {
					
					var oox:Float = spark.x;
					var ooy:Float = spark.y;
					spark.x += wire_sprite.x - 7;
					spark.y += wire_sprite.y - 7 - spark.offset.y;
					if (!is_dream) spark.draw();
					spark.move(oox, ooy);
				}
			}
			wire_sprite.x = ox;
			wire_sprite.y = oy;
			idx ++;
		}
		wire_sprite.visible = false;
		spark.visible = false;
		if (is_dream) alpha = wire_sprite.alpha;
		super.draw();
	}
	
	
	public function generic_circle_overlap(cx:Float, cy:Float, cr:Float, only_dmgtype:Int):Bool {
		
		
		if ((dark_off && dmgtype == 0) || (light_off && dmgtype == 1)) {
			return false;
		}
		
		if (this.dmgtype != only_dmgtype && only_dmgtype!= -1) {
			return false;
		} 
		if (children == null || children == []) return false;
		
		var ox:Float = this.x - 1 + this.width / 2;
		var oy:Float =  this.y - 1 	+ this.height / 2;
		
		var seg_a:Point = new Point(ox, oy);
		var seg_b:Point = new Point();
		var circ_pos:Point = new Point(cx, cy);
		var circ_rad:Float = cr;
		var seg_v:Point = new Point();
		var pt_v:Point = new Point();
		var proj_v:Point = new Point();
		var seg_v_unit:Point = new Point();
		var closest:Point = new Point();
		var dist_v:Point = new Point();
		for (child in children) {
			if (child == null) continue;
			//Log.trace("checking!");
			seg_b.setTo(child.x - 1 + child.width / 2, child.y - 1 + child.height / 2);
			seg_v.setTo(seg_b.x - seg_a.x, seg_b.y - seg_a.y);
			pt_v.setTo(circ_pos.x - seg_a.x, circ_pos.y - seg_a.y);
			var seg_v_mag:Float = Math.sqrt(seg_v.x * seg_v.x + seg_v.y * seg_v.y);
			
			
			seg_v_unit.setTo(seg_v.x / seg_v_mag, seg_v.y / seg_v_mag);
			
			var norm_proj_v:Float = seg_v_unit.x * pt_v.x + seg_v_unit.y * pt_v.y;
			if (norm_proj_v < 0) {
				closest.setTo(seg_a.x, seg_a.y);
			} else if (norm_proj_v > seg_v_mag) {
				closest.setTo(seg_b.x, seg_b.y);
			} else {
				proj_v.setTo(norm_proj_v * seg_v_unit.x, norm_proj_v * seg_v_unit.y);
				closest.setTo(seg_a.x + proj_v.x, seg_a.y + proj_v.y);
			}
			dist_v.setTo(circ_pos.x - closest.x, circ_pos.y - closest.y);
			if (dist_v.x * dist_v.x + dist_v.y * dist_v.y < circ_rad * circ_rad) {
				//Log.trace([dmgtype, only_dmgtype]);
				return true;
			}
			
		}
		
		
		return false;
	}
	
	
}