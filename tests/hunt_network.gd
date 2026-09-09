extends SceneTree
var game:Node
var role="host"
var passes=0
var failures=0
var joins=0
func _initialize() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--role="):role=arg.trim_prefix("--role=")
 run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func until(condition:Callable,limit:float=70.0) -> bool:
 var end=Time.get_ticks_msec()+int(limit*1000)
 while not condition.call():
  if Time.get_ticks_msec()>end:check(false,"network condition timed out "+role);return false
  await process_frame
 return true
func move_to(p:Vector3) -> bool:
 var end=Time.get_ticks_msec()+35000
 while true:
  var a=game.avatars[game.local_id];var delta=p-a.position;delta.y=0
  if delta.length()<1:return true
  if Time.get_ticks_msec()>end:check(false,"guest walking timed out "+str(a.position));return false
  game.yaw=atan2(-delta.x,-delta.z);game.submit_input(Vector2(0,-1),game.yaw,0,false,true,false);await physics_frame
 return false
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.bot_mode="network";game.test_mode=true;game.store.disabled=true
 if role=="host":await host_flow()
 else:await guest_flow()
 game.active=false;game.queue_free();await process_frame;print("TEST_SUMMARY hunt_network ",role," passes=",passes," failures=",failures);quit(1 if failures else 0)
func host_flow() -> void:
 game.multiplayer.peer_connected.connect(func(_id):joins+=1)
 game.start_host(true,"Host",999001)
 game.add_track(Vector3(40,2,40),.7,888)
 if not await until(func():return game.avatars.size()==4):return
 check(true,"host plus three independent guests joined hunting world")
 if not await until(func():return game.progress.sold>=1):return
 check(game.progress.wallet>=50 and game.progress.ammo==11,"host validates guest purchase shot and single sale")
 if not await until(func():return game.accepted_sessions>=4):return
 if not await until(func():return game.avatars.size()==1):return
 check(game.progress.sold==1,"disconnect and rejoin cannot duplicate harvest")
func guest_flow() -> void:
 game.start_join("127.0.0.1",role)
 if not await until(func():return game.active and game.avatars.size()==4):return
 check(game.animals.size()==5,"guest receives all wildlife identities")
 if not await until(func():return game.trail_history_received):return
 var shared=false
 for track in game.forest.tracks:
  if track.id==888 and track.p==Vector3(40,2,40) and absf(track.heading-.7)<.001:shared=true
 check(shared,"late guest receives existing host trail identity position and heading")
 if role!="guest0":
  var a=game.avatars[game.local_id];var before=a.position
  for i in range(40):game.submit_input(Vector2(1,0),0,0,false,false,false);await physics_frame
  check(a.position.distance_to(before)>1,"independent guest movement is host-simulated")
  if not await until(func():return game.progress.sold==1):return
  check(game.progress.wallet>=50,"other guest receives shared sale reward")
  game.end_session();return
 if not await move_to(game.C.SHOP+Vector3(0,0,3)):return
 game.submit_input(Vector2.ZERO,0,0,false,false,false);game.send_action("buy",{"upgrade":"rifle"});game.action_request.rpc_id(1,game.command_sequence,"buy",{"upgrade":"rifle"})
 if not await until(func():return "rifle" in game.progress.upgrades):return
 check(game.progress.wallet==15 and game.progress.ammo==12,"guest purchase and repeated sequence charge only once")
 if not await move_to(Vector3(0,0,24)):return
 if not await move_to(Vector3(0,0,8)):return
 var animal=game.animals.values()[0]
 var end=Time.get_ticks_msec()+15000
 while animal.hp>0:
  if Time.get_ticks_msec()>end:check(false,"guest shot timed out");return
  var a=game.avatars[game.local_id];var d=animal.position+Vector3.UP*1.2*animal.size_factor-(a.position+Vector3.UP*1.58);game.yaw=atan2(-d.x,-d.z);game.pitch=atan2(d.y,Vector2(d.x,d.z).length())
  game.submit_input(Vector2.ZERO,game.yaw,game.pitch,false,false,true);await physics_frame
  if float(a.fishing.get("steady",0))>.9:game.send_action("fire",{})
 check(not animal.authority and animal.shots==1,"guest sees host-authored clean harvest without local AI")
 if not await move_to(animal.position+Vector3(0,0,2)):return
 game.submit_input(Vector2.ZERO,0,0,false,false,false);game.send_action("pickup",{})
 if not await until(func():return game.avatars[game.local_id].held==animal.entity_id):return
 check(true,"guest retrieves host wildlife")
 if not await move_to(Vector3(0,0,24)):return
 if not await move_to(game.C.EXCHANGE+Vector3(0,0,3)):return
 game.submit_input(Vector2.ZERO,0,0,false,false,false);game.send_action("interact",{})
 if not await until(func():return game.progress.sold==1):return
 check(game.progress.wallet>=50,"guest banks shared harvest reward")
 game.end_session();await create_timer(.3).timeout;game.start_join("127.0.0.1","Rejoined")
 if not await until(func():return game.active):return
 check(game.progress.sold==1 and "rifle" in game.progress.upgrades,"rejoin restores host progression and equipment")
 if not await until(func():return game.trail_history_received):return
 check(game.forest.tracks.size()>9,"rejoin restores recent moving wildlife trails")
 game.end_session()
