extends Area2D
class_name YerbaDrop

enum Tipo { CLASICA, YUYOS, DESPALADA }

@export var tipo_aleatorio := true      # desmarcalo para forzar un tipo al probar
@export var tipo: Tipo = Tipo.CLASICA

@export var textura_clasica: Texture2D
@export var textura_yuyos: Texture2D
@export var textura_despalada: Texture2D

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if tipo_aleatorio:
		tipo = _elegir_tipo()

	match tipo:
		Tipo.CLASICA:
			sprite.texture = textura_clasica
		Tipo.YUYOS:
			sprite.texture = textura_yuyos
		Tipo.DESPALADA:
			sprite.texture = textura_despalada

	print("Yerba dropeada: ", Tipo.keys()[tipo])
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(20.0).timeout.connect(queue_free)   # desaparece si nadie la agarra


func _elegir_tipo() -> Tipo:
	var r := randf()
	if r < 0.6: return Tipo.CLASICA      # 60 %
	if r < 0.9: return Tipo.YUYOS        # 30 %
	return Tipo.DESPALADA                # 10 %


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("aplicar_yerba"):
		if body.aplicar_yerba(tipo):
			print("Yerba recogida: ", Tipo.keys()[tipo])
			queue_free()
