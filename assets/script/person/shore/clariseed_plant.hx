if (this.try_to_talk()) {
	if (R.inventory.is_item_found(10)) {
		this.dialogue("shore", "clariseed_plant", 2);
	} else {
		
		this.dialogue("shore", "clariseed_plant", 0);
	}
}