extends Spatial

var _class = "picture"
var t = 0
var rotation_factor = 1.3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	t += delta
	rotate(Vector3(0,1,0),rotation_factor*delta)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
