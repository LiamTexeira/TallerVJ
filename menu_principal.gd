extends Control
# Menu principal: portada y paneles (como jugar, controles, creditos).

const ESCENA_JUEGO := "res://escenas/el_calentador.tscn"
const MUSICA_MENU := "res://Assets/ACTION PACK 1 OGG/Long Preparation.ogg"
const ASSET_MATE := "res://Assets/asset_mate.png"

# Paleta
const C_SOL := Color("f4c14e")
const C_CREMA := Color("f7ead0")
const C_YERBA := Color("5c8f3f")
const C_YERBA2 := Color("3f6b2c")
const C_BORDE := Color("0e1823")
const C_MATE := Color("4a3018")
const C_MATE_H := Color("6a4a2b")
const C_AZUL := Color("24405a")
const C_LADRILLO := Color("8f3b22")
const C_MATE2 := Color("7d4a24")

var _vistas := {}
var _musica: AudioStreamPlayer


func _ready() -> void:
	# Ocultar el HUD mientras estamos en el menu
	if has_node("/root/Hud"):
		get_node("/root/Hud").visible = false

	_construir_fondo()
	_construir_musica()
	_vistas["portada"] = _construir_portada()
	_vistas["comojugar"] = _construir_panel_texto("Cómo jugar", _texto_como_jugar())
	_vistas["controles"] = _construir_controles()
	_vistas["creditos"] = _construir_creditos()
	for v in _vistas.values():
		add_child(v)
	_mostrar("portada")


func _mostrar(nombre: String) -> void:
	for clave in _vistas:
		_vistas[clave].visible = (clave == nombre)


# ---------- Fondo ----------
func _construir_fondo() -> void:
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.34, 0.64, 1.0])
	grad.colors = PackedColorArray([Color("172536"), Color("3a5774"), Color("7a6a73"), Color("b9743f")])
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


# ---------- Musica ----------
func _construir_musica() -> void:
	var stream = load(MUSICA_MENU)
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	_musica = AudioStreamPlayer.new()
	_musica.stream = stream
	_musica.bus = "Music"
	add_child(_musica)
	_musica.play()


# ---------- Portada ----------
func _construir_portada() -> CenterContainer:
	var centro := _centro()
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 10)
	centro.add_child(vbox)

	# Logo mate (si existe el asset)
	var mate_tex = load(ASSET_MATE)
	if mate_tex:
		var logo := TextureRect.new()
		logo.texture = mate_tex
		logo.custom_minimum_size = Vector2(0, 96)
		logo.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vbox.add_child(logo)

	var titulo := Label.new()
	titulo.text = "MATEÁLOS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ft := Estilo.fuente_titulo()
	if ft:
		titulo.add_theme_font_override("font", ft)
	titulo.add_theme_font_size_override("font_size", 40)
	titulo.add_theme_color_override("font_color", C_SOL)
	titulo.add_theme_color_override("font_shadow_color", C_MATE2)
	titulo.add_theme_constant_override("shadow_offset_x", 3)
	titulo.add_theme_constant_override("shadow_offset_y", 3)
	vbox.add_child(titulo)

	var tag := Label.new()
	tag.text = "Cebá, esquivá, sobreviví"
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var fu := Estilo.fuente_ui()
	if fu:
		tag.add_theme_font_override("font", fu)
	tag.add_theme_font_size_override("font_size", 16)
	tag.add_theme_color_override("font_color", C_CREMA)
	vbox.add_child(tag)

	var esp := Control.new()
	esp.custom_minimum_size = Vector2(0, 18)
	vbox.add_child(esp)

	vbox.add_child(_boton("JUGAR", _on_jugar, C_YERBA, C_YERBA.lightened(0.12)))
	vbox.add_child(_boton("CÓMO JUGAR", func(): _mostrar("comojugar")))
	vbox.add_child(_boton("CONTROLES", func(): _mostrar("controles")))
	vbox.add_child(_boton("CRÉDITOS", func(): _mostrar("creditos")))
	vbox.add_child(_boton("SALIR", _on_salir, C_LADRILLO, C_LADRILLO.lightened(0.12)))
	return centro


# ---------- Panel generico de texto ----------
func _construir_panel_texto(titulo_txt: String, cuerpo: String) -> CenterContainer:
	var centro := _centro()
	var panel := _panel()
	centro.add_child(panel)
	var vbox := panel.get_child(0)
	vbox.add_child(_titulo_panel(titulo_txt))

	var texto := RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.fit_content = true
	texto.scroll_active = false
	texto.custom_minimum_size = Vector2(520, 0)
	var fu := Estilo.fuente_ui()
	if fu:
		texto.add_theme_font_override("normal_font", fu)
	texto.add_theme_font_size_override("normal_font_size", 16)
	texto.add_theme_color_override("default_color", C_CREMA)
	texto.text = cuerpo
	vbox.add_child(texto)

	vbox.add_child(_boton("VOLVER", func(): _mostrar("portada"), C_AZUL, C_AZUL.lightened(0.15)))
	return centro


