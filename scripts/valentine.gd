extends KinematicBody

var mouse_sensitivity = 0.3
var head_angle_y = 0

onready var head = get_node("head")
onready var fly_camera = head.get_node("Camera")
onready var walk_camera = head.get_node("Camera2")
onready var changing_camera = get_node("Camera3")
onready var leg = get_node("Raycast")
onready var broom_area = get_node("Area/CollisionShape")
onready var spotlight = get_node("SpotLight")
onready var query_ray = get_node("Raycast")
onready var debug_label = get_node("Control/Label")
onready var animation_player = get_node("AnimationTree/AnimationPlayer")
onready var hud = get_node("Control")
onready var axe_with_camera = get_node("axe_with_camera")

signal talking
signal spell_cast

var health = 10

var camera
var min_head_dist = 7
var max_head_dist = 19

var broom
var book
var pnj
var query

var spells = {}

var STATE = "FLY"

var speed = 10
var jump_speed = 750
var acceleration = 5
var tilt_accel = 200
var direction
var aim
var paused = false
var velocity = Vector3()
var nearest_planet
var _planet_direction

var mass = 50
var g = 0
var weight = g*mass

var broom_in = false

func _ready():
	camera = fly_camera
	spotlight.light_energy = 0
	hud.hide()
	
func set_cam_environment(value):
	walk_camera.set_environment(value)
	fly_camera.set_environment(value)
	changing_camera.set_environment(value)

func set_camera(value):
	camera.current = false
	camera = value
	camera.current = true

func _process(delta):
	pass

func set_planet(planet):
	nearest_planet = planet
	set_g()

func set_g() :
	g = - mass * nearest_planet.mass / (nearest_planet.radius*nearest_planet.radius)
	weight = g*mass

func pause():
	paused = true
	axe_with_camera.stop_all()
	hud.hide()

func unpause():
	paused = false
	axe_with_camera.resume_all()
	if STATE == "QUERY":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else :
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if STATE == "CHANGING":
			hud.show()


func _physics_process(delta):
	if !paused :
		if STATE == "WALK" :
			walk(delta)
		elif STATE == "FLY" :
			fly(delta)
		elif STATE == "QUERY" :
			var pos = query_ray.get_collision_point()
			pos.y += 1
			var newtrans = spotlight.get_global_transform()
			newtrans.origin = pos
			spotlight.set_global_transform(newtrans)

func walk(delta):
	var planet_normal = nearest_planet.normal.normalized()
	var bas = transform.basis
	var this_dot = planet_normal.dot(bas.y)
	if abs(this_dot - 1) > 0.01 :
		print("@")
		var cross = planet_normal.cross(bas.y)
		var angle = planet_normal.angle_to(bas.y)
		bas = bas.rotated(cross.normalized(), -angle)
		var trans = transform.basis.orthonormalized()
		var newbas = Quat(trans).slerp(Quat(bas.orthonormalized()),clamp(this_dot,0.1,1.0))
		transform.basis = Basis( newbas )
		transform = transform.orthonormalized()
	else :
		transform.basis.y = planet_normal
		transform = transform.orthonormalized()
	direction = Vector3()
	var target = Vector3()
	var velxy = Vector2(velocity.x, velocity.z)
	if !axe_with_camera.is_active():
		aim = head.get_global_transform().basis
	if Input.is_action_pressed("ui_left") :
		direction -= aim.x
	if Input.is_action_pressed("ui_right") :
		direction += aim.x
	if Input.is_action_pressed("ui_up") :
		if leg.is_colliding() :
			target += jump_speed*planet_normal
		direction -= aim.z
		var Y = planet_normal
		var bb = direction.bounce(Y)
		var truc = bb + direction
		truc = truc.normalized()
		var trans = transform.looking_at(-truc+transform.origin, planet_normal)
		trans.basis.y = planet_normal	
		transform = transform.interpolate_with(trans.orthonormalized(), 10*delta).orthonormalized()
		head.transform = head.transform.interpolate_with(get_node("walk_goal").transform, velxy.length()*delta).orthonormalized()
		animate("Walk", velxy.length()/speed)
	if Input.is_action_pressed("ui_down") :
		direction += aim.z
	if is_on_floor() :
		if Input.is_action_pressed("jump") :
			target += jump_speed*planet_normal
			animate("Jump")
		elif velxy.length() < 0.001 :
			animate("Idle")
	direction = direction.normalized()
	target.x = direction.x*speed
	target.z = direction.z*speed
	target.y += velocity.y
	target += weight*planet_normal

	velocity = velocity.linear_interpolate(target, acceleration*delta)
	velocity = move_and_slide(velocity,planet_normal)
	
	if velxy.length_squared() < 1:
		head.transform = head.transform.interpolate_with(get_node("walk_goal").transform, delta)
		var bb = -aim.z.bounce(planet_normal)
		var truc = bb - aim.z	
		truc = truc.normalized()
		var trans = transform.looking_at(-truc+transform.origin, planet_normal)
		trans.basis.y = planet_normal
		transform = transform.interpolate_with(trans.orthonormalized(), delta).orthonormalized()

func fly(delta):
	animate("Fly")
	direction = Vector3()
	aim = fly_camera.get_global_transform().basis
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
	move_and_slide(velocity)
	if broom_in :
		broom.set_transform(transform)

func animate(value, speed = 1.0):
	if animation_player.is_playing() && animation_player.get_assigned_animation() == value :
		animation_player.set_speed_scale(speed)
	else :
		animation_player.play(value)
		print("Play "+value)

