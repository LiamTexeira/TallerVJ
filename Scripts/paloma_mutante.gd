extends CharacterBody2D

# estados
enum Estado { PATRULLA, PERSECUCION, ATAQUE, HERIDO, MUERTE }
var estado_actual: Estado = Estado.PATRULLA

# vida
@export var vida_maxima: int = 3
var vida_actual: int

# movimiento
@export var velocidad_patrulla: float = 30.0
@export var velocidad_persecucion: float = 50.0
@export var distancia_ataque: float = 20.0

#Empanada
@export var empanada_scene: PackedScene
@export_range(0.0, 1.0) var probabilidad_drop: float = 0.4 # 40% de probabilidad de caer


var objetivo_jugador: Node2D = null
var ya_hizo_dano_en_este_ataque: bool = false

# nodos
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_dano: Area2D = $AreaDano
@onready var area_dano_collision: CollisionShape2D = $AreaDano/CollisionShape2D

# patrulla
var direccion_patrulla: Vector2 = Vector2.ZERO
var tiempo_cambio_patrulla: float = 0.0

# escape de obstaculos
var punto_escape: Vector2 = Vector2.ZERO
var buscando_escape: bool = false
var posicion_anterior: Vector2 = Vector2.ZERO
var tiempo_atascado: float = 0.0




func _ready() -> void:
	vida_actual = vida_maxima
	add_to_group("Enemigos") # para detectarse entre ellas
	
	if distancia_ataque <= 0:
		distancia_ataque = 20.0
		
	_desactivar_dano()
	_elegir_nueva_direccion_patrulla()
	
	if sprite and not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	match estado_actual:
		Estado.PATRULLA:
			_logica_patrulla(delta)
		Estado.PERSECUCION:
			_logica_persecucion(delta)
		Estado.ATAQUE:
			_logica_ataque(delta)
		Estado.HERIDO, Estado.MUERTE:
			velocity = Vector2.ZERO

	move_and_slide()
	_actualizar_animacion()


func _actualizar_animacion() -> void:
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	elif objetivo_jugador and (estado_actual == Estado.ATAQUE or estado_actual == Estado.HERIDO):
		sprite.flip_h = (objetivo_jugador.global_position.x - global_position.x) < 0

	match estado_actual:
		Estado.PATRULLA:
			sprite.play("walk" if velocity != Vector2.ZERO else "idle")
		Estado.PERSECUCION:
			sprite.play("walk")
		Estado.ATAQUE:
			sprite.play("attack")
		Estado.HERIDO:
			sprite.play("hurt")
		Estado.MUERTE:
			sprite.play("death")


func _logica_patrulla(delta: float) -> void:
	tiempo_cambio_patrulla -= delta
	if tiempo_cambio_patrulla <= 0:
		_elegir_nueva_direccion_patrulla()

	# se juntan un poco si hay otras cerca
	var fuerza_bandada = _calcular_fuerza_bandada()
	var direccion_final = (direccion_patrulla + fuerza_bandada).normalized()

	velocity = direccion_final * velocidad_patrulla


func _calcular_fuerza_bandada() -> Vector2:
	var centro_grupo = Vector2.ZERO
	var palomas_cercanas = 0
	var radio_cohesion = 120.0

	# busca otras palomas en patrulla
	for enemigo in get_tree().get_nodes_in_group("Enemigos"):
		if enemigo != self and is_instance_valid(enemigo):
			var dist = global_position.distance_to(enemigo.global_position)
			if dist < radio_cohesion:
				centro_grupo += enemigo.global_position
				palomas_cercanas += 1

	if palomas_cercanas > 0:
		centro_grupo /= palomas_cercanas
		return (centro_grupo - global_position).normalized() * 0.4

	return Vector2.ZERO


func _elegir_nueva_direccion_patrulla() -> void:
	if randf() > 0.3:
		direccion_patrulla = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	else:
		direccion_patrulla = Vector2.ZERO
		
	tiempo_cambio_patrulla = randf_range(1.5, 3.5)


