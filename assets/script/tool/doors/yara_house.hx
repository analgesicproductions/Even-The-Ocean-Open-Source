// Trying to enter yara's house
// Yara stands in the garden after g1_3 and g2_1, and then inside of the house
// idles in garden after g1_1 and g1_2 AFTER the cutscenes? TODO!!
if (this.executing_from_player) {
	//R.dialogue_manager.change_scene_state_var("city", "intro_yara", 1, 1);
	
	//R.dialogue_manager.change_scene_state_var("g2_1", "yara", 1, 2);
	//R.dialogue_manager.change_scene_state_var("i2", "yara", 1, 0);
	
	// After fighting after g2_1, but before making up in Intermission 2, can't go in house
	if (1 <= R.dialogue_manager.get_scene_state_var("g2_1", "yara", 1) && 0 == R.dialogue_manager.get_scene_state_var("i2", "yara", 1)) {
		return ["!DIALOGUESTOP", "city", "misc_intro", "4"];
	} else if (1 == R.dialogue_manager.get_scene_state_var("city", "intro_yara", 1)) {
		return ["!DIALOGUESTOP", "city", "misc_intro", "8"];
	} else {
		// All the way up to the end of the Intro stuff ("give her some space!") - can't go in house
		return ["!DIALOGUESTOP", "city", "misc_intro", "3"];
	}
}
return [];