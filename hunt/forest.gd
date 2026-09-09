extends Node3D
const Surfaces=preload("res://hunt/surface_families.gd")
const V=preload("res://scripts/visuals.gd")
const Plants=preload("res://scripts/coastal_plants.gd")
const Camp=preload("res://hunt/camp_details.gd")
const Weapon=preload("res://hunt/weapon_model.gd")
const Routes=preload("res://hunt/wildlife_routes.gd")
var routes=Routes.new()
const C=preload("res://hunt/catalog.gd")
var displays:Dictionary={}
var tree_positions:Array[Vector3]=[]
const TRACK_LIMIT:=100
const HOOF_SCALE:=Vector3(.65,.10,1.5)
var tracks:Array=[]
var track_pool:MultiMeshInstance3D
var time=0.0
static func height_at(x:float,z:float) -> float:
 var hills=1.7+sin(x*0.046)*cos(z*0.045)*2.6+sin(z*0.082+x*0.03)*0.7
 var clearing=clampf((Vector2(x,z-20).length()-12.0)/24.0,0,1)
 return maxf(0,hills)*clearing
func point(x:float,z:float) -> Vector3:return Vector3(x,height_at(x,z),z)
func _ready() -> void:
 var sun=DirectionalLight3D.new();add_child(sun);sun.rotation_degrees=Vector3(-38,-28,0);sun.light_color=Color("fff0d7");sun.light_energy=.85;sun.shadow_enabled=true;sun.directional_shadow_max_distance=105
 var env=WorldEnvironment.new();add_child(env);env.environment=Environment.new()
 var sky=Sky.new();sky.radiance_size=Sky.RADIANCE_SIZE_512;var mat=ShaderMaterial.new();mat.shader=preload("res://hunt/woodland_sky.gdshader");sky.sky_material=mat
 var noise=FastNoiseLite.new();noise.seed=72519;noise.frequency=.018;noise.fractal_octaves=4
 var clouds=NoiseTexture2D.new();clouds.width=512;clouds.height=512;clouds.seamless=true;clouds.noise=noise;mat.set_shader_parameter("cloud_noise",clouds)
 env.environment.background_mode=Environment.BG_SKY;env.environment.sky=sky;env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_SKY;env.environment.ambient_light_color=Color("b8c8d6");env.environment.ambient_light_energy=.27;env.environment.ambient_light_sky_contribution=.30
 env.environment.tonemap_mode=Environment.TONE_MAPPER_ACES;env.environment.tonemap_exposure=1.0;env.environment.tonemap_white=6.0;env.environment.fog_enabled=true;env.environment.fog_light_color=Color("a7b6a4");env.environment.fog_density=0.0025;env.environment.fog_light_energy=.4;env.environment.fog_sky_affect=.18
 env.environment.adjustment_enabled=true;env.environment.adjustment_contrast=1.04;env.environment.adjustment_saturation=1.03
 env.environment.fog_aerial_perspective=.25;env.environment.fog_sun_scatter=.12
 # Ambient occlusion and glow are the two things the Compatibility renderer silently
 # dropped, and the reason for moving to Forward+. Measured cost is near zero here
 # because the frame is draw-call bound rather than pixel bound.
 env.environment.ssao_enabled=true;env.environment.ssao_radius=1.9;env.environment.ssao_intensity=2.4
 env.environment.ssao_power=1.5;env.environment.ssao_detail=.5;env.environment.ssao_light_affect=.05
 # One glow level, low intensity. Heavy multi-level bloom is the cheap-looking option.
 env.environment.glow_enabled=true;env.environment.glow_intensity=.5;env.environment.glow_bloom=.02
 env.environment.glow_hdr_threshold=.95;env.environment.glow_blend_mode=Environment.GLOW_BLEND_MODE_SOFTLIGHT
 # Glow levels are indexed 0..6, not the 1..7 shown in the inspector.
 for level in range(7):env.environment.set_glow_level(level,1.0 if level==3 else 0.0)
 terrain();groves();lodge();exchange();watchtower()
 reset_tracks()
func reset_tracks() -> void:
 clear_tracks()
 for i in range(9):
  var p=point(2+sin(i*.8)*2,14-i*3.0);add_track(p,0,0)
