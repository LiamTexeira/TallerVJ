extends Node

# Señal que notifica a la interfaz (HUD) cuando la vida cambia
signal vida_cambiada(nueva_vida: int, vida_maxima: int)

# Valores de temperatura validos GDD
enum TemperaturaAgua { TEMP_80 = 80, TEMP_100 = 100, TEMP_120 = 120 }

# Temperatura seleccionada para toda la expedición
var temperatura_actual: int = TemperaturaAgua.TEMP_80

# Modificadores de mecanica según la temperatura elegida
var multiplicador_buff_yerba: float = 1.0
var dano_quemadura_por_sorbo: int = 0

# Estado general del jugador con setter que limita la vida y emite la señal
var vida_maxima: int = 100
var vida_actual: int = 100:
	set(valor):
		vida_actual = clampi(valor, 0, vida_maxima)
		vida_cambiada.emit(vida_actual, vida_maxima)


func iniciar_expedicion(temperatura: int) -> void:
	temperatura_actual = temperatura
	
	match temperatura_actual:
		TemperaturaAgua.TEMP_80:
			multiplicador_buff_yerba = 1.0
			dano_quemadura_por_sorbo = 0
			print("Expedición iniciada a 80°C (Estándar)")
			
		TemperaturaAgua.TEMP_100:
			multiplicador_buff_yerba = 1.25
			dano_quemadura_por_sorbo = 0
			print("Expedición iniciada a 100°C (Agua hirviendo / +25% Buff)")
			
		TemperaturaAgua.TEMP_120:
			multiplicador_buff_yerba = 2.0  # Buffs al doble
			dano_quemadura_por_sorbo = 5    # Leve daño por quemadura al cebar
			print("Expedición iniciada a 120°C (Doble buff / Daño por quemadura)")
	
	# Restablecer vida inicial (al usar 'self.' activa el setter y notifica a la UI)
	self.vida_actual = vida_maxima
	
	# Transicion al nivel 1
	if ResourceLoader.exists("res://level1.tscn"):
		get_tree().change_scene_to_file("res://level1.tscn")
	else:
		print("AVISO: Cambia la ruta en RunManager.gd a la escena de tu mapa actual.")


func recibir_danio(cantidad: int) -> void:
	self.vida_actual -= cantidad