func _logica_persecucion(delta: float) -> void:
	if not objetivo_jugador:
		return
		
	var distancia = global_position.distance_to(objetivo_jugador.global_position)
	
	if distancia <= distancia_ataque:
		_iniciar_ataque()
		buscando_escape = false
		return

	# revisa si se trabo
	if global_position.distance_to(posicion_anterior) < 0.5:
		tiempo_atascado += delta
	else:
		tiempo_atascado = 0.0

	posicion_anterior = global_position

	# saca punto a un costado si se traba
	if tiempo_atascado >= 0.15:
		tiempo_atascado = 0.0
		buscando_escape = true
		
		var direccion_directa = (objetivo_jugador.global_position - global_position).normalized()
		var lado = -1.0 if randf() > 0.5 else 1.0
		var perpendicular = Vector2(-direccion_directa.y, direccion_directa.x) * lado
		
		punto_escape = global_position + (direccion_directa * 20.0) + (perpendicular * 60.0)

	var destino_actual: Vector2
	
	if buscando_escape:
		destino_actual = punto_escape
		if global_position.distance_to(punto_escape) < 10.0:
			buscando_escape = false
	else:
		destino_actual = objetivo_jugador.global_position

	var direccion = (destino_actual - global_position).normalized()
	velocity = direccion * velocidad_persecucion


func _iniciar_ataque() -> void:
	estado_actual = Estado.ATAQUE
	ya_hizo_dano_en_este_ataque = false
	
	if area_dano_collision:
		area_dano_collision.set_deferred("disabled", false)


func _logica_ataque(_delta: float) -> void:
	velocity = Vector2.ZERO
	
	if objetivo_jugador:
		var distancia = global_position.distance_to(objetivo_jugador.global_position)
		if distancia > distancia_ataque + 15.0:
			_desactivar_dano()
			estado_actual = Estado.PERSECUCION


func _aplicar_dano_a_cuerpo(body: Node2D) -> void:
	if ya_hizo_dano_en_este_ataque:
		return

	if estado_actual == Estado.ATAQUE and body.is_in_group("Player") and body.has_method("recibir_danio"):
		body.recibir_danio(1)
		ya_hizo_dano_en_este_ataque = true


func recibir_danio(cantidad: int) -> void:
	if estado_actual == Estado.MUERTE:
		return
		
	_desactivar_dano()
	vida_actual -= cantidad
	
	if vida_actual <= 0:
		estado_actual = Estado.MUERTE
	else:
		estado_actual = Estado.HERIDO


func _desactivar_dano() -> void:
	if area_dano_collision:
		area_dano_collision.set_deferred("disabled", true)


func _on_animation_finished() -> void:
	match sprite.animation:
		"attack":
			_desactivar_dano()
			if objetivo_jugador:
				estado_actual = Estado.PERSECUCION
			else:
				estado_actual = Estado.PATRULLA
		"hurt":
			if objetivo_jugador:
				estado_actual = Estado.PERSECUCION
			else:
				estado_actual = Estado.PATRULLA
		"death":
			morir() # <-- Llamamos a morir() para procesar el drop antes del queue_free



func morir() -> void:
	print("--- ENEMIGO MUERTO (Diagnóstico) ---")
	print("Escena actual: ", get_tree().current_scene)
	
	var wave_mgr = get_tree().current_scene.find_child("WaveManager", true, false)
	print("¿Encontró WaveManager con find_child?: ", wave_mgr)
	
	if wave_mgr and wave_mgr.has_method("registrar_enemigo_derrotado"):
		wave_mgr.registrar_enemigo_derrotado()
		print("¡Éxito! Baja registrada.")
	else:
		print("FALLÓ: El WaveManager no existe en esta escena o no tiene el método.")

	_intentar_drop()
	queue_free()

func _intentar_drop() -> void:
	if not empanada_scene:
		print("OJO: No hay empanada_scene asignada en el Inspector de la Paloma")
		return

	var numero_azar := randf()
	if numero_azar <= probabilidad_drop:
		var empanada = empanada_scene.instantiate()
		empanada.global_position = global_position
		
		# Agregamos al nivel para que persista
		get_parent().add_child(empanada)
		print("¡Empanada soltada con éxito en la posición: ", global_position)
	else:
		print("Mala suerte, esta paloma no soltó empanada (roll: ", numero_azar, ")")


func _on_zona_deteccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		objetivo_jugador = body
		if estado_actual != Estado.HERIDO and estado_actual != Estado.MUERTE:
			estado_actual = Estado.PERSECUCION


func _on_zona_deteccion_body_exited(_body: Node2D) -> void:
	# persigue para siempre
	pass


func _on_area_dano_body_entered(body: Node2D) -> void:
	_aplicar_dano_a_cuerpo(body)
	
	
	
	
	
