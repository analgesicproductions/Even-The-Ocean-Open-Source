package entity.tool;
import autom.SNDC;
import entity.MySprite;
import entity.player.Player;
import entity.util.Checkpoint;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import global.C;
import global.EF;
import global.Registry;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import help.JankSave;
import help.SaveModule;
import openfl.Assets;
import flash.display.BlendMode;
import flixel.FlxG;
import state.MyState;
/**
 * ...
 * @author Melos Han-Tani
 */

class SavePoint extends MySprite
{

	private var activated_anim_done:Bool = false;
	private var autosaves:Bool = false;
	private var particles:FlxTypedGroup<FlxSprite>;
	private var is_active_checkpoint:Bool = false;
	private var just_loaded:Bool = false; // not used 2015 11 20
	private var topPart:FlxSprite;
	public function new(_x:Int,_y:Int,_parent:MyState)
	{
		particles = new FlxTypedGroup<FlxSprite>();
		super(_x, _y,  _parent,  "SavePoint");
		
		topPart = new FlxSprite();
		AnimImporter.loadGraphic_from_data_with_id(this, 64, 64,"SavePoint");
		AnimImporter.loadGraphic_from_data_with_id(topPart, 64, 64, "SavePoint");
		//myLoadGraphic(Assets.getBitmapData("assets/sprites/tools/fire.png"), true, false, 48, 48);
		
		R = Registry.R;
		animation.play("bottom_idle");
		topPart.animation.play("top_idle");
		//topPart.alpha = 0.5;
		width = 10;
		offset.x = 32-5;
		topPart.width = 10;
		topPart.offset.x = 32 - 5;
		offset.y = topPart.offset.y = 32;
		height = 16;
		
		savingText= HF.init_bitmap_font();
		savingText.double_draw = true;
		
	}
	
