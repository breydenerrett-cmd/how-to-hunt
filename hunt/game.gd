extends Node3D
## Hunting orchestration. Reuses the fishing avatar, command gate, wire and storage layers.
const C=preload("res://hunt/catalog.gd")
const V=preload("res://scripts/visuals.gd")
const Avatar=preload("res://scripts/avatar.gd")
const Deer=preload("res://hunt/deer.gd")
const Forest=preload("res://hunt/forest.gd")
const Hud=preload("res://hunt/ui.gd")
const Store=preload("res://scripts/save_store.gd")
const Wire=preload("res://scripts/snapshot_wire.gd")
const Gate=preload("res://scripts/action_gate.gd")
const Session=preload("res://hunt/session.gd")
const Economy=preload("res://hunt/economy.gd")
const Stealth=preload("res://hunt/stealth.gd")
const Sound=preload("res://scripts/sound.gd")
const Touch=preload("res://hunt/touch.gd")
var shutting_down=false
var accepted_sessions=0
var trail_history_received=false
var active=false
var is_host=false
var online=false
var local_id=1
var nickname="Ranger"
var avatars:Dictionary={}
var animals:Dictionary={}
var progress=C.new_progress()
var store=Store.new()
var wire=Wire.new()
var forest:Node3D
var ui:CanvasLayer
var camera:Camera3D
var gun:Node3D
var sound:Node
var touch:CanvasLayer
var clock=0.0
var yaw=0.0
var pitch=-.08
var motion=.65
var ui_scale=1.0
var recoil=0.0
var next_sequence=0
var command_sequence=0
var revision=0
var last_revision=-1
var last_inputs:Dictionary={}
var last_commands:Dictionary={}
var snapshot_timer=0.0
var save_timer=0.0
var save_pending=false
var join_started=-1.0
var test_mode=false
var bot_mode=""
var capture_path=""
var capture_elapsed=0.0
const PAD_LOOK_SPEED:=3.1
var pad_invert_y=false
# Hold-to-aim needs a sustained right click, which is miserable on a trackpad: a two-finger
# press held down while the same surface is dragged to look. Toggle mode makes aim a state.
var aim_toggle=false
var aim_latched=false
var footstep=0.0
var tracked_id=-1
var tracked_until=0.0
func _ready() -> void:
 get_tree().auto_accept_quit=false;get_tree().multiplayer_poll=false;multiplayer.server_relay=false
 for arg in OS.get_cmdline_user_args():
  if arg=="--preview":store.disabled=true
  if arg=="--test" and OS.has_feature("editor"):test_mode=true;store.disabled=true
  if arg.begins_with("--bot=") and OS.has_feature("editor"):bot_mode=arg.trim_prefix("--bot=")
  if arg.begins_with("--capture="):capture_path=arg.trim_prefix("--capture=");store.disabled=true
 setup_inputs();load_settings()
 forest=Forest.new();add_child(forest);sound=Sound.new();add_child(sound)
 camera=Camera3D.new();add_child(camera);camera.current=true;camera.far=260;camera.position=Vector3(13,8,35);camera.look_at(Vector3(0,1,12))
 gun=Forest.rifle(camera);gun.scale=Vector3.ONE*.7;gun.position=Vector3(.3,-.32,-.80);V.hand(gun,Vector3(.035,-.09,.02));var fore=V.hand(gun,Vector3(-.02,-.10,-.35));fore.rotation.y=1.0;preload("res://hunt/sculpt.gd").viewmodel(gun);gun.hide()
 ui=Hud.new();ui.game=self;add_child(ui)
 touch=Touch.new();touch.game=self;add_child(touch)
 # A finger cannot hold a button and drag to look at the same time, so hold-to-aim is not
 # physically possible on a touchscreen. The trackpad toggle mode is the same solution.
 if touch.active:aim_toggle=true
 multiplayer.connected_to_server.connect(func():local_id=multiplayer.get_unique_id();hello.rpc_id(1,C.PROTOCOL,C.VERSION,nickname))
 multiplayer.connection_failed.connect(func():end_session("Could not reach host. Check the address and that the host is running."))
 multiplayer.server_disconnected.connect(func():end_session("The host ended the hunt. Banked progress belongs to the host world."))
 multiplayer.peer_disconnected.connect(peer_left)
 for arg in OS.get_cmdline_user_args():
  if arg=="--solo":start_host(false,"Ranger",1)
  if arg=="--host":start_host(true,"Host",3 if test_mode else 1)
  if arg.begins_with("--join="):start_join(arg.trim_prefix("--join="),"Guest")
 print("HUNT_BOOT ",C.VERSION," renderer=",RenderingServer.get_current_rendering_method())
