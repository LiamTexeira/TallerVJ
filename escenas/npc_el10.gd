extends Area2D

signal dialogo_finalizado

var nombres_posibles: Array[String] = ["El Astro", "El Diez", "Lio", "El Capitan"]
var nombre_npc: String = ""

var jugador_cerca: bool = false
var ya_se_hablo: bool = false

@onready var label_prompter: Label = $LabelPrompter if has_node("LabelPrompter") else null


func _ready() -> void:
	nombre_npc = nombres_posibles.pick_random()
	if label_prompter:
		label_prompter.visible = false
		
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.name.begins_with("Bal") and not body.name.begins_with("Enemy"):
		jugador_cerca = true
		if label_prompter:
			label_prompter.visible = true


func _on_body_exited(body: Node2D) -> void:
	if not body.name.begins_with("Bal") and not body.name.begins_with("Enemy"):
		jugador_cerca = false
		if label_prompter:
			label_prompter.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if jugador_cerca and not ya_se_hablo:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_F or (event.has_method("is_action_pressed") and event.is_action_pressed("interactuar")):
				_interactuar_con_npc()


func _interactuar_con_npc() -> void:
	ya_se_hablo = true
	if label_prompter:
		label_prompter.visible = false
		
	if Hud and Hud.has_method("mostrar_dialogo_con_opciones"):
		var opciones = ["Cebarle un mate", "Seguir de largo"]
		Hud.mostrar_dialogo_con_opciones(nombre_npc, "¿Qué hacés, gurí? ¿Te sentás un rato a compartir unos mates?", opciones)
		
		if not Hud.opcion_seleccionada.is_connected(_on_opcion_seleccionada):
			Hud.opcion_seleccionada.connect(_on_opcion_seleccionada, CONNECT_ONE_SHOT)
	else:
		_ejecutar_resultado_mate()


func _on_opcion_seleccionada(index: int) -> void:
	if index == 0:
		_ejecutar_resultado_mate()
	else:
		_mostrar_y_conectar_final(nombre_npc, "Todo bien, maestro. ¡Suerte con los bichos en el parque!")


func _ejecutar_resultado_mate() -> void:
	# Leemos la temperatura actual directamente desde el RunManager de forma segura
	var temp: int = 120 # Valor por defecto de respaldo
	var rm = get_node_or_null("/root/RunManager")
	if rm and "temperatura_actual" in rm:
		temp = rm.temperatura_actual
		print("NPC detectó temperatura de la run: ", temp)

	var respuesta_texto: String = ""
	if temp == 80:
		respuesta_texto = "¡Qué cal a gusto, bo! Justo a 80°C, un manjar. Tomá, guardate estos Botines de Oro."
	elif temp == 100:
		respuesta_texto = "Mmh, está medio lavado este agua... pero se toma igual. Gracias por la compañía, gurí."
	else:
		respuesta_texto = "¡Ananá! ¡Me quemaste la lengua, hermano! ¡Esto está a 120°C, es lava pura!"

	_mostrar_y_conectar_final(nombre_npc, respuesta_texto)


func _mostrar_y_conectar_final(nombre: String, texto: String) -> void:
	if Hud and Hud.has_method("mostrar_dialogo"):
		if not Hud.dialogo_cerrado.is_connected(_on_hud_dialogo_cerrado):
			Hud.dialogo_cerrado.connect(_on_hud_dialogo_cerrado, CONNECT_ONE_SHOT)
		Hud.mostrar_dialogo(nombre, texto)
	else:
		_on_hud_dialogo_cerrado()


func _on_hud_dialogo_cerrado() -> void:
	dialogo_finalizado.emit()
	queue_free()
