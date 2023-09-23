/* DEPRECATED 2015 11 23*/
//{ g2_1_yara
// Indoors yara house, fight scene. warps to city at night (somehow?) 
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.make_child("yara",false,"idle");
	if (this.get_ss("g2_1", "yara", 1) == 1) {
		this.set_ss("g2_1", "yara", 1, 2);
		R.player.enter_cutscene();
		R.player.animation.play("irn");
		R.player.x = this.x;
		R.player.y = this.y;
		R.TEST_STATE.skip_fade_lighten = true;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
}
var yara = this.sprites.members[0];
if (this.s1 == 0) {
	this.set_vars(yara,R.player.x + 32,R.player.y, 1);
	this.s1 = 1;
	
	R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
} else if (this.s1 == 1) {
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		R.song_helper.stop_song_changes = false;
		this.s1 = 2;
		this.dialogue("g2_1", "yara_in", 0, false);
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		R.TEST_STATE.cutscene_handle_signal(2, [0.02]);
		this.s1 = 3;
	} 
} else if (this.s1 == 3) {
	if (R.TEST_STATE.cutscene_just_finished(2)) {
		this.s1 = 4;
		this.dialogue("g2_1", "yara_in", 1, false);
	}
} else if (this.s1 == 4 && this.doff()) {
	
	R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
	this.s1 = 5;
}else if (this.s1 == 5) {
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		this.dialogue("g2_1", "yara_in", 12);
		this.s1 = 6;
	}
} else if (this.s1 == 6 && this.doff()) {
	this.s1 = 7;
	this.change_map(this.get_map("lo_res_night_normal"), 1, 1, true);
}
/* Quick ref for useful things 


// If called each frame, keeps player frozen till touching ground. Need to call pause_toggle after unless switch map
this.player_freeze_help()

this.energy_bar_move_set(false); // Hide the energy bar
this.energy_bar_move_set(true); // show the energy bar

this.dialogue(map,scene,pos,FALSE); // false will keep the energy bar hidden and player paused but
MAKE SURE TO CALL this.energy_Bar_move_set(true) after

// Pause player, make it look a certain way
R.player.enter_cutscene();
R.player.animation.play("irn");

// Stop player from moving or whatever but allow it to automove
R.player.pause_toggle(false); 
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