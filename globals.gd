extends Node

onready var width = get_viewport().size.x
onready var height = get_viewport().size.y

# Later we should calculate the lane y-coords based on window height
# draugrs add 2 honor
# ice giants add 4 honor
var lanes = [100, 200, 300]
var playerHonor = 0
var highScoreHonor = 0
#func _ready():
#	pass