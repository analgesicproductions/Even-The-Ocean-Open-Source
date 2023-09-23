/* DEPRECATED 2015 11 24 */
//{ i2_crowd_hastings
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	//this._trace("DEBUG 5e_crowd");
	//this.set_event(48, true);
	
	this.make_child("hastings", false, "idle");
	this.make_child("paxton",false,"idle");
	this.make_child("paxton",false,"idle");
	
	if (this.get_event(48, true) == 1 && this.get_ss("i2","crowd_hastings",1) == 0) {
		this.set_ss("i2", "crowd_hastings", 1, 1);
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	
}
var hastings = this.sprites.members[0];
var c1 = this.sprites.members[1];
var c2 = this.sprites.members[2];

// Do stuff
if (this.s1 == 0) {
	R.player.y = R.player.last.y = 12 * 16 - R.player.height + 1;
	R.player.x = R.player.last.x = 24 * 16;
	this.set_vars(hastings, R.player.x + 32, R.player.y, 1);
	this.set_vars(c1, R.player.x + 66, R.player.y, 1);
	this.set_vars(c2, R.player.x + 50, R.player.y, 1);
	this.s1 = 1;
} else if (this.s1 == 1) {
	this.t_1 ++;
	if (this.t_1 > 3) {
		this.play_music("wf_city_attack");
		this.dialogue("i2", "crowd_hastings", 0,false);
		this.s1 = 2;
	}
} else if (this.s1 == 2 && this.doff()) {
	R.player.enter_cutscene();
	R.player.pause_toggle(false); 
	R.player.animation.play("wrr");
	R.player.velocity.x = 75;
	hastings.velocity.x = 75;
	this.s1 = 3;
} else if (this.s1 == 3) {
	this.t_1 ++;
	if (this.t_1 > 45) {
		this.t_1 = 0;
		R.player.velocity.x = hastings.velocity.x = 0;
		R.player.animation.play("irn");
		this.dialogue("i2", "crowd_hastings", 1);
		this.s1 = 4;
	}
}  else if (this.s1 == 4 && this.doff()) {
	R.player.pause_toggle(false); 
	R.player.animation.play("wrr");
	R.player.velocity.x = 75;
	hastings.velocity.x = 75;
	this.s1 = 5;
	//this.change_map(this.get_map("mayor_office"), 1, 1, true);
	this.change_map("WF_GOV_MAYOR", 1, 1, true);
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