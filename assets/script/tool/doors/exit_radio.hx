if (this.executing_from_player) {
	
	// EXIT RADIO
	if (1 <= R.dialogue_manager.get_scene_state_var("ending", "mayor", 1) && R.event_state[47] == 0) {
		
		// You can leave if you have the communicator
		if (R.inventory.is_item_found(30)) {
			
		} else {
			return ["!DIALOGUESTOP", "city", "misc_intro", "7"];	
		}
	} else if (1 <= R.dialogue_manager.get_scene_state_var("i2", "mayor_init", 1) && R.event_state[48] == 0) { //depths condition
		return ["!DIALOGUESTOP", "city", "misc_intro", "7"];	
	}
}
return [];