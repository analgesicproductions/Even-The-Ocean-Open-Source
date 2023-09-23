package help;
import global.Registry;
import haxe.Log;

/**
 * ...
 * @author Copyright Melos Han-Tani, Developer of Analgesic Productions LLC, 2013 - ? , www.twitter.com/han_tani
 */
class AchievementModule
{

	
	public function new() 
	{
		
	}
	
	// [x] = added to game code
	// [xx] = tested as working in debug
	// [xxx] = got it in steam
	public var act1:Int = 0; // [x]
	public var act2:Int = 1; // [x]
	public var act3:Int = 2; // [x]
	public var act4:Int = 3; // [x]
	public var act5:Int = 4; // [x]
	public var test:Int = 5; // [x]
	
	public var story1:Int = 10; // [x]
	public var story2:Int = 11; // [x]
	public var story3:Int = 12; // [x]
	public var story4:Int = 13; // [x]
	public var story5:Int = 14; // [x]
	
	public var gauntlet1:Int = 20; // [xx]
	public var gauntlet2:Int = 21; // [xx]
	public var gauntlet3:Int = 22; // [xx]
	public var gauntlet4:Int = 23; // [xx]
	public var gauntlet5:Int = 24; // [xx]
	
	public var findPostgame:Int = 30; // [xx]
	public var takePicture:Int = 31; // []
	public var readJournal:Int = 32; // [xxx]
	public var museum:Int = 33; // [xxx]
	public var library:Int = 34; // [xxx]
	public var findLopez:Int = 35; // [xx]
	public var mom:Int = 36; // [xx]
	
	public var speedrunMain:Int = 40; // [xx]
	public var speedrunGauntlet:Int = 41; // [xx]
	
	public var debugNames:Array<String> = ["act1", "act2", "act3", "act4", "act5", "test", "", "", "", "", "story1", "story2", "story3", "story4", "story5", "", "", "", "", "", "gauntlet1", "gauntlet2", "gauntlet3", "gauntlet4", "gauntlet5", "", "", "", "", "", "findPostgame", "", "readJournal", "museum", "library", "findlopez", "mom", "", "", "", "speedrunMain", "speedrungauntlet", "", "", "", "", "", "", "", ""];
	
	
	public function unlock(id:Int):Void {
		if (id == mom || id == findLopez || id==takePicture) {
			return; // Ignore these
		}
		
		
		if (id >= 0 && id <= 4) {
			if (id + 1 > Registry.R.farthestact) {
				Registry.R.farthestact = id + 1;
			}
		}
		if (id == museum) {
			Registry.R.visitedmuseum = 1;
		}
		if (id == library) {
			Registry.R.visitedlibrary = 1;
		}
		
		if (ProjectClass.DEV_MODE_ON) {
			Log.trace("Also clearing achievement b/c dev mode on.");
			//Steam.clearAchievement(debugNames[id]);
		}
		/*
		if (Main.IsKartridge) {
			Log.trace("Trying to send Kartridge stat");
			if (Registry.R.inwarpmode == 1) Log.trace("ignoring bc warp mode");
			if (Kartridge.isReady() && Registry.R.inwarpmode == 0) {
				Log.trace("Sending Kartridge stat...");
				if (id == act1) Kartridge.submit("Act1_Complete", 1);
				if (id == act2) Kartridge.submit("Act2_Complete", 1);
				if (id == act3) Kartridge.submit("Act3_Complete", 1);
				if (id == act4) Kartridge.submit("Act4_Complete", 1);
				if (id == act5) Kartridge.submit("Act5_Complete", 1);
				
				if (id == museum) {
					Kartridge.submit("Visited_Museum", 1);
				}
				if (id == library) {
					Kartridge.submit("Visited_Library", 1);
				}
			}
		} else {
			Steam.setAchievement(debugNames[id]);
		}
		*/
		// to do...
		Log.trace("Unlock achievement " + Std.string(id) + ": " + debugNames[id]);	
	}
	
	public function speedrunCheck():Void {
		Log.trace(Registry.R.playtime);
		//test time is 5 hrs
		
		if (Registry.R.gauntlet_mode) {
			if (Registry.R.playtime < 60 * 60 * 60 * 3) {
				unlock(speedrunGauntlet);
			}
		} else if (!Registry.R.story_mode) { // normal mode
			if (Registry.R.playtime < 60 * 60 * 60 * 5) {
				unlock(speedrunMain);
			}
		}
	}
	
}