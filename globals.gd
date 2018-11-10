extends Node

onready var width = get_viewport().size.x
onready var height = get_viewport().size.y

# Later we should calculate the lane y-coords based on window height
var lanes = [100, 200, 300]

#func _ready():
#	pass