extends Spatial

onready var Player = get_node("valentine")
onready var Planet = get_node("Spatial2")

var Fire_Ball = preload("res://scenes/fire_ball.tscn")
var Fire_Column = preload("res://scenes/fire_column.tscn")

var current_camera

var spells = []

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var cam_env = get_node("Camera").get_environment()
	get_node("Spatial2/book").set_cam_environment(cam_env)
	get_node("Spatial5").set_cam_environment(cam_env)
	get_node("Spatial6").set_cam_environment(cam_env)
	Player.camera.current = true
	Player.set_cam_environment(cam_env)
	Player.set_planet(Planet)
	get_node("Camera").current = false
	current_camera = "player"
	Player.connect("talking", self, "on_Player_talking")
	Player.connect("spell_cast", self, "spell_casted")
	Player.add_spell_left(Fire_Ball)
	Player.add_spell_right(Fire_Column)
	Player.unpause()

func from_spells_vanished(spell):
	print("erase spell")
	remove_child(spell)
	spells.erase(spell)

func spell_casted(spell:Spell):
	spell.set_cast_direction(Player.transform.basis.z)
	spell.transform.origin = Player.transform.origin - 10*Player.aim.z
	spell.connect("spell_vanished", self, "from_spells_vanished", [spell])
	spell.visible = true
	add_child(spell)
	spell.launch()
	spells.append(spell)

func _input(event):
	if event is InputEventKey :
		key(event)

func _physics_process(delta):
	var dist = Player.get_global_transform().origin.distance_to( Planet.get_global_transform().origin )
	if dist < Planet.troposphere_height :
		Player.camera.get_environment().get_sky().set_sky_horizon_color(Planet.troposphere_color)
	elif dist > Planet.atmosphere_height :
		Player.camera.get_environment().get_sky().set_sky_horizon_color(Color.black)
	else :
		var t = (Planet.atmosphere_height-dist)/(Planet.atmosphere_height-Planet.troposphere_height)
		var color = Planet.troposphere_color.linear_interpolate(Color.black, 1-t)
		Player.camera.get_environment().get_sky().set_sky_horizon_color(color)
	if Player.get_global_transform().origin.y < -100 && Player.STATE == "WALK" :
		var new_trans = Player.get_global_transform()
		new_trans.origin = Planet.start_pos
		Player.set_global_transform(new_trans)
		Player.velocity = Vector3()

func key(event):
	if Input.is_action_just_pressed("ui_cancel") :
		if current_camera == "player" :
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Player.camera.current = false
			get_node("Camera").current = true
			current_camera = ""
			Player.pause()
			for spell in spells :
				spell.pause()
		else :
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Player.camera.current = true
			get_node("Camera").current = false
			current_camera = "player"
			Player.unpause()
			for spell in spells :
				spell.unpause()

func on_Player_talking(pnj):
	if pnj != null :
		get_node("Label").text = pnj.text
	else :
		get_node("Label").text = ""