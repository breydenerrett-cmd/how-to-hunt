extends SceneTree
var game:Node
var passes=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="gear";game.start_host(false,"Gear fixture",999125);game.set_physics_process(false)
 var a=game.avatars[1];a.position=game.C.SHOP;game.buy(a,"rifle");game.progress.wallet=300
 var old=game.progress.duplicate(true)
 check(game.C.valid_progress(old),"existing schema1 hunting ledger still loads without stealth items")
 for id in ["boots","overshirt","scent","muffler"]:game.buy(a,id)
 check(game.progress.wallet==40 and game.progress.upgrades.size()==5,"four party upgrades charge exact catalogue prices")
 game.buy(a,"boots");check(game.progress.wallet==40,"duplicate stealth equipment cannot charge twice")
 a.visual_speed=4.5;a.surface_name="leaf litter";a.input_sprint=false;a.crouched=false
 var ordinary=game.Stealth.movement_noise(a);var boots=game.Stealth.movement_noise(a,["boots"]);var wool=game.Stealth.movement_noise(a,["boots","overshirt"])
 check(is_equal_approx(boots,ordinary*.6) and is_equal_approx(wool,ordinary*.48),"movement upgrades stack as documented from actual speed")
 a.noise=0
 check(game.Stealth.detection(a,10,true,false)>0 and game.Stealth.detection(a,10,true,false,["overshirt"])==0,"wool reduces sight range while stationary")
 check(game.Stealth.scent_radius([])==9 and game.Stealth.scent_radius(["scent"])==4,"scent gear retains finite close-range detection")
 for id in ["boots","overshirt","scent","muffler"]:
  var display=game.forest.displays.get(id)
  check(display!=null and display.get_child_count()>0 and display.global_position.distance_to(game.C.SHOP)<8,"stealth equipment has reachable physical shop display")
 # Real shots in an isolated fixture; world physics and saves are paused, raycasting is real.
 for d in game.animals.values():d.queue_free()
 game.animals.clear();await physics_frame
 a.position=Vector3(200,.1,0);a.input_pitch=0;a.input_yaw=0;a.held=-1;a.reload_until=0;a.eye_height=1.58;a.magazines.rifle=4;game.progress.ammo=12
 var near=game.spawn_animal(Vector3(204,.1,0));var middle=game.spawn_animal(Vector3(220,.1,0));var far=game.spawn_animal(Vector3(240,.1,0))
 game.progress.upgrades.erase("muffler");await physics_frame;game.fire(a)
 check(near.alert>middle.alert and middle.alert>0 and far.alert==0,"real unsuppressed shot creates distance falloff within30m")
 for d in game.animals.values():d.alert=0
 game.progress.upgrades.append("muffler");game.clock+=1;game.fire(a)
 check(near.alert>0 and near.alert<.7 and middle.alert==0,"real muffled shot still warns close quarry while leaving distant quarry calm")
 game.V.box(game,Vector3(200,1,-12),Vector3(8,2,.2),Color.GRAY,true)
 var impact_deer=game.spawn_animal(Vector3(201,.1,-13));await physics_frame;game.clock+=1;game.fire(a)
 check(impact_deer.alert>.3 and impact_deer.threat_position.distance_to(Vector3(200,1.68,-11.9))<.2,"suppressed miss alerts quarry beside actual struck surface")
 game.gun.presentation(false,game.clock,false,.65,true)
 check(game.gun.muffler.visible,"purchased barrel attachment has a visible first-person model")
 var ledger=game.progress.duplicate(true);ledger.animals=[];check(game.C.valid_progress(ledger),"new equipment ids remain valid in schema1 saves")
 var store=game.Store.new();store.slot=999126
 var path=store.path();var exists=false
 for suffix in ["",".bak",".bak2",".tmp"]:exists=exists or FileAccess.file_exists(path+suffix)
 if exists:check(false,"reserved storage fixture slot must be unused")
 else:
  check(store.save_world(ledger) and store.load_world().upgrades==ledger.upgrades,"new equipment persists through actual storage write and reload")
  for suffix in ["",".bak",".bak2",".tmp"]:
   if FileAccess.file_exists(path+suffix):DirAccess.remove_absolute(ProjectSettings.globalize_path(path+suffix))
 game.active=false;game.sound.stop_all();game.queue_free();await process_frame;print("TEST_SUMMARY hunt_gear passes=",passes," failures=",failures);quit(1 if failures else 0)
