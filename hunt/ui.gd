extends CanvasLayer
const C=preload("res://hunt/catalog.gd")
var game:Node
var hud_nodes:Array=[]
var root:Control
var menu:PanelContainer
var panel:PanelContainer
var menu_status:Label
var header:Label
var objective:Label
var status:Label
var noise_label:Label
var noise_bar:ProgressBar
var prompt:Label
var message:Label
var ammo:Label
var aim:Label
var address:LineEdit
var player_name:LineEdit
var slot:OptionButton
var notice_time=0.0
var focused_item=""
var panel_kind=""
var shop_revision=""
func label(parent:Node,value:String,size:int=20,color:Color=Color("eadfca")) -> Label:
 var n=Label.new();parent.add_child(n);n.text=value;n.add_theme_font_size_override("font_size",size);n.add_theme_color_override("font_color",color);n.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;n.add_theme_color_override("font_outline_color",Color(.03,.05,.03,.95));n.add_theme_constant_override("outline_size",3);return n
func box(parent:Node,offsets:Vector4,anchor:Vector4=Vector4.ZERO) -> PanelContainer:
 var n=PanelContainer.new();parent.add_child(n);n.anchor_left=anchor.x;n.anchor_top=anchor.y;n.anchor_right=anchor.z;n.anchor_bottom=anchor.w;n.offset_left=offsets.x;n.offset_top=offsets.y;n.offset_right=offsets.z;n.offset_bottom=offsets.w
 var style=StyleBoxFlat.new();style.bg_color=Color(.08,.12,.10,.92);style.border_color=Color("857950");style.set_border_width_all(1);style.set_corner_radius_all(8);style.content_margin_left=18;style.content_margin_right=18;style.content_margin_top=14;style.content_margin_bottom=14;n.add_theme_stylebox_override("panel",style);return n
func button(parent:Node,value:String,callback:Callable) -> Button:
 var n=Button.new();parent.add_child(n);n.text=value;n.custom_minimum_size.y=44;n.add_theme_font_size_override("font_size",19)
 var style=StyleBoxFlat.new();style.bg_color=Color("455f4e");style.set_corner_radius_all(5);n.add_theme_stylebox_override("normal",style);var hover=style.duplicate();hover.bg_color=Color("698065");n.add_theme_stylebox_override("hover",hover);n.pressed.connect(callback);return n
func _ready() -> void:
 root=Control.new();add_child(root);root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);root.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var left=box(root,Vector4(22,20,590,110));var rows=VBoxContainer.new();left.add_child(rows);header=label(rows,"",17,Color("c2bb92"));objective=label(rows,"",20)
 var right=box(root,Vector4(-250,20,-22,98),Vector4(1,0,1,0));var status_rows=VBoxContainer.new();right.add_child(status_rows);status=label(status_rows,"",17);noise_label=label(status_rows,"",14);noise_bar=ProgressBar.new();status_rows.add_child(noise_bar);noise_bar.custom_minimum_size.y=8;noise_bar.show_percentage=false
 var lower=box(root,Vector4(22,-125,405,-22),Vector4(0,1,0,1));ammo=label(lower,"",17)
 var center=Control.new();root.add_child(center);center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);center.mouse_filter=Control.MOUSE_FILTER_IGNORE
 aim=label(center,"·",27);aim.set_anchors_and_offsets_preset(Control.PRESET_CENTER);aim.position-=Vector2(5,18);aim.size=Vector2(190,70)
 prompt=label(center,"",18);prompt.anchor_left=.5;prompt.anchor_right=.5;prompt.anchor_top=1;prompt.anchor_bottom=1;prompt.offset_left=-290;prompt.offset_right=290;prompt.offset_top=-100;prompt.offset_bottom=-50;prompt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 message=label(center,"",20,Color("f0d491"));message.anchor_left=.5;message.anchor_right=.5;message.anchor_top=.2;message.anchor_bottom=.2;message.offset_left=-310;message.offset_right=310;message.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 hud_nodes=[left,right,lower,center]
 menu=box(root,Vector4(35,38,495,-38),Vector4(0,0,0,1));var scroll=ScrollContainer.new();menu.add_child(scroll);var v=VBoxContainer.new();v.size_flags_horizontal=Control.SIZE_EXPAND_FILL;v.add_theme_constant_override("separation",12);scroll.add_child(v)
 label(v,"PINEFALL • 1–4 PLAYER HUNT",17,Color("bfbd8d"));label(v,"HOW TO HUNT",43);label(v,"Follow the signs.\nBring home a story.",23)
 label(v,"A woodland arcade prototype • "+C.VERSION,15)
 player_name=LineEdit.new();v.add_child(player_name);player_name.text="Ranger";player_name.placeholder_text="Your name";player_name.custom_minimum_size.y=40
 slot=OptionButton.new();v.add_child(slot)
 for n in range(3):slot.add_item("Hunting world %d"%(n+1),n+1)
 button(v,"PLAY SOLO",func():game.start_host(false,player_name.text,slot.selected+1))
 button(v,"HOST A HUNT",func():game.start_host(true,player_name.text,slot.selected+1))
 address=LineEdit.new();v.add_child(address);address.placeholder_text="Host address";address.text="127.0.0.1";address.custom_minimum_size.y=40
 button(v,"JOIN HUNT",func():game.start_join(address.text,player_name.text))
 menu_status=label(v,"Shared kit and credits. The host saves your world.",16)
 panel=box(root,Vector4(-285,-250,285,250),Vector4(.5,.5,.5,.5));panel.hide()
