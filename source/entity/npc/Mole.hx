package entity.npc;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import autom.SNDC;
import entity.MySprite;
import entity.trap.Pod;
import entity.trap.SapPad;
import entity.util.RaiseWall;
import entity.util.VanishBlock;
import flash.geom.Point;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import state.MyState;

class Mole extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		lightMole = new FlxSprite();
		darkMole = new FlxSprite();
		super(_x, _y, _parent, "Mole");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Mole");
				AnimImporter.loadGraphic_from_data_with_id(lightMole, 16, 16, "Mole","color");
				AnimImporter.loadGraphic_from_data_with_id(darkMole, 16, 16, "Mole","color");
		}
	}

	private var lightMole:FlxSprite;
	private var darkMole:FlxSprite;
	public static var ACTIVE_Mole:List<Mole>;
	private var energy:Float = 0;
	private var max_energy:Float = 128;
	private var x_vel_bounds:Point;
	private var y_vel_bounds:Point;
	private var turns_right:Bool = true;
	private var dir:Int = 1;
	
	private var bar_bg:FlxSprite;
	private var bar:FlxSprite;
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("init_energy", 64);
		p.set("max_energy", 128);
		p.set("vel_bounds", "50,100,50,100");
		p.set("turns_right", 1); 
		p.set("init_dir", 1); // urdl
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		energy = props.get("init_energy");
		max_energy = props.get("max_energy");
		turns_right = props.get("turns_right");
		dir = props.get("init_dir");
		var i:Array<Int> = HF.string_to_int_array(props.get("vel_bounds"));
		x_vel_bounds = new Point(i[0], i[1]);
		y_vel_bounds = new Point(i[2], i[3]);
		pt = new FlxPoint();
		pt2 = new FlxPoint();
		change_visuals();
		
		if (bar_bg == null) {
			bar_bg = new FlxSprite();
			bar_bg.makeGraphic(1, 4, 0xff000000);
			bar = new FlxSprite();
			bar.makeGraphic(1, 4, 0xffffffff);
			bar_bg.scale.x = 16;
		}
		set_vel();
	}
	
	private function set_vel():Void {
		if (dir == 0 || dir == 2) { // U / D
			velocity.x = 0;
			velocity.y = y_vel_bounds.x + (y_vel_bounds.y - y_vel_bounds.x) * (energy / max_energy);
			
			lightMole.animation.play("uLight");
			darkMole.animation.play("uDark");
			animation.play("u");
				darkMole.scale.x = lightMole.scale.x = scale.x = 1;
			if (dir == 0) {
				velocity.y *= -1;
				darkMole.angle = lightMole.angle = angle = 0;
			} else {
				darkMole.angle = lightMole.angle = angle = 180;
			}
		} else { // L  / R
			velocity.x = x_vel_bounds.x + (x_vel_bounds.y - x_vel_bounds.x) * (1 - (energy / max_energy));
			velocity.y = 0;
			lightMole.animation.play("rLight");
			darkMole.animation.play("rDark");
			animation.play("r");
				darkMole.angle = lightMole.angle = angle = 0;
			if (dir == 3) {
				velocity.x *= -1;
				darkMole.scale.x = lightMole.scale.x = scale.x = -1;
			} else {
				darkMole.scale.x = lightMole.scale.x = scale.x = 1;
			}
		}
	}
	
	function setIdleAnim(sapping:Bool = false ):Void 
	{
		if (!sapping) dir = props.get("init_dir");
		HF.round_to_16(this);
		HF.round_to_16(this,false);
		darkMole.angle = lightMole.angle = angle = 0;
		darkMole.scale.x = lightMole.scale.x = scale.x = 1;
		animation.play("u_idle"); darkMole.animation.play("uDark_idle"); lightMole.animation.play("uLight_idle");
		switch (dir) { // init dir
			case 0:
			case 1:
				animation.play("r_idle"); darkMole.animation.play("rDark_idle"); lightMole.animation.play("rLight_idle");
			case 2:
				darkMole.angle = lightMole.angle = angle = 180;
			case 3:
				darkMole.scale.x = lightMole.scale.x = scale.x = -1;
				animation.play("r_idle"); darkMole.animation.play("rDark_idle"); lightMole.animation.play("rLight_idle");
		}
	}
	override public function destroy():Void 
	{
		
		ACTIVE_Mole.remove(this);
			//HF.remove_list_from_mysprite_layer(this, parent_state,[lightMole,darkMole,bar_bg, bar]);
			HF.remove_list_from_mysprite_layer(this, parent_state,[lightMole,darkMole]);
		super.destroy();
	}
	var pt:FlxPoint;
	var pt2:FlxPoint;
	override public function preUpdate():Void 
	{
		
		//if (velocity.x != 0 || velocity.y != 0 ){
		for (raise_wall in RaiseWall.ACTIVE_RaiseWalls.members) {
			if (raise_wall != null) {
				if (raise_wall.overlapsPoint(pt) || raise_wall.overlapsPoint(pt2)) {
					touching = FlxObject.ANY;
					//velocity.set(0, 0);
				}
			}
		}
		for (vb in VanishBlock.ACTIVE_VanishBlocks) {
			if (vb != null && !vb.is_open) {
				if (vb.overlapsPoint(pt) || vb.overlapsPoint(pt2)) {
					touching = FlxObject.ANY;
					//velocity.set(0, 0);
				}
			}
		}
		//}
		for (p in Pod.ACTIVE_PodSwitches) {
			if (p.generic_overlap(this)) {
				p.flip_switch = true;
			}
		}
	
		super.preUpdate();
	}
	
	private var t_pulse:Float = 0;
	private var mode:Int = 0;
	private var home_base_mode:Int = 0;
	private var return_home:Bool = false;
	private var in_sapping_mode:Bool = false;
	private var skip_wall_ticks:Int = 0;
	private var t_fx:Float = 0;
	
	public function add_energy(is_light:Bool = false, amt:Int):Void {
		if (is_light) {
			energy += amt;
		} else {
			energy -= amt;
		}
		if (energy > max_energy) energy = max_energy;
		if (energy < 0) energy = 0;
	}
	private var pt3:FlxPoint;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			ACTIVE_Mole.add(this);
			//HF.add_list_to_mysprite_layer(this, parent_state, [lightMole,darkMole,bar_bg, bar]);
			HF.add_list_to_mysprite_layer(this, parent_state, [lightMole,darkMole]);
			did_init = true;
		}
		
		//bar.x = this.x + width / 2;
		//bar.y = this.y - 4;
		//bar_bg.x = bar.x; bar_bg.y = bar.y;
		//
		//if (energy > max_energy / 2) {
			//bar.color = 0xffffff;
			//bar.scale.x = (((max_energy/2) - (max_energy - energy)) / (max_energy / 2)) * 16;
		//} else {
			//bar.color = 0xff00ff;
			//bar.scale.x = ((max_energy / 2 - energy) / (max_energy / 2)) * 16;
		//}
		
		for (sap_pad in SapPad.ACTIVE_REVERSE_SapPads) {
			if (mode != 4 && sap_pad.detector.overlaps(this)) {
				var amt:Int = sap_pad.external_get_reverse(1);
				if (!in_sapping_mode && amt != 0) {
					in_sapping_mode = true;
				} else if (in_sapping_mode && (amt == 0 || energy == 0 || energy == max_energy)) {
					in_sapping_mode = false;
				}
				
				if (in_sapping_mode) {
					if (x < (sap_pad.detector.x + sap_pad.detector.width / 2) - width / 2) {
						x += 0.25;
					} else if (x > (sap_pad.detector.x + sap_pad.detector.width / 2) - width/2) {
						x -= 0.25;
					}
					if (Math.abs((x + width / 2) - (sap_pad.detector.x + sap_pad.detector.width / 2)) < 0.5) {
						x =  (sap_pad.detector.x + sap_pad.detector.width / 2) - width / 2;
					}
				}
				energy += amt;
				if (energy < 0) energy = 0;
				if (energy > max_energy) energy = max_energy;
				set_vel();
			}
		}
		
		for (sap_pad in SapPad.ACTIVE_NORMAL_SapPads) {
			if (sap_pad.detector.overlaps(this) && (Math.abs(this.getMidpoint(pt3).x - (sap_pad.detector.x + sap_pad.detector.width / 2)) < 2)) {
				if (energy > max_energy / 2) { // give light
					if (sap_pad.try_to_give(true, 1)) { // give to light sap pad
						energy -= 1;
						if (energy < max_energy / 2) energy = max_energy / 2;
						in_sapping_mode = true;
					} else {
						in_sapping_mode = false;
					}
				} else if (energy < max_energy/2) {
					if (sap_pad.try_to_give(false, 1)) {
						energy += 1;
						if (energy > max_energy / 2) energy = max_energy / 2;
						in_sapping_mode = true;
					} else {
						in_sapping_mode = false;
					}
				} else {
					in_sapping_mode = false;
				}
				
				if (in_sapping_mode) {
					R.sound_manager.play(SNDC.SapPad);
					x = (sap_pad.detector.x + sap_pad.detector.width / 2) - width / 2;
					set_vel();
					setIdleAnim(true);
				} else {
					if (!wait_for_turn) {
						set_vel();
					}
				}
			}
		}
		
		
		// Set mole alphas
		
		if (energy >= max_energy / 2) {
			darkMole.alpha = 0;
			// (e - 64) / 64, e in [64,128]
			// .75 and .25 here bc heh whatever
			lightMole.alpha = (energy - (max_energy / 2)) / (max_energy / 4);
			if (lightMole.alpha >= 0.6 && lightMole.alpha <= 0.95) {
				lightMole.alpha = 0.6;
			} else if (lightMole.alpha> 0.95) {
				lightMole.alpha = 1;
				t_pulse += elapsed;
				if (t_pulse > 0.5) {
					t_pulse -= 0.5;
				}
				var pulseIdx:Int = Std.int(360 * (t_pulse / 0.5));
				lightMole.alpha = 0.8 + 0.2 * FlxX.sin_table[pulseIdx];
			}
		} else {
			lightMole.alpha = 0;
			// (64 - e) / 64, e in [0,64]
			darkMole.alpha = ((max_energy / 2) - energy) / (max_energy / 4);
			if (darkMole.alpha >= 0.6 && darkMole.alpha <= 0.95) {
				darkMole.alpha = 0.6;
			} else if (darkMole.alpha > 0.95) {
				darkMole.alpha = 1;
				t_pulse += elapsed;
				if (t_pulse > 0.5) {
					t_pulse -= 0.5;
				}
				var pulseIdx:Int = Std.int(360 * (t_pulse / 0.5));
				darkMole.alpha = 0.8 + 0.2 * FlxX.sin_table[pulseIdx];
			}
		}
		
		if (mode == home_base_mode) {
			
				x = ix; y = iy;
			if (energy > .75 * max_energy || energy < .25 * max_energy) {
				mode = 1;
				R.sound_manager.play(SNDC.mole, 0.75, true, this);
			} else {
				wait_for_turn = false;
				setIdleAnim();
				velocity.x = velocity.y = 0;
			}
			
			super.update(elapsed);
			return;
		} else if (mode == 1) { // Travel, stopping at vanishblocks or mode switching from return home
			t_fx += elapsed;
			if (t_fx > 0.15) {
				t_fx -= 0.15;
				if (energy < 0.5 * max_energy) {
					R.player.HurtEffects.release(1, false, x - 5+ width / 2, y - 5 + height / 2);
				} else {
					R.player.HurtEffects.release(1, true, x -5 + width / 2, y - 5+ height / 2);
				}
			}
			
			if (!in_sapping_mode && !wait_for_turn) {
				R.sound_manager.play(SNDC.molewalk, 1, true, this);
			}
		
				// below mole will turn
			if (touching == FlxObject.ANY && !wait_for_turn) { //touched a vanishblock
				mode = 2;
				//velocity.set(0, 0);
				//energy = 64;
				//return_home = true;
				setIdleAnim(true);
				super.update(elapsed);
				return;
			}
		} else if (mode == 2 && !wait_for_turn) { // touching block, waiting for it todisappear
			velocity.x = velocity.y = 0;
			if (touching != FlxObject.ANY) {
				set_vel();
				mode = 1;
			}
			super.update(elapsed);
			return;
		} else if (mode == 3) { // return back
			
				R.sound_manager.play(SNDC.molewalk, 1, true, this);
			if (wait_for_turn == false) {
			set_vel();
			if ((ix - x) * (ix - x) + (iy - y) * (iy - y) < 9) {
				mode = 4;
				
				R.sound_manager.play(SNDC.mole, 0.75, true, this);
				if (dir == 1 && 3 == props.get("init_dir")) {
					animation.play("xr2l"); lightMole.animation.play("xr2ll"); darkMole.animation.play("xr2ld");
				wait_for_turn = true;
				R.sound_manager.play(SNDC.lens_attach,0.5);
				scale.x = lightMole.scale.x = darkMole.scale.x = 1;
				} else if (dir == 3 && 1 == props.get("init_dir")) {
					animation.play("xl2r"); lightMole.animation.play("xl2rl"); darkMole.animation.play("xl2rd");
				wait_for_turn = true;
				R.sound_manager.play(SNDC.lens_attach,0.5);
				scale.x = lightMole.scale.x = darkMole.scale.x = 1;
				}
				velocity.set(0, 0);
				x = ix; y = iy;
				angle = lightMole.angle = darkMole.angle = 0;
			}
			}
			
			// If touching vanishblock while returning hme dont move
			if (touching == FlxObject.ANY) {
				setIdleAnim(true);
				velocity.set(0, 0);
				super.update(elapsed);
				return;
			}
			
		} else if (mode == 4) {
			if (animation.finished) {
				wait_for_turn = false;
			}
			if (wait_for_turn == false) {
				mode = home_base_mode;
			}
			super.update(elapsed);
			return;
		}
		
		if (in_sapping_mode && mode != 3) {
			if (mode == 1 && (ix - x) * (ix - x) + (iy - y) * (iy - y) > 256) {
				return_home = true;
			}
			velocity.x = velocity.y = 0;
			
			super.update(elapsed);
			return;
		} else {
			if (return_home) {
				return_home = false;
				mode = 3;
				set_vel();
			}
		}
		
		var b:Bool = false;
		
			var turnTwice:Bool = false;
		if (skip_wall_ticks > 0) {
			skip_wall_ticks --;
			b = false; 	
		} else {
			// turn at walls if not overallping moletile
			switch (dir) {
				case 0: // u
					if (touching != 0 || 0!=parent_state.tm_bg.getTileCollisionFlags(x + width / 2, y-1)) {
						b = true;
							animation.play("xur"); lightMole.animation.play("xurl"); darkMole.animation.play("xurd");
						turnTwice = true;
					}
				case 1:
					if (touching != 0 || 0!=parent_state.tm_bg.getTileCollisionFlags(x+width,y+height/2)) {
						b = true;
							animation.play("xr2l"); lightMole.animation.play("xr2ll"); darkMole.animation.play("xr2ld");
						turnTwice = true;
					}
				case 2:
					if (touching != 0 || 0!=parent_state.tm_bg.getTileCollisionFlags(x+width/2,y+height)) {
						b = true;
							animation.play("xdl"); lightMole.animation.play("xdll"); darkMole.animation.play("xdld");
						turnTwice = true;
					}
				case 3:
					if (touching != 0 || 0!=parent_state.tm_bg.getTileCollisionFlags(x - 1,y+height/2)) {
						b = true;
							animation.play("xl2r"); lightMole.animation.play("xl2rl"); darkMole.animation.play("xl2rd");
						turnTwice = true;
					}
			}
			
			if (animation.curAnim != null && animation.curAnim.name.indexOf("x") != -1) {
				wait_for_turn = true;
				
				R.sound_manager.play(SNDC.lens_attach,0.5);
			}
		}
		
		if (b || touching != 0) {
			if (turns_right) {
				dir = (dir + 1) % 4;
			} else {
				dir--; if (dir < 0) dir = 3;
			}
			if (turnTwice) {
				if (turns_right) {
					dir = (dir + 1) % 4;
				} else {
					dir--; if (dir < 0) dir = 3;
				}
			}
			//set_vel();
		}
		var skip_wall:Bool = false;
		for (mole_tile  in MoleTile.ACTIVE_MoleTiles) {
			if (!wait_for_turn && mole_tile.is_off == false && overlaps(mole_tile)) {
				if (energy <= max_energy / 2 && mole_tile.light_only) { // Darker
					continue;
				} else if (energy >= max_energy / 2 && mole_tile.dark_only) { // lighter
					continue;
				}
				switch (mole_tile.dir) {
					case 0: // ur
						if (dir == 2 || dir == 3) skip_wall = true;
						if (dir == 2 && y + height > mole_tile.y + mole_tile.height) {
							dir = 1; y = mole_tile.y;
							animation.play("xdr"); lightMole.animation.play("xdrl"); darkMole.animation.play("xdrd");
						} else if (dir == 3 && x < mole_tile.x) {
							dir = 0; x = mole_tile.x; 
							animation.play("xlu"); lightMole.animation.play("xlul"); darkMole.animation.play("xlud");
						}
					case 1: // dr
						if (dir == 0 || dir == 3) skip_wall = true;
						if (dir == 0 && y < mole_tile.y) {
							dir = 1; y = mole_tile.y;
							animation.play("xur"); lightMole.animation.play("xurl"); darkMole.animation.play("xurd");
						} else if (dir == 3 && x < mole_tile.x) {
							dir = 2; x = mole_tile.x;
							animation.play("xld"); lightMole.animation.play("xldl"); darkMole.animation.play("xldd");
						}
					case 2:
						if (dir == 0 || dir == 1) skip_wall = true;
						if (dir == 0 && y < mole_tile.y) {
							dir = 3; y = mole_tile.y;
							animation.play("xul"); lightMole.animation.play("xull"); darkMole.animation.play("xuld");
						} else if (dir == 1 && x + width > mole_tile.x + mole_tile.width) {
							dir = 2; x = mole_tile.x;
							animation.play("xrd"); lightMole.animation.play("xrdl"); darkMole.animation.play("xrdd");
						}
					case 3: // ul
						if (dir == 2 || dir == 1) skip_wall = true;
						if (dir == 2 && y + height > mole_tile.y + mole_tile.height) {
							dir = 3; y = mole_tile.y;
							animation.play("xdl"); lightMole.animation.play("xdll"); darkMole.animation.play("xdld");
						} else if (dir == 1 && x + width > mole_tile.x + mole_tile.width ) {
							dir = 0; x = mole_tile.x;
							animation.play("xru"); lightMole.animation.play("xrul"); darkMole.animation.play("xrud");
						}
				}
				if (animation.curAnim != null && animation.curAnim.name.indexOf("x") != -1) {
					wait_for_turn = true;
				}
			}
		}
		if (wait_for_turn) {
			velocity.set(0, 0);
			
			angle = lightMole.angle = darkMole.angle = 0;
			scale.x = lightMole.scale.x = darkMole.scale.x = 1;
			if (animation.finished) {
				set_vel();
				wait_for_turn = false;
			}
		}
		
		if (skip_wall) {
			skip_wall_ticks = 1;
		}
		switch(dir) {
			case 0:
				pt.set(x + 1.5, y - 1);
				pt2.set(x + width - 1.5, y - 1);
			case 1:
				pt.set(x+width,y+height-1.5 );
				pt2.set(x+width,y+1.5 );
			case 2:
				pt.set(x + 1.5, y +height);
				pt2.set(x + width - 1.5, y +height);
			case 3:
				pt.set(x-1,y+height-1.5 );
				pt2.set(x-1,y+1.5 );
				
		}
		
		super.update(elapsed);
	}
	
	private var wait_for_turn:Bool = false;
	override public function draw():Void 
	{
		super.draw();
		
		lightMole.move(x, y);
		darkMole.move(x, y);
	}
}