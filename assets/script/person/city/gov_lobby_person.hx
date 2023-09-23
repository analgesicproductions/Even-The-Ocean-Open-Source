if (!this.child_init) {
	this.child_init = true;
	
	// Gov lobby secretary - maybe changes over the course of hte game
	this.s1 = 0;
}


if (this.s1 == 0) {
	if (this.try_to_talk()) {
		this.dialogue("city", "gov_lobby_person", 0);
	}
}