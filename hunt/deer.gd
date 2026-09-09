extends CharacterBody3D
## Host-only wildlife controller; the guest interpolates state and animates its pose.
const V=preload("res://scripts/visuals.gd")
const Model=preload("res://hunt/animal_model.gd")
const Forest=preload("res://hunt/forest.gd")
var entity_id=1
var authority=true
var size_factor=1.0
var elite=false
var hp=70.0
var shots=0
var base_value=35
var state="graze"
var alert=0.0
var timer=2.0
var holder=-1
var home=Vector3.ZERO
var target_position=Vector3.ZERO
var target_yaw=0.0
var wander=Vector3.ZERO
var view:Node3D
var neck:Node3D
var legs:Array[Node3D]=[]
var knees:Array[Node3D]=[]
var phase=0.0
var motion_speed=0.0
var track_at=Vector3.ZERO
var charge_target=Vector3.ZERO
var charge_hit=false
var charge_direction=Vector3.FORWARD
var danger:MeshInstance3D
var head_hit:Area3D
var head_pitch=0.0
var route=PackedVector3Array()
var route_timer=0.0
var route_state=""
var threat_position=Vector3.ZERO
var last_step_position=Vector3.ZERO
var stuck_time=0.0
var route_replans=0
func follow_route(game:Node,dt:float,flee:bool) -> Vector3:
 route_timer-=dt
 var flat_movement=Vector2(position.x-last_step_position.x,position.z-last_step_position.z).length()
 stuck_time=stuck_time+dt if not route.is_empty() and flat_movement<dt*.15 else 0.0
 last_step_position=position
 if route_state!=state or route.is_empty() or route_timer<=0 or stuck_time>.65:
  route_state=state;route_timer=2.0 if flee else 6.0;stuck_time=0;route_replans+=1
  if flee:route=game.forest.routes.escape(position,threat_position,home)
  else:route=game.forest.routes.route(position,home+wander*9)
 while not route.is_empty() and Vector2(position.x-route[0].x,position.z-route[0].z).length()<.4:route.remove_at(0)
 if route.is_empty():return Vector3.ZERO
 var direction=route[0]-position;direction.y=0;return direction.normalized()
func _ready() -> void:
 collision_layer=8;collision_mask=1
 var collision=CollisionShape3D.new();add_child(collision);var support=CapsuleShape3D.new();support.radius=.3*size_factor;support.height=2.0*size_factor;collision.shape=support;collision.position=Vector3.UP*size_factor
 var torso_hit=Area3D.new();add_child(torso_hit);torso_hit.collision_layer=4;torso_hit.collision_mask=0
 var hit=CollisionShape3D.new();torso_hit.add_child(hit);var shape=BoxShape3D.new();shape.size=Vector3(.62,.75,1.65)*size_factor;hit.shape=shape;hit.position=Vector3(0,1.16,0)*size_factor
 head_hit=Area3D.new();add_child(head_hit);head_hit.collision_layer=4;head_hit.collision_mask=0;head_hit.position=Vector3(0,1.39,-.57)*size_factor
 var head_shape=CollisionShape3D.new();head_hit.add_child(head_shape);var hs=BoxShape3D.new();hs.size=Vector3(.37,.38,.66)*size_factor;head_shape.shape=hs;head_shape.position=Vector3(0,.62,-.48)*size_factor
 view=Model.new();view.elite=elite;view.scale=Vector3.ONE*size_factor;add_child(view)
 neck=view.neck;legs=view.legs;knees=view.knees
 home=position;target_position=position;track_at=position;threat_position=position;last_step_position=position
 danger=MeshInstance3D.new();add_child(danger);danger.top_level=true;danger.global_transform=Transform3D.IDENTITY;danger.material_override=V.material(Color(1,.42,.15,.38),.3);danger.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED;danger.material_override.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
static func form(parent:Node3D,p:Vector3,s:Vector3,color:Color) -> Node3D:
 var n=V.sphere(parent,p,.5,color);n.scale=s;return n
static func limb(parent:Node3D,a:Vector3,b:Vector3,r:float,c:Color) -> Node3D:
 var n=V.cylinder(parent,(a+b)*.5,r,a.distance_to(b),c,false,r*.64);n.quaternion=Quaternion(Vector3.UP,(b-a).normalized());return n