func terrain() -> void:
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for z in range(-110,71,3):
  for x in range(-90,91,3):
   for o in [Vector2(0,0),Vector2(3,0),Vector2(0,3),Vector2(3,0),Vector2(3,3),Vector2(0,3)]:
    var p=point(x+o.x,z+o.y)
    var trail=absf(p.x-sin(p.z*.07)*3.5)<2.1 and p.z<28
    var n=sin(p.x*.24+p.z*.17)*sin(p.z*.37)*.5+.5
    var c=Color("879368").lerp(Color("596d47"),n*.6)
    if trail or Vector2(p.x,p.z-22).length()<10:c=Color("a99a72").lerp(Color("b9a57c"),n*.6)
    st.set_color(c);st.add_vertex(p)
 st.generate_normals();st.index();var mesh=st.commit();var ground=V.mesh(self,mesh,Vector3.ZERO,Color.WHITE);ground.name="Terrain"
 ground.material_override=Surfaces.material("ground",Color.WHITE,true)
 var body=StaticBody3D.new();add_child(body);var collision=CollisionShape3D.new();body.add_child(collision);collision.shape=mesh.create_trimesh_shape()
 # Forest boundary is visibly composed of rock ridges, with solid fences beneath.
 for x in [-88,88]:V.box(self,Vector3(x,8,-20),Vector3(2,24,180),Color("606651"),true).hide()
 for z in [-108,70]:V.box(self,Vector3(0,8,z),Vector3(180,24,2),Color("606651"),true).hide()
func groves() -> void:
 var rng=RandomNumberGenerator.new();rng.seed=81091
 Plants._bark=Surfaces.material("bark",Color.WHITE,true)
 var batch=Plants.begin(self,"ForestGroves");batch.cell_size=28.0
 for i in range(220):
  var p=point(rng.randf_range(-85,85),rng.randf_range(-103,65))
  if Vector2(p.x,p.z-22).length()<15 or absf(p.x-sin(p.z*.07)*3.5)<5:continue
  if p.distance_to(point(-16,-28))<6 or p.distance_to(point(26,-52))<6:continue
  var s=rng.randf_range(1.4,2.6);Plants.tree(batch,p,s,rng.randf()*TAU);tree_positions.append(p);routes.block_disc(p,.32*s)
  var b=StaticBody3D.new();add_child(b);b.position=p+Vector3(0,2,0)
  var col=CollisionShape3D.new();b.add_child(col);var cs=CylinderShape3D.new();cs.radius=.32*s;cs.height=4;col.shape=cs
 for i in range(650):
  var p=point(rng.randf_range(-70,70),rng.randf_range(-90,48))
  if Vector2(p.x,p.z-22).length()<13 or absf(p.x-sin(p.z*.07)*3.5)<2.5:continue
  var s=rng.randf_range(.7,1.5);var pose=Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*s),p)
  Plants._append(batch,"ForestFern" if i%4==0 else "ForestGrass",Plants.mesh_for("fern" if i%4==0 else "grass"),pose,Color("87905c").darkened(rng.randf()*.17),true)
 Plants.flush(batch)
 var stone=SphereMesh.new();stone.radius=1;stone.height=2;stone.radial_segments=12;stone.rings=6
 var mm=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true;mm.mesh=stone;mm.instance_count=180
 for i in range(180):
  var x=rng.randf_range(-86,86);var z=rng.randf_range(-103,65);var s=rng.randf_range(.25,1.6)
  if Vector2(x,z-22).length()<15:s=.08
  if i<45:x=cos(i*TAU/45)*84;z=-20+sin(i*TAU/45)*86;s=rng.randf_range(4,9)
  mm.set_instance_transform(i,Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3(s,s*.64,s*.83)),point(x,z)))
  mm.set_instance_color(i,Color("7d8771").lightened(rng.randf()*.16))
 var node=MultiMeshInstance3D.new();add_child(node);node.multimesh=mm;node.name="ForestStones";node.material_override=Surfaces.material("stone",Color.WHITE,true)
func beam(parent:Node3D,a:Vector3,b:Vector3,r:float,color:Color) -> Node3D:
 var n=V.cylinder(parent,(a+b)*.5,r,a.distance_to(b),color,false,r*.8);n.quaternion=Quaternion(Vector3.UP,(b-a).normalized());Surfaces.apply(n,"timber");return n
