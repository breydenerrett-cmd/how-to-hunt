extends RefCounted

const Th=preload("res://scripts/theme.gd")
## Fixed rasterisation size for world text. Cost is one glyph atlas; the payoff is that
## an 8pt shop tag and a 24pt sign are equally sharp. The font is MSDF, so magnifying
## the atlas stays clean rather than going soft.
const RASTER:=96

static func surface(node:MeshInstance3D,color:Color,wood:bool=false) -> void:
	if wood:
		node.material_override=preload("res://hunt/surface_families.gd").material("timber",color)
		node.set_meta("surface_family","timber")
		return
	var mat=ShaderMaterial.new()
	mat.shader=preload("res://shaders/surface.gdshader")
	mat.set_shader_parameter("base_color",color)
	mat.set_shader_parameter("wood",wood)
	node.material_override=mat

static func material(color:Color, emission:float=0.0, metallic:float=0.0, roughness:float=0.82) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	if color.a < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if emission > 0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emission
	return m

static func mesh(parent:Node3D, shape:Mesh, pos:Vector3, color:Color) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	n.mesh = shape
	n.material_override = material(color)
	parent.add_child(n)
	n.position = pos
	return n

static func box(parent:Node3D, pos:Vector3, size:Vector3, color:Color, solid:bool=false) -> MeshInstance3D:
	var shape = BoxMesh.new()
	shape.size = size
	var n = mesh(parent,shape,pos,color)
	if solid:
		var b = StaticBody3D.new()
		parent.add_child(b)
		b.position = pos
		var c = CollisionShape3D.new()
		var s = BoxShape3D.new()
		s.size = size
		c.shape = s
		b.add_child(c)
	return n

static func cylinder(parent:Node3D, pos:Vector3, radius:float, height:float, color:Color, solid:bool=false, top:float=-1.0) -> MeshInstance3D:
	var shape = CylinderMesh.new()
	shape.top_radius = radius if top < 0 else top
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = 128 if radius>8 else 24
	var n = mesh(parent,shape,pos,color)
	if solid:
		var b = StaticBody3D.new()
		parent.add_child(b)
		b.position = pos
		var c = CollisionShape3D.new()
		var s = CylinderShape3D.new()
		s.radius = radius
		s.height = height
		c.shape = s
		b.add_child(c)
	return n

static func sphere(parent:Node3D, pos:Vector3, radius:float, color:Color) -> MeshInstance3D:
	var shape = SphereMesh.new()
	shape.radius = radius
	shape.height = radius * 2
	shape.radial_segments = 24
	shape.rings = 12
	return mesh(parent,shape,pos,color)

static func ring(parent:Node3D, pos:Vector3, radius:float, color:Color) -> MeshInstance3D:
	var shape = TorusMesh.new()
	shape.inner_radius = radius * 0.84
	shape.outer_radius = radius
	shape.rings = 24
	shape.ring_segments = 6
	return mesh(parent,shape,pos,color)

