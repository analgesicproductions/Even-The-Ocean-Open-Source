if (this.s1 == 0) {
	// If you saw the outside scene andt alked to one person
	//this._trace("debug HILL cut_response.hx");
	//this.set_ss("hill", "storeroom_talked", 1, 0);
	//this.set_ss("hill", "storeroom_outside", 1, 1);
	//this.set_ss("hill", "storeroom_inside", 1, 1);
	//this.set_ss("hill", "storeroom_vera", 1, 0);
	
	if (this.get_scene_state("hill", "storeroom_talked", 1) == 0 && this.get_scene_state("hill", "storeroom_outside", 1) == 1) { 
		// Vera main, make Bay/Trent children
	
		this.make_child("bay_outside",false,"idle_r"); // bay 
		this.make_child("trent_outside", false, "idle_l"); // trent
	
		this.set_vars(this.sprites.members[0], this.x, this.y, 1, true);
		this.set_vars(this.sprites.members[1], this.x - 48, this.y, 1, true);
		this.sprites.members[1].scale.x = -1;
		this.sprites.members[0].scale.x = 1;
		this.x += 36;
		
		// If the inside scene finished, VBT should be idling
		if (this.get_scene_state("hill", "storeroom_inside", 1) == 1) {
			this.s1 = 10;
			this.sprites.members[0].x -= 32;
			this.sprites.members[1].x -= 32;
			if (0 == this.get_ss("hill", "storeroom_vera", 1)) {
				this.s3 = 10;
			}
		// else if the inside scene hasn't played, play it
		} else {
			this.s1 = 1;
		}
	} else {
		this.visible = false;
		this.s1 = -1;
	}
} else if (this.s1 == 1) {
	//this.camera_off();
	//this.cam_to_id(12);
			this.play_music("hill_storeroom",false);
	this.dialogue("hill", "storeroom_inside", 0);
	this.s1 = 2;
} else if (this.s1 == 2) {
	if (this.dialogue_is_on() == false) {
		this.stop_invisible_player_cutscene("HILL_4");
		this.set_scene_state("hill", "storeroom_inside", 1, 1);
		this.s1 = 3;
	}
} else if (this.s1 == 10) {
	if (this.s2 == 0) {
		if (this.s3 == 10) {
			if (R.player.x > this.x - 32) {
				this.s3 = 11;
			}
		}
		if (this.s3 == 11) {
			if (this.player_freeze_help()) {
				this.dialogue("hill", "storeroom_vera", 0);
				this.set_ss("hill", "storeroom_vera", 1, 1);
				this.s3 = 0;
				this.s2 = 1;
				return;
			} else {
				return;
			}
		}
		
		if (this.try_to_talk(0,this)) {
			this.s2 = 1;
			this.dialogue("hill", "storeroom_vera", 0);
		} else if (this.try_to_talk(0,this.sprites.members[0])){ // bay
			this.s2 = 1;
		this.sprites.members[0].scale.x = 1;
			this.dialogue("hill", "storeroom_bay", 0);
		} else if (this.try_to_talk(0, this.sprites.members[1])) { // trent
			this.s2 = 1;
		this.sprites.members[1].scale.x = 1;
			this.dialogue("hill", "storeroom_trent", 0);
		}
	} else if (this.s2 == 1) {
		if (!this.dialogue_is_on()) {
			this.s2 = 0;
			this.set_scene_state("hill", "storeroom_talked", 1, 1);
		}
	}
}