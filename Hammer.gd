extends KinematicBody2D

# Send Mjolnir flying, then stop when it reaches
# the end of the lane --> give it the same global movespeed
var movespeed_flying = 30
var movespeed_ground = 3
var movespeed = movespeed_flying
var bloodtex = preload("res://assets/blood.png")
var ishit = false
var reverse = false		# Come back, Mjolnir!
var velocity

func _ready():
	velocity = Vector2(1, 0)

func _physics_process(delta):

	var collision = move_and_collide(velocity.normalized() * movespeed)
	# Testing for collision/death is actually done by enemies, not Hammer
	if collision:
		print("Hammer hit")
		ishit = true
	
	if (!reverse && (position.x >= globals.width-$Sprite.texture.get_width()/2)):
		# The hammer is at the end of the lane.
		print("Come back, Mjolnir!")
		reverse = true
		velocity = Vector2(-1, 0)
		movespeed = movespeed_ground
		
	
	#if(ishit == true):
		#get_node("res://Draugr.tscn/Sprite").set_texture(bloodtex)
		#get_node("res://Draugr.tscn/CollisionShape2D").disabled = true
		#get_node("res://Draugr.tscn/Blood").show()
		#globals.playerHonor += 2000
		#get_node("res://Level.tscn/Honor").set_text(String(globals.playerHonor))
		#ishit = false