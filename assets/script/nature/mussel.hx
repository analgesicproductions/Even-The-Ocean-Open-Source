// Not in radius
if (this.state_1 == 0) {
	if (this.player_taxicab() < 36) {
		this.state_1 = 1;
		this.play_anim("close");
	}
} else {
	if (this.player_taxicab() >= 36) {
		this.state_1 = 0;
		this.play_anim("open");
	}
}