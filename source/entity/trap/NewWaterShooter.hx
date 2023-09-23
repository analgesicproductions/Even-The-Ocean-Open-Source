package entity.trap;
import autom.SNDC;
import entity.MySprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import global.C;
import help.AnimImporter;
import help.HF;
import state.MyState;

class NewWaterShooter extends MySprite
{

	
	private var body_sprite:FlxSprite;
	private var collide_sprite:FlxSprite;
	private var base_sprite:FlxSprite;
	
	private var water_shield:FlxSprite;
	private var water_foot:FlxSprite;
	private var ps:FlxTypedGroup<FlxSprite>;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		water_shield = new FlxSprite();
		water_foot = new FlxSprite();
		body_sprite = new FlxSprite();
		collide_sprite = new FlxSprite();
		base_sprite = new FlxSprite();
		ps = new FlxTypedGroup<FlxSprite>();
		for (i in 0...10) {
			var p:FlxSprite = new FlxSprite();
			p.loadGraphic("assets/sprites/trap/geyser_particle.png", true, 16, 16);
			for (j in 0...4) {
				p.animation.add(Std.string(j), [j], 10, true);
			}
			ps.add(p);
		}
		ps.exists = false;
		
		super(_x, _y, _parent, "NewWaterShooter");
	}
	
	override public function change_visuals():Void 
	{
		
		body_sprite.makeGraphic(32, 16, 0xcc0033ff);
		makeGraphic(32, 16, 0xcc0000ff);
		var fps:Int = Std.int(accel / 50.0); // or omething else
		
		AnimImporter.loadGraphic_from_data_with_id(body_sprite, 32, 16, "NewWaterShooter");
		AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, "NewWaterShooter");
		AnimImporter.loadGraphic_from_data_with_id(base_sprite, 48, 16, "NewWaterShooterBase");
		AnimImporter.loadGraphic_from_data_with_id(water_shield, 64, 32, "NewWaterShooterShield");
		AnimImporter.loadGraphic_from_data_with_id(water_foot, 32, 32, "NewWaterShooterFoot");
		
		water_shield.animation.play("spray");
		water_foot.animation.play("spray");
		
		body_sprite.animation.play("main", true);
		animation.play("top", true);
		base_sprite.animation.play("idle", true);
		//AnimImporter.loadGraphic_from_data_with_id(body_sprite, 32, 16, "WaterShooter", 0);
		//AnimImporter.loadGraphic_from_data_with_id(this, 32, 16, "WaterShooter", 0);
		//body_sprite.animation.play("a", false);
		//body_sprite.animation.curAnim.frameRate = fps;
		//animation.play("a", false);
		//animation.curAnim.frameRate = fps;
		if (R.TEST_STATE.MAP_NAME == "PASS_1" || R.TEST_STATE.MAP_NAME == "PASS_2") {
			base_sprite.alpha = 0;
		}
		switch (vistype) {
			case 0:
			case 1:
			default:
		}
	}
	
	private var off_from_energy:Bool = false;
	override public function recv_message(message_type:String):Int 
	{
		if (message_type == C.MSGTYPE_ENERGIZE_TICK_LIGHT) {
			alpha = 0;
			body_sprite.alpha = collide_sprite.alpha = 0;
			off_from_energy = true;
		} else if (message_type == "PUSH") {
			tile_height ++;
			collide_sprite.makeGraphic(32, 16 * tile_height, 0x88ffffff);
			y -= 16;
		}
		return 1;
	}
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("accel", 10);
		p.set("fall_dampen", 0);
		p.set("max_vel", 280);
		p.set("tile_height", 6);
		p.set("is_vert", 1);
		p.set("extra_shield_push", 3.0);
		return p;
	}
	private var max_vel:Float;
	private var accel:Float;
	private var tile_height:Int;
	private var fall_dampen:Float = 0;
	private var is_vert:Bool = false;
	private var wasInGeyser:Bool = false;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		fall_dampen = props.get("fall_dampen");
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		accel = props.get("accel");
		max_vel = props.get("max_vel");
		tile_height = props.get("tile_height");
		is_vert = props.get("is_vert") == 1;
		change_visuals();
		collide_sprite.makeGraphic(32, 16 * tile_height, 0x88ffffff);
		
	}
	
	override public function destroy():Void 
	{
		
		HF.remove_list_from_mysprite_layer(this, parent_state, [collide_sprite,base_sprite,water_shield]);
		HF.remove_list_from_mysprite_layer(this, parent_state, [water_foot,ps],MyState.ENT_LAYER_IDX_FG2);
		super.destroy();
	}
	
	private var sound_on:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		base_sprite.x = x + width / 2 - base_sprite.width / 2;
		base_sprite.y = y + 16 * tile_height - base_sprite.height;
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [collide_sprite,base_sprite,water_shield]);
			HF.add_list_to_mysprite_layer(this, parent_state, [water_foot,ps], MyState.ENT_LAYER_IDX_FG2);
			//collide_sprite.visible = false;
		}
		
		if (water_foot.exists) {
			water_foot.alpha -= 0.2;
			if (water_foot.alpha <= 0) {
				water_foot.exists = false;
			}
		}
		if (water_shield.exists) {
			water_shield.alpha -= 0.2;
			if (water_shield.alpha <= 0) {
				water_shield.exists = false;
			}
		}
		if (R.editor.editor_active) {
			collide_sprite.visible = true;
		} else {
			collide_sprite.visible = false;
		}
		
		collide_sprite.move(x, y);
		body_sprite.update(elapsed);
		
		if (off_from_energy) {
			return;
		}
		
		if (sound_on) {
			if (!R.player.overlaps(collide_sprite)) {
				sound_on = false;
			}
			
		} else {
			if (R.player.overlaps(collide_sprite)) {
				if (Math.abs(R.player.velocity.y) + Math.abs(R.player.velocity.x) <= 110) {
					R.sound_manager.play(SNDC.splash, 0.35);	
				} else {
					R.sound_manager.play(SNDC.splash, 0.7);
				}
				sound_on = true;
			}
		}
		
		if (is_vert) {
			if (R.player.overlaps(collide_sprite)) {
				if (ID == 0) {
					ID++;
					if (R.player.get_shield_dir() == 2 || R.player.get_shield_dir() == 0 || R.player.has_bubble) {
						R.sound_manager.play(SNDC.geyser, 0.7);
					} else {
						R.sound_manager.play(SNDC.geyser, 0.4);
					}
				} else {
					ID++;
					if (ID == 28) {
						ID = 0;
					}
				}
				wasInGeyser = true;
				water_foot.exists = true;
				water_foot.x = R.player.x + R.player.width / 2 - water_foot.width / 2;
				water_foot.y = R.player.y + R.player.height - 12;
				water_foot.alpha += 0.35;
				R.player.force_no_var_jump = true;
				// 9 is the dv for the player's default accel 
				if (R.player.is_on_the_ground(true)) {
					R.player.y -= 2;
					//R.player.last.y -= 2;
					//R.player.animation
				}
				if (R.player.is_in_water()) {
					R.player.y -= 1;
				}
				// Makes the geyser weaker when falling down 
				if (R.player.velocity.y > 0) {
					R.player.velocity.y += fall_dampen;
				}
				R.player.velocity.y -= (accel + 9.0);
				if (R.player.get_shield_dir() == 2 || R.player.get_shield_dir() == 0 || R.player.has_bubble) {
					if (R.player.y >= y && R.player.get_shield_dir() == 0) {
						water_shield.exists = true;
						water_shield.alpha += 0.35;
						water_shield.angle = 0;
						water_shield.x = R.player.x + R.player.width / 2 - water_shield.width / 2;
						water_shield.y = R.player.y - water_shield.height + 16;
					} else if (R.player.y + R.player.height -6>= y && 2 == R.player.get_shield_dir()) {
						water_shield.exists = true;
						water_shield.alpha += 0.35;
						water_shield.angle = 180;
						water_shield.x = R.player.x + R.player.width / 2 - water_shield.width / 2;
						water_shield.y = R.player.y - water_shield.height + 16 + 16;
					}
					R.player.velocity.y -= props.get("extra_shield_push");
					if (R.player.velocity.y < -max_vel) {
						R.player.velocity.y = -max_vel;
					}
				} else {
					if (R.player.velocity.y < -max_vel*.72) {
						R.player.velocity.y = -max_vel*.72;
					}
				}
				// If in the next frame the player will not be touching the water's top and you are too slow, go to
				// a min velocity so there is no rapid useless bouncing
				if ((R.player.y + R.player.height + R.player.velocity.y * FlxG.elapsed < y)) {
					if (R.player.velocity.y > -200) {
						R.player.velocity.y = -200;
					}
				}
			} else {
				ID = 0;
				if (wasInGeyser) {
					wasInGeyser = false;
					if (!ps.exists) {
						ps.exists = true;
						for (i in 0...ps.length) {
							var p:FlxSprite = ps.members[i];
							if (p != null) {
								p.velocity.set(0 + Math.random()*R.player.velocity.x*1.2, R.player.velocity.y*0.6);
								p.animation.play(Std.string(Std.int(4 * Math.random())), true);
								p.acceleration.y = 450;
								p.alpha = 1;
								p.move(R.player.x -16 + 24 * Math.random(), R.player.y + 13 * Math.random());
								
								if (Math.abs(p.velocity.x) < 30) {
									p.velocity.x = -60 + 120 * Math.random();
								}
								p.drag.x = 60 + Math.abs(p.velocity.x)/2;
								p.velocity.y *= ( 0.8 + 0.5 * Math.random());
								p.ID = 10 + Std.int(25*Math.random());
							}
						}
					}
				}
			}
			
			if (ps.exists) {
				var adone:Bool = true;
				for (i in 0...ps.length) {
					var p:FlxSprite = ps.members[i];
					if (p != null) {
						p.ID--;
						if (p.ID <= 0) {
							p.alpha *= 0.94; p.alpha -= 0.03;
						}
						if (p.alpha > 0) {
							adone = false;
						}
					}
				}
				if (adone) {
					ps.exists = false;
				}
			}
		}
		super.update(elapsed);
	}
	
	override public function draw():Void 
	{
		for (i in 0...tile_height - 1) {
			body_sprite.y = y + 16 * (i + 1);
			body_sprite.x = x;
			body_sprite.draw();
		}
		super.draw();
	}
	
	
}