extends SceneTree
const F=preload("res://hunt/surface_families.gd")
const V=preload("res://scripts/visuals.gd")
const S=preload("res://hunt/sculpt.gd")
var passes=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func run() -> void:
 var first=F.material("cloth",Color("778866"))
 var second=F.material("cloth",Color("445533"))
 check(first.normal_texture==second.normal_texture and first.albedo_texture==second.albedo_texture,"different colors share the same family maps")
 check(F.material("cloth",Color("778866"))==first,"repeated family and color reuses its material")
 var valid=true
 for family in F.TYPES:
  var material=F.material(family)
  var n=material.normal_texture.get_image()
  valid=valid and n.get_width()==128 and n.has_mipmaps() and material.uv1_triplanar and not material.uv1_world_triplanar
 check(valid,"all maps are bounded mipmapped and stay attached to local geometry")
 check(F.material("metal").metallic>.7 and F.material("fur").metallic==0 and F.material("fur").metallic_specular<.1,"metal and fur retain distinct light responses")
 var holder=Node3D.new();root.add_child(holder)
 var cloth=F.apply(V.box(holder,Vector3.LEFT,Vector3.ONE,Color("778866")),"cloth")
 var metal=F.apply(V.box(holder,Vector3.RIGHT,Vector3.ONE,Color("888899")),"metal")
 var excluded=V.sphere(holder,Vector3.UP, .1,Color.WHITE)
 S.batch_details(holder,"Mixed",[excluded]);await process_frame
 var c=holder.get_node("Mixed_cloth");var m=holder.get_node("Mixed_metal")
 check(is_instance_valid(excluded) and excluded.get_parent()==holder and c!=null and m!=null,"recursive batching keeps exclusions and separates declared families")
 check(c.mesh.get_aabb().position.is_equal_approx(Vector3(-1.5,-.5,-.5)) and m.mesh.get_aabb().position.is_equal_approx(Vector3(.5,-.5,-.5)),"family batching retains geometry positions")
 var colors=c.mesh.surface_get_arrays(0)[Mesh.ARRAY_COLOR]
 check(colors.size()>0 and colors[0].is_equal_approx(Color("778866")) and c.material_override.vertex_color_use_as_albedo,"batching preserves authored color with the family texture")
 holder.queue_free();await process_frame;F.clear()
 print("TEST_SUMMARY hunt_materials passes=",passes," failures=",failures);quit(1 if failures else 0)
