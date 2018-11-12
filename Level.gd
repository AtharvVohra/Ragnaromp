extends Node2D

onready var player = get_node("Player")
var player_lane
var target_lane
var changing_lanes
var delta_y
var steps_to_move = 23
var delta_y_per_step

var DraugrScene = load("res://Draugr.tscn")
var GiantScene = load("res://IceGiant.tscn")
var PatternScene = load("res://Pattern.tscn")
var StitchScene = load("res://Stitch.tscn")
var HammerScene = load("res://Hammer.tscn")

onready var quilt = get_node("Quilt")
var create_x = globals.width + 128
var last_enemy
var can_spawn = true

var thrown_hammer
var hammer

var movespeed

func _ready():
	print(globals.width)
	print(globals.height)
	
	# The globals.lanes array is a global singleton
	# Place player on the middle lane
	player_lane = 1
	player.position.y = globals.lanes[player_lane]
	player.position.x = 175
	player.show()
	
	# Vars for player lane changing
	changing_lanes = false
	movespeed = globals.movespeed
	thrown_hammer = false
	
	create_patterns()
	
	get_node("Honor").set_text(String(globals.playerHonor))

	if (globals.playerHonor > globals.endHonor): # 15000
		# WIN THE GAME
		pass
	elif (globals.playerHonor > 11250):
		globals.difficulty = 5
		globals.movespeed = 1 + (globals.difficulty * 2)
	elif (globals.playerHonor > 7250):
		globals.difficulty = 4
		globals.movespeed = 1 + (globals.difficulty * 2)
	elif (globals.playerHonor > 4250):
		globals.difficulty = 3
		globals.movespeed = 1 + (globals.difficulty * 2)
	elif (globals.playerHonor > 1500):
		globals.difficulty = 2
		globals.movespeed = 1 + (globals.difficulty * 2)

	$GameStartSound.play()
	$FGAnim.play("FGANIM")
	
	$BG.play("default")
	
	get_node("gametimer").start()
	$time.set_text("60")
	
func _physics_process(delta):
	
	#var pbs = (1 + (0.2 * (globals.difficulty-1)))
	#Player/AnimationPlayer.playback_speed = pbs
	
	$time.set_text(String(int($gametimer.get_time_left())))
	if($ThorFootsteps.is_playing() == false):
		$ThorFootsteps.play()

	if (!thrown_hammer && Input.is_action_just_pressed("ui_select")):
		thrown_hammer = true
		$HammerThrow.play()
		get_node("Player/hammerless").visible = true
		get_node("Player/Sprite").visible = false
		get_node("Player/hammerlessanimation").play("HAMMERLESS")
		print("throw hammer")
		hammer = HammerScene.instance()
		add_child(hammer)
		hammer.position.x = player.position.x + hammer.sprwidth/2
		#hammer.position.x = player.position.x + 150
		hammer.position.y = player.position.y
		
	if (thrown_hammer):
		if (hammer.hammer_back):
			thrown_hammer = false
			get_node("Player/hammerless").visible = false
			get_node("Player/Sprite").visible = true
			hammer.queue_free()

	# Player lane changing
	if (!changing_lanes and Input.is_action_pressed('ui_up')):
		if (player_lane > 0):
			target_lane = player_lane - 1
			delta_y = globals.lanes[target_lane] - globals.lanes[player_lane]
			delta_y_per_step = delta_y / steps_to_move
			changing_lanes = true
			#print("Changing lanes to ")
			#print(target_lane)
			#print(delta_y)
			#print(delta_y_per_step)
	if (!changing_lanes and Input.is_action_pressed('ui_down')):
		if (player_lane < 2):
			target_lane = player_lane + 1
			delta_y = globals.lanes[target_lane] - globals.lanes[player_lane]
			delta_y_per_step = delta_y / steps_to_move
			changing_lanes = true
			#print("Changing lanes to ")
			#print(target_lane)
			#print(delta_y)
			#print(delta_y_per_step)
	# Set objects' coords to their lane
	#player.position.y = globals.lanes[player_lane]
	if changing_lanes:
		player.position.y += delta_y_per_step
		#print(player.position.y)
		if (delta_y < 0):
			# We're moving up
			if (player.position.y <= globals.lanes[target_lane]):
				#print("Finished changing lanes")
				player.position.y = globals.lanes[target_lane]
				player_lane = target_lane
				changing_lanes = false
		if (delta_y > 0):
			# We're moving down
			if (player.position.y >= globals.lanes[target_lane]):
				#print("Finished changing lanes")
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
			elif (stitch.enemy == globals.GIANT):
				new_enemy = GiantScene.instance()
			add_child(new_enemy)
			new_enemy.position.x = create_x + stitch.xoffset
			new_enemy.lane = stitch.lane
			new_enemy.position.y = globals.lanes[new_enemy.lane]
			# Get the coordinate of the last 
			if (stitch == pattern.stitches[pattern.stitches.size()-1]):
				last_enemy = new_enemy
		can_spawn = false
	else:
		# Determine when the pattern's last enemy enters the screen
		if (last_enemy.position.x < globals.width):
			can_spawn = true
				
	#print(get_node("gametimer").get_time_left())
	
	if($gametimer.get_time_left() == 15):
		$Timeup.play()

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

func add_stitch_to_pattern(pattern, enemy, offset, lane):
	var stitch
	stitch = StitchScene.instance()
	stitch.enemy = enemy
	stitch.xoffset = offset
	stitch.lane = lane
	pattern.add_child(stitch)
	pattern.stitches.append(stitch)
	
func create_patterns():
	# Just for code readability.
	
	# Create patterns and add them to the Quilt
	# Later inside _process they will be used to create enemies
	var dbuffer = 250
	#var fbuffer = 
	var pattern
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 1)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	#################################
	# Sheet one of patterns by Justine
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.GIANT, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*5, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*6, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*7, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*6, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*7, 1)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*6, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*6, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, 0, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*4, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*5, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*6, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*6, 1)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*6, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*6, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.GIANT, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*4, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*5, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*6, 0)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.GIANT, 0, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*4, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*5, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*5, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*6, 1)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	# end of sheet 1, pattern 8
	# Sheet 2 of patterns by Justine: 

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.GIANT, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 0)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 1)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*4, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 1)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 1)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, 0, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*4, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.GIANT, 0, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*5, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*6, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*7, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*5, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*5, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.GIANT, 0, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, 0, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 1)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)

	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, 0, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*2, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*2, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 2)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)
	
	pattern = PatternScene.instance()
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 0)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer, 1)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer, 2)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*3, 1)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*3, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*4, 0)
	add_stitch_to_pattern(pattern, globals.GIANT, dbuffer*4, 2)
	add_stitch_to_pattern(pattern, globals.DRAUGR, dbuffer*5, 0)
	quilt.add_child(pattern)
	quilt.patterns.append(pattern)