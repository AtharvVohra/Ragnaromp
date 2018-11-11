extends Node

func _ready():
	
	## Get the scenes we need for patterns of enemies
	#var QuiltScene = load("res://Quilt.tscn")
	#var PatternScene = load("res://Pattern.tscn")
	#var StitchScene = load("res://Stitch.tscn")
	## Create the Quilt
	#var Quilt = QuiltScene.instance()
	#
	#var pattern1 = PatternScene.instance()
	#var stitch = StitchScene.instance()
	#stitch.xoffset = 0
	#stitch.lane = 0
	#stitch.enemy = DRAUGR
	#pattern1.stitches.append(stitch)
	#
	#Quilt.patterns.append(pattern1)

	get_tree().change_scene("res://Title.tscn")
