if (!this.child_init) {
	this.child_init = true;
}


if (R.player.x > this.x) {
	this.s1++;
	R.player.apply_wind(-this.s1, 0, true);
} else {
	this.s1 = 160;
}