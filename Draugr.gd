extends KinematicBody2D

# class member variables go here, for example:
var lane = 0
var isHit
var movespeed = globals.movespeed
var bloodtex = preload("res://assets/blood.png")
var id = globals.DRAUGR
var killedScore = 20
var deathScore = 10
var die = false

func _ready():
	# randomizes draugr lane
	#lane = randi() % 3
	isHit = false
	$AnimationPlayer.play("DraugrAnim")
	$Blood.hide()
	
func _physics_process(delta):
	
	if (die):
		if (position.x <= -$Sprite.texture.get_width()*10):
			queue_free()
	
	#position.y = globals.lanes[lane]
	deathScore = 10 + ((globals.difficulty-1) * 5)
	
	# Movement
	var velocity = Vector2(-1, 0)
	var collisioninfo = move_and_collide(velocity.normalized() * movespeed)
	if collisioninfo:
		if (collisioninfo.collider.id == globals.PLAYER or collisioninfo.collider.id == globals.HAMMER):
			isHit = true
		
	if(isHit):
		# change sprite and remove collision box
		# add honor points
		# play splat sound effect
		get_node("Sprite").set_texture(bloodtex)
		get_node("CollisionShape2D").disabled = true
		$AnimationPlayer.stop()
		$Sprite.hide()
		$BloodAnim.play("DEADDRAUGR")
		$Blood.show()
		globals.playerHonor += killedScore
		updateHonor()
		randomize()
		var pick = randi()%4
		if(pick == 0):
			$HonorGain1.play()
		elif(pick == 1):
			$HonorGain2.play()
		elif(pick == 2):
			$HonorGain3.play()
		else:
			$HonorGain4.play()
		isHit = false
		
	
	if(!die && isReached() && !get_node("CollisionShape2D").disabled):
		# decrease honor
		# play people screaming sound effect
		globals.playerHonor -= deathScore
		updateHonor()
		randomize()
		var pick = randi()%6
		if(pick == 0):
			$HonorLost1.play()
		elif(pick == 1):
			$HonorLost2.play()
		elif(pick == 2):
			$HonorLost3.play()
		elif(pick == 3):
			$HonorLost4.play()
		elif(pick == 4):
			$HonorLost5.play()
		else:
			$HeavyBreathing.play()
		
		print("Draugr escaped!")
		die = true
		# delete the instance
		#queue_free()

func isReached():
	return position.x <= 0
	
func updateHonor():
	get_node("../Honor").set_text(String(globals.playerHonor))