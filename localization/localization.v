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

struct Game {
	// fixed robot world data
	world []loc.Measurement
	n     int
mut:
	// robot state estimation data
	p        []f64
	position int
	// robot animation data
	bar_h  [5]int
	step   int
	height int
	width  int
	// gui data
	gg &gg.Context
}

///////////////////////////////////////
// MAIN
///////////////////////////////////////

fn main() {
	mut game := &Game{
		world: [.empty, .obstacle, .obstacle, .empty, .empty]
		n: 5
		p: []f64{len: 5, init: 1 / f64(5)}
		bar_h: [20, 20, 20, 20, 20]!
		position: 0
		step: 0
		width: window_width
		height: window_height
		gg: 0
	}

	// I have no idea why this code works...
	// I both return a local variable by reference inside new_default_window
	// And there is a circular reference between Game and gg.Context
	// Maybe because it is heap allocated and I pass a pointer
	// the lifetime and clean responsibility moves to game.gg?
	game.gg = new_default_window(mut game)

	println('world: $game.world')
	println('p: $game.p')

	println('Starting the simulation..')
	game.gg.run()
}

///////////////////////////////////////
// USE LOC MODULE FOR LOCALIZATION
///////////////////////////////////////
fn (mut game Game) init_game() {
	// initialize probabilities, robot position, ...
	game.p = []f64{len: 5, init: 1 / f64(5)}
	game.position = 0
	game.step = 0

	// make sure the bars are updated when the simulation is cleared
	// when pressing 'c'
	game.update_bars()
}

fn (mut game Game) move(u int) bool {
	// exact measurement at the current position in the game
	z := game.world[game.position]

	// sense and move cycle that updated position probabilities
	game.p = loc.sense(game.p, game.world, z)
	game.p = loc.move(game.p, u)

	// move the robot without noise
	game.position = loc.wrap(game.position + u, game.n)

	// simulation step counter just to display some dynamic text
	game.step += 1

	// not sure what this is used for
	return true
}

///////////////////////////////////////
// VISUALIZATION
///////////////////////////////////////
fn new_default_window(mut game Game) &gg.Context {
	return gg.new_context(
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
}

fn frame(mut game Game) {
	game.gg.begin()

	game.update_bars()

	// draw the world with obstacles and empty space
	// this should be done in some kind of init function that I can't get to work
	for i, z in game.world {
		c := match z {
			.obstacle { theme.obstacle }
			else { theme.empty }
		}
		game.gg.draw_rect(bar_width * i, 0, bar_width, 20, c)
	}

	// draw the probability bars
	for i, h in game.bar_h {
		game.gg.draw_rect(bar_width * i, game.height / 2 - h, bar_width, h, theme.bars)
	}

	// draw the robot and some text
	game.gg.draw_rect(bar_width * game.position, game.height - robot_height, bar_width,
		robot_height, theme.robot)
	game.gg.draw_text_def(10, game.height - 20, 'Iteration: $game.step')

	game.gg.end()
}

fn on_event(e &gg.Event, mut game Game) {
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

fn (mut game Game) update_bars() {
	for i, pi in game.p {
		game.bar_h[i] = int(pi * 100)
	}
}
