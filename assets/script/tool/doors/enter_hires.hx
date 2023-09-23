if (this.executing_from_player) {
	// Figure out later
	// see aliph_house for example
	//R.dialogue_manager.change_scene_state_var("g2_1", "debrief", 1, 1);
	if (1 == R.dialogue_manager.get_scene_state_var("g2_1","hi_res", 1)) {
		return ["!DIALOGUE", "g2_1", "cant_enter_home","2"];
	} else if (1 == R.dialogue_manager.get_scene_state_var("g2_1", "debrief", 1)) {
		return ["!DIALOGUE", "g2_1", "cant_enter_home","1"];
	} else {
		return ["!DIALOGUESTOP", "city", "misc_intro", "2"];
	}
}
return [];