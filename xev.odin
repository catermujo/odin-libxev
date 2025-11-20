package xev

import "core:c"

when ODIN_OS == .Windows {
    foreign import lib "libxev.lib"
} else when ODIN_OS == .Darwin {
    foreign import lib "libxev.darwin.a"
} else {
    foreign import lib "libxev.linux.a"
}

SIZEOF_LOOP: c.size_t : 512
SIZEOF_COMPLETION: c.size_t : 320
SIZEOF_WATCHER: c.size_t : 256
SIZEOF_THREADPOOL: c.size_t : 64
SIZEOF_THREADPOOL_BATCH: c.size_t : 24
SIZEOF_THREADPOOL_TASK: c.size_t : 24
SIZEOF_THREADPOOL_CONFIG: c.size_t : 64

ALIGN_T :: i128 when size_of(uintptr) == 8 else i64

Loop :: struct {
    _pad: ALIGN_T,
    data: [SIZEOF_LOOP - size_of(ALIGN_T)]byte,
}
Completion :: struct {
    _pad: ALIGN_T,
    data: [SIZEOF_COMPLETION - size_of(ALIGN_T)]byte,
}
Watcher :: struct {
    _pad: ALIGN_T,
    data: [SIZEOF_WATCHER - size_of(ALIGN_T)]byte,
}
Threadpool :: struct {
    _pad: ALIGN_T,
    data: [SIZEOF_THREADPOOL - size_of(ALIGN_T)]byte,
}
Threadpool_Batch :: struct {
    _pad: ALIGN_T,
    data: [SIZEOF_THREADPOOL_BATCH - size_of(ALIGN_T)]byte,
}
Threadpool_Task :: struct {
    _pad: ALIGN_T,
    data: [SIZEOF_THREADPOOL_TASK - size_of(ALIGN_T)]byte,
}
Threadpool_Config :: struct {
    _pad: ALIGN_T,
    data: [SIZEOF_THREADPOOL_CONFIG - size_of(ALIGN_T)]byte,
}

Action :: enum c.int {
    disarm = 0,
    rearm  = 1,
}
task_cb :: #type proc "c" (t: ^Threadpool_Task)
timer_cb :: #type proc "c" (loop: ^Loop, completion: ^Completion, result: c.int, userdata: rawptr) -> Action
async_cb :: #type proc "c" (loop: ^Loop, completion: ^Completion, result: c.int, userdata: rawptr) -> Action

Run_Mode :: enum c.int {
    no_wait    = 0,
    once       = 1,
    until_done = 2,
}
Completion_State :: enum c.int {
    dead   = 0,
    active = 1,
}

@(link_prefix = "xev_")
foreign lib {
    loop_init :: proc "c" (loop: ^Loop) -> c.int ---

    loop_deinit :: proc "c" (loop: ^Loop) ---
    loop_run :: proc "c" (loop: ^Loop, mode: Run_Mode) -> c.int ---
    loop_now :: proc "c" (loop: ^Loop) -> c.int64_t ---
    loop_update_now :: proc "c" (loop: ^Loop) ---

    completion_zero :: proc "c" (completion: ^Completion) ---
    completion_state :: proc "c" (c: ^Completion) -> Completion_State ---

    threadpool_config_init :: proc "c" (config: Threadpool_Config) ---
    threadpool_config_set_stack_size :: proc "c" (config: ^Threadpool_Config, v: c.uint32_t) ---
    threadpool_config_set_max_threads :: proc "c" (config: ^Threadpool_Config, v: c.uint32_t) ---

    threadpool_init :: proc "c" (pool: ^Threadpool, config: ^Threadpool_Config) -> c.int ---
    threadpool_deinit :: proc "c" (pool: ^Threadpool) ---
    threadpool_shutdown :: proc "c" (pool: ^Threadpool) ---
    threadpool_schedule :: proc "c" (pool: ^Threadpool, batch: ^Threadpool_Batch) ---

    threadpool_task_init :: proc "c" (t: ^Threadpool_Task, cb: task_cb) ---
    threadpool_batch_init :: proc "c" (b: ^Threadpool_Batch) ---
    threadpool_batch_push_task :: proc "c" (b: ^Threadpool_Batch, t: ^Threadpool_Task) ---
    threadpool_batch_push_batch :: proc "c" (b: ^Threadpool_Batch, other: ^Threadpool_Batch) ---

    timer_init :: proc "c" (w: ^Watcher) -> c.int ---
    timer_deinit :: proc "c" (w: ^Watcher) ---
    timer_run :: proc "c" (w: ^Watcher, loop: ^Loop, comp: ^Completion, next_ms: c.uint64_t, userdata: rawptr, cb: timer_cb) ---
    timer_reset :: proc "c" (w: ^Watcher, loop: ^Loop, comp: ^Completion, completion_cancel: ^Completion, next_ms: c.uint64_t, userdata: rawptr, cb: timer_cb) ---
    timer_cancel :: proc "c" (w: ^Watcher, loop: ^Loop, comp: ^Completion, completion_cancel: ^Completion, userdata: rawptr, cb: timer_cb) ---

    async_init :: proc "c" (w: ^Watcher) -> c.int ---
    async_deinit :: proc "c" (w: ^Watcher) ---
    async_notify :: proc "c" (w: ^Watcher) -> c.int ---
    async_wait :: proc "c" (w: ^Watcher, loop: ^Loop, comp: ^Completion, userdata: rawptr, cb: async_cb) ---
}
