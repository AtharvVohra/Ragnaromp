extends Node

onready var width = get_viewport().size.x
onready var height = get_viewport().size.y

# Later we should calculate the lane y-coords based on window height
# draugrs add 2 honor
# ice giants add 4 honor
var playerHonor = 0
var highScoreHonor = 0
var lanes = [240, 360, 480]

var movespeed = 3
# 5
# 10

const DRAUGR = 0	# Used for stitches (spawning enemies)
const GIANT  = 1
const PLAYER = 2
const HAMMER = 3
# The Quilt creation is in Main.gd

#func _ready():
#	pass