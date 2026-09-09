extends RefCounted
## Original opaque leaf geometry. Static builders only add decorative MultiMeshes.
## begin(parent), tree/palm(batch, local_position, scale_or_height, yaw), flush(batch).
## Meshes/materials are shared; 16 m cells keep culling bounds local to each grove.
static var _meshes:Dictionary = {}
static var _wind:ShaderMaterial
static var _bark:StandardMaterial3D

static func begin(parent:Node3D, label:String="CoastalPlants") -> Dictionary:
	var root=Node3D.new()
	root.name=label
	parent.add_child(root)
	return {"root":root,"groups":{},"plants":0}

static func tree(batch:Dictionary, p:Vector3, size:float=1.0, yaw:float=0.0) -> void:
	var pose=Transform3D(Basis(Vector3.UP,yaw).scaled(Vector3.ONE*size),p)
	_append(batch,"EvergreenBark",mesh_for("tree_bark"),pose,Color("957559"),false)
	_append(batch,"EvergreenLeaves",mesh_for("tree_leaves"),pose,Color("496f56"),true)
	batch.plants+=1

static func palm(batch:Dictionary, p:Vector3, height:float=4.0, yaw:float=0.0) -> void:
	var size=height/4.0
	var pose=Transform3D(Basis(Vector3.UP,yaw).scaled(Vector3.ONE*size),p)
	_append(batch,"PalmBark",mesh_for("palm_bark"),pose,Color("ac9270"),false)
	_append(batch,"PalmFronds",mesh_for("palm_leaves"),pose,Color("69965b"),true)
	batch.plants+=1

static func _append(batch:Dictionary, kind:String, shape:Mesh, pose:Transform3D, color:Color, moving:bool) -> void:
	var span=float(batch.get("cell_size",16.0))
	var cell=Vector2i(floori(pose.origin.x/span),floori(pose.origin.z/span))
	var key="%s_%d_%d"%[kind,cell.x,cell.y]
	if not batch.groups.has(key):
		batch.groups[key]={"mesh":shape,"poses":[],"colors":[],"moving":moving}
	var group:Dictionary=batch.groups[key]
	group.poses.append(pose)
	var variation=0.94+fposmod(sin(pose.origin.x*3.13+pose.origin.z*7.71)*437.2,1.0)*0.12
	group.colors.append(Color(color.r*variation,color.g*variation,color.b*variation))

static func flush(batch:Dictionary) -> Dictionary:
	var nodes=0
	var instances=0
	for key in batch.groups:
		var group:Dictionary=batch.groups[key]
		var mm=MultiMesh.new()
		mm.transform_format=MultiMesh.TRANSFORM_3D
		mm.use_colors=true
		mm.mesh=group.mesh
		mm.instance_count=group.poses.size()
		for i in range(mm.instance_count):
			mm.set_instance_transform(i,group.poses[i])
			mm.set_instance_color(i,group.colors[i])
		var node=MultiMeshInstance3D.new()
		node.name=key
		node.multimesh=mm
		node.material_override=wind_material() if group.moving else bark_material()
		# Automatic bounds include the entire real mesh; only add the small shader sway.
		node.extra_cull_margin=0.22 if group.moving else 0.0
		batch.root.add_child(node)
		nodes+=1
		instances+=mm.instance_count
	batch.groups.clear()
	return {"nodes":nodes,"instances":instances,"plants":batch.plants}

static func wind_material() -> ShaderMaterial:
	if _wind!=null: return _wind
	var shader=Shader.new()
	shader.code="""
shader_type spatial;
render_mode cull_disabled;
varying vec3 leaf_tint;
void vertex() {
	vec3 wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	float gust=sin(TIME*1.25+wp.x*0.22+wp.z*0.16);
	float flutter=sin(TIME*2.7+wp.x*1.1+wp.z*0.8);
	VERTEX.x+=(gust*0.085+flutter*0.018)*UV.x;
	VERTEX.z+=gust*0.034*UV.x;
	leaf_tint=COLOR.rgb;
}
void fragment() {
	ALBEDO=leaf_tint;
	ROUGHNESS=0.94;
}
"""
	_wind=ShaderMaterial.new()
	_wind.shader=shader
	return _wind

