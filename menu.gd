extends Control


# Ajustá esta ruta a donde tengas tu escena del juego
const GAME_SCENE := "res://level1.tscn"

func _ready() -> void:
	$Start.pressed.connect(_on_start_pressed)
	$Exit.pressed.connect(_on_exit_pressed)
	


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_exit_pressed() -> void:
	get_tree().quit()
