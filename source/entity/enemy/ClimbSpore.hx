package entity.enemy;

import entity.MySprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import help.HF;
import state.MyState;

class ClimbSpore extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		big_bullet = new FlxSprite();
		bullets = new FlxSpriteGroup();
		for (i in 0...2) {
			var b = new FlxSprite();
			bullets.add(b);
			b.visible = false;
		}
		super(_x, _y, _parent, "ClimbSpore");
	}
	
	private var big_bullet:FlxSprite;
	private var bullets:FlxSpriteGroup;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				makeGraphic(16, 16, 0xff993359);
				big_bullet.makeGraphic(8, 8, 0xff993359);
				for (i in 0...2) {
					bullets.members[i].makeGraphic(8, 8, 0xff993359);
					bullets.members[i].visible = false;
					bullets.members[i].move(ix, iy);
				}
			case 1:
				makeGraphic(16, 16, 0xffffeeff);
				big_bullet.makeGraphic(8, 8, 0xffffeeff);
				for (i in 0...2) {
					bullets.members[i].makeGraphic(8, 8, 0xffffeeff);
					bullets.members[i].visible = false;
					bullets.members[i].move(ix, iy);
				}
				
			default:
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("is_left", 0);
		p.set("tm_move", 2.3);
		p.set("tm_shoot", 2);
		p.set("vel", 70);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		tm_shoot = props.get("tm_shoot");
		tm_move = props.get("tm_move");
		MOVE_VELOCITY = props.get("vel");
		change_visuals();
	}
	
	private var mode:Int = 0;
	override public function destroy():Void 
	{
	
		HF.remove_list_from_mysprite_layer(this, parent_state, [big_bullet,bullets]);
		super.destroy();
	}
	
	private var t_shoot:Float = 0;
	private var tm_shoot:Float = 0;
	private var t_move:Float = 0;
	private var tm_move:Float = 0;
	private var try_to_shoot:Bool = false;
	private var last_move_mode:Int = 0;
	private var MOVE_VELOCITY:Int = 0;
	private var t_pause:Float = 0;
	private var tm_pause:Float = 0.5;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [big_bullet,bullets]);
		}
		
		if (mode == 0 || mode == 1) {
			t_shoot += FlxG.elapsed;
			if (t_shoot > tm_shoot) {
				t_shoot -= tm_shoot;
				try_to_shoot = true;
			}
		}
		if (mode == 0) { // up
			if (try_to_shoot) {
				try_to_shoot = false;
				mode = 2;
				last_move_mode = 0;
				velocity.y = 0;
				return;
			}
			
			if (parent_state.tm_bg.getTileCollisionFlags(x + 1, y ) != 0) {
				velocity.y = 0;
			}
			if (props.get("is_left") == 1) {
				if (parent_state.tm_bg.getTileCollisionFlags(x -2, y-2 ) == 0) {
					velocity.y = 0;
				}
			} else {
				if (parent_state.tm_bg.getTileCollisionFlags(x +width+2, y-2 ) == 0) {
					velocity.y = 0;
				}
			}
			
			t_move += FlxG.elapsed;
			if (t_move > tm_move) {
				t_move = 0;
				mode = 1;
				velocity.y = MOVE_VELOCITY;
			}
		} else if (mode == 1) { // down
			if (try_to_shoot) {
				try_to_shoot = false;
				mode	 = 2;
				last_move_mode = 1;
				velocity.y = 0;
				return;
			}
			
			if (parent_state.tm_bg.getTileCollisionFlags(x + 1, y + height) != 0) {
				velocity.y = 0;
			}
			if (props.get("is_left") == 1) {
				if (parent_state.tm_bg.getTileCollisionFlags(x -2, y+height+2 ) == 0) {
					velocity.y = 0;
				}
			} else {
				if (parent_state.tm_bg.getTileCollisionFlags(x +width+2, y+height+2 ) == 0) {
					velocity.y = 0;
				}
			}
			
			
			t_move += FlxG.elapsed;
			if (t_move > tm_move) {
				t_move = 0;
				mode = 0;
				velocity.y = -MOVE_VELOCITY;
			}
		} else if (mode == 2) {
			
			t_pause += FlxG.elapsed;
			if (t_pause > tm_pause) {
				t_pause = 0;
				velocity.set(0, 0);
				big_bullet.visible = true;
				big_bullet.x = this.x + 4;
				big_bullet.y = this.y + 4;
				if ( 1 == props.get("is_left")) {
					big_bullet.velocity.set(150, 0);
				} else {
					big_bullet.velocity.set( -150, 0);
				}
				mode = 3;
			}
		} else if (mode == 3) {
			// Big bullet collide w/ player
			var b:Bool = false;
			if (R.player.shield_overlaps(big_bullet)) {
				b = true;
			} else if (big_bullet.overlaps(R.player)) {
				b = true;
				if (dmgtype == 0 ) {
					R.player.add_dark(48); 
				} else if (dmgtype == 1) {
					R.player.add_light(48);
				}
			}
			if (b) {
				big_bullet.visible = false;
				big_bullet.velocity.set(0, 0);
				mode = last_move_mode;
				if (last_move_mode == 0) velocity.y = -MOVE_VELOCITY;
				if (last_move_mode == 1) velocity.y = MOVE_VELOCITY;
				return;
			}
			
			// Big bullet collide with tilemap
			if (parent_state.tm_bg.getTileCollisionFlags(big_bullet.x + big_bullet.width / 2, big_bullet.y + big_bullet.height / 2) != 0) {
				bullets.members[0].visible = true;
				bullets.members[1].visible = true;
				bullets.members[0].velocity.set(0, -150);
				bullets.members[1].velocity.set(0, 150);
				if (props.get("is_left") == 1) {
					bullets.members[1].move(big_bullet.x-4, big_bullet.y);
					bullets.members[0].move(big_bullet.x - 4, big_bullet.y);
				} else {
					bullets.members[1].move(big_bullet.x+4, big_bullet.y);
					bullets.members[0].move(big_bullet.x+4, big_bullet.y);
				}
				big_bullet.velocity.set(0, 0);
				big_bullet.visible = false;
				mode = 4;
			}
		} else if (mode == 4) {
			if (bullets.members[0].visible == false && false == bullets.members[1].visible) {
				mode = last_move_mode;
				bullets.members[0].velocity.set(0, 0);
				bullets.members[1].velocity.set(0, 0);
				if (last_move_mode == 0) velocity.y = -MOVE_VELOCITY;
				if (last_move_mode == 1) velocity.y = MOVE_VELOCITY;
				return;
			}
			for (i in 0...2) {
				if (bullets.members[i].visible) {
					if (R.player.shield_overlaps(bullets.members[i])) {
						bullets.members[i].visible = false;
						continue;
					}
					if (bullets.members[i].overlaps(R.player)) {
						if (dmgtype == 0) {
							R.player.add_dark(24);
						} else if (dmgtype == 1) {
							R.player.add_light(24);
						}
						bullets.members[i].visible = false;
						continue;
					}
					if (parent_state.tm_bg.getTileCollisionFlags(bullets.members[i].x + 4, bullets.members[i].y + 4) != 0) {
						bullets.members[i].visible = false;
						continue;
					}
					if (bullets.members[i].y > parent_state.tm_bg.heightInTiles * 16 || bullets.members[i].y < -16) {
						bullets.members[i].visible = false;
					}
					
				} 
			}
		}
		super.update(elapsed);
	}
}