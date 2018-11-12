extends StaticBody2D

var id = globals.PLAYER
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$AnimationPlayer.play("ThorWithHammer")
	hide()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