func mouse(event):
	if  STATE == "WALK" :
		var bas = head.transform.basis
		var angle = event.relative.x / 200
		var to = head.transform.origin
		bas = bas.rotated(Vector3(0,1,0), angle)
		to = to.rotated(Vector3(0,1,0), angle)
		head.transform.origin = to
		head.transform.basis = bas.orthonormalized()
	elif STATE == "FLY" :
		var bas = transform.basis
		bas = bas.rotated(bas.x, event.relative.y / 200)
		bas = bas.rotated(bas.y, -event.relative.x / 200)
		transform.basis = bas.orthonormalized()
	elif STATE == "QUERY" :
		var normal = camera.project_ray_normal(event.position).normalized()
		var origin = camera.project_ray_origin(event.position)
		var position = camera.project_position(event.position)
		var newtrans = Transform.IDENTITY
		var oth_normal = (position - origin).normalized()
		
		newtrans.origin = origin
		
		query_ray.set_global_transform(newtrans.orthonormalized())
		query_ray.set_cast_to((oth_normal) * 100)

func add_spell_left(Spell):
	add_spell(Spell,0,get_node("left_hand"))

func add_spell_right(Spell):
	add_spell(Spell, 1, get_node("right_hand"))

func add_spell(Spell, idx, parent_node) :
	spells[idx] = Spell
	print(str(idx) + "|" + str(spells))
	var spell = Spell.instance()
	parent_node.add_child(spell)
	spell.scale = spell.inventory_scale
	spell.transform.origin = spell.inventory_offset
	spell.visible = false
	spell.spell_velocity = 0
	spell.STATE = "INERT"
	spell.pause()

func remove_spell(idx):
	spells.remove(idx)

func spawn_spell(idx):
	if spells.has(idx):
		print("spawn"+str(idx))
		var spell = spells[idx].instance() as Spell
		yield(get_tree().create_timer(spell.cast_time), "timeout")
		emit_signal("spell_cast", spell)
	else :
		print("no spell")

func key(event):
	if event.pressed : 
		if event.scancode == KEY_A :
			if STATE == "WALK" :
				spawn_spell(0)
		if event.scancode == KEY_E :
			if STATE == "WALK" :
				spawn_spell(1)
		if event.scancode == KEY_R :
			if STATE == "FLY" :
				STATE = "WALK"
				set_camera(walk_camera)
				set_g()
			elif broom_in && STATE == "WALK" :
				STATE = "FLY"
				set_camera(fly_camera)
				g = 0
				weight = 0
		elif event.scancode == KEY_F :
			if book != null :
				if STATE == "WALK" :
					STATE = "BOOK"
					set_camera(book.camera)
				elif STATE == "BOOK" :
					STATE = "WALK"
					set_camera(walk_camera)
			elif pnj != null :
				if STATE == "WALK" :
					STATE = "BOOK"
					set_camera(pnj.camera)
					pnj.begin_talk()
					emit_signal("talking", pnj)
				elif STATE == "BOOK" :
					STATE = "WALK"
					set_camera(walk_camera)
					emit_signal("talking", null)
			elif query != null :
				if STATE == "WALK" :
					STATE = "QUERY"
					set_camera(query.camera)	
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					query_ray.enabled = true
					spotlight.light_energy = 1
				else :
					STATE = "WALK"
					set_camera(walk_camera)
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					query_ray.enabled = false
					spotlight.light_energy = 0
		elif event.scancode == KEY_V :
			if STATE == "WALK" :
				STATE = "CHANGING"
				hud.show()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				set_camera(changing_camera)
				animate("Inventory_Spell")
				visible_hand_spells(true)
			elif STATE == "CHANGING" :
				STATE = "WALK"
				hud.hide()
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				set_camera(walk_camera)
				animate("Idle")
				visible_hand_spells(false)

func visible_hand_spells(value) :
	for hand in [get_node("left_hand"),get_node("right_hand")] :
		for child in hand.get_children():
			child.visible = value

func _input(event):
	if !paused && camera.current :
		if event is InputEventMouseMotion:
			mouse(event)
		elif event is InputEventKey :
			key(event) 
		elif event is InputEventMouseButton :	
			var direction_to_player = head.to_local(transform.origin)
			direction_to_player = direction_to_player.normalized()
			direction_to_player *= event.factor / 2	
			var offset = Vector3()
			if event.button_index == BUTTON_WHEEL_DOWN :
				offset = -direction_to_player
			elif event.button_index == BUTTON_WHEEL_UP :
				offset = direction_to_player
			var newtrans = head.transform.translated(offset)
			var new_trans_len = clamp( newtrans.origin.length(), min_head_dist, max_head_dist )
			var t = (max_head_dist - new_trans_len)/(max_head_dist - min_head_dist)
			head.transform = head.transform.interpolate_with ( newtrans, -3*t*(t-1) )

func _on_Area_body_entered(body):
	if body.get_parent()._class == "broom" :
		broom_in = true
		broom = body.get_parent()
	elif body.get_parent()._class == "book" :
		book = body.get_parent()
	elif body.get_parent()._class == "pnj" :
		pnj = body.get_parent()
	elif body.get_parent()._class == "query" :
		query = body.get_parent()

func _on_Area_body_exited(body):
	if body.get_parent()._class == "broom" :
		broom_in = false
		broom = null
	elif body.get_parent()._class == "book" :
		book = null
	elif body.get_parent()._class == "pnj" :
		pnj = null
	elif body.get_parent()._class == "query" :
		query = null