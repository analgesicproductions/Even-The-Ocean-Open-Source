package entity.enemy;
/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import entity.MySprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import state.MyState;

	class WallBouncer extends MySprite
{

	private var pusher:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		aggro_zone = new FlxSprite();
		aggro_zone.makeGraphic(80, 16 + 160, 0x88ffffff);
		aggro_zone.visible = false;
		pusher = new FlxSprite();
		super(_x, _y, _parent, "WallBouncer");
	}
	
	private var aggro_zone:FlxSprite;
	override public function change_visuals():Void 
	{
		//switch (vistype) {
			//case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "dark");
				AnimImporter.loadGraphic_from_data_with_id(pusher, 32, 32, name, "bouncer");
				animation.play("idle");
			//case 1:
				//AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, "light");
				//AnimImporter.loadGraphic_from_data_with_id(pusher, 32, 32, name, "bouncer");
				//animation.play("idle");
			//default:
				//AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name, vistype);
				//AnimImporter.loadGraphic_from_data_with_id(pusher, 32, 32, name, "bouncer");
				//animation.play("idle");
		//}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("climb_vel", 60);
		p.set("push_vel", 250);
		p.set("push_ticks", 10);
		p.set("extend_distance", 6);
		p.set("extend_vel", 200);
		p.set("retract_vel", 5);
		p.set("tm_wait", 0.5);
		p.set("dmg", 0);
		p.set("faces_left",1);
		return p;
	}
	
	private var CLIMB_VEL:Int = 60;
	
	private var extend_distance:Int = 0;
	private var extend_vel:Float = 0;
	private var retract_vel:Float = 0;
	private var dmg:Int = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		CLIMB_VEL = props.get("climb_vel");
		extend_distance = props.get("extend_distance");
		extend_vel = props.get("extend_vel");
		retract_vel = props.get("retract_vel");
		tm_wait = props.get("tm_wait");
		dmg = props.get("dmg");
		change_visuals();
		if (props.get("faces_left") == 0) {
		 	scale.x = pusher.scale.x = -1;
		} else {
		 	scale.x = pusher.scale.x = 1;
		}
		
		width = 16;
		
			offset.x = 8;
		if (scale.x == -1) {
			offset.x = 8;
		} else {
		}
		pusher.width = pusher.height = 16;
		pusher.offset.set(8, 8);
		pusher.animation.play("idle");
	}
	
	override public function destroy():Void 
	{
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [aggro_zone,pusher]);
		super.destroy();
	}
	
	private var is_aggro:Bool = false;
	private var mode:Int = 0;
	private var t_wait:Float = 0;
	private var tm_wait:Float = 0.5;
	private var dmgd:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [aggro_zone,pusher]);
		}
		
		aggro_zone.x = x - 32;
		aggro_zone.y = y - 80;
		if (is_aggro) {
			
			if (!aggro_zone.overlaps(R.player) && mode == 0) {
				is_aggro = false;
				velocity.y = 0;
				mode = 0;
				animation.play("idle");
				return;	
			}
			
			if (mode == 0 || mode == 1 || mode == 3) {
				if (y +height / 2 > R.player.y + R.player.height / 2) {
					velocity.y = -CLIMB_VEL;
				} else if (y + height / 2 < R.player.y - 2 + R.player.height/2)  {
					velocity.y = CLIMB_VEL;
				} else {
					velocity.y = 0;
				}
				if (mode == 3) {
					velocity.y /= 2;
				}
				if (parent_state.tm_bg.getTileCollisionFlags(x + 4, y + height + 2) == 0) {
					if (velocity.y > 0) velocity.y = 0;
				} 
				if (parent_state.tm_bg.getTileCollisionFlags(x + 4, y - 2) == 0) {
					if (velocity.y < 0) velocity.y = 0;
				}
				
				if (velocity.y < 0 && (mode == 3 || mode == 0)) animation.play("walk_u");
				if (velocity.y > 0 && (mode == 3 || mode == 0)) animation.play("walk_d");
				if (velocity.y == 0 && mode == 3) animation.play("idle");
				if (velocity.y == 0 && mode == 0) animation.play("idle");
			}
			
			if (mode == 0) { // Track player and transition to warning state
				
				
				if (FlxX.l1_norm_from_mid(R.player, pusher) < 30) {
					mode = 1;
					animation.play("warning");
					velocity.y = 0;
				}
			} else if (mode == 1) { // warn the player and also do the push
				
				
				pusher.x = this.x;
				
				velocity.y = 0;
				if (animation.finished) {
					animation.play("attack");
					mode = 2;
				}
			} else if (mode == 2) {
				
				if (R.player.x < x) {
					pusher.velocity.x = -extend_vel;
					if (x - pusher.x > extend_distance) {
						pusher.velocity.x = 0;
						mode = 3;
					}
					if (R.player.overlaps(pusher)) {
						damage_player();
						R.player.do_hor_push(Std.int(-props.get("push_vel")), false, false, props.get("push_ticks"));
					}
				} else {
					pusher.velocity.x = extend_vel;
					if (pusher.x - x > extend_distance) {
						pusher.velocity.x = 0;
						mode = 3;
					}
					if (R.player.overlaps(pusher)) {
						damage_player();
						R.player.do_hor_push(Std.int(props.get("push_vel")), false, false, props.get("push_ticks"));
					}
				}
				
				if (mode == 3) {
					dmgd = false;
					animation.play("idle");
				}
			} else if (mode == 3) {
				pusher.immovable = true;
				FlxObject.separateX(R.player, pusher);
				if (R.player.overlaps(pusher)) {
					if (R.player.x < x) {
						R.player.do_hor_push( -50, false, false, props.get("push_ticks"));
					}  else {
						R.player.do_hor_push(50, false, false, props.get("push_ticks"));
					}
				}
				if (R.player.x < x) {
					pusher.velocity.x = retract_vel;
	
					if (pusher.x >= x) {
						mode = 4;
						pusher.velocity.x = 0;
					}
				} else {
					pusher.velocity.x = -retract_vel;
					if (pusher.x <= x) {
						mode = 4;
						pusher.velocity.x = 0;
					}
				}
			} else if (mode == 4) {
				t_wait += FlxG.elapsed;
				if (t_wait > tm_wait) {
					t_wait = 0;
					mode = 0;
				}
				
			}
		} else {
			
				pusher.x = this.x;
			if (aggro_zone.overlaps(R.player)) {
				is_aggro = true;
			}
		}
		
		super.update(elapsed);
	}
	
	private function damage_player():Void {
		if (!dmgd) {
			dmgd = true;
			if (dmgtype == 0) {
				R.player.add_dark(dmg);
			} else {
				R.player.add_light(dmg);
				
			}
		}
	}
	
	override public function draw():Void 
	{
		
		pusher.y = this.y + (this.height - pusher.height) / 2;
		super.draw();
	}
}