func setup_inputs() -> void:
 var keys={"left":KEY_A,"right":KEY_D,"forward":KEY_W,"back":KEY_S,"jump":KEY_SPACE,"crouch":KEY_CTRL,"sprint":KEY_SHIFT,"interact":KEY_E,"pickup":KEY_F,"drop":KEY_Q,"reload":KEY_R,"journal":KEY_TAB,"pause":KEY_ESCAPE}
 for action in keys:
  if not InputMap.has_action(action):InputMap.add_action(action)
  var ev=InputEventKey.new();ev.physical_keycode=keys[action];InputMap.action_add_event(action,ev)
 # C is an alternative for keyboards where Ctrl-click is reserved by the desktop.
 var crouch_key=InputEventKey.new();crouch_key.physical_keycode=KEY_C;InputMap.action_add_event("crouch",crouch_key)
 # Fire and aim used to be read straight off the mouse, which made them the only two verbs
 # a controller could never reach. As actions, any device can drive them.
 bind_mouse("fire",MOUSE_BUTTON_LEFT);bind_mouse("aim",MOUSE_BUTTON_RIGHT)
 # Standard twin-stick layout: triggers shoot and steady, left stick moves, right stick looks.
 bind_axis("fire",JOY_AXIS_TRIGGER_RIGHT,1.0);bind_axis("aim",JOY_AXIS_TRIGGER_LEFT,1.0)
 bind_axis("forward",JOY_AXIS_LEFT_Y,-1.0);bind_axis("back",JOY_AXIS_LEFT_Y,1.0)
 bind_axis("left",JOY_AXIS_LEFT_X,-1.0);bind_axis("right",JOY_AXIS_LEFT_X,1.0)
 bind_axis("look_left",JOY_AXIS_RIGHT_X,-1.0);bind_axis("look_right",JOY_AXIS_RIGHT_X,1.0)
 bind_axis("look_up",JOY_AXIS_RIGHT_Y,-1.0);bind_axis("look_down",JOY_AXIS_RIGHT_Y,1.0)
 bind_button("jump",JOY_BUTTON_A);bind_button("crouch",JOY_BUTTON_B)
 bind_button("reload",JOY_BUTTON_X);bind_button("interact",JOY_BUTTON_Y)
 bind_button("pickup",JOY_BUTTON_RIGHT_SHOULDER);bind_button("drop",JOY_BUTTON_LEFT_SHOULDER)
 bind_button("sprint",JOY_BUTTON_LEFT_STICK)
 bind_button("pause",JOY_BUTTON_START);bind_button("journal",JOY_BUTTON_BACK)
 # The 0.5 default deadzone is far too coarse for aiming; looking needs finer still.
 for action in ["forward","back","left","right"]:InputMap.action_set_deadzone(action,.20)
 for action in ["look_left","look_right","look_up","look_down"]:InputMap.action_set_deadzone(action,.14)
func ensure_action(action:String) -> void:
 if not InputMap.has_action(action):InputMap.add_action(action)
func bind_button(action:String,button:int) -> void:
 ensure_action(action);var e=InputEventJoypadButton.new();e.button_index=button;InputMap.action_add_event(action,e)
func bind_axis(action:String,axis:int,value:float) -> void:
 ensure_action(action);var e=InputEventJoypadMotion.new();e.axis=axis;e.axis_value=value;InputMap.action_add_event(action,e)
func bind_mouse(action:String,button:int) -> void:
 ensure_action(action);var e=InputEventMouseButton.new();e.button_index=button;InputMap.action_add_event(action,e)
func load_settings() -> void:
 var f=ConfigFile.new()
 if f.load("user://settings.cfg")==OK:motion=clampf(float(f.get_value("controls","motion",.65)),0,1);ui_scale=clampf(float(f.get_value("controls","ui_scale",1)),1,1.2);pad_invert_y=bool(f.get_value("controls","pad_invert_y",false));aim_toggle=bool(f.get_value("controls","aim_toggle",false))