static func bark_material() -> StandardMaterial3D:
	if _bark==null:
		_bark=StandardMaterial3D.new()
		_bark.vertex_color_use_as_albedo=true
		_bark.roughness=0.97
	return _bark

static func mesh_for(kind:String) -> ArrayMesh:
	if _meshes.has(kind): return _meshes[kind]
	var s=SurfaceTool.new()
	s.begin(Mesh.PRIMITIVE_TRIANGLES)
	match kind:
		"tree_bark": _evergreen(s,false)
		"tree_leaves": _evergreen(s,true)
		"palm_bark": _palm(s,false)
		"palm_leaves": _palm(s,true)
		"fern": _fern(s)
		"reed": _grass(s,true)
		_: _grass(s,false)
	var shape=s.commit()
	_meshes[kind]=shape
	return shape

static func _triangle(s:SurfaceTool, a:Vector3, b:Vector3, c:Vector3, color:Color, bend:float=0.0, weights:Vector3=Vector3(-1,-1,-1)) -> void:
	var normal=(b-a).cross(c-a).normalized()
	var points=[a,b,c]
	for i in range(3):
		s.set_normal(normal)
		s.set_color(color)
		s.set_uv(Vector2(bend if weights[i]<0.0 else weights[i],0))
		s.add_vertex(points[i])

static func _leaf(s:SurfaceTool, base:Vector3, tip:Vector3, width:float, color:Color, bend:float=1.0, roll:float=0.0) -> void:
	var direction=(tip-base).normalized()
	var side=direction.cross(Vector3.UP).normalized()
	if side.length_squared()<0.1: side=Vector3.RIGHT
	side=side.rotated(direction,roll)
	var fold=direction.cross(side).normalized()
	var ridge=base.lerp(tip,0.48)+fold*width*0.28
	# A folded six-sided blade reads as a leaf at ground level, rather than a diamond card.
	var outline=[base,base.lerp(tip,0.30)+side*width,base.lerp(tip,0.72)+side*width*0.72,
		tip,base.lerp(tip,0.72)-side*width*0.72,base.lerp(tip,0.30)-side*width]
	var weights=[0.0,0.30,0.72,1.0,0.72,0.30]
	for i in range(6):
		var next=(i+1)%6
		var shade=color.darkened(0.045) if i<3 else color
		_triangle(s,outline[i],outline[next],ridge,shade,0.0,Vector3(weights[i],weights[next],0.48)*bend)

static func _tube(s:SurfaceTool, points:Array[Vector3], radii:Array[float], sides:int=7) -> void:
	for n in range(points.size()-1):
		var up=(points[n+1]-points[n]).normalized()
		var across=up.cross(Vector3.FORWARD).normalized()
		if across.length_squared()<0.1: across=Vector3.RIGHT
		var front=up.cross(across).normalized()
		for j in range(sides):
			var a=float(j)*TAU/sides
			var b=float(j+1)*TAU/sides
			var v0=points[n]+(across*cos(a)+front*sin(a))*radii[n]
			var v1=points[n]+(across*cos(b)+front*sin(b))*radii[n]
			var v2=points[n+1]+(across*cos(b)+front*sin(b))*radii[n+1]
			var v3=points[n+1]+(across*cos(a)+front*sin(a))*radii[n+1]
			var shade=Color.WHITE.darkened(0.035*float(j%3)+0.025*float(n%2))
			_triangle(s,v0,v1,v2,shade)
			_triangle(s,v0,v2,v3,shade)

