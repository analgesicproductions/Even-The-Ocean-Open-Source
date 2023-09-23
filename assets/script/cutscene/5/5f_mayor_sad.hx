/* DEPRECATED 2015 11 24 */
//{ i2_mayor_sad
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	//this._trace("DEBUG 5f_mayor_sad");
	//this.set_ss("i2", "crowd_hastings", 1, 1);
	this.make_child("biggs",false,"idle");
	this.make_child("snickwad",false,"idle");
	if (this.get_ss("i2", "crowd_hastings", 1) == 1 && this.get_ss("i2", "mayor_sad", 1) == 0) {
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
}
var biggs = this.sprites.members[0];
var snickwad = this.sprites.members[1];
if (this.s1 == 0) {
	this.t_1++;
	if (this.t_1 > 4) {
		R.player.x = R.player.last.x = this.x;
		R.player.y = R.player.last.y = this.y;
		this.set_vars(biggs, this.x + 16, this.y, 1);
		this.set_vars(snickwad, this.x + 32, this.y, 1);
		this.play_music("mayor_sad_i2");
		this.t_1 = 0;
		this.dialogue("i2", "mayor_sad", 0);
		this.s1 = 1;
		this.set_ss("i2", "mayor_sad", 1, 1);
	}	
} else if (this.s1 == 1) {
	if (this.doff()) {
		this.s1 = 2;
		this.change_map("WF_HI_1", 53, 21, true);
	}
}