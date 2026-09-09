extends CanvasLayer
const Th=preload("res://scripts/theme.gd")
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
var applied_scale=-1.0
func label(parent:Node,value:String,size:int=20,color:Color=Color("eadfca"),floating:bool=false) -> Label:
 var n=Label.new();parent.add_child(n);n.text=value;n.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 if size>0:n.add_theme_font_size_override("font_size",size)
 if color!=Color("eadfca"):n.add_theme_color_override("font_color",color)
 # Only text drawn straight onto the 3D world needs an outline. On a panel it reads as cheap.
 if floating:n.add_theme_color_override("font_outline_color",Color(.03,.05,.03,.95));n.add_theme_constant_override("outline_size",4)
 return n
func box(parent:Node,offsets:Vector4,anchor:Vector4=Vector4.ZERO) -> PanelContainer:
 var n=PanelContainer.new();parent.add_child(n);n.anchor_left=anchor.x;n.anchor_top=anchor.y;n.anchor_right=anchor.z;n.anchor_bottom=anchor.w;n.offset_left=offsets.x;n.offset_top=offsets.y;n.offset_right=offsets.z;n.offset_bottom=offsets.w
 return n
func button(parent:Node,value:String,callback:Callable) -> Button:
 var n=Button.new();parent.add_child(n);n.text=value;n.custom_minimum_size.y=44
 n.pressed.connect(callback);return n
func _ready() -> void:
 root=Control.new();add_child(root);root.theme=Th.build();root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);root.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var left=box(root,Vector4(22,20,590,110));var rows=VBoxContainer.new();left.add_child(rows);header=label(rows,"",17,Color("c2bb92"));objective=label(rows,"",20)
 var right=box(root,Vector4(-250,20,-22,98),Vector4(1,0,1,0));var status_rows=VBoxContainer.new();right.add_child(status_rows);status=label(status_rows,"",17);noise_label=label(status_rows,"",14);noise_bar=ProgressBar.new();status_rows.add_child(noise_bar);noise_bar.custom_minimum_size.y=8;noise_bar.show_percentage=false
 var lower=box(root,Vector4(22,-125,405,-22),Vector4(0,1,0,1));ammo=label(lower,"",17)
 var center=Control.new();root.add_child(center);center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);center.mouse_filter=Control.MOUSE_FILTER_IGNORE
 # The reticle marks where the shot goes, so it must sit on the camera axis exactly. It
 # used to be a 190x70 box with default top-left text alignment nudged by a hand-tuned
 # offset, which only lined up for one glyph: swapping between +, • and ◌ moved the mark
 # while the player was trying to hold steady. Centring the text in a full-rect label puts
 # the glyph on screen centre whatever its metrics.
 aim=label(center,"·",27,Color("eadfca"),true);aim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 aim.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;aim.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;aim.mouse_filter=Control.MOUSE_FILTER_IGNORE
 prompt=label(center,"",18,Color("eadfca"),true);prompt.anchor_left=.5;prompt.anchor_right=.5;prompt.anchor_top=1;prompt.anchor_bottom=1;prompt.offset_left=-290;prompt.offset_right=290;prompt.offset_top=-100;prompt.offset_bottom=-50;prompt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 message=label(center,"",20,Color("f0d491"),true);message.anchor_left=.5;message.anchor_right=.5;message.anchor_top=.2;message.anchor_bottom=.2;message.offset_left=-310;message.offset_right=310;message.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 hud_nodes=[left,right,lower,center]
 menu=box(root,Vector4(35,38,495,-38),Vector4(0,0,0,1));var scroll=ScrollContainer.new();menu.add_child(scroll);var v=VBoxContainer.new();v.size_flags_horizontal=Control.SIZE_EXPAND_FILL;v.add_theme_constant_override("separation",12);scroll.add_child(v)
 label(v,"PINEFALL • 1–4 PLAYER HUNT",17,Color("bfbd8d"));var title=label(v,"HOW TO HUNT",0);title.theme_type_variation="Display";label(v,"Follow the signs.\nBring home a story.",23)
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
  var kit=[]
  for gear_id in ["boots","overshirt","scent","muffler"]:
   if gear_id in game.progress.upgrades:kit.append(C.ITEMS[gear_id].name)
  label(v,"STALKING KIT • "+(", ".join(kit) if not kit.is_empty() else "Available on the lodge side shelves"),16)
  label(v,"WASD move • Shift run • Space jump\nHold Ctrl or C: crouch / stalk\n%s: slow, steady aim\nLeft mouse: fire • R reload\nE inspect tracks / shop / sell\nF retrieve • Q put down\nTab journal • Esc pause\nController: sticks move and look, triggers aim and fire"%("Press right mouse to hold aim" if game.aim_toggle else "Hold right mouse"),18)
  label(v,"Gold hoofprints guide the hunt. Hold Ctrl or C to stalk quietly. The NOISE meter reflects movement and trail or leaf litter underfoot. Quiet is not invisible: line of sight and upwind scent still reveal you. Moving fast and approaching upwind raises suspicion. One clean steady shot earns 25% more; follow the trail if your quarry runs. Bank two deer to unlock the Crownback contract. Dodge its orange rush lane, then fire during recovery for full damage.",18)
  button(v,"REDUCED MOTION: "+("ON" if game.motion==0 else "OFF"),func():game.motion=0.0 if game.motion>0 else .65;game.save_settings();show_panel("journal"))
  button(v,"AIM: "+("TOGGLE • best on a trackpad" if game.aim_toggle else "HOLD • best with a mouse"),func():game.aim_toggle=not game.aim_toggle;game.aim_latched=false;game.save_settings();show_panel("journal"))
  button(v,"TEXT SIZE: "+("LARGE" if game.ui_scale>1 else "NORMAL"),func():game.ui_scale=1.0 if game.ui_scale>1 else 1.2;game.save_settings();show_panel("journal"))
  button(v,"SAVE & RETURN TO MENU",func():game.end_session())
 button(v,"BACK TO HUNT",func():panel.hide();Input.mouse_mode=Input.MOUSE_MODE_CAPTURED)
func update(dt:float) -> void:
 for node in hud_nodes:node.visible=game.active and not panel.visible
 notice_time=maxf(0,notice_time-dt);message.visible=notice_time>0
 if panel.visible and panel_kind=="shop" and shop_revision!=str(game.progress.wallet)+str(game.progress.upgrades):show_panel("shop",focused_item)
 # Scaling the viewport scales spacing and panels too, not only glyphs, and costs
 # nothing per frame. Base sizes stay as authored at construction.
 if applied_scale!=game.ui_scale:applied_scale=game.ui_scale;get_window().content_scale_factor=applied_scale
 # Reserve real panel extents after font/layout scaling; floating guidance gets
 # its own band above the equipment panel and below the two top panels.
 message.anchor_top=0;message.anchor_bottom=0
 message.offset_top=maxf(hud_nodes[0].get_rect().end.y,hud_nodes[1].get_rect().end.y)+12
 message.offset_bottom=message.offset_top+80
 prompt.anchor_top=0;prompt.anchor_bottom=0
 prompt.offset_bottom=hud_nodes[2].get_rect().position.y-12
 prompt.offset_top=prompt.offset_bottom-64
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
