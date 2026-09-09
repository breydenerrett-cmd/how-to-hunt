extends RefCounted
## Original shelf props for the party's stalking equipment.
const V=preload("res://scripts/visuals.gd")
static func build(parent:Node3D,id:String) -> void:
 match id:
  "boots":
   for side in [-1,1]:
    var x=side*.14
    V.box(parent,Vector3(x,.04,-.04),Vector3(.21,.08,.37),Color("293b32"))
    var toe=V.sphere(parent,Vector3(x,.13,-.12),.14,Color("766146"));toe.scale=Vector3(.7,.6,1.1)
    V.cylinder(parent,Vector3(x,.23,.04),.095,.32,Color("766146"))
    for y in [.18,.24,.30]:V.box(parent,Vector3(x,y,-.063),Vector3(.10,.014,.012),Color("d6c09b"))
  "overshirt":
   V.cylinder(parent,Vector3(0,.28,0),.19,.46,Color("788371"),false,.15)
   for side in [-1,1]:
    var sleeve=V.cylinder(parent,Vector3(side*.22,.28,0),.075,.40,Color("788371"));sleeve.rotation.z=side*.3
   V.box(parent,Vector3(0,.28,-.19),Vector3(.02,.35,.01),Color("c8be91"))
   V.box(parent,Vector3(.085,.36,-.175),Vector3(.09,.075,.02),Color("586451"))
  "scent":
   V.cylinder(parent,Vector3(0,.17,0),.12,.30,Color("bd9a60"))
   V.cylinder(parent,Vector3(0,.35,0),.07,.08,Color("435545"))
   V.box(parent,Vector3(0,.18,-.122),Vector3(.14,.15,.01),Color("e5d7ac"))
   V.text3d(parent,Vector3(0,.2,-.135),"PINE",8,Color("263e2c")).rotation.y=PI
  "muffler":
   var body=V.cylinder(parent,Vector3(0,.13,0),.07,.55,Color("35413b"));body.rotation.z=PI/2
   for x in [-.20,-.10,0,.10,.20]:
    var band=V.ring(parent,Vector3(x,.13,0),.071,Color("6e7b6b"));band.rotation.z=PI/2;band.scale.y=.2
 if id in ["overshirt","boots","muffler"]:
  var meshes:Array[MeshInstance3D]=[];preload("res://hunt/sculpt.gd").collect(parent,meshes)
  for mesh in meshes:preload("res://hunt/surface_families.gd").apply(mesh,{"overshirt":"cloth","boots":"leather","muffler":"metal"}[id])
 preload("res://hunt/sculpt.gd").batch_details(parent,"StalkingEquipment")
