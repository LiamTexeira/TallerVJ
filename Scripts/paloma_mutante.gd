extends CharacterBody2D

# Estados de la paloma
enum Estado { PATRULLA, PERSECUCION, ATAQUE, HERIDO, MUERTE }
var estado_actual: Estado = Estado.PATRULLA

# Variables de vida
@export var vida_maxima: int = 3
var vida_actual: int

# Variables de movimiento
@export var velocidad_patrulla: float = 30.0
@export var velocidad_persecucion: float = 50.0 
@export var distancia_ataque: float = 20.0       

var objetivo_jugador: Node2D = null
var ya_hizo_dano_en_este_ataque: bool = false

# Referencias a nodos
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_dano: Area2D = $AreaDano
@onready var area_dano_collision: CollisionShape2D = $AreaDano/CollisionShape2D

# Variables para patrulla aleatoria
var direccion_patrulla: Vector2 = Vector2.ZERO
var tiempo_cambio_patrulla: float = 0.0


func _ready() -> void:
	vida_actual = vida_maxima
	
	if distancia_ataque == null or distancia_ataque <= 0:
		distancia_ataque = 20.0
		
	# Desactivamos el hitbox de daño por defecto usando set_deferred
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
	
	velocity = direccion_patrulla * velocidad_patrulla


func _elegir_nueva_direccion_patrulla() -> void:
	if randf() > 0.3:
		direccion_patrulla = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	else:
		direccion_patrulla = Vector2.ZERO
		
	tiempo_cambio_patrulla = randf_range(1.5, 3.5)


func _logica_persecucion(_delta: float) -> void:
	if objetivo_jugador:
		var distancia = global_position.distance_to(objetivo_jugador.global_position)
		
		if distancia <= distancia_ataque:
			_iniciar_ataque()
			return
		
		var direccion = (objetivo_jugador.global_position - global_position).normalized()
		velocity = direccion * velocidad_persecucion


func _iniciar_ataque() -> void:
	estado_actual = Estado.ATAQUE
	ya_hizo_dano_en_este_ataque = false
	
	# Activamos la colision de daño de forma segura para el motor de física
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
			queue_free()


func _on_zona_deteccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		objetivo_jugador = body
		if estado_actual != Estado.HERIDO and estado_actual != Estado.MUERTE:
			estado_actual = Estado.PERSECUCION


func _on_zona_deteccion_body_exited(body: Node2D) -> void:
	if body == objetivo_jugador:
		objetivo_jugador = null
		if estado_actual != Estado.HERIDO and estado_actual != Estado.MUERTE:
			_desactivar_dano()
			estado_actual = Estado.PATRULLA
			_elegir_nueva_direccion_patrulla()


# SEÑAL DE IMPACTO: Godot la dispara en cuanto el área se activa sobre el jugador o el jugador la toca
func _on_area_dano_body_entered(body: Node2D) -> void:
	_aplicar_dano_a_cuerpo(body)
