extends RefCounted
## Single source of interface styling.
##
## Fonts come from SystemFont rather than a bundled file: no asset to ship or license,
## and allow_system_fallback means a machine missing every listed family degrades to a
## readable default instead of rendering nothing. The families are ordered so macOS and
## Windows each find something with actual character before hitting the generic tail.
##
## MSDF is enabled only on the world font. Label3D is magnified to arbitrary sizes, which
## is exactly what MSDF is for; flat 2D text sits at fixed pixel sizes where ordinary
## rasterisation is crisper.

# Warm old-style serif for titles and signage. Reads rustic rather than generic.
const DISPLAY_FAMILIES:=["Iowan Old Style","Palatino Linotype","Palatino","Georgia","Constantia","Times New Roman"]
# Humanist sans for anything read at a glance mid-hunt.
const BODY_FAMILIES:=["Avenir Next","Optima","Segoe UI","Gill Sans","Helvetica Neue","Arial"]

const INK:=Color("eadfca")
const INK_DIM:=Color("c2bb92")
const ACCENT:=Color("e9ce88")
const PANEL_BG:=Color(.055,.088,.075,.93)
const PANEL_EDGE:=Color(.52,.47,.31,.55)

static var _theme:Theme
static var _world:Font

static func _family(names:Array, msdf:bool) -> SystemFont:
	var f=SystemFont.new()
	f.font_names=PackedStringArray(names)
	f.allow_system_fallback=true
	f.multichannel_signed_distance_field=msdf
	f.generate_mipmaps=msdf
	return f

static func world_font() -> Font:
	if _world==null: _world=_family(DISPLAY_FAMILIES,true)
	return _world

static func _panel(bg:Color, radius:int, pad:Vector2) -> StyleBoxFlat:
	var s=StyleBoxFlat.new()
	s.bg_color=bg
	s.set_corner_radius_all(radius)
	s.content_margin_left=pad.x; s.content_margin_right=pad.x
	s.content_margin_top=pad.y; s.content_margin_bottom=pad.y
	return s

static func build() -> Theme:
	if _theme!=null: return _theme
	var body=_family(BODY_FAMILIES,false)
	var display=FontVariation.new()
	display.base_font=_family(DISPLAY_FAMILIES,false)
	display.variation_embolden=0.06
	display.spacing_glyph=2

	var t=Theme.new()
	t.default_font=body
	t.default_font_size=17

	t.set_font("font","Label",body)
	t.set_color("font_color","Label",INK)

	# Title treatment. Applied per node via theme_type_variation so ordinary labels are
	# untouched: letterspaced serif is right for a sign and wrong for a HUD readout.
	t.set_type_variation("Display","Label")
	t.set_font("font","Display",display)
	t.set_font_size("font_size","Display",44)
	t.set_color("font_color","Display",INK)

	var panel=_panel(PANEL_BG,9,Vector2(18,14))
	panel.set_border_width_all(1)
	panel.border_color=PANEL_EDGE
	# Depth against a bright, busy 3D scene; without it panels read as flat stickers.
	panel.shadow_size=7
	panel.shadow_color=Color(0,0,0,.28)
	t.set_stylebox("panel","PanelContainer",panel)

	var normal=_panel(Color("3d5545"),6,Vector2(16,10))
	normal.set_border_width_all(1)
	normal.border_color=Color(.62,.58,.38,.35)
	var hover=normal.duplicate(); hover.bg_color=Color("53704f"); hover.border_color=ACCENT
	var pressed=normal.duplicate(); pressed.bg_color=Color("2c3f33")
	var focus=normal.duplicate(); focus.bg_color=Color("46614e"); focus.border_color=ACCENT
	for state in ["normal","hover","pressed","focus","disabled"]:
		t.set_stylebox(state,"Button",normal if state in ["normal","disabled"] else (hover if state=="hover" else (pressed if state=="pressed" else focus)))
	t.set_font("font","Button",body)
	t.set_font_size("font_size","Button",19)
	t.set_color("font_color","Button",INK)
	t.set_color("font_hover_color","Button",Color("fbf3dd"))
	t.set_color("font_pressed_color","Button",ACCENT)

	var field=_panel(Color(.04,.06,.05,.85),6,Vector2(12,8))
	field.set_border_width_all(1)
	field.border_color=Color(.45,.42,.28,.45)
	for type in ["LineEdit","OptionButton"]:
		t.set_stylebox("normal",type,field)
		t.set_font("font",type,body)
		t.set_font_size("font_size",type,17)
		t.set_color("font_color",type,INK)
	t.set_stylebox("focus","LineEdit",field.duplicate())
	t.set_color("font_placeholder_color","LineEdit",Color(.78,.75,.62,.45))
	t.set_stylebox("hover","OptionButton",field.duplicate())
	t.set_stylebox("pressed","OptionButton",field.duplicate())
	t.set_stylebox("focus","OptionButton",field.duplicate())

	# The noise meter is read in motion, so it needs a defined trough, not a bare bar.
	t.set_stylebox("background","ProgressBar",_panel(Color(.03,.05,.04,.75),4,Vector2.ZERO))
	t.set_stylebox("fill","ProgressBar",_panel(Color("cfd8bb"),4,Vector2.ZERO))

	_theme=t
	return _theme
