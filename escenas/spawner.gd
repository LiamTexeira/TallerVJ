extends Node2D

@export var jugador: Node2D
@export var enemigo_scene: PackedScene # Paloma mutante
@export var perro_scene: PackedScene  # Perro cimarron
@export var radio_minimo: float = 120.0
@export var radio_maximo: float = 220.0
@export var max_intentos_spawn: int = 10

# Cola exacta de enemigos para la oleada actual
var cola_enemigos_oleada: Array[PackedScene] = []
var intervalo_entre_spawns: float = 1.0

@onready var timer_spawn: Timer = $TimerSpawn


func _ready() -> void:
	if timer_spawn:
		if not timer_spawn.timeout.is_connected(_on_timer_spawn_timeout):
			timer_spawn.timeout.connect(_on_timer_spawn_timeout)


# Recibe la composición exacta de la oleada desde el WaveManager y arma la cola fija
func iniciar_tanda_spawn_fija(palomas: int, perros: int, intervalo: float) -> void:
	cola_enemigos_oleada.clear()
	intervalo_entre_spawns = max(0.2, intervalo)
	
	# Cargamos la cola exactamente con la cantidad pedida de cada uno
	for i in range(palomas):
		if enemigo_scene:
			cola_enemigos_oleada.append(enemigo_scene)
			
	for i in range(perros):
		if perro_scene:
			cola_enemigos_oleada.append(perro_scene)
			
	# Mezclamos la cola para que salgan intercalados de forma aleatoria pero manteniendo el total exacto
	cola_enemigos_oleada.shuffle()
	
	print("Spawner: Tanda fija armada -> ", palomas, " Palomas y ", perros, " Perros. Total en cola: ", cola_enemigos_oleada.size())
	
	if timer_spawn and not cola_enemigos_oleada.is_empty():
		timer_spawn.stop()
		timer_spawn.wait_time = intervalo_entre_spawns
		timer_spawn.start()


func detener_spawner() -> void:
	if timer_spawn:
		timer_spawn.stop()
	cola_enemigos_oleada.clear()


func _on_timer_spawn_timeout() -> void:
	if cola_enemigos_oleada.is_empty():
		if timer_spawn:
			timer_spawn.stop()
		return

	if not is_instance_valid(jugador):
		return

	# Sacamos el próximo enemigo exacto de la cola
	var escena_a_instanciar = cola_enemigos_oleada.pop_front()
	if escena_a_instanciar:
		_generar_enemigo(escena_a_instanciar)

	if cola_enemigos_oleada.is_empty() and timer_spawn:
		timer_spawn.stop()


func _generar_enemigo(escena_a_instanciar: PackedScene) -> void:
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

	var enemigo = escena_a_instanciar.instantiate()
	enemigo.global_position = pos_valida
	get_parent().add_child(enemigo)


func _es_posicion_caminable(pos: Vector2) -> bool:
	var espacio_fisico := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1 
	var resultado := espacio_fisico.intersect_point(query)
	return resultado.is_empty()
