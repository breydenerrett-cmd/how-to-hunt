extends RefCounted
## Shared static clearance map; host-owned route choice, never a position teleport.
const CELL=1.0
const CLEARANCE=.58
var grid=AStarGrid2D.new()
func _init() -> void:
 grid.region=Rect2i(-84,-102,169,167)
 grid.cell_size=Vector2.ONE*CELL
 grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
 grid.update()
func cell(p:Vector3) -> Vector2i:return Vector2i(roundi(p.x/CELL),roundi(p.z/CELL))
func point(c:Vector2i) -> Vector3:return Vector3(c.x*CELL,0,c.y*CELL)
func open(c:Vector2i) -> bool:return grid.region.has_point(c) and not grid.is_point_solid(c)
func block_disc(p:Vector3,radius:float) -> void:
 # Include the square's half diagonal so a clear cell has full body clearance.
 var radius_with_margin=radius+CLEARANCE+CELL*.71
 var center=cell(p);var span=ceili(radius_with_margin/CELL)
 for x in range(center.x-span,center.x+span+1):
  for z in range(center.y-span,center.y+span+1):
   var id=Vector2i(x,z)
   if grid.region.has_point(id) and Vector2(x*CELL-p.x,z*CELL-p.z).length()<=radius_with_margin:grid.set_point_solid(id,true)
func block_rect(rect:Rect2) -> void:
 var padded=rect.grow(CLEARANCE+CELL*.71)
 for x in range(floori(padded.position.x),ceili(padded.end.x)+1):
  for z in range(floori(padded.position.y),ceili(padded.end.y)+1):
   var id=Vector2i(x,z)
   if grid.region.has_point(id):grid.set_point_solid(id,true)
func nearest(p:Vector3) -> Vector2i:
 var id=cell(p);id.x=clampi(id.x,grid.region.position.x,grid.region.end.x-1);id.y=clampi(id.y,grid.region.position.y,grid.region.end.y-1)
 if open(id):return id
 var best=id;var distance=INF
 for x in range(id.x-8,id.x+9):
  for z in range(id.y-8,id.y+9):
   var candidate=Vector2i(x,z)
   if open(candidate) and candidate.distance_squared_to(cell(p))<distance:best=candidate;distance=candidate.distance_squared_to(cell(p))
 return best
func clear_line(a:Vector3,b:Vector3) -> bool:
 var count=maxi(1,ceili(a.distance_to(b)/.3))
 for i in range(count+1):
  if not open(cell(a.lerp(b,float(i)/count))):return false
 return true
func route(from:Vector3,to:Vector3) -> PackedVector3Array:
 var start=nearest(from);var end=nearest(to);var result=PackedVector3Array()
 if not open(start) or not open(end):return result
 var ids=grid.get_id_path(start,end)
 if ids.is_empty():return result
 # Smooth only through clearance-checked cells; retain turns around corners.
 var anchor=from;var index=0
 while index<ids.size():
  var next=index
  while next+1<ids.size() and clear_line(anchor,point(ids[next+1])):next+=1
  var p=point(ids[next]);result.append(p);anchor=p;index=next+1
 return result
func escape(from:Vector3,threat:Vector3,home:Vector3) -> PackedVector3Array:
 var away=from-threat;away.y=0
 if away.length()<.1:away=Vector3.FORWARD
 away=away.normalized();var candidates:Array=[]
 for angle in [0.0,.65,-.65,1.3,-1.3,2.0,-2.0,PI]:
  var destination=point(nearest(from+away.rotated(Vector3.UP,angle)*20))
  var home_cost=maxf(0,Vector2(destination.x-home.x,destination.z-home.z).length()-40)*.65
  candidates.append({"p":destination,"score":destination.distance_to(threat)-home_cost})
 candidates.sort_custom(func(a,b):return a.score>b.score)
 for candidate in candidates:
  var path=route(from,candidate.p)
  if path.size()>1 and from.distance_to(path[-1])>6:return path
 return PackedVector3Array()
