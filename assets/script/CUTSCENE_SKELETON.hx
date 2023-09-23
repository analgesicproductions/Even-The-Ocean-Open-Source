

/* Add this to generic_npc.son somewhere (make name unique) */
//{ ending_init_yara
//script s "cutscene/8/8e_yara.hx"
//}

if (!this.child_init) {
	this.child_init = true;
	
	/* Visible in editor only */
	//this.only_visible_in_editor = true;
	
	/* Initialize state variables */
	this.s1 = 0;
	this.s2 = 0;
	
	
	/* Has a trigger at (x,y) size 20x32 */
	//this.has_trigger = true;
	//this.make_trigger(this.x, this.y, 20, 32);
	//R.player.overlaps(this.trigger)
	
	/* Change state based on context values */
	//if (this.context_values[0] == 1) {
		//
	//}
	
	/* [Debug function description] */
	//this._trace("DEBUG IN 4f_paxton");
	//this.set_event(34, true, 4);
	
	/* Make sprites */
	//this.make_child("paxton",false,"idle");
	
	/* Check for event */
	//if (this.get_event(47, true) == 1 && this.get_ss("ending","init_yara",1) == 0) {
		//
	//} else {
		//this.SCRIPT_OFF = true;
		//return;
	//}
	
	/* Check for dialogue flag */
	//if (this.get_ss("ending", "yara_init", 1) == 1) {
			//
	//} else {
		//this.SCRIPT_OFF = true;
		//return;
	//}
	
}

// Assign sprites
//var paxton = this.sprites.members[0];


// Do stuff
if (this.s1 == 0) {
	
} else if (this.s1 == 1) {
	
}




/* Quick ref for useful things 


// If called each frame, keeps player frozen till touching ground. Need to call pause_toggle after unless switch map
this.player_freeze_help()

this.energy_bar_move_set(false); // Hide the energy bar
this.energy_bar_move_set(true); // show the energy bar


// talk to main gnpc
	if (this.try_to_talk(0, this, true)) } 
	{

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

		// TrainTrigger ID, how long to wait, velocity, outvel? , stay?, wait for ret?
		this.pan_camera(2, 0, spd, 0, true,false);
		this.pan_done(); // check if done
 
 */