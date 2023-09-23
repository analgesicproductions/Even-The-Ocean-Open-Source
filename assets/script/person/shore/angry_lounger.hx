if (this.try_to_talk()) {
	if (R.inventory.is_item_found(11) == false) {
		this.dialogue("shore", "angry_lounger", 0);
	} else {
		this.dialogue("shore", "angry_lounger", 1);
	}
}