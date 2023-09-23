if (!this.child_init) {
	this.child_init = true;
	this.make_child("vale", false, "idle"); // vale
	this.s1 = 0;
	this.only_visible_in_editor = true;
	if (1 == this.get_ss("forest", "vale_3", 1)) {
		this.SCRIPT_OFF = true;
		return;
	}
}


var vale = this.sprites.members[0];

if (this.s1 == 0) {
	this.set_vars(vale, this.x + 120, this.y, 1);
	vale.alpha = 0;
	vale.scale.x = -1;
	this.s1 = 1;
} else if (this.s1 == 1) {
	if (1 == this.get_ss("forest", "aliph_lift", 1)) {
		this.s1 = 20;
		R.player.enter_cutscene();
	}
} else if (this.s1 == 20 && this.doff()) {
	R.TEST_STATE.cutscene_handle_signal(0, [0.02]);
	this.s1 = 2;
} else if (this.s1 == 2 && R.TEST_STATE.cutscene_just_finished(0)) {
	this.s1 = 3;
} else if (this.s1 == 3 && this.doff()) {
	this.t_1++;
	if (this.t_1 > 40) {
		this.t_1 = 0;
		this.s1 = 4;
		vale.alpha = 1;
		R.player.x -= 32; R.player.last.x -= 32;
		vale.move(R.player.x - 40, R.player.y - 10);
		R.player.facing = 0x1;
		R.player.animation.play("iln");
		R.TEST_STATE.cutscene_handle_signal(2, [0.02]);
	}
} else if (this.s1 == 4 && R.TEST_STATE.cutscene_just_finished(2)) {
	this.s1 = 5;
	this.dialogue("forest", "vale_3", 6);
} else if (this.s1 == 5 && this.doff()) {
	if (this.fade_out(vale)) {
		R.player.enter_main_state();
		this.s1 = 6;
	}
} else if (this.s1 == 6) {
	
} else if (this.s1 == 7) {
	
} else if (this.s1 == 8) {
	
}