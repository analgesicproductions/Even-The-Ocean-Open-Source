
if (!this.child_init) {
	this.child_init = true;
	if (R.inventory.is_item_found(12) == true) {
		this.animation.play("idle_r");
		this.SCRIPT_OFF = true;
		return;
	} 
}

if (this.doff() && this.try_to_talk()) {
	this.dialogue("canyon", "protector", 0);
	this.animation.play("idle_r");
}