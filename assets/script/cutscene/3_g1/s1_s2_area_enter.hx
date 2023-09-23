//{ s1_s2_area_enter
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.has_trigger = true;
	this.make_trigger(this.x, this.y, 20, 160);
	
	
	//this._trace("DEBUG 3_g1/s1_s2_area_enter");
	//this.set_event(49, false);
	
	//private function set_event(id:Int, on:Bool = true, val:Int = -100):Void {
	//var a:Array<String> = ["SHORE_1", "CANYON_1", "HILL_1", "RIVER_1", "WOODS_1", "FOREST_1", "PASS_1", "CLIFF_1", "FALLS_1"];
	
	//public static inline var area_enter_states:Int = 49; 
	var c = this.context_values[0];
	if (c > 0 && (1 << c) & R.event_state[49] == 0) {
		//this._trace("on");
		if (c > 6) {
			this.s1 = 100;
		}
	} else {
		this.s1 = -10230;
	}
}


if (this.s1 == 100) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 200;
	}
} else if (this.s1 == 200) {
	if (this.player_freeze_help()) {
		R.player.energy_bar.OFF = true;
		if (this.context_values[0] == 7) {
			this.dialogue("pass", "golem_enter", 0);
		} else if (this.context_values[0] == 8) {
			this.dialogue("cliff", "aliph_alone", 0);
		} else if (this.context_values[0] == 9) { // falls
			this.dialogue("pass", "golem_enter", 1);
		} 
		this.s1 = 101;
	}
} else if (this.s1 == 101) {
	if (this.doff()) {
		
		R.player.pause_toggle(true);
		if (this.context_values[0] == 7) {
			R.easycutscene.activate("3i_earthgeome");
		} else if (this.context_values[0] == 8) {
			R.easycutscene.activate("3j_airgeome");
		} else if (this.context_values[0] == 9) { // falls
			R.easycutscene.activate("3k_seageome");
		} 
		this.s1 = 102;
	}
} else if (this.s1 == 102 && R.easycutscene.is_off()) {
	this.nr_LIGHT_received = 1;
	this.s1 = 30;
	this.s2 = 10;
	return;
}

if (this.s1 == 0) {
	// sent from mayor checkin
	if (this.nr_LIGHT_received > 0) {
		R.player.enter_cutscene();
		//this.energy_bar_move_set(false,true);
		//R.player.animation.play("irn");
		//R.player.facing = 0x10;
		this.camera_off();
		//this.cam_to_id(10);
		this.pan_camera(11, 0, 40, 0, true, false);
		this.s1 = 10;
	}
} else if (this.s1 == 10 && this.pan_done()) {
	this.pan_camera(10, 0, 50, 0, true, false);
	this.s1 = 1;
} else if (this.s1 == 1) {
	this.t_1 ++;
	//this._trace(this.t_1);
	if (R.speed_opts[0]) this.t_1 = 121;
	if (this.t_1  > 120) {
		this.t_1 = 0;
		if (this.context_values[0] == 1) {
			R.TEST_STATE.eae.turn_on("SHORE");
		} else if (this.context_values[0] == 2) {
			R.TEST_STATE.eae.turn_on("CANYON");
		} else if (this.context_values[0] == 3) {
			R.TEST_STATE.eae.turn_on("HILL");
		} else if (this.context_values[0] == 4) {
			R.TEST_STATE.eae.turn_on("RIVER");
		} else if (this.context_values[0] == 5) {
			R.TEST_STATE.eae.turn_on("WOODS");
		} else if (this.context_values[0] == 6) {
			R.TEST_STATE.eae.turn_on("BASIN");
		} else if (this.context_values[0] == 7) {
			R.TEST_STATE.eae.turn_on("PASS");
		}else if (this.context_values[0] == 8) {
			R.TEST_STATE.eae.turn_on("CLIFF");
		}else if (this.context_values[0] == 9) {
			R.TEST_STATE.eae.turn_on("FALLS");
		}
		this.s1 = 2;
	}
} else if (this.s1 == 2 && this.pan_done()) {
	this.t_1 ++;
	if (R.speed_opts[0]) this.t_1 = 121;
	if (this.t_1 > 120) { 
		this.t_1 = 0;
		// TrainTrigger ID, how long to wait, velocity, outvel? , stay?, wait for ret?
		//this.pan_camera(11, 0, 65, 0, true, false);
		this.s1 = 3;
		this.pan_camera(11, 0, 130, 0, true, false);
	}
} else if (this.s1 == 3) {
	if (R.TEST_STATE.eae.is_off()) {
		this.s1 = 30;
	}
} else if (this.s1 == 30 && this.pan_done()) {
	if (this.s2 != 10) this.camera_to_player(true);
		R.player.energy_bar.OFF = false;
	this.s1 = 4;
	R.player.enter_main_state(); // calls pause toggle
	R.player.touching = 0x1000;
	this.energy_bar_move_set(true);
	R.there_is_a_cutscene_running = false;
//public function set_flag_bitwise(i:Int, val:Int,unset:Bool=false):Void {
	//EF.set_flag(i, event_state, event_state[i] | val);
	R.set_flag_bitwise(49, 1 << this.context_values[0]);
	
	//ucncomment gives glitch
	//R.player.energy_bar.dont_move_cutscene_bars = false;
} else if (this.s1 == 4) {
	
}