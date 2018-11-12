extends KinematicBody2D

# Send Mjolnir flying, then stop when it reaches
# the end of the lane --> give it the same global movespeed
var movespeed_flying = 50
var bloodtex = preload("res://assets/blood.png")
var ishit = false

func _ready():
	pass

func _physics_process(delta):
	var velocity = Vector2(1, 0)
	var collision = move_and_collide(velocity.normalized() * movespeed_flying)
	if collision:
		ishit = true
	
	if(ishit == true):
		get_node("res://Draugr.tscn/Sprite").set_texture(bloodtex)
		get_node("res://Draugr.tscn/CollisionShape2D").disabled = true
		get_node("res://Draugr.tscn/Blood").show()
		globals.playerHonor += 2000
		get_node("res://Level.tscn/Honor").set_text(String(globals.playerHonor))
		
		ishit = false