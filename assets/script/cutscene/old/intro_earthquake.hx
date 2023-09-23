if (ctr == -1) {
	if (R.event_state[5] || R.PAX_PRIME_DEMO_ON) {
		this.broadcast_to_children("instant_0");
		this.broadcast_to_children("instant_1");
		return 1;
	}
	// Someone talks
	if (R.player.enter_cutscene(true)) {
		this.play_dialogue("intro", "earthquake");
		R.player.animation.play("irn");
		return 0;
	}
	return -1;
} else if (ctr == 0) {
	if (this.is_dialogue_finished()) {
		this.shake(0.03, 3);
		this.set_t_one(2);
		this.broadcast_to_children("instant_0");
		this.flash(1.5, 0xffffff);
		// Play sound
		return 0;
	}
	return -1;
} else if (ctr == 1) {
	if (this.dec_t_one()) {
		
		this.play_dialogue("intro", "earthquake");
		
		return 0;
	}
	// when timer out, break some of the bridge so you the friends fall and
	// you are forced to jump down , passage to them is blocked
	// note: lots of gas where the other workers fall (to imply they die)
	return -1;
} else if (ctr == 2) {
	if (this.is_dialogue_finished()) {
		this.shake(0.05, 2);
		this.flash(1, 2);
		// Play sound
		this.broadcast_to_children("instant_1");
		R.player.enter_main_state();
		R.event_state[5] = true;
		return 1;
	}
}
return -1;