static func _evergreen(s:SurfaceTool, leaves:bool) -> void:
	if not leaves:
		_tube(s,[Vector3.ZERO,Vector3(0.06,1.4,0),Vector3(-0.09,2.8,0.03),Vector3(0.08,4.25,0)],[0.23,0.18,0.11,0.025])
	for tier in range(4):
		var height=1.9+tier*0.61
		var reach=1.62-tier*0.27
		var branch_count=5 if tier<3 else 4
		for branch in range(branch_count):
			var angle=float(branch)*TAU/branch_count+tier*1.07
			var outward=Vector3(cos(angle),0,sin(angle))
			var side=Vector3(-outward.z,0,outward.x)
			var start=Vector3(0,height+sin(branch*2.31+tier)*0.13,0)
			var end=start+outward*reach+Vector3.UP*(0.12+sin(branch*1.7+tier)*0.16)
			if not leaves:
				_tube(s,[start,start.lerp(end,0.5)-Vector3.UP*0.10,end],[0.08-tier*0.012,0.045,0.009],5)
			# Connected twig fans support fewer, larger leaves in overlapping tilted volumes.
			for spray in range(4):
				var t=0.16+spray*0.22
				var stem=start.lerp(end,t)-Vector3.UP*(sin(t*PI)*0.10)
				var span=(1.0-t*0.40)*(0.76-tier*0.06)
				for sign_value in [-1,1]:
					var rise=0.18+0.17*sin(spray*2.1+branch+sign_value)
					var spray_end=stem+side*float(sign_value)*span+outward*0.30+Vector3.UP*rise
					if not leaves:
						_tube(s,[stem,spray_end],[0.035,0.008],5)
						continue
					for leaflet in range(3):
						var f=float(leaflet)*0.34
						var base=stem.lerp(spray_end,f)
						var tip=base+outward*(0.50+0.12*sin(f*PI))+side*float(sign_value)*0.20+Vector3.UP*(0.10+0.26*sin(leaflet*1.8+spray+branch))
						var leaf_roll=float(sign_value)*(0.28+0.44*sin(spray+leaflet*1.3))
						_leaf(s,base,tip,0.22,Color.WHITE.darkened(0.11*(1.0-t)),0.45+t*0.40,leaf_roll)
			if leaves:
				_leaf(s,start.lerp(end,0.40),end+Vector3.UP*0.38,0.33,Color.WHITE.darkened(0.07),0.55,-0.25)
				_leaf(s,end-outward*0.22,end+outward*0.36+Vector3.UP*0.23,0.24,Color.WHITE,0.80,0.45)
	if leaves:
		for j in range(5):
			var angle=float(j)*TAU/5.0
			_leaf(s,Vector3(0,3.62,0),Vector3(cos(angle)*0.40,4.48,sin(angle)*0.40),0.24,Color.WHITE,0.6,float(j)*0.21)

