
//{ record_tester
if (!this.child_init) {
	this.child_init = true;
	
	// Make the contaner for the replay sprite
	this.make_child("test_tree");
	// Load the data
	this.init_record(this.sprites.members[0], "test", this.x, this.y);
	// set it visible
	this.set_vars(this.sprites.members[0], this.x, this.y, 1);
	this.s1 = 0;
	// set it invisibe?
	this.sprites.members[0].alpha = 0;
	return;
}

// Talk to book
if (this.s1 == 0 && this.try_to_talk(0, this, true)) {
	this.s1 = 1;
}

if (this.s1 == 1) {
	
	// update till it hits last frame and fades out
	this.update_record(this.sprites.members[0], 0);
 	if (this.record_data[0][3][0] - 1 == this.record_data[0][4][0]) {
		if (this.record_data[0][7][0] == 0) {
			this.s1 = 0;
			this.record_data[0][4][0] = 0;
		}
	}
}