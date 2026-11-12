extends SceneTree

const TIMEOUT: float = 5.0
var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var waited: float = 0.0
var started: bool = false


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		print("PROBE FAIL: no address given")
		quit(2)
		return
	var host: String = args[0]
	var port: int = 7777
	if host.contains(":"):
		var parts: PackedStringArray = host.rsplit(":", true, 1)
		host = parts[0]
		port = int(parts[1])
	var err: Error = peer.create_client(host, port)
	if err != OK:
		print("PROBE FAIL: could not start client: ", error_string(err))
		quit(1)
		return
	started = true


func _process(delta: float) -> bool:
	if not started:
		return false
	peer.poll()
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		print("PROBE OK: connected")
		peer.close()
		quit(0)
		return true
	waited += delta
	if waited >= TIMEOUT:
		print("PROBE FAIL: timed out")
		quit(1)
		return true
	return false
