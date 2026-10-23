extends CharacterBody2D

const TERMO_SCENE := preload("res://termo.tscn")
const MATE_SCENE := preload("res://mate.tscn")

const SPEED := 100.0
const DASH_SPEED := 300.0
const DASH_TIME := 0.15
const DASH_COOLDOWN := 0.5

const STAMINA_MAX := 100.0
const STAMINA_REGEN := 15.0  # por segundo

var side := 1  # 1 = derecha, -1 = izquierda

var is_dashing := false
var is_attacking := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := Vector2.ZERO
var facing := Vector2.DOWN

var current_weapon: Weapon
var stamina := STAMINA_MAX

# --- VARIABLES DE VIDA E INVULNERABILIDAD ---
@export var vida_maxima: int = 100
var vida_actual: int

const TIEMPO_INVULNERABLE := 0.8
var invulnerable_timer := 0.0
var is_invulnerable := false

@onready var sprite = $RoguelikeCharTransparent
@onready var weapon_holder: Marker2D = $WeaponHolder


func _ready() -> void:
	add_to_group("player")
	vida_actual = RunManager.vida_actual
	equip_weapon(MATE_SCENE)  # arma inicial


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		tomar_mate()
	# Para probar: 1 = mate, 2 = termo (creá estas acciones en el Mapa de Entrada)
	if event.is_action_pressed("weapon_1"):
		equip_weapon(MATE_SCENE)
	elif event.is_action_pressed("weapon_2"):
		equip_weapon(TERMO_SCENE)


func _physics_process(delta: float) -> void:
	dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)
	stamina = min(stamina + STAMINA_REGEN * delta, STAMINA_MAX)

	if is_invulnerable:
		invulnerable_timer -= delta
		sprite.modulate.a = 0.5 if fmod(invulnerable_timer, 0.2) > 0.1 else 1.0
		if invulnerable_timer <= 0.0:
			is_invulnerable = false
			sprite.modulate.a = 1.0

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO and not is_attacking:
		facing = input_dir.normalized()
		if input_dir.x != 0.0:
			side = 1 if input_dir.x > 0.0 else -1

	# Fuera del ataque, el arma solo mira a izquierda o derecha, como el personaje
	if not is_attacking:
		weapon_holder.rotation = 0.0
		weapon_holder.scale = Vector2(side, 1.0)
		
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * DASH_SPEED
		if dash_timer <= 0.0:
			is_dashing = false
	elif is_attacking:
		velocity = Vector2.ZERO  # el arma avisa cuándo termina
	else:
		velocity = input_dir * SPEED

		if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0:
			start_dash(input_dir)
		elif Input.is_action_just_pressed("attack"):
			start_attack()

	move_and_slide()
	_actualizar_animacion(input_dir)


func start_dash(input_dir: Vector2) -> void:
	is_dashing = true
	dash_timer = DASH_TIME
	dash_cooldown_timer = DASH_COOLDOWN
	dash_direction = input_dir.normalized() if input_dir != Vector2.ZERO else facing


func equip_weapon(weapon_scene: PackedScene) -> void:
	if is_attacking:
		return
	if current_weapon:
		current_weapon.queue_free()
	current_weapon = weapon_scene.instantiate()
	weapon_holder.add_child(current_weapon)


func start_attack() -> void:
	if not current_weapon or is_attacking:
		return
	if stamina < current_weapon.stamina_cost:
		return
	stamina -= current_weapon.stamina_cost
	is_attacking = true
	weapon_holder.rotation = facing.angle()  # el arma apunta hacia donde mirás
	current_weapon.attack_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
	# Durante el ataque, el arma apunta hacia donde venías caminando (8 direcciones)
	weapon_holder.rotation = facing.angle()
	weapon_holder.scale = Vector2(1.0, -1.0 if facing.x < 0.0 else 1.0)
	current_weapon.do_attack()
	# Red de seguridad por si el arma nunca avisa
	get_tree().create_timer(1.5).timeout.connect(func(): is_attacking = false)


func _on_attack_finished() -> void:
	is_attacking = false


func _actualizar_animacion(input_dir: Vector2) -> void:
	if not sprite:
		return
	if facing.x != 0:
		sprite.flip_h = facing.x < 0

	if is_attacking:
		return

	if velocity != Vector2.ZERO:
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
	else:
		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")


func recibir_danio(cantidad: int) -> void:
	if is_invulnerable:
		return
	RunManager.recibir_danio(cantidad)
	vida_actual = RunManager.vida_actual
	print("¡Jugador golpeado! Vida restante: ", vida_actual)
	if vida_actual <= 0:
		morir()
	else:
		is_invulnerable = true
		invulnerable_timer = TIEMPO_INVULNERABLE


func tomar_mate() -> void:
	print("\n--- CEBANDO MATE ---")
	print("Temperatura elegida en El Calentador: ", RunManager.temperatura_actual, "°C")
	if RunManager.dano_quemadura_por_sorbo > 0:
		recibir_danio(RunManager.dano_quemadura_por_sorbo)
		print("¡Te quemaste la boca al cebar a ", RunManager.temperatura_actual, "°C! Daño sufrido: ", RunManager.dano_quemadura_por_sorbo)
	else:
		print("Mate cebado sin quemaduras. Buff multiplicador: x", RunManager.multiplicador_buff_yerba)


func morir() -> void:
	print("El jugador ha muerto")
	set_physics_process(false)
	visible = false
