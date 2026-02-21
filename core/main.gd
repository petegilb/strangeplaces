extends Node3D

@export var player: Player

#func _physics_process(_delta: float) -> void:
	#await get_tree().create_timer(1.0).timeout
	#if player != null and $Npc != null:
		#$Npc.set_movement_target(player.position)