static func hand(parent:Node3D,pos:Vector3) -> Node3D:
	var root=Node3D.new(); parent.add_child(root); root.position=pos
	root.rotation.y=-0.55
	var skin=Color("d8b185")
	var skin_material=material(skin,0.0,0.0,0.86)
	# A rounded rectangular palm with a narrower wrist, rather than an egg.
	# Cross-sections keep a broad hand back and a shallow front-to-back depth.
	var sections=[Vector3(-0.071,0.035,0.017),Vector3(-0.044,0.049,0.025),Vector3(0.006,0.058,0.027),Vector3(0.040,0.052,0.022),Vector3(0.049,0.043,0.013)]
	var vertices:Array[Vector3]=[]
	for section in sections:
		for i in range(20):
			var angle=float(i)*TAU/20.0
			var ca=cos(angle); var sa=sin(angle)
			vertices.append(Vector3(signf(ca)*pow(absf(ca),0.65)*section.y,section.x,signf(sa)*pow(absf(sa),0.65)*section.z))
	var surface=SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(sections.size()-1):
		for i in range(20):
			var a=row*20+i; var b=row*20+(i+1)%20
			var c=(row+1)*20+i; var d=(row+1)*20+(i+1)%20
			for index in [a,b,c,b,d,c]: surface.add_vertex(vertices[index])
	for i in range(20):
		for vertex in [Vector3(0,sections[0].x,0),vertices[(i+1)%20],vertices[i]]: surface.add_vertex(vertex)
		for vertex in [Vector3(0,sections[-1].x,0),vertices[80+i],vertices[80+(i+1)%20]]: surface.add_vertex(vertex)
	surface.index()
	surface.generate_normals()
	var palm=mesh(root,surface.commit(),Vector3.ZERO,skin)
	palm.name="Palm"
	palm.material_override=skin_material
	# Four connected fingers curl over the knuckle ridge and around the handle.
	# Small flattened joints merge with the hand instead of reading as buttons.
	for i in range(4):
		var x=-0.038+i*0.026
		var rise=[0.000,0.004,0.002,-0.004][i]
		var knuckle=Vector3(x,0.046+rise,0.006)
		var bend=Vector3(x,0.041+rise,-0.044)
		var end=Vector3(x,-0.001+rise,-0.061)
		var joint=sphere(root,knuckle,0.014,skin)
		joint.scale=Vector3(0.94,0.60,1.25)
		joint.material_override=skin_material
		var proximal=cylinder(root,(knuckle+bend)*0.5,0.013,knuckle.distance_to(bend),skin,false,0.012)
		proximal.quaternion=Quaternion(Vector3.UP,(bend-knuckle).normalized())
		proximal.material_override=skin_material
		var curl=sphere(root,bend,0.0125,skin)
		curl.material_override=skin_material
		var distal=cylinder(root,(bend+end)*0.5,0.012,bend.distance_to(end),skin,false,0.0105)
		distal.quaternion=Quaternion(Vector3.UP,(end-bend).normalized())
		distal.material_override=skin_material
	# Opposing thumb crosses the near side of the grip, with a distinct pad.
	var thumb_base=Vector3(-0.044,-0.022,0.014)
	var thumb_joint=Vector3(-0.064,0.012,-0.019)
	var thumb_end=Vector3(-0.033,0.027,-0.047)
	var thumb=cylinder(root,(thumb_base+thumb_joint)*0.5,0.021,thumb_base.distance_to(thumb_joint),skin,false,0.018)
	thumb.quaternion=Quaternion(Vector3.UP,(thumb_joint-thumb_base).normalized())
	thumb.material_override=skin_material
	var thumb_bend=sphere(root,thumb_joint,0.018,skin)
	thumb_bend.scale=Vector3(1.0,0.84,0.88)
	thumb_bend.material_override=skin_material
	var pad=cylinder(root,(thumb_joint+thumb_end)*0.5,0.018,thumb_joint.distance_to(thumb_end),skin,false,0.015)
	pad.quaternion=Quaternion(Vector3.UP,(thumb_end-thumb_joint).normalized())
	pad.material_override=skin_material
	var fingertip=sphere(root,thumb_end,0.015,skin)
	fingertip.scale=Vector3(1.0,0.85,0.76)
	fingertip.material_override=skin_material
	var cuff=cylinder(root,Vector3(0,-0.093,0.005),0.039,0.055,Color("536e69"),false,0.040)
	cuff.scale.z=0.72
	var hem=ring(root,Vector3(0,-0.068,0.005),0.042,Color("91a394"))
	hem.scale.z=0.72
	box(root,Vector3(0.024,-0.091,0.033),Vector3(0.025,0.006,0.003),Color("b7b9a0"))
	return root

static func text3d(parent:Node3D, pos:Vector3, text:String, size:int=40, color:Color=Color("f4e8cc")) -> Label3D:
	var l = Label3D.new()
	l.text = text
	# Label3D rasterises at font_size then magnifies by pixel_size, so the old
	# font_size=size meant an 11px raster blown up to world scale — hence unreadable
	# shop tags. Rasterise at a fixed high size and derive pixel_size instead: the
	# rendered world height is identical, at up to 12x the texel density.
	l.font = Th.world_font()
	l.font_size = RASTER
	l.pixel_size = size * 0.012 / float(RASTER)
	l.modulate = color
	# Outline was a flat 6 regardless of size: 25% of the em at size 24 and 75% at
	# size 8, which swallowed the small labels. Proportional to the raster instead.
	l.outline_size = int(RASTER * 0.1)
	l.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	l.outline_modulate = Color(0.018,0.045,0.055,0.92)
	l.no_depth_test = false
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.visibility_range_end = 46.0
	parent.add_child(l)
	l.position = pos
	return l
