extends CanvasLayer

@onready var menu_pausa: Control = $MenuPause


func _ready() -> void:
	# arranca oculto
	menu_pausa.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P:
			alternar_pausa()


func alternar_pausa() -> void:
	var estado_actual = get_tree().paused
	get_tree().paused = !estado_actual
	menu_pausa.visible = !estado_actual


func _on_boton_reanudar_pressed() -> void:
	alternar_pausa()


func _on_boton_salir_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
