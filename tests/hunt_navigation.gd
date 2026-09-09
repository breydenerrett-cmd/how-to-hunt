extends SceneTree
var game:Node
var passes=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func walk_case(start:Vector3,goal:Vector3,label:String) -> void:
 var deer=game.spawn_animal(game.forest.point(start.x,start.z)+Vector3.UP*.1)
 deer.home=goal;deer.state="walk";deer.timer=1000;deer.wander=Vector3.ZERO
 var max_step=0.0;var began=Time.get_ticks_msec();var before=deer.position
 while Vector2(deer.position.x-goal.x,deer.position.z-goal.z).length()>1 and Time.get_ticks_msec()-began<65000:
  await physics_frame
  max_step=maxf(max_step,deer.position.distance_to(before));before=deer.position
 check(Vector2(deer.position.x-goal.x,deer.position.z-goal.z).length()<=1,label+" reached destination through real wildlife movement")
 check(max_step<.25 and deer.hp==70,label+" remains physical without warp/damage")
 print("NAV_ROUTE ",label," seconds=",(Time.get_ticks_msec()-began)/1000.0," max_step=",max_step," replans=",deer.route_replans," end=",deer.position)
 game.animals.erase(deer.entity_id);deer.queue_free();await physics_frame
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="navigation";game.start_host(false,"Navigation",999077)
 var a=game.avatars[1];a.health=0;game.avatars.erase(1);a.queue_free()
 for d in game.animals.values():d.queue_free()
 game.animals.clear();await physics_frame
 var routes=game.forest.routes
 check(not routes.open(routes.cell(game.C.SHOP)),"wildlife map excludes lodge interior")
 check(not routes.open(routes.cell(game.forest.tree_positions[0])),"wildlife map excludes real collidable tree")
 var path=routes.route(Vector3(-12,0,18),Vector3(0,0,18))
 check(path.size()>2,"route bends around solid lodge instead of crossing it")
 var clear=true
 for i in range(1,path.size()):clear=clear and routes.clear_line(path[i-1],path[i])
 check(clear,"smoothed route retains clearance through every corner")
 var boundary=routes.escape(Vector3(0,0,64),Vector3(0,0,50),Vector3(0,0,55));var safe=not boundary.is_empty()
 for p in boundary:safe=safe and p.z<65 and p.z> -105 and absf(p.x)<86
 check(safe,"edge flee route stays inside emergency recovery bounds")
 await walk_case(Vector3(-12,0,18),Vector3(0,0,18),"lodge detour")
 var tree:Vector3=game.forest.tree_positions[0];var start=routes.point(routes.nearest(tree+Vector3(-4,0,0)));var goal=routes.point(routes.nearest(tree+Vector3(4,0,0)))
 await walk_case(start,goal,"tree detour")
 var deer=game.spawn_animal(game.forest.point(0,-10));var hunter=game.add_avatar(1,"Scent")
 hunter.position=deer.position+Vector3(-.8,0,-.6)*8;hunter.previous_position=hunter.position;hunter.input_reel=true
 deer.alert=0;deer.timer=1000
 var alert_seen=false
 for i in range(100):
  game.submit_input(Vector2.ZERO,0,0,false,false,true);await physics_frame
  if deer.state=="alert":alert_seen=true
 check(alert_seen,"upwind quiet hunter prompts visible alert before flight")
 check(deer.alert>.5,"scent reaches deer from upwind beyond quiet sight radius")
 var start_pos=deer.position;deer.alert=1;deer.threat_position=hunter.position
 var max_step=0.0
 for i in range(170):
  var before=deer.position;game.submit_input(Vector2.ZERO,0,0,false,true,false);await physics_frame
  max_step=maxf(max_step,deer.position.distance_to(before))
 check(deer.position.distance_to(start_pos)>4 and max_step<.3,"flee route gains distance without teleporting")
 var snapshot=game.forest.trail_snapshot();game.forest.restore_trails(snapshot)
 check(game.forest.tracks.size()==snapshot.size(),"trail history restoration preserves bounded count")
 check(game.forest.tracks[-1].id==snapshot[-1].id and game.forest.tracks[-1].p==snapshot[-1].p,"trail history preserves animal identity and position")
 var older=game.forest.trail_snapshot();older[0].age=12;game.forest.restore_trails(older)
 check(absf(game.forest.time-game.forest.tracks[0].time-12)<.01,"trail history retains age in receiver clock")
 game.active=false;game.queue_free();await process_frame
 print("TEST_SUMMARY hunt_navigation passes=",passes," failures=",failures);quit(1 if failures else 0)
