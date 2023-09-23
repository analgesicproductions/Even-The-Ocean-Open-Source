package entity.player;
import autom.SNDC;
import entity.MySprite; 
import entity.tool.Door;
import flash.geom.Point;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import global.EF;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HF;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxObject;
import openfl.display.BitmapData;
import state.MyState;
import state.TestState;
/**
 * ...
 * @author Melos Han-Tani
 */

class WorldMapPlayer extends MySprite
{

	public var ts:TestState;
	
	private var mode:Int;
	private var mode_in_train:Int = 1;
	private var mode_normal:Int = 0;
	
	private var start_transition_into_train:Bool = false;
	private var start_transition_out_of_train:Bool = false;
	
	private var is_paused:Bool = false; 
	
	public var equipped_map_id:Int = -1;
	public var equipped_map:FlxSprite;
	public var search_bar:FlxSprite;
	public var search_msp:String = "";
	public var npc_interaction_bubble:FlxSprite;
	
	public var checkmarks:FlxTypedGroup<FlxSprite>;
	
	
	public function new(_x:Float,_y:Float,_parent:MyState)
	{
		super(_x, _y, _parent, "WorldMapPlayer");
		myLoadGraphic(Assets.getBitmapData("assets/sprites/player/map_even.png"), true, false, 16, 16);
		animation.add("walk_u", [4,5], 6);
		animation.add("walk_d", [0,1], 6);
		animation.add("walk_r", [2,3], 6);
		animation.add("walk_l", [6,7], 6);
		animation.add("idle_u", [4], 2);
		animation.add("idle_r", [2], 2);
		animation.add("idle_d", [0], 2);
		animation.add("idle_l", [6], 2);
		animation.play("idle_d");
		checkmarks = new FlxTypedGroup<FlxSprite>();
		for (i in 0...3) {
			var c:FlxSprite = new FlxSprite();
			c.myLoadGraphic(Assets.getBitmapData("assets/sprites/ui/map/check.png"), true, false, 16, 16);
			c.visible = false;
			c.scrollFactor.set(0, 0);
			checkmarks.add(c);
		}
		facing = FlxObject.DOWN;
		wm = 1;
		width = height = 8;
		offset.x = 4;
		offset.y = 8;
		// Offset more bc of distortion
		offset.y += 3;
		
		equipped_map = new FlxSprite();
		equipped_map.alpha = 0;
		equipped_map.ID = 0; 
		equipped_map.scrollFactor.set(0, 0);
		
		search_bar = new FlxSprite();
		search_bar.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/search.png"), true, false, 16, 16);
		search_bar.animation.add("idle", [0], 1);
		search_bar.animation.add("dark", [1], 1);
		search_bar.animation.add("light", [2], 1);
		search_bar.animation.play("idle");
		search_bar.alpha = 0;
		
		ts = cast(_parent, TestState);
		
	
		npc_interaction_bubble = new FlxSprite();
		AnimImporter.loadGraphic_from_data_with_id(npc_interaction_bubble, 16, 16, "npcbubble");
		npc_interaction_bubble.visible = false;
	}
	
	public function set_sprites_exists(e:Bool):Void {
		search_bar.exists = e;
		equipped_map.exists = e;
		if (e == false) {
			search_bar.ID = -1;
			search_bar.alpha = 0;
			checkmarks.members[0].alpha = 0;
			checkmarks.members[1].alpha = 0;
			checkmarks.members[2].alpha = 0;
		}
	}
	
	override public function preUpdate():Void 
	{
		
		FlxObject.separate(this, parent_state.tm_bg);
		FlxObject.separate(this, parent_state.tm_bg2);
		super.preUpdate();
	}
	
	private var dialogueon:Bool = false;
	/**
	 * Must be over 60 before you can search. bc of weird transitionb ug
	 */
	public var enternobartimer:Int = 0; 
	public var searching:Bool = false;
	private var pressinteract_fctr:Int = 0;
	
