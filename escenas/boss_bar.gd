extends CanvasLayer

@onready var nombre: Label = $Raiz/Contenedor/Nombre
@onready var barra: ProgressBar = $Raiz/Contenedor/Barra

func conectar(jefe: Jefe) -> void:
	nombre.text = jefe.nombre_jefe
	barra.max_value = jefe.vida_maxima
	barra.value = jefe.vida_actual
	jefe.vida_cambiada.connect(_on_vida_cambiada)
	jefe.jefe_muerto.connect(queue_free)   # la barra desaparece con el jefe

func _on_vida_cambiada(actual, _maxima) -> void:
	create_tween().tween_property(barra, "value", actual, 0.2)
