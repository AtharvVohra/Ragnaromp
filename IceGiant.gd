extends KinematicBody2D

# class member variables go here, for example:
var lane
var isHit
var movespeed = 20

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
		globals.honor += 4
	
	if(isReached(position.x)):
		# decrease honor
		# play people screaming sound effect
		globals.honor -= 2
		
		# delete the instance

func isReached(xpos):
	return position.x == 0