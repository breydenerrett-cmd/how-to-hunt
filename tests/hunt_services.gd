extends SceneTree
var game:Node
var passes=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="services"
 game.start_host(false,"Service fixture",999097);game.set_physics_process(false)
 var a=game.avatars[1];a.position=game.C.SHOP
 var before=game.progress.duplicate(true);game.is_host=false;game.buy(a,"rifle")
 check(game.progress==before,"guest cannot invoke purchase mutation directly")
 game.is_host=true;a.health=0;game.buy(a,"rifle")
 check(game.progress==before,"downed hunter cannot purchase directly")
 a.health=100;game.buy(a,"rifle")
 check(game.progress.wallet==15 and game.progress.ammo==12,"host purchase uses catalogue price and shared ammunition")
 var animal=game.animals.values()[0];animal.hp=0;animal.holder=1;a.held=animal.entity_id
 before=game.progress.duplicate(true);game.sell(a)
 check(game.progress==before and game.animals.has(animal.entity_id),"direct sale away from exchange preserves harvest and wallet")
 a.position=game.C.EXCHANGE;game.is_host=false;game.sell(a)
 check(game.progress==before and a.held==animal.entity_id,"guest cannot bank a harvest directly")
 game.is_host=true;animal.holder=42;game.sell(a)
 check(game.progress==before,"another hunter's harvest cannot be sold")
 animal.holder=1;var value=animal.value();game.sell(a);var wallet=game.progress.wallet;game.sell(a)
 check(wallet==before.wallet+value and game.progress.wallet==wallet and a.held<0,"unique harvest is consumed once before reward effects")
 # A second independent party must not inherit or mutate the first party's ledger.
 var other=game.C.new_progress();var original=game.progress.duplicate(true)
 var result=game.Economy.purchase(other,"rifle",true)
 check(result.ok and other.wallet==15 and game.progress==original,"separate party economy has no shared mutable ledger")
 game.trail_history_received=true;game.last_commands[7]=77;game.last_inputs[7]=88
 game.end_session("Fixture closed")
 check(not game.active and not game.is_host and game.avatars.is_empty() and game.animals.is_empty(),"session teardown clears all actors and authority")
 check(game.last_commands.is_empty() and game.last_inputs.is_empty() and not game.trail_history_received,"session teardown clears input admission and trail bootstrap state")
 await process_frame
 game.start_host(false,"Second hunt",999098);game.set_physics_process(false)
 check(game.active and game.avatars.size()==1 and game.animals.size()==5 and game.progress.wallet==40 and game.progress.upgrades.is_empty(),"same process starts a fresh independent hunt after teardown")
 game.start_host(false,"Duplicate",999099)
 check(game.store.slot==999098 and game.avatars.size()==1,"active host cannot silently replace its world")
 game.active=false;game.sound.stop_all();game.queue_free();await process_frame
 print("TEST_SUMMARY hunt_services passes=",passes," failures=",failures);quit(1 if failures else 0)
