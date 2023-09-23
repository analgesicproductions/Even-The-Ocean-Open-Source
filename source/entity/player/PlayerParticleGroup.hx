package entity.player;

import entity.util.FloatWall;
import flash.display.BlendMode;
import global.Registry;
import haxe.Log;
import help.AnimImporter;
import help.FlxX;
import help.HelpTilemap;
import help.HF;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import state.TestState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class PlayerParticleGroup extends FlxGroup
{

	public var bg:FlxGroup;
	private var sand_list:Array<FlxSprite>;
	private var sand_timers:Array<Float>;
	private var sand_tiles:Array<Int>;
	private var has_sand:Bool = false;
	private var R:Registry;
	private var test_state:TestState;
	
	private var bubble_list:Array<FlxSprite>;
	private var active_bubble_list:Array<FlxSprite>;
	private var bubble_timeout:Float = 0;
	
	private var snowprint_list:Array<FlxSprite>;
	private var snowprint_timers:Array<Float>;
	
	private var slimehit_group:FlxGroup;
	
	private var armor_dust_group:FlxGroup;
	
	private var wall_dust_group:FlxGroup;
	private var wall_spark_group:FlxGroup;
	private var t_wall_dust:Float = 0;
	
	public function reload_anims():Void {
		if (wall_dust_group != null) {
		for (i in 0...wall_dust_group.length) {
			var s:FlxSprite = cast wall_dust_group.members[i];
			AnimImporter.addAnimations(s, "WallEffect", "dust");
		}
		for (i in 0...wall_spark_group.length) {
			var s:FlxSprite = cast wall_spark_group.members[i];
			AnimImporter.addAnimations(s, "WallEffect", "spark");
		}
		}
	}
	public function new() 
	{
		bg = new FlxGroup();
		sand_list = new Array<FlxSprite>();
		sand_timers = [];
		
		snowprint_list = new Array<FlxSprite>();
		snowprint_timers = [];
		for (i in 0...10) {
			var sno:FlxSprite = new FlxSprite();
			snowprint_list.push(sno);
			snowprint_timers.push( -1);
			sno.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/snow_prints.png"), true, false, 6, 4);
			for (j in 0...6) {
				sno.animation.add(Std.string(j), [j]);
			}
			//sno.blend = BlendMode.ADD;
			//sno.blend = BlendMode.SCREEN;
			//sno.blend = BlendMode.MULTIPLY;
			sno.alpha = 0;
		}
		
		for (i in 0...10) {
			var s:FlxSprite = new FlxSprite();
			s.makeGraphic(1, 1, 0xffe8e890);
			s.acceleration.y = 300;
			sand_list.push(s);
			sand_timers.push( -1);
		}
		
		active_bubble_list = new Array<FlxSprite>();
		bubble_list = new Array<FlxSprite>();
		for (i in 0...10) {
			var bubble:FlxSprite = new FlxSprite();
			bubble.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/air_bubble.png"), true, false, 4, 4);
			bubble_list.push(bubble);
			bubble.exists = false;
		}
		
		wall_dust_group = new FlxGroup();
		wall_spark_group = new FlxGroup();
		for (i in 0...8) {
			var s:FlxSprite = new FlxSprite();
			s.loadGraphic(Assets.getBitmapData("assets/sprites/player/wall_dust_spark.png"), true, 16, 16);
			AnimImporter.addAnimations(s, "WallEffect", "dust");
			s.ID = 0;
			wall_dust_group.add(s);
		}
		for (i in 0...3) {
			var s:FlxSprite = new FlxSprite();
			s.loadGraphic(Assets.getBitmapData("assets/sprites/player/wall_dust_spark.png"), true, 16, 16);	
			AnimImporter.addAnimations(s, "WallEffect", "spark");
			s.ID = 0;
			wall_spark_group.add(s);
		}
		
		slimehit_group = new FlxGroup();
		for (i in 0...4) {
			var s:FlxSprite = new FlxSprite();
			s.makeGraphic(1, 1, 0xffeeeeff);
			slimehit_group.add(s);
			s.ID = 0;
		}
		
		armor_dust_group = new FlxGroup();
		for (i in 0...7) {
			var s:FlxSprite = new FlxSprite();
			s.loadGraphic(Assets.getBitmapData("assets/sprites/player/wall_dust_spark.png"), true, 16, 16);	
			AnimImporter.addAnimations(s, "WallEffect", "dust");
			armor_dust_group.add(s);
		}
		
		R = Registry.R;
		super();
	}
	
	public function register(sand:Array<Int>):Void {
		//Log.trace(sand);
		// reset sand
		
		// Clearout any existing snow
		for (j in 0...snowprint_list.length) {
			var sno:FlxSprite = snowprint_list[j];
			snowprint_list[j].alpha = 0;
			bg.remove(snowprint_list[j], true);
			snowprint_timers[j] = 0;
		}
	
		
		
		sand_tiles = sand;
		has_sand = true;
		if (sand_tiles.length == 0) {
			has_sand = false;
		}
		do_snowprints = false;
		if (R.TEST_STATE.MAP_NAME.indexOf("BASIN") != -1) {
			do_snowprints = true;
		}
		if (R.TEST_STATE.MAP_NAME.indexOf("WOODS") != -1) {
			has_sand = false;
		}
		if (R.TEST_STATE.MAP_NAME.indexOf("CLIFF_G") != -1) {
			has_sand = false;
		}
		if (R.TEST_STATE.MAP_NAME.indexOf("PASS_G") != -1) {
			has_sand = false;
		}
	}
	
	/**
	 * Takes metadata later
	 */
	public function change_bubble():Void {
		// clera and reset bubbles
		
	}

	private var slime_ctr:Int = 0;
	private var slime_on:Bool = false;
	private var slime_dir_right:Bool = false;
	
	private var slime_active:Bool = false;
	public function hit_slime(left:Bool=true):Void {
		slime_active = true;
		slime_dir_right = !left;
		slime_on = true;
		visible = true;
		slime_ctr++;
		if (slime_ctr == 1) {
			
		} else {
			if (slime_ctr == 7) {
				slime_ctr = 0;
			}
			return;
		}
		for (i in 0...slimehit_group.length) {
			var s:FlxSprite = cast slimehit_group.members[i];
			//Log.trace([s.ID, i]);
			if (s.ID == 0) {
				//Log.trace(i);
				add(s);
				s.ID = 1;
				s.velocity.x = 30 + 30* Math.random();
				s.velocity.y = -50 - 50 * Math.random();
				s.acceleration.y = 400 + 100 * Math.random();
				s.alpha = 1;
				if (left) {
					s.x = R.player.x + 2;
				} else {
					s.x  = R.player.x + R.player.width - s.width;
				}
				
				s.y = R.player.y + 8;
				if (!left) s.velocity.x *= -1;
				break;
			}
		}
	}
	private var dust_on:Bool = false;
	private var dust_active:Bool = false;
	public function hit_dust(v:Float,specialtype:Int=0):Void {
		dust_active = true;
		dust_on= true;
		visible = true;
		var ct:Int = 1;
		if (Player.armor_on) {
			ct = 2;
		}
		for (i in 0...armor_dust_group.length) {
			var s:FlxSprite = cast armor_dust_group.members[i];
			add(s);
			s.visible = s.exists = true;
			s.velocity.x = -15 + 30* Math.random();
			s.velocity.y = -20 - 15 * Math.random() + ( -1 * Math.abs(v) * 0.15);
			s.acceleration.y = 20 + 10 * Math.random();
			s.alpha = 1;
			s.x  = R.player.x + (R.player.width / 2) - (2 + 12) + 4 * Math.random();
			s.y = R.player.y + R.player.height - 6;
			if (specialtype == 1) {
				s.animation.play("on_ice");
			} else {
				s.animation.play("on");
			}
			
			ct--;
			if (ct == 0) break;
		}
	}
	
	private var sand_timeout:Float = 0;
	private var did_init:Bool = false;
	private var do_snowprints:Bool = false;
	private var snowprint_hi:Bool = false;
	override public function update(elapsed: Float):Void {
		
		if (!did_init) {
			did_init = true;
			test_state = R.TEST_STATE;
		}
		if (dust_active) {
			if (dust_on) {
				var d:FlxSprite = null;
				for (i in 0...armor_dust_group.length) {
					d = cast armor_dust_group.members[i];
					if (d.visible) {
						d.visible = d.exists = true;
						if (d.animation.finished) {
							//dust_on = false;
							d.visible = d.exists = false;
							remove(d, true);
						}
					}
				}
			}
		}
		if (slime_active) {
			
			if (slime_on) {
				if (slime_dir_right) {
					if (!R.input.right || false == HF.array_contains(HelpTilemap.noclimb,R.TEST_STATE.tm_bg.getTileID(R.player.x+R.player.width+1,R.player.y+6))) {
						slime_on = false;
					} else {
						hit_slime(false);
					}
				} else {
					if (!R.input.left|| false == HF.array_contains(HelpTilemap.noclimb,R.TEST_STATE.tm_bg.getTileID(R.player.x-1,R.player.y+6))) {
						slime_on = false;
					} else {
						hit_slime(true);
					}
				}
			}
			
			var s_ct:Int = 0;
			for (i in 0...slimehit_group.length) {
				var s:FlxSprite = cast slimehit_group.members[i];
				if (s.ID == 0) continue;
				s.ID ++;
				if (s.alpha < 0.05) {
					s_ct++;
					continue;
				}
				if (s.ID > 30) {
					s.alpha -= 0.01;
					s.alpha *= 0.96;
					if (s.alpha < 0.05) {
						remove(s);
						s.ID = 0;
					}
				}
			}
			if (s_ct == slimehit_group.length) {
				slime_active = false;
			}
		}
		
		if (has_sand) {
			var tt:Int = R.TEST_STATE.tm_bg.getTileID(R.player.x + R.player.width / 2, R.player.height + R.player.y + 2);
			var tt2:Int = R.TEST_STATE.tm_bg2.getTileID(R.player.x + R.player.width / 2, R.player.height + R.player.y + 2);
			if (sand_timeout <= 0 && (HF.array_contains(sand_tiles, tt) || HF.array_contains(sand_tiles, tt2)) && R.player.is_anim_foot_on_ground()) {
				sand_timeout = 0.09;
				if (do_snowprints) {
					for (j in 0...snowprint_list.length) {
						if (snowprint_timers[j] <= 0 && snowprint_list[j].alpha == 0) {
							snowprint_hi = !snowprint_hi;
							snowprint_timers[j] = 1; // The delay b4 fading
							bg.add(snowprint_list[j]);
							snowprint_list[j].x = R.player.x - 1 + R.player.width / 2;
							snowprint_list[j].y = R.player.y + R.player.height - 3;
							snowprint_list[j].alpha = 1;
							if (snowprint_hi) {
								snowprint_list[j].animation.play(Std.string(Std.int(3 * Math.random()) * 2), true);
							} else {
								snowprint_list[j].animation.play(Std.string(1 + Std.int(3 * Math.random()) * 2), true);
							}
							break;
						}
					}
				} else {
					var nr:Int = 0;
					for (j in 0...sand_list.length) {
						if (sand_timers[j] < 0) {
							sand_timers[j] = 0.5;
							add(sand_list[j]);
							sand_list[j].x = R.player.x + R.player.width / 2;
							sand_list[j].y = R.player.y + R.player.height;
							sand_list[j].velocity.x = R.player.velocity.x * ( -0.6 + 0.8 * Math.random());
							sand_list[j].velocity.y = -50 - 60 * Math.random();
							
							nr++;
							if (nr == 5) break;
						}
					}
				}
			}
			
			if (sand_timeout > 0) sand_timeout -= FlxG.elapsed;
			
			for (j in 0...sand_list.length) {
				if (sand_timers[j] > 0) {
					sand_timers[j] -= FlxG.elapsed;
					if (sand_timers[j] < 0) {
						remove(sand_list[j], true);
					}
				}
			}
			
			for (j in 0...snowprint_list.length) {
				var sno:FlxSprite = snowprint_list[j];
				if (snowprint_timers[j] <= 0  && sno.alpha > 0) {
					sno.alpha -= 0.01;
					if (sno.alpha <= 0) {
						bg.remove(snowprint_list[j], true);
					}
				} else if (snowprint_timers[j] > 0) {
					snowprint_timers[j] -= FlxG.elapsed;
				}
			}
			//bg.visible = true;
			visible = true;
		} else {
			if (!slime_active && !dust_active) {
			visible = false;
			}
				//bg.visible = false;
			bg.visible = true;
		}
		
		if (R.player.is_swimming()) {
			bubble_timeout += FlxG.elapsed;
			if (bubble_timeout > 1.2) {
				bubble_timeout -= 1.2;
				for (i in 0...bubble_list.length) {
					if (bubble_list[i].exists == false) {
						bubble_list[i].ID = 0;
						add(bubble_list[i]);
						active_bubble_list.push(bubble_list[i]);
						if (R.player.facing == FlxObject.RIGHT) {
							bubble_list[i].x = R.player.x + 8;
							bubble_list[i].y = R.player.y - 1;
						} else {							
							bubble_list[i].x = R.player.x -4;
							bubble_list[i].y = R.player.y - 1;
						}
						bubble_list[i].velocity.y = -50 + -50 * Math.random();
						bubble_list[i].exists = true;
						break;
					}
				}
			}
		}
		
		// need to do this bc once you've pressed jump you're not in wall mode anymore
		if (wall_spark_group.ID != 0) {
			if (R.input.jpA1) {
				for (i in 0...wall_spark_group.length) {
					var s:FlxSprite = cast wall_spark_group.members[i];
					if (s.ID == 0) {
						s.ID = 1;
						s.animation.play("on");
						// position based on what side wall u were on
						if (wall_spark_group.ID == 1) {
							s.x = R.player.last.x + R.player.width - 4;
						} else {
							s.x = R.player.last.x - 12;
						}
						s.y = R.player.last.y + R.player.height - 8;
						add(s);
						break;
					}
					
				}
			}
		}
		
		if (R.player.is_in_wall_mode() && !FloatWall.playerClimbing) {
			if (R.player.facing == FlxObject.LEFT) {
				wall_spark_group.ID = -1;
			} else {
				wall_spark_group.ID = 1;
			}
			
			if (t_wall_dust <= 0) {
				for (i in 0...wall_dust_group.length) {
					var s:FlxSprite = cast wall_dust_group.members[i];
					if (s.ID == 0) {
						s.ID = 1;
						s.animation.play("on");
						if (R.player.facing == FlxObject.LEFT) {
							s.x = R.player.x - 12 + 4 * Math.random();
						} else {
							s.x = R.player.x + R.player.width - 3 - 4*Math.random();
						}
						s.y = R.player.y + R.player.height - 6;
						if (R.player.velocity.y < 0) {
							s.velocity.y = 20;
						} else {
							s.velocity.y = -25;
						}
						s.velocity.x = -10 + 20 * Math.random();
						add(s);
						t_wall_dust = elapsed * 8;
						break;
					}
				}
			} 
		} else {
			wall_spark_group.ID = 0;
		}
		t_wall_dust -= elapsed;
		if (t_wall_dust <= 0) {
			t_wall_dust = 0;
		}
		FloatWall.playerClimbing = false;
		
		// walking in armor
		if (Player.armor_on && R.player.wasTouching &  FlxObject.DOWN > 0) {
			if (R.player.velocity.x != 0) {
				if (t_wall_dust <= 0) {
					for (i in 0...wall_dust_group.length) {
						var s:FlxSprite = cast wall_dust_group.members[i];
						if (s.ID == 0) {
							s.ID = 1;
							s.animation.play("on");
							s.velocity.y = -15 - 20 * Math.random();
							if (R.player.velocity.x > 0) {
								s.x = R.player.x-3;
								s.velocity.x = -10 - 10 * Math.random();
							} else {
								s.x = R.player.x + 3;
								s.velocity.x = 10 + 10* Math.random();
							}
							s.y = R.player.y + R.player.height - 8;
							add(s);
							t_wall_dust = elapsed * 10;
							break;
						}
					}
				}
			}
		}
		
		// detect hit ceiling
		if (R.player.wasTouching == FlxObject.UP && !R.player.is_swimming()) {
			if (t_wall_dust <= 0) {
				for (i in 0...wall_dust_group.length) {
					var s:FlxSprite = cast wall_dust_group.members[i];
					if (s.ID == 0) {
						s.ID = 1;
						s.animation.play("on");
						s.velocity.y = 35;
						s.velocity.x = -10 + 20 * Math.random();
						s.x = R.player.x - 4;
						s.y = R.player.y - 13;
						add(s);
						t_wall_dust = elapsed * 8;
						break;
					}
				}
			}
		}
		
		for (i in 0...wall_dust_group.length) {
			var s:FlxSprite = cast wall_dust_group.members[i];
			if (s.ID == 1) {
				if (s.animation.finished) {
					s.ID = 0;
					remove(s, true);
				}
			}
		}
		for (i in 0...wall_spark_group.length) {
			var s:FlxSprite = cast wall_spark_group.members[i];
			if (s.ID == 1) {
				if (s.animation.finished) {
					s.ID = 0;
					remove(s, true);
				}
			}
		}
		
		
		for (i in 0...active_bubble_list.length) {
			active_bubble_list[i].ID += 5;
			if (active_bubble_list[i].ID >= 360) active_bubble_list[i].ID = 0;
			active_bubble_list[i].x += FlxX.sin_table[active_bubble_list[i].ID] * 0.2;
			
			var bx:Float = active_bubble_list[i].x + 1;
			var by:Float = active_bubble_list[i].y + 1;
			var tt:Int = test_state.tm_bg.getTileID(bx, by);
			var tt2:Int = test_state.tm_bg2.getTileID(bx, by);
			
			var b:Bool = FlxObject.ANY == test_state.tm_bg.getTileCollisionFlags(bx, by);
			var c:Bool = (by % 16 < 8) && (HF.array_contains(HelpTilemap.active_surface_water, tt) || HF.array_contains(HelpTilemap.active_surface_water, tt2));
			if (b || c) {
				remove(active_bubble_list[i], true);
				active_bubble_list[i].exists = false;
			}
		}
		
		var bublen:Int = active_bubble_list.length;
		var iter_bub:Int = 0;
		for (i in 0...bublen) {
			if (active_bubble_list[iter_bub].exists == false) {
				active_bubble_list.splice(iter_bub, 1);
				iter_bub--;
			}
			iter_bub++;
		}
		
		
		
		super.update(elapsed);
	}
}