static func _palm(s:SurfaceTool, leaves:bool) -> void:
	var crown=Vector3(0.38,4.0,0.16)
	if not leaves:
		var points:Array[Vector3]=[]
		var radii:Array[float]=[]
		for i in range(17):
			var t=float(i)/16.0
			points.append(Vector3(crown.x*t*t,4.0*t,crown.z*t*t))
			radii.append(lerpf(0.21,0.115,t)+(0.018 if i%2==0 else 0.0))
		_tube(s,points,radii,8)
		return
	for frond in range(9):
		var angle=float(frond)*TAU/9.0
		var outward=Vector3(cos(angle),0,sin(angle))
		var side=Vector3(-outward.z,0,outward.x)
		var reach=2.35+float(frond%3)*0.18
		var arch=0.48+float(frond%3)*0.10
		for step in range(8):
			var t=float(step)/8.0
			var next_t=float(step+1)/8.0
			var stem=crown+outward*reach*t+Vector3.UP*(sin(t*PI)*arch-t*t*1.06)
			var next=crown+outward*reach*next_t+Vector3.UP*(sin(next_t*PI)*arch-next_t*next_t*1.06)
			# Broad folded center connects the feathered margins into a readable frond.
			var width=sin(t*PI)*0.40+0.025
			var next_width=sin(next_t*PI)*0.40+0.025
			var left=stem+side*width-Vector3.UP*width*0.40
			var right=stem-side*width-Vector3.UP*width*0.40
			var next_left=next+side*next_width-Vector3.UP*next_width*0.40
			var next_right=next-side*next_width-Vector3.UP*next_width*0.40
			var color=Color.WHITE.darkened(frond%3*0.045)
			_triangle(s,stem,left,next_left,color)
			_triangle(s,stem,next_left,next,color)
			_triangle(s,stem,next,next_right,color.darkened(0.055))
			_triangle(s,stem,next_right,right,color.darkened(0.055))
			if step==0: continue
			var span=sin(t*PI)*0.78+0.09
			for sign_value in [-1,1]:
				var tip=stem+side*float(sign_value)*span+outward*(0.31+t*0.25)-Vector3.UP*(0.13+t*0.21)
				_leaf(s,stem,tip,0.18*(1.0-t*0.35),color,0.35+t*0.40,float(sign_value)*0.25)
	# Three upright new leaves break the otherwise radial crown.
	for j in range(3):
		var angle=float(j)*TAU/3.0+0.4
		_leaf(s,crown,crown+Vector3(cos(angle)*0.60,0.92,sin(angle)*0.60),0.19,Color.WHITE.lightened(0.10),0.6)

static func _fern(s:SurfaceTool) -> void:
	for frond in range(6):
		var angle=float(frond)*TAU/6.0
		var outward=Vector3(cos(angle),0,sin(angle))
		var side=Vector3(-outward.z,0,outward.x)
		var previous=Vector3.ZERO
		for j in range(6):
			var t=0.14+float(j)*0.13
			var base=outward*t*0.65+Vector3.UP*(sin(t*PI)*0.35+0.04)
			_leaf(s,previous,base,0.016,Color.WHITE.darkened(0.12),0.0)
			previous=base
			for sign_value in [-1,1]:
				var tip=base+outward*0.12+side*float(sign_value)*0.20*(1.0-t)+Vector3.UP*0.035
				_leaf(s,base,tip,0.038,Color.WHITE.darkened(frond%2*0.08),t)

static func _grass(s:SurfaceTool, reed:bool) -> void:
	var count=9 if reed else 11
	for blade in range(count):
		var angle=float(blade)*2.399
		var outward=Vector3(cos(angle),0,sin(angle))
		var side=Vector3(-outward.z,0,outward.x)
		var height=(0.64+float(blade%4)*0.13) if reed else (0.23+float(blade%4)*0.055)
		var lean=0.25 if reed else 0.30
		var width=0.018 if reed else 0.034
		var base=outward*(0.04+float(blade%3)*0.035)
		for segment in range(4):
			var t=float(segment)/4.0
			var next_t=float(segment+1)/4.0
			var a=base+Vector3.UP*height*t+outward*lean*t*t
			var b=base+Vector3.UP*height*next_t+outward*lean*next_t*next_t
			var w0=width*(1.0-t*0.92)
			var w1=width*(1.0-next_t*0.92)
			var color=Color.WHITE.darkened(0.05*float(blade%3))
			# Shared ribbon vertices receive matching weights, preventing wind seams.
			_triangle(s,a-side*w0,a+side*w0,b+side*w1,color,0.0,Vector3(t*t,t*t,next_t*next_t))
			_triangle(s,a-side*w0,b+side*w1,b-side*w1,color,0.0,Vector3(t*t,next_t*next_t,next_t*next_t))
		if reed and blade%3==0:
			var head=base+Vector3.UP*height+outward*lean
			_leaf(s,head-Vector3.UP*0.08,head+Vector3.UP*0.12,0.035,Color(0.89,0.79,0.57),1.0)