func save_settings() -> void:
 if store.disabled:return
 var f=ConfigFile.new();f.set_value("controls","motion",motion);f.set_value("controls","ui_scale",ui_scale);f.set_value("controls","pad_invert_y",pad_invert_y);f.set_value("controls","aim_toggle",aim_toggle);f.save("user://settings.cfg")
func start_host(networked:bool,player_name:String,slot:int) -> void:
 Session.start_host(self,networked,player_name,slot)
func start_join(address:String,player_name:String) -> void:
 Session.start_join(self,address,player_name)
@rpc("any_peer","call_remote","reliable",0)
func hello(protocol:int,version:String,player_name:String) -> void:
 if not is_host or not active:return
 var id=multiplayer.get_remote_sender_id()
 if protocol!=C.PROTOCOL or version!=C.VERSION:refuse.rpc_id(id,"Build mismatch. Everyone needs How to Hunt "+C.VERSION);return
 if avatars.has(id):return
 if avatars.size()>=4:refuse.rpc_id(id,"The hunt is full.");return
 accepted_sessions+=1;add_avatar(id,clean_name(player_name));bootstrap.rpc_id(id,state_packet());receive_trail_history.rpc_id(id,forest.trail_snapshot());print("HUNT_PEER_ACCEPTED ",id)
@rpc("authority","call_remote","reliable",0)
func refuse(reason:String) -> void:end_session(reason)
@rpc("authority","call_remote","reliable",0)
func bootstrap(packet:Dictionary) -> void:
 if is_host:return
 active=true;join_started=-1;last_revision=-1;apply_state(packet);begin_view();print("HUNT_CLIENT_READY ",local_id)
@rpc("authority","call_remote","reliable",0)
func receive_trail_history(history:Array) -> void:
 if is_host or not active:return
 forest.restore_trails(history);trail_history_received=true
func clean_name(value:String) -> String:
 var s=value.strip_edges().replace("\n","").replace("\r","").left(20);return "Ranger" if s.is_empty() else s
func begin_view() -> void:
 yaw=0;pitch=-.08;aim_latched=false;ui.in_game()
 if avatars.has(local_id):avatars[local_id].body_root.hide();avatars[local_id].name_label.hide()
func add_avatar(id:int,label:String) -> Node3D:
 if avatars.has(id):return avatars[id]
 var a=Avatar.new();a.peer_id=id;a.display_name=label;a.name="Player_%d"%id;add_child(a);a.position=C.CAMP+Vector3((avatars.size()%4)*1.1,0,0);a.target_position=a.position;a.previous_position=a.position;a.last_input=clock;a.magazines={"rifle":mini(4,int(progress.ammo))};a.fishing={"steady":0.0};avatars[id]=a;return a
func seed_animals() -> void:
 for i in range(5):
  var positions=[Vector2(5,-5),Vector2(-16,-28),Vector2(26,-52),Vector2(-30,-62),Vector2(2,-79)]
  var p:Vector2=positions[i];spawn_animal(forest.point(p.x,p.y)+Vector3.UP*.1,.90+i*.11)
func spawn_animal(p:Vector3,size_value:float=1.0,elite:bool=false,id:int=-1) -> Node3D:
 if id<0:
  progress.sequence=int(progress.sequence)+1;id=int(progress.sequence)
  # Nothing guarantees a loaded world's sequence is above every id it restored, and the
  # dictionary write below would silently replace a live animal, leaving its node in the
  # tree still simulating while guests keep rendering the id as the new one.
  while animals.has(id):progress.sequence=int(progress.sequence)+1;id=int(progress.sequence)
 var animal=Deer.new();animal.entity_id=id;animal.authority=is_host;animal.size_factor=size_value;animal.elite=elite;animal.hp=160.0 if elite else 70.0;animal.base_value=150 if elite else int(35*size_value*size_value);animal.position=p;add_child(animal);animals[id]=animal;return animal
func peer_left(id:int) -> void:
 Session.peer_left(self,id)
func end_session(reason:String="Hunt saved. Your camp will be waiting.") -> void:
 Session.end_session(self,reason)
func _notification(what:int) -> void:
 if what==NOTIFICATION_WM_CLOSE_REQUEST:shutdown()
func shutdown() -> void:
 if shutting_down:return
 shutting_down=true
 if is_host and active:save_progress()
 sound.stop_all()
 if DisplayServer.get_name()!="headless":OS.delay_msec(100)
 get_tree().quit()
