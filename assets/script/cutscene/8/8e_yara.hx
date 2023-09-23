
if (!this.child_init) {
	this.child_init = true;
	
	this.only_visible_in_editor = true;
	
	this.s1 = 0;
	this.s2 = 0;
	
	//this._trace("DEBUG IN 8e_yara");
	//this.set_event(47, true);
	//this.set_event(18 , true);// air done, for alt bgs to trigger
	
	
	this.make_child("yara",false,"idle");
	
	// finished radio tower = 47
	if (this.get_event(47, true) == 1 && this.get_ss("ending","init_yara",1) == 0) {
		R.song_helper.permanent_song_name = R.song_helper.permanent_song_name.substr(0, 0);
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
}

var yara = this.sprites.members[0];


// Do stuff
if (this.s1 == 0) {
	
	this.set_vars(yara, this.x + 32, this.y, 1);
	//this.cam_to_id(0);
	// Move camera to yara.
	//R.player.x = this.camera_edge(true, false, true) + 24;
	//R.player.y = this.camera_edge(false, true, true) + 128;
	//this.energy_bar_move_set(false); 
	//aliph is offscreen. 
	
	this.cam_to_id(1);
		R.player.enter_cutscene();
	this.s1 = 100;
	this.t_1 = 0;
	
} else if (this.s1 == 100) {
	this.t_1++;
	if (this.t_1 >= 30) {
	//if (this.try_to_talk(0, yara, false)) {
		// Activate ending, so use speedrul vals to do stuff here
		R.achv.speedrunCheck();
		R.player.enter_cutscene();
		R.player.pause_toggle(false); // Stop player from moving or whatever but allow it to automove
		//R.player.animation.play("wrr");
		R.player.animation.play("irn");
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	// Maybe wait?
	//R.player.velocity.x = 85;
	
	//move aliph in. 
	//if (R.player.x > yara.x - 32) {
		//yara talks. 
		//R.player.velocity.x = 0;
		this.dialogue("ending", "init_yara", 0,false);
		this.s1 = 2;
	//}
} else if (this.s1 == 2) {
	// Todo: idk
	//fade in horizon view of flooding. 
	if (this.doff()) {
		this.s1 = 11;
	}
} else if (this.s1 == 10) {
	//this.play_music("rain",false); // sound of flooding starts
	//this.s1 = 11;
	//more dialogue. 
	//this.dialogue("ending", "init_yara", 6,false);
} else if (this.s1 == 11 && this.doff()) {
	//Set state and warp to flood scene (8f)
	this.set_ss("ending", "init_yara", 1, 1);
	this.start_invisible_player_cutscene("MAP3", 0, 0, true);
	this.s1 = 12;
}
