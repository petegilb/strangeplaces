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
@export var auction_ended_song: AudioStream
@export var before_auction_time: int = 20
@export var during_auction_time: int = 30
@export var auction_items = ["MP3 Player", "YSD for Dummies", "Kitsune Painting", "Cucumber", "Kanabo"]
@export var auction_items_dict: Dictionary[String, int] = {
	"MP3 Player": 300,
	"YSD for Dummies": 20,
	"Kitsune Painting": 100,
	"Cucumber": 99,
	"Kanabo": 150
}
@export var auction_items_dialogue_dict: Dictionary[String, String] = {
	"MP3 Player": "Announcing item 1",
	"YSD for Dummies": "Announcing item 2",
	"Kitsune Painting": "Announcing item 3",
	"Cucumber": "Announcing item 4",
	"Kanabo": "Announcing item 5"
}
@export var bidding_time: int = 11

@onready var player: Player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player")[0] else null
@onready var current_item: int = 0

var state: GameState = GameState.BeforeAuction
var rng = RandomNumberGenerator.new()
var highest_bid = 0
var highest_bidder: Node3D = null

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	$Music.stream = waiting_room_song
	$Music.play()
	$GlobalUI/WinScreen.hide()

func _on_dialogic_signal(argument:String):
	if argument == "StartAuction":
		start_auction_countdown()
	if argument == "placebet":
		player.check_bet()
	if argument == "startbidding":
		start_bidding()
	if argument == "DICTIONARY2":
		player.add_item_to_inventory("YSD for Dummies Vol.2")
	if argument == "youwin":
		$GlobalUI/WinScreen.show()
		player.immobile = true
		
func _process(_delta: float) -> void:
	if $AuctionTimer.is_stopped():
		$GlobalUI/TimerLabel.hide()
	else:
		$GlobalUI/TimerLabel.show()
		$GlobalUI/TimerLabel.text = "%d" % int($AuctionTimer.time_left)
		
func pause_timer() -> void:
	$AuctionTimer.paused = true
	
func resume_timer() -> void:
	$AuctionTimer.paused = false
	
func start_auction_countdown() -> void:
	if state != GameState.BeforeAuction:
		return
	print("Auction Countdown Starting!!!")
	state = GameState.AuctionCountdown
	$AuctionTimer.start(before_auction_time)

func _on_auction_timer_timeout() -> void:
	$AuctionTimer.stop()
	if state == GameState.AuctionCountdown:
		start_auction()
	if state == GameState.AuctionBidding:
		stop_bidding()
	if state == GameState.AuctionStarted:
		player.activate_dialogue(auction_items_dialogue_dict[auction_items[current_item]], true)

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
	for npc in get_tree().get_nodes_in_group("bidder"):
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
	$AuctionTimer.start(bidding_time)
	random_npc_bidding()

func random_npc_bidding() -> void:
	while state == GameState.AuctionBidding:
		await get_tree().create_timer(rng.randf_range(1.5, 5.0)).timeout
		if state != GameState.AuctionBidding or $AuctionTimer.paused or $AuctionTimer.time_left < 2.5:
			return
		var npcs = get_tree().get_nodes_in_group("bidder")
		var npc: Npc = npcs.pick_random()
		npc.place_bet()
		if highest_bid == 0:
			set_bid(auction_items_dict[auction_items[current_item]], npc)
		else:
			var new_bid = randi_range(1, 12) + highest_bid
			set_bid(new_bid, npc)
		await get_tree().create_timer(2.0).timeout
	
func stop_bidding() -> void:
	state = GameState.AuctionStarted
	if highest_bidder == player:
		player.money -= highest_bid
		player.add_item_to_inventory(auction_items[current_item])
		print("player won %s" % auction_items[current_item])
	else:
		print("yokai won %s" % auction_items[current_item])
	player.activate_dialogue("Segue to next item", true)
	highest_bid = 0
	highest_bidder = null
	current_item += 1
	player.bet_bar_value = 0.0
	# end the auction if all items have been sold
	if current_item >= auction_items.size():
		end_auction()
		return
	print('made it here')
	$AuctionTimer.start(during_auction_time)

func end_auction() -> void:
	state = GameState.AuctionEnded
	print("the auction has ended!")
	$Music.stop()
	$Music.stream = auction_ended_song
	$Music.play()
	
func set_bid(bid: int, bidder: Node3D):
	highest_bid = bid
	highest_bidder = bidder

func player_place_bet(bet: int) -> void:
	set_bid(bet, player)
