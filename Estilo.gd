extends RefCounted
class_name Estilo
# Fuentes del juego: titulo (Press Start 2P) y UI (Pixelify Sans).
# Se cargan una sola vez y se comparten.

const RUTA_TITULO := "res://Assets/fonts/PressStart2P-Regular.ttf"
const RUTA_UI := "res://Assets/fonts/PixelifySans.ttf"

static var _titulo: FontFile
static var _ui: FontFile


static func fuente_ui() -> FontFile:
	if _ui == null:
		_ui = _cargar(RUTA_UI)
		if _ui:
			_ui.fallbacks = [_sistema()]
	return _ui


static func fuente_titulo() -> FontFile:
	if _titulo == null:
		_titulo = _cargar(RUTA_TITULO)
		if _titulo:
			# Si al titulo le falta un glifo, cae a la UI y despues al sistema.
			var ui := fuente_ui()
			_titulo.fallbacks = [ui] if ui else [_sistema()]
	return _titulo


static func _cargar(ruta: String) -> FontFile:
	if not ResourceLoader.exists(ruta):
		return null
	var f := load(ruta) as FontFile
	if f == null:
		return null
	# Pixeles nitidos
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.hinting = TextServer.HINTING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.force_autohinter = false
	return f


static func _sistema() -> SystemFont:
	var sf := SystemFont.new()
	sf.font_names = PackedStringArray(["Noto Sans", "Segoe UI", "Arial"])
	return sf
