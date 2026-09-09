extends SceneTree
var game:Node
var stem="evidence/hunting_gear/view"
func _initialize() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--output="):stem=arg.trim_prefix("--output=")
 run.call_deferred()
func capture(label:String) -> void:
 await create_timer(.6).timeout;RenderingServer.force_draw();root.get_texture().get_image().save_png(stem+"_"+label+".png")
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="gear-render";game.start_host(false,"Gear view",999127);game.set_physics_process(false);game.ui_scale=1.2
 var a=game.avatars[1];a.position=game.C.SHOP+Vector3(0,0,1);a.previous_position=a.position;game.pitch=-.15;game.yaw=.95;game.ui.notice_time=0
 a.input_yaw=game.yaw;await capture("left_shelves");game.yaw=-.95;a.input_yaw=game.yaw;await capture("right_shelves")
 game.progress.wallet=300;game.buy(a,"rifle")
 for id in ["boots","overshirt","scent","muffler"]:game.buy(a,id)
 game.ui.show_panel("shop","muffler");await capture("muffler_shop");game.ui.show_panel("journal");await capture("journal");game.ui.panel.hide()
 a.position=game.C.CAMP;a.previous_position=a.position;game.yaw=0;game.pitch=-.05;await capture("muffled_rifle")
 game.active=false;game.sound.stop_all();game.queue_free();await process_frame;quit()
