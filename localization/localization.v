module main

import gx
import gg
// import time

import loc

const (
	window_width  = 500
	window_height = 200
	bar_width     = 100
	num_bars      = 5
	robot_height  = 50
)

struct Theme {
	bars       gx.Color
	robot      gx.Color
	background gx.Color
	obstacle   gx.Color
	empty      gx.Color
}

const (
	theme = Theme{
		bars: gx.rgb(21, 96, 100)
		robot: gx.rgb(0, 196, 154)
		background: gx.rgb(248, 225, 108)
		obstacle: gx.rgb(251, 143, 103)
		empty: gx.rgb(255, 194, 180)
	}
)

struct Robot {
	world []loc.Measurement
	n     int
mut:
	p []f64
}

struct Game {
mut:
	gg      &gg.Context
	bar_h   [5]int
	i_robot int
	step    int
	height  int
	width   int
	r       Robot
	draw_fn voidptr
}

///////////////////////////////////////
// MAIN
///////////////////////////////////////

fn main() {
	mut robot := &Robot{
		world: [.empty, .obstacle, .obstacle, .empty, .empty]
		n: 5
		p: []f64{len: 5, init: 1 / f64(5)}
	}

	mut game := &Game{
		gg: 0
		bar_h: [20, 20, 20, 20, 20]!
		i_robot: 0
		step: 0
		width: window_width
		height: window_height
		r: robot
	}
	game.gg = gg.new_context(
		width: window_width
		height: window_height
		font_size: 20
		use_ortho: true
		user_data: game
		window_title: '1D Localization demo'
		create_window: true
		frame_fn: frame
		event_fn: on_event
		bg_color: theme.background
		font_path: gg.system_font_path()
	)

	println('world: $robot.world')
	println('p: $robot.p')

	println('Starting the simulation..')
	game.gg.run()
}

fn (mut game Game) init_game() {
	game.r.p = []f64{len: 5, init: 1 / f64(5)}
	game.i_robot = 0
	game.step = 0
	for i, pi in game.r.p {
		game.bar_h[i] = int(pi * 100)
	}
}

///////////////////////////////////////
// VISUALIZATION
///////////////////////////////////////

fn frame(mut game Game) {
	game.gg.begin()

	for i, z in game.r.world {
		c := match z {
			.obstacle { theme.obstacle }
			else { theme.empty }
		}
		game.gg.draw_rect(bar_width * i, 0, bar_width, 20, c)
	}

	for i, h in game.bar_h {
		game.gg.draw_rect(bar_width * i, game.height / 2 - h, bar_width, h, theme.bars)
	}
	game.gg.draw_rect(bar_width * game.i_robot, game.height - robot_height, bar_width,
		robot_height, theme.robot)

	game.gg.draw_text_def(10, game.height - 20, 'Iteration: $game.step')
	game.gg.end()
}

fn on_event(e &gg.Event, mut game Game) {
	// println('code=$e.char_code')
	if e.typ == .key_down {
		game.key_down(e.key_code)
	}
}

fn (mut game Game) key_down(key gg.KeyCode) {
	// global keys
	match key {
		.escape {
			exit(0)
		}
		else {}
	}

	// keys while game is running
	match key {
		.left {
			game.move(-1)
		}
		.right {
			game.move(1)
		}
		.c {
			game.init_game()
		}
		else {}
	}
}

fn (mut game Game) move(u int) bool {
	// game.i_robot = loc.wrap(game.i_robot + dx)
	// println('moving: $u')
	z := game.r.world[game.i_robot]
	game.r.p = loc.sense(game.r.p, game.r.world, z)
	game.r.p = loc.move(game.r.p, u)
	// println('$game.r.p')

	// mut i_max := 0
	// mut p_max := 0.0
	for i, pi in game.r.p {
		game.bar_h[i] = int(pi * 100)
		// if pi > p_max {
		// 	p_max = pi
		// 	i_max = i
		// }
	}
	// game.i_robot = i_max
	game.i_robot = loc.wrap(game.i_robot + u, game.r.n)
	game.step += 1
	return true
}
