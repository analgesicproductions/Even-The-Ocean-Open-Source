package entity.enemy;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import entity.MySprite;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import state.MyState;

class AimSpore extends MySprite
{

	private var bullet:FlxSprite;
	public static var ACTIVE_AimSpores:List<AimSpore>;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		bullet = new FlxSprite();
		super(_x, _y, _parent, "AimSpore");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name,"dark");
				AnimImporter.loadGraphic_from_data_with_id(bullet, 16, 16, name, "dark");
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name,"light");
				AnimImporter.loadGraphic_from_data_with_id(bullet, 16, 16, name,"light");
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name,"light");
				AnimImporter.loadGraphic_from_data_with_id(bullet, 16, 16, name,"light");
		}
			animation.play("idle");
			bullet.animation.play("bullet");
			bullet.visible = false;
			bullet.width = 8; bullet.height = 8;
			bullet.offset.set(4, 4);
	}
	
	public function generic_overlap(o:FlxObject,only_dmgtype:Int=-1):Bool {
		if (this.dmgtype != only_dmgtype && only_dmgtype != -1) { //1 only light breaks
			return false;
		} 
		if (only_dmgtype == -1) {
			if (bullet.visible && bullet.overlaps(o)) {
				return true;
			}
		}
		return false;
	}
	
	private var BULLET_VELOCITY:Int = 250;
	private var t_wait:Float = 0;
	private var tm_wait:Float = 1.5;
	private var number_of_bounces:Int = 1;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("bul_vel", 360);
		p.set("t_wait", 2);
		p.set("nr_bounces", 0);
		p.set("damage", 64);
		p.set("hold_ticks", 10);
		p.set("fixed_angle", -1);
		return p;
	}
	
	private var DMG:Int = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		number_of_bounces = props.get("nr_bounces");
		tm_wait = props.get("t_wait");
		BULLET_VELOCITY = props.get("bul_vel");
		DMG = props.get("damage");
		change_visuals();
	}
	
	override public function destroy():Void 
	{

		ACTIVE_AimSpores.remove(this);
		HF.remove_list_from_mysprite_layer(this, parent_state, [bullet]);
		super.destroy();
	}
	
	private var mode:Int = 0;
	private var bounces_left:Int = 0;
	private var holdticks_left:Int = 0;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			ACTIVE_AimSpores.add(this);
			HF.add_list_to_mysprite_layer(this, parent_state, [bullet]);
		}
		
		switch (mode) {
			case 0:
				t_wait += FlxG.elapsed;
				if (tm_wait - t_wait < 0.33) {
					animation.play("warning");
				}
				if (t_wait > tm_wait) {
					t_wait = 0;
					mode = 1;
					bullet.visible = true;
					bullet.x = x + 4; bullet.y = y + 4;
					bounces_left = number_of_bounces;
					HF.scale_velocity(bullet.velocity, bullet, R.player, BULLET_VELOCITY);
					
					if (props.get("fixed_angle") != -1) {
						HF.set_vel_vector(bullet.velocity, props.get("fixed_angle"), BULLET_VELOCITY);
					}
				}
			case 1:
				if (R.player.overlaps(bullet)) {
					R.player.do_hor_push(Std.int(0.7*bullet.velocity.x), false, true, props.get("hold_ticks"));
					R.player.do_vert_push(Std.int(0.75*bullet.velocity.y));
					bullet.velocity.set(0, 0);
					holdticks_left = props.get("hold_ticks");
					mode = 2;
					animation.play("idle");
					
					if (!R.player.shield_overlaps(bullet)){
						if (dmgtype == 0) {
							R.player.add_dark(DMG);
						} else {
							R.player.add_light(DMG);
						}
					}
				} else if (bounces_left >= 0) {
					var bounced:Bool = false;
					if (bullet.velocity.x < 0) {
						if (parent_state.tm_bg.getTileCollisionFlags(bullet.x, bullet.y + bullet.height / 2) != 0) { 
							bullet.velocity.x *= -1;
							bounced = true;
						}
					} else if (bullet.velocity.x > 0) {
						if (parent_state.tm_bg.getTileCollisionFlags(bullet.x+bullet.width, bullet.y + bullet.height / 2) != 0) {
							bullet.velocity.x *= -1;
							bounced = true;
						}
					}
					if (bullet.velocity.y < 0) {
						if (parent_state.tm_bg.getTileCollisionFlags(bullet.x+bullet.width/2, bullet.y) != 0) {
							bullet.velocity.y *= -1;
							bounced = true;
						}
					} else if (bullet.velocity.y > 0) {
						if (parent_state.tm_bg.getTileCollisionFlags(bullet.x+bullet.width/2, bullet.y+bullet.height) != 0) {
							bullet.velocity.y *= -1;
							bounced = true;
						}
					}
					
					if (bounced) {
						if (bounces_left == 0) {
							bullet.visible = false;
							mode = 0;
							bullet.velocity.set(0, 0);
							animation.play("idle");
						}
						bounces_left--; 
					}
				}
			case 2:
				holdticks_left--;
				bullet.x = R.player.x + 3;
				bullet.y = R.player.y + 6;
				if (holdticks_left <= 0) {
					bullet.visible = false;
					mode = 0;
				}
		}
		
		super.update(elapsed);
	}
}