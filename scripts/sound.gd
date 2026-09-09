extends Node
var volume := 0.55:
	set(value):
		volume=clampf(value,0,1)
		if ambience: ambience.volume_db=linear_to_db(maxf(volume,0.0001))-25.0
var ambience:AudioStreamPlayer
var cache:Dictionary={}

func stop_all() -> void:
	for voice in get_children():
		if voice is AudioStreamPlayer:
			voice.stop()
			voice.stream=null
	cache.clear()

func _ready() -> void:
	if DisplayServer.get_name()=="headless": return
	var stream=AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=22050
	var count=22050*8
	var bytes=PackedByteArray()
	bytes.resize(count*2)
	var rng=RandomNumberGenerator.new()
	rng.seed=919
	var smooth:=0.0
	for i in range(count):
		var t=float(i)/22050.0
		smooth=lerpf(smooth,rng.randf_range(-1,1),0.10)
		var wave=0.36+0.28*sin(TAU*t/8.0)+0.08*sin(TAU*t/4.0)
		var edge=minf(1,minf(float(i)/1000.0,float(count-i)/1000.0))
		bytes.encode_s16(i*2,int(smooth*wave*edge*22000))
	stream.data=bytes
	stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
	stream.loop_end=count
	ambience=AudioStreamPlayer.new()
	ambience.stream=stream
	ambience.volume_db=linear_to_db(maxf(volume,0.0001))-25.0
	add_child(ambience)
	ambience.play()

func tone(kind:String) -> void:
	if DisplayServer.get_name()=="headless": return
	# Bound overlapping voices during four-player event bursts.
	if get_child_count()>12: return
	var player=AudioStreamPlayer.new()
	if not cache.has(kind): cache[kind]=make_tone(kind)
	player.stream=cache[kind]
	player.volume_db=linear_to_db(maxf(volume,0.0001))-(12.0 if kind=="step" else 0.0)
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func make_tone(kind:String) -> AudioStreamWAV:
	var pitches={"cast":330.0,"bite":880.0,"catch":660.0,"sell":1046.5,"press":220.0,"hit":120.0,"quest":784.0,"error":150.0,"win":1174.7,"click":440.0,"step":85.0}
	var hz=float(pitches.get(kind,440.0))
	var duration=0.24 if kind not in ["quest","win","catch"] else 0.7
	if kind=="step": duration=0.09
	if kind=="shot": duration=0.16; hz=72.0
	var stream=AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=22050
	var count=int(duration*22050)
	var bytes=PackedByteArray()
	bytes.resize(count*2)
	var rng=RandomNumberGenerator.new()
	rng.seed=kind.hash()
	for i in range(count):
		var t=float(i)/22050
		var env=sin(PI*float(i)/count)*exp(-t*4)
		var frequency=hz
		if kind in ["catch","sell","quest","win"]:
			frequency*=pow(2.0,float(mini(2,int(t*8.0)))*4.0/12.0)
		var sample=sin(TAU*frequency*t)*env*0.17+sin(TAU*frequency*2*t)*env*0.025
		if kind in ["step","hit","press"]: sample=(sin(TAU*hz*t)*0.6+rng.randf_range(-1,1)*0.4)*env*0.24*exp(-t*12)
		if kind=="shot": sample=(rng.randf_range(-1,1)*0.65+sin(TAU*hz*t)*0.35)*exp(-t*34.0)*0.35
		if kind=="cast": sample=(rng.randf_range(-1,1)*0.12+sin(TAU*(hz-t*300)*t)*0.06)*env
		bytes.encode_s16(i*2,int(sample*32767))
	stream.data=bytes
	return stream
