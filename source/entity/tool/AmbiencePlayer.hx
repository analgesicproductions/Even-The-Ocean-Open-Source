package entity.tool;
import entity.MySprite;
import haxe.Log;
import help.HF;
import hscript.Expr;
import hscript.Interp;
import openfl.Assets;
import flixel.FlxG;
import state.MyState;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class AmbiencePlayer extends MySprite
{

	var interp_1:Interp;
	var expr_1:Expr;
	private var state_1:Int = 0;
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		timers = [0, 0, 0, 0, 0];
		super(_x, _y, _parent, "AmbiencePlayer");
	}
	
	override public function change_visuals():Void 
	{
		myLoadGraphic(Assets.getBitmapData("assets/sprites/tools/AmbiencePlayer.png"), false, false, 32, 32);
		alpha = 0.7;
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("script1", "");
		//p.set("script2", "");
		p.set("distance", -1);
		p.set("follow_player", 0);
		p.set("max_scale", 1); // Scales max amplitude
		return p;
	}
	private var max_scale:Float = 0;
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		max_scale = props.get("max_scale");
		if (props.get("script1") != "") {
			interp_1 = new Interp();
			expr_1 = HF.get_program_from_script_wrapper("tool/" + props.get("script1")+".hx");
			interp_1.variables.set("this", this);
			interp_1.variables.set("R", R);
			interp_1.variables.set("Math", Math);
			
		} else {
			interp_1 = null;
		}
		change_visuals();
		// Do stuff
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	override public function update(elapsed: Float):Void 
	{
		if (R.editor.editor_active) {
			visible = true;
		} else {
			visible = false;
		}
		
		if (interp_1 != null) {
			interp_1.execute(expr_1);
		}
		super.update(elapsed);
		
	}
	private var timers:Array<Float>;
	private function set_rand_timer(timer_index:Int,min:Float, max:Float):Void {
		timers[timer_index] = min + (max - min) * Math.random();
	}
	
	private function dec_and_check_if_timer_done(timer_index:Int):Bool {
		//Log.trace(timers[timer_index]);
		if (timers[timer_index] > 0) {
			timers[timer_index] -= FlxG.elapsed;
		} else {
			return true;
		}
		return false;
	}
	
	private function play_s(name:String, volume:Float = 1, pan:Float = 0):Void {
		R.sound_manager.set_pan_for_next_play(pan);
			
		if (props.get("follow_player") == 1 && props.get("distance") > 0) {
			R.sound_manager.set_target_for_next_play(R.player, props.get("distance"), x, y);
			R.sound_manager.play(name, volume*max_scale);
		} else { 
			R.sound_manager.play(name, volume * max_scale);
		}
		//Log.trace("play");
	}	
	
}