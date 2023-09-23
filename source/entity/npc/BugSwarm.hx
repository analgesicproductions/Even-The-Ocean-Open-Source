package entity.npc;
import autom.SNDC;
import entity.MySprite;
import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
	class BugSwarm extends MySprite
{
	
	private var bugs:FlxTypedGroup<FlxSprite>;
	private var nr_bugs:Int = 1;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		bugs = new FlxTypedGroup<FlxSprite>();
		super(_x, _y, _parent, "BugSwarm");
		makeGraphic(8, 8, 0xffff0000);
		dest = new FlxObject(0, 0, 2, 2);
		
	}
	
	override public function change_visuals():Void 
	{
		var b:FlxSprite;
		min_xs = HF.array_init_with(min_xs, 0, nr_bugs);
		max_xs = HF.array_init_with(max_xs, 0, nr_bugs);
		min_ys = HF.array_init_with(min_ys, 0, nr_bugs);
		max_ys = HF.array_init_with(max_ys, 0, nr_bugs);
		
		var vel_val:Float = props.get("vel");
		var anims:Array<String> = props.get("anims").split(",");
		bugs.setAll("exists", false);
		switch (vistype) {
			default:
				for (i in 0...nr_bugs) {
					
					if (bugs.length <= i) {
						//b.makeGraphic(2, 2, 0xff000000 + Std.int(0x80*Math.random())*0x00010101);
						b = new FlxSprite();
						bugs.add(b);
					
					} else {
						b = bugs.members[i];
					}
					b.exists = true;
					
					if (props.get("vistype") == 0) {
						AnimImporter.loadGraphic_from_data_with_id(b, 8, 8, "BugSwarm");
					} else {
						AnimImporter.loadGraphic_from_data_with_id(b, 8, 8, "BugSwarm",props.get("vistype"));
					}
					
					b.animation.play(anims[Std.int(anims.length * Math.random())]);
					b.ID = 0;
					b.health = 0;
					bugs.members[i].velocity.x = vel_val + vel_val * Math.random();
					Math.random() > 0.5 ? bugs.members[i].velocity.x *= -1 : 1;
					bugs.members[i].velocity.y = vel_val + vel_val * Math.random();
					Math.random() > 0.5 ? bugs.members[i].velocity.y *= -1 : 1;
					
					bugs.members[i].maxVelocity.set(Math.abs(bugs.members[i].velocity.x), Math.abs(bugs.members[i].velocity.y));
					//bugs.members[i].alpha = 0.75 + 0.25 * Math.random();
					//bugs.members[i].blend = BlendMode.MULTIPLY;
					min_xs[i] = -bug_radius - bug_radius * Math.random();
					min_ys[i] = -bug_radius - bug_radius * Math.random();
					max_xs[i] = bug_radius + bug_radius * Math.random();
					max_ys[i] = bug_radius + bug_radius * Math.random();
					
					bugs.members[i].x = x;
					bugs.members[i].y = y;
				}
				
		}
		// Change visuals
	}
	
	private var bug_radius:Int;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("nr_bugs", 6);
		p.set("follows", 0);
		p.set("bug_radius", 24);
		p.set("anims", "test1,test2");
		p.set("vistype", 0);
		p.set("vel", 12);
		p.set("accel", 55);
		p.set("chase_radius", 300);
		p.set("dontpush", 0);
		//
		return p;
	}
	
	private var dontpush:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dontpush = props.get("dontpush") == 1;
		nr_bugs = props.get("nr_bugs");
		bug_radius = props.get("bug_radius");
		accel = props.get("accel");
		mode = -1;
		change_visuals();
	}
	
	override public function recv_message(message_type:String):Int 
	{
		
		if (message_type == "energize") {
			mode = 69;
			return 1;
		} else if (message_type == "superenergize") {
			bugs.exists = false;
			visible = false;
			mode = 69;
			return 1;
		} else if (message_type == "energize_tick_l") {
			mode = 69;
			return 1;
		}
		return 1;
	}
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [bugs]);
		super.destroy();
	}
	
	
	private var min_xs:Array<Float>;
	private var min_ys:Array<Float>;
	private var max_xs:Array<Float>;
	private var max_ys:Array<Float>;
	
	
	private var overlapping_player:Bool = false;
	
	private var angle_to_player:Float = 0;
	private var t_angle:Float = 0;
	
	private var mode:Int = 0;
	private var dest:FlxObject;
	private var t_circle:Float = 0 ;
	

	private var accel:Float = 55;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ID = 0;
			HF.add_list_to_mysprite_layer(this, parent_state, [bugs]);
		}
		if (R.editor.editor_active) {
			visible = true;
			flicker(1);
		} else {
			visible = false;
		}
		
		if (mode == 69) {
			accel = 0;
			for (i in 0...bugs.length) {
				bugs.members[i].alpha -= 0.004;
			}
			
			if (bugs.members[0].alpha == 0) {
				visible = false;
				mode = 70;
			}
		} else if (mode == 70) {
			return;
		}
		
		if (FlxMath.distanceToPoint(this, R.player.getMidpoint()) < bug_radius) {
			overlapping_player = true;
		} else {
			overlapping_player = false;
		}
		
		var spread_factor:Float = 0.5;
		//if (overlapping_player) spread_factor = 1;
		var b:FlxSprite;
		for (i in 0...bugs.length) {
			b = bugs.members[i];
			//b.x -= (x - ix);
			//b.y -= (y - iy);
			///*
			if (b.velocity.x > 0) {
				if (b.ID == 1 && b.velocity.x >= b.maxVelocity.x) {
					b.acceleration.x = 0;
					b.ID = 0;
				}
				if (b.ID == 0 && b.x > x + spread_factor*max_xs[i]) {
					//b.velocity.x *= -1;
					b.ID = 1;
					b.acceleration.x = -accel;
				}
			} else {
				if (b.ID == 1) {
					if (b.velocity.x <= -b.maxVelocity.x) {
						b.acceleration.x = 0;
						b.ID = 0;
					}
				}
				if (b.ID == 0 && b.x < x + spread_factor*min_xs[i]) {
					//b.velocity.x *= -1;
					b.ID = 1;
					b.acceleration.x = accel;
				}
			}
			
			if (b.velocity.y > 0) {
				if (b.health == 1 && b.velocity.y >= b.maxVelocity.y) {
					b.health = 0;
					b.acceleration.y = 0;
				}
				if (b.health == 0 && b.y > y + spread_factor*max_ys[i]) {
					//b.velocity.y *= -1;
					b.health = 1;
					b.acceleration.y = -accel;
				}
			} else {
				if (b.health == 1 && b.velocity.y <= -b.maxVelocity.y) {
					b.health = 0;
					b.acceleration.y = 0;
				}
				if (b.health == 0 && b.y < y + spread_factor*min_ys[i]) {
					//b.velocity.y *= -1;
					b.health = 1;
					b.acceleration.y = accel;
				}
			}
			//*/
			
			//b.x += (x - ix);
			//b.y += (y - iy);
		}
		
		//if (props.get("follows") == 0) return;
		
		if (R.editor.editor_active) {
			x = ix;
			y = iy;
			return;
		}
		
		
		if (overlapping_player && !dontpush) {
			R.player.animation.play("sru");
			R.player.randomize_draw_pos = true;
			
			R.player.randomize_draw_range = 2;
			if (R.player.facing == FlxObject.RIGHT && R.player.is_in_wall_mode()) {
				R.player.do_hor_push( -50, false, true,10);
			} else if (R.player.facing == FlxObject.LEFT && R.player.is_in_wall_mode()) {
				R.player.do_hor_push( 50, false, true,10);
			} else {
				R.player.velocity.x = 0;
				if (ID == 0) {
					ID = 1;
					R.sound_manager.play(SNDC.OuchOutlet_Shock);
				}
			}
			if (R.player.velocity.y < 0) {
				R.player.velocity.y += 25;
			} 
		} else {
			ID = 0;
			R.player.randomize_draw_pos = false;
		}
		
		super.update(elapsed);
		return;
		
		// below deprecated
		if (mode == 69) {
			acceleration.x = 300;
			super.update(elapsed);
			return;
		}
		
		if (mode != -1) {
			if (Math.sqrt((ix - R.player.x) * (ix - R.player.x) + (iy - R.player.y) * (iy - R.player.y)) > props.get("chase_radius")) {
				velocity.x = velocity.y = 0;
				mode = -1;
				t_circle = 0;
				x = ix;
				y = iy;
				return;
			} 
		} else {
			if (Math.sqrt((ix - R.player.x) * (ix - R.player.x) + (iy - R.player.y) * (iy - R.player.y)) > 32) {
				return;
			} else {
				mode = 0;
			}
		}
		
		if (mode == 0) {
			
			if (R.player.overlaps(this)) {
				mode = 1;
			}
			
			//t_angle += FlxG.elapsed;
			//if (t_angle > 0.05) {
				//t_angle -= 0.05;
				//angle_to_player += 6.3;
				//var r:Float = 32;
				//var mp:FlxPoint = R.player.getMidpoint();
				//if (angle_to_player > 360) angle_to_player = Std.int(angle_to_player) % 360;
				//x = mp.x + 24 * FlxX.cos_table[Std.int(angle_to_player)];
				//y = mp.y - 24 * FlxX.sin_table[Std.int(angle_to_player)];
			//}
			//t_circle += FlxG.elapsed;
			//if (t_circle  >0.3) {
				//mode = 1;
				//t_circle = 0;
			//}
		} else if (mode == 1) {
			x = R.player.x + R.player.width / 2 - 4;
			y = R.player.y + R.player.height / 2 - 4;
			t_fuck += FlxG.elapsed;
			if (t_fuck >= 0.5) {
				t_fuck = 0;
				R.player.do_hor_push(-100, false, true, 5);
			}
			//var mp:FlxPoint = R.player.getMidpoint();
			//angle_to_player = (angle_to_player + 180) % 360;
			//dest.x = mp.x + 32 * FlxX.cos_table[Std.int(angle_to_player)];
			//dest.y = mp.y - 32 * FlxX.sin_table[Std.int(angle_to_player)];
			//HF.scale_velocity(velocity, this, dest, 200);
			//mode = 2;
		} else if (mode == 2) {
			if (this.overlaps(dest)) {
				mode = 0;
				velocity.x = velocity.y = 0;
			} else if (this.overlaps(R.player)) {
				R.player.do_hor_push(Std.int(this.velocity.x), false, true, 5);
			} else if ((x - ix) * (x - ix) + (y - iy) * (y - iy) > props.get("chase_radius")*props.get("chase_radius")) {
				mode = 0;
				velocity.x = velocity.y = 0;
			}
		}
		
		
		super.update(elapsed);
	}
	private var t_fuck:Float = 0;
}