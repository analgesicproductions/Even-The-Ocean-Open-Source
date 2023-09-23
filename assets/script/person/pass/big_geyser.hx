if (!this.child_init) {
	this.child_init = true;
	
	this.only_visible_in_editor = true;
	// Turns  off the big geyser if conditions not met
	if (this.get_event_state(46, true) == 0x111) {
		if (this.get_ss("pass", "boulder", 1) == 0) {
			this.set_ss("pass", "boulder", 1, 1);
			this.s1 = 1;
		} 
	} else {
		//this.broadcast_tick(false);
	}
	
	var e = this.get_event_state(46, true);
	var nr_pushes = 0;
	if (e & 0x001 > 0) nr_pushes ++;
	if (e & 0x0010 > 0) nr_pushes ++;
	if (e & 0x00100 > 0) nr_pushes ++;
	for (i in [1, 2, 3]) {
		if (nr_pushes >= i) {
			this.broadcast_to_children("PUSH");	 
			this.broadcast_to_children("PUSH");	 
		}
	}
	
	
}