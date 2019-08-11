extends Spatial

var text = "HEY !"
var text_time = 1
var talked_time = 0
var eye_color = Color.red
var _class = "pnj"
var STATE = "IDLE"
var t = 0.0

var jaw_multiplicator = 0.02
var jaw_speed = 6.0

onready var camera = get_node("Camera")
onready var right_eye = get_node("KinematicBody/MeshInstance/OmniLight")
onready var left_eye = get_node("KinematicBody/MeshInstance/OmniLight3")
onready var jaw = get_node("KinematicBody/MeshInstance/MeshInstance")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_eye_color(eye_color)

func set_eye_color(value):
	eye_color = value
	set_eyes_color()

func set_eyes_color():
	right_eye.light_color = eye_color
	left_eye.light_color = eye_color

func set_cam_environment(value):
	camera.set_environment(value)

func begin_talk():
	STATE = "TALK"
	talked_time = 0

func stop_talk():
	STATE = "IDLE"

func talk(delta):
	t += delta
	talked_time += delta
	var offset = Vector3(0, jaw_multiplicator*sin(t*jaw_speed),0)
	jaw.set_transform(jaw.get_transform().translated(offset))

func _physics_process(delta):
	if STATE == "TALK":
		if talked_time < text_time :
			talk(delta)