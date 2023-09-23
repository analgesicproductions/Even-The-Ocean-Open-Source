if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.make_child("gm_rouge");
	this.make_child("gm_set1");
	this.make_child("gm_set2");
	this.make_child("gm_silos");
	this.make_child("gm_set3");
	this.make_child("gm_sunray");
	for (i in [0,1,2,3,4,5]) {
		this.set_vars(this.sprites.members[i], 0, 0, 0, true);
		this.sprites.members[i].scrollFactor.set(0, 0);
		this.sprites.members[i].width = 1;
		this.sprites.members[i].height = 1;
		this.sprites.members[i].ID = i;
		//this.sprites.members[i].y = 24 * i;
	}
	this.s1 = 0;
	this.s2 = 0;
	this.s3 = -1;
}


var curZone = 0;
var testX = R.player.x;
if (R.player.facing == 0x10) {
	testX = R.player.x + R.player.width;
}
if (testX >= 416 * 5) {
	curZone = 5;
} else if (testX >= 416 * 4) {
	curZone = 4;
} else if (testX >= 416 * 3) {
	curZone = 3;
} else if (testX >= 416 * 2) {
	curZone = 2;
} else if (testX >= 416 * 1) {
	curZone = 1;
} else {
	curZone = 0;
}

//this._trace(curZone);

if (this.s1 == 0) {
	this.s1 = 1;
	this.sprites.members[curZone].alpha = 1;
	this.s2 = curZone; // Keeps track of "source" zone
} else if (this.s1 == 1) {
	if (curZone != this.s2) {
		for (i in [0, 1, 2, 3, 4, 5]) {
			if (curZone == this.sprites.members[i].ID) {
				var sp = this.sprites.remove(this.sprites.members[i], true);
				this.sprites.add(sp);
				this.s2 = curZone;
				this.s3 = curZone;
				this.s1 = 2;
				break;
			}
		}
	}
} else if (this.s1 == 2) {
	if (this.s3 == -1) {
		this.s1 = 1;
	}
}

// Logic for fade, set s3 to fade
if (this.s3 != -1) {
	var ct = 0;
	for (i in [0, 1, 2, 3, 4, 5]) {
		if (this.s3 == this.sprites.members[i].ID) {
			if (this.fade_in(this.sprites.members[i],0.02)) {
				ct++;
			}
		} 
	}
	
	if (ct == 1) {
		for (i in [0,1,2,3,4,5]) {
			if (this.s3 != this.sprites.members[i].ID && this.fade_out(this.sprites.members[i],0.02)) {
				ct++;
			}
		}
	}
	if (ct == 6) {
		this.s3 = -1;
	}
}



