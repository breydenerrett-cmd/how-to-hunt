extends CharacterBody3D
const V = preload("res://scripts/visuals.gd")
const C = preload("res://hunt/catalog.gd")
var peer_id := 1
var display_name := "Ranger"
var input_move := Vector2.ZERO
var input_yaw := 0.0
var input_pitch := 0.0
var input_jump := false
var input_sprint := false
var input_reel := false
var magazines:Dictionary={}
var ammo_kind:="rubber"
var reload_until:=0.0
var reload_tool:=4
var next_shot:=0.0
var hurt_until:=0.0
var tool := 1
var held := -1
var health := 100.0
var water_time := 0.0
var water_jump_cooldown:=0.0
var down_time := 0.0
var action_gate=preload("res://scripts/action_gate.gd").new()
var last_input := 0.0
var target_position := Vector3.ZERO
var target_yaw := 0.0
var body_root:Node3D
var name_label:Label3D
var fishing:Dictionary = {}
var helper_of := -1
var visual_speed := 0.0
var visual_time := 0.0
var torso:Node3D
var left_arm:Node3D
var right_arm:Node3D
var left_leg:Node3D
var right_leg:Node3D
var previous_position:=Vector3.ZERO

func _ready() -> void:
	collision_layer=2
	collision_mask=1
	var col=CollisionShape3D.new()
	var shape=CapsuleShape3D.new()
	shape.radius=0.32
	shape.height=1.7
	col.shape=shape
	col.position.y=0.85
	add_child(col)
	body_root=Node3D.new()
	add_child(body_root)
	var colors=[Color("d78a50"),Color("77a3a0"),Color("b29bc8"),Color("d2b45e")]
	var color=colors[absi(peer_id)%4]
	torso=Node3D.new()
	torso.name="Torso"
	body_root.add_child(torso)
	var coat=V.cylinder(torso,Vector3(0,1.08,0),0.34,0.76,color,false,0.28)
	coat.scale.z=0.78
	V.box(torso,Vector3(0,1.08,-0.285),Vector3(0.08,0.66,0.035),Color("ead49c"))
	V.box(torso,Vector3(0,1.31,0.29),Vector3(0.52,0.30,0.12),Color("33494e"))
	V.sphere(torso,Vector3(0,1.62,0),0.255,Color("ecd4ad"))
	for x in [-0.09,0.09]:
		V.sphere(torso,Vector3(x,1.68,-0.225),0.032,Color("17343a"))
	var hat=V.cylinder(torso,Vector3(0,1.84,0),0.31,0.16,color.darkened(0.24),false,0.25)
	hat.scale.z=0.88
	V.box(torso,Vector3(0,1.80,-0.27),Vector3(0.45,0.045,0.30),color.darkened(0.28))
	left_leg=Node3D.new()
	left_leg.name="LeftLeg"
	body_root.add_child(left_leg)
	left_leg.position=Vector3(-0.17,0.72,0)
	V.box(left_leg,Vector3(0,-0.31,0),Vector3(0.23,0.62,0.27),Color("263f49"))
	V.box(left_leg,Vector3(0,-0.62,-0.08),Vector3(0.25,0.15,0.42),Color("182e35"))
	right_leg=Node3D.new()
	right_leg.name="RightLeg"
	body_root.add_child(right_leg)
	right_leg.position=Vector3(0.17,0.72,0)
	V.box(right_leg,Vector3(0,-0.31,0),Vector3(0.23,0.62,0.27),Color("263f49"))
	V.box(right_leg,Vector3(0,-0.62,-0.08),Vector3(0.25,0.15,0.42),Color("182e35"))
	left_arm=Node3D.new()
	left_arm.name="LeftArm"
	body_root.add_child(left_arm)
	left_arm.position=Vector3(-0.39,1.38,0)
	V.cylinder(left_arm,Vector3(0,-0.30,0),0.09,0.60,color)
	V.sphere(left_arm,Vector3(0,-0.63,0),0.105,Color("ecd4ad"))
	right_arm=Node3D.new()
	right_arm.name="RightArm"
	body_root.add_child(right_arm)
	right_arm.position=Vector3(0.39,1.38,0)
	V.cylinder(right_arm,Vector3(0,-0.30,0),0.09,0.60,color)
	V.sphere(right_arm,Vector3(0,-0.63,0),0.105,Color("ecd4ad"))
	name_label=V.text3d(self,Vector3(0,2.2,0),display_name,22)
	name_label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	target_position=position

