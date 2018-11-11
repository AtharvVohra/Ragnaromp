extends KinematicBody2D

# Send Mjolnir flying, then stop when it reaches
# the end of the lane --> give it the same global movespeed
movespeed_flying = 50

func _ready():
	pass

func _physics_process(delta):
	var velocity = Vector2(1, 0)
	move_and_collide(velocity.normalized() * movespeed_flying)