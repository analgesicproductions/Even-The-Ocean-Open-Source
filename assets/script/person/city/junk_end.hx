//{ junk_animal
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	if (this.context_values[0] == 0) {
		this.animation.play("animal_3");
	} else if (this.context_values[0] == 1) {
		this.animation.play("animal_2");
	}  else if (this.context_values[0] == 2) {
		this.animation.play("animal_1");
	} 
}

if (this.s1 == 0) {
	if (this.try_to_talk()) {
		this.s1 = 1;
		R.player.enter_cutscene();
		if (this.context_values[0] == 0) {
			this.dialogue("city", "wf_js", 7);
		} else if (this.context_values[0] == 1) {
			this.dialogue("city", "wf_jc", 7);
		}  else if (this.context_values[0] == 2) {
			this.dialogue("city", "wf_jh", 8);
		} 
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		R.player.pause_toggle(true); 
		this.change_map("WF_J", 17, 11, true);
		this.s1 = 2;
	}
}