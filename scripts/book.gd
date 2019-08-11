extends Spatial

# Declare member variables here. Examples:
onready var camera = get_node("Camera")

var _class = "book"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_cam_environment(value):
	camera.set_environment(value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
