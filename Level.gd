extends Node2D

onready var player = get_node("Player")
var player_lane
var target_lane
var changing_lanes
var delta_y
var steps_to_move
var delta_y_per_step

var create_x

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
	
	changing_lanes = false
	steps_to_move = 30
	
	create_x = globals.width + 128
	
	var DraugrScene = load("res://Draugr.tscn")
	var new_draugr = DraugrScene.instance()
	add_child(new_draugr)
	new_draugr.position.x = create_x
	#get_node("/root/Draugr.tscn").call_deferred("add_child", new_draugr)
	get_node("Honor").set_text(String(globals.playerHonor))
	
	get_node("gametimer").start()
	
func _physics_process(delta):

	# Player lane changing
	if (!changing_lanes and Input.is_action_just_pressed('ui_up')):
		if (player_lane > 0):
			target_lane = player_lane - 1
			delta_y = globals.lanes[target_lane] - globals.lanes[player_lane]
			delta_y_per_step = delta_y / steps_to_move
			changing_lanes = true
			print("Changing lanes to ")
			print(target_lane)
			print(delta_y)
			print(delta_y_per_step)
	if (!changing_lanes and Input.is_action_just_pressed('ui_down')):
		if (player_lane < 2):
			target_lane = player_lane + 1
			delta_y = globals.lanes[target_lane] - globals.lanes[player_lane]
			delta_y_per_step = delta_y / steps_to_move
			changing_lanes = true
			print("Changing lanes to ")
			print(target_lane)
			print(delta_y)
			print(delta_y_per_step)
	# Set objects' coords to their lane
	#player.position.y = globals.lanes[player_lane]
	if changing_lanes:
		player.position.y += delta_y_per_step
		print(player.position.y)
		if (delta_y < 0):
			# We're moving up
			if (player.position.y <= globals.lanes[target_lane]):
				print("Finished changing lanes")
				player.position.y = globals.lanes[target_lane]
				player_lane = target_lane
				changing_lanes = false
		if (delta_y > 0):
			# We're moving down
			if (player.position.y >= globals.lanes[target_lane]):
				print("Finished changing lanes")
				player.position.y = globals.lanes[target_lane]
				player_lane = target_lane
				changing_lanes = false
				
	print(get_node("gametimer").get_time_left())

func _on_gametimer_timeout():
	var t = Timer.new()
	t.set_wait_time(2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	#get_tree().paused = true
	get_node("GameOver").visible = true
	print("ROMP OVER!")
	yield(t, "timeout")
	t.queue_free()
	get_tree().change_scene("res://Title.tscn")