extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("StaticBody/CollisionShape").make_convex_from_brothers()
	print(get_node("StaticBody/CollisionShape").shape.points)

func _process(delta):
	pass	