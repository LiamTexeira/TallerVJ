extends CharacterBody2D

const SPEED := 100.0
const DASH_SPEED := 300.0
const DASH_TIME := 0.15
const DASH_COOLDOWN := 0.5
const ATTACK_TIME := 0.3

var is_dashing := false
var is_attacking := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var attack_timer := 0.0
var dash_direction := Vector2.ZERO
var facing := Vector2.DOWN


func _physics_process(delta: float) -> void:
	dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)

	# Flechas + WASD (ya mapeados). get_vector normaliza la diagonal.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		facing = input_dir.normalized()

	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * DASH_SPEED
		if dash_timer <= 0.0:
			is_dashing = false
	elif is_attacking:
		attack_timer -= delta
		velocity = Vector2.ZERO  # quieto mientras ataca
		if attack_timer <= 0.0:
			is_attacking = false
	else:
		velocity = input_dir * SPEED

		if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0:
			start_dash(input_dir)
		elif Input.is_action_just_pressed("attack"):
			start_attack()

	move_and_slide()


func start_dash(input_dir: Vector2) -> void:
	is_dashing = true
	dash_timer = DASH_TIME
	dash_cooldown_timer = DASH_COOLDOWN
	# Si no estás apretando dirección, dashea hacia donde mirabas
	dash_direction = input_dir.normalized() if input_dir != Vector2.ZERO else facing


func start_attack() -> void:
	is_attacking = true
	attack_timer = ATTACK_TIME
	# Acá disparás la animación / activás el hitbox
	print("Ataque hacia ", facing)
