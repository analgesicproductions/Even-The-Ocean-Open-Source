//silo_placer
// has three children
if (!this.child_init) {
	//this.only_visible_in_editor = true;
	this.alpha = 0;
	this.child_init = true;
	//this.only_visible_in_editor = true;
	//this._trace("DEBUG 7_silo_placer - adding maps to inventory!!");
	
	
	//this._trace(R.ignore_door);
	//this._trace(R.ok_doors);
	//this.set_ss("s3", "first_sleep", 1, 1);
	//R.inventory.set_item_found(0, 19, true);
	//R.inventory.set_item_found(0, 20, true);
	//R.inventory.set_item_found(0, 21, true);
	//Rasdsa.gs1 = 245;
	
	
	//this._trace("DEBUG 7_silo_placer - adding maps to inventory!!");
			//this.set_ss("s3", "air_silo_vis", 1, 1);
			//this.set_ss("s3", "sea_silo_vis", 1, 1);
			//this.set_ss("s3", "earth_silo_vis", 1, 1);
	
	this.s1 = -1;
	
	if (this.context_values[0] == 0) {
		// position the doors, shld be 64x64
		this.children[0].x = R.silo_coords.get("earth_door_pt").x;
		this.children[0].y = R.silo_coords.get("earth_door_pt").y;
		this.make_child("silos",false,"earth");
	} else {
		this.children[0].x = R.silo_coords.get("sea_door_pt").x;
		this.children[0].y = R.silo_coords.get("sea_door_pt").y;
		this.children[1].x = R.silo_coords.get("air_door_pt").x;
		this.children[1].y = R.silo_coords.get("air_door_pt").y;
		this.make_child("silos",false,"sea");
		this.make_child("silos",false,"air");
	}
	
	return;
}

var earth = this.sprites.members[0];
var air = null;
var sea = null;

if (this.context_values[0] == 1) {
	sea = this.sprites.members[0];
	air = this.sprites.members[1];
	if (!R.editor.editor_active) {
		this.player_separate(air, R.worldmapplayer);
		this.player_separate(sea, R.worldmapplayer);
	}
} else {
	if (!R.editor.editor_active) {
		this.player_separate(earth, R.worldmapplayer);
	}
}

if (this.s1 == -1) {
	this.s1 = 0;
	if (this.context_values[0] == 0) {
		// position the silos
		this.set_vars(earth, this.children[0].x + 40 - earth.width/2, this.children[0].y+ 40 - earth.height/2, 0, true);
		earth.ix = earth.x; earth.iy = earth.y;
	} else { 
		this.set_vars(sea, this.children[0].x + 40 - sea.width/2, this.children[0].y+ 40 - sea.height/2, 0, true);
		this.set_vars(air, this.children[1].x + 40 - air.width/2, this.children[1].y+ 40 - air.height/2 , 0, true);
		sea.ix = sea.x; sea.iy = sea.y;
		air.ix = air.x; air.iy = air.y;
	}
	
	if (this.context_values[0] == 0) {
		if (this.get_ss("s3", "earth_silo_vis", 1) == 1) {
			earth.alpha = 1;
			this.children[0].behavior_to_open();
		}
	} else {
		if (this.get_ss("s3", "sea_silo_vis", 1) == 1) {
			sea.alpha = 1;
			this.children[0].behavior_to_open();
		}
		if (this.get_ss("s3", "air_silo_vis", 1) == 1) {
			air.alpha = 1;
			this.children[1].behavior_to_open();
		}
	}
	
	var last = R.TEST_STATE.prev_map_name;
	//this._trace(last);
	if (this.context_values[0] == 0) {
		if (last == "EARTH_SILO_0") {
			R.worldmapplayer.move(this.children[0].x+32, this.children[0].y+32);
		}
	} else {
		if (last == "SEA_SILO_0") {
			R.worldmapplayer.move(this.children[0].x+32, this.children[0].y+32);
		} else if (last == "AIR_SILO_0") {
			R.worldmapplayer.move(this.children[1].x+32, this.children[1].y+32);
		}
	}
	R.worldmapplayer.last.x = R.worldmapplayer.x;
	R.worldmapplayer.y += 16;
	R.worldmapplayer.last.y = R.worldmapplayer.y;
}
if (this.s1 == 0 ) {
		//this._trace(R.attempted_door);
	if (R.attempted_door == "EARTH_SILO_0") {
		R.attempted_door = "";
		if (this.get_ss("s3","earth_silo_vis",1) == 0) {
			this.play_sound("clam_1.wav");
			this.set_ss("s3", "earth_silo_vis", 1, 1);
			this.children[0].behavior_to_open();
			this.s1 = 1;
		}
	}
	if (R.attempted_door == "AIR_SILO_0") {
		R.attempted_door = "";
		if (this.get_ss("s3","air_silo_vis",1) == 0) {
			this.play_sound("clam_1.wav");
			this.set_ss("s3", "air_silo_vis", 1, 1);
			this.children[1].behavior_to_open();
			this.s1 = 2;
		}
	}
	if (R.attempted_door == "SEA_SILO_0") {
		R.attempted_door = "";
		
		if (this.get_ss("s3", "sea_silo_vis", 1) == 0) {
			this.play_sound("clam_1.wav");
			this.set_ss("s3", "sea_silo_vis", 1, 1);
			this.children[0].behavior_to_open();
			this.s1 = 3;
		}
	}
}
if (this.s1 == 1) {
	if (this.fade_in(earth)) {
		this.s1 = 0;
		this.children[0].behavior_to_open();
	}
}
if (this.s1 == 2) {
	if (this.fade_in(air)) {
		this.s1 = 0;
		this.children[1].behavior_to_open();
	}
}
if (this.s1 == 3) {
	
	if (this.context_values[0] == 1) {
		if (this.fade_in(sea)) {
			this.s1 = 0;
			this.children[0].behavior_to_open();
		}
	}
}

// seapk to door - set attempted door to something xxx
// pick it up here - fades in sprite, sets dialogue state, send signal to door to change
// when reloading, if dialogue is set, sprite is faded in, send signal to door to change