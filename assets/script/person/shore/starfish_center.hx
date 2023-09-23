if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	
	if (0 == this.get_ss("shore", "starfish_center", 1)) {
		this.s1 = 1;
		this.has_trigger = true;
		this.make_trigger(this.x-32, this.y-40, 32, 100);
	}
}

if (this.s1 == 1) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 2;
	}
	return;
} else if (this.s1 == 2) {
	if (this.player_freeze_help()) {
		this.s1 = 0;
		this.dialogue("shore", "starfish_center");
		this.set_ss("shore", "starfish_center", 1, 1);
	}
	return;
}


if (this.try_to_talk()) {
	if (R.inventory.is_item_found(10)) {
		if (R.event_state[11] >= 0x111) {	
			this.dialogue("shore", "starfish_clear",1);
		} else {
			this.dialogue("shore", "starfish_clear",0);
		}
	} else {
		this.dialogue("shore", "starfish_center");
	}
}