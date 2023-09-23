package entity.trap;
import entity.MySprite;
import entity.util.OrbSlot;
import global.C;
import haxe.Log;
import openfl.Assets;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxObject;
import state.MyState;

/**
 * 
 * @author Melos Han-Tani 2013 - ? www.twitter.com/han_tani, of Analgesic Productions LLC
 */

class EnergyOrb extends MySprite
{

	private static inline var visdebugdark:Int = 0;
	private static inline var visdebuglight:Int = 1;
	
	public static var Spritesheet_EnergyOrb:BitmapData;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent,"EnergyOrb");
	}
	
	override public function change_visuals():Void 
	{
		if (Spritesheet_EnergyOrb  == null) {
			Spritesheet_EnergyOrb = Assets.getBitmapData("assets/sprites/trap/EnergyOrb.png");
		}
		
		switch (vistype) {
			case visdebugdark:
				myLoadGraphic(Spritesheet_EnergyOrb, true, false, 16, 16);
				animation.add("idle", [4, 5], 15);
				animation.add("disappear", [5, 6, 7, 8], 15, false);
				dmgtype = visdebugdark;
			case visdebuglight:
				myLoadGraphic(Spritesheet_EnergyOrb, true, false, 16, 16);
				animation.add("idle", [0, 1], 15);
				animation.add("disappear", [1, 2, 3, 8], 15, false);
				dmgtype = visdebuglight;
			default:
				
		}
		alpha = 0.7;
		animation.play("idle",true);
		// Change visuals
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", visdebugdark);
		// Set default properties here
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		vistype = props.get("vistype");
		
		change_visuals();
		// Do stuff
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	private var mode_attached_to_shield:Int = 1;
	private var mode_unattached:Int = 0;
	private var mode_charging_something:Int = 2;
	private var mode_destroyed:Int = 3;
	
	private var tm_respawn:Float = 2.0;
	private var t_respawn:Float = 0;
	override public function preUpdate():Void 
	{
		FlxObject.separate(this, parent_state.tm_bg);
		FlxObject.separate(this, parent_state.tm_bg2);
		super.preUpdate();
	}
	override public function update(elapsed: Float):Void 
	{
		super.update(elapsed);
		
		switch (state) {
			case _ if (mode_unattached == state):
				if (R.player.shield_overlaps(this, 0)) {
					state = mode_attached_to_shield;
					velocity.x = velocity.y = 0;
					acceleration.y = 0;
				} else if (overlaps(R.player)) {
					blow_up();
				}
			case _ if (mode_attached_to_shield == state):
				x = R.player.x;
				y = R.player.y - 14	; // ???
				if (R.player.shield_overlaps(this, 0) == false) {
					state = mode_unattached;
					acceleration.y = 100;
					velocity.y = R.player.velocity.y; // let player "throw" it
					if (velocity.y < 0) velocity.y -= 10;
					y -= 2;
					velocity.x = R.player.velocity.x;
				}
			case _ if (mode_destroyed == state):
				t_respawn += FlxG.elapsed;
				if (t_respawn > tm_respawn) {
					t_respawn = 0;
					x = ix;
					y = iy;
					state = mode_unattached;
					animation.play("idle");
				}
		}
		if (state == mode_unattached || state == mode_attached_to_shield) {
			for (i in 0...OrbSlot.ACTIVE_OrbSlots.members.length) {
				var orbslot:OrbSlot = cast OrbSlot.ACTIVE_OrbSlots.members[i];
				if (orbslot != null && overlaps(orbslot)) {
					
					var retval:Int = 0;
					switch (dmgtype) {
						case visdebugdark:
							retval = orbslot.recv_message(C.MSGTYPE_ENERGIZE_DARK);
						case visdebuglight:
							retval = orbslot.recv_message(C.MSGTYPE_ENERGIZE_LIGHT);
					}
					if (retval == C.RECV_STATUS_OK) {
						velocity.x = velocity.y = acceleration.y = 0;
						x = orbslot.x;
						y = orbslot.y;
						state = mode_charging_something;
					} else {
						blow_up();
					}
					// draw order
				}
			}
		}
	}
	
	public function hurt_player():Void {
		switch (dmgtype) {
			case visdebugdark:
				R.player.add_dark(48);
			case visdebuglight:
				R.player.add_light(48);
		}
	}
	
	private function blow_up():Void 
	{
		animation.play("disappear");
		hurt_player();
		state = mode_destroyed;
		acceleration.y = velocity.y = 0;
		velocity.x = 0;
	}
	
}