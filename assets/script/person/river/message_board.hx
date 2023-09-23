//{ river_message_board
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	this.alpha = 0;
}

if (this.s1 == 0) {
	if (this.try_to_talk(0, this, true)) {
		this.dialogue("river", "message_board",0);
		this.s1 = 1;
	}
} else if (this.s1 == 1 && this.doff()) {
	if (this.d_last_yn() > -1) {
		if (0 == this.d_last_yn()) {
			this.dialogue("river", "msg_boating");
		} else if (1 == this.d_last_yn()) {
			this.dialogue("river", "msg_farming");
		} else if (2 == this.d_last_yn()) {
			this.dialogue("river", "msg_ads");
		}
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		this.s1 = 0;
	}
}


