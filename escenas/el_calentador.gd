extends Control
# Escena inicial de la run. Primero narra la historia (saltable) y despues
# deja elegir la temperatura del agua, que queda fija toda la expedicion.

# Paleta del juego
const C_SOL := Color("f4c14e")
const C_CREMA := Color("f7ead0")
const C_YERBA := Color("5c8f3f")
const C_YERBA_H := Color("6ea64a")
const C_BORDE := Color("0e1823")
const C_AZUL := Color("24405a")
const C_AZUL_H := Color("335777")
const C_ROJO := Color("c0392b")
const C_ROJO_H := Color("e0533f")

const ASSET_MATE := "res://Assets/asset_mate.png"
const MUSICA := "res://Assets/ACTION PACK 1 OGG/Long Preparation.ogg"

# Lineas de la intro. Narrador seco, tono costumbrista y medio absurdo.
const LINEAS := [
	"El parque supo ser el lugar más tranquilo del barrio.\nDespués del apagón... bueno, la cosa cambió un poco.",
	"Las palomas mutaron. Los perros se volvieron medio locos.\nPero la gente sigue viniendo igual. A matear. Como si nada.",
	"Vos sos uno de esos. Un matero solitario y estoico.\nSolo querías pasar la tarde en paz, mirando el pasto.",
	"Abrís el bolso, sacás el termo, vas a la yerbera y...\nnada. Vacía. Te olvidaste la yerba en casa. Clásico.",
	"No queda otra, maestro: hay que meterse en el parque\ny conseguir provisiones. Con todos los bichos sueltos.",
	"Pero antes, la decisión más importante del día.\nLa que separa a un matero de verdad de un improvisado.",
]

# Estado de la intro
var _fase_intro := true
var _idx := 0
var _revelando := false
var _tween_texto: Tween

# Nodos de la fase intro
var _capa_intro: Control
var _label_texto: RichTextLabel
var _label_continuar: Label

# Nodos y estado de la fase calentador
var _capa_calentador: Control
var _tarjetas: Array = []
var _datos_tarjetas: Array = []
var _temp_elegida := -1
var _barra_confirmar: Control
var _musica: AudioStreamPlayer


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# Escondemos el HUD del juego mientras dura la intro y la seleccion
	var hud := get_node_or_null("/root/Hud")
	if hud:
		hud.visible = false

	_crear_fondo()
	_crear_musica()
	_capa_intro = _crear_intro()
	add_child(_capa_intro)
	_capa_calentador = _crear_calentador()
	_capa_calentador.visible = false
	add_child(_capa_calentador)

	_mostrar_linea(0)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if _fase_intro:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_F:
			_avanzar_intro()
		elif event.keycode == KEY_ESCAPE:
			_ir_a_calentador()
	else:
		if event.keycode == KEY_1:
			_seleccionar(0)
		elif event.keycode == KEY_2:
			_seleccionar(1)
		elif event.keycode == KEY_3:
			_seleccionar(2)
		elif (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER) and _temp_elegida >= 0:
			_confirmar()


# ---------- Fondo y musica ----------
func _crear_fondo() -> void:
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.52, 1.0])
	grad.colors = PackedColorArray([Color("14202e"), Color("473b4a"), Color("7a4a2e")])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	tex.width = 256
	tex.height = 256
	var fondo := TextureRect.new()
	fondo.texture = tex
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)


func _crear_musica() -> void:
	if not ResourceLoader.exists(MUSICA):
		return
	var stream = load(MUSICA)
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	_musica = AudioStreamPlayer.new()
	_musica.stream = stream
	_musica.bus = "Music"
	add_child(_musica)
	_musica.play()


