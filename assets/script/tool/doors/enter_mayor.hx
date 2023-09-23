// Trying to enter the mayor's office from the Lighthouse lobby
if (this.executing_from_player) {
	// Can enter
	if (R.event_state[38] == 1 && 0 == R.dialogue_manager.get_scene_state_var("g2_2", "debrief", 1)) {
		return ["!DIALOGUE", "city", "gov_lobby_person_g2_2"];
	} else if (R.event_state[31] == 1 && 0 == R.dialogue_manager.get_scene_state_var("i_1", "debrief", 1)) {
		return ["!DIALOGUE", "city", "gov_lobby_person_i1"];
	} else {
		//R.dialogue_manager.change_scene_state_var("city", "intro_aliph_home", 1, 1);
		return ["!DIALOGUESTOP", "city", "gov_lobby_person", "3"];
	}
}
return [];