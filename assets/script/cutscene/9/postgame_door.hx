if (!this.child_init) {
	this.only_visible_in_editor = true;
	this.child_init = true;
	this.s1 = -1;
	
	//this._trace("DEBUG: postgame door");
	//R.inventory.set_item_found(0, 44);
	//R.inventory.set_item_found(0, 44,false);
	//R.ignore_door = false;
	return;
}


if (this.s1 == -1) {
	this.s1 = 0;
	if (R.inventory.is_item_found(30)) {
		this.children[0].behavior_to_open();
		this._trace("open postgame on map");
	} else {
		this.children[0].x += 100;
	}
}
