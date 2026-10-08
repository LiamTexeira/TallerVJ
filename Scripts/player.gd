extends CharacterBody2D

const SPEED := 100.0
const DASH_SPEED := 300.0
const DASH_TIME := 0.15
const DASH_COOLDOWN := 0.5
const ATTACK_TIME := 0.3
const ALCANCE_ATAQUE := 16.0 # Distancia a la que se desplaza la hitbox desde el centro

var is_dashing := false
var is_attacking := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var attack_timer := 0.0
var dash_direction := Vector2.ZERO
var facing := Vector2.DOWN


# --- VARIABLES DE VIDA E INVULNERABILIDAD ---
@export var vida_maxima: int = 100
var vida_actual: int

const TIEMPO_INVULNERABLE := 0.8 # Segundos de proteccion tras ser golpeado
var invulnerable_timer := 0.0
var is_invulnerable := false

# Referencias a los nodos de ataque y animación
@onready var sprite = $RoguelikeCharTransparent
@onready var area_ataque: Area2D = $AreaAtaque
@onready var collision_ataque: CollisionShape2D = $AreaAtaque/CollisionShape2D


func _ready() -> void:
	vida_actual = RunManager.vida_actual # Sincronizar vida inicial con el RunManager
	
	# Aseguramos que el hitbox comience desactivado
	if collision_ataque:
		collision_ataque.disabled = true


func _unhandled_input(event: InputEvent) -> void:
	# Verificamos si se presiono la tecla y evitamos que se repita si queda apretada
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		tomar_mate()


func _physics_process(delta: float) -> void:
	dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)
	
	# Reducir tiempo de invulnerabilidad
	if is_invulnerable:
		invulnerable_timer -= delta
		# Parpadeo visual mientras es invulnerable
		sprite.modulate.a = 0.5 if fmod(invulnerable_timer, 0.2) > 0.1 else 1.0
		
		if invulnerable_timer <= 0.0:
			is_invulnerable = false
			sprite.modulate.a = 1.0 # Restablece la opacidad normal

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
		velocity = Vector2.ZERO # Quieto mientras ataca
		if attack_timer <= 0.0:
			is_attacking = false
			collision_ataque.disabled = true # Desactivamos el hitbox al finalizar el ataque
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
	# Si esta quieto, dashea hacia donde mirabas
	dash_direction = input_dir.normalized() if input_dir != Vector2.ZERO else facing


func start_attack() -> void:
	is_attacking = true
	attack_timer = ATTACK_TIME
	
	# Posicionamos el Area2D en frente del jugador según la dirección 'facing'
	area_ataque.position = facing * ALCANCE_ATAQUE
	
	# Activamos la colision de ataque
	collision_ataque.disabled = false
	
	if sprite and sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")


func _actualizar_animacion(input_dir: Vector2) -> void:
	if not sprite:
		return
		
	# Volteamos el sprite en X segun hacia donde camine o mire
	if facing.x != 0:
		sprite.flip_h = facing.x < 0

	if is_attacking:
		return # Mantiene la animacion "attack" activada en start_attack()
		
	if velocity != Vector2.ZERO:
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
	else:
		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")


# SEÑAL CONECTADA DESDE AreaAtaque
func _on_area_ataque_body_entered(body: Node2D) -> void:
	# Si choca con un nodo que tenga la función recibir_danio (como la paloma_mutante)
	if body.has_method("recibir_danio"):
		body.recibir_danio(1)


# FUNCIÓN PARA RECIBIR DAÑO
func recibir_danio(cantidad: int) -> void:
	if is_invulnerable:
		return
		
	RunManager.recibir_danio(cantidad)
	vida_actual = RunManager.vida_actual
	print("¡Jugador golpeado! Vida restante: ", vida_actual)
	
	if vida_actual <= 0:
		morir()
	else:
		# Activar invulnerabilidad temporal
		is_invulnerable = true
		invulnerable_timer = TIEMPO_INVULNERABLE


# FUNCIÓN PARA TOMAR MATE Y APLICAR MECÁNICAS DE TEMPERATURA
func tomar_mate() -> void:
	print("\n--- CEBANDO MATE ---")
	print("Temperatura elegida en El Calentador: ", RunManager.temperatura_actual, "°C")
	
	# Aplicar daño por quemadura si elegiste 120°C (sin curación)
	if RunManager.dano_quemadura_por_sorbo > 0:
		recibir_danio(RunManager.dano_quemadura_por_sorbo)
		print("¡Te quemaste la boca al cebar a ", RunManager.temperatura_actual, "°C! Daño sufrido: ", RunManager.dano_quemadura_por_sorbo)
	else:
		print("Mate cebado sin quemaduras. Buff multiplicador: x", RunManager.multiplicador_buff_yerba)


func morir() -> void:
	print("El jugador ha muerto")
	set_physics_process(false)
	visible = false