func _unhandled_input(event:InputEvent) -> void:
 if not active or not bot_mode.is_empty() or not capture_path.is_empty():return
 if event.is_action_pressed("pause") or event.is_action_pressed("journal"):
  if ui.panel.visible:ui.panel.hide();Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
  else:ui.show_panel("journal")
  return
 if ui.panel.visible:return
 if event is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
  yaw-=event.relative.x*.0023;pitch=clampf(pitch-event.relative.y*.0023,-1.3,1.3)
 if aim_toggle and event.is_action_pressed("aim"):aim_latched=not aim_latched
 for action in ["fire","interact","pickup","reload"]:
  if event.is_action_pressed(action):send_action(action,{})
 if event.is_action_pressed("drop"):send_action("drop",{})
func _physics_process(dt:float) -> void:
 multiplayer.poll()
 if not active:return
 if bot_mode.is_empty():
  var enabled=not ui.panel.visible and capture_path.is_empty()
  var aim=aim_active() and enabled
  var stick=touch.move if touch.active else Input.get_vector("left","right","forward","back")
  var crouching=(Input.is_action_pressed("crouch") or touch.crouch) and enabled
  var running=(Input.is_action_pressed("sprint") or touch.sprint) and enabled and not aim
  submit_input(stick*(.5 if aim else 1.0) if enabled else Vector2.ZERO,yaw,pitch,Input.is_action_pressed("jump") and enabled,running,aim,crouching)
 if not is_host:return
 for a in avatars.values():
  if clock-a.last_input>.6:a.input_move=Vector2.ZERO;a.input_sprint=false;a.input_reel=false;a.input_crouch=false
  a.server_step(dt,a.held>=0,.25 if "pack" in progress.upgrades else 0.0,false)
  a.surface_name=Stealth.surface_at(a.position);a.noise=Stealth.movement_noise(a,progress.upgrades)
  var gain=1.54 if "scope" in progress.upgrades else 1.0
  a.fishing.steady=clampf(float(a.fishing.get("steady",0))+dt*gain if a.input_reel and a.visual_speed<2.4 else 0,0,1)
  if a.reload_until>0 and clock>=a.reload_until:a.magazines.rifle=mini(4,int(progress.ammo));a.reload_until=0
  if a.health<=0 and a.down_time>3:
   drop(a);a.health=100;a.position=C.CAMP;a.velocity=Vector3.ZERO;note(a.peer_id,"Back at camp. Banked credits and equipment are safe.","quest")
  if absf(a.position.x)>88 or a.position.z< -107 or a.position.z>69:a.position=C.CAMP;a.velocity=Vector3.ZERO
 for animal in animals.values():animal.step(self,dt)
 snapshot_timer+=dt
 if snapshot_timer>=.05:
  snapshot_timer=fmod(snapshot_timer,.05)
  if online and multiplayer.get_peers().size()>0:
   var packet=state_packet();var chunks=Wire.encode(packet)
   for i in range(chunks.size()):receive_state.rpc(int(packet.revision),i,chunks.size(),chunks[i])
 save_timer+=dt
 if save_timer>=30 or (save_pending and save_timer>=3):save_timer=0;save_pending=false;save_progress()
func _process(dt:float) -> void:
 clock+=dt;recoil=maxf(0,recoil-dt*5)
 if join_started>=0 and clock-join_started>12:end_session("Connection timed out. Confirm both computers have this hunting build and the host is running.")
 if active:
  for a in avatars.values():
   if not is_host:a.client_step(dt,25 if a.peer_id==local_id else 18)
   a.update_visual(dt)
  for animal in animals.values():animal.visual_step(dt,motion)
  var a=avatars.get(local_id)
  if a:
   if a.health<=0 or a.held>=0:aim_latched=false
   stick_look(dt,a)
   var p=a.rendered_position() if is_host else a.position
   camera.position=p+Vector3(0,a.eye_height if a.health>0 else .5,0);camera.rotation=Vector3(pitch,yaw,0)
   camera.fov=lerpf(camera.fov,50.0 if a.input_reel and "scope" in progress.upgrades else (64.0 if a.input_reel else 82.0),1-exp(-9*dt))
   gun.visible="rifle" in progress.upgrades and a.held<0 and a.health>0
   gun.position=gun.position.lerp(Vector3(.04,-.28,-.92) if a.input_reel else Vector3(.3,-.32,-.80),1-exp(-10*dt))
   gun.rotation=Vector3(recoil*.19+(-.45 if a.reload_until>clock else 0),0,sin(clock*2)*.008*motion)
   gun.presentation(a.reload_until>clock,clock,"scope" in progress.upgrades,motion,"muffler" in progress.upgrades)
   footstep+=dt
   if a.visual_speed>.4 and footstep>(.70 if a.crouched else (.30 if a.input_sprint else .48)):sound.tone("step",maxf(.12,a.noise));footstep=0
 ui.update(dt)
 touch.show_controls(active and not ui.panel.visible)
 if not capture_path.is_empty():
  capture_elapsed+=dt
  if capture_elapsed>4 and DisplayServer.get_name()!="headless":
   RenderingServer.force_draw() # Also supports minimized, disposable capture sessions.
   get_viewport().get_texture().get_image().save_png(capture_path);print("HUNT_CAPTURE ",capture_path);capture_path=""
   if "--capture-quit" in OS.get_cmdline_user_args():shutdown()
