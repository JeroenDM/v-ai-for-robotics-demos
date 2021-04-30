module loc

const (
	p_hit   = 0.4
	p_miss  = 0.2
	p_exact = 0.9 // p that the robot executes a move
	p_under = 0.05 // p that the robot undershoots a move by 1
	p_over  = 0.05 // overshoot move by one
)

pub enum Measurement {
	obstacle
	empty
}

///////////////////////////////////////
// MATH UTIL
///////////////////////////////////////

// sum values in array
pub fn sum<T>(p []T) T {
	mut sum := 0.0
	for v in p {
		sum += v
	}
	return sum
}

// normalize probabilities
// not a normal vector! all values > 0 and sum = 1
pub fn normalized(p []f64) []f64 {
	s := sum(p)
	return p.map(it / s)
}

// wrap index around in list with length n
pub fn wrap(ind int, n int) int {
	if ind < 0 {
		return n + ind % n
	} else {
		return ind % n
	}
}

///////////////////////////////////////
// LOCALIZATION CODE
///////////////////////////////////////

// update probabilities after sensor input
// TODO replace this with map on arrays or something
pub fn sense(p []f64, w []Measurement, z Measurement) []f64 {
	mut p_new := p.clone()
	for i, _ in p {
		if w[i] == z {
			p_new[i] *= p_hit
		} else {
			p_new[i] *= p_miss
		}
	}
	return normalized(p_new)
}

// update probabilities after robot motion
pub fn move(p []f64, u int) []f64 {
	mut p_new := []f64{len: p.len, init: 0.0}

	for i, _ in p_new {
		p_new[wrap(i + u - 1, p.len)] += p[i] * p_under
		p_new[wrap(i + u, p.len)] += p[i] * p_exact
		p_new[wrap(i + u + 1, p.len)] += p[i] * p_over
	}
	return p_new
}
