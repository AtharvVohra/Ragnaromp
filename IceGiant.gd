extends Node

# class member variables go here, for example:
var lane
var isHit 
var isReached 
var xPos

func _ready():
	# Called when the node is added to the scene for the first time.
	# randomizes draugr lane
	lane = global.lanes[randi() % 3]
	isHit = false
	isReached = false
	pass

func _process(delta):
	
	if(isHit):
		# change sprite
		# add honor points
		# play splat sound effect
		global.honor += 4
		pass
	
	if(isReached(xpos)):
		# decrease honor
		# play people screaming sound effect
		global.honor -= 2
		pass
	
	pass

func _isReached(xpos):
	if(xpos == 0):
		return true
	else:
		return false
	pass