func aim_active() -> bool:
 if ui.panel.visible:return false
 return aim_latched if aim_toggle else Input.is_action_pressed("aim")
func stick_look(dt:float,a:Node3D) -> void:
 if not bot_mode.is_empty() or not capture_path.is_empty() or ui.panel.visible:return
 var look=Input.get_vector("look_left","look_right","look_up","look_down")
 if look.is_zero_approx():return
 # Squaring the magnitude keeps small stick movements fine-grained while still allowing a
 # fast sweep at full deflection. One stick has to both scan a treeline and hold on a deer.
 var scaled=look*look.length()
 # Steadying the rifle slows the turn, matching what the aim does to movement speed.
 var speed=PAD_LOOK_SPEED*(.45 if a.input_reel else 1.0)
 yaw=wrapf(yaw-scaled.x*speed*dt,-PI,PI)
 pitch=clampf(pitch-scaled.y*speed*dt*(-1.0 if pad_invert_y else 1.0),-1.3,1.3)
func submit_input(move:Vector2,y:float,p:float,jump:bool,sprint:bool,aim:bool,crouch:bool=false) -> void:
 next_sequence+=1
 if is_host:accept_input(local_id,next_sequence,move,y,p,jump,sprint,aim,crouch)
 elif active:player_input.rpc_id(1,next_sequence,move,y,p,jump,sprint,aim,crouch)
@rpc("any_peer","call_remote","unreliable_ordered",1)
func player_input(seq:int,move:Vector2,y:float,p:float,jump:bool,sprint:bool,aim:bool,crouch:bool=false) -> void:
 if is_host:accept_input(multiplayer.get_remote_sender_id(),seq,move,y,p,jump,sprint,aim,crouch)
func accept_input(id:int,seq:int,move:Vector2,y:float,p:float,jump:bool,sprint:bool,aim:bool,crouch:bool=false) -> void:
 if not avatars.has(id) or seq<=int(last_inputs.get(id,-1)) or not move.is_finite() or not is_finite(y) or not is_finite(p):return
 last_inputs[id]=seq;var a=avatars[id];a.input_move=move.limit_length(1);a.input_yaw=wrapf(y,-PI,PI);a.input_pitch=clampf(p,-1.3,1.3);a.input_jump=a.input_jump or jump;a.input_sprint=sprint;a.input_reel=aim;a.input_crouch=crouch;a.last_input=clock
func state_packet() -> Dictionary:
 revision+=1;var players=[];var wildlife=[]
 for a in avatars.values():players.append(a.packet())
 for animal in animals.values():wildlife.append(animal.packet())
 var p=progress.duplicate(true);p.animals=[]
 return {"revision":revision,"players":players,"animals":wildlife,"progress":p}
@rpc("authority","call_remote","unreliable",2)
func receive_state(rev:int,index:int,total:int,chunk:PackedByteArray) -> void:
 if not active or is_host or rev<=last_revision:return
 var p=wire.accept(rev,index,total,chunk)
 if not p.is_empty():apply_state(p)
