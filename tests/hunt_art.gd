extends SceneTree
var game:Node
var passes=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="art";game.start_host(false,"Art fixture",999086);game.set_physics_process(false)
 for d in game.animals.values():
  var original=d.saved();var transform=d.transform;var hit=d.head_hit.transform
  for pose in ["graze","alert","flee","windup","recover","down"]:
   for frame in range(30):d.view.pose(1.0/60,pose,0 if pose=="down" else 70,-.85 if pose=="graze" else .05,4.7 if pose=="flee" else 0,.65,d.entity_id)
  check(d.saved()==original and d.transform==transform and d.head_hit.transform==hit,"all model poses preserve physical and saved identity")
 var animal=game.animals.values()[0]
 for i in range(120):animal.view.pose(1.0/60,"down",0,.05,0,.65,1)
 var center=animal.view.transform*Vector3(0,1.1,0)
 check(absf(center.x)<.1 and center.y>.20 and center.y<.5,"laid-down torso stays centered and above terrain instead of rolling underground")
 for i in range(90):animal.view.pose(1.0/60,"flee",70,.05,4.7,0,1)
 check(absf(animal.view.legs[0].rotation.x)>.05,"reduced motion retains essential walking leg articulation")
 check(absf(animal.view.position.y)<.01,"reduced motion suppresses decorative body bounce")
 var meshes:Array[MeshInstance3D]=[];preload("res://hunt/sculpt.gd").collect(animal.view,meshes)
 var valid=true;var count=0
 for mesh in meshes:
  var bounds=mesh.mesh.get_aabb();valid=valid and bounds.position.is_finite() and bounds.size.is_finite()
  for surface in range(mesh.mesh.get_surface_count()):
   var arrays=mesh.mesh.surface_get_arrays(surface)
   for vertex in arrays[Mesh.ARRAY_VERTEX]:valid=valid and vertex.is_finite();count+=1
 check(valid and count>1000,"rendered animal meshes contain finite nontrivial geometry")
 var progress=game.progress.duplicate(true);var gun=game.gun
 gun.presentation(true,10,true,.65);gun.presentation(true,10.7,true,.65)
 check(gun.scope.visible and absf(gun.bolt.rotation.z)>.3,"purchased sight and reloading mechanism have visible poses")
 gun.presentation(false,12,false,0)
 check(not gun.scope.visible and gun.bolt.rotation.z==0 and game.progress==progress,"weapon presentation cannot grant equipment ammo or rewards")
 meshes.clear();preload("res://hunt/sculpt.gd").collect(gun,meshes)
 var no_shadow=true
 for mesh in meshes:no_shadow=no_shadow and mesh.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 check(no_shadow,"first-person-only weapon and hands do not cast floating world shadows")
 var details=game.forest.find_child("LodgeDetailsBatch",true,false);var colors=details.mesh.surface_get_arrays(0)[Mesh.ARRAY_COLOR];var colored=false
 for color in colors:
  if color.r>color.b*1.2 and color.r<.9:colored=true;break
 check(colored,"static camp batching preserves original wood vertex colors")
 game.active=false;game.sound.stop_all();game.queue_free();await process_frame;print("TEST_SUMMARY hunt_art passes=",passes," failures=",failures);quit(1 if failures else 0)
