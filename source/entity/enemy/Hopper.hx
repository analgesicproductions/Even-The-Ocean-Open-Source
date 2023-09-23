package entity.enemy;
import autom.SNDC;
import entity.MySprite;
import flixel.animation.FlxAnimation;
import flixel.FlxG;
import flixel.FlxObject;
import global.C;
import help.HF;
import state.MyState;

class Hopper extends MySprite
{

	public static var ACTIVE_Hoppers:List<Hopper>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "Hopper");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(16, 16, 0xffff00ff);
			case 1:
				makeGraphic(16, 16, 0xffffffff);
			default:
		}
	}
	
	private var jump_vel:Float = 0;
	private var x_vel:Float = 0;
	private var tm_jump:Float = 0;
	private var t_jump:Float = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("jump_vel", -300);
		p.set("x_vel", 50);
		p.set("tm_jump", 0.5);
		p.set("accel", 350);
		p.set("wall_jumps", 0);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		jump_vel = props.get("jump_vel");
		x_vel = props.get("x_vel");
		tm_jump = props.get("tm_jump");
		acceleration.y = props.get("accel");
		change_visuals();
		
		width = 6;
		height = 12;
		offset.set(5, 4);
		
		x = last.x =  ix + 5;
		y = last.y = iy + 4;
		if (x_vel > 0) {
			facing = FlxObject.RIGHT;
		} else {
			facing = FlxObject.LEFT;
		}
	}
	override public function destroy():Void 
	{
		ACTIVE_Hoppers.remove(this);
		if (player_stuck) {
			PLAYER_STUCK_LOCK = false;
		}
		super.destroy();
	}
	private var mode:Int = 0;
	private var t_wait:Float = 0;
	private var tm_wait:Float = 2;
	override public function preUpdate():Void 
	{
		FlxObject.separate(this, parent_state.tm_bg);
		super.preUpdate();
	}
	
	
	public function generic_overlap(o:FlxObject,only_dmgtype:Int=-1):Bool {
		if (this.dmgtype != only_dmgtype && only_dmgtype != -1) { //1 only light breaks
			return false;
		} 
		if (only_dmgtype == -1) {
			if (this.overlaps(o)) {
				return true;
			}
		}
		return false;
	}
	
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == C.MSGTYPE_MOVED_BY_EDITOR) {
			x = last.x = ix  +5;
			y = last.y = iy + 4;
		}
		return 0;
	}
	
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_Hoppers.add(this);
		}
		if (mode == 0) { // wait to jump
			t_jump += FlxG.elapsed;
			if (t_jump > tm_jump) {
				mode = 1;	
				t_jump = 0;
				if (facing == FlxObject.RIGHT) {
					velocity.x = Math.abs(x_vel);
				} else {
					velocity.x = -Math.abs(x_vel);
				}
				velocity.y = jump_vel;
			}
			if (!player_stuck && R.player.overlaps(this)) {
				mode = 2;
			}
		} else if (mode == 1) { // wait to touch then go back to jump
			if (touching & FlxObject.DOWN != 0) {
				mode = 0;
				velocity.x = 0;
				velocity.y = 0;
			}
			if (touching & FlxObject.RIGHT != 0) {
				facing = FlxObject.LEFT;	
				velocity.x = velocity.y = 0;
				if (props.get("wall_jumps") == 1) {
					t_jump = tm_jump;
					mode = 0;
				}
			}
			if (touching & FlxObject.LEFT != 0) {
				facing = FlxObject.RIGHT;
				velocity.x = velocity.y = 0;
				if (props.get("wall_jumps") == 1) {
					t_jump = tm_jump;
					mode = 0;
				}
			}
			
			if (!player_stuck && R.player.overlaps(this)) {
				mode = 2;
			}
		} else if (mode == 2) {
			if (!dmgd && !player_stuck) {
				if (dmgtype == 0) {
					R.player.add_dark(31);
				} else {
					R.player.add_light(31);
				}
				dmgd = true;
				if (!PLAYER_STUCK_LOCK) {
					R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
					PLAYER_STUCK_LOCK = true;
					player_stuck = true;
				}
			}
			mode = 0;
		} 
		
		
		if (player_stuck) {
			if (R.player.is_dying()) {
				player_stuck = false;
				exists = false;
			}
			if (R.input.jpA1) {
				
				//R.sound_manager.play(SNDC.player_jump_up);
				player_stuck = PLAYER_STUCK_LOCK = false;
				R.player.velocity.y = R.player.get_base_jump_vel();
			} else {
				R.player.x = x + width / 2 - R.player.width / 2;
				R.player.y = y + height / 2 - R.player.height / 2;
			}
		}
		if (t_wait > tm_wait) {
			dmgd = false;
			t_wait = 0;
		} else {
			if (dmgd && !player_stuck) {
				t_wait += FlxG.elapsed;
			}
		}
		super.update(elapsed);
	}
	private var player_stuck:Bool = false;
	private static var PLAYER_STUCK_LOCK:Bool = false;
	private var dmgd:Bool = false;
	override public function draw():Void 
	{
		var ox:Float = x;
		var oy:Float = y;
		if (mode == 3) {
			x = x - 4 + 8 * Math.random();
			y = y - 4 + 8 * Math.random();
		}
		super.draw();
		
		y = oy;
		x = ox;
	}
	override public function postUpdate(elapsed):Void 
	{
	if (R.editor.editor_active && FlxG.keys.pressed.SPACE) {
		} else {
			super.postUpdate(elapsed);
		}
	}
}