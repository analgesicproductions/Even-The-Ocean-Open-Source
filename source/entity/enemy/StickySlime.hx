package entity.enemy;
import entity.MySprite;
import help.AnimImporter;
import help.HF;
import flixel.FlxG;
import flixel.FlxObject;
import state.MyState;

class StickySlime extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "StickySlime");
	}
	
	private static var VISTYPE_LIGHT:Int = 0;
	private static  var VISTYPE_DARK:Int = 1;
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 5, 5, name, "light");
				dmgtype = VISTYPE_LIGHT;
				animation.play("idle", true);
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 5, 5, name, "dark");
				dmgtype = VISTYPE_DARK;
				animation.play("idle", true);
		}
	}
	
	//private var is_shield:Bool = false;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		//p.set("is_shield", 1);
		p.set("init_wall_dir", 0);
		p.set("vistype", 0);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		//is_shield = props.get("is_shield") == 1;
		vistype = props.get("vistype");
		change_visuals();
		on_wall = true;
		
		//if (is_shield) {
			play_wall_move(props.get("init_wall_dir"));
		//}
	}
	
	override public function destroy():Void 
	{
		
		super.destroy();
	}
	override public function preUpdate():Void 
	{
		FlxObject.separate(this, parent_state.tm_bg);
		super.preUpdate();
	}
	override public function update(elapsed: Float):Void 
	{
		// Styles
		// shake-off
		// shield-off
		// jump-off
		
		//if (is_shield) {
			update_shield();
		//}
		
		
		super.update(elapsed);
	}
	
	private var on_wall:Bool = false;
	private var in_air:Bool = false;
	private var wall_dir:Int;
	private var is_dead:Bool = false;
	private var t_dead:Float = 0;
	private var tm_dead:Float  = 2;
	private var on_body:Bool = false;
	
	private var energy_sapped:Int = 0;
	private var max_energy_sap:Int = 24;
	
	private var no_attach_ticks:Int = 0;
	private var t_sap:Float = 0;
	
	private static var shared_shield_stick_dir:Int;
	private static var lost_one:Bool = false;
	private function update_shield():Void {
		
		if (no_attach_ticks > 0) no_attach_ticks --;
		if (is_dead) {
			t_dead += FlxG.elapsed;
			if (t_dead > tm_dead ) {
				t_dead = 0;
				is_dead = false;
				visible = true;
				on_body = in_air = false;
				on_wall = true;
				x = ix;
				y = iy;
				play_wall_move(props.get("init_wall_dir"));
			}
			return;
		}
		if (on_wall) {
			if (R.player.overlaps(this)) {
				on_body = true;
				on_wall = false;
			} else {
				find_Shield_Collision();
				if (!on_wall) {
					animation.play("idle");
				}
			}
		} else if (on_body) {
			x = R.player.x;
			y = R.player.y;
			if (dmgtype == VISTYPE_DARK) {
				R.player.add_dark(24);
			} else {
				R.player.add_light(24);
			}
			
			visible = false;
			on_body = false;
			is_dead = true;
		} else if (in_air) {
			
			if (R.player.overlaps(this) && no_attach_ticks <= 0) {
				on_body = true; in_air = false;
				velocity.y = velocity.x = acceleration.y = 0;
			} else if (touching != 0) {
				switch (touching) {
					case FlxObject.UP:
						animation.play("u");
					case FlxObject.RIGHT:
						animation.play("r");
					case FlxObject.DOWN:
						animation.play("d");
					case FlxObject.LEFT:
						animation.play("l");
				}
				velocity.y = velocity.x = acceleration.y = 0;
				on_wall = true;
				in_air = false;
			} else if (no_attach_ticks <= 0) {
				if (find_Shield_Collision()) {
					in_air = false;
					velocity.y = velocity.x = acceleration.y = 0;
				}
			}
		} else {
			
			switch (shared_shield_stick_dir) {
				case 0:
					x = R.player.x + 2;
					y = R.player.y - 2;
				case 1:
					x = R.player.x + width + 2;
					y = R.player.y + 7;
				case 2:
					x = R.player.x + 2;
					y = R.player.y + 10;
				case 3:
					x = R.player.x - 1;
					y = R.player.y + 7;
			}
			
			var player_shield_dir:Int = R.player.get_shield_dir();
			if (shared_shield_stick_dir != player_shield_dir) { // poop off one
				in_air = true;
				no_attach_ticks = 20;
				var fire_dir:Int = player_shield_dir;
				if (player_shield_dir == 4) {
					fire_dir = shared_shield_stick_dir;
				}
				switch (fire_dir) {
					case 0:
						velocity.y = -150;
						velocity.x = R.player.velocity.x;
					case 1:
						velocity.x = 120;
					case 2:
						velocity.y = 80;
						velocity.x = R.player.velocity.x;
					case 3:
						velocity.x = -120;
				}
				acceleration.y = 250;
				
				if (player_shield_dir != 4) {
					shared_shield_stick_dir = player_shield_dir;
				}
			}
		}
	}
	
	private function hurt_player():Void {
		switch (dmgtype) {
			case 1:
				R.player.add_dark(16);
			case 0:
				R.player.add_light(16);
		}
	}
	private function play_wall_move(dir:Int = 0):Void 
	{
		switch (dir) {
			case 0:
				animation.play("u");
			case 1:
				animation.play("r");
			case 2:
				animation.play("d");
			case 3:
				animation.play("l");
		}
	}
	
	private function find_Shield_Collision():Bool 
	{
		if (R.player.shield_overlaps(this, 0)) {
			on_wall = false;
			shared_shield_stick_dir = 0;
			return true;
		} else if (R.player.shield_overlaps(this, 1)) {
			on_wall = false;
			shared_shield_stick_dir = 1;
			return true;
		} else if (R.player.shield_overlaps(this, 2)) {
			on_wall = false;
			shared_shield_stick_dir = 2;
			return true;
		} else if (R.player.shield_overlaps(this, 3)) {
			on_wall = false;
			shared_shield_stick_dir = 3;
			return true;
		}
			return false;
	}
}