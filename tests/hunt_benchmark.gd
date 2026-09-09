extends SceneTree
## Frame cost sampler.
##
## Runs two passes deliberately. The capped pass answers "does this hold 60?" and is
## what a player feels. The uncapped pass answers "what does a frame actually cost?"
## and is the only one that can detect a regression: under a 60 fps cap every median
## sits at the cap until frames already miss, so a capped-only benchmark reports any
## amount of added GPU work as free right up to the moment it is a visible problem.
##
## Render configuration is recorded with the numbers because these results are not
## comparable across renderers or resolutions. Keep a separate baseline per renderer.
var game:Node
var frame_times=[]
var previous=0
var sampling=false
var output="res://evidence/benchmark.json"
func _initialize() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
 run.call_deferred()
func _process(_dt:float) -> bool:
 if not sampling:return false
 var now=Time.get_ticks_usec()
 if previous>0:frame_times.append((now-previous)/1000.0)
 previous=now
 return false
func percentile(sorted:Array,fraction:float) -> float:
 if sorted.is_empty():return 0.0
 return float(sorted[clampi(int(sorted.size()*fraction),0,sorted.size()-1)])
func sample(seconds:float) -> Dictionary:
 # Settle first: the frames right after a cap change or load are not representative.
 await create_timer(1.5).timeout
 frame_times.clear();previous=0;sampling=true
 await create_timer(seconds).timeout
 sampling=false
 var times=frame_times.duplicate();times.sort()
 return {
  "samples":times.size(),
  "median_ms":snappedf(percentile(times,.50),.001),
  "p95_ms":snappedf(percentile(times,.95),.001),
  "p99_ms":snappedf(percentile(times,.99),.001),
  "draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
  "objects":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
  "primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
  "video_mem_mb":snappedf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.0,.01),
 }
func render_config() -> Dictionary:
 var size=DisplayServer.window_get_size()
 var config={
  "renderer":RenderingServer.get_current_rendering_method(),
  "viewport":[size.x,size.y],
  "msaa_3d":int(ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d",0)),
  "screen_space_aa":int(ProjectSettings.get_setting("rendering/anti_aliasing/quality/screen_space_aa",0)),
 }
 var world=root.get_viewport().find_world_3d()
 var env:Environment=world.environment if world else null
 if env:
  config.merge({
   "tonemap":int(env.tonemap_mode),
   "ssao":env.ssao_enabled,
   "ssil":env.ssil_enabled,
   "glow":env.glow_enabled,
   "volumetric_fog":env.volumetric_fog_enabled,
   "adjustments":env.adjustment_enabled,
  })
 return config
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game)
 game.bot_mode="benchmark";game.store.disabled=true;game.start_host(false,"Frame sample",998312)
 # Uncapped first, while nothing has had a chance to throttle.
 Engine.max_fps=0
 var uncapped=await sample(6.0)
 Engine.max_fps=60
 var capped=await sample(6.0)
 var report={
  "version":game.C.VERSION,
  "config":render_config(),
  "uncapped":uncapped,
  "capped":capped,
  "scope":"Two six-second native samples at camp with one idle avatar and five live simulated deer. Compare the uncapped median against a baseline captured on the SAME renderer and resolution; the capped pass only shows whether 60 is held. Neither is long-session co-op, weaker-hardware, or human performance acceptance.",
 }
 var f=FileAccess.open(output,FileAccess.WRITE)
 if f:f.store_string(JSON.stringify(report,"  "));f.close()
 print("HUNT_BENCHMARK ",JSON.stringify(report))
 game.active=false;game.queue_free();await process_frame;quit()
