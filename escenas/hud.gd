extends CanvasLayer

# Arreglo para asignar las texturas PNG desde el Inspector
@export var texturas_vida: Array[Texture2D] = []

@onready var barra_vida: TextureProgressBar = $Control/MarginContainer/VBoxContainer/BarraVida
@onready var label_temperatura: Label = $Control/MarginContainer/VBoxContainer/LabelTemperatura
@onready var label_oleada: Label = $Control/MarginContainer/VBoxContainer/LabelOleada
@onready var label_tiempo: Label = $Control/MarginContainer/VBoxContainer/LabelTiempo
@onready var label_enemigos: Label = $Control/MarginContainer/VBoxContainer/LabelEnemigos if has_node("Control/MarginContainer/VBoxContainer/LabelEnemigos") else null

# Referencias del cuadro de diálogo
@onready var cuadro_dialogo: Control = $CuadroDialogo
@onready var label_nombre_npc: Label = $CuadroDialogo/MarginContainer/VBoxContainer/LabelNombreNPC
@onready var label_texto_dialogo: RichTextLabel = $CuadroDialogo/MarginContainer/VBoxContainer/LabelTextoDialogo
@onready var boton_continuar: Button = $CuadroDialogo/MarginContainer/VBoxContainer/BotonContinuar

@onready var contenedor_opciones: VBoxContainer = $CuadroDialogo/MarginContainer/VBoxContainer/ContenedorOpciones if has_node("CuadroDialogo/MarginContainer/VBoxContainer/ContenedorOpciones") else null

signal dialogo_cerrado
signal opcion_seleccionada(opcion_index: int)

var opciones_activas: bool = false


func _ready() -> void:
	RunManager.vida_cambiada.connect(_on_vida_cambiada)

	if barra_vida:
		barra_vida.value = barra_vida.max_value
	if cuadro_dialogo:
		cuadro_dialogo.visible = false
	if boton_continuar:
		if not boton_continuar.pressed.is_connected(_on_boton_continuar_pressed):
			boton_continuar.pressed.connect(_on_boton_continuar_pressed)	
			
	if contenedor_opciones:
		contenedor_opciones.visible = false

	_actualizar_textura_vida(RunManager.vida_actual, RunManager.vida_maxima)
	_actualizar_texto_temperatura()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if opciones_activas:
			if event.keycode == KEY_F1:
				_on_opcion_presionada(0)
			elif event.keycode == KEY_F2:
				_on_opcion_presionada(1)
				
		elif cuadro_dialogo and cuadro_dialogo.visible and boton_continuar and boton_continuar.visible:
			if event.keycode == KEY_F:
				_on_boton_continuar_pressed()


func mostrar_dialogo(nombre: String, texto: String) -> void:
	opciones_activas = false
	if label_nombre_npc:
		label_nombre_npc.text = nombre
	if label_texto_dialogo:
		label_texto_dialogo.text = texto
	if contenedor_opciones:
		contenedor_opciones.visible = false
	if boton_continuar:
		boton_continuar.visible = true
		boton_continuar.text = "Continuar (F)"
	if cuadro_dialogo:
		cuadro_dialogo.visible = true


func mostrar_dialogo_con_opciones(nombre: String, texto: String, opciones: Array) -> void:
	opciones_activas = true
	if label_nombre_npc:
		label_nombre_npc.text = nombre
	if label_texto_dialogo:
		label_texto_dialogo.text = texto
	
	if boton_continuar:
		boton_continuar.visible = false
		
	if contenedor_opciones:
		contenedor_opciones.visible = true
		for child in contenedor_opciones.get_children():
			child.queue_free()
			
		for i in range(opciones.size()):
			var boton = Button.new()
			boton.text = "(F%d) %s" % [i + 1, str(opciones[i])]
			boton.name = "BotonOpcion_" + str(i)
			var index_copia = i
			boton.pressed.connect(func(): _on_opcion_presionada(index_copia))
			contenedor_opciones.add_child(boton)
			
	if cuadro_dialogo:
		cuadro_dialogo.visible = true


func _on_opcion_presionada(index: int) -> void:
	opciones_activas = false
	if contenedor_opciones:
		contenedor_opciones.visible = false
	if cuadro_dialogo:
		cuadro_dialogo.visible = false
	opcion_seleccionada.emit(index)


func _on_boton_continuar_pressed() -> void:
	if cuadro_dialogo:
		cuadro_dialogo.visible = false
	dialogo_cerrado.emit()


func mostrar_anuncio_npc(texto_anuncio: String) -> void:
	var anuncio = Label.new()
	anuncio.text = "⚠️ " + texto_anuncio + " ⚠️"
	anuncio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	anuncio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	anuncio.add_theme_font_size_override("font_size", 20)
	
	anuncio.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	anuncio.offset_top = 180
	anuncio.offset_left = -250
	anuncio.offset_right = 250
	
	if has_node("Control"):
		$Control.add_child(anuncio)
	else:
		add_child(anuncio)
	
	var tween = create_tween().set_loops(6)
	tween.tween_property(anuncio, "modulate:a", 0.2, 0.4)
	tween.tween_property(anuncio, "modulate:a", 1.0, 0.4)
	
	var tween_final = create_tween()
	tween_final.tween_interval(5.0)
	tween_final.tween_property(anuncio, "modulate:a", 0.0, 1.0)
	tween_final.tween_callback(anuncio.queue_free)


func _on_vida_cambiada(nueva_vida: int, vida_max: int) -> void:
	_actualizar_textura_vida(nueva_vida, vida_max)


func _actualizar_textura_vida(vida_actual: int, vida_max: int) -> void:
	if texturas_vida.is_empty() or not barra_vida:
		return

	var porcentaje: float = float(vida_actual) / float(vida_max)
	porcentaje = clamp(porcentaje, 0.0, 1.0)

	var total_texturas: int = texturas_vida.size()
	var indice: int = int((1.0 - porcentaje) * (total_texturas - 1))
	indice = clampi(indice, 0, total_texturas - 1)

	barra_vida.texture_progress = texturas_vida[indice]


func _actualizar_texto_temperatura() -> void:
	if label_temperatura:
		label_temperatura.text = "Temp: %d°C | Buff Yerba: x%.2f" % [
			RunManager.temperatura_actual,
			RunManager.multiplicador_buff_yerba
		]


func actualizar_oleada(numero: int) -> void:
	if label_oleada:
		label_oleada.text = "Oleada: " + str(numero)


# Muestra exclusivamente los enemigos restantes durante la acción
func mostrar_enemigos_restantes(cantidad: int) -> void:
	if label_enemigos:
		label_enemigos.visible = true
		label_enemigos.text = "Enemigos restantes: " + str(cantidad)
	if label_tiempo:
		label_tiempo.visible = false # Oculta el cronómetro mientras peleamos


# Muestra exclusivamente el temporizador durante los descansos o pausas
func mostrar_cronometro_descanso(segundos: float) -> void:
	if label_enemigos:
		label_enemigos.visible = false # Oculta los enemigos mientras descansamos
	if label_tiempo:
		label_tiempo.visible = true
		var total_seg: int = int(max(0.0, segundos))
		var minutos: int = total_seg / 60
		var segundos_resto: int = total_seg % 60
		label_tiempo.text = "Siguiente oleada en: %02d:%02d" % [minutos, segundos_resto]


func actualizar_temperatura_label(texto: String) -> void:
	if label_temperatura:
		label_temperatura.text = texto
