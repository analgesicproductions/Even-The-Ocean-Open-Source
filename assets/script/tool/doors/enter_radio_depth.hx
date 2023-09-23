if (this.executing_from_player) {
	if (1 == R.dialogue_manager.get_scene_state_var("ending", "city_enter", 1)) {
		return ["!DIALOGUESTOP", "city", "misc_intro", "6"];
	}
}
return [];