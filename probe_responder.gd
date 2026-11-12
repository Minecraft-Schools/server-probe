extends Node

signal reply_received(game_id: String, version: int, state: int, players: int, max_players: int)


@rpc("any_peer", "reliable")
func _probe_hello() -> void:
	pass   # only the real server answers this


@rpc("authority", "reliable")
func _probe_reply(game_id: String, version: int, state: int, players: int,
		max_players: int) -> void:
	reply_received.emit(game_id, version, state, players, max_players)
