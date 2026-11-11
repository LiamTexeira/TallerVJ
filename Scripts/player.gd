extends CharacterBody2D
const TERMO_SCENE := preload("res://termo.tscn")
const MATE_SCENE := preload("res://mate.tscn")

signal vida_cambiada(vida_actual, vida_maxima)
signal jugador_muerto

const SPEED := 100.0
const DASH_SPEED := 300.0
const DASH_TIME := 0.15
const DASH_COOLDOWN := 0.5
const ATTACK_TIME := 0.3
const ALCANCE_ATAQUE := 16.0 # Distancia a la que se desplaza la hitbox desde el centro

const STAMINA_MAX := 100.0
const STAMINA_REGEN := 15.0  # por segundo

# --- YERBAS ---
const YERBA_CLASICA_CURACION := 15
const YUYOS_DURACION := 30.0
const YUYOS_CURA_POR_TICK := 1          # 1 de vida por segundo, 30 en total
const DESPALADA_DURACION := 10.0
const DESPALADA_MULT_DANIO := 2.0
const DESPALADA_MULT_VELOCIDAD := 1.5

var mult_danio := 1.0
var mult_velocidad := 1.0
var timer_yuyos: Timer
var timer_tick_yuyos: Timer
var timer_despalada: Timer

var current_weapon: Weapon
var stamina := 100.0

var is_dashing := false
var is_attacking := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var attack_timer := 0.0
var dash_direction := Vector2.ZERO
var facing := Vector2.DOWN
var side := 1  # 1 = derecha, -1 = izquierda

@onready var weapon_holder: Marker2D = $WeaponHolder

# --- VARIABLES DE VIDA E INVULNERABILIDAD ---
@export var vida_maxima: int = 100
var vida_actual: int
var esta_muerto := false

const TIEMPO_INVULNERABLE := 0.8 # Segundos de proteccion tras ser golpeado
var invulnerable_timer := 0.0
var is_invulnerable := false

# Referencias a los nodos de ataque y animación
@onready var sprite = $RoguelikeCharTransparent
@onready var area_ataque: Area2D = $AreaAtaque
@onready var collision_ataque: CollisionShape2D = $AreaAtaque/CollisionShape2D


func _ready() -> void:
	vida_actual = RunManager.vida_actual # Sincronizar vida inicial con el RunManager
	emit_signal("vida_cambiada", vida_actual, vida_maxima) # Notifica vida inicial
	equip_weapon(TERMO_SCENE)  # arma inicial
	_crear_timers_yerba()
	
	# Aseguramos que el hitbox comience desactivado
	if collision_ataque:
		collision_ataque.disabled = true
		
	# Sincronizamos el HUD de entrada
	_notificar_hud_temperatura()


func _unhandled_input(event: InputEvent) -> void:
	# Cebar mate con la tecla E (antes estaba en la barra espaciadora, que ahora es el dash)
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		tomar_mate()

	if event.is_action_pressed("weapon_1"):
		equip_weapon(MATE_SCENE)
	elif event.is_action_pressed("weapon_2"):
		equip_weapon(TERMO_SCENE)
		
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
			RunManager.dano_quemadura_por_sorbo = 1 # O el daño por quemadura que prefieras
			
	_notificar_hud_temperatura()


func _notificar_hud_temperatura() -> void:
	var texto_hud := "Temp: %d°C | Buff Yerba: x%.2f" % [RunManager.temperatura_actual, RunManager.multiplicador_buff_yerba]
	
	if has_node("/root/HUD"):
		get_node("/root/HUD").actualizar_temperatura_label(texto_hud)
	elif has_node("/root/Hud"):
		get_node("/root/Hud").actualizar_temperatura_label(texto_hud)


func _physics_process(delta: float) -> void:
	dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)
	stamina = min(stamina + STAMINA_REGEN * delta, STAMINA_MAX)

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
	if input_dir != Vector2.ZERO and not is_attacking:
		facing = input_dir.normalized()
		if input_dir.x != 0.0:
			side = 1 if input_dir.x > 0.0 else -1

	# Fuera del ataque, el arma solo mira como el personaje
	if not is_attacking:
		weapon_holder.rotation = facing.angle()
		weapon_holder.scale = Vector2(1.0, -1.0 if facing.x < 0.0 else 1.0)
 
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * DASH_SPEED * mult_velocidad
		if dash_timer <= 0.0:
			is_dashing = false
	elif is_attacking:
		velocity = Vector2.ZERO # Quieto mientras ataca

	else:
		var speed_actual: float = SPEED * RunManager.multiplicador_buff_yerba * mult_velocidad
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
	# Si esta quieto, dashea hacia donde mirabas
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

	# Durante el ataque, el arma apunta hacia donde venías caminando (8 direcciones)
	weapon_holder.rotation = facing.angle()
	weapon_holder.scale = Vector2(1.0, -1.0 if facing.x < 0.0 else 1.0)

	# Evita el error de "ya está conectada"
	if not current_weapon.attack_finished.is_connected(_on_attack_finished):
		current_weapon.attack_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)

	current_weapon.mult_danio = mult_danio
	current_weapon.do_attack()
	## Red de seguridad por si el arma nunca avisa (solo afecta a este mismo arma)
	var arma := current_weapon
	get_tree().create_timer(1.5).timeout.connect(func():
		if arma == current_weapon and is_attacking:
			is_attacking = false
	)


