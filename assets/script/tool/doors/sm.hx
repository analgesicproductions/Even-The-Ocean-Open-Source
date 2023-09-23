//storymode
if (this.executing_from_player) {
	//R.story_mode = true;
	if (R.story_mode) {
		if (this.dest_map == "ROUGE_G1") {
			return ["ROUGE_B", 19 * 16, 18 * 16 - 18];
			
		// fIRST SET: warp to before pax/lop stuff
		} else if (this.dest_map == "SHORE_G1") {
			return ["SHORE_B", 8 * 16, 13* 16 - 18];
		} else if (this.dest_map == "CANYON_G1") {
			return ["CANYON_B", 4*16, 16*16-18];
		} else if (this.dest_map == "HILL_G1") {
			return ["HILL_B", 4 * 16, 34 * 16 - 18];
			
		// second set: warp to before possible pax death
		} else if (this.dest_map == "RIVER_G1") {
			return ["RIVER_B", 28 * 16, 9 * 16 - 18];
		} else if (this.dest_map == "WOODS_G1") {
			return ["WOODS_B", 89*16, 4*16-18];
		} else if (this.dest_map == "BASIN_G1") {
			return ["BASIN_B", 5 * 16, 12 * 16 - 18];
		
		// radio depths warp to console
		} else if (this.dest_map == "RADIO_DB") {
			return ["RADIO_DB", 46 * 16, 13 * 16 - 18];
			
		// Silos are in siloblock.hx
			
		// warp to before bomb planting
		// picnic.hx in pass
		// cactus.hx for cliff
		// rotate.hx for falls
		
		// Radio is in enter_radio_climb.hx
		} else {
			
		}
	}	
}
return [];