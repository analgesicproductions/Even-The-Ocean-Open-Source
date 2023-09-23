package entity.player;
import autom.SNDC;
import entity.MySprite;
import flash.display.BitmapData;
import flash.geom.Point;
import global.C;
import haxe.Log;
import help.AnimImporter;
import help.HF;
import flash.geom.Rectangle;
import help.Track;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import state.MyState;
/**
 * ...
 * @author Melos Han-Tani
 */

class EnergyBar extends MySprite
{
	private var upper_cutscene_bar:FlxSprite;
	private var lower_cutscene_bar:FlxSprite;
	
	private var IS_DEBUG:Bool = true;
	private var debug_text:FlxBitmapText;
	private var od_meter_debug_text:FlxBitmapText;
	
	public var frozen:Bool = false;
	
	public var bar_sprite:FlxSprite;
	private var energyLevel:Int = 128;
	private var target:Int = 128;
	private var maxEnergyLevel:Int = 256;
	
	private var t_od:Float = 0;
	private var t_od_max:Float = 1.5;
	
	public var force_gfx_update:Bool = true;
	public static var energybar_spritesheet:BitmapData;
	public var copy_rect:FlxRect;
	public var copy_flash_rect:Rectangle;
	public var copy_point:FlxPoint;
	public var copy_flash_point:Point;
	
	public var status:Int = 0;
	public var player_shade_timer:Float = 0;
	
	
	
	public var death_fade:FlxSprite;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		super(_x, _y,  _parent, "EnergyBar");
		copy_rect = new FlxRect();
		copy_point = new FlxPoint();
		copy_flash_point = new Point();
		copy_flash_rect = new Rectangle();
		
		debug_text = HF.init_bitmap_font("", "left", FlxG.width - 108, 4, null, C.FONT_TYPE_EDITOR);
		od_meter_debug_text = HF.init_bitmap_font("", "left", FlxG.width - 108, 15, null, C.FONT_TYPE_EDITOR);
		debug_text.visible = od_meter_debug_text.visible = false;
		
		target = Std.int(maxEnergyLevel / 2);
		makeGraphic(1, 1, 0x00000000);
		x = C.GAME_WIDTH - 128 - 8;
		y = 8;
		scrollFactor.set(0, 0);
		
		visible = false;
		
		if (energybar_spritesheet == null) {
			energybar_spritesheet = Assets.getBitmapData("assets/sprites/ui/energybar.png");
		}
		bar_sprite = new FlxSprite(0, 0);
		bar_sprite.makeGraphic(224, 17, 0x65002000, true);
		bar_sprite.scrollFactor.set(0, 0);
		bar_sprite.pixels.copyPixels(energybar_spritesheet, new Rectangle(0, 0, 224, 17), new Point(0, 0));
		bar_sprite.x = (C.GAME_WIDTH - bar_sprite.width) / 2;
		bar_sprite.y = (C.GAME_HEIGHT - bar_sprite.height - 8);
		
		
		death_fade = new FlxSprite(0, 0);
		AnimImporter.loadGraphic_from_data_with_id(death_fade, 1, 1, "DangerScreen");
		death_fade.scrollFactor.set(0, 0);
		death_fade.alpha = 0;
		death_fade.x = (C.GAME_WIDTH / 2) - death_fade.width / 2;
		death_fade.y = (C.GAME_HEIGHT / 2) - death_fade.height / 2;
		
