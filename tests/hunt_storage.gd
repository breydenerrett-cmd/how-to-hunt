extends SceneTree
const C=preload("res://hunt/catalog.gd")
const Store=preload("res://scripts/save_store.gd")
var passes=0
var failures=0
func check(ok:bool,label:String) -> void:
 if ok:passes+=1;print("TEST_PASS ",label)
 else:failures+=1;push_error("TEST_FAIL "+label)
func _initialize() -> void:
 var s=Store.new();s.slot=995000+OS.get_process_id();var p=C.new_progress()
 check(s.path().begins_with("user://world_"),"storage uses hunting project user namespace")
 check(s.save_world(p),"new hunting world writes")
 p.wallet=15;p.upgrades=["rifle"];p.ammo=12;check(s.save_world(p),"equipment snapshot writes")
 check(s.load_world()==JSON.parse_string(JSON.stringify(p)),"equipment and ammo persist exactly")
 check(s.save_world(p),"unchanged snapshot validates recovery copies")
 check(FileAccess.file_exists(s.path()+".bak2"),"second backup established")
 var old=p.duplicate(true);p.wallet=71;p.sold=2;p.contract=1
 check(s.save_world(p),"contract progress writes")
 var f=FileAccess.open(s.path(),FileAccess.WRITE);f.store_string("broken");f.close()
 var recovered=s.load_world();check(s.recovered and recovered==JSON.parse_string(JSON.stringify(old)),"corrupt primary recovers distinct previous equipment snapshot")
 check(s.save_world(recovered) and s.load_world()==JSON.parse_string(JSON.stringify(old)),"recovered state repairs primary")
 var bad=old.duplicate(true);bad.ammo=-1;check(not s.save_world(bad) and s.load_world()==JSON.parse_string(JSON.stringify(old)),"invalid save cannot overwrite valid world")
 # A corrupt primary must never be carried into the recovery copies. _write_snapshot
 # previously copied the primary into .bak unconditionally, so within two saves of any
 # corruption every recovery generation held the same damage.
 var good=old.duplicate(true);good.wallet=88
 check(s.save_world(good),"known good state stored before corruption")
 var handle=FileAccess.open(s.path(),FileAccess.WRITE);handle.store_string("{not json");handle.close()
 var next=good.duplicate(true);next.wallet=93
 check(s.save_world(next),"a save still succeeds when the primary on disk is corrupt")
 var backup=FileAccess.open(s.path()+".bak",FileAccess.READ)
 var backup_text=backup.get_as_text();backup.close()
 check(JSON.parse_string(backup_text)!=null,"corrupt primary is not copied over the recovery copy")
 check(s.load_world().wallet==93,"repaired primary loads the newest state")
 # Schema reach. The old ceilings described the first prototype exactly, so any new
 # species, region or contract could not be saved. Widening must admit that content
 # without rejecting worlds written before the fields existed.
 var legacy={"schema":1,"game":"how_to_hunt","wallet":40,"upgrades":[],"ammo":0,"sold":0,"banked":0,"contract":0,"sequence":0,"animals":[]}
 check(C.valid_progress(legacy),"a world written before the new fields still loads")
 var modern=legacy.duplicate(true);modern.stage=3;modern.region=2;modern.contract=9
 modern.animals=[{"id":1,"p":[0,0,0],"size":2.4,"hp":400,"shots":0,"value":1800,"elite":true,"kind":"elk"}]
 check(C.valid_progress(modern),"a tagged species beyond the old size, hp and value ceilings saves")
 var bad_stage=modern.duplicate(true);bad_stage.stage=-1
 check(not C.valid_progress(bad_stage),"a negative narrative stage is still rejected")
 var bad_kind=modern.duplicate(true);bad_kind.animals=[{"id":1,"p":[0,0,0],"size":1.0,"hp":70,"shots":0,"value":35,"elite":false,"kind":""}]
 check(not C.valid_progress(bad_kind),"an empty species tag is still rejected")
 var absurd=modern.duplicate(true);absurd.animals=[{"id":1,"p":[0,0,0],"size":9.0,"hp":70,"shots":0,"value":35,"elite":false}]
 check(not C.valid_progress(absurd),"an impossible animal size is still rejected")
 for suffix in ["",".bak",".bak2",".tmp"]:DirAccess.remove_absolute(ProjectSettings.globalize_path(s.path()+suffix))
 print("TEST_SUMMARY hunt_storage passes=",passes," failures=",failures);quit(1 if failures else 0)