func step(game:Node,dt:float) -> void:
 if not authority:return
 head_pitch=lerp_angle(head_pitch,-.85 if state=="graze" and alert<.4 else (-.45 if state=="windup" else .05),1-exp(-4*dt));head_hit.rotation.x=head_pitch
 if hp<=0:
  state="down";velocity=Vector3.ZERO
  if holder>=0 and game.avatars.has(holder):
   var a=game.avatars[holder];position=a.position-a.forward()*1.8;position.y=Forest.height_at(position.x,position.z);rotation.y=a.input_yaw+PI
  return
 var target:Node3D=null;var dist=1000.0;var visible=false
 var strongest=0.0
 for a in game.avatars.values():
  if a.health<=0:continue
  var d=position.distance_to(a.position)
  if d>35:continue
  var query=PhysicsRayQueryParameters3D.create(position+Vector3.UP*1.5,a.position+Vector3.UP*a.eye_height,1)
  var sight=get_world_3d().direct_space_state.intersect_ray(query).is_empty()
  # A low stance changes the sight ray; only physical cover blocks it.
  var scent=d<9 and (a.position-position).normalized().dot(Vector3(.8,0,.6))<-.4
  var strength=game.Stealth.detection(a,d,sight,scent)
  if strength>strongest or (strength==strongest and d<dist):
   strongest=strength;target=a;dist=d;visible=sight
 if strongest>0:
  alert=minf(1.0,alert+dt*strongest);threat_position=target.position
 else:alert=maxf(0,alert-dt*.18)
 timer-=dt
 if state=="windup":
  velocity.x=0;velocity.z=0
  if timer<=0:state="charge";timer=position.distance_to(charge_target)/10.0;charge_hit=false
 elif state=="charge":
  velocity.x=charge_direction.x*10;velocity.z=charge_direction.z*10;rotation.y=atan2(-charge_direction.x,-charge_direction.z)
  if not charge_hit:
   for a in game.avatars.values():
    if a.health>0 and a.position.distance_to(position)<1.9:a.health=maxf(0,a.health-28);charge_hit=true;game.note(a.peer_id,"Antler rush! Sidestep the marked approach.","hit")
  if timer<=0:state="recover";timer=3.2
 elif state=="recover":
  velocity.x=move_toward(velocity.x,0,dt*18);velocity.z=move_toward(velocity.z,0,dt*18)
  if timer<=0:state="graze";timer=2;alert=.5
 elif elite and target and visible and alert>.65 and dist<17:
  state="windup";timer=1.2;velocity=Vector3.ZERO
  charge_direction=target.position-position;charge_direction.y=0;charge_direction=charge_direction.normalized()
  rotation.y=atan2(-charge_direction.x,-charge_direction.z)
  charge_target=position+charge_direction*clampf(dist+4,10,18)
  charge_target.y=Forest.height_at(charge_target.x,charge_target.z)
 elif alert>.72:
  state="flee"
  var away=follow_route(game,dt,true)
  velocity.x=move_toward(velocity.x,away.x*4.7,dt*16);velocity.z=move_toward(velocity.z,away.z*4.7,dt*16)
  if away.length()>.1:rotation.y=lerp_angle(rotation.y,atan2(-away.x,-away.z),dt*6)
 elif alert>.35:
  state="alert";velocity.x=move_toward(velocity.x,0,dt*8);velocity.z=move_toward(velocity.z,0,dt*8)
  var toward=threat_position-position
  if toward.length()>.1:rotation.y=lerp_angle(rotation.y,atan2(-toward.x,-toward.z),dt*3)
 else:
  if timer<=0:
   wander=Vector3(sin(game.clock*.23+entity_id*3.1),0,cos(game.clock*.17+entity_id*2.7))
   timer=4+float(entity_id%3);state="graze" if state=="walk" else "walk";route.clear()
  if state not in ["walk","graze"]:state="graze"
  var direction=follow_route(game,dt,false) if state=="walk" else Vector3.ZERO
  velocity.x=move_toward(velocity.x,direction.x*.75,dt*3);velocity.z=move_toward(velocity.z,direction.z*.75,dt*3)
  if direction.length()>.1:rotation.y=lerp_angle(rotation.y,atan2(-direction.x,-direction.z),dt*2)
 if not is_on_floor():velocity.y-=20*dt
 else:velocity.y=0
 move_and_slide()
 if state=="charge" and is_on_wall():state="recover";timer=3.2;velocity.x=0;velocity.z=0
 motion_speed=Vector2(velocity.x,velocity.z).length()
 if position.y< -2 or absf(position.x)>86 or position.z< -105 or position.z>65:position=home;velocity=Vector3.ZERO
 if position.distance_to(track_at)>2.5:
  game.add_track(position,rotation.y,entity_id);track_at=position
func visual_step(dt:float,motion:float=1.0) -> void:
 if not authority:
  position=position.lerp(target_position,1-exp(-18*dt)) if position.distance_to(target_position)<8 else target_position
  rotation.y=lerp_angle(rotation.y,target_yaw,1-exp(-14*dt))
 update_danger()
 view.pose(dt,state,hp,head_pitch,motion_speed,motion,entity_id)
func take_shot(damage:float) -> float:
 # Crownback's braced hide rewards the counterattack after a committed rush.
 var applied=damage*(.45 if elite and state!="recover" else 1.0)
 shots+=1;hp=maxf(0,hp-applied);alert=1
 return applied
func value() -> int:return maxi(8,int(base_value*(1.25 if shots==1 else (1.0 if shots==2 else .85))))
func packet() -> Dictionary:
 return {"id":entity_id,"p":position,"yaw":rotation.y,"hp":hp,"state":state,"alert":alert,"size":size_factor,"shots":shots,"value":base_value,"elite":elite,"holder":holder,"speed":motion_speed,"charge":charge_target,"head_pitch":head_pitch}
func saved() -> Dictionary:
 var p=home if hp>0 else position
 return {"id":entity_id,"p":[p.x,p.y,p.z],"hp":hp,"size":size_factor,"shots":shots,"value":base_value,"elite":elite}

func update_danger() -> void:
 danger.visible=elite and hp>0 and state in ["windup","charge"]
 if not danger.visible:return
 var direction=charge_target-position;direction.y=0
 if direction.length()<.1:danger.hide();return
 var side=direction.normalized().cross(Vector3.UP)*1.9
 var mesh=ImmediateMesh.new();mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in range(8):
  var begin=position+direction*(i/8.0);var end=position+direction*((i+1)/8.0)
  var points=[begin-side,begin+side,end-side,begin+side,end+side,end-side]
  for p in points:mesh.surface_add_vertex(Vector3(p.x,Forest.height_at(p.x,p.z)+.055,p.z))
 mesh.surface_end();danger.mesh=mesh
