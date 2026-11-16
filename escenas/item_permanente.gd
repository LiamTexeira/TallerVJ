extends Area2D
class_name ItemPermanente

enum Tipo { BOTINES, BOLETERA, ESPUMADERA }

@export var tipo: Tipo = Tipo.BOTINES
@export var nombre_item := "Botines de Oro"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("aplicar_item"):
		body.aplicar_item(tipo)
		if Hud and Hud.has_method("mostrar_anuncio_npc"):
			Hud.mostrar_anuncio_npc("Obtuviste: " + nombre_item)
		queue_free()
