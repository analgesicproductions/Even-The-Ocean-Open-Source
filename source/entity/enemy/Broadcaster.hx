package entity.enemy;
import autom.SNDC;
import entity.MySprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import global.C;
import haxe.Log;
import help.HF;
import state.MyState;
/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class Broadcaster extends MySprite
{

	// now doubles velocities	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		bullets = new FlxSpriteGroup();
		targets = new Array<MySprite>();
		super(_x, _y, _parent, "Broadcaster");
	}
	
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(16, 16, 0xffff00ff);
				for (i in 0...bullets.length) {
					bullets.members[i].makeGraphic(8, 8, 0xffff44ff);
				}
			case 1:
				makeGraphic(16, 16, 0xffffffff);
				for (i in 0...bullets.length) {
					bullets.members[i].makeGraphic(8, 8, 0xffffbbff);
				}
			default:
				
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("children", "");
		p.set("timer", -1);
		p.set("vis-dmg", "0,0");
		p.set("vel", 100);
		return p;
	}
	
	private var timer:Float = 0;
	private var max_timer:Float = 0;
	private var vel:Float = 0;
	
	private var bullets:FlxSpriteGroup;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		max_timer = props.get("timer");
		vel = props.get("vel");
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);

		
		//bullets.setAll("visible", false);
		for (b in bullets.members) {
			if (b != null) {
				b.visible = false;
			}
		}
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		if (has_lock) {
			LOCKED = false;
		}
		HF.remove_list_from_mysprite_layer(this, parent_state, [bullets]);
		super.destroy();
	}
	
	private var targets:Array<MySprite>;
	private var forced_trigger:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			populate_parent_child_from_props();
			HF.add_list_to_mysprite_layer(this, parent_state, [bullets]);
		}
		
		if (max_timer == -1) {
			timer = -2;
		} else if (timer < max_timer) {
			timer += FlxG.elapsed;
		}
		if (timer > max_timer || forced_trigger) {
			if (forced_trigger) {
				forced_trigger = false;
			} else {
				timer -= max_timer;
			}
			var b:FlxSprite;
			var target:MySprite;
			
			var l:Int = parents.length + children.length;
			var expanded:Bool = false;
			for (i in 0...l) {
				if (i + 1 > bullets.length) {
					var new_bul:FlxSprite = new FlxSprite();
					new_bul.visible = false;
					bullets.add(new_bul);
					targets.push(null);
					expanded = true;
				}
			}
			if (expanded) {
				change_visuals();
			}
			
			for (i in 0...bullets.length) {
				b = bullets.members[i];
				if (b.visible == true) continue;
				if (i >= children.length && i < children.length + parents.length) {
					target = parents[i - children.length];
				} else if (i < children.length) {
					target = children[i];
				} else {
					continue;
				}
			
				b.x = this.x + this.width / 2 - b.width / 2;
				b.visible = true;
				b.y = this.y + this.height / 2 - b.height / 2;
				HF.scale_velocity(b.velocity, this, target, vel);
				targets[i] = target;
			}
		}
		
		for (i in 0...bullets.length) {
			if (bullets.members[i].visible) {
				if (bullets.members[i].overlaps(targets[i])) {
					
					bullets.members[i].visible = false;
					targets[i].recv_message(C.MSGTYPE_SIGNAL);
					targets[i] = null;
					bullets.members[i].velocity.set(0, 0);
					if (i == lock_idx) {
						targets[i] = null;
						bullets.members[i].visible = false;
						bullets.members[i].velocity.set(0, 0);
						LOCKED = has_lock = false;
					}
				} else if (R.player.shield_overlaps(bullets.members[i])) {
					if (i != lock_idx) { // attached bullet doesnt get affected by the shield
						targets[i] = null;
						bullets.members[i].visible = false;
						bullets.members[i].velocity.set(0, 0);
					}
				} else if ((has_lock && i == lock_idx) || bullets.members[i].overlaps(R.player)) {
					
					
					if (!LOCKED) {
						R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
						LOCKED = has_lock = true;
						lock_idx = i;
						if (dmgtype == 0) {
							R.player.add_dark(16);
						} else if (dmgtype == 1) {
							R.player.add_light(16);
						}
					} else if (has_lock && i == lock_idx) {
						var b:FlxSprite = cast bullets.members[i];
						R.player.x = b.x + b.width / 2 - R.player.width / 2;
						R.player.y = b.y +b.height / 2 - R.player.height / 2;
						R.player.velocity.y = 0;
						if (R.input.jpA1) {
							//R.sound_manager.play(SNDC.player_jump_up);
							targets[i] = null;
							bullets.members[i].visible = false;
							bullets.members[i].velocity.set(0, 0);
							R.player.velocity.y = R.player.get_base_jump_vel();
							LOCKED = has_lock = false;
						}
						
					}
				}
				
			}
		}
		super.update(elapsed);
	}
	private var lock_idx:Int = 0;
	private static var LOCKED:Bool = false;
	private var has_lock:Bool = false;
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == C.MSGTYPE_SIGNAL) {
			forced_trigger = true;
		}
		return 1;
	}
}