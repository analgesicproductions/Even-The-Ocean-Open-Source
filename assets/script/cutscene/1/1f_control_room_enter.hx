// control room enter

if (!this.child_init) {
	this.child_init = true;
	this.has_trigger = true;
	this.make_trigger(this.x, this.y-150, 100, 200);
	this.only_visible_in_editor = true;
	// Bridge, lightning, Cassidy not visible - also send signal to barbed wire to disappear?
	if (this.get_scene_state("intro", "control_room_enter", 1) == 1) {
		this.s1 = -1;
		return;
	}
}
if (this.s1 == -1) {
	return;
}

if (this.s1 == 0) {

	if (R.player.overlaps(this.trigger)) {
		if (this.player_freeze_help()) {
			this.s1 = 1;
			this.set_scene_state("intro", "control_room_enter", 1, 1);	
			this.dialogue("intro", "control_room_enter", 0,false);
		}
	}
} else if (this.s1 == 1 && this.doff()) {
	// TrainTrigger ID, how long to wait, velocity, outvel? , stay?, wait for ret?
	this.pan_camera(0, 0, 180, 0, true, false);
	this.s1 = 2;
} else if (this.s1 == 2 && this.pan_done()) {
	this.dialogue("intro", "control_room_enter", 1,false);
	this.s1 = 3;
} else if (this.s1 == 3 && this.doff()) {
	this.pan_camera(1, 0, 180, 0, true, false);
	this.s1 = 4;
} else if (this.s1 == 4 && this.pan_done()) {
	this.dialogue("intro", "control_room_enter", 2,false);
	this.s1 = 5;
} else if (this.s1 == 5 && this.doff()) {
	this.pan_camera(2, 0, 180, 0, true, false);
	this.s1 = 6;
} else if (this.s1 == 6 && this.pan_done()) {
	this.dialogue("intro", "control_room_enter", 3);
	this.s1 = 7;
} else if (this.s1 == 7 && this.doff()) {
	this.s1 = 8;
	this.camera_to_player(true);
}




