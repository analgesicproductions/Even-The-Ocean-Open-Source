
// state 0: wait for energy
// 0>1 get energy. change color
// state 1: wait for input
// 1>2 get input. change color . send energy signal to logical receiver that flips event flag for beating boss once. Also 
// state 2: idle.

if (this.state_1 == 0) {
	if (this.nr_ENERGIZE_received > 0) {
		this.state_1 = 1;
		this.play_anim("ready");
	}
} else if (this.state_1 == 1) {
	if (this.try_to_talk()) {
		this.state_1 = 2;
		this.broadcast_tick(true);
		this.play_anim("on");
	}
} else if (this.state_1 == 2) {
	
}