	override public function update(elapsed: Float):Void 
	{
		
		
		
		if (R.activePlayer == R.worldmapplayer) {
			var lp:Float = R.player.energy_bar.get_LIGHT_percentage();
			if (lp <= 0.26) {
				R.player.energy_bar.set_energy(70);
				R.player.energy_bar.status = 0;
				R.player.energy_bar.player_shade_timer = 0;
				R.player.energy_bar.death_fade.alpha = 0;
			} else if (lp >= 0.74) {
				R.player.energy_bar.set_energy(186);
				R.player.energy_bar.status = 0;
				R.player.energy_bar.player_shade_timer = 0;
				R.player.energy_bar.death_fade.alpha = 0;
			}
		}
		
		if (search_bar.ID == 2) {
			search_bar.alpha -= 0.09; 
			// enering hidden door
		}
		
		if (search_bar.ID == 3) {
			search_bar.alpha -= 0.01;
			if (search_bar.alpha <= 0.9) {
				search_bar.alpha -= 0.04;
				if (search_bar.alpha <= 0) {
					search_bar.ID = -1;
				}
			}
		}
		
		if (is_paused) {
			if (R.input.jpUp) {
				facing = FlxObject.UP;
			} else if (R.input.jpDown) {
				facing = FlxObject.DOWN;
			} else if (R.input.jpRight) {
				facing = FlxObject.RIGHT;
			} else if (R.input.jpLeft) {
				facing = FlxObject.LEFT;
			}
			return;
		}
	
		super.update(elapsed);
		
		if (parent_state.dialogue_box.is_active()) {
			return;
		}
		if (dialogueon) {
			enternobartimer = 60;
			dialogueon = false;
			if (R.input.up) {
				facing = FlxObject.UP;
			} else if (R.input.down) {
				facing = FlxObject.DOWN;
			} else if (R.input.right) {
				facing = FlxObject.RIGHT;
			} else if (R.input.left) {
				facing = FlxObject.LEFT;
			}
		}
		
		// If you press a2 before unholding all dirs, still give 10 frames for this to be okay
		if (pressinteract_fctr > 0) pressinteract_fctr--;
		if (R.input.jpA2) pressinteract_fctr = 10;
		
		
		if (enternobartimer < 60) enternobartimer++;
		
		if (search_bar.ID == -1 && ((R.input.a2 && pressinteract_fctr > 0)|| R.input.jpA2 ) && !R.input.any_dir_down() && enternobartimer >= 60) {
			search_bar.ID = 0;
			searching = true;
		} else if (searching && R.input.a2) {
			if (Door.overlapping_open_door) {
				// Ignore
				return;
			} else {
				if (search_bar.ID == 0) {
							search_bar.animation.play("idle");
				
					search_bar.x = this.x + this.width / 2 - (search_bar.width / 2);
					search_bar.y = this.y - search_bar.height - 9;
					velocity.set(0, 0);
					if (facing == FlxObject.RIGHT) {
						animation.play("idle_r");
					} else if (facing == FlxObject.LEFT) {
						animation.play("idle_l");
					} else if (facing == FlxObject.UP) {
						animation.play("idle_u");
					} else {
						animation.play("idle_d");
					}
					search_bar.ID = 1;
					search_msp = "";
					// play sound
				} else if (search_bar.ID == 1) {
					// play sounds for growing
					search_bar.alpha += 0.04;
					if (search_bar.alpha >= 1) {
						if (Door.overlapping_hidden_worldmap_door) {
							Door.signal_to_enter_hidden_worldmap_door = true;
							search_bar.ID = 2;
							search_bar.animation.play("light");
						} else {
							if (search_msp != null && search_msp != "" && search_msp.length > 5) {
								parent_state.dialogue_box.start_dialogue(search_msp.split(",")[0], search_msp.split(",")[1], Std.parseInt(search_msp.split(",")[2]));
								dialogueon = true;
								search_bar.animation.play("light");
								R.sound_manager.play(SNDC.clam_1);
							} else {
								R.sound_manager.play(SNDC.edgedoor_close);
								search_bar.animation.play("dark");
								//parent_state.dialogue_box.start_dialogue("ui", "look_for_map", 0);
							}
							search_bar.ID = 3;
						}
					}
					Door.overlapping_hidden_worldmap_door = false;
				} else if (search_bar.ID == 2) {
					search_bar.alpha -= 0.05; 
					// enering hidden door
				}
			}
			return;
		} else {
			searching = false;
			if (search_bar.ID >= 0) {
				search_bar.ID = -1;
			}
			if (search_bar.alpha > 0) {
				search_bar.alpha -= 0.04;
			}
			if (search_bar.ID == 2 && search_bar.alpha <= 0) {
				search_bar.ID = -1;
			}
		}
		
		
		// Jump / MAP key
		if (R.input.a1 && velocity.x == 0 && velocity.y == 0 && R.gs1 != 245) {
			if (equipped_map_id == 48) {
				if (R.input.jpA1) {
					parent_state.dialogue_box.start_dialogue("ui","map_equip",2);
					dialogueon = true;
					equipped_map.ID = 0;
					velocity.set(0, 0);
				}
			} else if (equipped_map_id != -1) {
				if (equipped_map.ID == 0) {
					
					var a:Array<Dynamic> = R.inventory.get_item_pic_info(equipped_map_id);
					var bm:BitmapData = Assets.getBitmapData(a[0]);
					// hardcode 19-21
					if (equipped_map_id >= 19 && equipped_map_id<= 21) {
						if (equipped_map_id == 19) {
							bm = R.get_silo_bitmap_in_menu(19);
						} else if (equipped_map_id == 20) {
							bm = R.get_silo_bitmap_in_menu(20);
						} else {
							bm = R.get_silo_bitmap_in_menu(21);
						}
					}
					equipped_map.myLoadGraphic(bm,true, false,Std.int(a[1]),Std.int(a[2]));
					equipped_map.x = (FlxG.width - equipped_map.width) / 2;
					equipped_map.y = (FlxG.height - equipped_map.height) / 2;
					equipped_map.alpha = 0;
					
					equipped_map.ID = 1;
					velocity.set(0, 0);
					
					for (i in 0...3) {
						checkmarks.members[i].visible = false;
					}
					
					if (equipped_map_id == 18) {
						if (R.event_state[EF.shore_done] == 1) { checkmarks.members[0].visible = true; checkmarks.members[0].move(241, 40);  }
						if (R.event_state[EF.canyon_done] == 1) { checkmarks.members[1].visible = true; checkmarks.members[1].move(188, 146);  }
						if (R.event_state[EF.hill_done] == 1) { checkmarks.members[2].visible = true; checkmarks.members[2].move(182, 47);  }
					} else if (equipped_map_id == 50) {
						if (R.event_state[EF.river_done] == 1) { checkmarks.members[0].visible = true; checkmarks.members[0].move(153, 94);  }
						if (R.event_state[EF.woods_done] == 1) { checkmarks.members[1].visible = true; checkmarks.members[1].move(169, 134);  }
						if (R.event_state[EF.forest_done] == 1) { checkmarks.members[2].visible = true; checkmarks.members[2].move(217, 179);  }
					}
					
				} else if (equipped_map.ID == 1) {
					equipped_map.alpha += 0.04;
					checkmarks.setAll("alpha", equipped_map.alpha);
				}
				return;
			} else {
				// continue
			}
		} else if (equipped_map_id != -1) {
			if (equipped_map.ID == 1) {
				equipped_map.ID = 0;
			}
			equipped_map.alpha -= 0.04;
			checkmarks.setAll("alpha", equipped_map.alpha);
		}
		
			if (R.input.jpUp) {
				facing = FlxObject.UP;
			} else if (R.input.jpDown) {
				facing = FlxObject.DOWN;
			} else if (R.input.jpRight) {
				facing = FlxObject.RIGHT;
			} else if (R.input.jpLeft) {
				facing = FlxObject.LEFT;
			}
			if (R.input.up) {
				if (facing == FlxObject.UP || (!R.input.right && !R.input.left)) {
					animation.play("walk_u");
					if (!R.input.right && !R.input.left) {
						facing = FlxObject.UP;
					}
				}
				velocity.y = -y_vel;
			} else if (R.input.down) {
				if (facing == FlxObject.DOWN || facing == FlxObject.UP|| (!R.input.left && !R.input.right)) {
					animation.play("walk_d");
					facing = FlxObject.DOWN;
				}
				velocity.y = y_vel;
			}
			if (R.input.right) {
				if (facing == FlxObject.RIGHT|| (!R.input.down && !R.input.up)) {
					animation.play("walk_r");
					if (!R.input.down && !R.input.up) {
						facing = FlxObject.RIGHT;
					}
				}
				velocity.x = x_vel;
			} else if (R.input.left) {
				if (facing == FlxObject.LEFT || facing == FlxObject.RIGHT || (!R.input.down && !R.input.up)) {
					facing = FlxObject.LEFT;
					animation.play("walk_l");
				}
				velocity.x = -x_vel;
			}
			
			if (velocity.x != 0 && velocity.y != 0) {
				velocity.x *= 0.717;
				velocity.y *= 0.717;
			}
			
			if (!R.input.left && !R.input.right && !R.input.down && !R.input.up) {
				if (facing == FlxObject.UP) {
					animation.play("idle_u");
				} else if (facing == FlxObject.RIGHT) {
					animation.play("idle_r");
				} else if (facing == FlxObject.DOWN) {
					animation.play("idle_d");
				} else if (facing == FlxObject.LEFT) {
					animation.play("idle_l");
				}
			}
			
			if (!R.input.right && !R.input.left) {
				velocity.x = 0;
			}
			if (!R.input.down && !R.input.up) {
				velocity.y = 0;
			}
		
	}
	
