package entity.tool;
import autom.EMBED_TILEMAP;
import entity.MySprite;
import flixel.util.FlxAxes;
import haxe.Log;
import help.HF;
import hscript.Expr;
import hscript.Interp;
import openfl.Assets;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import state.MyState;
/**
 * Object that runs cutscene scripts and handles some global state
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class Cutscene extends MySprite
{

	private var interp:Interp;
	private var program:Expr;
	private var ctr:Int = -1;
	private var cutscene_sprite:FlxSprite;
	
	private var mode:Int = 0;
	private static inline var MODE_NOT_RUNNING:Int = 0;
	private static inline var MODE_RUNNING:Int = 1;
	private static inline var MODE_FINISHED_PLAYING:Int = 2;
	
	private static inline var retval_PART_NOT_FINISHED:Int = -1;
	private static inline var retval_PART_FINISHED:Int = 0;
	private static inline var retval_CUTSCENE_FINISHED:Int = 1;
	
	public var t_one:Float = 0;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		interp = new Interp();
		cutscene_sprite = new FlxSprite();
		
		cutscene_sprite.myLoadGraphic(Assets.getBitmapData("assets/sprites/tools/Cutscene.png"), false, false, 16, 16);
		super(_x, _y, _parent, "Cutscene");
		interp.variables.set("R", R);
		
		animation.frameIndex = 0;
		visible = false;
		interp.variables.set("this", this);
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				makeGraphic(_w, _h, 0xaa123123);
				
		}
	}
	
	private var _w:Int = 0;
	private var _h:Int = 0;
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("cutscene_name", "none");
		p.set("width", 16);
		p.set("height", 16);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		program = null;
		ctr = -1;
		mode = MODE_NOT_RUNNING;
		_w = props.get("width");
		_h = props.get("height");
		if (props.get("cutscene_name") != "none") {
			program = HF.get_program_from_script_wrapper("cutscene/" + props.get("cutscene_name").toLowerCase()+".hx");
		}
		if (did_init) {
			populate_parent_child_from_props();
		}
		
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		R.there_is_a_cutscene_running = false;
		
			HF.remove_list_from_mysprite_layer(this, parent_state, [cutscene_sprite]);
			cutscene_sprite.destroy();
		super.destroy();
	}
	
	private var started:Bool = false;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			populate_parent_child_from_props();
			HF.add_list_to_mysprite_layer(this, parent_state, [cutscene_sprite]);
		}
		
		
		cutscene_sprite.x = x;
		
		cutscene_sprite.y = y;
		
		if (R.editor.editor_active) {
			visible = true;
			cutscene_sprite.visible = true;
			return;
		} else {
			visible = false;
			cutscene_sprite.visible = false;
		}
		
		if (!started) {
			if (R.activePlayer.overlaps(this)) {
				started = true;
			}
			return;
		}
		
		if (mode == MODE_FINISHED_PLAYING) {
			return;
		}
		
		var retval:Int = -1;
		if (program != null) {
			interp.variables.set("ctr", ctr);
			retval = interp.execute(program);
		}
		
	switch (mode) {
			case MODE_NOT_RUNNING:
				if (retval == retval_CUTSCENE_FINISHED) {
					mode = MODE_FINISHED_PLAYING;
				} else if (retval == retval_PART_FINISHED) {
					mode = MODE_RUNNING;
					R.there_is_a_cutscene_running = true;
					ctr++;
				}
			case MODE_RUNNING:
				
				if (retval == retval_PART_FINISHED) {
					ctr++;
				} else if (retval == retval_CUTSCENE_FINISHED) {
					mode = MODE_FINISHED_PLAYING;
				}
		}
		if (mode == MODE_FINISHED_PLAYING) {
			R.there_is_a_cutscene_running = false;
			R.toggle_players_pause(false);
		}
		
		super.update(elapsed);
	}
	
	public function get_title_of_map(mapname:String):String {
		return EMBED_TILEMAP.actualname_hash.get(mapname);
	}

	public function play_dialogue(map:String, scene:String):Void {
		parent_state.dialogue_box.start_dialogue(map, scene);
	}
	public function is_dialogue_finished():Bool {
		var is_active:Bool = parent_state.dialogue_box.is_active();
		if (is_active == true) {
			return false;
		}
		return true;
	}
	public function shake(intensity:Float,duration:Float,hor:Bool=true,vert:Bool=true):Void {
		if (hor && vert) {
			FlxG.cameras.shake(intensity, duration, null, true, FlxAxes.XY);
		} else if (hor) {
			FlxG.cameras.shake(intensity, duration, null, true, FlxAxes.X);
		} else if (vert) {
			FlxG.cameras.shake(intensity, duration, null, true, FlxAxes.Y);
		}
	}
	public function flash(duration:Float, color:Int):Void {
		FlxG.cameras.flash(color, duration, null, true);
	}
	
	public function set_t_one(f:Float):Void {
		t_one = f;
	}
	public function dec_t_one():Bool {
		t_one -= FlxG.elapsed;
		if (t_one < 0) {
			return true;
		}
		return false;
	}
	
	
}