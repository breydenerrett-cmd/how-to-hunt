extends RefCounted
const VERSION="0.1.6-hunt"
const PROTOCOL=2
const PORT=27951
const CAMP=Vector3(0,0.15,26)
const SHOP=Vector3(-6,0,19)
const EXCHANGE=Vector3(7,0,21)
const ITEMS={
 "rifle":{"name":"Trail rifle","cost":25,"detail":"Steady bolt-action • includes 12 rounds"},
 "ammo":{"name":"12 field rounds","cost":8,"detail":"Shared ammunition • top up at camp"},
 "scope":{"name":"Clear-glass sight","cost":65,"detail":"Closer aimed view; steadies 35% faster"},
 "pack":{"name":"Dragging harness","cost":45,"detail":"Move 25% faster while bringing game home"},
 "rifle2":{"name":"Ranger action","cost":110,"detail":"40% faster bolt cycle • requires trail rifle"},
 "boots":{"name":"Softstep boots","cost":35,"detail":"40% less movement noise • shared party upgrade"},
 "overshirt":{"name":"Wool overshirt","cost":55,"detail":"20% less movement noise; 15% shorter sight detection range"},
 "scent":{"name":"Pine scent cover","cost":40,"detail":"Permanent party kit • scent range 9m → 4m; wind still matters"},
 "muffler":{"name":"Muffled barrel","cost":130,"detail":"Shot sound range 30m → 10m • impacts and direct hits still alert wildlife"}
}
static func new_progress() -> Dictionary:
 return {"schema":1,"game":"how_to_hunt","wallet":40,"upgrades":[],"ammo":0,"sold":0,"banked":0,"contract":0,"sequence":0,"animals":[]}
static func valid_progress(p:Variant) -> bool:
 if not p is Dictionary or not p.has_all(new_progress().keys()):return false
 if p.schema!=1 or p.game!="how_to_hunt":return false
 for key in ["wallet","ammo","sold","banked","contract","sequence"]:
  var n=p[key]
  if typeof(n) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(n)) or n<0 or n>100000000 or float(n)!=floorf(float(n)):return false
 if p.contract>2 or p.ammo>9999 or not p.upgrades is Array or not p.animals is Array or p.animals.size()>12:return false
 var ids=[]
 for id in p.upgrades:
  if not id is String or not ITEMS.has(id) or id=="ammo" or id in ids:return false
  ids.append(id)
 ids=[]
 for a in p.animals:
  if not a is Dictionary or not a.has_all(["id","p","size","hp","shots","value","elite"]):return false
  if typeof(a.id) not in [TYPE_INT,TYPE_FLOAT] or a.id<1 or a.id in ids:return false
  ids.append(a.id)
  if not a.p is Array or a.p.size()!=3:return false
  for n in a.p:
   if typeof(n) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(n)) or absf(n)>500:return false
  for key in ["size","hp","shots","value"]:
   if typeof(a[key]) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(a[key])):return false
  if a.size<0.8 or a.size>1.7 or a.hp<0 or a.hp>180 or a.shots<0 or a.shots>100 or a.value<0 or a.value>500 or not a.elite is bool:return false
 return true
static func objective(p:Dictionary) -> String:
 if "rifle" not in p.upgrades:return "1 / 4 • Visit the lodge and buy your trail rifle."
 if int(p.sold)==0:return "2 / 4 • Follow hoofprints. Aim steadily, then shoot."
 if int(p.contract)==0:return "3 / 4 • Bring two deer to the game exchange (%d / 2)."%mini(2,int(p.sold))
 if int(p.contract)==1:return "RIDGE CONTRACT • Track the Crownback beyond the old watchtower."
 return "CROWNBACK COMPLETE • Explore, improve your kit and hunt again."
