//{ outer_wm_thing
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	if (R.gs1 == 245) { // Set by 8f_flood
		this.SCRIPT_OFF = true;
		return;
	}
	
	
	// code in door.hx  line 275
	R.ok_doors = "TUNNEL_3,TUNNEL_5"; // change - list of transtion areas so fater golems or arriving to KV you can go only to KV
	
	if (this.event(50)) {
		this._trace("map2 blocker off bc ending done");
		this.SCRIPT_OFF = true;
		return;
	}
	this.s1 = -1;
	
	//R.inventory.set_item_found(0, 23, true); 
	
	//public static inline var g3_1_DONE:Int = 43;
	//public static inline var g3_2_DONE:Int = 44;
	//public static inline var g3_3_DONE:Int = 45;
	// block to only KV after g1 and after g2
	
	//this._trace("debug 7hworldmap postg3_1");
	//this.set_event(43);
	
	//this._trace("debug 7h after firstsleep");
	//this.set_ss("s3", "first_sleep", 1, 1);
	
	//this.set_ss("s3", "debrief", 1, 1);
	
	//this.set_event(44);	
	//this.set_ss("s3", "debrief_2", 1, 1);
	
	//this._trace("debug 7hworldmap postg3_2");
	//this.set_event(44);
	
	//this._trace("debug 7hworldmap postg3_3");
	//this.set_event(45);
	
	if (this.get_event(45, true) == 1 && this.get_ss("s3", "last_debrief", 1) == 0) {
		this.s1 = 0;
		this.s2 = 3;
		R.ignore_door = true;
	} else if (this.get_event(44, true) == 1 && this.get_ss("s3", "debrief_2", 1) == 0) {
		this.s1 = 0;
		this.s2 = 4;
		R.ignore_door = true;
	} else if (this.get_event(43, true) == 1 && this.get_ss("s3", "debrief", 1) == 0) {
		this.s1 = 0;
		this.s2 = 5;
		R.ignore_door = true;
		return;
	// Only can enter Karavold if just left train station
	} else if (this.get_ss("s3", "first_sleep", 1) == 0) {
		this.s1 = 0;
		this.s2 = 6;
		R.ignore_door = true;
		return;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
}


if (this.s1 == 0) {
	
	if (this.dialogue_is_on()) {
		R.attempted_door = "";
		return;
	}
	
	if (R.attempted_door != null && R.attempted_door.length > 1) {
		if (R.attempted_door == "KV_1") {
			if (this.s2 >= 2 && this.s2 <= 6) {
				this.change_map("KV_1", 8, 16, true);
				R.player.facing = 0x10;
			}
		} else if (R.attempted_door == "TRANSITIONAREATODO") {
			var _x = 34;
			var _y = 45;
			if (R.attempted_door == "name1") {
				_x = 34;
				_y = 45;
			} else if (R.attempted_door == "name2") {
			} 
			// TODO figure out if there is multiple ways to get into transition area which side to go to
			if (this.s2 >= 2 && this.s2 <= 6) {
				this.change_map(R.attempted_door, _x, _y, true);
			}
		} else { 
			if (this.s2 == 6) {
				this.dialogue("s3", "mapblocker", 0);
			} else {
				this.dialogue("s3", "mapblocker", 1);
			}
		}
		R.attempted_door = "";
	}
}