extends Node2D

# A Stitch object merely holds information for a single
# location where an enemy can be spawned in a pattern.

# The stitch objects will be initialized in patterns
# as part of global scope.

var xoffset		# in relation to the beginning of the pattern
var lane		# which lane an enemy should go into
var enemy		# tells us which enemy to spawn, see globals.gd