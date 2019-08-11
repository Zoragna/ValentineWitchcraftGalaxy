extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var troposphere_color = Color.white

var troposphere_height = 15
var atmosphere_height = 30

var mass = 0.02
var radius = 1

var start_pos

var normal = Vector3(0,0.2,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _ready():
	start_pos = get_node("Spatial").get_global_transform().origin