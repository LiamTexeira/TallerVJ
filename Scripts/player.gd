extends CharacterBody2D
const TERMO_SCENE := preload("res://termo.tscn")
const MATE_SCENE := preload("res://mate.tscn")

const SPEED := 100.0
const DASH_SPEED := 300.0
const DASH_TIME := 0.15
const DASH_COOLDOWN := 0.5

var current_weapon: Weapon
var stamina := 100.0

var is_dashing := false
var is_attacking := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := Vector2.ZERO
var facing := Vector2.DOWN

@onready var weapon_holder: Marker2D = $WeaponHolder

func _ready() -> void:
	equip_weapon(TERMO_SCENE)  # arma inicial

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
		velocity = Vector2.ZERO  # quieto mientras ataca
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


func equip_weapon(weapon_scene: PackedScene) -> void:
	if current_weapon:
		current_weapon.queue_free()
	current_weapon = weapon_scene.instantiate()
	weapon_holder.add_child(current_weapon)

func start_attack() -> void:
	if not current_weapon or is_attacking:
		return
	if stamina < current_weapon.stamina_cost:
		return  # no hay estamina suficiente
	stamina -= current_weapon.stamina_cost
	is_attacking = true
	current_weapon.do_attack()
	current_weapon.attack_finished.connect(func(): is_attacking = false, CONNECT_ONE_SHOT)