func apply_state(packet:Dictionary) -> void:
 if int(packet.revision)<=last_revision:return
 last_revision=int(packet.revision);progress=packet.progress;var ids=[]
 for d in packet.players:
  var id=int(d.id);ids.append(id);var a=add_avatar(id,d.name);a.target_position=d.p;a.target_yaw=d.yaw;a.health=d.hp;a.held=int(d.held);a.visual_speed=d.speed;a.fishing=d.fish;a.magazines=d.magazines;a.crouched=bool(d.crouched);a.noise=float(d.noise);a.surface_name=str(d.surface);a.eye_height=float(d.eye_height);a.input_yaw=float(d.get("input_yaw",d.yaw))
  # Reload remaining time is derived from a duration in future revisions; current packet uses a host-relative hint only.
  a.reload_until=clock+.1 if float(d.reload_until)>0 else 0
  if id==local_id:a.input_reel=aim_active();a.body_root.hide();a.name_label.hide()
 for id in avatars.keys():
  if id not in ids:avatars[id].queue_free();avatars.erase(id)
 ids=[]
 for d in packet.animals:
  var id=int(d.id);ids.append(id);var a=animals.get(id)
  if not a:a=spawn_animal(d.p,float(d.size),bool(d.elite),id)
  a.target_position=d.p;a.target_yaw=d.yaw;a.hp=d.hp;a.state=d.state;a.alert=d.alert;a.holder=int(d.holder);a.shots=int(d.shots);a.base_value=int(d.value);a.motion_speed=d.speed;a.charge_target=d.charge;a.head_pitch=float(d.get("head_pitch",0))
 for id in animals.keys():
  if id not in ids:animals[id].queue_free();animals.erase(id)
func send_action(action:String,data:Dictionary) -> void:
 if not active:return
 command_sequence+=1
 if is_host:accept_action(local_id,command_sequence,action,data)
 else:action_request.rpc_id(1,command_sequence,action,data)
@rpc("any_peer","call_remote","reliable",0)
func action_request(seq:int,action:String,data:Dictionary) -> void:
 if is_host:accept_action(multiplayer.get_remote_sender_id(),seq,action,data)
func accept_action(id:int,seq:int,action:String,data:Dictionary) -> void:
 if not active or not is_host or not avatars.has(id) or seq<=int(last_commands.get(id,-1)):return
 last_commands[id]=seq;var a=avatars[id]
 if a.health<=0 or a.action_gate.admit(clock,action,data)!=Gate.Admission.ACCEPT:return
 match action:
  "buy":buy(a,str(data.get("upgrade","")))
  "fire":fire(a)
  "reload":
   if "rifle" in progress.upgrades and a.reload_until<=0 and progress.ammo>0 and int(a.magazines.get("rifle",0))<4:a.reload_until=clock+1.4;note(id,"Working the bolt. Reloading…","click")
  "interact":interact(a)
  "pickup":pickup(a)
  "drop":drop(a)
 # Transactions save immediately: credits and equipment must never be lost. Firing and
 # carrying only move ammunition and holder state, and were costing a full duplicate,
 # JSON encode and synchronous disk write on every single shot.
 if action in ["buy","interact"]:save_progress()
 elif action in ["fire","pickup","drop"]:save_pending=true
func buy(a:Node3D,id:String) -> void:
 if not active or not is_host or avatars.get(a.peer_id)!=a or a.health<=0:return
 var result=Economy.purchase(progress,id,a.position.distance_to(C.SHOP)<=8)
 if result.get("refill",false):
  for player in avatars.values():player.magazines.rifle=4
 if not result.message.is_empty():note(a.peer_id,result.message,result.tone)
func fire(a:Node3D) -> void:
 if "rifle" not in progress.upgrades or a.held>=0 or a.reload_until>clock or clock<a.next_shot:return
 if int(a.magazines.get("rifle",0))<=0 or int(progress.ammo)<=0:note(a.peer_id,"Empty. [R] reload, or visit camp for ammunition.","error");return
 a.next_shot=clock+(.52 if "rifle2" in progress.upgrades else .87);a.magazines.rifle-=1;progress.ammo-=1
 var origin=a.position+Vector3.UP*a.eye_height;var direction=Basis.from_euler(Vector3(a.input_pitch,a.input_yaw,0))*Vector3.FORWARD
 var query=PhysicsRayQueryParameters3D.create(origin,origin+direction*85,5);query.collide_with_areas=true;var result=get_world_3d().direct_space_state.intersect_ray(query)
 var end=origin+direction*85 if result.is_empty() else result.position
 shot_fx(origin,end,a.peer_id)
 if online:shot_fx.rpc(origin,end,a.peer_id)
 Stealth.shot_disturbance(self,origin,end,not result.is_empty())
 if result.is_empty() or not result.collider is Area3D:return
 var animal=result.collider.get_parent()
 if not animal.get_script()==Deer:return
 if animal.hp<=0:return
 var clean=float(a.fishing.get("steady",0))>=.85
 var applied=animal.take_shot(85 if clean else 38)
 if animal.hp<=0:animal.state="down";animal.velocity=Vector3.ZERO;note(a.peer_id,"CLEAN HARVEST • +25%" if animal.shots==1 else "Harvest secured. Follow the trail and press [F] to drag it.","catch")
 elif animal.elite:note(a.peer_id,"EXPOSED HIT • %d damage"%int(applied) if animal.state=="recover" else "BRACED HIDE • reduced damage. Dodge the rush, then fire while it recovers.","hit")
 else:note(a.peer_id,"Hit! Follow its hoofprints; steady aim hits harder.","hit")
