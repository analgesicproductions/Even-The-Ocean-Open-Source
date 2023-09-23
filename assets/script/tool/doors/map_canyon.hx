if (this.executing_from_player) {
	// If gauntlet 1 != canyon and gauntlet 1 nto done and gauntlet 1 is chosen...
	if (R.event_state[26] != 2 && 0 == R.event_state[29] && R.event_state[26] > 0 ) {
		return ["!DIALOGUESTOP", "city", "misc_intro", "0"];
		// If gauntlet 2 not done, gauntlet 2 is chosen, and gauntlet 2 is not canyon...
	} else if (R.event_state[30] == 0 && R.event_state[27] > 0 && R.event_state[27] != 2) {
		return ["!DIALOGUESTOP", "city", "misc_intro", "0"];
	} else {
		// ignore this and run something with the normal script vars
	}
}
return [];