if (!this.child_init) {
	this.child_init = true;
	this.has_trigger = true;
	this.make_trigger(this.x-16, this.y, 48, 32);
	this.immovable = true;
	
	if (this.context_values[0] == 0) {
	if (this.get_ss("hill", "backyard", 1) == 1) {
		this.s1 = 1;
	}
	} else {
	if (this.get_ss("hill", "backyard", 2) == 1) {
		this.s1 = 1;
	}
		
	}
}
	//{ hill_lock
if (this.s1 == 0) {
	// set in storeroom_trigger before the transition to the inner VBT cutscene
	//this.set_ss("hill", "storeroom_outside", 1, 1);
	
	this.player_separate(this);
	if (this.try_to_talk(0, this.trigger, true)) {
		if (R.inventory.is_item_found(49)) {
			this.dialogue("hill", "backyard", 1);
			
	if (this.context_values[0] == 0) {
			this.set_ss("hill", "backyard", 1, 1);
	} else {
			this.set_ss("hill", "backyard", 2, 1);
	}
			this.s1 = 1;
		} else {
			this.dialogue("hill", "backyard", 0);
		}
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		this.alpha -= 0.05;
	}
}