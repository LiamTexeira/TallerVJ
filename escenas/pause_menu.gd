extends CanvasLayer
# Menu de pausa (tecla P). Incluye el panel de como jugar.

# Paleta del juego
const C_SOL := Color("f4c14e")
const C_CREMA := Color("f7ead0")
const C_YERBA := Color("5c8f3f")
const C_YERBA_H := Color("6ea64a")
const C_BORDE := Color("0e1823")
const C_MATE := Color("4a3018")
const C_MATE_H := Color("6a4a2b")
const C_AZUL := Color("24405a")
const C_AZUL_H := Color("335777")
const C_LADRILLO := Color("8f3b22")
const C_LADRILLO_H := Color("b04d2e")

@onready var menu_pausa: Control = $MenuPause
@onready var fondo: ColorRect = $MenuPause/FondoOscuro
@onready var centro_principal: CenterContainer = $MenuPause/CenterContainer
@onready var vbox: VBoxContainer = $MenuPause/CenterContainer/VBoxContainer
@onready var titulo: Label = $MenuPause/CenterContainer/VBoxContainer/Titulo
@onready var boton_reanudar: Button = $MenuPause/CenterContainer/VBoxContainer/BotonReanudar
@onready var boton_salir: Button = $MenuPause/CenterContainer/VBoxContainer/BotonSalir

var _panel_ayuda: Control


func _ready() -> void:
	# arranca oculto
	menu_pausa.visible = false
	_estilizar()
	_panel_ayuda = _construir_ayuda()
	menu_pausa.add_child(_panel_ayuda)
	_panel_ayuda.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P:
			alternar_pausa()


func alternar_pausa() -> void:
	var pausando := not get_tree().paused
	get_tree().paused = pausando
	menu_pausa.visible = pausando
	if pausando:
		# siempre abrir en la vista principal
		_panel_ayuda.visible = false
		centro_principal.visible = true


func _on_boton_reanudar_pressed() -> void:
	alternar_pausa()


func _on_boton_salir_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")


func _on_como_jugar_pressed() -> void:
	centro_principal.visible = false
	_panel_ayuda.visible = true


func _volver_de_ayuda() -> void:
	_panel_ayuda.visible = false
	centro_principal.visible = true


# ---------- Estilo ----------
func _estilizar() -> void:
	fondo.color = Color(0.03, 0.05, 0.08, 0.80)

	vbox.add_theme_constant_override("separation", 12)

	titulo.text = "JUEGO EN PAUSA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ft := Estilo.fuente_titulo()
	if ft:
		titulo.add_theme_font_override("font", ft)
	titulo.add_theme_font_size_override("font_size", 28)
	titulo.add_theme_color_override("font_color", C_SOL)
	titulo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	titulo.add_theme_constant_override("shadow_offset_x", 3)
	titulo.add_theme_constant_override("shadow_offset_y", 3)

	if vbox.has_node("Espaciador"):
		var esp := vbox.get_node("Espaciador") as Control
		esp.custom_minimum_size = Vector2(0, 14)

	_estilizar_boton(boton_reanudar, "REANUDAR", C_YERBA, C_YERBA_H)
	_estilizar_boton(boton_salir, "SALIR AL MENÚ", C_LADRILLO, C_LADRILLO_H)

	# Boton nuevo entre Reanudar y Salir
	var b := Button.new()
	_estilizar_boton(b, "CÓMO JUGAR", C_MATE, C_MATE_H)
	b.pressed.connect(_on_como_jugar_pressed)
	vbox.add_child(b)
	vbox.move_child(b, boton_salir.get_index())


func _estilizar_boton(b: Button, txt: String, base: Color, hover: Color) -> void:
	b.text = txt
	b.custom_minimum_size = Vector2(320, 50)
	b.focus_mode = Control.FOCUS_NONE
	var fu := Estilo.fuente_ui()
	if fu:
		b.add_theme_font_override("font", fu)
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", C_CREMA)
	b.add_theme_color_override("font_hover_color", Color("fff2cf"))
	b.add_theme_color_override("font_pressed_color", C_CREMA)
	b.add_theme_stylebox_override("normal", _sb(base))
	b.add_theme_stylebox_override("hover", _sb(hover, C_SOL))
	b.add_theme_stylebox_override("pressed", _sb(base.darkened(0.2)))
	b.add_theme_stylebox_override("focus", _sb(base))


func _sb(bg: Color, borde: Color = C_BORDE) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.anti_aliasing = false        # bordes duros, look pixel
	sb.set_corner_radius_all(0)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 4
	sb.border_width_bottom = 5
	sb.border_color = borde
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 9
	sb.content_margin_bottom = 11
	return sb


# ---------- Panel como jugar ----------
func _construir_ayuda() -> Control:
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.055, 0.094, 0.137, 0.92)
	sb.set_border_width_all(2)
	sb.border_color = Color(C_SOL.r, C_SOL.g, C_SOL.b, 0.45)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 26
	sb.content_margin_right = 26
	sb.content_margin_top = 20
	sb.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", sb)
	centro.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	panel.add_child(vb)

	var tit := Label.new()
	tit.text = "CÓMO JUGAR"
	tit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ft := Estilo.fuente_titulo()
	if ft:
		tit.add_theme_font_override("font", ft)
	tit.add_theme_font_size_override("font_size", 20)
	tit.add_theme_color_override("font_color", C_SOL)
	vb.add_child(tit)

	var intro := RichTextLabel.new()
	intro.bbcode_enabled = true
	intro.fit_content = true
	intro.scroll_active = false
	intro.custom_minimum_size = Vector2(440, 0)
	var fu := Estilo.fuente_ui()
	if fu:
		intro.add_theme_font_override("normal_font", fu)
	intro.add_theme_font_size_override("normal_font_size", 15)
	intro.add_theme_color_override("default_color", C_CREMA)
	intro.text = "[center]Sobreviví las oleadas. Cebá mate ([color=#f4c14e]E[/color]) para potenciarte y esquivá con el dash.[/center]"
	vb.add_child(intro)

	var filas := [
		["Moverse", "WASD / Flechas"],
		["Dash / esquivar", "J"],
		["Atacar", "K  /  X"],
		["Cambiar arma", "4 (mate) · 5 (termo)"],
		["Cebar mate", "E"],
		["Interactuar (NPCs)", "F"],
		["Reanudar / pausa", "P"],
	]
	for f in filas:
		var fila := HBoxContainer.new()
		fila.custom_minimum_size = Vector2(440, 0)
		var a := Label.new()
		a.text = f[0]
		if fu:
			a.add_theme_font_override("font", fu)
		a.add_theme_font_size_override("font_size", 15)
		a.add_theme_color_override("font_color", C_CREMA)
		a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(a)
		var t := Label.new()
		t.text = f[1]
		if fu:
			t.add_theme_font_override("font", fu)
		t.add_theme_font_size_override("font_size", 15)
		t.add_theme_color_override("font_color", C_SOL)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		fila.add_child(t)
		vb.add_child(fila)

	var volver := Button.new()
	_estilizar_boton(volver, "VOLVER", C_AZUL, C_AZUL_H)
	volver.pressed.connect(_volver_de_ayuda)
	vb.add_child(volver)

	return centro
