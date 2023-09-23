if (!this.child_init) {
	this.child_init = true;
	this.width = 84;
	this.offset.x = 45;
	this.height = 48;
	this.offset.y = 80;
}
if (R.inventory.is_item_found(12) == true) {
	if (this.doff()) {
		if (this.try_to_talk()) {
			this.dialogue("canyon", "rock");
		} else {
			if (this.overlaps(R.player)) {
				this.t_1++;
				if (this.t_1 > 10) {
					this.t_1 = 0;
					R.player.add_light(1);
				}
			}
		}
	}
	this.alpha = 1;
} else {
	this.alpha = 0.3;
}