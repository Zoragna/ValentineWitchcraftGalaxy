extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var color = Color.blue
onready var mesh = get_node("MeshInstance")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_color(value):
	color = value
	var mat = mesh.get_surface_material(0)
	mat.set_albedo(color)
	mesh.set_surface_material(0,mat)

func get_color():
	return color
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
