package entity.enemy;

import entity.MySprite;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import haxe.Log;
import help.FlxX;
import help.HF;

import state.MyState;
class TriggeredLaser extends MySprite
{

	
	private var bullets:FlxSpriteGroup;
	private var radial_distance:Float;
	private var num_bullets:Int;
	
	private var do_fire:Bool = false;
	
	
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		bullets = new FlxSpriteGroup();
		super(_x, _y, _parent, "TriggeredLaser");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(16, 16, 0xffff60ff);
				for (i in 0...bullets.length) {
					bullets.members[i].makeGraphic(8, 8, 0xffff60ff);
				}
			case 1:
				makeGraphic(16, 16, 0xffffffff);
				for (i in 0...bullets.length) {
					bullets.members[i].makeGraphic(8, 8, 0xffffffff);
				}
			default:
				makeGraphic(16, 16, 0xffffffff);
				for (i in 0...bullets.length) {
					bullets.members[i].makeGraphic(8, 8, 0xffffffff);
				}
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("angle", 0);
		p.set("shoot_vel", 300);
		p.set("dmg", 64);
		return p;
	}
	
	private var shoot_angle:Float = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		
		shoot_angle = props.get("angle");
		var bul:FlxSprite = new FlxSprite();
		bul.visible = false;
		bullets.clear();
		bullets.add(bul);	
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [bullets]);
		super.destroy();
	}
	
	override public function recv_message(message_type:String):Int 
	{
		do_fire = true;
		return 1;
	}
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [bullets]);
		}
		var b:FlxSprite = bullets.members[0];
		if (do_fire) {
			do_fire = false;
			if (b.visible == false) {
				b.x = this.x + 4;
				b.y = this.y + 4;
				var o:FlxObject = new FlxObject();
				o.x = b.x + FlxX.cos_table[props.get("angle")] * 10;
				o.y = b.y + FlxX.sin_table[props.get("angle")] * 10;
				HF.scale_velocity(b.velocity, b, o, props.get("shoot_vel"));
				b.visible = true;
			}
		}
		
		if (b.visible) {
			if (b.overlaps(R.player)) {
				if (!R.player.shield_overlaps(b)) {
					if (dmgtype == 0) {
						R.player.add_dark(props.get("dmg"));
					} else if (dmgtype == 1) {
						R.player.add_light(props.get("dmg"));
					}
				}
				b.visible = false;
			}
			if (b.overlaps(parent_state.tm_bg)) {
				b.visible = false;
			}
		}
		super.update(elapsed);
	}
}