extends RefCounted
## Party transactions. No scene, network, sound or storage access.
## The host command boundary admits requests; outcomes tell the scene which effects to perform.
const C=preload("res://hunt/catalog.gd")
static func denied(message:String="",tone:String="error") -> Dictionary:
 return {"ok":false,"message":message,"tone":tone}
static func purchase(progress:Dictionary,id:String,near_shop:bool) -> Dictionary:
 if not near_shop or not C.ITEMS.has(id):return denied()
 if id in progress.upgrades:return denied("Already owned by the hunting party.")
 if id!="rifle" and "rifle" not in progress.upgrades:return denied("Start with the trail rifle.")
 var cost=int(C.ITEMS[id].cost)
 if progress.wallet<cost:return denied("Not enough credits. Bank a harvest at the exchange.")
 if id=="ammo" and int(progress.ammo)>9987:return denied()
 progress.wallet-=cost
 if id=="ammo":progress.ammo+=12
 else:progress.upgrades.append(id)
 if id=="rifle":progress.ammo+=12
 return {"ok":true,"message":C.ITEMS[id].name+" added to the party's kit.","tone":"sell","refill":id=="rifle"}
static func bank(progress:Dictionary,amount:int,crown:bool) -> Dictionary:
 # Identity, possession and exchange proximity must be consumed by the host before calling.
 progress.wallet+=amount;progress.banked+=amount;progress.sold+=1
 var notes=[{"message":"BANKED +%d credits • %d total"%[amount,int(progress.wallet)],"tone":"sell"}]
 var spawn_crown=false
 if progress.contract==0 and progress.sold>=2:
  progress.contract=1;progress.wallet+=50;spawn_crown=true
  notes.append({"message":"Contract complete: +50 credits. Crownback spotted beyond the watchtower!","tone":"quest"})
 if crown and progress.contract==1:
  progress.contract=2;progress.wallet+=125
  notes.append({"message":"CROWNBACK CONTRACT COMPLETE • +125 credits. Pinefall is yours to explore.","tone":"win"})
 return {"notes":notes,"spawn_crown":spawn_crown}
static func recover_ammo(progress:Dictionary) -> bool:
 if "rifle" not in progress.upgrades or progress.ammo!=0 or progress.wallet>=8:return false
 progress.ammo=4
 return true
