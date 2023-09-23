if (next_map.indexOf("E_PARK") == 0 && "E_PARK".length == next_map.length) {
	return [5, 6];
} else if (next_map.indexOf("REALHOME") == 0 && "REALHOME".length == next_map.length) {
	return [1, 2, 3];
} else {
	return [ 1, 2, 3, 5, 4];
}

