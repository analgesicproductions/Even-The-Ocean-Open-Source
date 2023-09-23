
if (this.state_1 < this.nr_LIGHT_received) {
	this.state_1 = this.nr_LIGHT_received;
	this.broadcast_tick(false);
	//this.play_anim("idle");
} else {
	// this.play_anim("flash");
}

if (this.try_to_talk(2)) {
	this.dialogue("canyon", "test");
}