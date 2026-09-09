extends RefCounted
const V=preload("res://scripts/visuals.gd")
const S=preload("res://hunt/sculpt.gd")
static func lodge(parent:Node3D) -> void:
 var root=Node3D.new();parent.add_child(root);root.name="LodgeCraftDetails"
 var wood=Color("a08259");var dark=Color("4b594c")
 for x in [-3.38,3.38]:
  for i in range(8):
   var z=-2.4+i*.65
   V.box(root,Vector3(x,1.35,z),Vector3(.23,2.65,.045),wood.darkened(.16+float(i%3)*.03))
  V.box(root,Vector3(x,.16,0),Vector3(.35,.3,5.7),Color("6e7569"))
  V.box(root,Vector3(x,2.7,0),Vector3(.27,.18,5.7),wood)
 for x in [-3.3,0,3.3]:V.box(root,Vector3(x,1.4,-2.52),Vector3(.12,2.7,.16),wood)
 for x in [-2.7,2.7]:
  V.box(root,Vector3(x,2.65,2.7),Vector3(.13,.7,.14),wood).rotation.z=-signf(x)*.7
  lantern(root,Vector3(x,2.1,2.65))
 # Interior fittings sit within the original collidable shop footprint.
 for x in [-2.9,2.9]:
  barrel(root,Vector3(x,.45,-.8))
  for z in [-2.2,-1.5]:V.box(root,Vector3(x,.1,z),Vector3(.55,.18,.6),Color("a38b66"))
 V.box(root,Vector3(0,2.07,-2.43),Vector3(1.45,.70,.09),dark)
 # Small brass compass emblem over the equipment rack.
 var ring=V.ring(root,Vector3(0,2.10,-2.36),.22,Color("c5a56b"));ring.rotation.x=PI/2
 for angle in [0,PI/2]:V.box(root,Vector3(0,2.10,-2.32),Vector3(.035,.36,.028),Color("e1c488")).rotation.z=angle
 for node in root.get_children():
  if node is MeshInstance3D and str(node.name).begins_with("Barrel"):preload("res://hunt/surface_families.gd").apply(node,"timber")
 S.batch_details(root,"LodgeDetailsBatch")
static func exchange(parent:Node3D) -> void:
 var root=Node3D.new();parent.add_child(root);root.name="ExchangeCraftDetails"
 var wood=Color("967a55");var dark=Color("43584b")
 # Raised back wall and gabled canopy dress the existing sales counter.
 for x in [-2.05,2.05]:
  V.box(root,Vector3(x,1.75,-.35),Vector3(.13,2.5,.15),wood)
  V.box(root,Vector3(x,2.55,-.55),Vector3(.13,.7,.14),wood).rotation.z=-signf(x)*.7
  lantern(root,Vector3(x,1.94,.40))
 for i in range(12):
  V.box(root,Vector3(-1.95+i*.355,.73,.42),Vector3(.025,1.4,.035),wood.darkened(.15))
 V.box(root,Vector3(0,1.55,0),Vector3(4.55,.14,1.05),Color("b09165"))
 # Counter tools: brass weighing pan, ledger, wrapped field supplies.
 V.cylinder(root,Vector3(-1.25,1.67,0),.22,.1,Color("626d5d"))
 V.cylinder(root,Vector3(-1.25,1.87,0),.035,.32,Color("b59d69"))
 V.cylinder(root,Vector3(-1.25,2.01,0),.30,.035,Color("bba777"))
 V.box(root,Vector3(.35,1.65,.04),Vector3(.55,.07,.37),dark).rotation.y=.2
 V.box(root,Vector3(.35,1.69,.04),Vector3(.49,.012,.32),Color("d4c4a1")).rotation.y=.2
 for x in [.94,1.26,1.55]:V.cylinder(root,Vector3(x,1.72,-.04),.09,.20,Color("ac9b74"))
 S.batch_details(root,"ExchangeDetailsBatch")
static func barrel(parent:Node3D,p:Vector3) -> void:
 S.loft(parent,"Barrel",[S.section(p+Vector3(0,-.42,0),.28,.28),S.section(p,.34,.34),S.section(p+Vector3(0,.42,0),.28,.28)],Color("826445"),Color.TRANSPARENT,12)
 for y in [-.29,.29]:V.ring(parent,p+Vector3(0,y,0),.32,Color("46534a")).scale.y=.25
static func lantern(parent:Node3D,p:Vector3) -> void:
 V.box(parent,p,Vector3(.18,.26,.16),Color("d6b477"))
 for y in [-.15,.15]:V.box(parent,p+Vector3(0,y,0),Vector3(.24,.06,.23),Color("36483e"))
 for x in [-.10,.10]:V.box(parent,p+Vector3(x,0,0),Vector3(.025,.27,.19),Color("36483e"))
