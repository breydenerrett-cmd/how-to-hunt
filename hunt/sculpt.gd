extends RefCounted
## Original rounded cross-section meshes, shared by woodland props and animal parts.
const V=preload("res://scripts/visuals.gd")
static func loft(parent:Node3D,label:String,sections:Array,color:Color,belly:Color=Color.TRANSPARENT,sides:int=16) -> MeshInstance3D:
 var controls=sections;sections=[]
 for i in range(controls.size()-1):
  var before=controls[maxi(0,i-1)];var a=controls[i];var b=controls[i+1];var after=controls[mini(controls.size()-1,i+2)]
  for step in range(3):
   var t=step/3.0;var radii:Vector2=a.r.cubic_interpolate(b.r,before.r,after.r,t)
   sections.append({"p":a.p.cubic_interpolate(b.p,before.p,after.p,t),"r":radii.max(Vector2.ONE*.002)})
 sections.append(controls[-1])
 var previous_right=Vector3.RIGHT
 var vertices:Array[Vector3]=[];var normals:Array[Vector3]=[];var colors:Array[Color]=[]
 for row in range(sections.size()):
  var section:Dictionary=sections[row];var center:Vector3=section.p
  var tangent:Vector3=sections[mini(row+1,sections.size()-1)].p-sections[maxi(row-1,0)].p
  tangent=tangent.normalized()
  var right=previous_right-tangent*previous_right.dot(tangent)
  if right.length()<.1:right=Vector3.UP.cross(tangent)
  right=right.normalized();previous_right=right
  var up=tangent.cross(right).normalized()
  for j in range(sides):
   var angle=j*TAU/sides;var radial=right*cos(angle)*section.r.x+up*sin(angle)*section.r.y
   vertices.append(center+radial)
   normals.append((right*cos(angle)/maxf(.01,section.r.x)+up*sin(angle)/maxf(.01,section.r.y)).normalized())
   var vertical=radial.normalized().y
   var shade=color.darkened(maxf(0,vertical)*.14)
   if belly.a>0:shade=shade.lerp(belly,smoothstep(.25,.85,-vertical)*.94)
   colors.append(shade.lightened(sin(row*1.2)*.015))
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for row in range(sections.size()-1):
  for j in range(sides):
   var a=row*sides+j;var b=row*sides+(j+1)%sides;var c=a+sides;var d=b+sides
   for index in [a,c,b,b,c,d]:
    st.set_color(colors[index]);st.set_normal(normals[index]);st.set_uv(Vector2(float(index%sides)/sides,float(index/sides)/sections.size()));st.add_vertex(vertices[index])
 # End caps use explicit normals, preserving rounded side shading.
 for end in [0,sections.size()-1]:
  var normal:Vector3=(sections[0].p-sections[1].p).normalized() if end==0 else (sections[-1].p-sections[-2].p).normalized()
  for j in range(sides):
   var ring=[vertices[end*sides+j],vertices[end*sides+(j+1)%sides]]
   if end==0:ring.reverse()
   for p in [sections[end].p,ring[0],ring[1]]:st.set_normal(normal);st.set_color(color);st.set_uv(Vector2.ZERO);st.add_vertex(p)
 st.index();var node=V.mesh(parent,st.commit(),Vector3.ZERO,Color.WHITE);node.name=label
 node.material_override.vertex_color_use_as_albedo=true;node.material_override.roughness=.9
 return node
static func section(p:Vector3,width:float,height:float) -> Dictionary:return {"p":p,"r":Vector2(width,height)}
static func branch(parent:Node3D,label:String,points:Array,radii:Array,color:Color) -> MeshInstance3D:
 var sections=[]
 for i in range(points.size()):sections.append(section(points[i],radii[i],radii[i]))
 return loft(parent,label,sections,color,Color.TRANSPARENT,10)
static func batch_details(parent:Node3D,label:String,exclude:Array=[],recursive:bool=true) -> void:
 # Decorative static details share a colored mesh; interaction/collision stays separate.
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var meshes:Array[MeshInstance3D]=[]
 if recursive:collect(parent,meshes)
 else:
  for child in parent.get_children():
   if child is MeshInstance3D and child not in exclude:meshes.append(child)
 for node in meshes:
  var transform=parent.global_transform.affine_inverse()*node.global_transform
  var normal_basis=transform.basis.inverse().transposed()
  var color=Color.WHITE
  if node.material_override is StandardMaterial3D:color=node.material_override.albedo_color
  for surface in range(node.mesh.get_surface_count()):
   var arrays=node.mesh.surface_get_arrays(surface);var vertices=arrays[Mesh.ARRAY_VERTEX];var normals=arrays[Mesh.ARRAY_NORMAL];var indices=arrays[Mesh.ARRAY_INDEX];var paint=arrays[Mesh.ARRAY_COLOR]
   if indices==null or indices.is_empty():indices=range(vertices.size())
   for index in indices:
    st.set_color(color*paint[index] if paint!=null and not paint.is_empty() else color);st.set_normal((normal_basis*normals[index]).normalized());st.add_vertex(transform*vertices[index])
  node.queue_free()
 st.index();var result=V.mesh(parent,st.commit(),Vector3.ZERO,Color.WHITE);result.name=label;result.material_override.vertex_color_use_as_albedo=true
static func collect(root:Node,meshes:Array[MeshInstance3D]) -> void:
 for child in root.get_children():
  if child is MeshInstance3D:meshes.append(child)
  collect(child,meshes)
static func viewmodel(root:Node3D) -> void:
 var meshes:Array[MeshInstance3D]=[];collect(root,meshes)
 for mesh in meshes:mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
