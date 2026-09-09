extends CanvasLayer
## On-screen controls for touchscreens.
##
## The game is built around a mouse and a keyboard, and two of its verbs cannot survive the
## translation unchanged: holding a button to steady the rifle is impossible when the same
## finger must also drag to look, and there is no hover state to reveal what is nearby. So
## touch forces the TOGGLE aim mode added for trackpads, and the buttons are always visible.
##
## Fingers are tracked by index rather than through Godot's GUI, because a virtual stick and
## a look drag are continuous gestures rather than clicks. Button rectangles are excluded by
## hit test so a press on FIRE is never also read as the start of a look drag.
const Th=preload("res://scripts/theme.gd")
const STICK_RADIUS:=88.0
const LOOK_SENSITIVITY:=.0042
var game:Node
var active=false
var move:=Vector2.ZERO
var crouch=false
var sprint=false
var root:Control
var stick_base:Panel
var stick_knob:Panel
var buttons:Array[Button]=[]
var stick_finger:=-1
var look_finger:=-1
var stick_origin:=Vector2.ZERO

func _ready() -> void:
	layer=2
	# --touch forces the overlay on a desktop so the layout can be inspected without a phone.
	active=DisplayServer.is_touchscreen_available() or "--touch" in OS.get_cmdline_user_args()
	root=Control.new();add_child(root);root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter=Control.MOUSE_FILTER_IGNORE;root.theme=Th.build()
	stick_base=circle(Vector2(150,-150),Vector2(STICK_RADIUS*2,STICK_RADIUS*2),Color(1,1,1,.10))
	stick_knob=circle(Vector2(150,-150),Vector2(74,74),Color(1,1,1,.22))
	var column=0
	for spec in [["FIRE","fire"],["AIM","aim"],["E","interact"],["F","pickup"],["R","reload"],["Q","drop"]]:
		add_button(spec[0],spec[1],column);column+=1
	add_button("CROUCH","crouch",column)
	# The stick is drawn where the thumb lands, so it must not be visible before then.
	hide_stick()
	show_controls(false)

func circle(offset:Vector2,size:Vector2,tint:Color) -> Panel:
	var n=Panel.new();root.add_child(n)
	n.anchor_left=0;n.anchor_top=1;n.anchor_right=0;n.anchor_bottom=1
	n.offset_left=offset.x-size.x*.5;n.offset_top=offset.y-size.y*.5
	n.offset_right=offset.x+size.x*.5;n.offset_bottom=offset.y+size.y*.5
	var style=StyleBoxFlat.new();style.bg_color=tint;style.set_corner_radius_all(int(size.x*.5))
	n.add_theme_stylebox_override("panel",style);n.mouse_filter=Control.MOUSE_FILTER_IGNORE
	return n

func add_button(text:String,action:String,column:int) -> void:
	var b=Button.new();root.add_child(b)
	b.text=text;b.custom_minimum_size=Vector2(96,72)
	b.anchor_left=1;b.anchor_right=1;b.anchor_top=1;b.anchor_bottom=1
	# Two rows climbing from the bottom-right, so a right thumb reaches them without
	# covering the centre of the screen where the quarry is.
	var col=column%4;var row=column/4
	b.offset_right=-18-col*104;b.offset_left=b.offset_right-96
	b.offset_bottom=-18-row*80;b.offset_top=b.offset_bottom-72
	b.pressed.connect(func():press(action))
	buttons.append(b)

func press(action:String) -> void:
	if game==null or not game.active:return
	match action:
		"aim":game.aim_latched=not game.aim_latched
		"crouch":crouch=not crouch
		_:game.send_action(action,{})

func show_controls(value:bool) -> void:
	root.visible=value and active

func over_button(position:Vector2) -> bool:
	for b in buttons:
		if b.get_global_rect().has_point(position):return true
	return false

func _input(event:InputEvent) -> void:
	# Trust the device over the capability query. Browsers disagree about what
	# is_touchscreen_available reports, and a phone that answers false would leave the
	# player with no controls at all. An actual touch is unambiguous proof.
	if not active and event is InputEventScreenTouch:
		active=true
		if game:game.aim_toggle=true
	if not active or game==null or not game.active or game.ui.panel.visible:return
	var width=get_viewport().get_visible_rect().size.x
	if event is InputEventScreenTouch:
		if event.pressed:
			if over_button(event.position):return
			# Left of centre starts a movement stick wherever the thumb lands, rather than
			# forcing it onto a fixed spot the player cannot see while looking at the deer.
			if event.position.x<width*.45 and stick_finger<0:
				stick_finger=event.index;stick_origin=event.position;show_stick(event.position)
			elif look_finger<0:
				look_finger=event.index
		else:
			if event.index==stick_finger:stick_finger=-1;move=Vector2.ZERO;hide_stick()
			if event.index==look_finger:look_finger=-1
	elif event is InputEventScreenDrag:
		if event.index==stick_finger:
			var delta=event.position-stick_origin
			move=(delta/STICK_RADIUS).limit_length(1.0)
			stick_knob.position=stick_origin+delta.limit_length(STICK_RADIUS)-stick_knob.size*.5
		elif event.index==look_finger:
			game.yaw=wrapf(game.yaw-event.relative.x*LOOK_SENSITIVITY,-PI,PI)
			game.pitch=clampf(game.pitch-event.relative.y*LOOK_SENSITIVITY,-1.3,1.3)

func show_stick(at:Vector2) -> void:
	stick_base.position=at-stick_base.size*.5;stick_knob.position=at-stick_knob.size*.5
	stick_base.visible=true;stick_knob.visible=true

func hide_stick() -> void:
	stick_base.visible=false;stick_knob.visible=false
