//{ river_jr_gatekeeper
if (!this.child_init) {
	this.child_init = true;
	this.init_loopsound("river.wav", 3450);
	this.begin_loopsound();
	this.loopsound.volume = 0;
	this.loopsound2.volume = 0;
	this.only_visible_in_editor = true;
}

//863
//875 = max
// 810 = half?
// 750 = silent

var f = 0.0;
if (R.player.y >= 870) {
	f = 1.0;
} else if (R.player.y <= 750) {
	f = 0.0;
} else {
	f = 1 - ((870 - R.player.y) / (870 - 750.0));
}

//this._trace(f);
this.loopsound.volume = f;
this.loopsound2.volume = f;