func server_step(dt:float, heavy:bool, harness_bonus:float, assistance:bool) -> void:
	previous_position=position
	rotation.y=input_yaw
	var direction=Basis(Vector3.UP,input_yaw)*Vector3(input_move.x,0,input_move.y)
	var speed=6.5 if input_sprint else 4.5
	var swimming=position.y < -0.65 and not is_on_floor()
	if swimming: speed=2.8
	if heavy: speed*=0.65*(1.0+harness_bonus)*(1.25 if assistance else 1.0)
	if health<=0: speed=0
	var desired=direction*speed
	var acceleration=24.0 if input_move.length()>0.01 else 32.0
	velocity.x=move_toward(velocity.x,desired.x,acceleration*dt)
	velocity.z=move_toward(velocity.z,desired.z,acceleration*dt)
	water_jump_cooldown=maxf(0,water_jump_cooldown-dt)
	if swimming:
		water_time+=dt
		velocity.y=move_toward(velocity.y,clampf((-1.65-position.y)*7.0,-2.0,3.0),dt*18.0)
		if input_jump and water_jump_cooldown<=0 and health>0:
			velocity.y=8.7; water_jump_cooldown=0.85
		if water_time>12: health=maxf(1.0,health-dt*12.0)
	elif not is_on_floor(): velocity.y-=20.0*dt
	elif input_jump and health>0: velocity.y=6.5
	input_jump=false
	move_and_slide()
	if not swimming: water_time=maxf(0,water_time-dt*4.0)
	if water_time>16 or position.y < -8:
		position=C.CAMP
		velocity=Vector3.ZERO
		water_time=0
	if health<=0: down_time+=dt
	else: down_time=0
	visual_speed=Vector2(velocity.x,velocity.z).length()

func client_step(dt:float,position_rate:float=18.0) -> void:
	if position.distance_to(target_position)>5:
		position=target_position
	else: position=position.lerp(target_position,1.0-exp(-position_rate*dt))
	rotation.y=lerp_angle(rotation.y,target_yaw,1.0-exp(-15*dt))

func update_visual(dt:float) -> void:
	if not body_root: return
	var move_amount=clampf(visual_speed/6.5,0,1)
	visual_time+=dt*(3.5+visual_speed*1.25)
	var stride=sin(visual_time)*0.72*move_amount
	left_leg.rotation.x=lerp(left_leg.rotation.x,stride,1.0-exp(-14.0*dt))
	right_leg.rotation.x=lerp(right_leg.rotation.x,-stride,1.0-exp(-14.0*dt))
	var arm_stride=-stride*0.65
	if held>=0:
		left_arm.rotation.x=lerp(left_arm.rotation.x,-1.12,1.0-exp(-12.0*dt))
		right_arm.rotation.x=lerp(right_arm.rotation.x,-1.12,1.0-exp(-12.0*dt))
		left_arm.rotation.z=lerp(left_arm.rotation.z,-0.22,1.0-exp(-12.0*dt))
		right_arm.rotation.z=lerp(right_arm.rotation.z,0.22,1.0-exp(-12.0*dt))
	else:
		left_arm.rotation.x=lerp(left_arm.rotation.x,arm_stride,1.0-exp(-12.0*dt))
		right_arm.rotation.x=lerp(right_arm.rotation.x,-arm_stride,1.0-exp(-12.0*dt))
		left_arm.rotation.z=lerp(left_arm.rotation.z,0.04,1.0-exp(-12.0*dt))
		right_arm.rotation.z=lerp(right_arm.rotation.z,-0.04,1.0-exp(-12.0*dt))
	if water_time>0:
		left_arm.rotation.x=-1.0+sin(visual_time*1.7)*0.8
		right_arm.rotation.x=-1.0-sin(visual_time*1.7)*0.8
		left_leg.rotation.x=sin(visual_time*2)*0.35
		right_leg.rotation.x=-sin(visual_time*2)*0.35
	var down_target=1.42 if health<=0 else 0.0
	body_root.rotation.z=lerp_angle(body_root.rotation.z,down_target,1.0-exp(-8.0*dt))
	body_root.position.y=lerp(body_root.position.y,(-0.45 if health<=0 else absf(sin(visual_time))*0.035*move_amount),1.0-exp(-15.0*dt))
	torso.rotation.z=sin(visual_time*0.5)*0.018*move_amount

func forward() -> Vector3:
	return Vector3(-sin(input_yaw),0,-cos(input_yaw))

func rendered_position() -> Vector3:
	if position.distance_to(previous_position)>3.0: return position
	return previous_position.lerp(position,Engine.get_physics_interpolation_fraction())

func holding_position() -> Vector3:
	return position+Vector3(0,1.25,0)+forward()*1.3

func packet() -> Dictionary:
	return {"id":peer_id,"name":display_name,"p":position,"yaw":rotation.y,"hp":health,"held":held,"tool":tool,"water":water_time,"speed":visual_speed,"fish":fishing.duplicate(true),"magazines":magazines.duplicate(),"ammo_kind":ammo_kind,"reload_until":reload_until}
