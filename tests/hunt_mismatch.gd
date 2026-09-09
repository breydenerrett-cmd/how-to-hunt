extends SceneTree
var game:Node
var role="host"
func _initialize() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--role="):role=arg.trim_prefix("--role=")
 run.call_deferred()
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="mismatch";game.test_mode=true
 if role=="host":
  game.start_host(true,"Host",999118);await create_timer(10).timeout
  var ok=game.avatars.size()==1;print("MISMATCH_HOST isolated=",ok);game.active=false;game.queue_free();await process_frame;quit(0 if ok else 1)
 else:
  game.start_join("127.0.0.1","Previous build");await create_timer(5).timeout
  var ok=not game.active and "Build mismatch" in game.ui.menu_status.text
  print("MISMATCH_CLIENT rejected=",ok," message=",game.ui.menu_status.text);game.active=false;game.queue_free();await process_frame;quit(0 if ok else 1)