		lower_cutscene_bar = new FlxSprite(0, 0);
		upper_cutscene_bar = new FlxSprite(0, 0);
		lower_cutscene_bar.makeGraphic(FlxG.width, 32, 0xff040404);
		upper_cutscene_bar.makeGraphic(FlxG.width, 32, 0xff040404);
		lower_cutscene_bar.scrollFactor.set(0, 0);
		upper_cutscene_bar.scrollFactor.set(0, 0);
		lower_cutscene_bar.y = FlxG.height;
		upper_cutscene_bar.y = -upper_cutscene_bar.height;
		upper_cutscene_bar.alpha = lower_cutscene_bar.alpha = 0;
	}
	
	public function invert():Void {
		if (frozen) return;
		var r:Int = 0;
		if (target < 128) {
			r = 128 - target;
			target = 128 + r;
		} else if (target > 128) {
			r = target - 128;
			target = 128  - r;
		}
		
	}
	public function is_stable():Bool {
		return energyLevel == target;
	}
	public function get_LIGHT_percentage():Float {
		return energyLevel / cast(maxEnergyLevel, Float);
	}
	public function my_set_exists(_exists):Void {
		exists = _exists;
		debug_text.exists = _exists;
		od_meter_debug_text.exists = _exists;
		bar_sprite.exists = _exists;
		upper_cutscene_bar.exists = _exists;
		lower_cutscene_bar.exists = _exists;
	}
	public function add_to(g:FlxGroup):Void {
		g.add(this);
		g.add(bar_sprite);
		g.add(debug_text);
		g.add(od_meter_debug_text);
		g.add(upper_cutscene_bar);
		g.add(lower_cutscene_bar);
	}
	public function toggle_debug():Void {
		debug_text.visible = !debug_text.visible;
		od_meter_debug_text.visible = debug_text.visible;
		upper_cutscene_bar.alpha = od_meter_debug_text.visible ? 1 : 0;
		lower_cutscene_bar.alpha = od_meter_debug_text.visible ? 1 : 0;
		
	}
	
	public function toggle_bar(deflt:Bool = true, visibl:Bool = true):Void {
		if (deflt == false) {
			bar_sprite.visible = visibl;
		} else {
			bar_sprite.visible = !bar_sprite.visible;
		}
	}
	public function exit_extremes():Void {
		var lp:Float = get_LIGHT_percentage();
		if (lp <= 0.26) {
			set_energy(70);
			status = 0;
			player_shade_timer = 0;
			//death_fade.alpha = 0;
		} else if (lp >= 0.74) {
			set_energy(186);
			status = 0;
			player_shade_timer = 0;
			//death_fade.alpha = 0;
		}
	}
	public var skip_tick:Bool = false;
	public var OFF:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		
		
		if (OFF) {
			if (bar_sprite.alpha >= 0) {
				bar_sprite.alpha -= 0.05;
			}
			if (death_fade.alpha >= 0) {
				death_fade.alpha -= 0.05;
			}
			return;
		} else {
			if (bar_sprite.alpha < 1) {
				bar_sprite.alpha += 0.01;
			}
		}
		update_movement_in_cutscene();
		
		if (ProjectClass.DEV_MODE_ON) {
			if (FlxG.keys.myJustPressed("ONE") && FlxG.keys.pressed.D) {
				energyLevel = target = maxEnergyLevel;
			}
		}
		if (wait_for_death_to_finish) {
			//Log.trace("lala");
			death_fade.alpha -= 0.025;
			//if (death_fade.color == 0x000000) {
				//death_fade.makeGraphic(C.GAME_WIDTH, C.GAME_HEIGHT, 0xff000000);
			//} else {
				//death_fade.makeGraphic(C.GAME_WIDTH, C.GAME_HEIGHT, 0xffffffff);
				//death_fade.color = 0xffffff;
			//}
			return;
		}
		if (skip_tick) {
			skip_tick = false;
			return;
		}
		var update_bar_graphics:Bool = false;
		if (force_gfx_update) {
			force_gfx_update = false;
			update_bar_graphics = true;
		}
		
		if (R.player.is_in_cutscene()) {
		} else if (target < energyLevel) {
			status = -1;
			player_shade_timer = 0.25;
			energyLevel--;
			play_bar_sound(energyLevel);
			update_bar_graphics = true;
		} else if (target > energyLevel) {
			status = 1;
			player_shade_timer = 0.25;
			energyLevel++;
			play_bar_sound(energyLevel);
			update_bar_graphics = true;
		} else {
		}
		
		var lp:Float = get_LIGHT_percentage();
		if (lp <= 0.1) {
			//player_shade_timer = 0.2;
			status = -1;
		} else if (lp >= 0.9) {
			//player_shade_timer = 0.2;
			status = 1;
		} else if (target == energyLevel) {
			//player_shade_timer = 0.05;
		}
		if (R.editor.editor_active) {
			lower_cutscene_bar.visible = false;
		} else {
			lower_cutscene_bar.visible = true;
		}
		
		if (energyLevel == 0 || energyLevel == maxEnergyLevel) {
			if (R.editor.death_lock_on || R.access_opts[3]) {
				if (energyLevel == 0) energyLevel = 1;
				if (energyLevel == maxEnergyLevel) energyLevel = maxEnergyLevel - 1;
				update_bar_graphics = true;
			} else {
				wait_for_death_to_finish = true;
				if (R.player.exists) {
					R.player.enter_dying();
				}
			}
		} else {
			if (t_od > 0) {
				t_od -= FlxG.elapsed;
			} else {
				t_od = 0;
			}
		}
		if (update_bar_graphics) {
			var bar_margin:Int = 7; // x start of 'copying'
			var light_y_off:Int = 0;
			var dark_y_off:Int = 17;
			var interm_y_off:Int = 34;
			var bar_width:Int = 224;
			var bar_height:Int = 17;
			var color_px:Int = (bar_width - 2 * bar_margin); // nr of pixels i bar that are colors
			var light_px:Int = Std.int( color_px * ((energyLevel * 1.0) / maxEnergyLevel));
			var dark_px:Int = color_px - light_px;
			
			copy_rect.set(bar_margin, light_y_off, light_px, bar_height);
			copy_point.set(bar_margin, 0);
			bar_sprite.pixels.copyPixels(energybar_spritesheet, copy_rect.copyToFlash(copy_flash_rect), copy_point.copyToFlash(copy_flash_point));
			copy_rect.set(bar_margin+light_px, dark_y_off, dark_px, bar_height);
			copy_point.set(bar_margin+light_px, 0);
			bar_sprite.pixels.copyPixels(energybar_spritesheet, copy_rect.copyToFlash(copy_flash_rect), copy_point.copyToFlash(copy_flash_point));
			
			if (target != energyLevel) {
				var interm_start:Int = 0;
				var interm_px:Int = 0;
				var diff:Int = 0;
				if (target > energyLevel) {
					// bug: interm is not being to the left enough.
					diff = bar_margin + Math.round(color_px * ((target* 1.0) / maxEnergyLevel));
					interm_start = bar_margin + Math.floor(color_px * ((energyLevel * 1.0) / maxEnergyLevel));
					interm_px = diff - interm_start + 1;
				} else { // <
					diff = energyLevel - target;
					interm_start = bar_margin + Math.ceil(color_px * ((target* 1.0) / maxEnergyLevel));
					interm_px = Math.round(color_px * ((diff  * 1.0) / maxEnergyLevel));
				}
				copy_rect.set(interm_start, interm_y_off, interm_px, bar_height);
				copy_point.set(interm_start, 0);
				bar_sprite.pixels.copyPixels(energybar_spritesheet, copy_rect.copyToFlash(copy_flash_rect), copy_point.copyToFlash(copy_flash_point));
			}
		}
		
		if (energyLevel < 64) {
			
			if (energyLevel != target || death_fade.alpha < 0.02) {
				death_fade.animation.play("dark");
				death_fade.scale.y = 1.15 - 0.313 * ((64 - energyLevel) / 64);
				death_fade.scale.x = 1.15 - 0.2153 * ((64 - energyLevel) / 64);
			}
			if (death_fade.alpha < 0.4) {
				death_fade.alpha += 0.01;
			}
		} else if (energyLevel > 204) {
			if (energyLevel != target  || death_fade.alpha < 0.02) {
				death_fade.animation.play("light");
				death_fade.scale.y = 0.837 + 0.333 * ((255 - energyLevel) / 64);
				death_fade.scale.x = 0.9347 +  0.2353 * ((255 - energyLevel) / 64);
			}
			if (death_fade.alpha < 0.4) {
				death_fade.alpha += 0.01;
			}
		} else {
			death_fade.alpha -= 0.02;
		}
		
		super.update(elapsed);
	}
	
	/**
	 * Set energy to a minimum if needed
	 */
	public function map_transition():Void {
		
		if (frozen) return;
		if (target == 0) {
			target = 1;
		} else if (target == maxEnergyLevel) {
			target = maxEnergyLevel - 1;
		} else {
			target = energyLevel;
		}
		// In case we skip a graphics update when the target has been set here to something
		// that was in the middle of drawing
		force_gfx_update = true;
	}
	public function add_dark(amount:Int):Int {
		if (frozen) return 0;
		var old:Int = target;
		target = Math.floor(Math.max(0, target - amount));
		return old - target;
	}
	
	public function add_light(amount:Int):Int {
		//Log.trace(Track.get_stacktrace(true));
		if (frozen) return 0;
		var old:Int = target;
		target = Math.floor(Math.min(maxEnergyLevel, target + amount));
		return target - old;
	}
	public function balance_energy():Void {
		
		if (frozen) return;
		target = Std.int(maxEnergyLevel / 2);
	}
	
	public function get_energy():Int {
		return target;
	}
	
	public function set_energy(value:Int):Void {
		if (frozen) return;
		energyLevel = value;
		target = energyLevel;
		force_gfx_update = true;
	}
	
	public var wait_for_death_to_finish:Bool = false;
	
	public function reset_after_death():Void {
		if (frozen) return;
		wait_for_death_to_finish = false;
		target = Std.int(maxEnergyLevel / 2);
		active = true;
		energyLevel = Std.int(maxEnergyLevel / 2);
		force_gfx_update = true;
	}
	
	public var cutscene_mode:Int = 0;
	// Disallow the bar moving back onto the screen - set in GenericNPC during long dialogue where we don't want it moving in and out constantly
	public var allow_move:Bool = true;
	public var force_hide:Bool = false;
	private var cutscene_h:Int = 16;
	public var dont_move_cutscene_bars:Bool = false;
	
	/**
	 * Current game state in a gauntlet area?
	 * If not, then hide bar when inactive.
	 */
	public var in_gauntlet:Bool = false;
	public var hiddenForInactive:Bool = false;
	private var tInactive:Float = 0;
	function update_movement_in_cutscene():Void 
	{
		//Log.trace([cutscene_mode, dont_move_cutscene_bars, tInactive, hiddenForInactive]);
		if (cutscene_mode == 0) {
			if (force_hide || R.TEST_STATE.dialogue_box.is_active()) {
				cutscene_mode = 1;
				force_hide = false;
			}
			// Always reset this here in case some code somewhere sends cutscnee mode back to 0.
			hiddenForInactive = false;
			if (!in_gauntlet) {
				tInactive += FlxG.elapsed;
				if (tInactive > 3.0) {
					tInactive = 0;
					cutscene_mode = 1;
					force_hide = false;
					hiddenForInactive = true;
					dont_move_cutscene_bars = true;
				}
				// Don't hide the bar for inactivity when at extreme energy levels.
				if (energyLevel <= 32 || energyLevel >= 256 - 32) {
					tInactive = 0;
				}
			}
		} else if (cutscene_mode == 1) {
			bar_sprite.velocity.y += 5;
			bar_sprite.velocity.y *= 1.1;
			
			if (!dont_move_cutscene_bars) {
				var bar_y:Float = C.GAME_HEIGHT - bar_sprite.height - 8;
				bar_y = C.GAME_HEIGHT - bar_y;
				bar_y = (bar_sprite.y - (C.GAME_HEIGHT-bar_sprite.height-8)) / (bar_y); // ratio
				upper_cutscene_bar.y = -32 + cutscene_h * (bar_y);
				lower_cutscene_bar.y = C.GAME_HEIGHT - cutscene_h * bar_y;
			}
			//Log.trace(bar_y);
			if (bar_sprite.y > C.GAME_HEIGHT) {
				bar_sprite.velocity.y = 0;
				bar_sprite.y = C.GAME_HEIGHT;
				cutscene_mode = 2;
				if (!dont_move_cutscene_bars) {
					set_final_cutscene_bar_pos();
				}
			}
			
		} else if (cutscene_mode == 2) {
			if (allow_move == false) return; 
			if (hiddenForInactive) {
				// Unhide the bar if you lock, get hurt, or are in a gauntlet area.
				if (R.player.draw_start_lock_shield_effect == true || energyLevel != target || in_gauntlet) {
					cutscene_mode = 3;
					dont_move_cutscene_bars = true;
					// If somehow you've started to draw the shield to re-show the bar, and the cutscene
					// bars are stuck , then allow them to move.
					if (lower_cutscene_bar.y == C.GAME_HEIGHT - cutscene_h) {
						dont_move_cutscene_bars = false;
					}
 				}
			} else {
				if (!R.TEST_STATE.dialogue_box.is_active()) {
					cutscene_mode = 3;
				}
			}
		} else if (cutscene_mode == 3) {
			
			
			bar_sprite.velocity.y -= 5;
			bar_sprite.velocity.y *= 1.1;
			
			if (!dont_move_cutscene_bars) {
				var bar_y:Float = C.GAME_HEIGHT - bar_sprite.height - 8;
				bar_y = C.GAME_HEIGHT - bar_y;
				bar_y = (bar_sprite.y - (C.GAME_HEIGHT-bar_sprite.height-8)) / (bar_y); // ratio
				bar_y = 1 - bar_y;
				upper_cutscene_bar.y = (-32 + cutscene_h) - cutscene_h * (bar_y);
				lower_cutscene_bar.y = (C.GAME_HEIGHT - cutscene_h) + cutscene_h * bar_y;
			}
			//Log.trace(bar_y);
			if (bar_sprite.y < C.GAME_HEIGHT - bar_sprite.height - 8) {
				bar_sprite.y = C.GAME_HEIGHT - bar_sprite.height - 8;
				bar_sprite.velocity.y = 0;
				cutscene_mode = 0;
				if (!dont_move_cutscene_bars) {
					upper_cutscene_bar.y = -32;
					lower_cutscene_bar.y = C.GAME_HEIGHT;
				}
				dont_move_cutscene_bars = false;
				hiddenForInactive = false;
			}
		}
	}
	
	private function play_bar_sound(i:Int):Void {
		if (i > 0 && i < 128) {
			if (i % 16 == 0) {
				i = 128 - i;
				i = Std.int(i / 16);
				R.sound_manager.play("eb/e_d"+Std.string(i)+".wav");
			}
		} else if (i == 128) {
			R.sound_manager.play(SNDC.eb_e_n);
		} else {
			if (i % 16 == 0) {
				i -= 128;
				i = Std.int(i / 16);
				R.sound_manager.play("eb/e_l"+Std.string(i)+".wav");
			}
		}
	}
	
	function set_final_cutscene_bar_pos():Void 
	{
		upper_cutscene_bar.y = -32 + cutscene_h;
		lower_cutscene_bar.y = C.GAME_HEIGHT - cutscene_h;
	}
	
	// Sticks the bars into idle mode, hides energy, shows cutscene.
	// Must set 'allow-move' to true to get out
	public function force_set_cutscene_bar(_Allow_move:Bool=false):Void {
		set_final_cutscene_bar_pos();
		bar_sprite.velocity.y = 0;
		bar_sprite.y = C.GAME_HEIGHT;
		cutscene_mode = 2;
		allow_move = _Allow_move;
	}
	
}