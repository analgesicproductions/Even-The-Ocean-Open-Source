if (ctr == -1) {
	if (R.event_state[6]) {
		return 1;
	}
	R.player.enter_cutscene();
	return 0;
} else if (ctr == 0) {
	if (R.player.velocity.y < 20) {
		this.flash(2, 0xffffff);
		this.shake(0.03, 1);
		this.set_t_one(1.5);
		R.event_state[6] = true;
		R.player.change_vistype(0);
		R.player.animation.play("irn");
		return 0;
	}
	return -1;
} else if (ctr == 1) {
	if (this.dec_t_one()) {
		this.play_dialogue("introcave", "fall");
		return 0;
	}
	return -1;
} else if (ctr == 2) {
	if (this.is_dialogue_finished()) {
		R.player.enter_main_state();
		return 1;
	}
	return -1;
}
return -1;