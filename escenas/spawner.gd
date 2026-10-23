extends Node2D

# Exportamos el personaje y la escena para asignarlos desde el editor
@export var jugador: Node2D
@export var enemigo_scene: PackedScene
@export var perro_scene: PackedScene
@export var probabilidad_perro: float = 0.25 # 25% de probabilidad
@export var radio_minimo: float = 120.0
@export var radio_maximo: float = 220.0
@export var max_intentos_spawn: int = 10 # Límite de intentos para buscar suelo libre
@export var tiempo_spawn: float = 2.0

@onready var timer_spawn: Timer = $TimerSpawn


func _ready() -> void:
	if timer_spawn:
		timer_spawn.wait_time = tiempo_spawn
		
		# Aseguramos que la señal timeout llame a la función de generación
		if not timer_spawn.timeout.is_connected(_on_timer_spawn_timeout):
			timer_spawn.timeout.connect(_on_timer_spawn_timeout)
			
		timer_spawn.start()


func actualizar_intervalo_spawn(nuevo_tiempo: float) -> void:
	tiempo_spawn = max(0.2, nuevo_tiempo) # Asegura un mínimo de 0.2s
	
	if timer_spawn:
		timer_spawn.stop()
		timer_spawn.wait_time = tiempo_spawn
		timer_spawn.start() # Reinicia la cuenta con el nuevo ritmo acelerado
		print("Spawner: nuevo intervalo asignado -> ", tiempo_spawn, "s")


func _on_timer_spawn_timeout() -> void:
	# Si no están asignados en el Inspector o el jugador no existe, no hace nada
	if not enemigo_scene or not is_instance_valid(jugador):
		return

	_generar_enemigo()


func _generar_enemigo() -> void:
	var pos_valida := Vector2.ZERO
	var se_encontro_posicion := false

	for i in range(max_intentos_spawn):
		var angulo := randf() * TAU
		var distancia := randf_range(radio_minimo, radio_maximo)
		var pos_candidata := jugador.global_position + Vector2(cos(angulo), sin(angulo)) * distancia

		if _es_posicion_caminable(pos_candidata):
			pos_valida = pos_candidata
			se_encontro_posicion = true
			break

	if not se_encontro_posicion:
		return

	# Selección aleatoria de escena
	var escena_a_instanciar := enemigo_scene
	if perro_scene and randf() < probabilidad_perro:
		escena_a_instanciar = perro_scene

	var enemigo = escena_a_instanciar.instantiate()
	enemigo.global_position = pos_valida
	get_parent().add_child(enemigo)


# Comprueba si el punto en el mapa no choca con capas de pared/obstáculos
func _es_posicion_caminable(pos: Vector2) -> bool:
	var espacio_fisico := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	
	# Definir qué capas de colision considerar paredes (ej: máscara 1)
	query.collision_mask = 1 

	var resultado := espacio_fisico.intersect_point(query)
	# Si el resultado está vacío, no hay pared en ese punto
	return resultado.is_empty()
