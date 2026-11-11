
extends CanvasLayer

func _ready() -> void:
	# Nos aseguramos de que el juego no esté pausado
	get_tree().paused = false


func _on_boton_reiniciar_pressed() -> void:
	# Reiniciar la partida
	RunManager.reiniciar_run()
	get_tree().change_scene_to_file("res://level1.tscn")


func _on_boton_menu_pressed() -> void:
	# Volver al menú principal
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_volver_menu_pressed() -> void:
	pass # Replace with function body.
