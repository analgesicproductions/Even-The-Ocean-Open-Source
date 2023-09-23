package entity.trap;
import entity.MySprite;
import entity.player.Player;
import global.C;
import haxe.Log;
import help.HF;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import state.MyState;

/**
 * A cannon that lobs bombs that blow up mostly vertical shrapnel with some horizontal.
 * It charges up based on your proximity - the closer, the faster.
 * It can be started in an idle state and require an energy boost.
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class NearCannon extends MySprite
{

	private var bomb:FlxSprite;
	private var explosion:FlxSprite;
	private var shrapnel:FlxGroup;
	
	private var mode:Int;
	private var mode_idle:Int = 0;
	private var mode_active:Int = 1;
	private var mode_wait_for_contact:Int = 2;
	private var mode_wait_for_ready:Int = 3;
	
	private static inline var vt_dark:Int = 0;
	private static inline var vt_light:Int = 1;
	private var t_shoot:Float = 0;
	private var tm_shoot:Float = 3;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		bomb = new FlxSprite();
		bomb.makeGraphic(8, 8, 0xff003333);
		bomb.exists = false;
		explosion = new FlxSprite();
		explosion.makeGraphic(32, 32, 0xdd882222);
		explosion.exists = false;
		t_shoot = tm_shoot;
		shrapnel = new FlxGroup(0, "nearcannonshrapnel");
		for (i in 0...6) {
			var piece_of_shrapnel:FlxSprite = new FlxSprite();
			piece_of_shrapnel.makeGraphic(4, 4, 0xff990099);
			piece_of_shrapnel.exists = false;
			shrapnel.add(piece_of_shrapnel);
		}
		
		super(_x, _y, _parent, "NearCannon");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case vt_dark:
				makeGraphic(32, 32, 0xff000022);
			case vt_light:
				makeGraphic(32, 32, 0xffffdd11);
				
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vistype", vt_dark);
		p.set("starts_idle", 0);
		p.set("tm_shoot", 3);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		vistype = props.get("vistype");
		if (props.get("starts_idle") == 1) {
			mode = mode_idle;
		} else {
			mode = mode_active;
		}
		tm_shoot = props.get("tm_shoot");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [bomb,this,explosion,shrapnel]);
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.remove_list_from_mysprite_layer(this, parent_state, [this]);
			HF.add_list_to_mysprite_layer(this, parent_state, [bomb,this,explosion,shrapnel]);
		}
		
		if (mode == mode_idle) {
			
		} else if (mode == mode_active) {
			
			var max_d:Float = 250;
			var d:Float = HF.get_midpoint_distance(this, R.player);
			if (d > max_d) {
				t_shoot = tm_shoot;
			} else {
				var r:Float = d / max_d;
				if (r < 0.2) { t_shoot -= FlxG.elapsed * 5; }
				else if (r < 0.4) { t_shoot -= FlxG.elapsed * 4; } 
				else if (r < 0.6) { t_shoot -= FlxG.elapsed * 3; } 
				else if (r < 0.8) { t_shoot -= FlxG.elapsed * 2; } 
				else if (r < 1) { t_shoot -= FlxG.elapsed; } 
			}
			
			alpha = t_shoot / tm_shoot;
			
			if (t_shoot < 0) {
				t_shoot = tm_shoot;
				bomb.x = x;
				bomb.y = y;
				bomb.exists = true;
				bomb.acceleration.y = 250;
				R.player.y -= 16; 
				
				HF.scale_velocity(bomb.velocity, this, R.player, 300);
				R.player.y += 16;
				
				mode = mode_wait_for_contact;  
			}
		} else if (mode == mode_wait_for_contact) {
			if (bomb.exists) {
				FlxObject.separate(bomb, parent_state.tm_bg);
			}
			if (bomb.overlaps(R.player)) {
				bomb.touching = FlxObject.UP;
			} 
			if (bomb.exists && bomb.touching != FlxObject.NONE) {
				bomb.exists = false;
				explosion.exists = true;
				explosion.alpha = 1;
				explosion.x = bomb.getMidpoint().x - (explosion.width / 2);
				explosion.y = bomb.getMidpoint().y - (explosion.height  / 2);
				
				
				if (explosion.overlaps(R.player)) {
					R.player.do_vert_push( -500);
					damage(20, R.player);
				} 
				
				
				var o:FlxObject = new FlxObject(0, 0, 1, 1);
				for (i in 0...shrapnel.length) {
					var piece:FlxSprite = cast shrapnel.members[i];
					piece.exists = true;
					piece.acceleration.y = 250;
					if (bomb.touching & FlxObject.LEFT != 0) {
						piece.move(bomb.x + 3, bomb.y + 2);
						o.move(piece.x + 32, piece.y - 8 + 16 * Math.random());
					} else if (bomb.touching & FlxObject.RIGHT != 0) {
						piece.move(bomb.x - 3, bomb.y + 2);
						o.move(piece.x - 32, piece.y - 8 + 16 * Math.random());
					} else if (bomb.touching & FlxObject.DOWN != 0) {
						piece.move(bomb.x , bomb.y + 4);
						o.move(piece.x  - 8 + 16*Math.random(), piece.y -32);
					} else if (bomb.touching & FlxObject.UP != 0) {
						piece.move(bomb.x, bomb.y -4 );
						o.move(piece.x -8 + 16*Math.random(), piece.y + 32 );
					}
					HF.scale_velocity(piece.velocity, piece, o, 400);
				}
				
				mode = mode_wait_for_ready;
			}
		} else if (mode == mode_wait_for_ready) {
			
			explosion.alpha -= 0.015;
			if (explosion.alpha == 0) {
				explosion.exists = false;
			}
			
			var nr_alive:Int = 0;
			for (i in 0...shrapnel.length) {
				var piece:FlxSprite = cast shrapnel.members[i];
				if (piece.exists) { 
					nr_alive ++; 
					if (parent_state.tm_bg.getTileCollisionFlags(piece.x, piece.y) != FlxObject.NONE) {
						piece.exists = false;
					} else if (R.player.shield_overlaps(piece)) {
						piece.exists = false;
					} else if (piece.overlaps(R.player)) {
						damage(8, R.player);
						piece.exists = false;
					} 
					
				}
			}
			
			if (explosion.exists == false) {
				mode = mode_active;
			}
			
		}
		super.update(elapsed);
	}
	
	private function damage_mysprite(amt:Int, m:MySprite):Void {
		if (vistype == vt_dark) {
			m.recv_message(C.MSGTYPE_ENERGIZE_AMT_D + "+" + Std.string(amt));
		} else if (vistype == vt_light) {
			m.recv_message(C.MSGTYPE_ENERGIZE_AMT_L+ "+" + Std.string(amt));
		}
	}
	private function damage(amt:Int, p:Player) {
		if (vistype == vt_dark) {
			p.add_dark(amt);
		} else if (vistype == vt_light) {
			p.add_light(amt);
		}
	}
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == C.MSGTYPE_ENERGIZE_DARK) {
			if (vistype == vt_dark && mode == mode_idle) {
				mode = mode_active;
			}
		} else if (message_type == C.MSGTYPE_ENERGIZE_LIGHT) {
			if (vistype == vt_light && mode == mode_idle) {
				mode = mode_active;
			}
		}
		return C.RECV_STATUS_OK;
	}
	
}