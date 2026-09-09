extends Node3D
## Original trail rifle; all mechanism motion is cosmetic.
const F=preload("res://hunt/surface_families.gd")
const V=preload("res://scripts/visuals.gd")
const S=preload("res://hunt/sculpt.gd")
var bolt:Node3D
var scope:Node3D
var muffler:Node3D
var was_reloading=false
var reload_started=0.0
func _ready() -> void:
 var wood=Color("815437");var steel=Color("354443");var brass=Color("b9995e")
 var stock=S.loft(self,"CarvedWalnutStock",[S.section(Vector3(0,-.02,-.03),.055,.07),S.section(Vector3(0,-.005,.08),.05,.06),S.section(Vector3(0,-.055,.19),.065,.12),S.section(Vector3(0,-.07,.37),.072,.145),S.section(Vector3(0,-.07,.45),.069,.14)],wood,Color.TRANSPARENT,20)
 grain(stock,wood)
 S.loft(self,"RecoilPad",[S.section(Vector3(0,-.07,.445),.071,.143),S.section(Vector3(0,-.07,.475),.072,.143)],Color("303d35"),Color.TRANSPARENT,20)
 var fore=S.loft(self,"Forestock",[S.section(Vector3(0,.018,-.14),.062,.067),S.section(Vector3(0,.015,-.4),.06,.055),S.section(Vector3(0,.034,-.59),.047,.039)],wood)
 grain(fore,wood)
 F.apply(V.box(self,Vector3(0,.076,-.19),Vector3(.108,.12,.30),steel),"metal")
 for z in [-.12,-.24]:V.box(self,Vector3(0,.143,z),Vector3(.06,.014,.035),Color("9fa497"))
 var barrel=V.cylinder(self,Vector3(0,.11,-.64),.027,.78,steel);barrel.rotation.x=PI/2;F.apply(barrel,"metal")
 var muzzle=V.cylinder(self,Vector3(0,.11,-1.04),.032,.035,Color("5b6964"));muzzle.rotation.x=PI/2;F.apply(muzzle,"metal")
 var bore=V.cylinder(self,Vector3(0,.11,-1.061),.016,.002,Color("111d1b"));bore.rotation.x=PI/2
 for z in [-.43,-.58]:
  var band=V.ring(self,Vector3(0,.064,z),.063,steel);band.scale=Vector3(1,1.1,.28);band.rotation.x=PI/2
 S.branch(self,"TriggerGuard",[Vector3(0,-.01,-.02),Vector3(0,-.13,-.03),Vector3(0,-.155,-.13),Vector3(0,-.14,-.25),Vector3(0,-.01,-.26)],[.011,.011,.012,.011,.01],steel)
 S.branch(self,"Trigger",[Vector3(0,-.005,-.14),Vector3(0,-.075,-.14),Vector3(0,-.10,-.10)],[.012,.012,.008],brass)
 var grip=S.loft(self,"PistolGrip",[S.section(Vector3(0,-.035,.015),.055,.065),S.section(Vector3(0,-.15,.075),.05,.055),S.section(Vector3(0,-.20,.08),.045,.04)],wood)
 grain(grip,wood)
 bolt=Node3D.new();add_child(bolt);bolt.position=Vector3(0,.10,-.15)
 var shaft=V.cylinder(bolt,Vector3(.09,-.015,0),.013,.16,Color("a7ada2"));shaft.rotation.z=PI/2
 V.sphere(bolt,Vector3(.17,-.035,0),.028,steel)
 for z in [.29,-.47]:
  for side in [-1,1]:
   var screw=V.cylinder(self,Vector3(side*.065,-.025,z),.012,.005,brass);screw.rotation.z=PI/2
 V.box(self,Vector3(0,.15,-.94),Vector3(.017,.067,.026),steel)
 V.sphere(self,Vector3(0,.186,-.94),.008,brass)
 scope=Node3D.new();add_child(scope);scope.position=Vector3(0,.23,-.20)
 for z in [-.10,.10]:
  V.box(scope,Vector3(0,-.045,z),Vector3(.07,.06,.032),steel)
 var optic=V.cylinder(scope,Vector3.ZERO,.046,.36,steel);optic.rotation.x=PI/2;F.apply(optic,"metal")
 for z in [-.19,.19]:
  var rim=V.cylinder(scope,Vector3(0,0,z),.060,.06,steel);rim.rotation.x=PI/2
  var lens=V.cylinder(scope,Vector3(0,0,z+signf(z)*.032),.048,.003,Color("517e78"));lens.rotation.x=PI/2;lens.material_override.metallic=.5;lens.material_override.roughness=.15
 scope.hide()
 muffler=Node3D.new();add_child(muffler)
 var sleeve=V.cylinder(muffler,Vector3(0,.11,-1.13),.056,.25,Color("35413b"));sleeve.rotation.x=PI/2;F.apply(sleeve,"metal")
 for z in [-1.23,-1.17,-1.11]:
  var ring=V.ring(muffler,Vector3(0,.11,z),.056,Color("677363"));ring.rotation.x=PI/2;ring.scale.y=.2
 var opening=V.cylinder(muffler,Vector3(0,.11,-1.257),.021,.003,Color("14221b"));opening.rotation.x=PI/2
 muffler.hide()
func presentation(reloading:bool,clock:float,has_scope:bool,motion:float,has_muffler:bool=false) -> void:
 scope.visible=has_scope
 muffler.visible=has_muffler
 if reloading and not was_reloading:reload_started=clock
 was_reloading=reloading
 var cycle=sin(clampf((clock-reload_started)/1.4,0,1)*PI) if reloading else 0.0
 bolt.rotation.z=cycle*-.95*motion;bolt.position.z=-.15+cycle*.07*motion
static func grain(node:MeshInstance3D,color:Color) -> void:
 var shader=Shader.new();shader.code="""
shader_type spatial;
uniform vec4 tint : source_color;
varying vec3 local;
void vertex(){ local=VERTEX; }
void fragment(){
 float grain=sin(local.z*39.0+sin(local.y*62.0)*.35+local.x*190.0);
 ALBEDO=tint.rgb*(.94+grain*.045);
 ROUGHNESS=.71;
}
"""
 var material=ShaderMaterial.new();material.shader=shader;material.set_shader_parameter("tint",color);node.material_override=material
