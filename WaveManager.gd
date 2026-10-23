extends Node

# Referencias exportadas
@export var spawner: Node2D

# Parámetros iniciales de la Oleada 1
var oleada_actual: int = 1
var tiempo_restante: float = 120.0 # 2 minutos
var tiempo_base_oleada: float = 120.0
var tiempo_spawn_actual: float = 10.0 # Segundos entre spawns iniciales

var oleada_activa: bool = true


func _ready() -> void:
	_iniciar_oleada()


func _unhandled_input(event: InputEvent) -> void:
	# Captura únicamente UN pulso al presionar la tecla "." (evita saltos múltiples)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_PERIOD:
			_completar_oleada()


func _process(delta: float) -> void:
	if not oleada_activa:
		return

	# Descuenta el tiempo de la oleada
	tiempo_restante -= delta
	if tiempo_restante <= 0.0:
		tiempo_restante = 0.0
		_completar_oleada()

	_actualizar_ui()


func _iniciar_oleada() -> void:
	oleada_activa = true
	
	# Búsqueda dinámica del Spawner si no fue asignado en el Inspector
	if not is_instance_valid(spawner):
		var escena_actual = get_tree().current_scene
		if escena_actual:
			spawner = escena_actual.find_child("Spawner", true, false)
			
		# Fallback directo al nodo raíz por si acaso
		if not spawner:
			spawner = get_node_or_null("/root/Spawner")
		
	if spawner and spawner.has_method("actualizar_intervalo_spawn"):
		spawner.actualizar_intervalo_spawn(tiempo_spawn_actual)

	print("--- INICIANDO OLEADA ", oleada_actual, " ---")
	print("Duración: ", tiempo_base_oleada, "s | Intervalo Spawn: ", tiempo_spawn_actual, "s")


func _completar_oleada() -> void:
	oleada_activa = false
	print("--- OLEADA ", oleada_actual, " COMPLETADA ---")

	# Escalado de dificultad
	oleada_actual += 1
	tiempo_restante = tiempo_base_oleada
	
	# Reduce el intervalo de spawn a la mitad (tope mínimo de 0.2s)
	tiempo_spawn_actual = max(2.5, tiempo_spawn_actual / 2.0)

	_iniciar_oleada()


func reducir_tiempo(segundos: float) -> void:
	if not oleada_activa:
		return
		
	tiempo_restante = max(0.0, tiempo_restante - segundos)
	print("¡Enemigo eliminado! Tiempo reducido en ", segundos, "s. Quedan: ", tiempo_restante, "s")
	
	# Forzamos la actualización inmediata del Label del HUD
	_actualizar_ui()
		
	if tiempo_restante <= 0.0:
		_completar_oleada()


func _actualizar_ui() -> void:
	# 1. Intento por grupo "HUD" (Recomendado)
	var nodos_hud = get_tree().get_nodes_in_group("HUD")
	if not nodos_hud.is_empty():
		for hud in nodos_hud:
			if hud.has_method("actualizar_tiempo"):
				hud.actualizar_tiempo(tiempo_restante)
			if hud.has_method("actualizar_oleada"):
				hud.actualizar_oleada(oleada_actual)
		return

	# 2. Búsqueda flexible en la escena actual
	var escena_actual = get_tree().current_scene
	var hud_nodo = null
	
	if escena_actual:
		hud_nodo = escena_actual.find_child("HUD", true, false)
		if not hud_nodo:
			hud_nodo = escena_actual.find_child("Hud", true, false)

	# 3. Fallback a AutoLoad /root/
	if not hud_nodo:
		if has_node("/root/HUD"):
			hud_nodo = get_node("/root/HUD")
		elif has_node("/root/Hud"):
			hud_nodo = get_node("/root/Hud")

	if hud_nodo:
		if hud_nodo.has_method("actualizar_oleada"):
			hud_nodo.actualizar_oleada(oleada_actual)
		if hud_nodo.has_method("actualizar_tiempo"):
			hud_nodo.actualizar_tiempo(tiempo_restante)
