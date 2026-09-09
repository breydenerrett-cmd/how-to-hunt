extends SceneTree
var game:Node
var frame_times=[]
var elapsed=0.0
var previous=0
var sampling=false
var output="res://evidence/benchmark.json"
func _initialize() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
 run.call_deferred()
func _process(dt:float) -> bool:
 if not sampling:return false
 var now=Time.get_ticks_usec()
 if previous>0:frame_times.append((now-previous)/1000.0)
 previous=now;elapsed+=dt
 return false
func run() -> void:
 Engine.max_fps=60;game=load("res://main.tscn").instantiate();root.add_child(game);game.bot_mode="benchmark";game.store.disabled=true;game.start_host(false,"Frame sample",998312)
 await create_timer(1.5).timeout;sampling=true;await create_timer(6).timeout;sampling=false
 frame_times.sort();var report={"version":game.C.VERSION,"samples":frame_times.size(),"median_ms":frame_times[frame_times.size()/2],"p95_ms":frame_times[int(frame_times.size()*.95)],"p99_ms":frame_times[int(frame_times.size()*.99)],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"scope":"Six-second native1080p cap60 sample at camp, one idle avatar and five live simulated deer. Not long-session co-op, weaker-machine or human performance acceptance."}
 var f=FileAccess.open(output,FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close();print("HUNT_BENCHMARK ",JSON.stringify(report));game.active=false;game.queue_free();await process_frame;quit()
