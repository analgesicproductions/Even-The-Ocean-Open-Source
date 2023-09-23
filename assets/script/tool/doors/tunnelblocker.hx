// blocks tunnel until u finish I2
if (this.executing_from_player) {
	//R.dialogue_manager.change_scene_state_var("i2", "yara", 1, 1);	
	if (0 < R.dialogue_manager.get_scene_state_var("s3", "map1_tunnel_vis", 1)) {
		return [];
	} else {
		return ["!STOP"];
	}
}
return [];