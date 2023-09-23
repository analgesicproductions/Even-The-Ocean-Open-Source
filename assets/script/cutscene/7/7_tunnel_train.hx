//{ tunnel_train

if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	this.s2 = 0;
	
	R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
	this.camera_off();
	this.cam_to_id(0);
	// turned off in TestState.update_mode_change part 1 so the energy bar doesnt appear till youre gone
	R.player.energy_bar.OFF = true;
	
	if (R.TEST_STATE.MAP_NAME == "TUNNEL_2") {
		this.s2 = 2;
	} else if (R.TEST_STATE.MAP_NAME == "TUNNEL_3") {
		this.s2 = 3;
	} else if (R.TEST_STATE.MAP_NAME == "TUNNEL_5") {
		this.s2 = 4;
	}
	//this.set_event(45);
	//this.set_event(50);
	return;
}

R.player.x = 500;
R.player.y = 300;
R.player.velocity.y = 0;

if (this.s2 == 2) {
	if (this.s1 == 0) {
		// First time
		if (this.event(45) == false) {
			this.dialogue("s3", "tunnel", 0);
			this.s1 = 1;
		// After rain starts
		} else if (this.event(50) == false) {
			this.dialogue("s3", "tunnel", 3);
			this.s1 = 2;
		// postgame
		} else {
			this.dialogue("s3", "tunnel", 4);
			this.s1 = 1;
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			if (this.d_last_yn() == 0) {
				this.s1 = 12; 
				this.dialogue("s3", "tunnel", 5);
			} else if (1 == this.d_last_yn()) {
				this.s1 = 10;
			}
		}
	} else if (this.s1 == 2) {
		if (this.doff()) {
			this.s1 = 10;
		}
	} else if (this.s1 == 10) {
			this.change_map("MAP1", 128, 111, true);
		this.s1 = 11;
	} else if (this.s1 == 12 ) {
		if (this.doff()) {
			R.easycutscene.activate("3d_tunnel_to_kv");
			this.s1 = 13;
		}
	} else if (this.s1 == 13) {
		if (R.easycutscene.ping_last) {
			if (this.get_ss("s3", "tunnel_kvside", 1) == 0) {
				this.change_map("TUNNEL_3", 5, 5, true);
			} else {
				this.change_map("MAP2", 51, 45, true);
			}
			this.s1 = 11;
		}
	}
}


// back to WF from kv (tunnel 3)
if (this.s2 == 3) {
	
	if (this.s1 == 0 && this.doff()) {
		// First time/before debrief
		if (this.get_ss("s3","last_debrief",1) == 0) {
			if (this.get_ss("s3", "tunnel_kvside",	 1) == 0) {
				this.dialogue("s3", "tunnel_kvside", 0);	 
				this.set_ss("s3", "tunnel_kvside", 1, 1);
				this.s1 = 2;
			} else {
				this.dialogue("s3", "tunnel_kvside", 4);
				this.s1 = 3;
			}
		// after final debrief
		} else {
			if (this.event(50)) {
				this.dialogue("s3", "tunnel_kvside", 5);
				this.s1 = 3;
			// postgame
			}  else {
				this.dialogue("s3", "tunnel_kvside", 2);
				this.s1 = 1;
			}
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			if (this.d_last_yn() == 0) {
				R.easycutscene.activate("3e_tunnel_to_wf");
				this.s1 = 12; 
			} else if (1 == this.d_last_yn()) {
				this.s1 = 10;
			}
		}
	} else if (this.s1 == 2) {
		if (this.doff()) {
			this.s1 = 10;
		}
	} else if (this.s1 == 3) {
		if (this.doff()) {
			if (this.d_last_yn() == 0) {
			// go to tunnel 6 (north continent exit)
				R.easycutscene.activate("3e_tunnel_to_wf");
				this.s1 = 13; 
			} else if (1 == this.d_last_yn()) {
				// try to go to WF, can't go.
				
				if (this.event(50)) {
					R.easycutscene.activate("3e_tunnel_to_wf");
					this.s1 = 12; 
				} else {
					this.s1 = 0;
					this.dialogue("s3", "tunnel_kvside", 1);
				}
			} else {
				// exit back to s continent
				this.s1 = 10;
			}
		}
	} else if (this.s1 == 10) {
		this.change_map("MAP2", 51, 45, true);
		this.s1 = 11;
	} else if (this.s1 == 12 ) {
		if (R.easycutscene.ping_last) {
			this.change_map("MAP1", 128, 111, true);
			this.s1 = 11;
		}
	} else if (this.s1 == 13) {
		if (R.easycutscene.ping_last) {
			this.change_map("MAP3", 55, 73, true);
			this.s1 = 11;
		}
	}
}

// N continent station (tunnel 5)
if (this.s2 == 4) {
	if (this.s1 == 0) {
		this.dialogue("s3", "tunnel_kvside", 3);
		this.s1 = 1;
	} else if (this.s1 == 1) {
		if (this.doff()) {
			if (this.d_last_yn() == 0) {
			// go to tunnel 4 (south continent exit)
				R.easycutscene.activate("3e_tunnel_to_wf");
				this.s1 = 12; 
			} else if (1 == this.d_last_yn()) {
				// exit to tunnel 6
				this.s1 = 13;
			}
		}
	} else if (this.s1 == 12 ) {
		if (R.easycutscene.ping_last) {
		this.change_map("MAP2", 51, 45, true);
			this.s1 = 11;
		}
	} else if (this.s1 == 13) {
			this.change_map("MAP3", 55, 73, true);
		this.s1 = 11;
	}
}
