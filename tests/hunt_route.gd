extends SceneTree
var game:Node
var a:Node3D
var passes=0
var failures=0
var pathfinder=AStarGrid2D.new()
var max_step=0.0
var started=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func tick(move:Vector2=Vector2.ZERO,aim:bool=false,sprint:bool=false) -> void:
 game.submit_input(move,game.yaw,game.pitch,false,sprint,aim);var before=a.position
 await physics_frame
 max_step=maxf(max_step,a.position.distance_to(before))
func cell(p:Vector3) -> Vector2i:return Vector2i(roundi(p.x/2),roundi(p.z/2))
func walk(target:Vector3,stop:float=.75) -> bool:
 var start_time=Time.get_ticks_msec()
 var start_cell=cell(a.position);var end=cell(target);pathfinder.set_point_solid(start_cell,false);pathfinder.set_point_solid(end,false)
 var path=pathfinder.get_id_path(start_cell,end)
 if path.is_empty():check(false,"route planner finds walking path");return false
 for i in range(1,path.size()):
  var point=Vector3(path[i].x*2,0,path[i].y*2)
  if i==path.size()-1:point=target
  while Vector2(point.x-a.position.x,point.z-a.position.z).length()>(stop if i==path.size()-1 else 1.0):
   if Time.get_ticks_msec()-start_time>50000:check(false,"walk timed out at "+str(a.position)+" toward "+str(point));return false
   var delta=point-a.position;game.yaw=atan2(-delta.x,-delta.z);game.pitch=0;await tick(Vector2(0,-1),false,true)
 await tick();return true
func aim_at(animal:Node3D) -> void:
 var delta=animal.position+Vector3.UP*1.2*animal.size_factor-(a.position+Vector3.UP*1.58)
 game.yaw=atan2(-delta.x,-delta.z);game.pitch=atan2(delta.y,Vector2(delta.x,delta.z).length())
func hunt(animal:Node3D) -> bool:
 var began=Time.get_ticks_msec();var id=animal.entity_id
 while animal.hp>0:
  if Time.get_ticks_msec()-began>65000:check(false,"hunt timed out");return false
  if animal.elite and animal.state in ["windup","charge"]:
   aim_at(animal);await tick(Vector2(1,0),false,true);continue
  if a.position.distance_to(animal.position)>(14 if animal.elite else 23):
   var approach=animal.position+(a.position-animal.position).normalized()*(11 if animal.elite else 17)
   if not await walk(approach,1.5):return false
  aim_at(animal);await tick(Vector2.ZERO,true)
  if a.magazines.rifle<=0 and a.reload_until<=0:game.send_action("reload",{})
  if float(a.fishing.get("steady",0))>.90 and a.reload_until<=0 and game.clock>a.next_shot and (not animal.elite or animal.shots==0 or animal.state=="recover"):
   game.send_action("fire",{});print("ROUTE_SHOT id=",id," hp=",animal.hp," range=",a.position.distance_to(animal.position))
   if animal.hp>0 and animal.shots==0:
    if not await walk(a.position+(animal.position-a.position).normalized()*3,1):return false
 check(animal.shots>=1,"wildlife downed through real rifle raycasts")
 if not await walk(animal.position,2.4):return false
 game.send_action("pickup",{});check(a.held==id,"walked to downed deer and retrieved it")
 if not await walk(game.C.EXCHANGE+Vector3(0,0,2),.9):return false
 var before=game.progress.wallet;game.send_action("interact",{});check(game.progress.wallet>before and a.held<0,"walked harvest to exchange and earned credits")
 return true
func run() -> void:
 started=Time.get_ticks_msec();game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="route";game.start_host(false,"Earned route",992000);a=game.avatars[1]
 pathfinder.region=Rect2i(-43,-52,87,86);pathfinder.cell_size=Vector2.ONE*2;pathfinder.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES;pathfinder.update()
 for x in range(-43,44):
  for z in range(-52,34):
   var p=Vector3(x*2,0,z*2)
   for tree in game.forest.tree_positions:
    if Vector2(p.x-tree.x,p.z-tree.z).length()<2:pathfinder.set_point_solid(Vector2i(x,z),true);break
 for x in range(-5,0):
  for z in range(7,11):pathfinder.set_point_solid(Vector2i(x,z),true)
 for x in range(2,6):
  for z in range(10,12):pathfinder.set_point_solid(Vector2i(x,z),true)
 for i in range(20):await tick()
 check(a.is_on_floor(),"real camp terrain supports the avatar")
 check(game.progress.wallet==40 and game.progress.upgrades.is_empty(),"earned route starts with normal credits and no equipment")
 if not await walk(game.C.SHOP+Vector3(0,0,3),1):await finish();return
 game.send_action("buy",{"upgrade":"rifle"});check("rifle" in game.progress.upgrades and game.progress.wallet==15,"walked to lodge and purchased starter rifle")
 if not await walk(Vector3(0,0,9)):await finish();return
 var first=game.animals.values()[0]
 if not await hunt(first):await finish();return
 if not await walk(game.C.SHOP+Vector3(0,0,3),1):await finish();return
 game.send_action("buy",{"upgrade":"pack"});check("pack" in game.progress.upgrades,"first hunt affords a useful upgrade")
 if not await walk(Vector3(0,0,8)):await finish();return
 var second=game.animals.values()[0]
 if not await hunt(second):await finish();return
 check(game.progress.contract==1,"earned two-deer route unlocks Crownback")
 if "--crownback" in OS.get_cmdline_user_args():
  if not await walk(Vector3(0,0,12)):await finish();return
  var crown:Node3D
  for d in game.animals.values():
   if d.elite:crown=d
  if not await hunt(crown):await finish();return
  check(game.progress.contract==2,"earned Crownback hunt banks the final contract")
 check(max_step<.4,"movement used physics inputs without teleport steps")
 check(game.progress.ammo>=0 and a.health>0,"ordinary earned route stays alive and solvent")
 await finish()
func finish() -> void:
 print("HUNT_ROUTE_RESULT ",JSON.stringify({"seconds":(Time.get_ticks_msec()-started)/1000.0,"wallet":game.progress.wallet,"ammo":game.progress.ammo,"sold":game.progress.sold,"max_step":max_step,"health":a.health}))
 game.active=false;game.queue_free();await process_frame;print("TEST_SUMMARY hunt_route passes=",passes," failures=",failures);quit(1 if failures else 0)
