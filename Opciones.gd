extends Node
# Opciones de audio: volumen y muteo del bus "Music", guardado entre sesiones.
# Dibuja un control chico abajo a la derecha (altavoz + slider al pasar el mouse).

const BUS_NOMBRE := "Music"
const CFG_PATH := "user://opciones.cfg"

# Paleta del juego
const C_CREMA := Color("f7ead0")
const C_SOL := Color("f4c14e")
const C_YERBA := Color("5c8f3f")
const C_LADRILLO := Color("c6613a")

var volumen: float = 0.8   # 0.0 a 1.0
var muteado: bool = false

var _raiz: HBoxContainer
var _icono: IconoAltavoz
var _caja_slider: PanelContainer
var _slider: HSlider
var _expandido := false


# ---------- Altavoz dibujado a mano ----------
class IconoAltavoz extends Control:
	var muteado := false
	var col := Color("f7ead0")
	var col_off := Color("c6613a")
	var al_click: Callable

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		custom_minimum_size = Vector2(28, 28)
		tooltip_text = "Música (clic para silenciar)"

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if al_click.is_valid():
				al_click.call()

	func _draw() -> void:
		var s := size.x / 28.0
		var c := col_off if muteado else col
		# Cuerpo del parlante (cuello + cono)
		var cuerpo := PackedVector2Array([
			Vector2(4, 11) * s, Vector2(10, 11) * s, Vector2(16, 5) * s,
			Vector2(16, 23) * s, Vector2(10, 17) * s, Vector2(4, 17) * s,
		])
		draw_colored_polygon(cuerpo, c)
		if muteado:
			# Una "X" en vez de ondas
			draw_line(Vector2(19, 9) * s, Vector2(25, 19) * s, col_off, 2.2 * s)
			draw_line(Vector2(25, 9) * s, Vector2(19, 19) * s, col_off, 2.2 * s)
		else:
			# Ondas de sonido
			var centro := Vector2(15, 14) * s
			draw_arc(centro, 5.0 * s, deg_to_rad(-52), deg_to_rad(52), 14, col, 1.7 * s)
			draw_arc(centro, 8.2 * s, deg_to_rad(-52), deg_to_rad(52), 16, col, 1.7 * s)


func _ready() -> void:
	# Que funcione incluso con el juego en pausa (get_tree().paused)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cargar()
	_aplicar()
	_crear_ui()


func _process(_delta: float) -> void:
	if _icono == null:
		return
	# Zona de hover = icono + slider (si se ve), con un margen.
	var mp := _icono.get_viewport().get_mouse_position()
	var r := _icono.get_global_rect()
	if _caja_slider.visible:
		r = r.merge(_caja_slider.get_global_rect())
	r = r.grow(6.0)
	var sobre := r.has_point(mp)
	if sobre != _expandido:
		_expandido = sobre
		_caja_slider.visible = sobre
	# Opacidad suave: mas discreto cuando no se usa.
	var objetivo := 1.0 if _expandido else 0.5
	_raiz.modulate.a = lerpf(_raiz.modulate.a, objetivo, 0.18)


# --- Aplicar al bus de audio ---
func _aplicar() -> void:
	var idx := AudioServer.get_bus_index(BUS_NOMBRE)
	if idx == -1:
		return
	AudioServer.set_bus_mute(idx, muteado)
	AudioServer.set_bus_volume_db(idx, linear_to_db(max(volumen, 0.0001)))


func set_volumen(v: float) -> void:
	volumen = clampf(v, 0.0, 1.0)
	# Si subo el volumen desde 0, lo desmuteo solo
	if volumen > 0.0 and muteado:
		muteado = false
		_refrescar_icono()
	_aplicar()
	_guardar()


func toggle_mute() -> void:
	muteado = not muteado
	_aplicar()
	_guardar()
	_refrescar_icono()


func _refrescar_icono() -> void:
	if _icono:
		_icono.muteado = muteado
		_icono.queue_redraw()


# --- Persistencia ---
func _cargar() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CFG_PATH) == OK:
		volumen = clampf(cfg.get_value("audio", "volumen", 0.8), 0.0, 1.0)
		muteado = bool(cfg.get_value("audio", "muteado", false))


func _guardar() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "volumen", volumen)
	cfg.set_value("audio", "muteado", muteado)
	cfg.save(CFG_PATH)


# --- Control visible (altavoz + slider) en la esquina inferior derecha ---
func _crear_ui() -> void:
	var capa := CanvasLayer.new()
	capa.layer = 128  # por encima del HUD y del menu
	capa.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(capa)

	_raiz = HBoxContainer.new()
	_raiz.add_theme_constant_override("separation", 7)
	_raiz.alignment = BoxContainer.ALIGNMENT_END
	# Franja fija abajo a la derecha; el interior es transparente y deja pasar clics.
	_raiz.anchor_left = 1.0
	_raiz.anchor_right = 1.0
	_raiz.anchor_top = 1.0
	_raiz.anchor_bottom = 1.0
	_raiz.offset_left = -232.0
	_raiz.offset_right = -14.0
	_raiz.offset_top = -44.0
	_raiz.offset_bottom = -12.0
	_raiz.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_raiz.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.modulate = Color(1, 1, 1, 0.5)
	capa.add_child(_raiz)

	# Caja del slider (oculta hasta pasar el mouse)
	_caja_slider = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.055, 0.094, 0.137, 0.80)
	sb.set_border_width_all(1)
	sb.border_color = Color(C_SOL.r, C_SOL.g, C_SOL.b, 0.35)
	sb.set_corner_radius_all(7)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	_caja_slider.add_theme_stylebox_override("panel", sb)
	_caja_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	_caja_slider.visible = false
	_raiz.add_child(_caja_slider)

	_slider = HSlider.new()
	_slider.min_value = 0.0
	_slider.max_value = 1.0
	_slider.step = 0.05
	_slider.value = volumen
	_slider.custom_minimum_size = Vector2(110, 0)
	_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_slider.focus_mode = Control.FOCUS_NONE
	_estilizar_slider(_slider)
	_slider.value_changed.connect(set_volumen)
	_caja_slider.add_child(_slider)

	# Icono del altavoz (a la derecha del todo)
	var ico := IconoAltavoz.new()
	ico.muteado = muteado
	ico.col = C_CREMA
	ico.col_off = C_LADRILLO
	ico.al_click = Callable(self, "toggle_mute")
	_raiz.add_child(ico)
	_icono = ico


func _estilizar_slider(s: HSlider) -> void:
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Color(0.0, 0.0, 0.0, 0.35)
	fondo.set_corner_radius_all(3)
	fondo.content_margin_top = 3
	fondo.content_margin_bottom = 3
	var lleno := StyleBoxFlat.new()
	lleno.bg_color = C_YERBA
	lleno.set_corner_radius_all(3)
	lleno.content_margin_top = 3
	lleno.content_margin_bottom = 3
	s.add_theme_stylebox_override("slider", fondo)
	s.add_theme_stylebox_override("grabber_area", lleno)
	s.add_theme_stylebox_override("grabber_area_highlight", lleno)
