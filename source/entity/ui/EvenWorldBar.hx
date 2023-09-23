package entity.ui;
import entity.tool.Door;
import flash.display.BitmapData;
import global.C;
import global.Registry;
import help.HF;
import hscript.Expr;
import hscript.Interp;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * Displays cards, lets you into an area
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class EvenWorldBar extends FlxGroup
{
	
	private var vistype:Int = 0;
	private var R:Registry;
	
	private var bar:FlxSprite;
	private var icons:FlxTypedGroup<FlxSprite>;
	private var selector:FlxSprite;
	private var idx_selector:Int = 0;
	
	public static var spritesheet_even_worldmap_cards:BitmapData;
	public function new() 
	{
		if (spritesheet_even_worldmap_cards == null) {
			spritesheet_even_worldmap_cards = Assets.getBitmapData("assets/sprites/ui/even_worldmap_cards.png");
		}
		super();
		R = Registry.R;
		bar = new FlxSprite();
		bar.scrollFactor.set(0, 0);
		change_visuals();
		icons = new FlxTypedGroup<FlxSprite>();
		selector = new FlxSprite(0, 0);
		selector.makeGraphic(26, 26, 0xaaff00ff);
		selector.scrollFactor.set(0, 0);
		idx_selector = 0;
		add(bar);
		add(icons);
		
		add(selector);
		selector.exists = false;
	}
	
	private function change_visuals():Void {
		switch (vistype) {
			case 0:
				bar.makeGraphic(22 * 16, 3 * 16, 0xffedb370);
				
		}
		bar.x = (C.GAME_WIDTH - bar.width) / 2;
		bar.y = 16;
	}
	
	private var cur_next_map:String = "";
	private static inline var ICON_SIZE:Int  = 24;
	private static inline var HORIZONTAL_ICON_SPACING:Int = 8;
	
	private var mode:Int = 0;
	private static inline var MODE_INACTIVE_INVISIBLE:Int = 0;
	private static inline var MODE_INACTIVE_VISIBLE:Int = 2;
	private static inline var MODE_IN_BAR:Int = 1;
	private static inline var MODE_EXITING:Int = 3;
	override public function update(elapsed: Float):Void 
	{
		super.update(elapsed);
			
		
		if (mode == MODE_IN_BAR) {
			if (R.input.jpCANCEL) {
				selector.exists = false;
				mode = MODE_INACTIVE_VISIBLE;
				R.toggle_players_pause(false);
			} else if (R.input.jpRight) {
				if (idx_selector < icons.length - 1) {
					idx_selector ++ ;
					selector.x += ICON_SIZE + HORIZONTAL_ICON_SPACING;
				}
			} else if (R.input.jpLeft) {
				if (idx_selector > 0) {
					idx_selector -- ;
					selector.x -= ICON_SIZE + HORIZONTAL_ICON_SPACING;
				}
				
			} else if (R.input.jpCONFIRM) {
				if (idx_selector == 0) {
					Door.SIG_EVEN_WORLDMAP_ALLOW_ENTERING = true;
					//mode = MODE_EXITING;
					mode = MODE_EXITING;
				} else {
					
				}
			}
		} else if (mode == MODE_INACTIVE_VISIBLE) {
			fade_alpha(0.035);
			if (R.input.jpCONFIRM) {
				fade_alpha(1);
				mode = MODE_IN_BAR;
				R.toggle_players_pause(true);
				selector.exists = true;
				idx_selector = 0;
				selector.x = icons.members[0].x - 1;
				selector.y = icons.members[0].y - 1;
			} else if (R.input.jpDown || R.input.jpUp || R.input.jpLeft || R.input.jpRight) {
				mode = MODE_INACTIVE_INVISIBLE;
				icons.callAll("destroy");
				icons.clear();
			}
		} else if (mode == MODE_INACTIVE_INVISIBLE) {
			fade_alpha( -0.035);
			if (R.train.is_idle() && Door.player_Is_On_EVEN_worlddoor) {
				mode = MODE_INACTIVE_VISIBLE;
				cur_next_map = Door.cur_even_worldmap_next_map;
				var expr:Expr = HF.get_program_from_script_wrapper("evenworldmap_bar_script.hx");
				var interpr:Interp = new Interp();
				interpr.variables.set("next_map", cur_next_map);
				var even_ids_to_check:Array<Int> = interpr.execute(expr);
				
				var enter_icon:FlxSprite = new FlxSprite(0, 0);
				
				enter_icon.myLoadGraphic(spritesheet_even_worldmap_cards, true, false, ICON_SIZE, ICON_SIZE);
				enter_icon.animation.frameIndex = 7;
				enter_icon.scrollFactor.set(0, 0);
				icons.add(enter_icon);
				
				for (even_id in even_ids_to_check) {
					if (R.inventory.is_item_found(even_id)) {
						var icon:FlxSprite = new FlxSprite(0, 0);
						icon.myLoadGraphic(spritesheet_even_worldmap_cards, true, false, ICON_SIZE, ICON_SIZE);
						icon.animation.frameIndex = even_id;
						icons.add(icon);
						icon.scrollFactor.set(0, 0);
					}
				}
				// TODO: Won't work if we have too many, add a bar or somethin
				//icons.setAll("scrollFactor", null);
				
				icons.setAll("alpha", 0);
				icons.setAll("y", (bar.y + (bar.height / 2)) - (enter_icon.height / 2));
				var required_width:Int = (ICON_SIZE + HORIZONTAL_ICON_SPACING) * (icons.length - 1) + ICON_SIZE;
				icons.members[0].x = ((bar.x + (bar.width / 2)) - (required_width / 2));
				for (i in 1...icons.length) {
					icons.members[i].x = icons.members[i - 1].x + ICON_SIZE + HORIZONTAL_ICON_SPACING;
				}
				
			}
		} else if (mode == MODE_EXITING) {
			fade_alpha( -0.015);
		}
		Door.player_Is_On_EVEN_worlddoor = false; // God help us
		
		if (FlxG.keys.myJustPressed("A")) {
			R.inventory.set_item_found(Inventory.INV_EVEN, 5);
						
			R.inventory.set_item_found(Inventory.INV_EVEN, 3);

		} else if (FlxG.keys.myJustPressed("S")) {
			R.inventory.set_item_found(Inventory.INV_EVEN, 6);
			
			R.inventory.set_item_found(Inventory.INV_EVEN, 2);
		}
	}
	
	public function fade_alpha(delta:Float):Void {
		bar.alpha += delta;
		selector.alpha += delta;
		icons.setAll("alpha", bar.alpha);
	}
		
	public function reset_for_entering_worldmap():Void {
		mode = MODE_INACTIVE_INVISIBLE;
		icons.callAll("destroy");
		icons.clear();
		bar.alpha = 1;
	}
}