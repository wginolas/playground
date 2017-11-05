extends KinematicBody2D

const ACCEL = 1500
const MAX_SPEED = 500
const FRICTION = -500
const GRAVITY = 2000
const JUMP_SPEED = -1000
const MIN_JUMP = -300

onready var ground_ray = get_node("ground_ray")
onready var sprite = get_node("sprite")
var acc = Vector2()
var vel = Vector2()

func _ready():
	set_fixed_process(true)
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_up") and ground_ray.is_colliding():
		vel.y = JUMP_SPEED
	if event.is_action_released("ui_up"):
		vel.y = clamp(vel.y, MIN_JUMP, vel.y)

func _fixed_process(delta):
	# movement
	acc.y = GRAVITY
	acc.x = Input.is_action_pressed("ui_right") - Input.is_action_pressed("ui_left")
	acc.x *= ACCEL
	if acc.x == 0:
		acc.x = vel.x * FRICTION * delta
	
	vel += acc * delta
	vel.x = clamp(vel.x, -MAX_SPEED, MAX_SPEED)
	
	var motion = move(vel * delta)
	if is_colliding():
		var n = get_collision_normal()
		motion = n.slide(motion)
		vel = n.slide(vel)
		move(motion)
		
	# animation
	if vel.x < 0:
		sprite.set_flip_h(true)
	if vel.x > 0:
		sprite.set_flip_h(false)
	
	if ground_ray.is_colliding():
		if abs(vel.x) < 10:
			sprite.set_animation("idle")
		else:
			sprite.set_animation("running")
	else:
		if vel.y < 0:
			sprite.set_animation("jump_up")
		else:
			sprite.set_animation("jump_down")
