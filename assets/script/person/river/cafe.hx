if (this.s1 == 0) {
	if (this.try_to_talk()) {
		this.dialogue("river", "cafe_owner",0);
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (!this.dialogue_is_on()) { 
		this.s1 = 0;
	}
}