func _on_attack_finished() -> void:
	is_attacking = false

func _actualizar_animacion(input_dir: Vector2) -> void:
	if not sprite:
		return
		
	# Volteamos el sprite en X segun hacia donde camine o mire
	#if facing.x != 0:
	#	sprite.flip_h = facing.x < 0
	sprite.flip_h = false  # ya hay animaciones para izquierda y derecha
	
	
	if is_attacking:
		return # Mantiene la animacion "attack" activada en start_attack()
	
	# Elige la dirección según el eje dominante de hacia dónde mirás
	var dir := "s"
	if abs(facing.x) > abs(facing.y):
		dir = "e" if facing.x > 0.0 else "o"
	else:
		dir = "n" if facing.y < 0.0 else "s"

	var nombre := "walk3_" + dir
	if not sprite.sprite_frames.has_animation(nombre):
		return

	if velocity != Vector2.ZERO:
		sprite.play(nombre)
	else:
		# Quieto: se queda en el primer frame mirando hacia donde iba
		sprite.animation = nombre
		sprite.stop()
		sprite.frame = 0


# SEÑAL CONECTADA DESDE AreaAtaque
func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body.has_method("recibir_danio"):
		body.recibir_danio(1)


# FUNCIÓN PARA RECIBIR DAÑO
func recibir_danio(cantidad: int) -> void:
	if is_invulnerable or esta_muerto:
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
		RunManager.vida_actual = vida_actual  # sincroniza, si no se pierde la curación
		print("Jugador curado. Vida actual: ", vida_actual)
		emit_signal("vida_cambiada", vida_actual, vida_maxima)

func morir() -> void:
	if esta_muerto:
		return
	esta_muerto = true
	timer_yuyos.stop()
	timer_tick_yuyos.stop()
	timer_despalada.stop()
	print("El jugador ha muerto")
	emit_signal("jugador_muerto")
	set_physics_process(false)
	visible = false
	
	var pantalla_over = load("res://escenas/game_over.tscn").instantiate()
	get_tree().current_scene.add_child(pantalla_over)
	
	
func _crear_timers_yerba() -> void:
	timer_yuyos = _crear_timer(YUYOS_DURACION, true, _fin_yuyos)
	timer_tick_yuyos = _crear_timer(1.0, false, _tick_yuyos)
	timer_despalada = _crear_timer(DESPALADA_DURACION, true, _fin_despalada)


func _crear_timer(tiempo: float, una_vez: bool, callback: Callable) -> Timer:
	var t := Timer.new()
	t.wait_time = tiempo
	t.one_shot = una_vez
	t.timeout.connect(callback)
	add_child(t)
	return t


# Devuelve true si la yerba se consumió
func aplicar_yerba(tipo: int) -> bool:
	if esta_muerto:
		return false
	match tipo:
		YerbaDrop.Tipo.CLASICA:
			if vida_actual >= vida_maxima:
				return false              # no se gasta con la vida llena
			curar(YERBA_CLASICA_CURACION)
		YerbaDrop.Tipo.YUYOS:
			timer_yuyos.start()           # si ya estaba activa, reinicia los 30 s
			timer_tick_yuyos.start()
		YerbaDrop.Tipo.DESPALADA:
			mult_danio = DESPALADA_MULT_DANIO
			mult_velocidad = DESPALADA_MULT_VELOCIDAD
			sprite.self_modulate = Color(1.3, 0.8, 0.6)   # se nota el buff
			timer_despalada.start()
	return true


func _tick_yuyos() -> void:
	if not esta_muerto:
		curar(YUYOS_CURA_POR_TICK)


func _fin_yuyos() -> void:
	timer_tick_yuyos.stop()


func _fin_despalada() -> void:
	mult_danio = 1.0
	mult_velocidad = 1.0
	sprite.self_modulate = Color.WHITE
