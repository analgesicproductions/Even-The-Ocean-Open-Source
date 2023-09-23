// Blocks s2 gauntlets until u finish I_1
if (this.executing_from_player) {
	//R.dialogue_manager.change_scene_state_var("i_1", "gate_exit", 1, 1);
	if (1 == R.dialogue_manager.get_scene_state_var("i_1","gate_exit", 1)) {
		return [];
	} else {
		return ["!DIALOGUESTOP", "i_1", "s2_block", "0"];
	}
}
return [];