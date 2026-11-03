extends Node

@export var spawner: Node2D
@export var npc_el10_scene: PackedScene 
@export var npc_chofer_scene: PackedScene 
@export var posicion_spawn_npc: Vector2 = Vector2(0, 0) 
@export var npc_tortas_fritas_scene: PackedScene

# Control de oleadas
var oleada_actual: int = 1
var max_oleadas: int = 10 # 10 oleadas en total (la última de 10 perros cimarrones)

# Estado del juego
var oleada_activa: bool = false
var en_descanso: bool = false
var esperando_interaccion_npc: bool = false
var tiempo_descanso: float = 10.0 # 10 segundos de descanso estándar entre oleadas

# Conteo de enemigos en la oleada actual
var enemigos_totales_oleada: int = 0
var enemigos_vivos_en_mapa: int = 0

var npc_instanciado: Node2D = null


func _ready() -> void:
	_iniciar_oleada()


func _unhandled_input(event: InputEvent) -> void:
	# Atajo de prueba con punto (.) para saltar oleada si lo deseás probar rápido
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_PERIOD:
			_completar_oleada()


func _process(delta: float) -> void:
	if en_descanso:
		tiempo_descanso -= delta
		_actualizar_ui_personalizada(tiempo_descanso)
			
		if tiempo_descanso <= 0.0:
			_finalizar_descanso()
		return

	if esperando_interaccion_npc:
		_actualizar_ui_personalizada(0.0)
		return


# Definición de la composición fija de cada oleada (Palomas, Perros)
func _obtener_composicion_oleada(num_oleada: int) -> Dictionary:
	match num_oleada:
		1:  return {"palomas": 9,  "perros": 1}   # Total: 10
		2:  return {"palomas": 8,  "perros": 2}   # Total: 10
		3:  return {"palomas": 7,  "perros": 3}   # Total: 10
		4:  return {"palomas": 6,  "perros": 4}   # Total: 10
		5:  return {"palomas": 5,  "perros": 5}   # Total: 10
		6:  return {"palomas": 4,  "perros": 6}   # Total: 10
		7:  return {"palomas": 3,  "perros": 7}   # Total: 10
		8:  return {"palomas": 2,  "perros": 8}   # Total: 10
		9:  return {"palomas": 1,  "perros": 9}   # Total: 10
		10: return {"palomas": 0,  "perros": 10}  # Total: 10 (Oleada final de perros cimarrones)
		_:  return {"palomas": 0,  "perros": 10}


func _iniciar_oleada() -> void:
	oleada_activa = true
	en_descanso = false
	
	var composicion = _obtener_composicion_oleada(oleada_actual)
	var palomas = composicion["palomas"]
	var perros = composicion["perros"]
	
	enemigos_totales_oleada = palomas + perros
	enemigos_vivos_en_mapa = enemigos_totales_oleada
	
	var probabilidad_perro = float(perros) / float(enemigos_totales_oleada) if enemigos_totales_oleada > 0 else 0.0
	
	print("--- INICIANDO OLEADA ", oleada_actual, " (Palomas: ", palomas, " | Perros: ", perros, ") ---")
	
	if not is_instance_valid(spawner):
		var escena_actual = get_tree().current_scene
		if escena_actual:
			spawner = escena_actual.find_child("Spawner", true, false)

	if is_instance_valid(spawner):
		spawner.set_process(true)
		spawner.set_physics_process(true)
		if spawner.has_method("iniciar_tanda_spawn_fija"):
			# Le pasamos la cantidad exacta de palomas y perros sin depender de porcentajes al azar
			spawner.iniciar_tanda_spawn_fija(palomas, perros, 1.5)
	
	_actualizar_ui()


func _completar_oleada() -> void:
	oleada_activa = false
	print("--- OLEADA ", oleada_actual, " COMPLETADA ---")

	if is_instance_valid(spawner) and spawner.has_method("detener_spawner"):
		spawner.detener_spawner()

	# Verificamos eventos de NPCs según la oleada completada
	if oleada_actual == 3:
		_iniciar_evento_npc()
	elif oleada_actual == 6:
		_iniciar_evento_chofer()
	elif oleada_actual == 9:
		_iniciar_evento_tortas_fritas()
	elif oleada_actual >= max_oleadas:
		_iniciar_pausa_jefe_final()
	else:
		_iniciar_descanso(10.0)


func _iniciar_descanso(segundos: float) -> void:
	en_descanso = true
	tiempo_descanso = segundos
	print("=== COMIENZAN ", segundos, " SEGUNDOS DE DESCANSO ===")


func _iniciar_pausa_jefe_final() -> void:
	en_descanso = true
	tiempo_descanso = 60.0 # 1 minuto de pausa antes del jefe / fase final
	print("=== ¡TODAS LAS OLEADAS COMPLETADAS! INICIANDO PAUSA DE 1 MINUTO PARA EL JEFE FINAL ===")
	
	var hud = _buscar_hud()
	if hud and hud.has_method("mostrar_anuncio_npc"):
		hud.mostrar_anuncio_npc("⚠️ ¡Preparate! El jefe final se acerca en 1 minuto ⚠️")


