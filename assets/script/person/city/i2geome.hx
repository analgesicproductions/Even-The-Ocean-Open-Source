//{ i2geome_script
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	this.make_child("i2geome", false, "earth");
	this.make_child("i2geome", false, "air");
	this.make_child("i2geome", false, "sea");
	
	//this._trace("EDBUG i2geome");
	//this.set_event(39);
	this.alpha = 0;
	// If after g2_3 but depths not done
	if (this.event(39) && !this.event(48)) {
		
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	this.set_vars(this.sprites.members[0], 1854, 1204, 1, true);
	this.set_vars(this.sprites.members[1], 1870, 1118, 1, true);
	this.set_vars(this.sprites.members[2], 1810, 1150, 1, true);
	this.set_wh(this.sprites.members[0], 48, 40, true, true);
	this.set_wh(this.sprites.members[1], 64, 48, true, true);
	this.set_wh(this.sprites.members[2], 64, 48, true, true);
	this.sprites.members[0].iy = this.sprites.members[0].y;
	this.sprites.members[0].ix = this.sprites.members[0].x;
	this.sprites.members[1].iy = this.sprites.members[1].y;
	this.sprites.members[1].ix = this.sprites.members[1].x;
	this.sprites.members[1].offset.y = 24;
	this.sprites.members[2].offset.y = 24;
	this.sprites.members[2].iy = this.sprites.members[2].y;
	this.sprites.members[2].ix = this.sprites.members[2].x;
	this.sprites.members[2].scale.x = -1;
	
	this.t_1 = 0;
	this.t_2 = 0;
	this.s1 = 0;
	this.s2 = 90;
}

var earth = this.sprites.members[0];
var air = this.sprites.members[1];
var sea = this.sprites.members[2];

earth.immovable = true;
air.immovable = true;
sea.immovable = true;

this.t_1++;
if (this.t_1 > 2) {
	this.t_1 = 0;
	this.s1+= 3;
	if (this.s1 >= 360) {
		this.s1 -= 360;
	}
}
air.offset.y = 8 + 3 * this.get_sin(this.s1);

this.t_2++;
if (this.t_2 > 2) {
	this.t_2 = 0;
	this.s2+= 4;
	if (this.s2 >= 360) {
		this.s2 -= 360;
	}
}
sea.offset.y = 8 - 4 * this.get_sin(this.s1);


this.player_separate(earth);
this.player_separate(air);
this.player_separate(sea);
