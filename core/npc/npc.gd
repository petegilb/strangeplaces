extends CharacterBody3D

enum NpcState{
	Idle,
	Moving,
	Betting
}

var state: NpcState = NpcState.Idle
@export var next_dialogue_timeline = "nothing"
@export var auction_location: Node3D = null

# https://docs.godotengine.org/en/latest/tutorials/navigation/navigation_introduction_3d.html
var movement_speed: float = 1.0
var movement_target_position: Vector3 = Vector3()
var auction_look_target: Vector3 = Vector3(0, 0, 10)
var look_target: Vector3 = Vector3()

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	actor_setup.call_deferred()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	#set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(_delta):
	handle_anims()
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	if not look_target.is_zero_approx():
		look_at(look_target)
	elif not global_position.is_equal_approx(next_path_position):
		look_at(next_path_position)
	
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()
	
func handle_anims() -> void:
	if navigation_agent.is_navigation_finished():
		$AnimationTree.set("parameters/WalkTransition/transition_request", "Idle")
		if state == NpcState.Betting:
			look_at(auction_look_target)
	else:
		$AnimationTree.set("parameters/WalkTransition/transition_request", "Walk")

func get_dialogue() -> String:
	return next_dialogue_timeline
	
func auction_started() -> void:
	set_movement_target(auction_location.global_position)
	state = NpcState.Betting
