extends Control

@onready var boton_80: Button = $VBoxContainer/Boton80
@onready var boton_100: Button = $VBoxContainer/Boton100
@onready var boton_120: Button = $VBoxContainer/Boton120


func _ready() -> void:
	# Conectamos los clicks de los botones
	boton_80.pressed.connect(_on_boton_80_pressed)
	boton_100.pressed.connect(_on_boton_100_pressed)
	boton_120.pressed.connect(_on_boton_120_pressed)


func _on_boton_80_pressed() -> void:
	RunManager.iniciar_expedicion(80)


func _on_boton_100_pressed() -> void:
	RunManager.iniciar_expedicion(100)


func _on_boton_120_pressed() -> void:
	RunManager.iniciar_expedicion(120)
