extends CharacterBody2D

const TERMO_SCENE := preload("res://termo.tscn")
const MATE_SCENE := preload("res://mate.tscn")

signal vida_cambiada(vida_actual, vida_maxima)
signal jugador_muerto

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
@onready var weapon_holder: Marker2D = $WeaponHolder


func _ready() -> void:
	vida_actual = RunManager.vida_actual # Sincronizar vida inicial con el RunManager
	emit_signal("vida_cambiada", vida_actual, vida_maxima) # Notifica vida inicial
	
	# Aseguramos que el hitbox comience desactivado
	if collision_ataque:
		collision_ataque.disabled = true
		
	# Sincronizamos el HUD de entrada
	_notificar_hud_temperatura()
	
	# Arma inicial de tu compañero
	equip_weapon(TERMO_SCENE)


func _unhandled_input(event: InputEvent) -> void:
	# Verificamos si se presiono la tecla y evitamos que se repita si queda apretada
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		tomar_mate()
		
	# Teclas 1, 2 y 3 para cambiar la temperatura en tiempo real
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				cambiar_temperatura(80)
			KEY_2:
				cambiar_temperatura(100)
			KEY_3:
				cambiar_temperatura(120)


func cambiar_temperatura(temp: int) -> void:
	RunManager.temperatura_actual = temp
	
	match temp:
		80:
			RunManager.multiplicador_buff_yerba = 1.00
			RunManager.dano_quemadura_por_sorbo = 0
		100:
			RunManager.multiplicador_buff_yerba = 1.50
			RunManager.dano_quemadura_por_sorbo = 0
		120:
			RunManager.multiplicador_buff_yerba = 2.00
			RunManager.dano_quemadura_por_sorbo = 1
			
	_notificar_hud_temperatura()


func _notificar_hud_temperatura() -> void:
	var texto_hud := "Temp: %d°C | Buff Yerba: x%.2f" % [RunManager.temperatura_actual, RunManager.multiplicador_buff_yerba]
	
	if has_node("/root/HUD"):
		get_node("/root/HUD").actualizar_temperatura_label(texto_hud)
	elif has_node("/root/Hud"):
		get_node("/root/Hud").actualizar_temperatura_label(texto_hud)


func _physics_process(delta: float) -> void:
	dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)
	
	if is_invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0.0:
			is_invulnerable = false

	# Flechas + WASD
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
		var speed_actual: float = SPEED * RunManager.multiplicador_buff_yerba
		velocity = input_dir * speed_actual

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0:
		start_dash(input_dir)
	elif Input.is_action_just_pressed("attack"):
		start_attack()

	move_and_slide()
	_actualizar_animacion(input_dir)


func _process(_delta: float) -> void:
	# tecla rapida para probar la muerte instantanea
	if Input.is_key_pressed(KEY_N):
		morir()


func start_dash(input_dir: Vector2) -> void:
	is_dashing = true
	dash_timer = DASH_TIME
	dash_cooldown_timer = DASH_COOLDOWN
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
	
	if sprite and sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")


func _actualizar_animacion(_input_dir: Vector2) -> void:
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


# SEÑAL CONECTADA DESDE AreaAtaque
func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body.has_method("recibir_danio"):
		body.recibir_danio(1)


# FUNCIÓN PARA RECIBIR DAÑO
func recibir_danio(cantidad: int) -> void:
	if is_invulnerable:
		return
		
	RunManager.recibir_danio(cantidad)
	vida_actual = RunManager.vida_actual
	emit_signal("vida_cambiada", vida_actual, vida_maxima)
	print("¡Jugador golpeado! Vida restante: ", vida_actual)
	
	if vida_actual <= 0:
		morir()
	else:
		is_invulnerable = true
		invulnerable_timer = TIEMPO_INVULNERABLE


# FUNCIÓN PARA TOMAR MATE Y APLICAR MECÁNICAS DE TEMPERATURA
func tomar_mate() -> void:
	print("\n--- CEBANDO MATE ---")
	print("Temperatura elegida en El Calentador: ", RunManager.temperatura_actual, "°C")
	
	if RunManager.dano_quemadura_por_sorbo > 0:
		recibir_danio(RunManager.dano_quemadura_por_sorbo)
		print("¡Te quemaste la boca al cebar a ", RunManager.temperatura_actual, "°C! Daño sufrido: ", RunManager.dano_quemadura_por_sorbo)
	else:
		print("Mate cebado sin quemaduras. Buff multiplicador: x", RunManager.multiplicador_buff_yerba)


func curar(cantidad: int) -> void:
	if vida_actual < vida_maxima:
		vida_actual = min(vida_actual + cantidad, vida_maxima)
		print("Jugador curado. Vida actual: ", vida_actual)
		
		if has_signal("vida_cambiada"):
			emit_signal("vida_cambiada", vida_actual, vida_maxima)


func morir() -> void:
	print("El jugador ha muerto")
	emit_signal("jugador_muerto")
	set_physics_process(false)
	visible = false
	
	var pantalla_over = load("res://escenas/game_over.tscn").instantiate()
	get_tree().current_scene.add_child(pantalla_over)