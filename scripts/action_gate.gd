extends RefCounted
## Per-avatar admission for ordered reliable commands. Execute small bursts now;
## never queue stale actions for later. Weapon and transaction rules stay separate.
enum Admission { ACCEPT, INVALID, LIMITED }
const CAPACITY:=4.0
const REFILL_PER_SECOND:=20.0
var tokens:=CAPACITY
var last_refill:=-1.0
var next_notice:=-1.0

func admit(now:float,action:String,data:Dictionary) -> int:
	if not is_finite(now): return Admission.INVALID
	if last_refill<0.0: last_refill=now
	var elapsed=maxf(0.0,now-last_refill)
	tokens=minf(CAPACITY,tokens+elapsed*REFILL_PER_SECOND)
	last_refill=maxf(last_refill,now)
	if tokens+0.000001<1.0: return Admission.LIMITED
	tokens=maxf(0.0,tokens-1.0)
	return Admission.ACCEPT if valid_payload(action,data) else Admission.INVALID

func notice_due(now:float) -> bool:
	if not is_finite(now) or now<next_notice: return false
	next_notice=now+1.0
	return true

static func valid_payload(action:String,data:Dictionary) -> bool:
	if data.size()>1: return false
	match action:
		"tool":
			var value=data.get("tool",1)
			return only_key(data,"tool") and number_in(value,1.0,5.0) and float(value)==floorf(float(value))
		"cast": return only_key(data,"charge") and number_in(data.get("charge",0.4),0.0,1.0)
		"drop": return only_key(data,"power") and number_in(data.get("power",0.0),0.0,10.0)
		"buy": return only_key(data,"upgrade") and identifier(data.get("upgrade",""),48)
		"lure": return only_key(data,"id") and identifier(data.get("id","T00"),16)
		"lure_cycle": return data.size()==1 and data.has("direction") and typeof(data.direction)==TYPE_INT and data.direction in [-1,1]
		"boat_destination": return data.is_empty()
		"hook","cancel","hit","tow","interact","pickup","fire","reload","ammo": return data.is_empty()
	return false

static func only_key(data:Dictionary,key:String) -> bool:
	return data.is_empty() or data.has(key)

static func identifier(value:Variant,limit:int) -> bool:
	return value is String and value.length()>0 and value.length()<=limit

static func number_in(value:Variant,low:float,high:float) -> bool:
	if typeof(value)!=TYPE_INT and typeof(value)!=TYPE_FLOAT: return false
	var number=float(value)
	return is_finite(number) and number>=low and number<=high
