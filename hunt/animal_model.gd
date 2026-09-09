extends Node3D
## Presentation only. The wildlife controller owns all collision, damage and identity.
const V=preload("res://scripts/visuals.gd")
const S=preload("res://hunt/sculpt.gd")
var elite=false
var neck:Node3D
var legs:Array[Node3D]=[]
var knees:Array[Node3D]=[]
var ears:Array[Node3D]=[]
var eyes:Array[Node3D]=[]
var tail:Node3D
var body:Node3D
var phase=0.0
var life=0.0
var reaction=0.0
var previous_hp=-1.0
func _ready() -> void:
 var coat=Color("a57b4f") if not elite else Color("79684e")
 var cream=Color("d9c6a5") if not elite else Color("c7b88f")
 body=S.loft(self,"ChestFlankHaunch",[
  S.section(Vector3(0,1.28,-.84),.12,.19),S.section(Vector3(0,1.23,-.7),.27,.35),
  S.section(Vector3(0,1.18,-.46),.335,.40),S.section(Vector3(0,1.16,-.12),.32,.37),
  S.section(Vector3(0,1.19,.23),.25,.30),S.section(Vector3(0,1.25,.50),.31,.34),
  S.section(Vector3(0,1.25,.72),.28,.29),S.section(Vector3(0,1.29,.89),.13,.16),
  S.section(Vector3(0,1.31,.94),.035,.06)],coat,cream,24)
 neck=Node3D.new();add_child(neck);neck.position=Vector3(0,1.39,-.57)
 S.loft(neck,"TaperedNeck",[
  S.section(Vector3(0,-.16,.12),.25,.23),S.section(Vector3(0,.03,0),.23,.23),
  S.section(Vector3(0,.27,-.13),.18,.19),S.section(Vector3(0,.47,-.23),.14,.16),
  S.section(Vector3(0,.64,-.31),.125,.13)],coat,cream)
 S.loft(neck,"BrowCheekMuzzle",[
  S.section(Vector3(0,.68,-.23),.09,.11),S.section(Vector3(0,.68,-.34),.18,.20),
  S.section(Vector3(0,.65,-.48),.19,.18),S.section(Vector3(0,.58,-.65),.13,.13),
  S.section(Vector3(0,.55,-.80),.095,.085),S.section(Vector3(0,.55,-.88),.075,.065)],coat.lightened(.05),cream,20)
 var nose=V.sphere(neck,Vector3(0,.57,-.885),.08,Color("28322c"));nose.scale=Vector3(1.05,.67,.48)
 S.branch(neck,"MouthCrease",[Vector3(-.095,.50,-.77),Vector3(0,.49,-.82),Vector3(.095,.50,-.77)],[.008,.01,.008],Color("5f4837"))
 for side in [-1,1]:
  var brow=V.sphere(neck,Vector3(side*.169,.71,-.46),.08,coat.darkened(.22));brow.scale=Vector3(.6,.55,1.15)
  var eye=V.sphere(neck,Vector3(side*.191,.688,-.49),.035,Color("172621"));eye.scale=Vector3(.42,.9,1.1);eyes.append(eye)
  V.sphere(neck,Vector3(side*.204,.699,-.505),.009,Color("f4e5be"))
  var ear=Node3D.new();neck.add_child(ear);ear.position=Vector3(side*.13,.80,-.28);ear.rotation.z=side*-.62;ears.append(ear)
  S.loft(ear,"PointedEar",[S.section(Vector3.ZERO,.055,.035),S.section(Vector3(side*.025,.15,.015),.095,.035),S.section(Vector3(side*.02,.31,.02),.07,.025),S.section(Vector3(0,.40,.015),.008,.008)],coat)
  S.loft(ear,"InnerEar",[S.section(Vector3(0,.055,-.033),.025,.009),S.section(Vector3(side*.02,.18,-.025),.06,.01),S.section(Vector3(0,.33,-.008),.004,.004)],Color("b9977c"))
  antler(side,1.35 if elite else 1.0)
 for z in [-.52,.58]:
  for x in [-.22,.22]:
   var rear=z>0;var leg=Node3D.new();add_child(leg);leg.position=Vector3(x,1.02,z);legs.append(leg)
   S.loft(leg,"UpperLeg",[S.section(Vector3(0,.20,0),.14 if rear else .10,.12),S.section(Vector3(0,.03,.02),.12,.11),S.section(Vector3(0,-.21,.08 if rear else -.025),.085,.075),S.section(Vector3(0,-.45,.08),.05,.05)],coat)
   var knee=Node3D.new();leg.add_child(knee);knee.position=Vector3(0,-.45,.08);knees.append(knee)
   S.loft(knee,"TendonAndPastern",[S.section(Vector3(0,0,0),.055,.055),S.section(Vector3(0,-.14,.045 if rear else -.015),.043,.04),S.section(Vector3(0,-.39,-.025),.027,.033),S.section(Vector3(0,-.48,-.04),.04,.045)],coat.darkened(.13))
   for side in [-1,1]:
    S.loft(knee,"ClovenHoof",[S.section(Vector3(side*.027,-.475,-.01),.024,.03),S.section(Vector3(side*.027,-.51,-.045),.025,.045),S.section(Vector3(side*.027,-.52,-.14),.023,.025)],Color("30392f"),Color.TRANSPARENT,10)
 tail=Node3D.new();add_child(tail);tail.position=Vector3(0,1.44,.78)
 S.loft(tail,"WhiteFlagTail",[S.section(Vector3.ZERO,.07,.06),S.section(Vector3(0,.05,.14),.09,.065),S.section(Vector3(0,.09,.29),.055,.04),S.section(Vector3(0,.11,.36),.004,.005)],coat,cream)
 # Explicit surface membership, before batching; no authoritative shape changes.
 var surfaces:Array[MeshInstance3D]=[];S.collect(self,surfaces)
 for mesh in surfaces:
  if str(mesh.name) in ["ChestFlankHaunch","TaperedNeck","BrowCheekMuzzle","PointedEar","InnerEar","UpperLeg","TendonAndPastern","WhiteFlagTail"]:
   preload("res://hunt/surface_families.gd").apply(mesh,"fur")
 # Merge only rigid surfaces; animated joints and blinking eyes remain independent.
 S.batch_details(neck,"HeadAndAntlers",eyes,false)
 for ear in ears:S.batch_details(ear,"EarSurface")
 for knee in knees:S.batch_details(knee,"LowerLegAndHooves")
