extends SceneTree
func _initialize() -> void:run.call_deferred()
func run() -> void:
 var game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="stance-render";game.start_host(false,"View",999120);game.set_physics_process(false);game.pitch=-.12;game.ui.notice_time=0
 var other=game.add_avatar(2,"Stalking hunter");other.position=game.C.CAMP+Vector3(0,0,-3);other.rotation.y=PI;other.previous_position=other.position
 for crouch in [false,true]:
  other.crouched=crouch;other.visual_speed=.6
  await create_timer(.8).timeout;RenderingServer.force_draw();root.get_texture().get_image().save_png("res://evidence/hunting_stalking/third_person_"+("crouch" if crouch else "standing")+".png")
 game.active=false;game.sound.stop_all();game.queue_free();await process_frame;quit()
