extends MeshInstance

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var spot = get_node("SpotLight")

var t = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	spot.light_energy = 1.5+cos(t)
