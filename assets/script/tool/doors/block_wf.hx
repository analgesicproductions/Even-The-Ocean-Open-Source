// blocks WF from world map if u sletp for first time in karavold
if (this.executing_from_player) {
	//this.set_ss("s3", "first_sleep", 1, 1);
	//R.dialogue_manager.change_scene_state_var("s3", "first_sleep", 1, 1);
	if (1 == R.dialogue_manager.get_scene_state_var("s3","first_sleep", 1) && 0 ==  R.dialogue_manager.get_scene_state_var("s3","last_debrief", 1) ) {
		return ["!DIALOGUESTOP", "s3", "no_wf", "0"];
	} else {
		return [];
	}
}
return [];