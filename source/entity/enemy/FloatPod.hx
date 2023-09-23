package entity.enemy;
import autom.EMBED_TILEMAP;
import autom.SNDC;
import entity.MySprite;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import state.MyState;
import help.AnimImporter;
import flixel.FlxG;
import flixel.FlxSprite;

class FloatPod extends MySprite
{

	private var wings:FlxSprite;
	private var anim_mode:Int;
	private var logic_mode:Int;
	private var t_recover:Float = 0;
	private var tm_recover:Float = 0;
	
	private var linear_velocity:Int = 0;
	
	private var circ_angle:Float = 0;
	private var circ_angle_vel:Float = 0;
	private var circ_radius:Float = 0;
	
	private var is_circle:Bool = false;
	private var upDown:Bool = false;
	
	
	private var poof:FlxSprite;
	private var poof_mode:Int = 0;
	
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		wings = new FlxSprite();
		poof = new FlxSprite();
		super(_x, _y, _parent, "FloatPod");
	}
	
	override public function change_visuals():Void 
	{
		
		
		AnimImporter.loadGraphic_from_data_with_id(poof, 64, 64, "HurtEffectGroup", "pod_poof");
		poof.exists = false;
		switch (vistype) {
			case 0:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", "1");
			case 1:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", "0");
			default:
				AnimImporter.loadGraphic_from_data_with_id(this, 16, 16, "Pod", "0");
				
		}
		animation.play("n_full");
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		
		p.set("is_circle", 0);
		p.set("start_angle", 0);
		p.set("circ_radius", 48);
		p.set("circ_angle_vel", 180);
		
		p.set("linear_velocity", 100);
		p.set("upDown", 1);
		p.set("startsDownRight", 1);
		p.set("tm_recover", 0.8);
		
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);

		linear_velocity = props.get("linear_velocity");
		t_recover = 0;
		tm_recover = props.get("tm_recover");
		
		circ_angle = props.get("start_angle");
		circ_radius = props.get("circ_radius");
		circ_angle_vel = props.get("circ_angle_vel");
		is_circle = 1 == props.get("is_circle");
		upDown = 1 == props.get("upDown");
		
		change_visuals();
		
		width = height = 8;
		offset.set(4, 4);
		set_Init_Vel();
		x = ix + offset.x;
		y = iy + offset.y;
		
		anim_mode = 0;
		
	}
	
	override public function destroy():Void 
	{
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [poof,wings]);
		super.destroy();
	}
	
	private var editorWasOn:Bool = false;
	override public function update(elapsed:Float):Void 
	{
		
		if (!did_init) {
			did_init = true;
			
			HF.insert_list_before_object_in_mysprite_layer(this, parent_state, [poof]);
			HF.add_list_to_mysprite_layer(this, parent_state, [wings]);
		}
		if (R.editor.editor_active) {
			move(ix, iy);
			circ_angle = props.get("start_angle");
			velocity.set(0, 0);
			set_Init_Vel();
			editorWasOn = true;
			return;
		}
		
		
		
		if (editorWasOn) {
			editorWasOn = false;
			x = ix + offset.x;
			y = iy + offset.y;
		}
		
		
		
		if (poof_mode == 0) {
		} else if (poof_mode == 1) {
			poof.exists = true;
			if (dmgtype == 0) {
				poof.animation.play("d", true);
			} else {
				poof.animation.play("l", true);
			}
			poof.x = (x + width / 2) - poof.width / 2;
			poof.y = (y + height / 2) - poof.height / 2;
			poof_mode = 2;
		} else if (poof_mode == 2) {
			if (poof.animation.finished) {
				poof_mode = 0;
				poof.exists = false;
			}
		}
		
		
		
		if (is_circle) {
			circ_angle += circ_angle_vel * elapsed;
			if (circ_angle >= 360.0) circ_angle -= 360.0;
			if (circ_angle < 0) circ_angle += 360.0;
			x = ix + offset.x + circ_radius * FlxX.cos_table[Std.int(circ_angle)];
			y = iy + offset.y + circ_radius * FlxX.sin_table[Std.int(circ_angle)];
		} else {
			if (logic_mode == 0) {
				if (needsToTurn()) {
					if (velocity.x != 0) acceleration.x = -1 * velocity.x * 4;
					if (velocity.y != 0) acceleration.y = -1 * velocity.y * 4;
					logic_mode = 1;
				}
			} else if (logic_mode == 1) {
				if (acceleration.x > 0 && velocity.x > linear_velocity) { velocity.x = linear_velocity; logic_mode = 0; }
				if (acceleration.x < 0 && velocity.x < -linear_velocity) { velocity.x = -linear_velocity; logic_mode = 0; }
				if (acceleration.y > 0 && velocity.y > linear_velocity) { velocity.y = linear_velocity; logic_mode = 0; }
				if (acceleration.y < 0 && velocity.y < -linear_velocity) { velocity.y = -linear_velocity; logic_mode = 0; }
				if (logic_mode == 0) {
					acceleration.set(0, 0);
				}
			}
		}
		
		if (anim_mode == 0) {
			if (R.player.overlaps(this)) {
				if (dmgtype == 0) {
					R.player.energy_bar.add_dark(24);
				} else {
					R.player.energy_bar.add_light(24);
				}
				R.sound_manager.play(SNDC.pod_hit);
				animation.play("n_empty");
				anim_mode = 1;
				poof_mode = 1;
			}
		} else if (anim_mode == 1) {
			t_recover += elapsed;
			if (t_recover >= tm_recover) {
				t_recover = 0;
				anim_mode = 0;
				animation.play("n_full");
			} else if (t_recover >= tm_recover * 0.7) {
				animation.play("n_recover");
			}
		}
		
		super.update(elapsed);
	}
	private function needsToTurn():Bool {
		var txOff:Float = 0;
		var tyOff:Float = 0;
		if (velocity.x > 0 ) {
			txOff = width;
		} else if (velocity.x < 0) {
		} else if (velocity.y > 0) {
			tyOff = height;
		} else {
		}
		if (HelpTilemap.active_sand.indexOf(parent_state.tm_bg.getTileID(x + txOff,y+tyOff)) != -1 || HelpTilemap.active_sand.indexOf(parent_state.tm_bg2.getTileID(x + txOff,y+tyOff)) != -1) {
			return true;
		}
		return false;
	}
	function set_Init_Vel():Void 
	{
		velocity.set(0, 0);
		if (props.get("startsDownRight")) {
			if (upDown) {
				velocity.y = linear_velocity;
			} else {
				velocity.x = linear_velocity;
			}
		} else {
			if (upDown) {
				velocity.y = -linear_velocity;
			} else {
				velocity.x = -linear_velocity;
			}
		}
	}
}