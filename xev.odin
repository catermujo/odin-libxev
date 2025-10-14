package libxev


import "core:c"

foreign import libxev "libxev.a"

XEV_SIZEOF_LOOP: c.size_t : 512
XEV_SIZEOF_COMPLETION: c.size_t : 320
XEV_SIZEOF_WATCHER: c.size_t : 256
XEV_SIZEOF_THREADPOOL: c.size_t : 64
XEV_SIZEOF_THREADPOOL_BATCH: c.size_t : 24
XEV_SIZEOF_THREADPOOL_TASK: c.size_t : 24
XEV_SIZEOF_THREADPOOL_CONFIG: c.size_t : 64


XEV_ALIGN_T :: i128 // FIXME: is this long double like libxev uses?

loop :: struct {
	_pad: XEV_ALIGN_T,
	data: [XEV_SIZEOF_LOOP - size_of(XEV_ALIGN_T)]u8,
}

completion :: struct {
	using _: loop,
}

watcher :: struct {
	using _: loop,
}

threadpool :: struct {
	using _: loop,
}

threadpool_batch :: struct {
	using _: loop,
}
threadpool_task :: struct {
	using _: loop,
}
threadpool_config :: struct {
	using _: loop,
}

cb_action :: enum c.int {
	DISARM = 0,
	REARM  = 1,
}

run_mode_t :: enum c.int {
	RUN_NO_WAIT    = 0,
	RUN_ONCE       = 1,
	RUN_UNTIL_DONE = 2,
}

completion_state_t :: enum c.int {
	COMPLETION_DEAD   = 0,
	COMPLETION_ACTIVE = 1,
}

task_cb :: proc "c" (t: ^threadpool_task)
timer_cb :: proc "c" (
	loop: ^loop,
	completion: ^completion,
	result: c.int,
	userdata: rawptr,
) -> cb_action
async_cb :: proc "c" (
	loop: ^loop,
	completion: ^completion,
	result: c.int,
	userdata: rawptr,
) -> cb_action


@(link_prefix = "xev_")
foreign libxev {

	loop_init :: proc "c" (loop: ^loop) -> c.int ---

	loop_deinit :: proc "c" (loop: ^loop) ---
	loop_run :: proc "c" (loop: ^loop, mode: run_mode_t) -> c.int ---
	loop_now :: proc "c" (loop: ^loop) -> c.int64_t ---
	loop_update_now :: proc "c" (loop: ^loop) ---

	completion_zero :: proc "c" (completion: ^completion) ---
	completion_state :: proc "c" (c: ^completion) -> completion_state_t ---

	threadpool_config_init :: proc "c" (config: threadpool_config) ---
	threadpool_config_set_stack_size :: proc "c" (config: ^threadpool_config, v: c.uint32_t) ---
	threadpool_config_set_max_threads :: proc "c" (config: ^threadpool_config, v: c.uint32_t) ---

	threadpool_init :: proc "c" (pool: ^threadpool, config: ^threadpool_config) -> c.int ---
	threadpool_deinit :: proc "c" (pool: ^threadpool) ---
	threadpool_shutdown :: proc "c" (pool: ^threadpool) ---
	threadpool_schedule :: proc "c" (pool: ^threadpool, batch: ^threadpool_batch) ---

	threadpool_task_init :: proc "c" (t: ^threadpool_task, cb: task_cb) ---
	threadpool_batch_init :: proc "c" (b: ^threadpool_batch) ---
	threadpool_batch_push_task :: proc "c" (b: ^threadpool_batch, t: ^threadpool_task) ---
	threadpool_batch_push_batch :: proc "c" (b: ^threadpool_batch, other: ^threadpool_batch) ---

	timer_init :: proc "c" (w: ^watcher) -> c.int ---
	timer_deinit :: proc "c" (w: ^watcher) ---
	timer_run :: proc "c" (w: ^watcher, loop: ^loop, comp: ^completion, next_ms: c.uint64_t, userdata: rawptr, cb: timer_cb) ---
	timer_reset :: proc "c" (w: ^watcher, loop: ^loop, comp: ^completion, completion_cancel: ^completion, next_ms: c.uint64_t, userdata: rawptr, cb: timer_cb) ---
	timer_cancel :: proc "c" (w: ^watcher, loop: ^loop, comp: ^completion, completion_cancel: ^completion, userdata: rawptr, cb: timer_cb) ---

	async_init :: proc "c" (w: ^watcher) -> c.int ---
	async_deinit :: proc "c" (w: ^watcher) ---
	async_notify :: proc "c" (w: ^watcher) -> c.int ---
	async_wait :: proc "c" (w: ^watcher, loop: ^loop, comp: ^completion, userdata: rawptr, cb: async_cb) ---

}
