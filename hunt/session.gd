extends RefCounted
## Session lifecycle and persistence. RPC transport stays at the stable game scene path.
## No retained scene reference: each operation receives its owning hunt explicitly.
const C=preload("res://hunt/catalog.gd")
const Wire=preload("res://scripts/snapshot_wire.gd")
static func start_host(game:Node,networked:bool,player_name:String,slot:int) -> void:
 if game.active:return
 # Cancel any join still in flight. start_join only clears join_started on bootstrap, so a
 # player who clicks JOIN and then HOST leaves it set, and the 12s join timeout in
 # _process later tears down this healthy hosted session as "Connection timed out".
 game.join_started=-1
 game.store.slot=slot;var loaded=game.store.load_world()
 if loaded.is_empty():game.ui.main_menu(game.store.last_error);return
 if networked:
  var peer=ENetMultiplayerPeer.new()
  if game.test_mode:peer.set_bind_ip("127.0.0.1")
  var err=peer.create_server(C.PORT+1 if game.test_mode else C.PORT,3)
  if err!=OK:game.ui.main_menu("Could not host (%d). Another hunt may be open."%err);return
  game.multiplayer.multiplayer_peer=peer
 else:game.multiplayer.multiplayer_peer=OfflineMultiplayerPeer.new()
 game.active=true;game.is_host=true;game.online=networked;game.local_id=1;game.nickname=game.clean_name(player_name);game.progress=loaded
 game.add_avatar(1,game.nickname);game.forest.reset_tracks()
 if game.progress.animals.is_empty():game.seed_animals()
 else:
  for d in game.progress.animals:
   var animal=game.spawn_animal(Vector3(d.p[0],d.p[1],d.p[2]),float(d.size),bool(d.elite),int(d.id));animal.hp=float(d.hp);animal.shots=int(d.shots);animal.base_value=int(d.value)
 game.begin_view();game.note(1,"Welcome to Pinefall. Buy a rifle at the timber lodge, then follow the hoofprints.","quest");game.save_progress()
 print("HUNT_HOST_READY online=",game.online)
static func start_join(game:Node,address:String,player_name:String) -> void:
 if game.active or game.join_started>=0:return
 if address.strip_edges().is_empty() or address.length()>253:game.ui.menu_status.text="Enter the host address.";return
 var peer=ENetMultiplayerPeer.new();var err=peer.create_client(address.strip_edges(),C.PORT+1 if game.test_mode else C.PORT)
 if err!=OK:game.ui.menu_status.text="Could not start connection (%d)."%err;return
 game.multiplayer.multiplayer_peer=peer;game.online=true;game.is_host=false;game.nickname=game.clean_name(player_name);game.join_started=game.clock;game.ui.menu_status.text="Connecting to the hunt…"
static func peer_left(game:Node,id:int) -> void:
 if not game.is_host:return
 if game.avatars.has(id):game.drop(game.avatars[id]);game.avatars[id].queue_free();game.avatars.erase(id)
 game.last_commands.erase(id);game.last_inputs.erase(id);game.save_progress()
static func end_session(game:Node,reason:String="Hunt saved. Your camp will be waiting.") -> void:
 # save_progress reports failures through a note, which this teardown then destroys, so
 # the player was told "Hunt saved" precisely when it had not been.
 var stored=true
 if game.active and game.is_host:stored=game.save_progress()
 if not stored:reason="Your hunt could NOT be saved. "+game.store.last_error
 game.active=false;game.is_host=false;game.online=false;game.join_started=-1;game.trail_history_received=false;game.forest.reset_tracks();game.multiplayer.multiplayer_peer=OfflineMultiplayerPeer.new()
 for a in game.avatars.values():a.queue_free()
 for a in game.animals.values():a.queue_free()
 game.avatars.clear();game.animals.clear();game.last_inputs.clear();game.last_commands.clear();game.wire=Wire.new();game.last_revision=-1;game.revision=0;game.gun.hide();game.ui.main_menu(reason)
 game.camera.position=Vector3(13,8,35);game.camera.look_at(Vector3(0,1,12))
static func save_progress(game:Node) -> bool:
 if not game.is_host or not game.active:return false
 var p=game.progress.duplicate(true);p.animals=[]
 for animal in game.animals.values():p.animals.append(animal.saved())
 if not game.store.save_world(p):game.note(game.local_id,game.store.last_error,"error");return false
 return true