	private var wm:Int = 0;
	public function FORCE_TO_GIVE_CONTROL_TO_TRAIN():Void {
		mode = mode_in_train;
		alpha = 0;
		velocity.x = velocity.y = 0;
		ts.set_default_camera("train");
		ts.train.stop_being_inactive();
	}
	/**
	 * Called from teststate to return its state to that of before entering any world map.
	 * Often for when entering an even world map mucks stuff up
	 */
	public function set_to_normal():Void {
		mode = mode_normal;
		alpha = 1;
	}
	
	
	public function idleanim():Void {
		
					if (facing == FlxObject.RIGHT) {
						animation.play("idle_r");
					} else if (facing == FlxObject.LEFT) {
						animation.play("idle_l");
					} else if (facing == FlxObject.UP) {
						animation.play("idle_u");
					} else {
						animation.play("idle_d");
					}
	}
	private function update_mode_in_train():Void {
		if (ts.train.is_even_map()) {
			last.x = x = ts.train.x;
			last.y = y = ts.train.y;
			return;
		}
		
		if (start_transition_out_of_train) {
			alpha += 0.01;
			if (alpha == 1) {
				start_transition_out_of_train = false;
				mode = mode_normal;
				ts.set_default_camera();
				FlxG.camera.followLerp = 60;
			}
		}
	}
	
