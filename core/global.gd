extends Node

@onready var main: Main = get_tree().get_nodes_in_group("main")[0]

func get_game_state() -> Main.GameState:
	return main.state
