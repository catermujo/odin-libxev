package main

import "base:runtime"
import "core:fmt"
import "core:c"
import xev ".."


main :: proc() {

	loop: xev.loop

	if xev.loop_init(&loop) != 0 {
		fmt.println("loop init failed")
		return
	}
	defer xev.loop_deinit(&loop)


	w: xev.watcher
	if (xev.timer_init(&w) != 0) {
		fmt.println("timer init failed")
		return
	}
	defer xev.timer_deinit(&w)

	completion: xev.completion
	xev.timer_run(&w, &loop, &completion, 5000, nil, on_timer)
	xev.loop_run(&loop, .RUN_UNTIL_DONE)


}


on_timer :: proc "c" (loop: ^xev.loop, comp: ^xev.completion, result: c.int, userdata: rawptr) -> xev.cb_action {
    context = runtime.default_context()
    fmt.println("callback called!")
    return .DISARM
}

