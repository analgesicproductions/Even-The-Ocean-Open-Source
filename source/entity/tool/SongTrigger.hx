package entity.tool;
import entity.MySprite;
import global.C;
import help.HF;
import help.SongHelper;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import state.MyState;
/**
 * ...
 * @author Melos Han-Tani
 */

class SongTrigger extends MySprite
{

	public var songname:String = "trudge";
	public var nametext:FlxBitmapText;
	
	public function new(_x:Float,_y:Float,_parent:MyState)
	{
		super(_x, _y, _parent, "SongTrigger");
		
		makeGraphic(16, 48, 0xff123123);
		
		nametext = HF.init_bitmap_font(songname, "left", Std.int(x), Std.int(y), new FlxPoint(1, 1), C.FONT_TYPE_APPLE_WHITE);
	}
	
	override public function getDefaultProps():Map<String,Dynamic> 
	{
		var p:Map<String,Dynamic> = new Map<String,Dynamic>();
		p.set("name", "trudge");
		return p;
	}
	
	override public function set_properties(p:Map<String,Dynamic>):Void 
	{
		props = p;
		songname = p.get("name");
		songname = songname.toLowerCase();
		
	}
	override public function destroy():Void 
	{
		HF.remove_list_from_mysprite_layer(this, parent_state, [nametext]);
		super.destroy();
	}
	override public function update(elapsed: Float):Void 
	{
		if (!did_init) {
			did_init = true;
			HF.add_list_to_mysprite_layer(this, parent_state, [nametext]);
		}
		super.update(elapsed);
		
		if (R.editor.editor_active) {
			nametext.visible = visible = true; 
			flicker( -1);
			nametext.text = songname;
		} else {
			nametext.visible = visible = false;
		}
		
		if (R.player.overlaps(this) && songname != R.song_helper.next_song_name) {
			R.song_helper.fade_to_this_song(songname);
		}
	}
	
}