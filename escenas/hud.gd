extends CanvasLayer

# Arreglo para asignar las texturas PNG desde el Inspector
# Orden sugerido: [0] Barra llena, [1] -16%, [2] -33%, ..., [ultimo] Barra vacía
@export var texturas_vida: Array[Texture2D] = []

# 1. Cambiamos el tipo de dato de TextureRect a TextureProgressBar
@onready var barra_vida: TextureProgressBar = $Control/MarginContainer/VBoxContainer/BarraVida
@onready var label_temperatura: Label = $Control/MarginContainer/VBoxContainer/LabelTemperatura


func _ready() -> void:
	# Escuchar la señal del RunManager cuando la vida cambia
	RunManager.vida_cambiada.connect(_on_vida_cambiada)

	# Asegurar que la barra muestre la textura completa al 100%
	if barra_vida:
		barra_vida.value = barra_vida.max_value

	# Configurar estado inicial
	_actualizar_textura_vida(RunManager.vida_actual, RunManager.vida_maxima)
	_actualizar_texto_temperatura()


func _on_vida_cambiada(nueva_vida: int, vida_max: int) -> void:
	_actualizar_textura_vida(nueva_vida, vida_max)


func _actualizar_textura_vida(vida_actual: int, vida_max: int) -> void:
	if texturas_vida.is_empty() or not barra_vida:
		return

	# Calcular el porcentaje de vida restante (de 0.0 a 1.0)
	var porcentaje: float = float(vida_actual) / float(vida_max)
	porcentaje = clamp(porcentaje, 0.0, 1.0)

	# Convertir el porcentaje al índice correspondiente en el arreglo de texturas
	# El índice 0 es vida llena (100%) y el último índice es vida vacía (0%)
	var total_texturas: int = texturas_vida.size()
	var indice: int = int((1.0 - porcentaje) * (total_texturas - 1))
	indice = clampi(indice, 0, total_texturas - 1)

	# 2. Asignamos la imagen a texture_progress en lugar de texture
	barra_vida.texture_progress = texturas_vida[indice]


func _actualizar_texto_temperatura() -> void:
	if label_temperatura:
		label_temperatura.text = "Temp: %d°C | Buff Yerba: x%.2f" % [
			RunManager.temperatura_actual,
			RunManager.multiplicador_buff_yerba
		]
