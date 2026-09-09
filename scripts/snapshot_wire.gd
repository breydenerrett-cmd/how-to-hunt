extends RefCounted
## Bounded, atomic snapshot assembly. Missing datagrams are superseded by newer snapshots.
const CHUNK_BYTES=900
const MAX_CHUNKS=32
const MAX_DECODED=65536
var pending:Dictionary={}
var newest:=-1

static func encode(packet:Dictionary) -> Array[PackedByteArray]:
	var raw=var_to_bytes(packet)
	if raw.size()>MAX_DECODED: return []
	var compressed=raw.compress(FileAccess.COMPRESSION_DEFLATE)
	var chunks:Array[PackedByteArray]=[]
	if compressed.size()>CHUNK_BYTES*MAX_CHUNKS: return chunks
	for offset in range(0,compressed.size(),CHUNK_BYTES):
		chunks.append(compressed.slice(offset,mini(offset+CHUNK_BYTES,compressed.size())))
	return chunks

func accept(revision:int,index:int,total:int,chunk:PackedByteArray) -> Dictionary:
	if revision<newest-1 or total<1 or total>MAX_CHUNKS or index<0 or index>=total or chunk.is_empty() or chunk.size()>CHUNK_BYTES: return {}
	newest=maxi(newest,revision)
	for key in pending.keys():
		if key<newest-1: pending.erase(key)
	if not pending.has(revision): pending[revision]={"count":total,"parts":{}}
	var entry:Dictionary=pending[revision]
	if entry.count!=total: return {}
	entry.parts[index]=chunk
	if entry.parts.size()!=total: return {}
	var compressed=PackedByteArray()
	for part in range(total): compressed.append_array(entry.parts[part])
	pending.erase(revision)
	var raw=compressed.decompress_dynamic(MAX_DECODED,FileAccess.COMPRESSION_DEFLATE)
	if raw.is_empty(): return {}
	var packet=bytes_to_var(raw)
	if not packet is Dictionary or not packet.has_all(["revision","players","animals","progress"]): return {}
	if int(packet.revision)!=revision: return {}
	return packet
