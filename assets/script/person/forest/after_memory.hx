if (!this.child_init) { 
	this.child_init = true;
	this.make_child("forest_memory_npc",false,"dolly"); // Dolly 
	this.make_child("forest_memory_npc",false,"tracy"); // Tracy
}	

var dolly = this.sprites.members[0];
var tracy = this.sprites.members[1];


if (this.s1 == 0) {
	if (this.s2 == 0) {
		if (this.try_to_talk()) {
			R.player.pause_toggle(true);
			R.player.velocity.x = 0;
			this.s2 = 1;
		} 
	} else if (this.s2 == 1) {
		if (this.fade_out(this) && 	this.fade_out(R.player)) {
			this.s1 = 1;
			this.s2 = 0;
			this.set_vars(dolly, this.x - 32, this.y, 0, true);
			this.set_vars(tracy, this.x + 32, this.y, 0, true);
		}
	}
} else if (this.s1 == 1) {
	if (this.fade_in([dolly,tracy])) {
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.s2 == 0) {
		this.dialogue("forest", "after_memory", 0,false);
		this.s2 = 1;
	} else if (this.s2 == 1) {
		if (this.dialogue_is_on() == false) {
			this.s2 = 2;
		}
	} else if (this.s2 == 2) {
		if (this.fade_out([dolly, tracy]) && this.fade_in(this) && this.fade_in(R.player)) {
			this.s2 = 0;
			this.s1 = 0;
			R.player.pause_toggle(false);
		}
	}
} 
	