# ---------- Fase 1: intro narrativa ----------
func _crear_intro() -> Control:
	var capa := Control.new()
	capa.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Atrapa los clics para avanzar el dialogo (va atras del todo)
	var catcher := Control.new()
	catcher.set_anchors_preset(Control.PRESET_FULL_RECT)
	catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	catcher.gui_input.connect(_on_catcher_input)
	capa.add_child(catcher)

	# Caja de dialogo estilo novela visual, abajo
	var caja := PanelContainer.new()
	caja.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	caja.offset_left = 44
	caja.offset_right = -44
	caja.offset_top = -176
	caja.offset_bottom = -30
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.08, 0.12, 0.92)
	sb.anti_aliasing = false
	sb.set_corner_radius_all(0)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 4
	sb.border_width_bottom = 5
	sb.border_color = C_BORDE
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 16
	sb.content_margin_bottom = 14
	caja.add_theme_stylebox_override("panel", sb)
	capa.add_child(caja)

	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 8)
	caja.add_child(vb)

	# Fila del nombre con un matecito de avatar
	var fila_nombre := HBoxContainer.new()
	fila_nombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila_nombre.add_theme_constant_override("separation", 8)
	vb.add_child(fila_nombre)

	var mate_tex = load(ASSET_MATE) if ResourceLoader.exists(ASSET_MATE) else null
	if mate_tex:
		var avatar := TextureRect.new()
		avatar.texture = mate_tex
		avatar.custom_minimum_size = Vector2(26, 26)
		avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fila_nombre.add_child(avatar)

	var nombre := Label.new()
	nombre.text = "EL PARQUE"
	nombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ft := Estilo.fuente_titulo()
	if ft:
		nombre.add_theme_font_override("font", ft)
	nombre.add_theme_font_size_override("font_size", 13)
	nombre.add_theme_color_override("font_color", C_SOL)
	nombre.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila_nombre.add_child(nombre)

	_label_texto = RichTextLabel.new()
	_label_texto.bbcode_enabled = true
	_label_texto.fit_content = true
	_label_texto.scroll_active = false
	_label_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label_texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var fu := Estilo.fuente_ui()
	if fu:
		_label_texto.add_theme_font_override("normal_font", fu)
	_label_texto.add_theme_font_size_override("normal_font_size", 17)
	_label_texto.add_theme_color_override("default_color", C_CREMA)
	vb.add_child(_label_texto)

	_label_continuar = Label.new()
	_label_continuar.text = "clic  /  Espacio  /  F  para seguir"
	_label_continuar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label_continuar.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if fu:
		_label_continuar.add_theme_font_override("font", fu)
	_label_continuar.add_theme_font_size_override("font_size", 12)
	_label_continuar.add_theme_color_override("font_color", Color(C_CREMA.r, C_CREMA.g, C_CREMA.b, 0.55))
	_label_continuar.visible = false
	vb.add_child(_label_continuar)

	# Parpadeo suave del aviso de continuar
	var blink := create_tween().set_loops()
	blink.tween_property(_label_continuar, "modulate:a", 0.3, 0.6)
	blink.tween_property(_label_continuar, "modulate:a", 1.0, 0.6)

	# Boton saltar, arriba a la derecha (va adelante del todo)
	var saltar := Button.new()
	saltar.text = "SALTAR"
	saltar.focus_mode = Control.FOCUS_NONE
	saltar.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	saltar.offset_left = -150
	saltar.offset_top = 16
	saltar.offset_right = -18
	saltar.offset_bottom = 52
	if fu:
		saltar.add_theme_font_override("font", fu)
	saltar.add_theme_font_size_override("font_size", 15)
	saltar.add_theme_color_override("font_color", C_CREMA)
	saltar.add_theme_color_override("font_hover_color", Color("fff2cf"))
	saltar.add_theme_stylebox_override("normal", _sb(Color(0.0, 0.0, 0.0, 0.35)))
	saltar.add_theme_stylebox_override("hover", _sb(C_AZUL_H, C_SOL))
	saltar.add_theme_stylebox_override("pressed", _sb(C_AZUL))
	saltar.add_theme_stylebox_override("focus", _sb(Color(0.0, 0.0, 0.0, 0.35)))
	saltar.pressed.connect(_ir_a_calentador)
	capa.add_child(saltar)

	return capa


func _on_catcher_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_avanzar_intro()


func _mostrar_linea(i: int) -> void:
	_idx = i
	_label_continuar.visible = false
	_label_texto.text = LINEAS[i]
	_label_texto.visible_ratio = 0.0
	_revelando = true
	var dur := clampf(float(LINEAS[i].length()) * 0.018, 0.4, 2.2)
	if _tween_texto and _tween_texto.is_valid():
		_tween_texto.kill()
	_tween_texto = create_tween()
	_tween_texto.tween_property(_label_texto, "visible_ratio", 1.0, dur)
	_tween_texto.tween_callback(_fin_revelado)


func _fin_revelado() -> void:
	_revelando = false
	_label_continuar.visible = true


func _avanzar_intro() -> void:
	if not _fase_intro:
		return
	if _revelando:
		# Un primer toque completa el texto de golpe
		if _tween_texto and _tween_texto.is_valid():
			_tween_texto.kill()
		_label_texto.visible_ratio = 1.0
		_revelando = false
		_label_continuar.visible = true
		return
	if _idx + 1 >= LINEAS.size():
		_ir_a_calentador()
	else:
		_mostrar_linea(_idx + 1)


func _ir_a_calentador() -> void:
	if not _fase_intro:
		return
	_fase_intro = false
	_capa_calentador.visible = true
	_capa_calentador.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(_capa_intro, "modulate:a", 0.0, 0.3)
	t.tween_callback(func(): _capa_intro.visible = false)
	t.tween_property(_capa_calentador, "modulate:a", 1.0, 0.35)


