package entity.enemy;
import entity.MySprite;
import entity.trap.Pew;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import state.MyState;

/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

 class Dasher extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "Dasher");
		immovable = true;
	}
	
	public static var ACTIVE_Dashers:List<Dasher>;
	private static inline var VIS_DARK:Int = 0;
	private static 	inline var VIS_LIGHT:Int = 1;
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case VIS_DARK:
				if (props.get("is_32") == 1) {
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "dark_32");
				} else {
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "dark");
				}
				props.set("dmgtype", 0);
			case VIS_LIGHT:
				
				if (props.get("is_32") == 1) {
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "light_32");
				} else {
					AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, name, "light");
				}
				props.set("dmgtype", 1);
		}
		
		if (props.get("is_hor") == 1 && props.get("is_vert") == 1) {
			animation.play("both", true);
		} else if (props.get("is_hor") == 1) {
			animation.play("hor", true);
		} else if (props.get("is_vert") == 1) {
			animation.play("vert",true);
		} else {
			animation.play("none", true);
		}
	}
		
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("dash_vel", 120);
		p.set("is_hor", 1);
		p.set("is_vert", 0);
		//p.set("vistype", 0);
		//p.set("dmgtype", 0);
		p.set("vis-dmg", "0,0");
		p.set("always_bounce", 0);
		p.set("y_dash_vel", 0);
		p.set("is_32", 0);
		return p;
	}
	
	private var dash_vel:Int = 0;
	private var y_dash_vel:Int = 0;
	private var always_bounce:Bool = false;
	private var is_vert:Bool = false;
	private var is_hor:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dash_vel = props.get("dash_vel");
		y_dash_vel = props.get("y_dash_vel");
		
		if (props.exists("vistype") && props.exists("dmgtype")) {
			var s:String = Std.string(props.get("vistype")) + "," + Std.string(props.get("dmgtype"));
			props.set("vis-dmg", s);
			props.remove("vistype");
			props.remove("dmgtype");
		}
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		
		is_vert = props.get("is_vert") == 1 ? true : false;
		is_hor = props.get("is_hor") == 1 ? true : false;
		if (props.get("always_bounce") == 1) {
			always_bounce = true;
		}
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		Dasher.ACTIVE_Dashers.remove(this);
		super.destroy();
	}
	
	private var mode:Int = 0;
	private var y_mode:Int = 0;
	private var sepd:Bool = false;

	override public function update(elapsed: Float):Void 
	{
		immovable = true;
		sepd = FlxObject.separate(this, R.player);
		if (!did_init) {
			did_init = true;
			Dasher.ACTIVE_Dashers.push(this);
		}
		for (p in Pew.ACTIVE_Pews.members) {
			if (p != null) {
				p.generic_overlap(this, vistype);
			}
		}
		
		if (mode == 0) {
			if (always_bounce || (R.player.x > x && velocity.x == 0 && R.player.y + R.player.height > y && R.player.y + R.player.height - 1 <= y + height)) {
				mode = 2;
				velocity.x = dash_vel;
			}
		} else if (mode == 1) {
			if (always_bounce || (R.player.x < x && velocity.x == 0&& R.player.y + R.player.height > y && R.player.y + R.player.height - 1 <= y + height)) {
				mode = 3;
				velocity.x = -dash_vel;
			}
		} else if (mode == 2) { // dashing right, wait to hit osmething
			if (parent_state.tm_bg.getTileCollisionFlags(x + width+1, y + height/2) != 0) {
				velocity.x = 0;
				mode = 1;
			}
		} else if (mode == 3) {
			if (parent_state.tm_bg.getTileCollisionFlags(x - 1, y + height/2) != 0) {
				velocity.x = 0;
				mode = 0;
			}
		}
		if (y_mode == 0) {
			if (always_bounce || (R.player.y > y && velocity.y == 0 && R.player.x + R.player.width> x && R.player.x + R.player.width- 1 <= x+width)) {
				y_mode = 2;
				velocity.y = y_dash_vel;
			}
		} else if (y_mode == 1) {
			if (always_bounce || (R.player.y <= y && velocity.y == 0 && R.player.x + R.player.width> x && R.player.x + R.player.width- 1 <= x+width)) {
				y_mode = 3;
				velocity.y = -y_dash_vel;
			}
		} else if (y_mode == 2) { // dashing right, wait to hit osmething
			if (parent_state.tm_bg.getTileCollisionFlags( x + width/2,y + height+1) != 0) {
				velocity.y = 0;
				y_mode = 1;
			}
		} else if (y_mode == 3) {
			if (parent_state.tm_bg.getTileCollisionFlags(x + width/2,y - 1)	 != 0) {
				velocity.y = 0;
				y_mode = 0;
			}
		}
		
		if (sepd || R.player.overlaps(this)) {
			
			var do_hurt:Bool = false;
			if (is_hor && touching & (FlxObject.LEFT | FlxObject.RIGHT) != 0) {
				do_hurt = true;
			} 
			if (is_vert && touching & (FlxObject.UP | FlxObject.DOWN) != 0) {
				do_hurt = true;
			}
			if (R.player.overlaps(this)) {
				do_hurt = true;
			}
			
			if (is_hor && !dmgd && R.player.overlaps(this) && (touching & (FlxObject.DOWN | FlxObject.UP) == 0)) {
				R.player.do_hor_push( Std.int(velocity.x), false, false, 3);
			}
			
			if (do_hurt) {
				if (dmgtype == 0) {
					R.player.add_dark(1);
				} else {
					R.player.add_light(1);
				}
				
				if ((0 != parent_state.tm_bg.getTileCollisionFlags(R.player.x, R.player.y + R.player.height - 3) || 0 != parent_state.tm_bg.getTileCollisionFlags(R.player.x + width, R.player.y + R.player.height - 3)) && !dmgd) {
					dmgd = true;
					if (dmgtype == 0) {
						R.player.add_dark(32);
					} else {
						R.player.add_light(32);
					}
				}
			} 
		} else {
				dmgd = false;
		}
		super.update(elapsed);
	}
	private var dmgd:Bool  = false;
	
}