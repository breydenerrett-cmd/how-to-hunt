extends SceneTree
var game:Node
var passes=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func wait(seconds:float) -> void:await create_timer(seconds).timeout
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="rules";game.start_host(false,"Rule fixture",991001);game.set_physics_process(false)
 var C=game.C;var a=game.avatars[1]
 check(C.valid_progress(C.new_progress()),"new hunting save validates")
 check(ProjectSettings.get_setting("application/config/name")=="How to Hunt","independent application/save namespace")
 var bad=C.new_progress();bad.game="catch_catastrophe";check(not C.valid_progress(bad),"fishing identity rejected")
 bad=C.new_progress();bad.wallet=NAN;check(not C.valid_progress(bad),"nonfinite balance rejected")
 check(game.progress.wallet==40 and game.progress.upgrades.is_empty(),"paid empty-hands start")
 var cash=game.progress.wallet;game.buy(a,"rifle");check(game.progress.wallet==cash,"remote camp purchase rejected")
 a.position=C.SHOP;game.buy(a,"rifle");check(game.progress.wallet==15 and game.progress.ammo==12 and "rifle" in game.progress.upgrades,"rifle purchased with normal credits and ammunition")
 game.buy(a,"rifle");check(game.progress.wallet==15,"duplicate equipment cannot charge twice")
 a.action_gate=game.Gate.new();game.accept_action(1,100,"buy",{"upgrade":"ammo"});var ammo=game.progress.ammo;game.accept_action(1,100,"buy",{"upgrade":"ammo"});check(game.progress.ammo==ammo and game.progress.wallet==7,"duplicate sequence cannot purchase ammunition twice")
 game.accept_action(1,101,"buy",{"upgrade":"ammo","cost":0});check(game.progress.wallet==7,"forged purchase payload rejected")
 var animal=game.animals.values()[0];animal.position=Vector3(0,.1,0);animal.home=animal.position;a.position=Vector3(0,.1,8);a.input_yaw=0;a.input_pitch=-.035;a.input_reel=true;a.fishing.steady=1.0
 await wait(.1)
 var hp=animal.hp;game.fire(a);check(animal.hp<hp,"production raycast damages visible deer")
 check(animal.hp==0 and animal.shots==1 and animal.value()>animal.base_value,"steady shot yields clean harvest premium")
 var rounds=game.progress.ammo;game.fire(a);check(game.progress.ammo==rounds,"cooldown blocks rapid duplicate fire")
 a.position=Vector3(0,0,1);game.pickup(a);check(a.held==animal.entity_id and animal.holder==1,"dead animal can be retrieved")
 var id=a.held;game.drop(a);check(a.held<0 and game.animals[id].holder<0,"harvest can be put down and retrieved again")
 game.pickup(a);a.position=C.EXCHANGE+Vector3(0,0,2);cash=game.progress.wallet;var value=animal.value();game.interact(a);check(game.progress.wallet==cash+value and not game.animals.has(id),"exchange banks exactly the harvested value")
 game.interact(a);check(game.progress.wallet==cash+value,"repeated sell does not duplicate reward")
 var second=game.animals.values()[0];second.hp=0;second.position=a.position+Vector3(1,0,0);game.pickup(a);game.interact(a)
 check(game.progress.contract==1,"two sales unlock Crownback contract")
 var crown:Node3D
 for d in game.animals.values():
  if d.elite:crown=d
 check(crown!=null,"contract spawns distinct larger Crownback")
 crown.hp=0;crown.position=a.position+Vector3(1,0,0);game.pickup(a);game.interact(a);check(game.progress.contract==2,"Crownback harvest completes its contract")
 var snapshot=game.state_packet();var wire=game.Wire.new();var restored={};var parts=game.Wire.encode(snapshot)
 for n in range(parts.size()):restored=wire.accept(snapshot.revision,n,parts.size(),parts[n])
 check(restored==snapshot,"bounded snapshot roundtrip preserves hunting state")
 var saved=game.progress.duplicate(true);saved.animals=[]
 for d in game.animals.values():saved.animals.append(d.saved())
 check(C.valid_progress(saved),"actual wildlife state validates for saving")
 a.position=C.SHOP;game.progress.wallet=0;game.progress.ammo=0;game.interact(a);check(game.progress.ammo==4,"bankrupt empty-ammo hunter has free recovery")
 game.progress.ammo=10;a.magazines.rifle=0;a.reload_until=0;game.clock+=1;game.accept_action(1,102,"reload",{});check(a.reload_until>game.clock,"real reload action starts without ammo grant")
 a.position=C.CAMP;var before=a.position;game.accept_input(1,10,Vector2.INF,NAN,0,false,false,false);check(a.position==before and not game.last_inputs.has(1),"invalid movement input rejected")
 game.accept_input(1,11,Vector2(10,0),0,0,false,false,false);check(a.input_move.length()<=1,"client movement magnitude clamped")
 for d in game.animals.values():
  var state=d.saved();d.visual_step(.2,0);check(d.saved()==state,"animation cannot change wildlife identity/value/save")
 game.active=false;game.queue_free();await process_frame;print("TEST_SUMMARY hunt_rules passes=",passes," failures=",failures);quit(1 if failures else 0)
