if (this.executing_from_player) {
	//R.dialogue_manager.change_scene_state_var("ending", "city_enter", 1, 1);
	if (0 == R.dialogue_manager.get_scene_state_var("ending", "city_enter", 1)) {
		return ["!DIALOGUESTOP", "city", "misc_intro", "5"];
	}
}
if (R.story_mode) {
	return ["RADIO_B2", 12*16, 25*16-18];
}
return [];