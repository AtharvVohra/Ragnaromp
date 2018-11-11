extends Node

onready var width = get_viewport().size.x
onready var height = get_viewport().size.y

# Later we should calculate the lane y-coords based on window height
var lanes = [200, 350, 500]

#func _ready():
#	pass