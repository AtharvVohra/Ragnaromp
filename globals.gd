extends Node

onready var width = get_viewport().size.x
onready var height = get_viewport().size.y

# Later we should calculate the lane y-coords based on window height
# draugrs add 2 honor
# ice giants add 4 honor
var playerHonor = 0
var highScoreHonor = 0
var lanes = [170, 270, 370]

#func _ready():
#	pass