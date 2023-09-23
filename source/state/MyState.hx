package state;
import entity.ui.DecisionBox;
import entity.ui.DialogueBox;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.io.Bytes;
import haxe.io.BytesData;
import flash.geom.Point;
import help.AnimTileEngine;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.util.FlxSave;
import flixel.FlxState;
import flixel.tile.FlxTilemap;

/**
 * An extended state with placeholder tile layers, sprite groups
 * @author Melos Han-Tani
 */

class MyState extends FlxState
{

	public var anim_tile_engine:AnimTileEngine;
	
	/**
	 * A group of background layers with various parallax values.
	 */
	public var b_bg_parallax_layers:FlxGroup;
	public var bg_parallax_layers:FlxGroup;
	public var fg1_parallax_layers:FlxGroup;
	public var fg2_parallax_layers:FlxGroup;
	
	public inline static var ENT_LAYER_IDX_BELOW_BG:Int = 0;
	public inline static var ENT_LAYER_IDX_BG1:Int = 1;
	public inline static var ENT_LAYER_IDX_BG2:Int = 2;
	public inline static var ENT_LAYER_IDX_FG2:Int = 4;
	/**
	 * Sprites that are drawn below the bg tilemap. 
	 */
	public var below_bg_sprites:FlxGroup;
	
	public var bg1_sprites:FlxGroup;
	/**
	 * Sprites that go in front of the bg2 tilemap layers. For the love of god only put mysprites in here
	 */
	public var bg2_sprites:FlxGroup;
	/**
	 * Sprites that go in front of the FG layers?
	 */
	public var fg2_sprites:FlxGroup;
	/**
	 * Sprites that are drawn on top of everything.
	 */
	public var gui_sprites:FlxGroup;
	
	public var tm_bg:FlxTilemapExt;
	public var tm_bg2:FlxTilemapExt;
	public var tm_fg:FlxTilemapExt;
	public var tm_fg2:FlxTilemapExt;
	
	//public var animtiles_bg:FlxGroup; 
	public var dialogue_box:DialogueBox;
	public var decision_box:DecisionBox;
	
	/**
	 * The current identifying name of the map. Used in serialization, getting CSV
	 */
	public var MAP_NAME:String;
	/**
	 * Current identifying name of the tileset.
	 */
	public var TILESET_NAME:String;
	public var BG_NAME:String;
	
	public inline static var LDX_BG:Int = 0;
	public inline static var LDX_BG2:Int = 1;
	public inline static var LDX_FG:Int = 2;
	public inline static var LDX_FG2:Int = 3;
	
	public var next_player_x:Int;
	public var next_player_y:Int;
	
	public var prev_map_name:String = "";
	public var next_map_name:String;
	public var DO_CHANGE_MAP:Bool = false;
	public var DO_PLAYER_DIED:Bool = false;
	
	public var next_bg_name:String;
	public var next_tileset_name:String;
	
	
	
	/**
	 * Can the editor edit this state (maaaybe)
	 */
	public var is_editable:Bool = false;
	
	public function set_bg_alpha(a:Float):Void {
		for (i in [b_bg_parallax_layers,bg_parallax_layers, fg1_parallax_layers,fg2_parallax_layers]) {
			for (j in 0...i.length) {
				if (i.members[j] != null) {
					var s:FlxSprite = cast i.members[j];
					s.alpha = a;
				}
			}
		}
	}
	public function new() 
	{
		
		b_bg_parallax_layers = new FlxGroup();
		bg_parallax_layers = new FlxGroup();
		below_bg_sprites = new FlxGroup();
		fg1_parallax_layers = new FlxGroup();
		fg2_parallax_layers = new FlxGroup();
		bg1_sprites = new FlxGroup();
		bg2_sprites = new FlxGroup();
		fg2_sprites = new FlxGroup();
		gui_sprites = new FlxGroup();
		//animtiles_bg = new FlxGroup();
		anim_tile_engine = new AnimTileEngine();
		
		tm_bg = new FlxTilemapExt();
		tm_bg2 = new FlxTilemapExt();
		tm_fg = new FlxTilemapExt();
		tm_fg2 = new FlxTilemapExt();
		
		dialogue_box = new DialogueBox();
		decision_box = new DecisionBox();
		super();
	}
	
	public function get_tilemaps():Array<FlxTilemapExt> {
		return [tm_bg, tm_bg2, tm_fg, tm_fg2];
	}
	public function get_entity_sprite_layers():Array<FlxGroup> {
		var a:Array<FlxGroup> = [below_bg_sprites, bg1_sprites,bg2_sprites, fg2_sprites];
		return a;
	}
	
	public function get_map_dimensions():Point {
		var dim:Point = new Point(tm_bg.widthInTiles, tm_bg.heightInTiles);
		return dim;
	}
	
}