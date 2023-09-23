// -1 = Current part not done, 0 = current part done (increment counter), 1 = cutscene done (reset, cleanup)


// Convention: -1 is the condition to check whether this should run, or if it's run already and done
if (ctr == -1) {
	if (R.event_state[4] || R.PAX_PRIME_DEMO_ON) {
		return 1;
	} 
	R.song_helper.fade_to_this_song("intro_scene");
	R.player.enter_cutscene();
	R.player.animation.play("wrr");
	R.player.x =R.player.last.x = 180;
	R.player.y = R.player.last.y = 276;
	R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
	return 0;
} if (ctr == 0) {
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		R.TEST_STATE.cutscene_handle_signal(1, [0.01,this.get_title_of_map("INTRO")]);
		return 0;
	}
	return -1;
} else if (ctr == 1) {
	if (R.TEST_STATE.cutscene_just_finished(1)) {
		this.set_t_one(2);
		return 0;
	}
	return -1;
} else if (ctr == 2) {
	if (this.dec_t_one()) {
		R.TEST_STATE.cutscene_handle_signal(3, [0.01]);
		return 0;
	}
	return -1;
} else if (ctr == 3) {
	if (R.TEST_STATE.cutscene_just_finished(3)) {
		R.TEST_STATE.cutscene_handle_signal(2, [0.01]);
		this.set_t_one(2);
		return 0;
	}
	return -1;
} else if (ctr == 4) {
	if (this.dec_t_one()) {
		R.player.animation.play("wlr");
		return 0;
	}
	return -1;
} else if (ctr == 5) {
	if (R.player.animation.finished || 1) { // fix with actual wake up animation
		R.event_state[4] = true;
		R.player.enter_main_state();
		return 1;
	}
	return -1;
}
return -1;