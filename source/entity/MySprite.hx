package entity;
import global.C;
import global.Registry;
import haxe.Log;
import help.HF;
import openfl.Assets;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import state.MyState;
#if cpp
import sys.io.File;
#end
/**
 * Just the FlxSprite with some extra functionsetc
 * @author Melos Han-Tani
 */

class MySprite extends FlxSprite
{

	
	public static var presets:Map<String,Dynamic>;
	public var state:Int = 0;
	public var did_init:Bool = false;
	public var parent_state:MyState;
	public var props:Map<String,Dynamic>;
	public var name:String;
	public var R:Registry;
	public var cur_layer:Int;
	public var vistype:Dynamic;
	public var dmgtype:Int;
	/**
	 * An automatically-set linked sprite (camera trigger zones on a camera trigger etc)
	 */
	public var linked_sprite:MySprite;
	
	public var does_proximity_sleep:Bool = false;
	public var ctr_proximity_sleep:Int = 0;	
	public var asleep:Bool = false;
	
	public var children:Array<MySprite>;
	public var parents:Array<MySprite>;
	
	public var ix:Int;
	public var iy:Int;
	/**
	 * good-enough-id, just for distinguishing in a group. when being added with
	 * the editor, should be checked to make sure no duplicates
	 */
	public var geid:Int;
	public static var SKIP_INIT_SET_PROPERTIES:Bool = false;
	public function new(X:Float = 0, Y:Float = 0, parentstate:MyState=null,_name:String="",_props:Map<String,Dynamic>=null , SimpleGraphic:Dynamic = null) 
	{
		super(X, Y, SimpleGraphic);
		parent_state = parentstate;
		
		if (_props == null) {
			props = getDefaultProps();
		}
		name = _name;
		if (name == "MYSPRITESKEL") {
			Log.trace("You put MYSPRITESKEL as the name.");
		}
		children = [];
		parents = [];
		R = Registry.R;
		//if (SKIP_INIT_SET_PROPERTIES == false) {
			set_properties(props);
		//}
		ix = Math.floor(X);
		iy = Math.floor(Y);
		geid = Math.floor(1000000.0 * Math.random());
	}
	
	override public function destroy():Void 
	{
		CUT_CHILD_RELATIONSHIPS(children);
		CUT_PARENT_RELATIONSHIPS(parents);
		children = null;
		parents = null;
		props = null;
		linked_sprite = null;
		super.destroy();
	}
	
	public function CUT_CHILD_RELATIONSHIPS(_children:Array<MySprite>):Void {
		if (_children == null) return;
		for (i in 0...children.length) {
			_children[i].parents.remove(this);
		}
		
		while (children.length > 0) {
			_children.pop();
		}
	}
	public function CUT_PARENT_RELATIONSHIPS(_parents:Array<MySprite>):Void {
		if (_parents == null) return;
		for (i in 0...parents.length) {
			_parents[i].children.remove(this);
			_parents[i].props.set("children", _parents[i].get_children_string());
		}
		while (parents.length > 0) {
			_parents.pop();
		}
	}
	
	// Populate children array of this sprite bbased on an existing string of
	// child GEIDs
	public function populate_parent_child_from_props():Void {
		CUT_CHILD_RELATIONSHIPS(children);
		var s:String = props.get("children");
		if (s != null && s != "") {
			var geid_strs:Array<String> = s.split(",");
			var grps:Array<FlxGroup> = parent_state.get_entity_sprite_layers();
			for (i in 0...geid_strs.length) {
				var next_geid:Int = Std.parseInt(geid_strs[i]);
				var found:Bool = false;
				for (j in 0...grps.length) {
					for (k in 0...grps[j].members.length) {
						var ms:MySprite = cast grps[j].members[k];
						if (ms != null && ms.geid == next_geid) {
							ms.parents.push(this);
							children.push(ms);
							found = true;
							break;
						}
					}
					if (found) {
						found = false;
						break;
					}
				}
			}
		}
	}
	public function get_children_string():String {
		var s:String = "";
		for (i in 0...children.length) {
			s += Std.string(children[i].geid);
			if (i != children.length - 1) {
				s += ",";
			}
		}
		return s;
		
	}
	public function change_visuals():Void {
		
	}
	/**
	 * Called when you successfully change an entity's
	 * property in the editor - updates the graphics,
	 * behavior, etc.
	 *
	 * @param	p
	 */
	public function set_properties(p:Map<String,Dynamic>):Void {
		//if (p == null) return;
		//var k:String;
		//for (k in p.keys()) {
			//Log.trace(k);
			//Log.trace(p.get(k));
			//Log.trace("---");
		//}
	}
	
	public function add_parent(parent:MySprite):Void {
		parents.push(parent);
	}
	/** called when a child moves, child sends a generic message to this sprite
	 * */
	public function on_child_notification(child:MySprite):Void {
		
	}
	/**
	 * Override this. Called once when the sprite is created,
	 * defaults the fields to something (to prevent horrible issues if
	 * we update the entity data in future patches etc)
	 * @return
	 */
	public function getDefaultProps():Map<String,Dynamic> {
		return new Map<String,Dynamic> () ;
	}
	
	public function on_clicked_for_edit():Void {
		
	}
	public function recv_message(message_type:String):Int {
		return -1;
	}
	public function broadcast_to_children(message_type:String):Void {
		for (i in 0...children.length) {
			children[i].recv_message(message_type);
		}
	}
	override public function update(elapsed: Float):Void 
	{
		if (does_proximity_sleep) {
			ctr_proximity_sleep++;
			if (ctr_proximity_sleep > 30) {
				ctr_proximity_sleep = 0;
				if (!asleep) {
					if (Math.abs(x - R.player.x) > 700 || Math.abs(y - R.player.y) > 500) {
						asleep = true;
						sleep();
					}
				} else {
					if (Math.abs(x - R.player.x) < 700 && Math.abs(y - R.player.y) < 500) {
						asleep = false;
						wakeup();
					}
				}
			}
		}
		super.update(elapsed);
	}
	
	override public function draw():Void 
	{
		#if cpp
		if (R.editor.editor_active) {
			for (i in 0...children.length) {
				FlxG.camera.debugLayer.graphics.lineStyle(1, 0xff0000, 1);
				FlxG.camera.debugLayer.graphics.moveTo(x - FlxG.camera.scroll.x, y - FlxG.camera.scroll.y);
				FlxG.camera.debugLayer.graphics.lineTo(children[i].x - FlxG.camera.scroll.x, children[i].y - FlxG.camera.scroll.y);
			}
		}
		#end 
		super.draw();
	}
	public function wakeup():Void {
		
	}
	public function sleep():Void {
		
	}
	
	/**
	* Loads PRESET file at PATH
	* @param	_presets the object to initialize
	* @param path	Path to file (relative to "assets/")
	* @return
	*/
	public static function initialize_entity_presets(path:String, from_dev:Bool = false):Map < String, Dynamic > {
		if (from_dev) {
			#if cpp
			return HF.parse_SON(File.getContent(C.EXT_ASSETS + "entity_presets.son"));
			#end
			#if !cpp
			return HF.parse_SON(Assets.getText("assets/" + path));
			#end
		} else {
			return HF.parse_SON(Assets.getText("assets/" + path));
		}
		return null;
	}
	
}