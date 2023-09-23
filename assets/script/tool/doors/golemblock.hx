// Blocks entering pass/cliff/falls if you dont have the bombs
if (this.executing_from_player) {
	//R.dialogue_manager.change_scene_state_var("i_1", "gate_exit", 1, 1);
	
	if (this.dest_map == "PASS_1") {
		if (!R.inventory.is_item_found(23)) {
			return ["!DIALOGUESTOP", "s3", "mapblocker", "2"];
		} else {
			return [];
		}
	} else if (this.dest_map == "CLIFF_1") {
		if (!R.inventory.is_item_found(24)) {
			return ["!DIALOGUESTOP", "s3", "mapblocker", "2"];
		} else {
			return [];
		}
	} else if (this.dest_map == "FALLS_1") {
		if (!R.inventory.is_item_found(25)) {
			return ["!DIALOGUESTOP", "s3", "mapblocker", "2"];
		} else {
			return [];
		}
	}
}
return [];