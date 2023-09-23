//  BLocks entering silos after u get bombs
if (this.executing_from_player) {
	//R.dialogue_manager.change_scene_state_var("i_1", "gate_exit", 1, 1);
	
	
	if (R.TEST_STATE.MAP_NAME == "EARTH_SILO_0") {
		if (R.inventory.is_item_found(23)) {
			return ["!DIALOGUESTOP", "s3", "silo_door_block", "0"];
		} else {
			if (R.story_mode) {
				return ["EARTH_SILO_2B", 99*16,67*16-18];
			}
			return [];
		}
	} else if (R.TEST_STATE.MAP_NAME == "AIR_SILO_0") {
		if (R.inventory.is_item_found(24)) {
			return ["!DIALOGUESTOP", "s3", "silo_door_block", "0"];
		} else {
			if (R.story_mode) {
				return ["AIR_SILO_2", 150*16, 72*16-18];
			}
			return [];
		}
	} else if (R.TEST_STATE.MAP_NAME == "SEA_SILO_0") {
		if (R.inventory.is_item_found(25)) {
			return ["!DIALOGUESTOP", "s3", "silo_door_block", "0"];
		} else {
			if (R.story_mode) {
				return ["SEA_SILO_2", 70 * 16, 59 * 16 - 18];
			}
			return [];
		}
	}
}
return [];