extends Area2D

@export var curacion: int = 1


func _ready() -> void:
	# Conectamos la señal que avisa cuando algo entra al área
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Verificamos si lo que pasó por encima es el jugador
	if body.is_in_group("Player"):
		_aplicar_efecto(body)


func _aplicar_efecto(jugador: Node2D) -> void:
	# Si el jugador maneja su propia vida con curar() o recibir_danio()
	if jugador.has_method("curar"):
		jugador.curar(curacion)
		queue_free()
	# Si modifica directamente la variable vida_actual
	elif "vida_actual" in jugador:
		var vida_max: int = jugador.get("vida_maxima") if "vida_maxima" in jugador else 10
		
		# Solo la consume si no esta a vida máxima
		if jugador.vida_actual < vida_max:
			jugador.vida_actual = min(jugador.vida_actual + curacion, vida_max)
			print("¡Empanada consumida! Vida actual: ", jugador.vida_actual)
			queue_free()