# ---------- Fase 2: seleccion de temperatura ----------
func _crear_calentador() -> Control:
	_datos_tarjetas = [
		{
			"valor": 80, "temp": "80°", "nombre": "TEMPLADA", "color": C_YERBA, "hover": C_YERBA_H,
			"flavor": "Agua tranquila, sin sobresaltos.\nComo a la abuela le gustaba.",
			"efecto": "Efecto yerba normal\nNo te quema",
		},
		{
			"valor": 100, "temp": "100°", "nombre": "CALIENTE", "color": C_SOL, "hover": Color("ffd470"),
			"flavor": "Para los que saben.\nNi muy muy, ni tan tan.",
			"efecto": "Efecto yerba +25%\nNo te quema",
		},
		{
			"valor": 120, "temp": "120°", "nombre": "HIRVIENDO", "color": C_ROJO, "hover": C_ROJO_H,
			"flavor": "Lava pura. Te quema la lengua,\npero te hace sentir vivo.",
			"efecto": "Efecto yerba x2\nQuemadura: -5 vida por sorbo",
		},
	]

	var capa := Control.new()
	capa.set_anchors_preset(Control.PRESET_FULL_RECT)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.add_child(centro)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 10)
	centro.add_child(col)

	var titulo := Label.new()
	titulo.text = "EL CALENTADOR"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ft := Estilo.fuente_titulo()
	if ft:
		titulo.add_theme_font_override("font", ft)
	titulo.add_theme_font_size_override("font_size", 30)
	titulo.add_theme_color_override("font_color", C_SOL)
	titulo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	titulo.add_theme_constant_override("shadow_offset_x", 3)
	titulo.add_theme_constant_override("shadow_offset_y", 3)
	col.add_child(titulo)

	var sub := Label.new()
	sub.text = "¿A qué temperatura va el agua? Queda fija toda la expedición."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var fu := Estilo.fuente_ui()
	if fu:
		sub.add_theme_font_override("font", fu)
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", C_CREMA)
	col.add_child(sub)

	var esp := Control.new()
	esp.custom_minimum_size = Vector2(0, 10)
	col.add_child(esp)

	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 18)
	col.add_child(fila)

	_tarjetas.clear()
	for i in range(_datos_tarjetas.size()):
		var card := _crear_tarjeta(i, _datos_tarjetas[i])
		fila.add_child(card)
		_tarjetas.append(card)

	# Barra de confirmacion (aparece al elegir)
	_barra_confirmar = _crear_barra_confirmar()
	_barra_confirmar.visible = false
	col.add_child(_barra_confirmar)

	return capa


func _crear_tarjeta(indice: int, datos: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(232, 292)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_theme_stylebox_override("panel", _sb_tarjeta(datos.color, "normal"))
	card.gui_input.connect(func(e): _on_tarjeta_input(e, indice))
	card.mouse_entered.connect(func(): _on_tarjeta_hover(indice, true))
	card.mouse_exited.connect(func(): _on_tarjeta_hover(indice, false))

	var vb := VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 6)
	card.add_child(vb)

	var ft := Estilo.fuente_titulo()
	var fu := Estilo.fuente_ui()

	var temp := Label.new()
	temp.text = datos.temp
	temp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if ft:
		temp.add_theme_font_override("font", ft)
	temp.add_theme_font_size_override("font_size", 34)
	temp.add_theme_color_override("font_color", datos.hover)
	temp.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	temp.add_theme_constant_override("shadow_offset_x", 2)
	temp.add_theme_constant_override("shadow_offset_y", 2)
	vb.add_child(temp)

	var nombre := Label.new()
	nombre.text = datos.nombre
	nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if fu:
		nombre.add_theme_font_override("font", fu)
	nombre.add_theme_font_size_override("font_size", 20)
	nombre.add_theme_color_override("font_color", C_CREMA)
	vb.add_child(nombre)

	var linea := _separador(datos.color)
	vb.add_child(linea)

	var flavor := Label.new()
	flavor.text = datos.flavor
	flavor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if fu:
		flavor.add_theme_font_override("font", fu)
	flavor.add_theme_font_size_override("font_size", 14)
	flavor.add_theme_color_override("font_color", Color(C_CREMA.r, C_CREMA.g, C_CREMA.b, 0.82))
	flavor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(flavor)

	var efecto := Label.new()
	efecto.text = datos.efecto
	efecto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	efecto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if fu:
		efecto.add_theme_font_override("font", fu)
	efecto.add_theme_font_size_override("font_size", 13)
	efecto.add_theme_color_override("font_color", datos.hover)
	vb.add_child(efecto)

	return card