@rpc("authority","call_remote","unreliable",3)
func shot_fx(start:Vector3,end:Vector3,shooter:int) -> void:
 # Recoil is a first-person camera kick. Applying it on every peer meant a four-player
 # hunt jolted everyone's view each time anyone pulled a trigger.
 if shooter==local_id:recoil=1
 # Roll the report off with distance from the listener, so a shot across the valley reads
 # as a distant cue instead of arriving at the same volume as your own rifle.
 var falloff=clampf(8.0/maxf(8.0,camera.global_position.distance_to(start)),.06,1.0)
 sound.tone("shot",(.28 if "muffler" in progress.upgrades else 1.0)*falloff)
 var mesh=ImmediateMesh.new();mesh.surface_begin(Mesh.PRIMITIVE_LINES);mesh.surface_add_vertex(start);mesh.surface_add_vertex(end);mesh.surface_end()
 var n=MeshInstance3D.new();add_child(n);n.mesh=mesh;n.material_override=V.material(Color("eacf9b"),.6)
 var tween=create_tween();tween.tween_interval(.075);tween.tween_callback(n.queue_free)
 if start.distance_to(end)<84.9:
  var spark=V.sphere(self,end,.055,Color("e8bf77"));var fade=create_tween();fade.tween_property(spark,"scale",Vector3.ONE*.1,.18);fade.tween_callback(spark.queue_free)
func nearest_animal(a:Node3D,dead:bool=true) -> Node3D:
 var selected:Node3D=null;var distance=3.4
 for animal in animals.values():
  if dead and (animal.hp>0 or animal.holder>=0):continue
  var d=animal.position.distance_to(a.position)
  if d<distance:distance=d;selected=animal
 return selected
func pickup(a:Node3D) -> void:
 if a.held>=0:return
 var animal=nearest_animal(a)
 if not animal:note(a.peer_id,"Move within reach of a downed deer, then press [F].","click");return
 animal.holder=a.peer_id;a.held=animal.entity_id;note(a.peer_id,"Harvest secured. Drag it home to the game exchange.","click")
func drop(a:Node3D) -> void:
 if animals.has(a.held):animals[a.held].holder=-1
 a.held=-1
func interact(a:Node3D) -> void:
 if a.position.distance_to(C.EXCHANGE)<4.2:
  if animals.has(a.held):sell(a);return
  note(a.peer_id,"Drag a harvested deer here, then press [E] to bank it.","click");return
 if a.position.distance_to(C.SHOP)<8:
  if Economy.recover_ammo(progress):
   note(a.peer_id,"Camp recovery: four field rounds. Reload and try again.","quest");return
  var id=display_for(a);open_shop(a.peer_id,id);return
 var closest:Dictionary={};var distance=3.5
 for track in forest.tracks:
  var d=a.position.distance_to(track.p)
  if d<distance:distance=d;closest=track
 if not closest.is_empty():
  var animal=animals.get(int(closest.id))
  if not animal:
   var first=animals.values();animal=first[0] if not first.is_empty() else null
  if animal:track_hint(a.peer_id,animal.entity_id,animal.position,animal.state)
  return
 pickup(a)
