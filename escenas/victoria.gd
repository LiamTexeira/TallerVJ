
extends CanvasLayer

func _ready() -> void:
	# que no quede pausado
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	# R tambien reintenta
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		_on_boton_reiniciar_pressed()


func _on_boton_reiniciar_pressed() -> void:
	RunManager.reiniciar_run()
	get_tree().change_scene_to_file("res://level1.tscn")


func _on_volver_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
