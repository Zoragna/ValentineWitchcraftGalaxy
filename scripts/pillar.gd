extends Spatial

var color = Color.red
var t = 0
var state = "DEACTIVATED"
onready var mesh = get_node("MeshInstance")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	var mat = mesh.get_surface_material(0)
	if state == "ACTIVATED" :
		mat.set_emission(Color((10*sin(3*t)+60)/256,0,0))
	else :
		mat.set_emission(Color((20*sin(t)+30)/256,0,0))
	mesh.set_surface_material(0, mat)

func activate():
	state = "ACTIVATED"

func deactivate():
	state = "DEACTIVATED"