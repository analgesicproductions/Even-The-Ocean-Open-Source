if (this.try_to_talk()) {
	this.R.inventory.set_all_planted();
	this.dialogue("shore", "starfish_center");
}