# ---------- Panel de controles ----------
func _construir_controles() -> CenterContainer:
	var centro := _centro()
	var panel := _panel()
	centro.add_child(panel)
	var vbox := panel.get_child(0)
	vbox.add_child(_titulo_panel("Controles"))

	var filas := [
		["Moverse", "WASD / Flechas"],
		["Dash / esquivar", "J  (y Barra espaciadora)"],
		["Atacar", "K  /  X"],
		["Cambiar arma", "4 (mate)  ·  5 (termo)"],
		["Cebar mate", "E"],
		["Interactuar (NPCs)", "F"],
		["Pausa", "P"],
	]
	var fu := Estilo.fuente_ui()
	for f in filas:
		var fila := HBoxContainer.new()
		fila.custom_minimum_size = Vector2(500, 0)
		var acc := Label.new()
		acc.text = f[0]
		if fu:
			acc.add_theme_font_override("font", fu)
		acc.add_theme_font_size_override("font_size", 16)
		acc.add_theme_color_override("font_color", C_CREMA)
		acc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(acc)
		var tec := Label.new()
		tec.text = f[1]
		if fu:
			tec.add_theme_font_override("font", fu)
		tec.add_theme_font_size_override("font_size", 16)
		tec.add_theme_color_override("font_color", C_SOL)
		tec.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		fila.add_child(tec)
		vbox.add_child(fila)

	vbox.add_child(_boton("VOLVER", func(): _mostrar("portada"), C_AZUL, C_AZUL.lightened(0.15)))
	return centro


# ---------- Panel de creditos ----------
func _construir_creditos() -> CenterContainer:
	var centro := _centro()
	var panel := _panel()
	centro.add_child(panel)
	var vbox := panel.get_child(0)
	vbox.add_child(_titulo_panel("Créditos"))

	var equipo := RichTextLabel.new()
	equipo.bbcode_enabled = true
	equipo.fit_content = true
	equipo.scroll_active = false
	equipo.custom_minimum_size = Vector2(520, 0)
	var fu := Estilo.fuente_ui()
	if fu:
		equipo.add_theme_font_override("normal_font", fu)
	equipo.add_theme_font_size_override("normal_font_size", 16)
	equipo.add_theme_color_override("default_color", C_CREMA)
	equipo.text = "[center]Desarrollado por\n[color=#ffe6a6]Federico Martini[/color]  y  [color=#ffe6a6]Liam Texeira[/color][/center]\n\n[color=#f4c14e]Assets[/color]\nMúsica — Luis Zuno (ansimuz)\nMapa e íconos — Kenney (CC0)\nUI de diálogos — CSAF UI Kit"
	vbox.add_child(equipo)

	vbox.add_child(_boton("VOLVER", func(): _mostrar("portada"), C_AZUL, C_AZUL.lightened(0.15)))
	return centro


# ---------- Helpers ----------
func _centro() -> CenterContainer:
	var c := CenterContainer.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	return c


func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.055, 0.094, 0.137, 0.82)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.956, 0.757, 0.306, 0.4)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 26
	sb.content_margin_right = 26
	sb.content_margin_top = 22
	sb.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", sb)
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)
	return panel


func _titulo_panel(txt: String) -> Label:
	var l := Label.new()
	l.text = txt
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ft := Estilo.fuente_titulo()
	if ft:
		l.add_theme_font_override("font", ft)
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", C_SOL)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 2)
	return l


func _boton(txt: String, accion: Callable, base: Color = C_MATE, hover: Color = C_MATE_H) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(320, 52)
	var fu := Estilo.fuente_ui()
	if fu:
		b.add_theme_font_override("font", fu)
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_color_override("font_color", C_CREMA)
	b.add_theme_color_override("font_hover_color", Color("fff2cf"))
	b.add_theme_color_override("font_pressed_color", C_CREMA)
	b.add_theme_color_override("font_focus_color", C_CREMA)
	b.add_theme_stylebox_override("normal", _sb(base))
	b.add_theme_stylebox_override("hover", _sb(hover, C_SOL))
	b.add_theme_stylebox_override("pressed", _sb(base.darkened(0.2)))
	b.add_theme_stylebox_override("focus", _sb(hover, C_SOL))
	b.pressed.connect(accion)
	return b


func _sb(bg: Color, borde: Color = C_BORDE) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.anti_aliasing = false        # bordes duros, look pixel
	sb.set_corner_radius_all(0)     # esquinas cuadradas
	# Borde mas grueso abajo y a la derecha para dar relieve
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


func _texto_como_jugar() -> String:
	return "[center]Sobreviví las oleadas en el barrio: bandadas de [color=#f4c14e]palomas mutantes[/color] y [color=#f4c14e]perros cimarrones[/color] vienen por vos.[/center]\n\n• Cebá mate (tecla [color=#f4c14e]E[/color]) para potenciarte. En [color=#f4c14e]El Calentador[/color] elegís la temperatura del agua.\n• 80° seguro · 100° más buff · 120° máximo poder… pero te quema un poco en cada sorbo.\n• Cambiá entre [color=#f4c14e]mate[/color] (rápido) y [color=#f4c14e]termo[/color] (lento y pesado) según el enemigo.\n• Usá el dash para esquivar. Si tu vida llega a 0, se acabó."


# ---------- Acciones ----------
func _on_jugar() -> void:
	if has_node("/root/Hud"):
		get_node("/root/Hud").visible = true
	get_tree().change_scene_to_file(ESCENA_JUEGO)


func _on_salir() -> void:
	get_tree().quit()
