extends SceneTree
func _initialize() -> void:run.call_deferred()
func run() -> void:
 var a=load("res://scripts/avatar.gd").new();root.add_child(a);a.crouched=true;a.noise=.2
 var before=a.packet();var transform=a.transform;var hit=a.capsule.transform
 for i in range(90):a.update_visual(1.0/60)
 var feet=[]
 for k in a.knees:feet.append(a.to_local(k.to_global(Vector3(0,-.395,-.08))))
 var ok=a.packet()==before and a.transform==transform and a.capsule.transform==hit and a.knees.size()==2
 var above=true
 for p in feet:above=above and p.is_finite() and p.y>-.08 and p.y<.2
 print("TEST_PASS" if ok else "TEST_FAIL"," articulated crouch preserves authoritative state")
 print("TEST_PASS" if above else "TEST_FAIL"," crouched boot soles remain near ground ",feet)
 a.queue_free();await process_frame;print("TEST_SUMMARY hunt_stance_pose passes=",int(ok)+int(above)," failures=",2-int(ok)-int(above));quit(0 if ok and above else 1)
