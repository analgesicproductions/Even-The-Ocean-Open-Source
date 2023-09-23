//{ woods_book
if (!this.child_init) {
	this.child_init = true;

	
	// Context values: 0 = ID (of the 4 books), 1 = 
	// Make the contaner for the replay sprite
	
	this.animation.play("close");
	
	if (this.context_values[1] == 1) {
		this.s1 = -69;
		// broadcast to turn things off
	} else {
		this.make_child("test_tree");
		// Load the data
		if (this.context_values[0] == 0) {
			this.init_record(this.sprites.members[0], "book1", this.x-10, this.y);
			this.set_vars(this.sprites.members[0], this.x-10, this.y, 1);
		} else if (this.context_values[0] == 1) {
			this.init_record(this.sprites.members[0], "book2", this.x-10, this.y);
			this.set_vars(this.sprites.members[0], this.x-10, this.y, 1);
		} else if (this.context_values[0] == 2) {
			this.init_record(this.sprites.members[0], "book3", this.x-10, this.y);
			this.set_vars(this.sprites.members[0], this.x-10, this.y, 1);
		} else if (this.context_values[0] == 3) {
			this.init_record(this.sprites.members[0], "book4", this.x-10, this.y);
			this.set_vars(this.sprites.members[0], this.x-10, this.y, 1);
		}
		// set it visible
		this.s1 = 0;
		// set it invisibe?
		this.sprites.members[0].alpha = 0;	
	}
	return;
}

// Talk to book
if (this.s1 == 0 && (this.try_to_talk(0, this, true) || this.nr_ENERGIZE_received > 0)) {
	this.s1 = 1;
	this.animation.play("open");
		this.play_sound("shield_md.wav");
	
	// If not activated by child
	if (this.nr_ENERGIZE_received == 0) {
		this.broadcast_to_children("energize");
		
		if (this.context_values[0] == 0) {
			if (this.get_ss("woods", "book", 1) == 0) {
				this.set_ss("woods", "book", 1, 1);
				this.dialogue("woods", "book", 0);
			}
		} else if (this.context_values[0] == 1) {
			//this.dialogue("woods", "book", 1);
		} else if (this.context_values[0] == 2) {
			//this.dialogue("woods", "book", 2);
		} else if (this.context_values[0] == 3) {
			//this.dialogue("woods", "book", 3);
		}
	} else {
		this.nr_ENERGIZE_received = 0;
	}
	this.alpha = 1;
} else if (this.s1 == 1) {
	if (this.doff()) {
		this.s1 = 2;
	}
}

if (this.s1 == 2) {
	
	this.update_record(this.sprites.members[0], 0);
	
	// if secondary book says to stop
	if (this.nr_ENERGIZE_received > 0) {
		this.nr_ENERGIZE_received = 0;
		this.record_data[0][7][0] = 2;
		this.s1 = 3;
		this.animation.play("close");
		return;
	}
	
	if (this.try_to_talk(0, this, true)) {
		this.record_data[0][7][0] = 2;
		this.s1 = 3;
		this.play_sound("shield_md.wav");
		this.animation.play("close");
		this.broadcast_to_children("energize");
	}
	
	// uncomment if u want it to update till it hits last frame and fades out
 	//if (this.record_data[0][3][0] - 1 == this.record_data[0][4][0]) {
		//if (this.record_data[0][7][0] == 0) {
			//this.s1 = 0;
			//this.record_data[0][4][0] = 0;
		//}
	//}
} else if (this.s1 == 3) {
	this.update_record(this.sprites.members[0], 0);
	if (this.record_data[0][7][0] == 0) {
		this.s1 = 0;
	}
}


// Logic for secondary books
if (this.s1 == -69) {
	if (this.try_to_talk(0, this, true)) {
		this.broadcast_to_children("energize");
		this.animation.play("open");
		this.play_sound("shield_md.wav");
		this.s1 = -70;
	}
	
	if (this.nr_ENERGIZE_received > 0) {
		this.nr_ENERGIZE_received = 0;
		this.animation.play("open");
		this.s1 = -70;
	}
} else if (this.s1 == -70) {
	// Turn off 
	if (this.nr_ENERGIZE_received > 0) {
		this.nr_ENERGIZE_received = 0;
		this.animation.play("close");
		this.s1 = -69;
	}
	if (this.try_to_talk(0, this, true)) {
		this.broadcast_to_children("energize");
		this.animation.play("close");
		this.play_sound("shield_md.wav");
		this.s1 = -69;
	}
}