func lodge() -> void:
 routes.block_rect(Rect2(C.SHOP.x-3.5,C.SHOP.z-4.5,7,5.7))
 var root=Node3D.new();add_child(root);root.position=C.SHOP+Vector3(0,0,-1.7)
 var wood=Color("826248");var trim=Color("c8ab7b")
 V.surface(V.box(root,Vector3(0,-.07,0),Vector3(7,.14,5.5),wood),wood,true)
 for x in [-3.4,3.4]:
  V.surface(V.box(root,Vector3(x,1.4,0),Vector3(.18,2.8,5.5),wood,true),wood,true)
  for z in [-2.6,2.6]:V.cylinder(root,Vector3(x,1.55,z),.13,3.1,trim)
 V.surface(V.box(root,Vector3(0,1.4,-2.6),Vector3(7,2.8,.18),wood,true),wood,true)
 for x in [-1,1]:
  var roof=V.box(root,Vector3(x*1.85,3.25,0),Vector3(3.95,.16,6.25),Color("394f4b"));roof.rotation.z=-x*.29;Surfaces.apply(roof,"metal")
  for z in range(-3,4):
   var seam=V.box(root,Vector3(x*1.85,3.34,z*.86),Vector3(3.95,.05,.05),Color("668078"));seam.rotation.z=-x*.29
 V.box(root,Vector3(0,2.55,2.8),Vector3(5.3,.64,.12),Color("354c43"))
 V.text3d(root,Vector3(0,2.6,2.88),"PINE & POWDER",24,Color("eed4a3")).billboard=BaseMaterial3D.BILLBOARD_DISABLED
 V.text3d(root,Vector3(0,2.19,2.89),"TRAIL OUTFITTER",13,Color("c2c7ad")).billboard=BaseMaterial3D.BILLBOARD_DISABLED
 var ids=C.ITEMS.keys()
 for i in range(ids.size()):
  var p=Vector3(-2.5+i*1.25,1.08,-1.55) if i<5 else Vector3(-2.7 if i<7 else 2.7,1.08,.1+float((i-5)%2)*1.35)
  V.box(root,p-Vector3(0,.13,0),Vector3(1.0,.12,.65),trim)
  var display=Node3D.new();root.add_child(display);display.position=p;displays[ids[i]]=display
  if ids[i] in ["boots","overshirt","scent","muffler"]:preload("res://hunt/gear_display.gd").build(display,ids[i])
  elif ids[i] in ["rifle","rifle2"]:
   var model=rifle(display);model.rotation=Vector3(-.2,PI/2,0);model.scale=Vector3.ONE*.7
  elif ids[i]=="ammo":
   for n in range(5):V.cylinder(display,Vector3((n-2)*.11,.11,0),.035,.22,Color("c69e59"))
  elif ids[i]=="scope":V.cylinder(display,Vector3(0,.15,0),.10,.45,Color("334846")).rotation.x=PI/2
  else:V.sphere(display,Vector3(0,.22,0),.24,Color("647153")).scale=Vector3(1,1.2,.65)
  var tag=V.text3d(root,p+Vector3(0,.78 if i>=5 else .53,.08),C.ITEMS[ids[i]].name+"\n"+str(C.ITEMS[ids[i]].cost)+" credits",11,Color("f1ddb9"));tag.visibility_range_end=6.5
 for side in [-1,1]:
  var lamp=OmniLight3D.new();root.add_child(lamp);lamp.position=Vector3(side*2,2.5,1);lamp.light_color=Color("ffd29a");lamp.light_energy=.6;lamp.omni_range=5
 # Solid sides and back keep the walk-in shop consistent with its geometry.
 for p in [Vector3(-3.4,1.3,0),Vector3(3.4,1.3,0),Vector3(0,1.3,-2.6)]:
  V.box(root,p,Vector3(.2,2.6,5.5) if p.x!=0 else Vector3(7,2.6,.2),wood,true).hide()
 Camp.lodge(root)
