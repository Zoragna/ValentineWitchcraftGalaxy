extends KinematicBody

var mouse_sensitivity = 0.3
var head_angle_y = 0

onready var camera = get_node("head/Camera")
onready var head = get_node("head")

var speed = 10
var acceleration = 5
var direction
var aim
var paused = false
var velocity = Vector3()

var mass = 50
var g = 9.8
var weight = g*mass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pause():
	paused = true

func unpause():
	paused = false

func _physics_process(delta):
	if !paused :
		walk(delta)

func walk(delta):
	direction = Vector3()
	aim = camera.get_global_transform().basis
	if Input.is_action_pressed("ui_left") :
		direction -= aim.x
	if Input.is_action_pressed("ui_right") :
		direction += aim.x
	if Input.is_action_pressed("ui_up") :
		direction -= aim.z
	if Input.is_action_pressed("ui_down") :
		direction += aim.z
	direction = direction.normalized()
	var target = direction*speed
	velocity.y -= weight*delta
	velocity = velocity.linear_interpolate(target, acceleration*delta)
#		move_and_slide(speed*delta*direction, Vector3(0,1,0))
	velocity = move_and_slide(velocity,Vector3(0,1,0))

func fly(delta):
	direction = Vector3()
	aim = camera.get_global_transform().basis
	if Input.is_action_pressed("ui_left") :
		direction -= aim.x
	if Input.is_action_pressed("ui_right") :
		direction += aim.x
	if Input.is_action_pressed("ui_up") :
		direction -= aim.z
	if Input.is_action_pressed("ui_down") :
		direction += aim.z
	direction = direction.normalized()
	var target = direction*speed
	velocity = velocity.linear_interpolate(target, acceleration*delta)
#		move_and_slide(speed*delta*direction, Vector3(0,1,0))
	move_and_slide(velocity)

func look_updown_rotation(rotation = 0):
	"""
	Get the new rotation for looking up and down
	"""
	var toReturn = camera.get_rotation() + Vector3(rotation, 0, 0)
	toReturn.x = clamp(toReturn.x, 0, PI)
	return toReturn

func look_leftright_rotation(rotation = 0):
	"""
	Get the new rotation for looking left and right
	"""
	return head.get_rotation() + Vector3(0, 0, rotation)

func mouse(event):
	"""
	First person camera controls
	"""
	head.set_rotation(look_leftright_rotation(event.relative.x / -200))
	camera.set_rotation(look_updown_rotation(event.relative.y / -200))

func _input(event):
	##
	## We'll only process mouse motion events
	if !paused :
		if event is InputEventMouseMotion:
			if camera.current :
				return mouse(event)