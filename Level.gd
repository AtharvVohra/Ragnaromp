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
	player.position.x = 70
	print(player.position.y)
	player.show()
	
func _process(delta):
	# Input
	if Input.is_action_just_pressed('ui_up'):
		if (player_lane > 0):
			player_lane -= 1
	if Input.is_action_just_pressed('ui_down'):
		if (player_lane < 2):
			player_lane += 1

	# Set objects' coords to their lane
	player.position.y = globals.lanes[player_lane]

#func _physics_process(delta):
#	pass