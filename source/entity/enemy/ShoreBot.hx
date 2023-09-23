package entity.enemy;import entity.MySprite;
import global.C;
import help.HF;
import hscript.Expr;
import hscript.Interp;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import state.MyState;

/**
 * ShorePlace boss
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class ShoreBot extends MySprite
{

	private var expr:Expr;
	private var interp:Interp;
	
	public static var ShoreBot_Group:FlxTypedGroup<ShoreBot>;
	
	private var water_pillar:FlxSprite;
	
	public function new(_x:Float,_y:Float,_parent:MyState) 
	{
		if (ShoreBot_Group == null) {
			ShoreBot_Group = new FlxTypedGroup<ShoreBot>();
		}
		interp = new Interp();
		
		super(_x, _y, _parent, "ShoreBot");
		
	}
	override public function recv_message(message_type:String):Int 
	{
		var n:Int = 0;
		if (message_type.split("+")[0] == C.MSGTYPE_ENERGIZE_AMT_D) {
			n = Std.parseInt(message_type.split("+")[1]);
			health -= n;
		} else if (message_type.split("+")[0]  == C.MSGTYPE_ENERGIZE_AMT_L) {
			n = Std.parseInt(message_type.split("+")[1]);
			health += n;
		}
		return C.RECV_STATUS_OK;
	}
	
	override public function change_visuals():Void 
	{
		switch (vistype) {
			default:
				makeGraphic(24, 24, 0xffff00ff);
		}
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("script_name", "enemy/shorebot_hs.hx");
		p.set("health", 100);
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		HF.copy_props(p, props);
		health = props.get("health");
		change_visuals();
	}
	
	override public function destroy():Void 
	{
		//HF.remove_list_from_mysprite_layer(this, parent_state, []);
		ShoreBot_Group.remove(this, true);
		super.destroy();
	}
	
	private var mode:Int = 0;
	private var mode_moving:Int = 1;
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			expr = HF.get_program_from_script_wrapper(props.get("script_name"));
			ShoreBot_Group.add(this);
			interp.variables.set("R", R);	
			interp.variables.set("this", this);
			did_init = true;
			//HF.add_list_to_mysprite_layer(this, parent_state, []);
		}
		
		interp.execute(expr);
		
		/* rolls on ceiling or moves horizontally along the ceiling
		 * need to get it hit by enough energy thingies  to overload
		 * status of energy shows on the left and right - it starts full light but you want to bring it to full dark
		 * two pits of water, with risen platforms tot he left and right and center.
		 * The pts have light energy gas in them , with water 3 tiles deep 
		 * Can fire pumps that raise water pillars out with  light infusion
		 * 
		 * light eventally splatters the tosp oft he pillars, so you have to stay on the walls
		 * 
		 * how to beat? */
		super.update(elapsed);
	}
}