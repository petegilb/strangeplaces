class_name Main
extends Node3D

enum GameState {
	BeforeAuction,
	AuctionCountdown,
	AuctionStarted,
	AuctionEnded
}

@export var before_auction_time: int = 20

var state: GameState = GameState.BeforeAuction
@onready var player: Player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player")[0] else null

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument:String):
	if argument == "StartAuction":
		start_auction_countdown()
	if argument == "placebet":
		player.check_bet()
		
func _process(_delta: float) -> void:
	if $AuctionTimer.is_stopped():
		$GlobalUI/TimerLabel.hide()
	else:
		$GlobalUI/TimerLabel.show()
		$GlobalUI/TimerLabel.text = "%d Min" % int($AuctionTimer.time_left)
	

func start_auction_countdown() -> void:
	print("Auction Countdown Starting!!!")
	state = GameState.AuctionCountdown
	$AuctionTimer.start(before_auction_time)
		
func start_auction() -> void:
	print("The Auction is starting!")
	player.auction_started()
	state = GameState.AuctionStarted
	for npc in get_tree().get_nodes_in_group("npc"):
		npc.auction_started()

func _on_auction_timer_timeout() -> void:
	if state == GameState.AuctionCountdown:
		start_auction()
	$AuctionTimer.stop()

#func _physics_process(_delta: float) -> void:
	#await get_tree().create_timer(1.0).timeout
	#if player != null and $Npc != null:
		#$Npc.set_movement_target(player.position)
