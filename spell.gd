extends RigidBody

class_name Spell

onready var timer = get_node("Timer")

signal spell_vanished

var cast_time = -1
var vanish_time = -1
var cast_direction = Vector3()
var spell_velocity = 0

var inventory_scale = Vector3(1,1,1)
var inventory_offset = Vector3(0,0,0)

var time_start = OS.get_ticks_msec()
var paused = false

var STATE = "MASTERED"

func pause():
	paused = true
	timer.stop()

func unpause():
	paused = false
	timer.start(timer.get_time_left())

func _ready():
	self.hide()

func launch():
	STATE = "LAUNCHED"
	timer.set_wait_time(vanish_time)
	timer.start()
	timer.connect("timeout", self, "vanish")
	self.show()

func vanish():
	STATE = "VANISHED"
	emit_signal("spell_vanished")

func _physics_process(delta):
	if !paused :
		set_linear_velocity(cast_direction.normalized()*delta*spell_velocity)
	else :
		set_linear_velocity(Vector3(0,0,0))
	if STATE == "MASTERED":
		transform.origin.y = -2 + sin((OS.get_ticks_msec() - time_start)*delta/10)/2

func set_cast_direction(value):
	cast_direction = value

func get_cast_direction():
	return cast_direction