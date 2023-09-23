// Blocks s2 gauntlets until u finish I_1
if (this.executing_from_player && R.TEST_STATE.dialogue_box.is_active() == false) {
	if (1 == R.dialogue_manager.get_scene_state_var("s3", "tunnel_block", 1)) {
		return [];
	} else if (true == R.inventory.is_item_found(26)) {
		R.dialogue_manager.change_scene_state_var("s3", "tunnel_block", 1, 1);
		return ["!DIALOGUE", "s3", "tunnel_block", "1"];
	} else {
		//R.inventory.set_item_found(0, 26, true);
		return ["!DIALOGUESTOP", "s3", "tunnel_block", "0"];
	}
}
return ["!STOP"];