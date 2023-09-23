if (!this.child_init) {
	this.child_init = true;
	
	
	// DEBUG
	//this.set_event(46, false);
	//R.inventory.set_item_found(0, 22, true);
	
	// DEBUG the big geyser thing
	//R.set_flag_bitwise(46, 0x001);
	//R.set_flag_bitwise(46, 0x010);
	//R.set_flag_bitwise(46, 0x100);
	
	// CROWBAR = 22
	if (R.inventory.is_item_found(22)) {
	//public static inline var pass_geysers:Int = 46;
		var e = this.get_event_state(46, true);
		var nr_pushes = 0;
		if (e & 0x001 > 0) nr_pushes ++;
		if (e & 0x0010 > 0) nr_pushes ++;
		if (e & 0x00100 > 0) nr_pushes ++;
		
		if (this.context_values[0] == 0) {
			if (e & 0x001 > 0) {
				this.s1 = 2;
			} else {
				
			}
		} else if (this.context_values[0] == 1) {
			if (e & 0x010 > 0) {
				this.s1 = 2;
			}
		} else if (this.context_values[0] == 2) {
			if (e & 0x100 > 0) {
				this.s1 = 2;
			}
		}
		// Wait to be moved
		if (this.s1 != 2) {
			this.s1 = 1;
			for (i in [1, 2]) {
				if (nr_pushes >= i) {
					this.broadcast_to_children("PUSH");	 
				}
			}
		// Mvoe and broadcast
		} else {
			this.x += this.width; 
			// Sigal geyser
			this.broadcast_tick(false);
		}
	} else {
		this.s1 = 0;
	}
}

if (this.s1 == 0) {
	
	if (R.inventory.is_item_found(22)) {
		this.s1 = 1;
	}
	if (this.try_to_talk()) {
		this.dialogue("pass", "boulder", 0);
	}
} else if (this.s1 == 1) { // interact to lift boulder
	if (this.s2 == 0) {
		if (this.try_to_talk()) {
			this.s2 = 10;
			if (0 == this.get_event_state(46, true)) {
				this.dialogue("pass", "boulder", 1);
			} else if (this.get_event_state(46, true) == 0x110 || this.get_event_state(46, true) == 0x101 || this.get_event_state(46, true) == 0x011) {
				this.dialogue("pass", "boulder", 3);
			}
		}
	} else if (this.s2 == 10 && this.doff()) {
		this.s2 = 1;
		this.dialogue("pass", "boulder", 2);
	} else if (this.s2 == 1) {
		if (this.doff()) {
			if (this.context_values[0] == 0) {
				R.set_flag_bitwise(46, 0x001);
			} else if (this.context_values[0] == 1) {
				R.set_flag_bitwise(46, 0x010);
			} else if (this.context_values[0] == 2) {
				R.set_flag_bitwise(46, 0x100);
			}
			this.s2 = 2;
		}
	} else if (this.s2 == 2) {
		// Change maps so that our canges are reflected
		if (this.doff()) {
			R.player.enter_cutscene();
			this.change_map("PASS_2", R.player.x, R.player.y);
			this.s2 = 3;
		}
	}
} else if (this.s1 == 2) { // Do nothing b/c already pushed
	if (this.try_to_talk()) {
		this.dialogue("pass", "boulder", 0);
	}
}

