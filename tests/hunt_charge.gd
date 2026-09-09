extends SceneTree
var game:Node
var passes=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="charge";game.start_host(false,"Charge fixture",999078)
 var a=game.avatars[1]
 var crown=game.spawn_animal(game.forest.point(0,0),1.55,true);a.position=game.forest.point(0,7);a.previous_position=a.position;crown.alert=1
 for i in range(3):game.submit_input(Vector2.ZERO,0,0,false,false,false);await physics_frame
 check(crown.state=="windup","elite commits to a warned attack before movement")
 crown.update_danger()
 check(crown.danger.global_transform==Transform3D.IDENTITY,"world-space charge lane has no inherited animal offset")
 check((-crown.basis.z).dot(crown.charge_direction)>.99,"braced animal faces its actual marked attack direction")
 var locked=crown.charge_target;var initial=crown.position;var old_health=a.health
 var reduced=crown.take_shot(85)
 check(absf(reduced-38.25)<.01,"braced hide reduces ordinary steady shot")
 var saw_charge=false;var elapsed=0.0;var fixed=true
 while elapsed<5 and crown.state!="recover":
  game.submit_input(Vector2(1,0),0,0,false,true,false);await physics_frame;elapsed+=1.0/60
  fixed=fixed and crown.charge_target==locked
  if crown.state=="charge":saw_charge=true
 check(saw_charge and crown.state=="recover","rush ends in an attack opportunity")
 check(fixed and a.health==old_health,"real strafing escapes the locked lane without homing damage")
 check(crown.position.distance_to(initial)>8,"rush travels through its marked corridor")
 var full=crown.take_shot(85)
 check(full==85 and crown.hp>0,"recovery restores full shot damage")
 check(crown.timer>3,"counterattack window allows steady aim and a follow-up")
 var before=crown.hp;crown.take_shot(85)
 check(before>0 and crown.hp==0,"counterattack can finish the Crownback")
 # Obstacles stop a committed charge; no attack through the lodge's wall.
 var blocked=game.spawn_animal(game.forest.point(0,18),1.55,true);blocked.state="charge";blocked.charge_direction=Vector3.LEFT;blocked.charge_target=Vector3(-10,0,18);blocked.timer=1.5
 a.position=Vector3(20,0,30);a.previous_position=a.position
 for i in range(90):game.submit_input(Vector2.ZERO,0,0,false,false,false);await physics_frame
 check(blocked.state=="recover" and blocked.position.x> -3,"solid lodge stops charge and opens recovery")
 game.active=false;game.queue_free();await process_frame
 print("TEST_SUMMARY hunt_charge passes=",passes," failures=",failures);quit(1 if failures else 0)
