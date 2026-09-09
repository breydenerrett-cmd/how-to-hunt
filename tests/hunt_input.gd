extends SceneTree
## Guards controller reachability. Fire and aim were once read straight off the mouse, so a
## controller could move and look but never shoot or steady. This fails if any gameplay
## action ships without a pad binding.
var passes=0
var failures=0
const GAMEPLAY:=["forward","back","left","right","jump","crouch","sprint","interact","pickup","drop","reload","fire","aim","journal","pause"]
const LOOK:=["look_left","look_right","look_up","look_down"]
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func kinds(action:String) -> Dictionary:
 var found={"key":false,"pad":false}
 if not InputMap.has_action(action):return found
 for e in InputMap.action_get_events(action):
  if e is InputEventKey or e is InputEventMouseButton:found.key=true
  if e is InputEventJoypadButton or e is InputEventJoypadMotion:found.pad=true
 return found
func _initialize() -> void:
 # Instantiating during _initialize runs before the scene tree is ready, so _ready and
 # therefore setup_inputs would not have run when the assertions execute.
 run.call_deferred()
func run() -> void:
 var game=load("res://main.tscn").instantiate();game.bot_mode="input";game.store.disabled=true
 root.add_child(game)
 var missing_action=[];var missing_pad=[];var missing_key=[]
 for action in GAMEPLAY:
  if not InputMap.has_action(action):missing_action.append(action);continue
  var k=kinds(action)
  if not k.pad:missing_pad.append(action)
  if not k.key:missing_key.append(action)
 check(missing_action.is_empty(),"every gameplay action is registered %s"%[missing_action])
 check(missing_pad.is_empty(),"every gameplay action is reachable from a controller %s"%[missing_pad])
 check(missing_key.is_empty(),"every gameplay action is reachable from keyboard or mouse %s"%[missing_key])
 var look_ok=true
 for action in LOOK:
  if not kinds(action).pad:look_ok=false
  # A 0.5 deadzone swallows the small stick movements aiming depends on.
  if InputMap.has_action(action) and InputMap.action_get_deadzone(action)>.2:look_ok=false
 check(look_ok,"right stick look is bound with an aiming-grade deadzone")
 check(kinds("fire").key and kinds("fire").pad,"fire works on both mouse and trigger")
 check(kinds("aim").key and kinds("aim").pad,"aim works on both mouse and trigger")
 # Aim mode. A latched aim must never survive into a state where the rifle is not in hand,
 # or the player returns from a menu or a carry already scoped with no way to tell.
 game.aim_toggle=true;game.aim_latched=true
 check(game.aim_active(),"toggle mode reports aim from the latch")
 game.ui.panel.show()
 check(not game.aim_active(),"an open panel suppresses a latched aim")
 game.ui.panel.hide()
 game.aim_toggle=false
 check(not game.aim_active(),"hold mode ignores a stale latch when nothing is pressed")
 game.aim_toggle=true;game.aim_latched=true;game.begin_view()
 check(not game.aim_latched,"entering the world clears any latched aim")
 game.active=false;game.queue_free();await process_frame
 print("TEST_SUMMARY hunt_input passes=",passes," failures=",failures);quit(1 if failures else 0)
