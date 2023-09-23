
this.scale.set(0.7, 0.7);

this.s2++;
if (this.s2 > 360) {
	this.s2 = 0;
}

this.angle = this.sin_table[this.s2] * 10;
this.angularVelocity = 0.1;

if (this.s1 == 0) {
	if (R.input.jpA1) {
		this.y += 128;
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	this.y --;
	if (this.y < this.iy - 25) {
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	//this.angle = 30;
	//this._trace(this.angle);
}