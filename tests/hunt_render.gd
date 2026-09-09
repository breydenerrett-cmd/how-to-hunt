extends SceneTree
var game:Node
var output="evidence/visual"
func _initialize() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
 run.call_deferred()
func capture(label:String) -> void:
 await create_timer(.5).timeout;RenderingServer.force_draw();var img=root.get_texture().get_image();var err=img.save_png(output+"_"+label+".png");print("HUNT_RENDER ",label," ",img.get_size()," result=",err)
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="render"
 await capture("menu")
 game.start_host(false,"Render fixture",991234);game.set_physics_process(false);game.ui_scale=1.2
 await capture("camp")
 var a=game.avatars[1];a.position=game.C.SHOP+Vector3(0,0,3);a.previous_position=a.position;game.yaw=0;game.pitch=-.1
 await capture("lodge")
 game.buy(a,"rifle");game.ui.show_panel("shop","scope");await capture("purchase");game.ui.panel.hide()
 var animal=game.animals.values()[0];animal.position=game.forest.point(0,-8)+Vector3.UP*.1;animal.rotation.y=.7;animal.state="graze";animal.head_pitch=-.85;a.position=game.forest.point(0,-3)+Vector3.UP*.1;a.previous_position=a.position;game.pitch=-.03;game.yaw=0
 game.ui.notice_time=0;await capture("deer_graze")
 var original=a.position;a.position=game.forest.point(4,-8)+Vector3.UP*.1;a.previous_position=a.position;game.yaw=PI/2;game.pitch=0;await capture("deer_profile")
 a.position=original;a.previous_position=a.position;game.yaw=0;game.pitch=-.03
 game.progress.upgrades.append("scope");a.input_reel=true;await capture("scope_aim");a.input_reel=false
 a.reload_until=game.clock+1.3;await capture("reload");a.reload_until=0
 animal.state="alert";animal.head_pitch=.05;animal.alert=.5;await capture("deer_alert")
 animal.state="flee";animal.head_pitch=.05;animal.motion_speed=4.7;animal.alert=1;await capture("deer_flee")
 animal.hp=0;animal.state="down";animal.motion_speed=0;await capture("deer_down")
 var crown=game.spawn_animal(game.forest.point(3,-8),1.55,true);crown.state="windup";crown.head_pitch=-.45;crown.charge_target=a.position;crown.rotation.y=atan2(-(a.position.x-crown.position.x),-(a.position.z-crown.position.z));crown.alert=1;animal.hide();await capture("crownback")
 crown.state="recover";crown.head_pitch=.05;await capture("crownback_recover")
 game.sound.stop_all();await create_timer(.15).timeout;game.active=false;game.queue_free();await process_frame;quit()
