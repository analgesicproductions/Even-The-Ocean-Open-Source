package entity.enemy;
import entity.MySprite;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.MyState;

class ShockFloat extends MySprite
{

	public static var ACTIVE_ShockFloats:List<ShockFloat>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		hurt_sprite = new FlxSprite();
		
		super(_x, _y, _parent, "ShockFloat");
	}
	
	private var hurt_sprite:FlxSprite;
	
	private var is_giving:Bool = false;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				hurt_sprite.makeGraphic(48, 48, 0xcc123123);
				makeGraphic(32, 32, 0xffff00ff);
			case 1:
				hurt_sprite.makeGraphic(48, 48, 0xcc123123);
				makeGraphic(32, 32, 0xffffffff);
		}
	}
	
	public function generic_overlap(o:FlxObject, dmg:Int = -1):Bool {
		if (dmg == -1) {
			if (hurt_mode == 1 && hurt_sprite.overlaps(o)) {
				return true;
			}
		}
		return false;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", 0);
		p.set("t_off", 0.5);
		p.set("t_on", 0.5);
		p.set("t_hurt", 0.02);
		p.set("float_vel", 50);
		return p;
	}
	
	private var float_vel:Float;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		vistype = props.get("vistype");
		tm_on = props.get("t_on");
		tm_off = props.get("t_off");
		tm_hurt = props.get("t_hurt");
		float_vel = props.get("float_vel");
			velocity.x = Math.abs(float_vel);
		change_visuals();
		hurt_sprite.visible = false;
	}
	
	override public function destroy():Void 
	{
		ACTIVE_ShockFloats.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [hurt_sprite]);
		super.destroy();
	}
	
	
	private var touches_player:Bool = false;
	override public function preUpdate():Void 
	{
		touches_player = false;
		immovable = true;
		touches_player = FlxObject.separate(this, R.player);
		immovable = false;	
		FlxObject.separate(this, parent_state.tm_bg);
		super.preUpdate();
	}
	
	private var t_on:Float;
	private var t_off:Float;
	private var tm_on:Float;
	private var tm_off:Float;
	
	private var t_hurt:Float;
	private var tm_hurt:Float;
	
	private var hurt_mode:Int = 0;
	
	private var move_mode:Int = 0;
	
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_ShockFloats.push(this);
			HF.add_list_to_mysprite_layer(this, parent_state, [hurt_sprite]);
		}
		
		if (is_giving) {
			if (velocity.y < 0 && y <= iy) {
				y = iy;
				velocity.y = 0;
				acceleration.y = 0;
				is_giving = false;
			}
		}
		
		if (move_mode == 0) {
			//if (parent_state.tm_bg.getTileCollisionFlags(x + width, y + height / 2) != 0) {
			if (touching & FlxObject.RIGHT != 0) {
				velocity.x = float_vel * -1;
				move_mode = 1;
			} 
		} else if (move_mode == 1) {
			//if (parent_state.tm_bg.getTileCollisionFlags(x, y + height / 2) != 0) {
			if (touching & FlxObject.LEFT != 0) {
				velocity.x = float_vel;
				move_mode = 0;
			} 
		}
		
		if (hurt_mode == 0) {
			t_off += FlxG.elapsed;
			if (t_off > tm_off) {
				t_off = 0;
				hurt_mode = 1;
				hurt_sprite.visible = true;
				hurt_sprite.flicker(tm_on);
			}
		} else {
			t_on += FlxG.elapsed;
			if (hurt_sprite.overlaps(R.player)) {
				t_hurt += FlxG.elapsed;
				if (t_hurt > tm_hurt) {
					t_hurt -= tm_hurt;
					
					if (vistype == 0) {
						R.player.add_dark(2);
					} else { // L
						R.player.add_light(2);
					}
				}
			}
			if (t_on > tm_on) {
				t_on = 0;
				hurt_mode = 0;
				hurt_sprite.visible = false;
			}
		}
		
		if (player_hang_mode == 0) {
			if (touches_player) {
				if (R.player.touching & FlxObject.RIGHT != 0) {
					R.player.activate_wall_hang();
					player_hang_mode = 1;
				} else if (R.player.touching & FlxObject.LEFT != 0) {
					R.player.activate_wall_hang();
					player_hang_mode = 2;
				} else if (R.player.touching & FlxObject.DOWN != 0) {
					if (!is_giving) {
						is_giving = true;
						velocity.y = 70;
						acceleration.y = -250;
						R.player.velocity.y = 70;
					}
					R.player.y = y - R.player.height + 1;
				}
			}
		} else if (player_hang_mode == 1) { // player rightside is touching
			R.player.x = x - R.player.width + 1;
			R.player.activate_wall_hang();
			if (R.player.is_wall_hang_points_in_object(this) == false) {
				player_hang_mode = 0;
			}
		} else if (player_hang_mode == 2) { // leftside player
			R.player.x = x + width - 1;
			R.player.activate_wall_hang();
			if (R.player.is_wall_hang_points_in_object(this) == false) {
				player_hang_mode = 0;
			}
		}
		
		super.update(elapsed);
	}
	
	private var player_hang_mode:Int = 0;
	override public function postUpdate(elapsed):Void 
	{
		super.postUpdate(elapsed);
		hurt_sprite.x = x - (hurt_sprite.width - width) / 2;
		hurt_sprite.y = y - (hurt_sprite.height - height) / 2;
	}
}