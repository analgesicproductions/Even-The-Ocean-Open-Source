package entity.enemy;
import autom.SNDC;
import entity.MySprite;
import flash.geom.Point;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import global.C;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import state.MyState;

class MovePod extends MySprite
{

	private var poof:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		markers = [new FlxSprite(), new FlxSprite()];
		poof = new FlxSprite();
		super(_x, _y, _parent, "MovePod");
	}
	
	override public function change_visuals():Void 
	{
		AnimImporter.loadGraphic_from_data_with_id(poof, 64, 64, "HurtEffectGroup", "pod_poof");
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name,"0");
				for (marker in markers) {
					AnimImporter.loadGraphic_from_data_with_id(marker, 16, 16, name, "0marker");
					marker.animation.play("idle");
				}
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name,1);
				for (marker in markers) {
					AnimImporter.loadGraphic_from_data_with_id(marker, 16, 16, name, "1marker");
					marker.animation.play("idle");
					
				}
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name,vistype);
				for (marker in markers) {
					AnimImporter.loadGraphic_from_data_with_id(marker, 16, 16, name, Std.string(vistype)+"marker");
				}
		}
		
		animation.play("u",true);
		switch (launch_dir) {
			case 0: angle = 0;
			case 1: angle = 45;
			case 2: angle = 90;
			case 3: angle = 135;
			case 4: angle = 180;
			case 5: angle = 225;
			case 6: angle = 270;
			case 7: angle = 315;
			//case 0: animation.play("u",true);
			//case 1: animation.play("ur",true);
			//case 2: animation.play("r",true);
			//case 3: animation.play("dr",true);
			//case 4: animation.play("d",true);
			//case 5: animation.play("dl",true);
			//case 6: animation.play("l",true);
			//case 7: animation.play("ul",true);
		}
	}
	
	private var launch_dir:Int;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("behavior", 0); // 0 = stationary, 1 = left/right
		p.set("dir", 0); // up (0) to up-left (7)
		p.set("launch_dir", 0);
		p.set("move_vel", 50);
		p.set("tm_reset", 0.5);
		p.set("min_max", "32,32");
		p.set("launch_vel", 250);
		p.set("touch_dmg", 32);
		return p;
	}
	
	private var t_reset:Float;
	private var tm_reset:Float;
	private var launch_vel:Float;
	private var move_vel:Float;
	private var dir:Int;
	private var behavior:Int;
	private var min_max:Array<Float>;
	private var _angle:Int = 0;
	private var markers:Array<FlxSprite>;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		tm_reset = props.get("tm_reset");
		launch_dir = props.get("launch_dir");
		launch_vel = props.get("launch_vel");
		move_vel = props.get("move_vel");
		dir = props.get("dir");
		behavior = props.get("behavior");
		
		var s:String = props.get("min_max");
		if (s.length <= 2) {
			min_max = [0, 0];
		} else {
			var a:Array<Point> = HF.string_to_point_array(props.get("min_max"));
			
			if (a.length > 0) {
				min_max = [];
				min_max.push(a[0].x);
				min_max.push(a[0].y);
			}
		}
		change_visuals();
		if (behavior == 0) {
			markers[0].visible = false;
			markers[1].visible = false;
		} else {
			behavior = 1;
			markers[0].visible = true;
			markers[1].visible = true;
		}
		
		// set marker positions
		// 0 on top, 1 on bottom
		offset.set(3, 3);
		if (dir == 0 || dir == 4) {
			markers[0].x = ix;
			markers[1].x = ix;
			markers[1].y = iy + min_max[1];
			markers[0].y = iy - min_max[0];
		} else {
			markers[0].x = ix - min_max[0];
			markers[1].x = ix + min_max[1];
			if (dir == 2 || dir == 6) {
				markers[0].y = iy;
				markers[1].y = iy;
			} else {
				if (dir == 3 || dir == 7) {
					markers[0].y = iy - min_max[0];
					markers[1].y = iy + min_max[1];
				} else {
					//markers[0].y = iy + frameHeight / 2 + min_max[0] - offset.y;
					markers[0].y = iy + min_max[0];
					markers[1].y = iy - min_max[1];
				}
			}
		}
		velocity.set(0, 0);
		vel_helper(this, move_vel);
		
		if (behavior == 0) {
			velocity.set(0, 0);
		}
		
		width = height = 10;
		
		x = ix + offset.x;
		y = iy + offset.y;
		
	}

	private function vel_helper(thing:FlxSprite, vel:Float,is_launch:Bool=false):Void {
		
		var c:Float = 0.707;
		
		var d:Int = dir;
		if (is_launch) {
			d = launch_dir;
		}
		switch (d) {
			case 0: thing.velocity.y = -vel;
			case 1: thing.velocity.x = vel * c; thing.velocity.y = vel * c * -1;
			case 2: thing.velocity.x = vel;
			case 3: thing.velocity.x = vel * c; thing.velocity.y = vel * c;
			case 4: thing.velocity.y = vel;
			case 5: thing.velocity.x = -vel * c; thing.velocity.y = vel * c;
			case 6: thing.velocity.x = -vel;
			case 7:thing.velocity.x = -vel * c; thing.velocity.y = vel * c*-1;
		}
	}
	private var mode:Int = 0;
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [markers[0],markers[1],poof]);
		super.destroy();
	}
	
	private var poof_mode = 0;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			x = ix + offset.x;
			y = iy + offset.y;
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [markers[0],markers[1],poof]);
		}
		
		
		if (poof_mode == 0) {
			poof.exists = false;
			// set to 1 when hit player
		} else if (poof_mode == 1) {
			poof.exists = true;
			if (dmgtype == 0) {
				poof.animation.play("d_dir", true);
			} else {
				poof.animation.play("l_dir", true);
			}
			poof.angle = angle;
			poof.x = (x + width / 2) - poof.width / 2;
			poof.y = (y + height / 2) - poof.height / 2;
			//poof.x += 30;
			//poof.y += 30;
			//Log.trace(1);
			poof_mode = 2;
		} else if (poof_mode == 2) {
			//Log.trace(2);
			if (poof.animation.finished) {
				poof_mode = 0;
				poof.exists = false;
				
			}
		}
		
		
		// Logic to bounce up/down in a range
		var mx:Float = x + width / 2;
		var my:Float = y + height / 2;
		var imx:Float = ix + offset.x + width / 2;
		var imy:Float = iy + offset.y + height / 2;
		if (dir == 0 || dir == 4) { // Up or down
			if (velocity.y < 0) {
				if (imy - my > min_max[0]) {
					velocity.y *= -1;
				}
			} else {
				if (my - imy > min_max[1]) {
					velocity.y *= -1;
				}
			}
		} else {
			if (velocity.x > 0) {
				if (mx - imx > min_max[1]) {
					velocity.x *= -1;
					if (dir != 2 && dir != 6) {
						velocity.y *= -1;
					}
				}
			} else {
				if (imx - mx > min_max[0]) {
					velocity.x *= -1;
					if (dir != 2 && dir != 6) {
						velocity.y *= -1;
					}
				}
			}
		}
		
		var shield_Dir:Int = R.player.get_shield_dir();
		
		var shield_boost:Bool = false;
		//if (R.player.shield_overlaps(this)) {
			//switch (shield_Dir) {
				//case 0:// up
					//if (launch_dir >= 3 && launch_dir <= 5) {
						//shield_boost = true;
					//}
				//case 1: // right
					//if (launch_dir <= 7 && launch_dir >= 5) {
						//shield_boost = true;
					//}
				//case 2:
					//if (launch_dir == 7 || launch_dir == 0 || launch_dir == 1) {
						//shield_boost = true;
					//}
				//case 3:
					//if (launch_dir >= 1 && launch_dir <= 3) {
						//shield_boost = true;
					//}
			//}
		//}
		
		if (!dmgd && (R.player.overlaps(this) || shield_boost)) {
			R.player.force_no_var_jump = true;
			animation.play("u_off");
			dmgd = true;
			if (dmgtype == 0) {
				R.player.add_dark(props.get("touch_dmg"),2,x+width/2,y+width/2);
			} else {
				R.player.add_light(props.get("touch_dmg"),3,x+width/2,y+width/2);
			}
			poof_mode = 1;
			if (shield_boost) {
				R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
				R.player.skip_motion_ticks = 5;
			} else {
				R.sound_manager.play(SNDC.pop);
			}
			var v:FlxSprite = new FlxSprite();
			vel_helper(v, launch_vel, true);
			//if (v.velocity.y < 0 && R.player.velocity.y < 0) {
				//v.velocity.y += R.player.velocity.y / 3;
			//}
			//var c:Float = shield_boost ? 1.3 : 1;
			var c:Float = shield_boost ? 1 : 1;
			//if (R.player.is_on_the_ground()){
				//R.player.do_hor_push(Std.int(v.velocity.x*c));
			//} else {
				R.player.velocity.x = v.velocity.x * c;
			//}
			R.player.do_vert_push(Std.int(v.velocity.y*c),true);
			
			//var lp:Float = R.player.energy_bar.get_LIGHT_percentage();
			//if (lp> 0.6) {
				//R.player.velocity.y *= 1.2 + (0.3 * ((lp - 0.6) / (0.4)));
			//} else if (lp < 0.4) {
				//R.player.velocity.x *= 1.2 + (0.3 * ((0.4 - lp) / (0.4)));
			//}
		} 
		if (dmgd) {
			t_reset += FlxG.elapsed;
			if (t_reset > tm_reset) {
				t_reset = 0;
				animation.play("u");
				dmgd = false;
				alpha = 1;
			} else if (t_reset > tm_reset / 2 ) {
				animation.play("recover");
			}
			
		}
		super.update(elapsed);
	}
	private var dmgd:Bool = false;
	
	
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == C.MSGTYPE_MOVED_BY_EDITOR) {
			x = ix + offset.x;
			y = iy + offset.y;
		}
		return 0;
	}
	
	override public function postUpdate(elapsed):Void 
	{
	if (R.editor.editor_active && FlxG.keys.pressed.SPACE) {
		} else {
			super.postUpdate(elapsed);
		}
	}
	
	override public function draw():Void 
	{
		if (behavior == 1) {
		if (dir == 2 || dir == 6) {
			// marker 0 always left of marker 1
			markers[0].animation.play("chain", true);
			var ox:Float = markers[0].x;
			var d:Float = ((markers[1].x - markers[0].x));
			for (i in 0...Std.int(d / 16)) {
				markers[0].x += 16;
				markers[0].draw();
			}
			markers[0].x = ox;
			markers[0].animation.play("idle", true);
			markers[1].draw();
		}
		if (dir == 0 || dir == 4) {
			// 0 above 1
			markers[0].animation.play("chain", true);
			var oy:Float = markers[0].y;
			var d:Float = (markers[1].y - markers[0].y);
			for (i in 0...Std.int(d / 16)) {
				markers[0].y += 16;
				markers[0].draw();
			}
			markers[0].y = oy;
			markers[0].animation.play("idle", true);
			markers[1].draw();
			
		}
		}
		super.draw();
	}
	
}