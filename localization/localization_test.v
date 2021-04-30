module main

fn test_wrap() {
	assert wrap(-1, 5) == 4
	assert wrap(-2, 5) == 3
	assert wrap(4, 5)  == 4
	assert wrap(5, 5)  == 0
	assert wrap(6, 5)  == 1
}
