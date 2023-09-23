var s = "45,";


// after get kv maps
if (this.get_ss("s3", "kv_maps", 1) != 0) {
	s += "32,34,35,36,37,38,39,41,42,43,44,";
}


// after g1_3 done
if (this.get_event_state(31)) {
	s += "9,11,17,20,22,23,24,25,26,27,28,29,";
}

// after intro console
if (this.get_event_state(23)) {
	s += "12,13,14,15,16,18,";
}

s += "0,1,2,3,4,5,6,7,8";


return s;