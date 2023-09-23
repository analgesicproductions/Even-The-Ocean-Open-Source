if (this.executing_from_player) {
	if (1 == R.dialogue_manager.get_scene_state_var("ending", "radio_end", 1)) {
		return ["!DIALOGUESTOP", "ending", "enter_tower", "1"]; // Its done... the energy
	} else if (1 == R.dialogue_manager.get_scene_state_var("ending", "mayor", 1)) {
		return ["!DIALOGUE", "ending", "enter_tower", "0"]; // intro words
	} else {
		return ["!DIALOGUESTOP", "city", "intro_aliph_home", "0"]; // Locked during RADIO DEPTHS?
	}
}
return [];