if (!this.child_init) {
	this.child_init = true;
	this.s1 = -1;
	this.only_visible_in_editor = true;
	
	//this._trace("debug 2e_aliph_out");
	//this.set_scene_state("city", "mayor_intro", 1, 1);
	//this.set_scene_state("city", "city_aliph_after_mayor_intro", 1, 0);
	
	if (this.get_scene_state("city", "mayor_intro", 1) == 1 && this.get_scene_state("city", "city_aliph_after_mayor_intro", 1) == 0) {
		this.set_scene_state("city", "city_aliph_after_mayor_intro", 1, 1);
		this.s1 = 0;
	} else {
		return;
	}
	
	R.player.enter_cutscene();
	R.player.animation.play("iln");
	R.player.x = R.player.last.x = 53 * 16;
	R.player.y = R.player.last.y = 21 * 16 - R.player.height + 1;
	R.player.energy_bar.OFF = true;
}

if (this.s1 == 0) {
	this.t_1 ++;
	if (this.t_1 > 15) {
		this.s1 = 1;
		this.t_1 = 0;
		this.dialogue("city", "city_aliph_after_mayor_intro", 0);
	}
} else if (this.s1 == 1) {
	if (!this.dialogue_is_on()) {
		R.player.enter_cutscene();
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	this.t_1 ++;
	if (this.t_1 > 15) {
		this.t_1 = 0;
		R.easycutscene.start("0e_pamphlets");
		// turn off updating bc of the one frame where the energy bar could change state to move its stuff back
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	if (R.easycutscene.is_off()) {
		this.dialogue("city", "city_aliph_after_mayor_intro", 4);
		this.s1 = 4;
	}
	// go up
} else if (this.s1 == 4 && this.doff()) {
	R.player.energy_bar.OFF = false;
	this.s1 = 8;
	R.player.enter_main_state();
	R.player.facing = 0x0001;
}