func exchange() -> void:
 routes.block_rect(Rect2(C.EXCHANGE.x-2.4,C.EXCHANGE.z-.8,4.8,1.6))
 var root=Node3D.new();add_child(root);root.position=C.EXCHANGE;root.rotation.y=-.15
 for x in [-2.2,2.2]:V.cylinder(root,Vector3(x,1.5,-1),.15,3,Color("937152"))
 var roof=V.box(root,Vector3(0,2.9,-.7),Vector3(5,.14,3.4),Color("ac875e"));roof.rotation.x=.08;Surfaces.apply(roof,"cloth")
 V.surface(V.box(root,Vector3(0,.76,0),Vector3(4.3,1.5,.8),Color("77664d"),true),Color("967454"),true)
 V.text3d(root,Vector3(0,2.5,.4),"THE GAME EXCHANGE",20,Color("f1dfbb")).billboard=BaseMaterial3D.BILLBOARD_DISABLED
 V.text3d(root,Vector3(0,2.14,.4),"Bring your harvest here • [E]",12).billboard=BaseMaterial3D.BILLBOARD_DISABLED
 for x in [-1.5,1.5]:V.box(root,Vector3(x,.25,1.1),Vector3(.7,.5,.65),Color("b08c61"))
 Camp.exchange(root)
func watchtower() -> void:
 var root=Node3D.new();add_child(root);root.position=point(17,-46);root.rotation.y=.2
 for x in [-1.6,1.6]:
  for z in [-1.6,1.6]:beam(root,Vector3(x,0,z),Vector3(x*.8,5,z*.8),.16,Color("886b4b"))
 V.box(root,Vector3(0,4,0),Vector3(3.7,.2,3.7),Color("a08355"))
 V.box(root,Vector3(0,6.1,0),Vector3(4.2,.15,4.2),Color("46594b")).rotation.z=.08
 for y in range(12):V.box(root,Vector3(0,.3+y*.31,1.8),Vector3(.8,.1,.15),Color("b39b74"))
 V.text3d(self,point(2,-24)+Vector3(0,1.4,0),"CROWNBACK RIDGE\n↑ Beyond the watchtower",20,Color("e7c78b"))
static func rifle(parent:Node3D) -> Node3D:
 var model=Weapon.new();parent.add_child(model);return model
func track_surface() -> MultiMeshInstance3D:
 # Every hoofprint used to be its own Node3D holding two MeshInstance3Ds, each with a
 # freshly built 24x12 SphereMesh and its own material: 200 meshes, 200 materials and
 # 200 draw calls, roughly 115k triangles, for marks a few centimetres across. One
 # MultiMesh draws the lot in a single call.
 if track_pool:return track_pool
 track_pool=MultiMeshInstance3D.new();add_child(track_pool)
 var shape=SphereMesh.new();shape.radius=.075;shape.height=.15;shape.radial_segments=8;shape.rings=4
 var mm=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=shape
 mm.instance_count=TRACK_LIMIT*2;mm.visible_instance_count=0
 track_pool.multimesh=mm;track_pool.material_override=V.material(Color("d1b671"))
 return track_pool
func refresh_tracks() -> void:
 var mm=track_surface().multimesh;var shown=0
 for t in tracks:
  # Reproduces the old hierarchy exactly: parent rotated by heading, hoof offset in that
  # rotated frame, then flattened in its own local frame.
  var rot=Basis(Vector3.UP,float(t.heading));var base=t.p+Vector3(0,.025,0)
  for x in [-.11,.11]:
   mm.set_instance_transform(shown,Transform3D(rot*Basis.from_scale(HOOF_SCALE),base+rot*Vector3(x,0,0)));shown+=1
 mm.visible_instance_count=shown
func add_track(p:Vector3,heading:float,id:int) -> void:
 tracks.append({"p":p,"id":id,"time":time,"heading":heading})
 while tracks.size()>TRACK_LIMIT:tracks.pop_front()
 refresh_tracks()
func clear_tracks() -> void:
 tracks.clear();track_surface().multimesh.visible_instance_count=0
func trail_snapshot() -> Array:
 var result=[]
 for track in tracks:result.append({"p":track.p,"id":track.id,"heading":track.heading,"age":maxf(0,time-track.time)})
 return result
func restore_trails(history:Array) -> void:
 clear_tracks()
 for track in history.slice(maxi(0,history.size()-100)):
  if not track is Dictionary or not track.get("p") is Vector3 or not track.p.is_finite():continue
  var heading=float(track.get("heading",0));var age=float(track.get("age",0))
  if not is_finite(heading) or not is_finite(age):continue
  add_track(track.p,heading,int(track.get("id",0)));tracks[-1].time=time-maxf(0,age)
func _process(dt:float) -> void:
 time+=dt
func _exit_tree() -> void:
 Plants._meshes.clear();Plants._wind=null;Plants._bark=null;Surfaces.clear()
