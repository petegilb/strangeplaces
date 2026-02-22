class_name Main
extends Node3D

enum GameState {
	BeforeAuction,
	AuctionCountdown,
	AuctionStarted,
	AuctionBidding,
	AuctionEnded
}


@export var waiting_room_song: AudioStream
@export var auction_started_song: AudioStream
@export var before_auction_time: int = 20
@export var auction_items: Array[String] = ["Dictionary"]


@onready var player: Player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player")[0] else null

var state: GameState = GameState.BeforeAuction
var current_item: int = 0

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	$Music.stream = waiting_room_song
	$Music.play()

func _on_dialogic_signal(argument:String):
	if argument == "StartAuction":
		start_auction_countdown()
	if argument == "placebet":
		player.check_bet()
	if argument == "startbidding":
		start_bidding()
		
func _process(_delta: float) -> void:
	if $AuctionTimer.is_stopped():
		$GlobalUI/TimerLabel.hide()
	else:
		$GlobalUI/TimerLabel.show()
		$GlobalUI/TimerLabel.text = "%d Min" % int($AuctionTimer.time_left)
	
func start_auction_countdown() -> void:
	if state != GameState.BeforeAuction:
		return
	print("Auction Countdown Starting!!!")
	state = GameState.AuctionCountdown
	$AuctionTimer.start(before_auction_time)

func _on_auction_timer_timeout() -> void:
	if state == GameState.AuctionCountdown:
		start_auction()
	$AuctionTimer.stop()

func wait_for_npc_arrival() -> void:
	while true:
		var npc_arrived: bool = true
		for npc in get_tree().get_nodes_in_group("npc"):
			npc_arrived = npc_arrived and npc.navigation_agent.is_navigation_finished()
		var leader_pos: Vector3 = $Level1/AuctionLeader.global_position
		npc_arrived = npc_arrived and leader_pos.distance_squared_to(player.global_position) < 50.0
		await get_tree().create_timer(1.0).timeout
		if npc_arrived == true:
			break

func start_auction() -> void:
	print("The Auction is starting!")
	player.auction_started()
	state = GameState.AuctionStarted
	for npc in get_tree().get_nodes_in_group("npc"):
		npc.auction_started()
	var tween = get_tree().create_tween()
	var final_position = $Level1/Models/RoomDoor.position + Vector3(0, 6, 0)
	$Level1/DoorOpen.play()
	tween.tween_property($Level1/Models/RoomDoor, "position", final_position, 3.0)
	await wait_for_npc_arrival()
	print('everyone has arrived')
	$Music.stop()
	$Music.stream = auction_started_song
	$Music.play()
	player.activate_dialogue("auctionstart2", true)
	
func start_bidding() -> void:
	state = GameState.AuctionBidding
	print("bidding has begun for %s" % auction_items[current_item])