func in_game() -> void:
 menu.hide();panel.hide();Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
func main_menu(text:String="") -> void:
 menu.show();panel.hide();menu_status.text=text;Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
func notify(text:String) -> void:message.text=text;notice_time=4.0
func show_panel(kind:String,id:String="") -> void:
 for c in panel.get_children():panel.remove_child(c);c.queue_free()
 panel.show();focused_item=id;panel_kind=kind;shop_revision=str(game.progress.wallet)+str(game.progress.upgrades);Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
 var scroll=ScrollContainer.new();panel.add_child(scroll);var v=VBoxContainer.new();scroll.add_child(v);v.size_flags_horizontal=Control.SIZE_EXPAND_FILL;v.add_theme_constant_override("separation",10)
 if kind=="shop":
  label(v,"PINE & POWDER",29);label(v,"Shared wallet • %d credits"%int(game.progress.wallet),18)
  for item in C.ITEMS:
   if id!="" and item!=id:continue
   label(v,C.ITEMS[item].name,23);label(v,C.ITEMS[item].detail,17)
   var owned=item in game.progress.upgrades
   var b=button(v,"OWNED" if owned else "BUY • %d credits"%C.ITEMS[item].cost,func():game.send_action("buy",{"upgrade":item}));b.disabled=owned
  button(v,"ALL EQUIPMENT",func():show_panel("shop"))
 else:
  label(v,"FIELD JOURNAL",29);label(v,C.objective(game.progress),20)
  label(v,"WASD move • Shift run • Space jump\nHold Ctrl or C: crouch / stalk\nRight mouse: slow, steady aim\nLeft mouse: fire • R reload\nE inspect tracks / shop / sell\nF retrieve • Q put down\nTab journal • Esc pause",18)
  label(v,"Gold hoofprints guide the hunt. Hold Ctrl or C to stalk quietly. The NOISE meter reflects movement and trail or leaf litter underfoot. Quiet is not invisible: line of sight and upwind scent still reveal you. Moving fast and approaching upwind raises suspicion. One clean steady shot earns 25% more; follow the trail if your quarry runs. Bank two deer to unlock the Crownback contract. Dodge its orange rush lane, then fire during recovery for full damage.",18)
  button(v,"REDUCED MOTION: "+("ON" if game.motion==0 else "OFF"),func():game.motion=0.0 if game.motion>0 else .65;game.save_settings();show_panel("journal"))
  button(v,"TEXT SIZE: "+("LARGE" if game.ui_scale>1 else "NORMAL"),func():game.ui_scale=1.0 if game.ui_scale>1 else 1.2;game.save_settings();show_panel("journal"))
  button(v,"SAVE & RETURN TO MENU",func():game.end_session())
 button(v,"BACK TO HUNT",func():panel.hide();Input.mouse_mode=Input.MOUSE_MODE_CAPTURED)
func update(dt:float) -> void:
 for node in hud_nodes:node.visible=game.active
 notice_time=maxf(0,notice_time-dt);message.visible=notice_time>0
 if panel.visible and panel_kind=="shop" and shop_revision!=str(game.progress.wallet)+str(game.progress.upgrades):show_panel("shop",focused_item)
 noise_label.add_theme_font_size_override("font_size",int(14*game.ui_scale))
 for n in [header,objective,status,prompt,ammo]:n.add_theme_font_size_override("font_size",int((20 if n==objective else 17)*game.ui_scale))
 header.text="PINEFALL • %d HUNTERS • %d CREDITS"%[game.avatars.size(),int(game.progress.wallet)]
 objective.text=C.objective(game.progress)
 var a=game.avatars.get(game.local_id)
 status.text="HEALTH %d\nWIND ↘ SE"%int(a.health if a else 100)
 prompt.text=game.context_prompt() if game.active else ""
 aim.visible=game.active and not panel.visible
 if a:
  noise_label.text=("CROUCHED" if a.crouched else "STANDING")+" • NOISE %d%%\n%s"%[int(a.noise*100),a.surface_name]
  noise_bar.value=a.noise*100
  noise_bar.modulate=Color("8ebc8c") if a.noise<.3 else (Color("e1c271") if a.noise<.65 else Color("e98d65"))
  var steady=float(a.fishing.get("steady",0))
  aim.text="+" if not a.input_reel else ("•" if steady>.85 else "◌")
  aim.add_theme_color_override("font_color",Color("e9ce88") if steady>.85 else Color("eee8d9"))
  ammo.text=("TRAIL RIFLE • %d / %d rounds"%[int(a.magazines.get("rifle",0)),int(game.progress.ammo)] if "rifle" in game.progress.upgrades else "EMPTY HANDS • visit the lodge")+"\n"+("Reloading…" if a.reload_until>game.clock else "[R] reload • [TAB] field journal")
  if a.held>=0:prompt.text="[E] sell at exchange • [Q] put down your harvest"
