package entity.player;

import autom.SNDC;
import flash.geom.Point;
import global.C;
import global.Registry;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import openfl.display.BlendMode;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class PlayerDeathAnim extends FlxGroup
{

	public var player:FlxSprite;
	public var spot:FlxSprite;
	public var tube:FlxSprite;
	public var particles:FlxTypedGroup<FlxSprite>;
	public var tm_particle:Float = 0.1;
	public var t_particle:Float = 0;
	public var mode:Int = 0;
	public var scrollBG:FlxSprite;
	public var scrollBG2:FlxSprite;
	public var vignette:FlxSprite;
	
	public function new() 
	{
		super();
		player = new FlxSprite();
		spot = new FlxSprite();
		tube = new FlxSprite();
		scrollBG = new FlxSprite();
		scrollBG2 = new FlxSprite();
		particles = new FlxTypedGroup<FlxSprite>();
		add(spot);
		add(scrollBG);
		add(scrollBG2);
		add(particles);
		add(tube);
		add(player);
		vignette = new FlxSprite();
		add(vignette);
		// r or d
		scrollBG.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/darkdeathtexture.png"), false, false, 832, 256);
		// u or u
		scrollBG2.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/darkdeathtexture2.png"), false, false, 832, 256);
		player.myLoadGraphic(Player.player_sprite_bitmap, true, false, 32, 32);
		player.animation.frameIndex = 	280; player.height = 24; player.width = 8;
		player.offset.y = 8;
		player.offset.x = 12;
		spot.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/diedark_spot.png"), true, false, C.GAME_WIDTH, C.GAME_HEIGHT);	
		scrollBG.exists = scrollBG2.exists = spot.exists = particles.exists = tube.exists = player.exists = false;
		tube.scrollFactor.set(0, 0);
		tube.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/diedark_tube.png"), true, false, 416, 64);
		for (i in 0...20) {
			var particle:FlxSprite = new FlxSprite();
			particle.makeGraphic(1, 1, 0xffdf6587);
			particle.exists = false;
			particles.add(particle);
		}
		vignette.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/darkdeathvignette.png"));
		
		AnimImporter.addAnimations(player, "PlayerDeathAnim", "player");
		AnimImporter.addAnimations(tube, "PlayerDeathAnim", "tube");
	}
	
	public var is_light:Bool = false;
	public function init(x:Float, y:Float,is_light:Bool=false):Void {
		player.x = x;
		player.y = y;
		if (is_light) {			
			tube.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/dielight_tube.png"), true, false, 64, 256);
			spot.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/dielight_spot.png"), true, false, C.GAME_WIDTH, C.GAME_HEIGHT);	
			// r or d
			scrollBG.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/lightdeathtexture.png"), false, false, 416, 512);
			// u or l
			scrollBG2.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/lightdeathtexture2.png"), false, false, 416, 512);
			vignette.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/lightdeathvignette.png"));
				
		} else {
			tube.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/diedark_tube.png"), true, false, 416, 64);
			spot.myLoadGraphic(Assets.getBitmapData("assets/sprites/player/diedark_spot.png"), true, false, C.GAME_WIDTH, C.GAME_HEIGHT);	
			// r or d
			scrollBG.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/darkdeathtexture.png"), false, false, 832, 256);
			// u or u
			scrollBG2.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/darkdeathtexture2.png"), false, false, 832, 256);
			vignette.myLoadGraphic(Assets.getBitmapData("assets/sprites/bg/darkdeathvignette.png"));
		}
		spot.scrollFactor.set(0, 0);
		vignette.scrollFactor.set(0, 0);
		tube.blend = BlendMode.ADD;
		scrollBG.blend = BlendMode.ADD;
		scrollBG2.blend = BlendMode.ADD;
		//vignette.blend = BlendMode.ADD;
		scrollBG.scrollFactor.set(0, 0);
		scrollBG2.scrollFactor.set(0, 0);
		scrollBG.alpha = scrollBG2.alpha = 0;
		vignette.alpha = 0;
		vignette.move(0, 0);
		
		AnimImporter.addAnimations(tube, "PlayerDeathAnim", "tube");
		this.is_light = is_light;
		
		for (i in 0...particles.length) {
			if (is_light) {
				particles.members[i].makeGraphic(1, 1, 0xff91e7b6);
			} else {
				particles.members[i].makeGraphic(1, 1, 0xffdf6587);
			}
		}
		
		mode = 0;
	}
	public function finalize():Void {
		exists = false;
		vignette.exists = spot.exists = particles.exists = tube.exists = player.exists = false;
			vignette.visible = spot.visible = particles.visible = tube.visible = player.visible = false;
			scrollBG.visible = scrollBG.exists = false;
			scrollBG2.visible = scrollBG2.exists = false;
			scrollBG.velocity.set(0, 0);
			scrollBG2.velocity.set(0, 0);
	}
	public function is_finished():Bool {
		if (mode == 4) {
			return true;
		} 
		return false;
	}
	
	
	private var lerp_start:Point;
	private var t_lerp:Float = 0;
	private var skip:Bool = false;
	override public function update(elapsed: Float):Void {
		
		if (Registry.R.input.jpCONFIRM && mode != 4) {
			skip = true;
		}
		
		
		
		// bg scroll logic.
		if (mode != 0) { 
			var lightVel:Float = 50;
			var darkVel:Float = 50;
			
			// bg goes down or right, bg2 goes up or left
			if (is_light) {
				scrollBG.velocity.y = lightVel;
				scrollBG2.velocity.y = -lightVel;
				if (scrollBG.y + FlxG.elapsed * lightVel >= 0) {
					scrollBG.y = -scrollBG.height / 2;
				}
				if (scrollBG2.y - FlxG.elapsed * lightVel <= -scrollBG2.height / 2) {
					scrollBG2.y = 0;
				}
			} else {
				scrollBG.velocity.x = darkVel;
				scrollBG2.velocity.x = -darkVel;
				if (scrollBG.x + FlxG.elapsed * darkVel >= 0) {
					scrollBG.x = -scrollBG.width / 2;
				}
				if (scrollBG2.x - FlxG.elapsed * darkVel <= -scrollBG2.width/2) {
					scrollBG2.x = 0;
				}
			}
		}
		
		if (mode == 0) {
		    if (Registry.R.speed_opts[2]) {
				skip = true;
			} 
			vignette.exists = scrollBG.exists = scrollBG2.exists = spot.exists = particles.exists = tube.exists = player.exists = true;
			vignette.visible = scrollBG2.visible = scrollBG.visible = spot.visible = particles.visible = tube.visible = false;
			
			spot.alpha = 0;
			player.visible = true;
			mode = 1;
			lerp_start = new Point(player.x,player.y);
			t_lerp = 0;
			Registry.R.sound_manager.play(SNDC.die_big);
			if (is_light) {
				if (Registry.R.player.shieldless_sprite) {
					player.animation.play("light_shake_noshield", true);
				} else {
					player.animation.play("light_shake", true);
				}
				scrollBG.move(0,-scrollBG.height/2);
				scrollBG2.move(0, 0);
			} else  {
				if (Registry.R.player.shieldless_sprite) {
					player.animation.play("dark_shake_noshield", true);
				} else {
					player.animation.play("dark_shake", true);
				}
				scrollBG.move(-scrollBG.width/2, 0);
				scrollBG2.move(0, 0);
			}
			
			// bg goes down or right, bg2 goes up or left
		} else if (mode == 1) {
			Registry.R.song_helper.base_song_volume -= 0.05;
			Registry.R.song_helper.set_volume_modifier(Registry.R.song_helper.get_volume_modifier());
			
			spot.alpha += 0.1;
			vignette.alpha = scrollBG2.alpha = scrollBG.alpha = spot.alpha;
			var dest_x:Float = (FlxG.camera.scroll.x + FlxG.camera.width / 2) - (player.width / 2);
			var dest_y:Float = (FlxG.camera.scroll.y + FlxG.camera.height / 2) - (player.height / 2);
			
			t_lerp += FlxG.elapsed;
			vignette.visible = scrollBG.visible = scrollBG2.visible = spot.visible = true;
			if (skip) {
				t_lerp = 0.5;
				Registry.R.song_helper.base_song_volume = 0;
				Registry.R.song_helper.set_volume_modifier(Registry.R.song_helper.get_volume_modifier());
				
			}
			if (t_lerp < 0.5) {
				player.x = lerp_start.x + (dest_x - lerp_start.x) * (t_lerp / 0.5);	
				player.y = lerp_start.y + (dest_y - lerp_start.y) * (t_lerp / 0.5);
				scrollBG.preUpdate();
				scrollBG2.preUpdate();
				scrollBG.update(elapsed);
				scrollBG2.update(elapsed);
				scrollBG.postUpdate(elapsed);
				scrollBG2.postUpdate(elapsed);
				
				return;
			} 
			
			player.x = dest_x;
			player.y = dest_y;
			mode = 2;
			spot.alpha = 1;
			vignette.alpha = scrollBG2.alpha = scrollBG.alpha = spot.alpha;
			
			Registry.R.player.energy_bar.player_shade_timer = 0;
			Registry.R.player.energy_bar.status = 0;
			
			spot.x = player.x - (spot.width - player.width) / 2;
			spot.y = player.y - (spot.height -player.height) / 2;
			particles.visible = true;
		} else if (mode == 2) {
			Registry.R.song_helper.base_song_volume -= 0.02;
			if (Registry.R.song_helper.base_song_volume <= 0) {
				Registry.R.song_helper.base_song_volume = 0;
			}
			if (player.animation.finished || skip) {
				mode = 3;
				
				if (is_light) {
					tube.x = (C.GAME_WIDTH - tube.width) / 2;
					tube.y = 0;
				} else {
					tube.x = 0;
					tube.y = (C.GAME_HEIGHT - tube.height) / 2;
				}
				tube.visible = true;
				if (Registry.R.player.shieldless_sprite) {
					player.animation.play("noshield", true);
				} else {
					player.animation.play("shield");	
				}
				if (is_light) {
					tube.animation.play("move_l");
				} else {
					tube.animation.play("move_d");
				}
			}
		} else if (mode == 3) {
			if (tube.animation.finished || skip) {
				tube.visible = false;
				mode = 4;
				skip = false;
			}
		}
		
		
		if (mode == 2) {
			t_particle += 2*FlxG.elapsed;
			if (t_particle > tm_particle) {
				t_particle -= tm_particle;
				for (i in 0...particles.length) {
					
					if (particles.members[i].exists == false) {
						var p:FlxSprite = particles.members[i];
						p.exists = true; p.visible = true;
						p.velocity.x = -75 + 150 * Math.random();
						p.velocity.y = Math.sqrt(75 * 75 - p.velocity.x * p.velocity.x);
						if (Math.random() > 0.5) p.velocity.y *= -1;
						p.x = player.x + player.width / 2;
						p.y = player.y + player.height / 2;
						break;
					}
				}
			}
		}
		for (i in 0...particles.length) {
			if (particles.members[i].exists = true) {
				var p:FlxSprite = particles.members[i];
				if (p.x < spot.x || p.x > spot.x + spot.width || p.y > spot.y + spot.height || p.y < spot.y) {
					p.exists = false;
				}
			}
		}
		super.update(elapsed);
	}
	override public function draw():Void 
	{
		var ox:Float = spot.x;
		var oy:Float = spot.y;
		spot.move(0, 0);
		super.draw();
		spot.move(ox, oy);
	}
}