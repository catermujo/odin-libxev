package main

import "base:runtime"
import "core:c"
import "core:fmt"

import xev ".."

main :: proc() {
    loop: xev.Loop

    if xev.loop_init(&loop) != 0 {
        fmt.println("loop init failed")
        return
    }
    defer xev.loop_deinit(&loop)

    w: xev.Watcher
    if (xev.timer_init(&w) != 0) {
        fmt.println("timer init failed")
        return
    }
    defer xev.timer_deinit(&w)

    completion: xev.Completion
    xev.timer_run(&w, &loop, &completion, 5000, nil, on_timer)
    xev.loop_run(&loop, .until_done)
}

on_timer :: proc "c" (loop: ^xev.Loop, comp: ^xev.Completion, result: c.int, userdata: rawptr) -> xev.Action {
    context = runtime.default_context()
    fmt.println("callback called!")
    return .disarm
}
