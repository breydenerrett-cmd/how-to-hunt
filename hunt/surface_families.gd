extends RefCounted
## Original, small tileable material maps. Shared across objects; never touch physics.
## Local triplanar mapping keeps detail attached to moving animals and equipment.
const SIZE=128
const TYPES={
 "timber":{"rough":.84,"spec":.22,"scale":Vector3(1.4,.28,1.4),"bump":.7},
 "bark":{"rough":.96,"spec":.12,"scale":Vector3(1.1,.22,1.1),"bump":1.4},
 "stone":{"rough":.80,"spec":.28,"scale":Vector3.ONE*.8,"bump":1.6},
 "fur":{"rough":.94,"spec":.08,"scale":Vector3(4,1.6,4),"bump":.25},
 "cloth":{"rough":.88,"spec":.15,"scale":Vector3.ONE*3,"bump":.55},
 "leather":{"rough":.76,"spec":.24,"scale":Vector3.ONE*3,"bump":.65},
 "metal":{"rough":.32,"spec":.5,"scale":Vector3.ONE*2,"bump":.14},
 "ground":{"rough":.98,"spec":.08,"scale":Vector3.ONE*.65,"bump":1.0}
}
static var maps:Dictionary={}
static var materials:Dictionary={}
static func material(family:String,color:Color=Color.WHITE,vertex_color:bool=false) -> StandardMaterial3D:
 assert(TYPES.has(family),"Unknown surface family")
 var key=family+":"+color.to_html()+":"+str(vertex_color)
 if materials.has(key):return materials[key]
 if not maps.has(family):maps[family]=make_maps(family)
 var definition:Dictionary=TYPES[family];var textures:Dictionary=maps[family]
 var m=StandardMaterial3D.new();m.albedo_color=color;m.vertex_color_use_as_albedo=vertex_color
 m.roughness=definition.rough;m.metallic_specular=definition.spec;m.metallic=.78 if family=="metal" else 0.0
 m.albedo_texture=textures.color;m.normal_enabled=true;m.normal_texture=textures.normal;m.normal_scale=1.0
 m.roughness_texture=textures.rough;m.roughness_texture_channel=BaseMaterial3D.TEXTURE_CHANNEL_RED
 m.uv1_triplanar=true;m.uv1_triplanar_sharpness=4;m.uv1_scale=definition.scale
 m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
 materials[key]=m;return m
static func apply(node:MeshInstance3D,family:String) -> MeshInstance3D:
 var color=Color.WHITE;var vertex_color=false
 if node.material_override is StandardMaterial3D:
  color=node.material_override.albedo_color;vertex_color=node.material_override.vertex_color_use_as_albedo
 node.set_meta("surface_family",family);node.material_override=material(family,color,vertex_color);return node
static func make_maps(family:String) -> Dictionary:
 var height=Image.create(SIZE,SIZE,false,Image.FORMAT_RGB8)
 var color=Image.create(SIZE,SIZE,false,Image.FORMAT_RGB8)
 var rough=Image.create(SIZE,SIZE,false,Image.FORMAT_RGB8)
 var noise=FastNoiseLite.new();noise.seed=17429;noise.frequency=.12;noise.fractal_octaves=3
 for y in range(SIZE):
  for x in range(SIZE):
   var u=float(x)/SIZE;var v=float(y)/SIZE
   # Blend opposite edges of a seeded noise tile; repeating maps have no hard seam.
   var n=lerpf(lerpf(noise.get_noise_2d(x,y),noise.get_noise_2d(x-SIZE,y),u),lerpf(noise.get_noise_2d(x,y-SIZE),noise.get_noise_2d(x-SIZE,y-SIZE),u),v)*.5+.5
   var detail=n
   match family:
    "timber","bark":detail=.5+.75*(n-.5)+.075*sin(u*TAU*12+sin(v*TAU)*1.1)
    "fur":detail=.5+.20*sin(u*TAU*29+sin(v*TAU*3)*.4)+.24*(n-.5)
    "cloth":detail=.5+.17*sin(u*TAU*24)*sin(v*TAU*24)+.12*(n-.5)
    "metal":detail=.5+(n-.5)*.10
   detail=clampf(detail,0,1);height.set_pixel(x,y,Color(detail,detail,detail))
   var grain=lerpf(.88,1.0,detail) if family in ["timber","bark","stone","ground"] else lerpf(.94,1.0,detail)
   color.set_pixel(x,y,Color(grain,grain,grain))
   var r=lerpf(.91,1.0,n);rough.set_pixel(x,y,Color(r,r,r))
 height.bump_map_to_normal_map(TYPES[family].bump)
 height.generate_mipmaps(true);color.generate_mipmaps();rough.generate_mipmaps()
 return {"normal":ImageTexture.create_from_image(height),"color":ImageTexture.create_from_image(color),"rough":ImageTexture.create_from_image(rough)}
static func clear() -> void:
 materials.clear();maps.clear()
