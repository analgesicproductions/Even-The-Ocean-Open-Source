if (this.s1 == 0) {
	if (this.get_ss("canyon", "marble", 1) == 1) {
		
	this.s1 = 2;
	} else {
		this.only_visible_in_editor = true;
	this.s1 = 1;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		if (this.try_to_talk()) {
			this.dialogue("canyon", "tempsign", 0);
		}
	}
}