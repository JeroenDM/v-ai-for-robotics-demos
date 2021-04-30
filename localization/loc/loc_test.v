module loc

fn test_sum() {
	p := [0.2, 0.2, 0.2, 0.2]
	assert sum(p) == 0.8
}

fn test_normalized() {
	mut p := [0.2, 0.2, 0.2, 0.2]
	p = normalized(p)
	for v in p {
		assert v == 0.25
	}
}

fn test_wrap() {
	assert wrap(-1, 5) == 4
	assert wrap(-2, 5) == 3
	assert wrap(4, 5)  == 4
	assert wrap(5, 5)  == 0
	assert wrap(6, 5)  == 1
}
