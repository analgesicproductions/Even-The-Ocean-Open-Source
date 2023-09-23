// bomb bags at end of gauntlet
if (!this.child_init) {
	this.child_init = true;
	//this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = this.context_values[0]; // 0,1,2 for earth,air,sea
	
	if (this.s2 == 0) {
		this.animation.play("earth");
	} else if (this.s2 == 1) {
		this.animation.play("air");
	} else if (this.s2 == 2) {
		this.animation.play("sea");
	}
	
	this.s3 = 0;
	// earth / air/ sea
	if (R.inventory.is_item_found(23)) {
		this.s3++;
		if (this.s2 == 0) {
			this.s1 = 10;
		}
	}
	if (R.inventory.is_item_found(24)) {
		this.s3++;
		if (this.s2 == 1) {
			this.s1 = 10;
		}
	}
	if (R.inventory.is_item_found(25)) {
		this.s3++;
		if (this.s2 == 2) {
			this.s1 = 10;
		}
	}
}

if (this.s1 == 0) {
	if (this.try_to_talk(0, this, false)) {
		this.s3++;
		this.dialogue("s3", "find_bombs", this.s3 - 1);
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		// Earth, air, sea. tese dialogues give items 23, 24, 25 respectively (The bombs)
		if (this.s2 == 0) {
			this.dialogue("s3", "find_bombs", 3);
		} else if (this.s2 == 1) {
			this.dialogue("s3", "find_bombs", 5);
		} else if (this.s2 == 2) {
			this.dialogue("s3", "find_bombs", 7);
		} 
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		if (this.s2 == 0) {
			this.change_map("EARTH_SILO_0", 49, 11, true);	
		}
		if (this.s2 == 1) {
			this.change_map("AIR_SILO_0", 50, 11, true);
		}
		if (this.s2 == 2) {
			this.change_map("SEA_SILO_0", 51, 11, true);
		}
		
		if (R.gauntlet_mode) {
			this.change_map("GM_1", 80, 13, true);
		}
		
		this.s1 = 3;
	}
}

if (this.s1 == 10) {
	if (this.try_to_talk(0, this, false)) {
		this.dialogue("s3", "find_bombs", 9);
	}
}