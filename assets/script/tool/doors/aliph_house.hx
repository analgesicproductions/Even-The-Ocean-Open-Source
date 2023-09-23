if (this.executing_from_player) {
	
	// can'tenter after this pt
	if (2 == R.dialogue_manager.get_scene_state_var("g2_1", "yara", 1)) {
		return ["!DIALOGUESTOP", "g2_1", "cant_enter_home","0"];
	} else if (1 == R.dialogue_manager.get_scene_state_var("g2_1", "hi_res", 1)) {
		return ["!DIALOGUESTOP", "g2_1", "cant_enter_home", "3"];
	// I'm home! After seeing the pamphlet stuff.
	} else if (0 == R.dialogue_manager.get_scene_state_var("city", "intro_aliph_home", 1) && 0 < R.dialogue_manager.get_scene_state_var("city", "city_aliph_after_mayor_intro", 1)) {
		R.dialogue_manager.change_scene_state_var("city", "intro_aliph_home", 1, 1);
		R.player.energy_bar.OFF = true;
		return ["!DIALOGUE", "city", "intro_aliph_home", "0"];
	} else {
	}
}
return [];