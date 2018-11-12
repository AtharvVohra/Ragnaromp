extends KinematicBody2D

# class member variables go here, for example:
var lane = 0
var isHit
var movespeed = 3
var bloodtex = preload("res://assets/blood.png")

func _ready():
	# randomizes draugr lane
	#lane = randi() % 3
	isHit = false
	$AnimationPlayer.play("GiantAnim")
	$Blood.hide()
	
func _physics_process(delta):
	
	#position.y = globals.lanes[lane]
	
	# Movement
	var velocity = Vector2(-1, 0)
	var collisioninfo = move_and_collide(velocity.normalized() * movespeed)
	if collisioninfo:
		isHit = true
		
	if(isHit):
		# change sprite and remove collision box
		# add honor points
		# play splat sound effect
		get_node("Sprite").set_texture(bloodtex)
		get_node("CollisionShape2D").disabled = true
		$AnimationPlayer.stop()
		$Sprite.hide()
		$BloodAnim.play("DEADGIANT")
		$Blood.show()
		globals.playerHonor += 60
		updateHonor()
		var pick = randi()%2
		if(pick == 0):
			$HonorGain1.play()
		else:
			$HonorGain2.play()
		isHit = false
	
	if(isReached() && !get_node("CollisionShape2D").disabled):
		# decrease honor
		# play people screaming sound effect
		globals.playerHonor -= 30
		updateHonor()
		var pick = randi()%2
		if(pick == 0):
			$HonorLost1.play()
		else:
			$HonorLost2.play()
		# delete the instance
		queue_free()
		print("Giant escaped!")

func isReached():
	return position.x <= -get_node("Sprite").texture.get_width()
	
func updateHonor():
	get_node("../Honor").set_text(String(globals.playerHonor))