package entity.util;
import autom.SNDC;
import entity.enemy.AimSpore;
import entity.enemy.BallDropper;
import entity.enemy.GhostLight;
import entity.enemy.Hopper;
import entity.enemy.ShockFloat;
import entity.enemy.SmashHand;
import entity.enemy.SpikeExtend;
import entity.enemy.SquishyChaser;
import entity.enemy.WalkPod;
import entity.MySprite;
import entity.npc.Cauliflower;
import entity.player.BubbleSpawner;
import entity.trap.BarbedWire;
import entity.trap.FlameBlower;
import entity.trap.HurtOutlet;
import entity.trap.MiniMoveBlock;
import entity.trap.Pew;
import entity.trap.Pod;
import entity.trap.RubberLaser;
import entity.trap.Spike;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import global.EF;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import state.MyState;

class PlantBlock extends MySprite
{

	public var block:FlxSprite;
	public var bg:FlxSprite;
	public var particles:FlxTypedGroup<FlxSprite>;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		block = new FlxSprite();
		bg = new FlxSprite();
		super(_x, _y, _parent, "PlantBlock");
	}
	
	private var is_overlapping:Bool = false;
	override public function change_visuals():Void 
	{
		var s:String = R.TEST_STATE.MAP_NAME;
		var suf:String = "";
		if (s == "PASS_B" || s == "FALLS_B" || s == "CLIFF_B") {
			suf = "_pass";
		}
		if (vistype == 1 || vistype == 0) {
			AnimImporter.loadGraphic_from_data_with_id(block, 16, 16, name, "block");
			AnimImporter.loadGraphic_from_data_with_id(this, 48, 48, name,"default"+suf);
			width = height = 16;
			offset.x = offset.y = 16;
			if (behavior == 0) {
				AnimImporter.loadGraphic_from_data_with_id(bg, 0, 0, name, "hor"+suf);
				bg.width = bg.height = 16;
				bg.offset.set(32, 8);
			} else if (behavior == 1) {
				AnimImporter.loadGraphic_from_data_with_id(bg, 0, 0, name,"vert"+suf);
				bg.width = bg.height = 16;
				bg.offset.set(8, 32);
			} else if (behavior == 2) {
				AnimImporter.loadGraphic_from_data_with_id(bg, 0, 0, name, "circle");
				bg.width = bg.height = 16;
				bg.offset.set(32, 32);
			}
			bg.alpha = 1;
			
			bg.animation.play("idle");
			bg.visible = false;
			block.animation.play("idle");
			block.width = block.height = 8;
			block.offset.set(4, 4);
		} else {
			
		}
		
		
		playanim();
		block.visible = false;
	}
	
	private var block_dir:Int = 0;
	private var block_off_x:Float = 0;
	private var block_off_y:Float = 0;
	private var float_distance:Float = 0;
	private var behavior:Int = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("vis-dmg", "0,0");
		p.set("dir", 0);
		p.set("float_dis", 32);
		p.set("behavior", 1);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		dmgtype = Std.parseInt(props.get("vis-dmg").split(",")[1]);
		vistype = Std.parseInt(props.get("vis-dmg").split(",")[0]);
		block_dir = props.get("dir");
		float_distance = props.get("float_dis");
		behavior = props.get("behavior");
		if (behavior < 0 || behavior > 3) {
			behavior = 3;
			props.set("behavior", 3);
		}
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		BLOCK_LOCK = false;
		HF.remove_list_from_mysprite_layer(this, parent_state, [bg, block, particles], MyState.ENT_LAYER_IDX_FG2);
		if (active_plantblock == this) {
			active_plantblock = null;
		}
		super.destroy();
	}
	
	private var mode:Int = 0;
	
	private var t_osc:Float = 0;
	private var tm_osc:Float = 0.05;
	private var osc_idx:Int = 0;
	public static var BLOCK_LOCK:Bool = false;
	public static var active_plantblock:PlantBlock;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [bg,block],MyState.ENT_LAYER_IDX_FG2);	
		}
		
		
		if (particles !=  null && particles.exists) {
			for (i in 0...particles.length) {
				var p:FlxSprite = particles.members[i];
				p.alpha *= 0.99;
				p.alpha -= 0.002;
				if (p.alpha <= 0) {
					particles.exists = false;
					p.velocity.set(0, 0);
					p.acceleration.set(0, 0);
				}
			}
		}
		if (mode == 0) {
			
			
			if (!parent_state.dialogue_box.is_active()) {
				
				if (!BLOCK_LOCK && !overlapping_accepter && R.player.overlaps(this)) {
					if (!R.input.a2) {
						R.player.activate_npc_bubble("speech_appear");
						overlapping_accepter = true;
					}
				} else if (overlapping_accepter) {
					if (!R.player.overlaps(this)) {
						R.player.activate_npc_bubble("speech_disappear");
						overlapping_accepter = false;
					} else if (R.input.jpCONFIRM && !BLOCK_LOCK) {
						overlapping_accepter = false;
						R.player.activate_npc_bubble("speech_disappear");
					}
				}
			}
			
			if (R.player.overlaps(this) && R.input.jpCONFIRM) {
				if (BLOCK_LOCK && active_plantblock != null) {
					active_plantblock.destroy_active_block();
					active_plantblock = this;
				}
				if (parent_state.MAP_NAME == "INTRO_B" && R.event_state[EF.INTRO_plantblock_tut_done] == 0) {
					R.set_flag(EF.INTRO_plantblock_tut_done, true);
					parent_state.dialogue_box.start_dialogue("intro", "plantblock", 5);
				} else {
					// behavior : 0 1 2 3 for H, V, R, or HVR
					if (props.get("behavior") == 3) {
						parent_state.dialogue_box.start_dialogue("intro", "plantblock", 8 + props.get("behavior"));
					}
					mode = -1;
				}
				
			}
		} else if (mode == -1) {
			if (!parent_state.dialogue_box.is_active()) {
				
				if (props.get("behavior") == 3) {
					if (parent_state.dialogue_box.last_yn != 3) {
						behavior = parent_state.dialogue_box.last_yn;
						//hor vert circle - 0 1 2
						change_visuals();	
						behavior = parent_state.dialogue_box.last_yn + 1;
					} else {
						mode = 0;
						return;
					}
					
				} else {
					behavior = props.get("behavior") + 1;
				}
				
				mode = 3;
				osc_idx = 0;
				BLOCK_LOCK = true;
				active_plantblock = this;
				block.visible = true; block.alpha = 0;
				R.sound_manager.play(SNDC.lens_get);
				bg.x = x;
				bg.y = y;
				bg.alpha = 1;
				bg.visible = true;
				bg.animation.play("idle");
				//continue
				
			}
		} else if (mode == 3) { // lego BG tracks to player
			bg.alpha += 0.05;
			bg.alpha *= 1.1;
			if (bg.alpha > 0.8) {
				bg.alpha = 1;
			}
			if (bg.x + bg.width / 2 < R.player.x + R.player.width / 2) {
				bg.velocity.x = 155;
			} else {
				bg.velocity.x = -155;
			}
			
			if (bg.y + bg.height / 2 < R.player.y + R.player.height / 2) {
				bg.velocity.y = 155;
			} else {
				bg.velocity.y = -155;
			}
			if (Math.abs((bg.x + bg.width / 2) - (R.player.x + R.player.width / 2)) < 3 && Math.abs((bg.y + bg.height/2) - (R.player.y + R.player.height / 2)) < 2 && bg.alpha == 1) {
				bg.x = R.player.x + R.player.width / 2 - (bg.width / 2);
				bg.y = R.player.y + R.player.height / 2 - (bg.height / 2);
				mode = 4;
				R.sound_manager.play(SNDC.lens_attach);
				bg.velocity.set(0, 0);
				if (props.get("float_dis") == 24) {
					bg.animation.play("small");
				} else {
					bg.animation.play("big");
				}
				
			}
		} else if (mode == 4) { // lego bg extends
			if (bg.animation.finished) {
				mode = 1;
			}
		} else if (mode == 1) { // lego is now moving
			
			if (R.player.overlaps(this) && R.input.jpCONFIRM) {
				destroy_active_block();
				return;
			}
			
			block.alpha += 0.1;
			block.alpha *= 1.1;
			if (block_dir == 0) {
				block_off_x = 0;
				block_off_y = -float_distance;
			} else if (block_dir == 1) {
				block_off_x = float_distance;
				block_off_y = 0;
			} else if (block_dir == 2) {					
				block_off_x = 0;
				block_off_y = float_distance;
			} else if (block_dir == 3) {
				block_off_x = -float_distance;
				block_off_y = 0;
			}
			if (behavior == 1 || behavior == 2 || behavior  == 3) {
				block_off_x = block_off_y = 0;
			}
		} else if (mode == 2) { // lego has broken or been placed
			bg.alpha -= 0.021;
			bg.alpha *= 0.93;
			if (block.animation.finished && bg.alpha <= 0.05) {
				bg.alpha = 0;
				bg.angle = 0;
				bg.velocity.set(0, 0); bg.acceleration.y = 0; bg.angularVelocity = 0;
				mode = 0;
				if (active_plantblock == this) {
					BLOCK_LOCK = false;
				}	
				block.x = ix;
				block.y = iy;
				block.animation.play("idle");
			}
			block.alpha = bg.alpha;
		}
		
		if (mode == 1) {
			
			if (behavior != 3) {
				if (osc_idx == 90 || osc_idx == 270) {
					if (t_wait_a_bit == 0) {
						t_wait_a_bit = 10;
						block.animation.play("flash");
					}
				}
				if (t_wait_a_bit > 0) {
					t_wait_a_bit --;
					if (t_wait_a_bit != 0) {
						super.update(elapsed);
						return;
						
					}
				}
			}
			
			
			t_osc += FlxG.elapsed;
			
			if (t_osc > tm_osc && mode != 2) {
				osc_idx += 5;
				t_osc -= tm_osc;
				if (osc_idx >= 360) {
					osc_idx = 0;
				}
			}
		}
		super.update(elapsed);
	}
	
	private var overlapping_accepter:Bool = false;
	private var t_wait_a_bit:Int = 0;
	override public function draw():Void 
	{
		if (mode == 1 || mode == 4) {
			bg.x = R.player.x + R.player.width / 2 - bg.width / 2;
			bg.y = R.player.y + R.player.height / 2 - bg.height / 2;
			block.x = R.player.x + R.player.width / 2 - block.width / 2;
			block.y = R.player.y + R.player.height / 2 - block.height / 2;
		} else if (mode == 0) {
			block.x = x;
			block.y = y;
		} else if (mode == 3) {
			block.x = bg.x + bg.width - block.width / 2;
			block.y = bg.y + bg.height - block.height / 2;
		}
		
		if (mode == 1 || mode == 3 || mode == 4) {
			if (behavior == 0) {
				block.y += 4 * FlxX.sin_table[osc_idx];
			} else if (behavior == 1) {
				block.x += float_distance * FlxX.sin_table[osc_idx];
			} else if (behavior == 2) {
				block.y += float_distance * FlxX.sin_table[osc_idx];
			} else if (behavior == 3) {
				block.x += float_distance * FlxX.cos_table[osc_idx];
				block.y -= float_distance * FlxX.sin_table[osc_idx];
			}
		}
		
		
		super.draw(); 
		if (mode == 1) {
			var i:PlantBlockAccepter;
			var b:Bool  = false;
		
			for (i in PlantBlockAccepter.ACTIVE_PlantBlockAccepters) {
				i.height += 4; i.width += 4; i.x -= 2; i.y -= 2;
				if (R.player.overlaps(i) && R.player.is_on_the_ground(true) && R.input.CONFIRM) {
					if (i.activate(behavior,false,false,true,osc_idx)) {
						mode = 0;
						BLOCK_LOCK = false;
						block.animation.play("idle");
						bg.alpha = 0;
						block.alpha = 0;
					}
				}
				i.height += -4; i.width += -4; i.x -= -2; i.y -= -2;
				
				if (R.player.overlaps(i) && !i.is_on()) {
					b = true;
				}
			}
			
			//if (!overlapping_accepter && b) {
				//R.player.activate_npc_bubble("speech_appear");
				//overlapping_accepter = true;
			//} else if (overlapping_accepter && !b) {
				//R.player.activate_npc_bubble("speech_disappear");
				//overlapping_accepter = false;
			//}
			
			var destroyed:Bool = false;
			for (pew in Pew.ACTIVE_Pews.members) {
				if (pew != null && pew.generic_overlap(block, -1)) {
					destroyed = true;
				}
			}
			
			for (pod in Pod.ACTIVE_Pods) {
				if (pod != null && !pod.is_vanish && pod.generic_overlap(block)) {
					destroyed = true;
				}
			}
			
			for (se in SpikeExtend.ACTIVE_SpikeExtends) {
				if (se.generic_overlap(block)) {
					destroyed = true;
				}
			}
			
			for (spike in Spike.ACTIVE_Spikes.members) {
				if (spike != null && spike.generic_overlap(block)) {
					destroyed = true;
				}
			}
			
			for (gl in GhostLight.ACTIVE_GhostLights) {
				if (gl.is_ghost && gl.generic_overlap(block)) {
					destroyed = true;
				}
			}
			
			for (fbb in FlameBlower.ACTIVE_FlameBlowers) {
				if (fbb.generic_overlap(block)) {
					destroyed = true;
				}
			}
			
			for (sf in ShockFloat.ACTIVE_ShockFloats) {
				if (sf.generic_overlap(block)) {
					destroyed = true;
				}
			}
			for (caul in Cauliflower.ACTIVE_Cauliflowers) {
				if (caul != null && caul.generic_overlap(block)) {
					destroyed = true;
				}
			}
			
			for (ho in HurtOutlet.ACTIVE_HurtOutlets) {
				if (ho != null && ho.generic_overlap(block)) {
					destroyed = true;
				}
			}
			
			for (rl in RubberLaser.ACTIVE_RubberLasers) {
				if (rl.generic_overlap(block)) {
					destroyed = true;
				}
			}
			for (bwww in BarbedWire.ACTIVE_BarbedWires) {
				if (bwww.generic_overlap(block)) {
					destroyed = true;
				}
			}
			
			for (smsm in SmashHand.ACTIVE_SmashHands) {
				if (smsm.generic_overlap(block)) {
					destroyed = true;
				}
			}
			for (fffe in SquishyChaser.ACTIVE_SquishyChasers) {
				if (fffe.generic_overlap(block)) {
					destroyed = true;
				}
			}
			
			for (wpod in WalkPod.ACTIVE_WalkPods) {
				if (wpod.hitbox.overlaps(block)) {
					destroyed = true;
				}
			}
			
			//
			//for (bd in BallDropper.ACTIVE_BallDroppers) {
				//if (bd.generic_overlap(block)) {
					//destroyed = true;
				//}
			//}
			//for (as in AimSpore.ACTIVE_AimSpores) {
				//if (as.generic_overlap(block)) {
					//destroyed = true;
				//}
			//}
			
			//for (hop in Hopper.ACTIVE_Hoppers) {
				//if (hop.generic_overlap(block)) {
					//destroyed = true;
				//}
			//}
			//
			//for (mmb in MiniMoveBlock.ACTIVE_MiniMoveBlocks) {
				//if (mmb.generic_overlap(block)) {
					//destroyed = true;
				//}
			//}
			
			var no_gas:Bool = false;
			if (BubbleSpawner.cur_bubble != null) {
				if (FlxX.circle_flx_obj_overlap(BubbleSpawner.circle[0], BubbleSpawner.circle[1], BubbleSpawner.circle[2], block)) {
					no_gas = true;
				}
			}
			
			if (!no_gas) {
				var gasarray:Array<Int> = [];
				for (tm in [parent_state.tm_bg,parent_state.tm_bg2]) {
					gasarray = HelpTilemap.active_gaslight;
					if (HF.array_contains(gasarray, tm.getTileID(block.x + block.width / 2, block.y + block.height / 2))) {
						destroyed = true;
					}
					gasarray = HelpTilemap.active_gasdark;
					if (HF.array_contains(gasarray, tm.getTileID(block.x + block.width / 2, block.y + block.height / 2))) {
						destroyed = true;
					}
				}
			}
			
			if (destroyed) {
				destroy_active_block();
			}
		}
		
	}
	
	public function destroy_active_block():Void 
	{
		mode = 2;
		block.animation.play("explode",true);
		R.sound_manager.play(SNDC.lens_attach);
		if (particles == null) {
			particles = new FlxTypedGroup<FlxSprite>();
			HF.add_list_to_mysprite_layer(this, parent_state, [particles]);
			for (i in 0...8) {
				var p:FlxSprite = new FlxSprite();
				p.makeGraphic(1, 1);
				particles.add(p);
			}
		}
		
		particles.exists = true;
		for (i in 0...particles.length) {
			var p:FlxSprite = particles.members[i];
			p.velocity.x = -10 + 20 * Math.random();
			p.velocity.y = -10 + 20 * Math.random();
			p.velocity.x += R.player.velocity.x;
			p.velocity.y += R.player.velocity.y;
			p.velocity.x *= 0.8 + 0.4 * Math.random();
			p.velocity.y *= 0.8 + 0.4 * Math.random();
			p.acceleration.y = 200 + 70 * Math.random();
			p.x = block.x + block.width / 2;
			p.y = block.y + block.height / 2;
			p.alpha = 1;
		}
		
		if (Math.random() > 0.5) {
			bg.velocity.x = -50;
		} else {
			bg.velocity.x = 50;
		}
		bg.velocity.y = -20;
		bg.acceleration.y = 300;
		bg.angularVelocity = 200;
	}
	
	function playanim():Void 
	{
		var ob:Int = behavior;
		behavior = props.get("behavior");
		if (behavior == 0) {
			animation.play("idle_lr");
		} else if (behavior == 1) {
			animation.play("idle_ud");
		} else if (behavior == 2) {
			animation.play("idle_circle");
		} else if (behavior == 3) {
			animation.play("idle_any");
		}
		behavior = ob;
	}
}