	override public function destroy():Void 
	{
		overlapping_savept = false;
		//HF.remove_list_from_mysprite_layer(this, parent_state, [topPart,particles],4);
		HF.remove_list_from_mysprite_layer(this, parent_state, [topPart,savingText],4);
		super.destroy();
	}
	private var did_autosave:Bool = false;
	
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		//p.set("autosaves",0);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		autosaves = true;
		particle_mode = 0;
		//particles.clear();
		for (i in 0...8) {
			//var p:FlxSprite = new FlxSprite();
			//p.makeGraphic(1, 1, 0xffffffff);
			//particles.add(p);
			//p.alpha = 0;
			//p.exists = false;
		}
	}
	
	
	private var in_saving:Bool = false;
	private var in_choosing:Bool = false;
	private var overlapping_accepter:Bool = false;
	public static var overlapping_savept:Bool = false;
	
	private var alive_ticks:Int = 0;
	private var playedanim:Bool = false;
	
	private var fadezone:FlxSprite;
	private var savingText:FlxBitmapText;
	private var savingString:String = "";
	private var savingCtr:Int = 0;
	private var t_save:Int = 0;
	
	override public function update(elapsed: Float):Void 
	
	{
		
		if (savingCtr == 0) {
			// activate when saving by runningon, which turns ID to -2
			if (playedanim && savingText.ID == -2) {
				savingText.ID = 0;
				savingCtr = 1;
				savingText.text = R.dialogue_manager.lookup_sentence("intro", "save_point", 3, true, true);
				savingString = savingText.text;
				savingText.text += "...";
				t_save = 0;
				savingText.exists = true;
				savingText.alpha = 0;
				savingText.scrollFactor.set(0, 0);
				savingText.y = (y - 8) - FlxG.camera.scroll.y - offset.y;
				savingText.x = C.GAME_WIDTH / 2 - savingText.width / 2;
				savingText.text = savingString;
				
			}
		} else if (savingCtr == 1) {
		
			savingText.alpha += 0.025;
			if (savingText.alpha >= 1) {
				savingCtr = 2;
				savingText.ID = 0;
			}
		} else if (savingCtr == 2) {
			savingText.ID++;
			if (savingText.ID >= 40) {
				savingText.alpha -= 0.025;
				if (savingText.alpha <= 0) {
					if (!playedanim) {
						savingCtr = 0;
						savingText.exists = false;
					}
				}
			}
		}
		
		if (savingCtr > 0) {
			t_save ++;
			var fps:Int = 10;
			if (t_save == fps * 1) {
				savingText.text = savingString + ".  ";
			} else if (t_save == fps * 2) {
				savingText.text = savingString + ".. ";
			} else if (t_save == fps * 3) {
				savingText.text = savingString + "...";
			} else if (t_save == fps * 4) {
				savingText.text = savingString + " ..";
			} else if (t_save == fps * 5) {
				savingText.text = savingString + "  .";
			} else if (t_save == fps * 6) {
				savingText.text = savingString + "  ";
				t_save = 0;
			}
		}
			
			
		
		//R.song_helper.base_song_volume -= 0.03;
		//R.song_helper.set_volume_modifier(R.song_helper.get_volume_modifier());
		
		alive_ticks ++;
		if (alive_ticks > 20) alive_ticks = 20;
		
		if (playedanim && animation.finished) {
			playedanim = false;
			animation.play("bottom_idle");
			topPart.animation.play("top_idle");
		}
		topPart.move(x, y);
		
		if (!did_init) {
			did_init = true;
			if (is_active_checkpoint) {
				activegeid = geid;
			}
			
		if (alive_ticks == 1 && R.player.overlaps(this)) {
			is_active_checkpoint = true;
			//animation.play("bottom_anim");
			//topPart.animation.play("top_anim");
			
			//playedanim = true;
			activated_anim_done = true;
			stepped_on = true;
		}
			
			//HF.add_list_to_mysprite_layer(this, parent_state, [topPart,particles],4);
			HF.add_list_to_mysprite_layer(this, parent_state, [topPart,savingText],4);
		}
		x = ix + 3;
		//if (R.PAX_PRIME_DEMO_ON) {
			//if (did_autosave == false && R.player.overlaps(this)) {
				//did_autosave = true;
				//R.savepoint_mapName = parent_state.MAP_NAME;
				//R.savepoint_X = ix;
				//R.savepoint_Y = iy;
				//HF.save_map_entities(R.TEST_STATE.MAP_NAME, R.TEST_STATE,true);
				//JankSave.save(0);
			//}
		//}
		
		if (R.player.overlaps(this) && !R.player.is_jump_state_air()) {
			R.player.y = R.player.last.y = y + 16 - 2 - R.player.height;
			R.player.velocity.y = 0;
			R.player.touching |= 0x1000;
		}
		
		if (in_saving) {
			if (R.save_module.is_idle()) {
				in_saving = false;
				overlapping_savept = false;
				parent_state.remove(R.save_module);
				//R.player.pause_toggle(false);
				ID = 100;
				R.toggle_players_pause(false);
				if (R.save_module.just_saved) {
					activegeid = geid;
					is_active_checkpoint = true;
					Checkpoint.tempmap = ""; Checkpoint.tempx = 0; // Turn off chkpts
					playedanim = true; // keep this 
					
							animation.play("bottom_anim");
							topPart.animation.play("top_anim");
					save_vals();
				}
			}
			super.update(elapsed);
			return;
		} else if (in_choosing) {
			
			// waiting for the logic of da box
			if (parent_state.decision_box.exists == false) {
				switch (parent_state.decision_box.get_response_index()) {
					case 0:
						parent_state.add(R.save_module);
						R.save_module.activate(SaveModule.MODE_SAVE, R.player.x,R.player.y);
						R.save_module.timeout = 5;
						in_saving = true;
					case 2:
						R.toggle_players_pause(false);
					case 1:
						R.toggle_players_pause(false);
					case -1:
						R.toggle_players_pause(false);
						
				}
				in_choosing = false;
				overlapping_savept = false;
			}
			super.update(elapsed);
			return;
		}
			
		if (parent_state.dialogue_box.is_active()) {
			
			super.update(elapsed);
			return;
		}
		
		//Log.trace([stepped_on, overlapping_accepter, overlapping_savept, is_active_checkpoint]);
		
		if (!overlapping_savept && R.player.overlaps(this)) {
			overlapping_accepter = true;
			overlapping_savept = true;
		} else if (overlapping_accepter) {
			if (!R.player.overlaps(this)) {
				overlapping_accepter = false;
				overlapping_savept = false;
			} else {
				//fix
				if (R.activePlayer == R.player) {
					if (R.player.is_dying()) {
						return;
					}
				}
				if (!R.PAX_PRIME_DEMO_ON && !R.editor.editor_active) {
					if (R.input.jpPause && R.TEST_STATE.pause_menu.is_idle() == true && !R.input.left && !R.input.right && !R.input.down && !R.input.up) {
						R.save_module.timeout = 10;
						R.toggle_players_pause(true);
						R.sound_manager.play(SNDC.menu_open);
						parent_state.add(R.save_module);
						R.save_module.activate(SaveModule.MODE_SAVE,R.player.x,R.player.y);
						in_saving = true;
						
						/* Save recent */
					// Only save if touching, game is in play mode, or game in change mode and fading  IN to an area
					} else if (R.player.touching != 0 && (R.TEST_STATE.mode == 0 || (R.TEST_STATE.mode == 1 && R.TEST_STATE.mode_change_ctr == 2)) && (R.input.jpCONFIRM || (autosaves  && !R.speed_opts[3] && is_active_checkpoint == false))) {
					
						if (!R.speed_opts[3]) stepped_on = true;
						
						
						// particles effect
						R.save_module.caller_x = Std.int(R.player.x);
						R.save_module.caller_y = Std.int(R.player.y);
						R.save_module.save_external();
						is_active_checkpoint = true;
						Checkpoint.tempmap = ""; Checkpoint.tempx = 0; // Turn off chkpts
						activated_anim_done = true;
						save_vals();
						activegeid = geid;
						if (alive_ticks == 20) {
							if (!playedanim) {
							R.sound_manager.play(SNDC.savesound);
							animation.play("bottom_anim");
							topPart.animation.play("top_anim");
							R.player.skip_motion_ticks = 3;
							playedanim = true;
							savingText.ID = -2;
							}
						}
						//particle_mode = 1;
						//for (i in 0...particles.length) {
							//if (i % 2 == 0) {
								//particles.members[i].makeGraphic(1, 1, 0xffffbbff);
							//} else {
								//particles.members[i].makeGraphic(1, 1, 0xffeeffee);
							//}
							//particles.members[i].exists = true;
							//particles.members[i].alpha = 0.6;
							//particles.members[i].velocity.set(-50 + 100 * Math.random(),-40 - 25*Math.random());
							//particles.members[i].acceleration.y = 150;
							//particles.members[i].move(x + width / 2, y + 12);
						//}
					}
				}
			}
			
		} else {
			if (ID == 100) {
				ID = 0;
			}
			
			if (stepped_on) {
				stepped_on = false;
				is_active_checkpoint = false;
			}
			
			if (is_active_checkpoint && geid != activegeid) {
				is_active_checkpoint = false;
				//animation.play("idle");
				animation.play("bottom_idle");
				topPart.animation.play("top_idle");
			}
		}
			
		//if (particle_mode == 1) {
			//for (i in 0...particles.length) {
				//particles.members[i].alpha += 0.03;
				//if (particles.members[i].alpha >= 1) {
					//particle_mode = 2;
				//}
			//}
		//} else if (particle_mode == 2) {
			//for (i in 0...particles.length) {
				//particles.members[i].alpha -= 0.019;
				//if (particles.members[i].alpha <= 0) {
					//particle_mode = 0;
					//particles.members[i].exists = false;
				//}
			//}
		//}
		super.update(elapsed);
	}
	private var particle_mode:Int  = 0;
	private static var activegeid:Int = -1;
	private var stepped_on:Bool = false;
	
	private function save_vals():Void {
		R.savepoint_X = Std.int(x); // quick save for respawn
		R.savepoint_Y = Std.int(y + height - R.player.height);
		R.savepoint_mapName = parent_state.MAP_NAME;
		
	}
	
}