extends CanvasLayer


func _ready() -> void:
	# asegura que el juego no se quede pausado si se uso pausa previamente
	get_tree().paused = false


func _process(_delta: float) -> void:
	# reiniciar con tecla R o Enter / Espacio
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_R):
		_reiniciar_juego()
	elif Input.is_key_pressed(KEY_ESCAPE):
		_volver_al_menu()


func _on_boton_reiniciar_pressed() -> void:
	_reiniciar_juego()


func _reiniciar_juego() -> void:
	# recarga la escena principal del juego
	RunManager.reiniciar_run() # Reestablecemos la vida del jugador 
	get_tree().change_scene_to_file("res://level1.tscn")


func _on_volver_menu_pressed() -> void:
	_volver_al_menu()


func _volver_al_menu() -> void:
	# vuelve a la pantalla de inicio
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
