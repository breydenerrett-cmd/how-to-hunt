extends RefCounted
const Catalog=preload("res://hunt/catalog.gd")
var last_error := ""
var recovered := false
var slot := 1
var disabled := false
var _validated_backups:Dictionary={}

func path() -> String:
	return "user://world_%d.json" % slot

func validate(p:Variant) -> bool:
	return Catalog.valid_progress(p)

func load_world() -> Dictionary:
	last_error = ""
	recovered = false
	if disabled: return Catalog.new_progress()
	for suffix in ["", ".bak", ".bak2"]:
		var f = FileAccess.open(path()+suffix, FileAccess.READ)
		if not f: continue
		var parser=JSON.new()
		if parser.parse(f.get_as_text())!=OK: continue
		var p = parser.data
		if validate(p):
			recovered = suffix != ""
			return p
	if FileAccess.file_exists(path()):
		last_error = "Save is unreadable. Choose a different slot; the original is preserved."
		return {}
	return Catalog.new_progress()

func save_world(p:Dictionary) -> bool:
	if disabled: return true
	last_error = ""
	if not validate(p):
		last_error = "Save validation failed. Existing save preserved."
		return false
	# Compare the current primary, not a cache: missing, corrupt or externally
	# replaced files must still be repaired. Changed transactions remain synchronous.
	var contents=JSON.stringify(p)
	var bytes=contents.to_utf8_buffer()
	var existing=FileAccess.open(path(),FileAccess.READ)
	if existing:
		var same=false
		if existing.get_length()==bytes.size():
			var actual=existing.get_buffer(bytes.size())
			same=existing.get_error()==OK and actual==bytes
		existing.close()
		if same: return _ensure_backups()
	return _write_snapshot(contents)

func _ensure_backups() -> bool:
	# Keep distinct valid generations; heal only missing/unreadable recovery copies.
	# A no-op save still establishes both backups when the world is brand new.
	for suffix in [".bak",".bak2"]:
		var file=FileAccess.open(path()+suffix,FileAccess.READ)
		var valid=false
		if file:
			var contents=file.get_as_text()
			if file.get_error()==OK:
				# Always reread the file. Memoize only validation of byte-for-byte
				# unchanged text, with two bounded entries; replacement is detected.
				if _validated_backups.get(suffix)!=null and _validated_backups[suffix]==contents:
					valid=true
				else:
					var parser=JSON.new()
					valid=parser.parse(contents)==OK and validate(parser.data)
					if valid and contents.length()<=65536: _validated_backups[suffix]=contents
			file.close()
		if valid: continue
		_validated_backups.erase(suffix)
		var err=DirAccess.copy_absolute(ProjectSettings.globalize_path(path()),ProjectSettings.globalize_path(path()+suffix))
		if err!=OK:
			last_error="World is saved, but a recovery copy could not be repaired (%d)."%err
			return false
	return true

func _write_snapshot(contents:String) -> bool:
	var temp = path()+".tmp"
	var f = FileAccess.open(temp,FileAccess.WRITE)
	if not f:
		last_error = "Unable to write save. Check storage permissions."
		return false
	f.store_string(contents)
	f.flush()
	f.close()
	var absolute = ProjectSettings.globalize_path(path())
	# Copy backups first. A rename failure never deletes the original.
	if FileAccess.file_exists(path()+".bak"):
		DirAccess.copy_absolute(absolute+".bak",absolute+".bak2")
	if FileAccess.file_exists(path()):
		DirAccess.copy_absolute(absolute,absolute+".bak")
	var err = DirAccess.rename_absolute(ProjectSettings.globalize_path(temp),absolute)
	if err != OK:
		last_error = "Could not finalize save (%d). Existing save preserved." % err
		return false
	return true
