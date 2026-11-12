extends SceneTree

const EXPECT_GAME_ID: String = "manor-game"
const EXPECT_VERSION: int = 1
const TIMEOUT: float = 8.0

var _done: bool = false


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		_finish(false, "no address given")
		return
	var host: String = args[0]
	var port: int = 7777
	if host.contains(":"):
		var parts: PackedStringArray = host.rsplit(":", true, 1)
		host = parts[0]
		port = int(parts[1])

	var responder: Node = root.get_node_or_null("ProbeResponder")
	if responder == null:
		_finish(false, "ProbeResponder autoload is missing")
		return
	responder.reply_received.connect(_on_reply)

	var peer := ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(host, port)
	if err != OK:
		_finish(false, "could not start client: " + error_string(err))
		return
	var mp: MultiplayerAPI = get_multiplayer()
	mp.multiplayer_peer = peer
	mp.connected_to_server.connect(_on_connected)
	mp.connection_failed.connect(func() -> void: _finish(false, "connection failed"))
	create_timer(TIMEOUT).timeout.connect(func() -> void: _finish(false, "timed out"))


func _on_connected() -> void:
	var responder: Node = root.get_node("ProbeResponder")
	responder._probe_hello.rpc_id(1)


func _on_reply(game_id: String, version: int, state: int, players: int,
		max_players: int) -> void:
	if game_id != EXPECT_GAME_ID:
		_finish(false, "wrong game id: " + game_id)
	elif version != EXPECT_VERSION:
		_finish(false, "wrong version: " + str(version))
	else:
		_finish(true, "game=%s version=%d state=%d players=%d/%d" % [
			game_id, version, state, players, max_players])


func _finish(ok: bool, message: String) -> void:
	if _done:
		return
	_done = true
	print(("PROBE OK: " if ok else "PROBE FAIL: ") + message)
	quit(0 if ok else 1)
