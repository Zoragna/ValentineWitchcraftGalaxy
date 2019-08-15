extends Spell

var blocks = []
var block_speed = 100
var explosion_time = 1.0

func _ready():
	cast_time = -1
	vanish_time = 15.0
	spell_velocity = 1200
	inventory_scale = 0.4*Vector3(1,-1,1)
	inventory_offset = Vector3(0,-2,0)
	blocks.append(get_node("MeshInstance"))
	blocks.append(get_node("MeshInstance2"))
	blocks.append(get_node("MeshInstance3"))

func explode():
	print("column explode !")
	spell_velocity = 0
	for block in blocks :
		var tween = Tween.new()
		tween.interpolate_property(block, "scale", null, Vector3(0.1,0.1,0.1), explosion_time, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		tween.start()
		add_child(tween)
	yield(get_tree().create_timer(explosion_time), "timeout")
	emit_signal("spell_vanished")

func _physics_process(delta):
	if !paused :
		for block in blocks :
			block.transform = block.transform.rotated(Vector3(0,1,0), delta*block_speed)