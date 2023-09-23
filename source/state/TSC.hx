package state;

/**
 * Test State constants
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */

class TSC 
{

	
	
	public static inline var SIG_FADE_IN_OVERLAY:Int = 0;
	public static inline var SIG_FADE_IN_TITLE_TEXT:Int = 1;
	public static inline var SIG_FADE_OUT_OVERLAY:Int = 2;
	public static inline var SIG_FADE_OUT_TITLE_TEXT:Int = 3;
	public static inline var SIG_CHANGE_COLOR:Int = 4;
	public static inline var SIG_DIALOGUE_BOX_ON_TOP:Int = 5;
	
	public static var do_fade_in_overlay:Bool = false;
	public static var JF_fade_in_overlay:Bool = false;
	
	public static var do_fade_out_overlay:Bool = false;
	public static var JF_fade_out_overlay:Bool = false;
	
	public static var fade_overlay_rate:Float = 0;
	
	
	public static var do_fade_in_title_text:Bool = false;
	public static var fade_in_title_text_caption:String = " ";
	public static var JF_fade_in_title_text:Bool = false;
	
	public static var do_fade_out_title_text:Bool = false;
	public static var JF_fade_out_title_text:Bool = false;
	
	public static var fade_title_text_rate:Float = 0;
	
	public static function reset_just_finished():Void {
		JF_fade_in_title_text = false;
		JF_fade_in_overlay = false;
		JF_fade_out_title_text = false;
		JF_fade_out_overlay = false;
	}
}