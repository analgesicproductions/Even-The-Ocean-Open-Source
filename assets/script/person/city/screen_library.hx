//{ screen_library
//script s "person/city/screen_library.hx"
//}

if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	// 7 Modes - intro, then the other 6
	//this._trace("wf_library DEBUG");
	//this.set_event(29);
	//this.set_event(37,false);
	// testing donation
	//this.set_event(37);
	
	
	//this.set_ss("city", "lib_talk_g1_1_first", 1, 0);
	
	// Gauntlets
	//for (i in [9, 12, 13, 15, 14, 16]) {
		//this.set_event(i);
	//}
	
	R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
	
	//this.set_event(39,false);
	//this.set_event(39);
	
	return;
}

if (this.s1 == 0) {
	this.camera_off();
	this.cam_to_id(0);
	this.s1 = 1;
	R.player.energy_bar.toggle_bar(false, false);
	// turned off in TestState.update_mode_change part 1 so the energy bar doesnt appear till youre gone
	R.player.energy_bar.OFF = true;
}
if (this.s1 == 2) {
	R.player.energy_bar.force_hide = false;
	this.change_map("WF_TRAIN_LO", 0, 0, true);
	this.s1 = 3;
}

R.player.x = 500;
R.player.y = 300;
R.player.velocity.y = 0;


if (this.s1 == 1) {
	if (this.s2 == 0) {
		// Choices 
		if (this.doff()) {
			this.dialogue("city", "lib_intro", 1);
			this.s2 = 1;
		}
	} else if (this.s2 == 1) { // Act on the first choice
		if (this.doff()) {
			if (this.d_last_yn() == 0) { // leave
				this.s1 = 2;
			} else if (this.d_last_yn() == 1) { // play nate dialogue depending on state
				this.s2 = 2;
				if (this.event(39)) {
					this.dialogue("city", "lib_talk_g2_3", 0);
					this.set_ss("city", "lib_talk_g2_3", 1, 1);
				} else if (this.event(38)) {
					this.dialogue("city", "lib_talk_g2_2", 0);
					this.set_ss("city", "lib_talk_g2_2", 1, 1);
				} else if (this.event(37)) {
					this.dialogue("city", "lib_talk_g2_1", 0);
					if (this.get_ss("city", "lib_talk_g2_1", 1) == 0) {
						this.set_ss("city", "lib_talk_g2_1", 1, 1);
					}
				} else if (this.event(31)) {
					this.dialogue("city", "lib_talk_g1_3", 0);
					this.set_ss("city", "lib_talk_g1_3", 1, 1);
				} else if (this.event(30)) {
					this.dialogue("city", "lib_talk_g1_2", 0);
					this.set_ss("city", "lib_talk_g1_2", 1, 1);
				} else {
					this.dialogue("city", "lib_talk_g1_1_first", 0);
				}
			} else if (this.d_last_yn() == 2) { // book choices, only shows if 'lib_talk_g1_1_first' is read.
				this.s2 = 3;
				this.dialogue("city", "lib_intro", 2);
				this.parent_state.dialogue_box.yesno_no_leave = 0;
			} else if (this.d_last_yn() == 3) { // Donations
				if (this.get_ss("city", "lib_donate", 1) == 2) {
					this.dialogue("city", "lib_donate", 0);
				} else {
					this.dialogue("city", "lib_donate", 1);
				}
				this.s2 = 2;
			} else {
				this.s1 = 2;
			}
		}
	} else if (this.s2 == 2) {
		if (this.doff()) {
			this.s2 = 0;
			R.achv.unlock(R.achv.library);
		}
	} else if (this.s2 == 3) { // Book choices
		if (this.d_last_yn() != -1) {
			if (this.d_last_yn() == 0) { // Never Mind
				this.s2 = 0;
			} else if (this.d_last_yn() > 0) { 
				var i = this.huhgauntlets(this.d_last_yn() - 1); //sch rw(fb) (Shore, etc)
				this.s2 = 4;
				//R.player.enter_cutscene();
				//public function add_sprite(filename:String, w:Int, h:Int, fidx:Int,x:Float,y:Float):Void {
				if (i == 9) {
					R.infopage.activate("city", "lib_books", 0, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
				} else if (i == 12) {
					R.infopage.activate("city", "lib_books", 1, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
				}else if (i == 13) {
					R.infopage.activate("city", "lib_books", 2, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
				}else if (i == 15) {
					R.infopage.activate("city", "lib_books", 3, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
				}else if (i == 14) {
					R.infopage.activate("city", "lib_books", 4, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
				}else if (i == 16) {
					R.infopage.activate("city", "lib_books", 5, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
				}
			}
		}
	} else if (this.s2 == 4) {
		if (R.infopage.is_off()) {
			this.s2 = 3;
			R.TEST_STATE.dialogue_box.last_yn = -1; // So the above state doesn't choose till you do
			R.TEST_STATE.dialogue_box.mode = 6; // Change mode out of info page
			//R.player.enter_main_state();
			this.dialogue("city", "lib_intro", 2);
			this.parent_state.dialogue_box.yesno_no_leave = 0;
		}
	}
}
