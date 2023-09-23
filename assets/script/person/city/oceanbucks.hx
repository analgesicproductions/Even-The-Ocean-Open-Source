//{ oceanbucks

// see randomideas.txt for list of valid codes
// located in fay rouge dungeon post-game?idk
if (!this.child_init) {
	this.child_init = true;
	this.s1 = -1;
	this.s2 = 0;
	this.make_child("yara",false,"idle");
	this.make_child("yara",false,"idle");
	//this._trace("oceanbucks debu");
	//this.set_ss("city", "oceanbucks_guy1", 1, 0);
	
	this.ignore_parent_dialogue = true;
	if (this.get_ss("city", "oceanbucks_guy1", 1) == 0) {
		this.s3 = 2;
	}
	return;
}



var sean = this.sprites.members[0];
var joni = this.sprites.members[1];
if (this.s1 == -1) {
	this.set_vars(sean, this.x + 16*8, this.y, 1);
	this.set_vars(joni, this.x + 16 * 9, this.y, 1);
	this.s1 = 0;
	if (this.get_ss("city", "dev_jail", 1) == 1) {
		sean.alpha = 0;
		joni.alpha = 0;
	}
}

if (this.s1 == 100 && this.doff()) {
	sean.velocity.x = -100;
	joni.velocity.x = -100;
	this.s1 = 0;
}

// Do stuff
if (this.s1 == 0) {
	
	
	if (this.nr_LIGHT_received > 0) {
		this.nr_LIGHT_received = 0;
		if (this.get_ss("city", "dev_jail", 1) == 0) {
			this.set_ss("city", "dev_jail", 1, 1);
			this.s1 = 100;
			this.dialogue("city", "dev_jail", 0);
			return;
		}
	}
	
	if ((this.s3 == 2 && R.player.overlaps(this)) || this.try_to_talk(0, this, true)) {
		// No bucks -> add 5
		if (this.get_ss("city", "oceanbucks_guy1", 1) == 0) {
			this.dialogue("city", "oceanbucks_guy1", 0);
			R.init_bucks();
			this.s1 = 1;
			this.s3 = 0;
			this.set_ss("city", "oceanbucks_guy1", 1, 1);
		} else {
			this.dialogue("city", "oceanbucks_guy2", 0);
			this.s1 = 2;
		}
	}
	
} else if (this.s1 == 1 && this.doff()) {
	this.s1 = 0;
	R.player.enter_main_state();
} else if (this.s1 == 2) {
	
	if (this.d_last_yn() == 1) { // enter passcode
		this.s1 = 4;
	} else if (this.d_last_yn() == 0) { // balance
		this.s1 = 3;
	} else if (this.d_last_yn() == 2) {
		this.s1 = 0;
	}
} else if (this.s1 == 3 && this.doff()) {
	this.s1 = 0;
} else if (this.s1 == 4 && this.doff()) {
	// Load passcode entry
	R.player.enter_cutscene();
	this.name_entry_on(R.dialogue_manager.lookup_sentence("city", "oceanbucks_guy2", 3));
	this.s1 = 5;
} else if (this.s1 == 5) {
	if (R.name_entry.is_done()) {
		this.name_entry_off();
		// Check if it's valid
		if (R.add_bucks(R.name_entry.returnword) > 0) {
			this.dialogue("city", "oceanbucks_guy2", 4);
		} else {
			this.dialogue("city", "oceanbucks_guy2", 5);
		}
		
		this.s1 = 1;
	}
}