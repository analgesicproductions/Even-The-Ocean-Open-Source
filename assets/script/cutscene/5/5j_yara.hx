/* deprecated */
//{ i2_yara

if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	//this._trace("DEBUG 5j_yara");
	//this.set_ss("i2", "humus_jail", 1, 1);
	
	this.make_child("yara",false,"idle");
	if (this.get_ss("i2","humus_jail",1) == 1 && this.get_ss("i2","yara",1) == 0) {
		this.set_ss("i2", "yara", 1, 1);
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	R.player.enter_main_state();
	R.player.pause_toggle(true);
}

var yara = this.sprites.members[0];
if (this.s1 == 0) {
	this.play_music("yara_sad");
	R.player.enter_cutscene();
	R.player.animation.play("irn");
	this.set_vars(yara, this.x + 16, this.y + 16, 1);
	R.player.x = yara.x - 32;
	R.player.y = yara.y;
	this.s1 = 1;
} else if (this.s1 == 1) {
	this.t_1++;
	if (this.t_1 > 10) {
		this.t_1 = 0;
		this.dialogue("i2", "yara", 0,false);
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	this.t_1 ++;
	if (this.t_1 > 60 * 1) {
		
		R.player.energy_bar.set_energy(128);
		this.change_map("WF_YARA", 15, 11, true);
		this.s1 = 4;
		this.energy_bar_move_set(true);
		R.player.energy_bar.force_hide = false;
		R.there_is_a_cutscene_running = false;
	}
}




/* Quick ref for useful things 


// If called each frame, keeps player frozen till touching ground. Need to call pause_toggle after unless switch map
this.player_freeze_help()

this.energy_bar_move_set(false); // Hide the energy bar
this.energy_bar_move_set(true); // show the energy bar


R.player.enter_cutscene(); // freze player movements

R.player.pause_toggle(false); // Stop player from moving or whatever but allow it to automove
R.player.animation.play("wln");
R.player.velocity.x = -75;


		this.camera_off();
this.cam_to_id(0); // Instantly snap camera to this ID and unfollow player
 this.camera_edge(true, false, true, false); // Get left camera edge x coordinate

this.start_invisible_player_cutscene("NPC_HILL", 387, 69,true); // set false if you dont want to warp back to original pos somehow
this.stop_invisible_player_cutscene("WF_LO_1", 1, 1);

this.change_map("WF_SQUARE", 1, 1, true); // Warp to specified map with tile coords
this.change_map(this.get_map("passboulder"), R.player.x, R.player.y);  // Warp to map set in generic_npc.son under "important_maps"

this.set_event(34, true, 4); // Set to '4'
this.set_event(34, true); // Set to 'true'

this.play_music("wf_after_tower", false); // Set to true if you want instant

 R.song_helper.stop_song_changes = true; // Don't let the game change songs
 
this.set_vars(yara, this.x + 32, this.y, 1);
 
 */