extends SceneTree
var game:Node
var passes=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="behavior";game.start_host(false,"Behavior fixture",999031)
 await create_timer(1.3).timeout
 for d in game.animals.values():
  var height=game.Forest.height_at(d.position.x,d.position.z)
  check(absf(d.position.y-height)<.28,"deer stands with feet on real terrain")
 var a=game.avatars[1];var deer=game.animals.values()[0]
 a.position=deer.position+Vector3(0,0,5);a.previous_position=a.position
 for i in range(100):
  game.submit_input(Vector2.ZERO,0,0,false,true,false);await physics_frame
 check(deer.alert>.72 and deer.state=="flee","close loud hunter triggers real flee state")
 var before=deer.position
 await create_timer(.6).timeout
 check(deer.position.distance_to(before)>1,"fleeing wildlife moves across ground")
 var crown=game.spawn_animal(Vector3(0,.1,0),1.55,true);a.position=Vector3(0,.1,7);a.previous_position=a.position;crown.alert=1
 var warned=false;var rushed=false;var health=a.health
 for i in range(190):
  game.submit_input(Vector2.ZERO,0,0,false,false,false);await physics_frame
  if crown.state=="windup":warned=true
  if crown.state=="charge":rushed=true
 check(warned and rushed,"Crownback warns before charging through real physics")
 check(a.health<health and a.health>=health-28,"one charge damages once within its corridor")
 crown.hp=0;var target=crown.charge_target;var snapshot=crown.saved();crown.visual_step(.1,0)
 check(not crown.danger.visible and crown.saved()==snapshot and crown.charge_target==target,"downed wildlife clears telegraph and cosmetic update cannot change combat/save")
 game.active=false;game.queue_free();await process_frame;print("TEST_SUMMARY hunt_behavior passes=",passes," failures=",failures);quit(1 if failures else 0)
