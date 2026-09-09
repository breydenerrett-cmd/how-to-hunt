extends SceneTree
var game:Node
var passes=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func steps(a:Node3D,count:int) -> void:
 for i in range(count):
  await physics_frame;a.server_step(1.0/60,false,0,false);a.surface_name=game.Stealth.surface_at(a.position);a.noise=game.Stealth.movement_noise(a)
func run() -> void:
 game=load("res://main.tscn").instantiate();root.add_child(game);game.store.disabled=true;game.bot_mode="stalking";game.start_host(false,"Stalking fixture",999109);game.set_physics_process(false)
 var a=game.avatars[1]
 game.V.box(game,Vector3(200,-.25,0),Vector3(30,.5,30),Color.GRAY,true)
 game.V.box(game,Vector3(200,1.55,-3),Vector3(4,.3,4),Color.GRAY,true)
 a.position=Vector3(200,.08,1);a.velocity=Vector3.ZERO;a.input_crouch=true;a.input_sprint=true;a.input_move=Vector2(0,-1)
 await steps(a,90)
 check(a.crouched and a.capsule.shape.height==1.25 and a.eye_height<1.06,"crouch lowers physical capsule and authoritative eye height")
 check(a.position.z< -1 and a.visual_speed<1.81,"crouch overrides sprint and walks beneath low ceiling")
 a.input_crouch=false;a.input_move=Vector2.ZERO;await steps(a,20)
 check(a.crouched and a.capsule.shape.height==1.25,"release under ceiling retains safe crouch")
 a.input_jump=true;var y=a.position.y;await steps(a,5)
 check(absf(a.position.y-y)<.03,"blocked stance cannot jump through ceiling")
 a.input_move=Vector2(0,1);await steps(a,110)
 check(not a.crouched and absf(a.eye_height-1.58)<.01,"leaving cover restores standing with clear headroom")
 # Same physical travel, each stance, off the quiet trail.
 var levels=[];var speeds=[]
 for stance in ["crouch","walk","run"]:
  a.position=Vector3(200,.08,5);a.velocity=Vector3.ZERO;a.input_crouch=stance=="crouch";a.input_sprint=stance=="run";a.input_move=Vector2(1,0)
  await steps(a,25);levels.append(a.noise);speeds.append(a.visual_speed)
 check(speeds[0]<speeds[1] and speeds[1]<speeds[2],"physical travel has three distinct speed tiers")
 check(levels[0]<levels[1] and levels[1]<levels[2] and levels[2]<=1,"actual movement generates graduated host noise")
 var leaves=a.noise;a.surface_name="trail";var trail=game.Stealth.movement_noise(a)
 check(trail<leaves,"trail travel is quieter than leaf litter")
 a.input_move=Vector2.ZERO;await steps(a,25)
 check(a.noise<.001,"stopping reduces movement noise to zero")
 a.crouched=true;a.noise=.15;var quiet=game.Stealth.detection(a,7,true,false)
 a.crouched=false;a.input_sprint=true;a.noise=1;var loud=game.Stealth.detection(a,7,true,false)
 check(quiet<loud and loud>0,"quiet crouch approach accumulates less suspicion at the same range")
 a.crouched=true;a.noise=0
 check(game.Stealth.detection(a,3,true,false)>0 and game.Stealth.detection(a,7,false,true)>0,"silent stance remains detectable by close sight and scent")
 check(game.Stealth.detection(a,7,false,false)==0,"physical cover with no audible movement avoids detection")
 # A crouched shot must originate below a low overhead blocker.
 var deer=game.animals.values()[0];deer.position=Vector3(200,.1,-8);deer.hp=70;deer.shots=0
 a.position=Vector3(200,.08,-3);a.velocity=Vector3.ZERO;a.input_crouch=true;a.input_move=Vector2.ZERO;await steps(a,15)
 game.progress.upgrades=["rifle"];game.progress.ammo=12;a.magazines.rifle=4;a.fishing.steady=1;a.input_yaw=0
 var delta=deer.position+Vector3.UP*1.2*deer.size_factor-(a.position+Vector3.UP*a.eye_height)
 a.input_pitch=atan2(delta.y,Vector2(delta.x,delta.z).length());game.fire(a)
 check(deer.hp==0,"crouched authoritative shot clears low ceiling and hits quarry")
 var packet=game.state_packet();var guest=game.Avatar.new();game.add_child(guest)
 var p=packet.players[0]
 check(p.crouched and p.noise==a.noise and p.eye_height==a.eye_height,"stance noise and eye height are included in snapshots")
 game.accept_input(1,900,Vector2.ZERO,0,0,false,false,false,true);game.accept_input(1,899,Vector2.ZERO,0,0,false,false,false,false)
 check(a.input_crouch,"stale input cannot overwrite admitted crouch")
 game.active=false;game.sound.stop_all();game.queue_free();await process_frame;print("TEST_SUMMARY hunt_stalking passes=",passes," failures=",failures);quit(1 if failures else 0)
