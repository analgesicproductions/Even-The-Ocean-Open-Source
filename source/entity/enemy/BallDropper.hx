package entity.enemy;

import autom.SNDC;
import entity.MySprite;
import entity.util.VanishBlock;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import global.Registry;
import help.AnimImporter;
import help.HF;
import state.MyState;
/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class BallDropper extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		balls = new FlxTypedGroup<FlxSprite>();
		super(_x, _y, _parent, "BallDropper");
	}
	
	public static var ACTIVE_BallDroppers:List<BallDropper>;
	private var balls:FlxTypedGroup<FlxSprite>;
	private var t_shoot:Float = 0;
	private var tm_shoot:Float = 0;
	override public function change_visuals():Void 
	{
		var ball:FlxSprite;
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "dark");
				for (ball in balls.members) {
					if (ball != null) {
						AnimImporter.loadGraphic_from_data_with_id(ball, 16, 16, name, "dark");
					}
				}
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "light");
				for (ball in balls.members) {
					if (ball != null) {
						AnimImporter.loadGraphic_from_data_with_id(ball, 16, 16, name, "light");
					}
				}
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, Std.string(vistype));
				for (ball in balls.members) {
					if (ball != null) {
						AnimImporter.loadGraphic_from_data_with_id(ball, 16, 16, name, Std.string(vistype));
					}
				}
		}
		
		for (ball in balls.members) {
			if (ball != null) {
				ball.exists = false;
				ball.width = ball.height = 8;
				ball.offset.set(4, 4);
				ball.velocity.x = props.get("x_vel");
				ball.acceleration.y = props.get("y_accel");
			}
		}
		animation.play("idle");
		
	}
	
	
	public function generic_overlap(o:FlxObject,only_dmgtype:Int=-1):Bool {
		if (this.dmgtype != only_dmgtype && only_dmgtype != -1) { //1 only light breaks
			return false;
		} 
		if (only_dmgtype == -1) {
			for (ball in balls.members) {
				if (ball != null) {
					if (ball.exists && ball.ID != 1 && ball.overlaps(o)) {
						return true;
					}
				}
			}
		}
		return false;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("nr_balls", 3);
		p.set("damage", 32);
		p.set("y_accel", 520);
		p.set("x_vel", 140);
		p.set("tm_shoot", 1);
		p.set("dampen", 0.8);
		return p;
	}	
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		tm_shoot = props.get("tm_shoot");
		balls.clear();
		for (i in 0...props.get("nr_balls")) {
			var ball:FlxSprite = new FlxSprite();
			balls.add(ball);
		}
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		ACTIVE_BallDroppers.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [balls]);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_BallDroppers.add(this);
			
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [balls]);
		}
		
		t_shoot += FlxG.elapsed;
		if (t_shoot > tm_shoot) {
			t_shoot = 0;
			for (i in 0...balls.length) {
				var b:FlxSprite = balls.members[i];
				if (b.exists == false) {
					b.exists = true;
					//R.sound_manager.play(SNDC.pop);
					b.x = x; b.y = y;
					b.velocity.x = props.get("x_vel");
					b.velocity.y = 0;
					b.ID = 0;
					b.animation.play("ball_idle");
					break;
				}
			}
		}
		
		for (i in 0...balls.length) {
			var b:FlxSprite = balls.members[i];
			if (b.exists) {
				if (b.velocity.y > 0 && R.player.shield_overlaps(b, 0)) {
					b.velocity.y *= -1;
					continue;
				} else if (b.velocity.x > 0 && R.player.shield_overlaps(b, 3)) {
					b.velocity.x *= -1;
					continue;
				} else if (b.velocity.x < 0 && R.player.shield_overlaps(b, 1)) {
					b.velocity.x *= -1;
					continue;	
				} else if (b.velocity.y < 0 && R.player.shield_overlaps(b, 2)) {
					b.velocity.y *= -1;
					continue;
				}
			
				if (b.overlaps(R.player) && b.ID != 1) {
					if (dmgtype == 0) {
						R.player.add_dark(props.get("damage"));
						//R.sound_manager.play(SNDC.pop);
					} else {
						R.player.add_light(props.get("damage"));
						//R.sound_manager.play(SNDC.pop);
					}
					b.ID = 1; // do ball disappear
					b.animation.play("ball_break");
					//play anim
				} else if (b.ID == 1) {
					b.velocity.set(0, 0);
					if (b.animation.finished) {
						b.ID = 0;
						b.exists = false;
					}
				} else {
					for (vanish in VanishBlock.ACTIVE_VanishBlocks) {
						if (vanish.overlaps(b) && vanish.props.get("s_open") == 0) {
							b.ID = 1;
							b.animation.play("ball_break");
						}
					}
					var try_to_stop:Bool = false;
					var do_dampen:Bool = false;
					if (b.velocity.y >0 && parent_state.tm_bg.getTileCollisionFlags(b.x + b.width / 2, b.y + b.height) != 0) {
						b.velocity.y *= -1;
						try_to_stop = true;
						do_dampen = true;
					}
					if (b.velocity.y < 0 && parent_state.tm_bg.getTileCollisionFlags(b.x + b.width / 2, b.y) != 0) {
						b.velocity.y *= -1;
						do_dampen = true;
						//try_to_stop = true;
					}
					if ((b.velocity.x < 0 && parent_state.tm_bg.getTileCollisionFlags(b.x, b.y + b.height / 2) != 0) || (b.velocity.x > 0 && parent_state.tm_bg.getTileCollisionFlags(b.x + b.width, b.y + b.height / 2) != 0)) {
						b.velocity.x *= -1;
						do_dampen = true;
						//try_to_stop = true;
					}
					if (do_dampen) {
						b.velocity.x *= props.get("dampen");
						b.velocity.y *= props.get("dampen");
					}
					if (try_to_stop) {
						if (Math.abs(b.velocity.x) < 50) {
							b.ID = 1;
							b.velocity.x = 0;
							b.velocity.y = 0;
							b.animation.play("ball_break");
						}
					}
				}
				if (b.y > parent_state.tm_bg.height || b.x + b.width < 0 || b.x > parent_state.tm_bg.width) {
					b.exists = false;
				}
			}
		}
		super.update(elapsed);
	}
}