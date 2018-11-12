extends KinematicBody2D

# Send Mjolnir flying, then stop when it reaches
# the end of the lane --> give it the same global movespeed
onready var sprwidth = 150
var movespeed_flying = 30
var movespeed_ground = 3
var movespeed = movespeed_flying
var bloodtex = preload("res://assets/blood.png")
var ishit = false
var reverse = false		# Come back, Mjolnir!
var velocity
var hammer_back = false
var id = globals.HAMMER

func _ready():
	velocity = Vector2(1, 0)
	$AnimationPlayer.play("Spin")
	$Dropped.hide()
	print(sprwidth)

func _physics_process(delta):

	var collision = move_and_collide(velocity.normalized() * movespeed)
	# Testing for collision/death is actually done by enemies, not Hammer
	if (!reverse && collision):
		print("Hammer hit")
		ishit = true
	
	if (!reverse && (position.x >= globals.width)):
		# The hammer is at the end of the lane.
		print("Come back, Mjolnir!")
		$HammerReached.play()

		$AnimationPlayer.stop()
		$Sprite.hide()
		$Dropped.show()
		
		reverse = true
		velocity = Vector2(-1, 0)
		movespeed = movespeed_ground
	
	if (reverse && collision):
		$HammerReturn.play()
		print("Got Mjolnir back!")
		hammer_back = true
	
	#if(ishit == true):
		#get_node("res://Draugr.tscn/Sprite").set_texture(bloodtex)
		#get_node("res://Draugr.tscn/CollisionShape2D").disabled = true
		#get_node("res://Draugr.tscn/Blood").show()
		#globals.playerHonor += 2000
		#get_node("res://Level.tscn/Honor").set_text(String(globals.playerHonor))
		#ishit = false