func antler(side:int,factor:float) -> void:
 var bone=Color("c8ae80");var start=Vector3(side*.105,.81,-.32)
 var points=[start,start+Vector3(side*.055,.13,.01)*factor,start+Vector3(side*.13,.28,.08)*factor,start+Vector3(side*.22,.41,.19)*factor,start+Vector3(side*.39,.53,.23)*factor,start+Vector3(side*.54,.59,.18)*factor]
 S.branch(neck,"CurvedAntlerBeam",points,[.043,.039,.034,.027,.017,.003],bone)
 for i in range(1,5):
  var origin:Vector3=points[i];var height=(.12+.045*i)*factor
  S.branch(neck,"AntlerTine",[origin,origin+Vector3(side*.02,height*.5,-.045),origin+Vector3(side*.04,height,-.10),origin+Vector3(side*.02,height+.035,-.14)],[.022,.015,.008,.002],bone.lightened(.13))
func pose(dt:float,state:String,hp:float,head_pitch:float,speed:float,motion:float,id:int) -> void:
 life+=dt;phase+=dt*(2.0+speed*1.9)
 if previous_hp>=0 and hp<previous_hp:reaction=1.0
 previous_hp=hp;reaction=move_toward(reaction,0,dt*4)
 var dead=hp<=0;var amount=clampf(speed/4.7,0,1)*lerpf(.65,1.0,motion)
 var gallop=state in ["flee","charge"]
 for i in range(legs.size()):
  var offset=(PI if i in [0,3] else 0.0) if not gallop else ([0.0,.35,PI+.25,PI+.6][i])
  var stride=sin(phase+offset)*amount*(.9 if gallop else .55)
  var folded=(.55 if i<2 else -.48) if dead else 0.0
  legs[i].rotation.x=lerp_angle(legs[i].rotation.x,folded if dead else stride,1-exp(-11*dt))
  knees[i].rotation.x=lerp_angle(knees[i].rotation.x,.8 if dead else maxf(0,-stride)*.95,1-exp(-12*dt))
 rotation.z=lerp_angle(rotation.z,PI*.47 if dead else sin(phase)*amount*.025,1-exp(-5*dt))
 var fall=clampf(absf(rotation.z)/(PI*.47),0,1) if dead else 0.0
 var center=Vector3(0,lerpf(1.1,.36,fall)*scale.y,0)
 var pivot=Basis(Vector3.FORWARD,-rotation.z)*Vector3(0,1.1*scale.y,0)
 var offset=center-pivot if dead else Vector3(0,absf(sin(phase))*.06*amount*motion,0)
 position=position.lerp(offset,1-exp(-12*dt))
 body.scale.y=1.0+(sin(life*2.1+id)*.004 if not dead else 0.0)*motion
 neck.rotation.x=lerp_angle(neck.rotation.x,head_pitch,1-exp(-14*dt))
 neck.rotation.z=(sin(life*.8+id)*.035+reaction*.09)*motion if not dead else .15
 for i in range(ears.size()):
  var side=-1 if i==0 else 1
  ears[i].rotation.z=side*-.62+sin(life*1.8+id+i*2)*.09*motion if not dead else side*-.95
 var blink=.1 if fmod(life+id*.71,4.6)>4.45 or dead else .9
 for eye in eyes:eye.scale.y=lerpf(eye.scale.y,blink,1-exp(-22*dt))
 tail.rotation.x=lerp_angle(tail.rotation.x,-.75 if gallop and not dead else .05,1-exp(-7*dt))
 tail.rotation.y=sin(life*2.4+id)*.12*motion if not dead else 0.0