func sell(a:Node3D) -> void:
 if not active or not is_host or avatars.get(a.peer_id)!=a or a.health<=0 or a.position.distance_to(C.EXCHANGE)>=4.2:return
 var animal=animals.get(a.held)
 if not animal or animal.hp>0 or animal.holder!=a.peer_id:return
 var amount=animal.value();var crown=animal.elite
 # Remove the unique harvest before any feedback/contract side effect can re-enter.
 animals.erase(animal.entity_id);animal.queue_free();a.held=-1
 var result=Economy.bank(progress,amount,crown)
 if result.spawn_crown:spawn_animal(forest.point(26,-64)+Vector3.UP*.1,1.55,true)
 for message in result.notes:note(a.peer_id,message.message,message.tone)
 if animals.size()<5:spawn_animal(forest.point(-18+sin(progress.sequence)*25,-25-cos(progress.sequence)*20)+Vector3.UP*.1,.9+fmod(progress.sequence*.13,.5))
func display_for(a:Node3D) -> String:
 var best="";var score=.55
 for id in forest.displays:
  var delta=forest.displays[id].global_position-(a.position+Vector3.UP*1.4)
  var dot=a.forward().dot(delta.normalized())
  if delta.length()<5 and dot>score:score=dot;best=id
 return best
func open_shop(id:int,item:String) -> void:
 if id==local_id:show_shop(item)
 elif online:show_shop.rpc_id(id,item)
@rpc("authority","call_remote","reliable",0)
func show_shop(item:String) -> void:ui.show_panel("shop",item)
func track_hint(id:int,animal_id:int,p:Vector3,state:String) -> void:
 if id==local_id:show_track(animal_id,p,state)
 elif online:show_track.rpc_id(id,animal_id,p,state)
@rpc("authority","call_remote","reliable",0)
func show_track(id:int,p:Vector3,state:String) -> void:
 tracked_id=id;tracked_until=clock+20;var a=avatars.get(local_id);var dist=int(a.position.distance_to(p)) if a else 0
 ui.notify("Fresh hoofprints • %dm away • %s. Wind blows toward the south-east."%[dist,state]);sound.tone("click")
func add_track(p:Vector3,heading:float,id:int) -> void:
 forest.add_track(p,heading,id)
 if online:receive_track.rpc(p,heading,id)
@rpc("authority","call_remote","reliable",0)
func receive_track(p:Vector3,heading:float,id:int) -> void:forest.add_track(p,heading,id)
func context_prompt() -> String:
 var a=avatars.get(local_id)
 if not a:return ""
 if a.position.distance_to(C.EXCHANGE)<4.2:return "[E] bank your harvest at the exchange"
 if a.position.distance_to(C.SHOP)<8:
  var id=display_for(a);return "[E] inspect "+C.ITEMS[id].name if id!="" else "[E] browse the lodge's equipment"
 for animal in animals.values():
  if animal.elite and animal.hp>0 and animal.position.distance_to(a.position)<24:
   if animal.state=="windup":return "CROWNBACK BRACES • Sidestep the orange lane!"
   if animal.state=="recover":return "CROWNBACK EXPOSED • Full damage now!"
 for animal in animals.values():
  var delta=animal.position-a.position;delta.y=0
  if animal.hp>0 and animal.state=="alert" and delta.length()<20 and a.forward().dot(delta.normalized())>.85:return "QUARRY ALERT • Keep still or move downwind."
 if nearest_animal(a):return "[F] drag harvested deer"
 if tracked_until>clock and animals.has(tracked_id):
  var animal=animals[tracked_id];var delta=animal.position-a.position;var angle=wrapf(atan2(-delta.x,-delta.z)-yaw,-PI,PI)
  var arrow="↑" if absf(angle)<.45 else ("↓" if absf(angle)>2.4 else ("←" if angle>0 else "→"))
  return "TRAIL %s • %dm • %s"%[arrow,int(a.position.distance_to(animal.position)),animal.state.to_upper()]
 for track in forest.tracks:
  if a.position.distance_to(track.p)<3.5:return "[E] inspect fresh hoofprints"
 return "Right mouse: steady aim • Left mouse: fire" if "rifle" in progress.upgrades else "Follow the trail back to the timber lodge"
func note(id:int,text:String,tone:String="click") -> void:
 if id==local_id:show_note(text,tone)
 elif online:show_note.rpc_id(id,text,tone)
@rpc("authority","call_remote","reliable",0)
func show_note(text:String,tone:String) -> void:ui.notify(text);sound.tone(tone);print("HUNT_EVENT ",text)
func save_progress() -> bool:
 return Session.save_progress(self)
