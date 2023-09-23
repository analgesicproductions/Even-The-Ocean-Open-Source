
if (this.try_to_talk()) {
	if (this.times_scene_played("shore", "starfish_center") > 0) {
		this.dialogue("shore", "clariseed_observer");
	} else {
		this.dialogue("shore", "clariseed_observer", 0);
	}
}