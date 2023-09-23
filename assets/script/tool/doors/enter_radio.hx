if (this.executing_from_player) {

	
	// Can enter after fighting the mayor but before finishing radio tower.
	if (1 <= R.dialogue_manager.get_scene_state_var("ending", "mayor", 1) && R.event_state[47] == 0) {
		

	// Can enter after debriefing with the mayor, but before beating depths.
	} else if (1 <= R.dialogue_manager.get_scene_state_var("i2", "mayor_init", 1) && R.event_state[48] == 0) { //depths condition
		
	} else {
		if (R.event_state[48] == 0) {
			return ["!EASYCUT", "city", "misc_intro", "0","0h_radiolook"];	
		} else {
			return ["!DIALOGUESTOP", "city", "misc_intro", "0"];	
		}
	}
}
return [];