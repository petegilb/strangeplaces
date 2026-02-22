extends Node

@onready var main: Main = get_tree().get_nodes_in_group("main")[0] if get_tree().get_nodes_in_group("main") else null

func get_game_state() -> Main.GameState:
	return main.state

func player_place_bet(bet: int) -> void:
	main.player_place_bet(bet)

func get_highest_bid() -> int:
	return main.highest_bid

func pause_timer() -> void:
	main.pause_timer()

func resume_timer() -> void:
	main.resume_timer()