func _finalizar_descanso() -> void:
	en_descanso = false
	
	if oleada_actual >= max_oleadas:
		print("¡Tiempo de pausa del jefe final terminado! Disparando evento de jefe...")
		return
		
	_siguiente_oleada()


func _siguiente_oleada() -> void:
	oleada_actual += 1
	_iniciar_oleada()


func _iniciar_evento_npc() -> void:
	print("=== EVENTO EL 10 ===")
	_preparar_evento_npc()
	if npc_el10_scene:
		npc_instanciado = npc_el10_scene.instantiate()
		_conectar_y_posicionar_npc(npc_instanciado)


func _iniciar_evento_chofer() -> void:
	print("=== EVENTO CHOFER ===")
	_preparar_evento_npc()
	if npc_chofer_scene:
		npc_instanciado = npc_chofer_scene.instantiate()
		_conectar_y_posicionar_npc(npc_instanciado)


func _iniciar_evento_tortas_fritas() -> void:
	print("=== EVENTO TORTAS FRITAS ===")
	_preparar_evento_npc()
	if npc_tortas_fritas_scene:
		npc_instanciado = npc_tortas_fritas_scene.instantiate()
		_conectar_y_posicionar_npc(npc_instanciado)


func _preparar_evento_npc() -> void:
	esperando_interaccion_npc = true
	if is_instance_valid(spawner) and spawner.has_method("detener_spawner"):
		spawner.detener_spawner()
		
	_limpiar_enemigos_mapa()
	
	var hud = _buscar_hud()
	if hud and hud.has_method("mostrar_anuncio_npc"):
		hud.mostrar_anuncio_npc("⚠️ ¡Un personaje ha aparecido en el mapa! Buscalo para interactuar ⚠️")


func _conectar_y_posicionar_npc(npc: Node2D) -> void:
	if not npc:
		return
	if not npc.dialogo_finalizado.is_connected(_on_npc_dialogo_finalizado):
		npc.dialogo_finalizado.connect(_on_npc_dialogo_finalizado)
	_posicionar_npc(npc)


func _posicionar_npc(npc: Node2D) -> void:
	var escena_actual = get_tree().current_scene
	if not escena_actual:
		return
	escena_actual.add_child(npc)
	
	var nombre_marcador = "PuntoSpawnNPC"
	var ruta = npc.scene_file_path.to_lower()
	if "el10" in ruta: nombre_marcador = "SpawnEl10"
	elif "chofer" in ruta: nombre_marcador = "SpawnChofer"
	elif "tortas" in ruta: nombre_marcador = "SpawnTortasFritas"
		
	var punto = escena_actual.find_child(nombre_marcador, true, false)
	if punto:
		npc.global_position = punto.global_position
	else:
		var player = escena_actual.find_child("player", true, false)
		if player: npc.global_position = player.global_position + Vector2(-80, 0)
		else: npc.global_position = Vector2(200, 200)


func _limpiar_enemigos_mapa() -> void:
	# Barrido completo buscando tanto en grupo "Enemigo" como en "Enemigos" (plural y singular)
	for nodo in get_tree().get_nodes_in_group("Enemigo"):
		if is_instance_valid(nodo):
			nodo.queue_free()
	for nodo in get_tree().get_nodes_in_group("Enemigos"):
		if is_instance_valid(nodo):
			nodo.queue_free()
			
	print("Limpieza de enemigos completada con éxito.")


func _on_npc_dialogo_finalizado() -> void:
	esperando_interaccion_npc = false
	_iniciar_descanso(10.0)


func _buscar_hud() -> Node:
	var escena = get_tree().current_scene
	if not escena: return null
	var h = escena.find_child("HUD", true, false)
	if not h: h = escena.find_child("Hud", true, false)
	if not h:
		if has_node("/root/HUD"): h = get_node("/root/HUD")
		elif has_node("/root/Hud"): h = get_node("/root/Hud")
	return h


func _actualizar_ui() -> void:
	var hud = _buscar_hud()
	if hud:
		if hud.has_method("actualizar_oleada"):
			hud.actualizar_oleada(oleada_actual)
		if hud.has_method("mostrar_enemigos_restantes"):
			hud.mostrar_enemigos_restantes(enemigos_vivos_en_mapa)


func _actualizar_ui_personalizada(tiempo_a_mostrar: float) -> void:
	var hud = _buscar_hud()
	if hud:
		if hud.has_method("actualizar_oleada"):
			hud.actualizar_oleada(oleada_actual)
		if hud.has_method("mostrar_cronometro_descanso"):
			hud.mostrar_cronometro_descanso(tiempo_a_mostrar)
			
			
# Llamado cada vez que un enemigo muere en el mapa
func registrar_enemigo_derrotado() -> void:
	if not oleada_activa:
		return
		
	enemigos_vivos_en_mapa = max(0, enemigos_vivos_en_mapa - 1)
	print("Enemigo derrotado. Restantes en oleada: ", enemigos_vivos_en_mapa)
	
	_actualizar_ui()
	
	if enemigos_vivos_en_mapa <= 0:
		_completar_oleada()
