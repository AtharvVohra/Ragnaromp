extends VBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	if globals.playerHonor == 200000:
		get_node("Won").visible = true

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_StartGame_pressed():
	get_tree().change_scene("res://Level.tscn")


func _on_Upgrades_pressed():
	pass # replace with function body
