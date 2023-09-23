package entity.trap;
import entity.MySprite;
import flash.Lib;
import flixel.FlxG;
import flixel.FlxObject;
import help.AnimImporter;
import help.HF;
import state.MyState;

class MoveBlock extends MySprite
{

	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y, _parent, "MoveBlock");
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32, name,"dark");
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32,name,"light");
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 32, 32,name,Std.string(vistype));
		}
		animation.play("idle");
	}
	override public function preUpdate():Void 
	{
		FlxObject.separate(parent_state.tm_bg,this);
		super.preUpdate();
	}
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("init_dir", 1); // 0 to 3
		p.set("max_vel", 100);
		p.set("accel", 100);
		p.set("t_wait", 1);
		p.set("clockwise", 0);
		return p;
	}
	
	private var init_accel:Float = 0;
	private var t_wait:Float = 0;
	private var tm_wait:Float = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		dir = props.get("init_dir");
		tm_wait = props.get("t_wait");
		init_accel = props.get("accel");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	private var wall_mode:Int = 0;
	
	private var mode:Int = 0;
	private var dir:Int = 0;
	private var is_charged:Bool = false;
	
	override public function update(elapsed: Float):Void 
	{
		
	
		
		if (is_charged  && mode != 0 &&  overlaps(R.player)) {
			is_charged = false;
			if (dmgtype == 0) {
				R.player.add_dark(18);
			} else {
				R.player.add_light(18);
			}
			if (velocity.x != 0) {
				R.player.do_hor_push(Std.int(velocity.x)*3, false, false, 10);
			} else {
				R.player.do_vert_push(Std.int(velocity.y)*3);
			}
			animation.play("discharged");
		}
		if (mode == 0) {
			t_wait += FlxG.elapsed;
			if (t_wait > tm_wait) {
				t_wait = 0;
				mode = 1;
				animation.play("charged");
				is_charged = true;
				if (dir == 0) {
					acceleration.y = init_accel * -1;
				} else if (dir == 1) {
					acceleration.x = init_accel;
				} else if (dir == 2) {
					acceleration.y = init_accel;
				} else if (dir == 3) {
					acceleration.x = -init_accel;
				}
			}
		} else if (mode == 1) {
			if (touching != FlxObject.NONE) {
				mode = 0;
				animation.play("idle");
				if (props.get("clockwise") == 0) {
					dir --; 
					if (dir == -1) dir = 3;
				} else {
					dir ++;
					if (dir == 4) dir = 0;
				}
				acceleration.set(0, 0);
				velocity.set(0, 0);
			}
		}
		
		
		super.update(elapsed);
		
		if (Math.abs(velocity.y) > props.get("max_vel")) {
			if (velocity.y > 0) velocity.y = props.get("max_vel");
			if (velocity.y <= 0) velocity.y = -props.get("max_vel");
		} 
		if (Math.abs(velocity.x) > props.get("max_vel")) {
			if (velocity.x > 0) velocity.x = props.get("max_vel");
			if (velocity.x <= 0) velocity.x = -props.get("max_vel");
		}
	}
	
		
		
}