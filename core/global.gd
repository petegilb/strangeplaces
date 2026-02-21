extends Node

@onready var main: Main = get_tree().get_nodes_in_group("main")[0] if get_tree().get_nodes_in_group("main") else null

func get_game_state() -> Main.GameState:
	return main.state
