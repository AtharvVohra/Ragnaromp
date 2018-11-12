extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	get_node("Won").set_text(String(globals.playerHonor)+"/"+String(globals.endHonor))
	if(globals.playerHonor >= globals.endHonor):
		$Won.set_text(String("THOR SAVED ASGARD THANKS TO HIS HONOR! GAME LOGIC!"))

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Button_pressed():
	get_tree().change_scene("res://Level.tscn")