	public function pause_toggle(on:Bool):Void {
		//Log.trace("TOGGLE "+Std.string(on));
		if (on) {
			velocity.x = velocity.y = 0;
			is_paused = true;
			animation.paused = true;
		} else {
			search_bar.ID = -1;
			animation.paused= false;
			is_paused = false;
			enternobartimer = 0;
		}
	}
	
	override public function getDefaultProps():Map<String, Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("y_vel",y_vel);
		p.set("x_vel",x_vel);
		return p;
	}
	
	private var y_vel:Float = 95;
	private var x_vel:Float = 100;
	override public function set_properties(p:Map<String, Dynamic>):Void 
	{
		HF.copy_props(p, props);
		y_vel = p.get("y_vel");
		x_vel = p.get("x_vel");
	}
	
	
	private var npc_interaction_off:Bool = false;
	public function activate_npc_bubble(anim:String):Void {
		//Log.trace(CallStack.callStack()[1]);
		if (npc_interaction_bubble.animation.name != anim) {
			npc_interaction_bubble.animation.play(anim);
		}
		//if (anim.indexOf("disappear") != -1) {
			//npc_interaction_off = false;
		//} else {
			//npc_interaction_off = false;
		//}
		npc_interaction_bubble.visible = true;
	}
	
	public function c(x:Float, y:Float):Int {
		return parent_state.tm_bg.getTileCollisionFlags(x, y);
	}
	
	override public function postUpdate(elapsed:Float):Void 
	{
		if (is_paused) return;
		
		
		var onlyLeft:Bool = R.input.left && !R.input.right && !R.input.down && !R.input.up;
		var onlyRight:Bool = !R.input.left && R.input.right && !R.input.down && !R.input.up;
		var DL:Int = FlxObject.LEFT | FlxObject.DOWN;
		var DR:Int = FlxObject.RIGHT | FlxObject.DOWN;
		var UL:Int = FlxX.SLOPE_LEFT | FlxObject.UP;
		var UR:Int = FlxX.SLOPE_RIGHT | FlxObject.UP;
		
		// Correct the speed walking striaght left or right into slopes
		if (onlyLeft && (touching == UR || touching == DL)) {
			velocity.x *= 0.717;
		}
		if (onlyRight && (touching == UL || touching == DR)) {
			velocity.x *= 0.717;
			y -= 1; last.y -= 1; // do this so you are far enough to not walk into a consecutive slope and phase..
		}
		
		// Walking up or down into slopes = pushing along that dir
		var theresDL:Bool = false;
		var theresDR:Bool = false;
		if (c(x + width + 2, y - 2) == FlxObject.UP | FlxObject.RIGHT) {
			theresDL = true;
		}
		if (c(x -2, y - 2) == FlxObject.UP | FlxObject.LEFT) {
			theresDR = true;
		}
		
		// If walking up, and there's a slope tile to your upper-right, move like so.
		if (R.input.up && (theresDL || (touching & FlxX.SLOPE_LEFT > 0 && touching & FlxObject.UP > 0))) {
			if (R.input.right) {
				velocity.x *= -1;
			} else {
				velocity.x = -0.717 * x_vel;
			}
		} else if (R.input.up && (theresDR || (touching & FlxX.SLOPE_RIGHT > 0 && touching & FlxObject.UP > 0))) {
			if (R.input.left) {
				velocity.x *= -1;
			} else {
				velocity.x = 0.717 * x_vel;
			}
		} 
		
		if (velocity.y < 0) {
			// Sometimes if you're going to run into a hard tile, manually nudg playe
			// top right in solid, top left in non-solid, bottom-right in sw slope
			if (c(x + width+2, y - 2) == FlxObject.ANY && c(x, y - 2) != FlxObject.ANY && c(x+width+2,y+height) == (FlxObject.RIGHT | FlxObject.CEILING)) {
				x -= 1;
				last.x = x;
				velocity.x = -10;
			}
			if (c(x -2, y - 2) == FlxObject.ANY && c(x+width, y - 2) != FlxObject.ANY && c(x-2,y+height) == (FlxObject.LEFT | FlxObject.CEILING)) {
				x += 1;
				last.x = x;
				velocity.x = 10;
			}
		}
		
		// same garbage as above for floro tiles
		var theresUL:Bool = false;
		var theresUR:Bool = false;
		
		// this code doesnt actually run but it doesnt seem to matter
		if (c(x + width + 2, y - 2) == FlxObject.DOWN | FlxObject.RIGHT) {
			theresUL = true;
		}
		if (c(x -2, y - 2) == FlxObject.DOWN| FlxObject.LEFT) {
			theresUR = true;
		}
		// end code that doesnt run
		
		
		if (R.input.down && (theresUL || (touching == DR && touching_floor_slope))) {
			if (R.input.right) {
				velocity.x *= -1;
			} else {
				velocity.x = -0.717 * x_vel;
			}
		} else if (R.input.down && (theresUR || (touching == DL && touching_floor_slope))) {
			if (R.input.left) {
				velocity.x *= -1;
			} else {
				velocity.x = 0.717 * x_vel;
			}
		} 
		
		
		if (velocity.y > 0) {
			// moving down, down-right corenr in solid, down-left corner in nothing
			if (c(x + width+2, y +height+2) == FlxObject.ANY && c(x, y+height+2) != FlxObject.ANY && c(x+width+2,y) == FlxX.SLOPE_LEFT && c(x+width+2,y+height) != FlxObject.ANY ) {
				x -= 1;
				last.x = x;
				velocity.x = -10;
			}
			// moving down, down-left in solid, down-right in nothing
			// for some reasons, floor sloeps have collision values of SLOPE_LEFT regardless of being right/left.
			if (c(x -2, y +height+2) == FlxObject.ANY && c(x+width, y +height+2) == FlxX.SLOPE_LEFT && c(x-2,y) == FlxX.SLOPE_LEFT) {
				x += 1;
				last.x = x;
				velocity.x = 10;
			}
		}
		
		// remove weird ass shaking by checking tiles in a corner shape
		if (c(x + width + 2, y) > 0 && c(x + width + 2, y + height + 2) == 0x1111 && c(x,y+height+2) == 0x1111 && R.input.right && R.input.down) {
			velocity.set(0, 0);
		}
		if (c(x -2, y) > 0 && c(x -2, y + height + 2) == 0x1111 && c(x+width,y+height+2) == 0x1111 && R.input.left && R.input.down) {
			velocity.set(0, 0);
		}
		if (c(x + width + 2, y+height) > 0 && c(x + width + 2, y - 2) == 0x1111 && c(x,y-2) == 0x1111 && R.input.right && R.input.up) {
			velocity.set(0, 0);
		}
		if (c(x -  2, y+height) > 0 && c(x - 2, y - 2) == 0x1111 && c(x+width,y-2) == 0x1111 && R.input.left && R.input.up) {
			velocity.set(0, 0);
		}
		
		if (R.access_opts[12]) {
			velocity.x *= 3;
			velocity.y *= 3;
		}
		
		var wt:Int = touching;
		super.postUpdate(elapsed);
		
		// Ignore the y-calculation if you're walking DL into a floor, so if you walk onto a slope you don't 'phase' through it.
		if (R.input.down && 0x1111 == c(x+width/2,y+height+1)) {
			y = last.y;
			velocity.set(0, 0);
		}
		if (R.input.up && 0x1111 == c(x+width/2,y-1)) {
			y = last.y;
			velocity.set(0, 0);
		}
		if (R.input.right && (0x1111 == c(x+width,y+height) || 0x1111 == c(x+width,y)) && 0 == c(x+width-2,y+height) && 0 == c(x+width-2,y)) {
			x = last.x;
			velocity.x = 0;
		}
		if (R.input.left && (0x1111 == c(x, y + height) || 0x1111 == c(x, y )) && 0 == c(x+2,y+height) && 0 == c(x+2,y)) {
			x = last.x;
			velocity.x = 0;
		}
		
		
		npc_interaction_bubble.x = x - 4;
		npc_interaction_bubble.y = Math.floor(y) - 26;
		
	}
	
}