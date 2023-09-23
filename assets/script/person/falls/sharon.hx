//falls_sharon
if (!this.child_init) {
	this.child_init = true;
	
	
	// SEA done
	
	//this._trace("DEBUG sharon.hx - SEA finished");
	
	//this.set_event(19);
	if (this.event(19)) {
		this.visible = false;
		this.s1 = 0;
	} else {
		this.s1 = 3;
	}
	
	if (this.context_values[0] == 1) {
		if (this.get_ss("falls", "sharon", 1) == 1) {
			this.SCRIPT_OFF = true;
			this.visible = false;
			return;
		}
		this.s1 = 10;
		this.has_trigger = true;
		this.make_trigger(this.x, this.y - 200, 32, 250);
		this.visible = false;
	}
	//coins
	//R.inventory.set_item_found(0,28);
	//R.inventory.set_item_found(0, 29);
	
	
	// sea bombs
	//R.inventory.set_item_found(0,25);
	
	//R.inventory.set_item_found(0,28,false);
	//R.inventory.set_item_found(0, 29,false);
	//R.inventory.set_item_found(0,25,false);
	
	//this._trace("falls debug");
	//this.set_ss("falls", "falls_state", 2, 1);
}


if (this.s1 == 10) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 11;
	}
} else if (this.s1 == 11) {
	if (this.player_freeze_help()) {
		this.s1 = 12;
		// ez cutscnee
	}
} else if (this.s1 == 12) {
	this.s1 = 13;
} else if (this.s1 == 13) {
	this.dialogue("falls", "sharon", 0,false);
	this.s1 = 14;
	this.alpha = 0;
	this.visible = true;
	this.scale.set(1.5, 1.5);
} else if (this.s1 == 14 && this.doff()) {
	this.alpha += 0.02;
	this.scale.x -= .5 / 50;
	this.scale.y -= .5 / 50;
	if (this.alpha >= 1) {
		this.dialogue("falls", "sharon", 1);
		this.s1 = 15;
	}
} else if (this.s1 == 15 && this.doff()) {
	this.alpha -= 0.02;
	this.scale.x += .5 / 50;
	this.scale.y += .5 / 50;
	if (this.alpha <= 0) {
		this.s1 = 20;
		this.set_ss("falls", "sharon", 1, 1);
		//R.player.enter_cutscene();
	}
} else if (this.s1== 16) { 
	if (this.doff()) {
		this.pan_camera(0, 0, 50, 0, true, false);
		R.TEST_STATE.eae.turn_on("FALLS");
		this.s1 = 17; 
		this.t_1 = 0;
	}
} else if (this.s1 == 17) {
	if (this.pan_done()) {
		this.t_1++;
		if (this.t_1 > 100) {
			this.s1 = 18;
			this.pan_camera(1, 0, 50, 0, true, false);
		}
	}
} else if (this.s1 == 18 && R.TEST_STATE.eae.is_off()) {
	this.s1 = 19;
} else if (this.s1 == 19 && this.pan_done()) {
	R.player.enter_main_state();
	this.camera_to_player(true);	
	R.player.facing = 0x0010;
	this.s1 = 20;
} 



if (this.s1 == 0) {
	
} else if (this.s1 == 3) { 
	if (this.s2 == 0) {
		if (this.doff() && this.try_to_talk(0, this)) {
			if (1 == this.get_ss("falls","falls_state",2)) {
				this.dialogue("falls", "sharon_post", 1);
				this.s2 = 10;
			} else {
							
				var dark_score = 0;
				var dark_ss = this.get_ss("falls", "npc", 1);
				if (dark_ss & 0x1 > 0) dark_score++;
				if (dark_ss & 0x10 > 0) dark_score++;
				if (dark_ss & 0x100 > 0) dark_score++;
				if (dark_ss & 0x1000 > 0) dark_score++;
				
				var light_score = 0;
				dark_ss = this.get_ss("falls", "npc", 2);
				if (dark_ss & 0x1 > 0) light_score ++;
				if (dark_ss & 0x10 > 0) light_score ++;
				if (dark_ss & 0x100 > 0) light_score ++;
				if (dark_ss & 0x1000 > 0) light_score ++;
				
				// "bring me more!"
				if (dark_score + light_score <= 1) {
					this.dialogue("falls", "sharon_post", 0);
					this.s2 = 1;
				} else {
					this.dialogue("falls", "sharon_post", 3);
					this.s2 = 2;
				}
			}
		}
	} else if (this.s2 == 1) {
		if (this.doff()) {
			this.s2 = 0;
		}
	} else if (this.s2 == 2) { // with 2 or 3 spirits, give a hinto
		if (this.doff()) {
			this.s2 = 0;
			var dark_ss = this.get_ss("falls", "npc", 1);
			if (dark_ss & 0x1 == 0) { 
				this.dialogue("falls", "sharon_post", 4);
			} else if (dark_ss & 0x10 == 0) {
				this.dialogue("falls", "sharon_post", 5);
			} else if (dark_ss & 0x100 == 0) {
				this.dialogue("falls", "sharon_post", 6);
			} else if (dark_ss & 0x1000 == 0) {
				this.dialogue("falls", "sharon_post", 7);
			}
		}
	} else if (this.s2 == 10) {
		if (this.d_last_yn() > -1) {
			if (this.d_last_yn() == 0) {
				this.s2 = 20;
			} else {
				this.s2 = 0;
			}
		}
	} else if (this.s2 == 20 && this.doff()) {
		this.s2 = 3;
			//if (R.story_mode) {
				//this.change_map("FALLS_B", 40, 48, true);
			//} else {
				//this.change_map("FALLS_G1", 12, 0, true);
			//}
		this.change_map("FALLS_SET", 1, 1, true);
	}
}