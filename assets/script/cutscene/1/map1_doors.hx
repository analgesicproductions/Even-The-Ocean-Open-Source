//{ map1_doors
//script s "cutscene/1/map1_doors.hx"
//}
if (!this.child_init) {
	this.only_visible_in_editor = true;
	this.child_init = true;
	this.s1 = -1;
	return;
}

if (this.s1 == -1) {
	this.s1 = 0;
	this.s2 = 0;
	if (this.get_ss("city", "dm1shore", 1) == 1) {
		this.door_search_and_open("SHORE_1");
	}
	if (this.get_ss("city", "dm1canyon", 1) == 1) {
		this.door_search_and_open("CANYON_1");
	}
	if (this.get_ss("city", "dm1hill", 1) == 1) {
		this.door_search_and_open("HILL_1");
	}
	if (this.get_ss("city", "dm1river", 1) == 1) {
		this.door_search_and_open("RIVER_1");
	}
	if (this.get_ss("city", "dm1woods", 1) == 1) {
		this.door_search_and_open("WOODS_1");
	}
	if (this.get_ss("city", "dm1basin", 1) == 1) {
		this.door_search_and_open("BASIN_1");
	}
	if (this.get_ss("city", "dm1mom", 1) == 1) {
		this.door_search_and_open("PARENTS_1");
	}
	if (this.get_ss("city", "dm1lopez", 1) == 1) {
		this.door_search_and_open("LOPEZ_1");
	}
}
if (this.s1 == 0 ) {
	if (R.attempted_door == "PARENTS_1") {
		if (this.get_ss("city", "dm1mom", 1) == 0) {
			R.attempted_door = ""; // only reset if havent opened, otherwise we wont get the 'cant enter msg' from the other script
			this.play_sound("clam_1.wav");
			this.set_ss("city", "dm1mom", 1, 1);
			this.door_search_and_open("PARENTS_1");
		}
	}
	if (R.attempted_door == "LOPEZ_1") {
		//this.set_ss("g2_1", "paxton", 1, 1);
		if (this.get_ss("city", "dm1lopez", 1) == 0) {
			R.attempted_door = ""; // only reset if havent opened, otherwise we wont get the 'cant enter msg' from the other script
			if (this.get_ss("g2_1", "paxton", 1) == 1) {
				this.play_sound("clam_1.wav");
				this.set_ss("city", "dm1lopez", 1, 1);
				this.door_search_and_open("LOPEZ_1");
			}
		}
	}
	if (R.attempted_door == "SHORE_1") {
		if (this.get_ss("city", "dm1shore", 1) == 0) {
			R.attempted_door = ""; // only reset if havent opened, otherwise we wont get the 'cant enter msg' from the other script
			this.play_sound("clam_1.wav");
			this.set_ss("city", "dm1shore", 1, 1);
			this.door_search_and_open("SHORE_1");
		}
	}
	if (R.attempted_door == "CANYON_1") {
		if (this.get_ss("city", "dm1canyon", 1) == 0) {
		R.attempted_door = "";
			this.play_sound("clam_1.wav");
			this.set_ss("city", "dm1canyon", 1, 1);
			this.door_search_and_open("CANYON_1");
		}
	}
	if (R.attempted_door == "HILL_1") {
		if (this.get_ss("city", "dm1hill", 1) == 0) {
			R.attempted_door = ""; 
			this.play_sound("clam_1.wav");
			this.set_ss("city", "dm1hill", 1, 1);
			this.door_search_and_open("HILL_1");
		}
	}
	if (R.attempted_door == "RIVER_1") {
		if (this.get_ss("city", "dm1river", 1) == 0) {
		R.attempted_door = "";
			this.play_sound("clam_1.wav");
			this.set_ss("city", "dm1river", 1, 1);
			this.door_search_and_open("RIVER_1");
		}
	}
	if (R.attempted_door == "WOODS_1") {
		if (this.get_ss("city", "dm1woods", 1) == 0) {
		R.attempted_door = "";
			this.play_sound("clam_1.wav");
			this.set_ss("city", "dm1woods", 1, 1);
			this.door_search_and_open("WOODS_1");
		}
	}
	if (R.attempted_door == "BASIN_1") {
		if (this.get_ss("city", "dm1basin", 1) == 0) {
		R.attempted_door = "";
			this.play_sound("clam_1.wav");
			this.set_ss("city", "dm1basin", 1, 1);
			this.door_search_and_open("BASIN_1");
		}
	}
	
	
}