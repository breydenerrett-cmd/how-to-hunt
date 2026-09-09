extends RefCounted
## Host-computed stalking cues. Noise is movement sound, not an invisibility score.
static func surface_at(p:Vector3) -> String:
 return "trail" if (absf(p.x-sin(p.z*.07)*3.5)<2.1 and p.z<28) or Vector2(p.x,p.z-22).length()<10 else "leaf litter"
static func movement_noise(a:Node3D,gear:Array=[]) -> float:
 if a.health<=0:return 0.0
 var base=.20 if a.crouched else (1.0 if a.input_sprint else .55)
 var speed=1.8 if a.crouched else (6.5 if a.input_sprint else 4.5)
 var surface=.75 if a.surface_name=="trail" else 1.15
 var clothing=(.60 if "boots" in gear else 1.0)*(.80 if "overshirt" in gear else 1.0)
 return clampf(clothing*base*clampf(a.visual_speed/speed,0,1)*surface,0,1)
static func detection(a:Node3D,distance:float,sight:bool,scent:bool,gear:Array=[]) -> float:
 var radius=5.5 if a.crouched else (18.0 if a.input_sprint else (6.5 if a.input_reel else 11.0))
 if "overshirt" in gear:radius*=.85
 var seen=sight and distance<radius
 var heard=a.noise>.015 and distance<lerpf(2.0,14.0,a.noise)
 if not seen and not heard and not scent:return 0.0
 # Sight and scent still matter while stationary; freezing is not invisibility.
 return maxf(.25 if scent or seen else 0.0,lerpf(.15,1.0,a.noise))
static func scent_radius(gear:Array) -> float:return 4.0 if "scent" in gear else 9.0
static func shot_disturbance(game:Node,origin:Vector3,impact:Vector3,hit_surface:bool) -> void:
 # Only the host calls this after accepting a shot. A muffler never erases impact noise.
 if not game.is_host:return
 var radius=10.0 if "muffler" in game.progress.upgrades else 30.0
 for animal in game.animals.values():
  if animal.hp<=0:continue
  var muzzle=clampf(1.0-animal.position.distance_to(origin)/radius,0,1)
  var strike=clampf(1.0-animal.position.distance_to(impact)/6.0,0,1)*.9 if hit_surface else 0.0
  var amount=maxf(muzzle,strike)
  if amount<=0:continue
  animal.alert=minf(1,animal.alert+amount)
  animal.threat_position=impact if strike>muzzle else origin
