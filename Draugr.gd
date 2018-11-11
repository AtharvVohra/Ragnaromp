extends KinematicBody2D

# class member variables go here, for example:
var lane
var isHit
var movespeed = 100

func _ready():
	# randomizes draugr lane
	lane = randi() % 3
	position.y = globals.lanes[lane]
	isHit = false
	
func _physics_process(delta):
	
	# Movement
	var velocity = Vector2(-1, 0)
	move_and_slide(velocity.normalized() * movespeed)
	
	if(isHit):
		# change sprite
		# add honor points
		# play splat sound effect
		globals.playerHonor += 2000
	
	if(isReached()):
		# decrease honor
		# play people screaming sound effect
		globals.playerHonor -= 1000
		
		# delete the instance
		queue_free()
		print("Draugr escaped!")

func isReached():
	return position.x <= -get_node("Sprite").texture.get_width()