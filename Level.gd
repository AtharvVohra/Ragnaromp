extends Node2D

onready var player = get_node("Player")
var player_lane

func _ready():
	print(globals.width)
	print(globals.height)
	
	# Place player on the middle
	# lanes array is a global singleton
	player_lane = 1
	print(player_lane)
	player.position.y = globals.lanes[player_lane]
	print(player.position.y)
	player.show()
	
func _process():
	# Set objects' coords to their lane
	player.position.y = player_lane
	
	
func _physics_process(delta):
	pass