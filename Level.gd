extends Node2D

onready var player = get_node("Player")
var player_lane
var target_lane
var changing_lanes
var delta_y
var steps_to_move
var delta_y_per_step

var DraugrScene = load("res://Draugr.tscn")
var PatternScene = load("res://Pattern.tscn")
var StitchScene = load("res://Stitch.tscn")
var last_enemy
var can_spawn = true

var create_x = globals.width + 128

onready var quilt = get_node("Quilt")

func _ready():
	print(globals.width)
	print(globals.height)
	
	# The globals.lanes array is a global singleton
	# Place player on the middle lane
	player_lane = 1
	player.position.y = globals.lanes[player_lane]
	player.position.x = 70
	player.show()
	
	# Vars for player lane changing
	changing_lanes = false
	steps_to_move = 30
		
	# Create patterns and add them to the Quilt
	# Later inside _process they will be used to create enemies
	var pattern = PatternScene.instance()
	var stitch = StitchScene.instance()
	stitch.enemy = globals.DRAUGR
	stitch.xoffset = 0
	stitch.lane = 0
	pattern.add_child(stitch)
	pattern.stitches.append(stitch)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	
#	var DraugrScene = load("res://Draugr.tscn")
#	var new_draugr = DraugrScene.instance()
#	add_child(new_draugr)
#	new_draugr.position.x = create_x
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
	
	# Spawn enemies based on patterns
	# Pick a random pattern
	if can_spawn:
		var pattern = quilt.patterns[rand_range(0, quilt.patterns.size())]
		for stitch in pattern.stitches:
			var new_enemy
			if (stitch.enemy == globals.DRAUGR):
				new_enemy = DraugrScene.instance()
				add_child(new_enemy)
				new_enemy.position.x = create_x + stitch.xoffset
				new_enemy.lane = stitch.lane
				# Get the coordinate of the last 
			if (stitch == pattern.stitches[pattern.stitches.size()-1]):
				last_enemy = new_enemy
		can_spawn = false
	else:
		# Determine when the pattern's last enemy enters the screen
		if (last_enemy.position.x < globals.width):
			can_spawn = true
				
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