func _separador(col: Color) -> Control:
	var sep := Control.new()
	sep.custom_minimum_size = Vector2(0, 3)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pan := Panel.new()
	pan.set_anchors_preset(Control.PRESET_FULL_RECT)
	pan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(col.r, col.g, col.b, 0.5)
	sb.anti_aliasing = false
	sb.set_corner_radius_all(0)
	pan.add_theme_stylebox_override("panel", sb)
	sep.add_child(pan)
	return sep


func _crear_barra_confirmar() -> Control:
	var caja := VBoxContainer.new()
	caja.alignment = BoxContainer.ALIGNMENT_CENTER
	caja.add_theme_constant_override("separation", 8)

	var esp := Control.new()
	esp.custom_minimum_size = Vector2(0, 6)
	caja.add_child(esp)

	var aviso := Label.new()
	aviso.name = "Aviso"
	aviso.text = ""
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var fu := Estilo.fuente_ui()
	if fu:
		aviso.add_theme_font_override("font", fu)
	aviso.add_theme_font_size_override("font_size", 15)
	aviso.add_theme_color_override("font_color", C_SOL)
	caja.add_child(aviso)

	var boton := Button.new()
	boton.name = "BotonConfirmar"
	boton.text = "CEBAR Y ENTRAR AL PARQUE"
	boton.focus_mode = Control.FOCUS_NONE
	boton.custom_minimum_size = Vector2(0, 50)
	if fu:
		boton.add_theme_font_override("font", fu)
	boton.add_theme_font_size_override("font_size", 19)
	boton.add_theme_color_override("font_color", C_CREMA)
	boton.add_theme_color_override("font_hover_color", Color("fff2cf"))
	boton.add_theme_stylebox_override("normal", _sb(C_YERBA))
	boton.add_theme_stylebox_override("hover", _sb(C_YERBA_H, C_SOL))
	boton.add_theme_stylebox_override("pressed", _sb(C_YERBA.darkened(0.2)))
	boton.add_theme_stylebox_override("focus", _sb(C_YERBA))
	boton.pressed.connect(_confirmar)
	caja.add_child(boton)

	return caja


func _on_tarjeta_input(event: InputEvent, indice: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_seleccionar(indice)


func _on_tarjeta_hover(indice: int, encima: bool) -> void:
	if indice == _temp_elegida:
		return
	var datos: Dictionary = _datos_tarjetas[indice]
	var estado := "hover" if encima else "normal"
	_tarjetas[indice].add_theme_stylebox_override("panel", _sb_tarjeta(datos.color, estado))


func _seleccionar(indice: int) -> void:
	_temp_elegida = indice
	for i in range(_tarjetas.size()):
		var datos: Dictionary = _datos_tarjetas[i]
		var estado := "selec" if i == indice else "apagada"
		_tarjetas[i].add_theme_stylebox_override("panel", _sb_tarjeta(datos.color, estado))

	var aviso := _barra_confirmar.get_node("Aviso") as Label
	aviso.text = "Elegiste %s. Esta decisión te acompaña toda la expedición." % _datos_tarjetas[indice].temp
	_barra_confirmar.visible = true


func _confirmar() -> void:
	if _temp_elegida < 0:
		return
	# Mostramos el HUD de nuevo justo antes de arrancar la partida
	var hud := get_node_or_null("/root/Hud")
	if hud:
		hud.visible = true
	RunManager.iniciar_expedicion(_datos_tarjetas[_temp_elegida].valor)


# ---------- Estilos ----------
func _sb(bg: Color, borde: Color = C_BORDE) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.anti_aliasing = false
	sb.set_corner_radius_all(0)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 4
	sb.border_width_bottom = 5
	sb.border_color = borde
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 10
	sb.content_margin_bottom = 12
	return sb


# Estilo de tarjeta segun estado: normal, hover, selec, apagada
func _sb_tarjeta(col: Color, estado: String) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.anti_aliasing = false
	sb.set_corner_radius_all(0)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 4
	sb.border_width_bottom = 5
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 18
	sb.content_margin_bottom = 16
	var base := Color(0.05, 0.08, 0.12, 0.9)
	match estado:
		"hover":
			sb.bg_color = Color(col.r * 0.35 + 0.05, col.g * 0.35 + 0.08, col.b * 0.35 + 0.08, 0.95)
			sb.border_color = col
		"selec":
			sb.bg_color = Color(col.r * 0.45 + 0.05, col.g * 0.45 + 0.06, col.b * 0.45 + 0.06, 0.98)
			sb.border_color = C_SOL
			sb.border_width_left = 3
			sb.border_width_top = 3
			sb.border_width_right = 5
			sb.border_width_bottom = 6
		"apagada":
			sb.bg_color = Color(base.r, base.g, base.b, 0.55)
			sb.border_color = Color(C_BORDE.r, C_BORDE.g, C_BORDE.b, 0.5)
		_:
			sb.bg_color = base
			sb.border_color = Color(col.r, col.g, col.b, 0.6)
	return sb
