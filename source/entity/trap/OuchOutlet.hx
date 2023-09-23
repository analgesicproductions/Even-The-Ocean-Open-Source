package entity.trap;
/**
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
import autom.SNDC;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import entity.MySprite;
import flixel.group.FlxGroup;
 
import help.HF;
import state.MyState;

class OuchOutlet extends MySprite
{

	private var sparks:FlxTypedGroup<FlxSprite>;
	private var hurt_sprite:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		sparks = new FlxTypedGroup<FlxSprite>();
		hurt_sprite = new FlxSprite();
		super(_x, _y, _parent, "OuchOutlet");
	}
	
	private function set_sparks_size(s:FlxSprite, i:Int ):Void {
		if (len > 1) {
			switch (i) {
				case 0:
					s.height = len * 16;
				case 1:
					s.width = len * 16;
				case 2:
					s.height = len * 16;
				case 3:
					s.width = len * 16;
			}
		}
	}
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				for (i in 0...4) {
					var s:FlxSprite = new FlxSprite();
					s.makeGraphic(16, 16, 0xffff00ff);
					sparks.add(s);
					set_sparks_size(s,i);
				}
				hurt_sprite.makeGraphic(32, 32, 0xffff44ff);
				makeGraphic(16, 16, 0xeeff33ee);
			case 1:
				for (i in 0...4) {
					var s:FlxSprite = new FlxSprite();
					s.makeGraphic(16, 16, 0xffffffff);
					sparks.add(s);
					set_sparks_size(s,i);
				}
				makeGraphic(16, 16, 0xeef7f5f6);
				hurt_sprite.makeGraphic(32, 32, 0xeefff3f2);
			default:
				makeGraphic(16, 16, 0xeef7f5f6);
		}
	}
	
	private var t_on:Float;
	private var tm_on:Float;
	private var t_off:Float;
	private var tm_off:Float;
	private var t_dmg_reset:Float = 0;
	private var tm_dmg_reset:Float;
	private var len:Int = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("tm_on", 1);
		p.set("tm_off", 1);
		p.set("dmg", 48);
		p.set("tm_dmg_reset", 0.5);
		p.set("tm_slow_player", 0.5);
		p.set("vel_lr", 250);
		p.set("vel_lr_ticks", 13);
		p.set("vel_down", 250);
		p.set("vel_up", 355);
		p.set("len", 1);
		return p;
	}
	
	private var t_slow_player:Float = 0;
	private var tm_slow_player:Float = 0;
	private var vel_lr:Int= 0;
	private var vel_lr_ticks:Int = 0;
	private var vel_down:Int = 0;
	private var vel_up:Int = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		sparks.clear();
		len = props.get("len");
		change_visuals();
		tm_off = props.get("tm_off");
		tm_on = props.get("tm_on");
		tm_dmg_reset = props.get("tm_dmg_reset");
		tm_slow_player = props.get("tm_slow_player");
		vel_lr = props.get("vel_lr");
		vel_lr_ticks = props.get("vel_lr_ticks");
		vel_down = props.get("vel_down");
		vel_up = props.get("vel_up");
		if (len < 1) len = 1;
		sparks.setAll("exists", false);
		hurt_sprite.exists = false;
	}
	
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [sparks,hurt_sprite]);
		super.destroy();
	}
	
	private var dmgd:Bool = false;
	private var is_damaging:Bool = false;
	private var dmg_dir:Int = 0;
	private var allow_move:Int = 2;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [sparks,hurt_sprite]);
		}
		
		if (state == 0) {
			t_off += FlxG.elapsed;
			if (t_off > tm_off ) {
				t_off = 0;
				var s:FlxSprite = null;
				for (i in 0...4) {
					s = cast sparks.members[i];
					switch (i) {
						case 0:
							s.x = this.x;
							s.y = this.y - s.height;
						case 1:
							s.x = this.x + this.width;
							s.y = this.y;
						case 2:
							s.x = this.x;
							s.y = this.y + this.height;
						case 3:
							s.x = this.x - s.width;
							s.y = this.y;
					}
					s.exists = true;
					if (parent_state.tm_bg.getTileCollisionFlags(s.x + s.width / 2, s.y + s.height / 2) != 0) {
						s.exists = false;
					}
				}
				state = 1;
			}
			
		} else if (state == 1) {
			t_on += FlxG.elapsed;
			
			
			if (t_on > tm_on) {
				t_on = 0;
				state = 0;
				sparks.setAll("exists", false);
				dmgd = false; 
				t_dmg_reset = 0;
			} else {
				
					
				if (dmgd && !is_damaging) {
					t_dmg_reset += FlxG.elapsed;
					if (t_dmg_reset > tm_dmg_reset) {
						t_dmg_reset = 0;
						dmgd = false;
					}
				}
				
				var s:FlxSprite = null;
				for (i in 0...4) {
					s = cast sparks.members[i];
					if (s.exists && s.overlaps(R.player)) {
						if (!dmgd) {
							hurt_sprite.exists = true;
							hurt_sprite.x = R.player.x + R.player.width / 2 - hurt_sprite.width / 2;
							hurt_sprite.y = R.player.y + R.player.height / 2 - hurt_sprite.height / 2;
							is_damaging = true;
							dmgd = true;
							dmg_dir = i;
							R.sound_manager.play(SNDC.OuchOutlet_Shock);
							break;
						}
					}
				}
			}
		}
		
		if (is_damaging) {
			t_slow_player += FlxG.elapsed;
			if (t_slow_player > tm_slow_player) {
				t_slow_player = 0;
				is_damaging = false;
				R.player.skip_motion_ticks = -1;
				hurt_sprite.exists = false;
				if (dmgtype == 0) {
					R.player.add_dark(props.get("dmg"));
				} else {
					R.player.add_light(props.get("dmg"));
				}
				
				R.sound_manager.play(SNDC.OuchOutlet_Shock_Hit);
				switch (dmg_dir) {
					case 0:
						//FlxG.cameras.shake(0.04, 0.1, null, true, FlxCamera.SHAKE_VERTICAL_ONLY);
						R.player.do_vert_push(-vel_up);
					case 1:
						//FlxG.cameras.shake(0.03, 0.05, null, true, FlxCamera.SHAKE_HORIZONTAL_ONLY);
						R.player.do_hor_push(vel_lr, false, false, vel_lr_ticks);
					case 2:
						//FlxG.cameras.shake(0.04, 0.1, null, true, FlxCamera.SHAKE_VERTICAL_ONLY);
						R.player.do_vert_push(vel_down);
					case 3:
						//FlxG.cameras.shake(0.03, 0.05, null, true, FlxCamera.SHAKE_HORIZONTAL_ONLY);
						R.player.do_hor_push(-vel_lr, false, false, vel_lr_ticks);
				}
			} else {
				
				hurt_sprite.x = R.player.x + R.player.width / 2 - hurt_sprite.width / 2;
				hurt_sprite.y = R.player.y + R.player.height / 2 - hurt_sprite.height / 2;
				R.player.randomize_draw_pos = true;
				R.player.randomize_draw_range = 2;
				allow_move ++;
				if (allow_move == 6) {
					if (dmgtype == 0) {
						R.player.add_dark(1);
					} else {
						R.player.add_light(1);
					}
					allow_move = 0;
					R.player.skip_motion_ticks = -1; 
				} else {
					R.player.skip_motion_ticks = 1;
				}
			}
		}
		
		
		
		super.update(elapsed);
	}
	
	override public function draw():Void 
	{
		if (len > 1) {
			var a:Array<FlxSprite> = sparks.members;
			for (i in 0...len - 1) {
				a[0].y += 16; if (a[0].exists) a[0].draw();
				a[1].x += 16; if (a[1].exists) a[1].draw();
				a[2].y += 16; if (a[2].exists) a[2].draw();
				a[3].x += 16; if (a[3].exists) a[3].draw();
			}
			for (i in 0...len - 1) {
				a[0].y -= 16;
				a[1].x -= 16;
				a[2].y -= 16;
				a[3].x -= 16;
			}
		}
		super.draw();
	}
}