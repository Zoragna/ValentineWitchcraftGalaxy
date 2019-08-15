extends Spell

onready var particles = get_node("Particles")

var explosion_time = 1.0

func _ready():
	cast_time = -1
	vanish_time = 5.0
	spell_velocity = 2500
	inventory_scale = 10*Vector3(1,1,1)
	inventory_offset = Vector3(0,-2,0)

func explode():
	print("explode !")
	particles.emitting = true
	var tween = Tween.new()
	tween.interpolate_property(get_node("MeshInstance"), "scale", null, Vector3(0.1,0.1,0.1), explosion_time, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	add_child(tween)
	spell_velocity = Vector3(0,0,0)
	yield(get_tree().create_timer(explosion_time), "timeout")
	emit_signal("spell_vanished")

func _on_Area_body_entered(body):
	if STATE != "EXPLODING" && STATE != "MASTERED":
		explode()
		STATE = "EXPLODING"
