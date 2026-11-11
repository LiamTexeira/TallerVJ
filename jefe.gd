extends CharacterBody2D
class_name Jefe

signal vida_cambiada(actual, maxima)
signal jefe_muerto

enum Estado { ENTRADA, PERSECUCION, TELEGRAFIA, ATAQUE, MUERTE }

@export var nombre_jefe := "El Braian"
@export var vida_maxima := 40
@export var velocidad := 45.0
@export var velocidad_carga := 220.0
@export var rango_melee := 45.0
@export var danio_contacto := 10
@export var rango_carga := 160.0   # a qué distancia se anima a embestir
@export var barra_scene: PackedScene   # boss_bar.tscn

var vida_actual: int
var fase := 1
var estado := Estado.ENTRADA
var cooldown_ataque := 2.0
var carga_vel := Vector2.ZERO
var objetivo: Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_dano: Area2D = $AreaDano
@onready var area_dano_col: CollisionShape2D = $AreaDano/CollisionShape2D


func _ready() -> void:
	vida_actual = vida_maxima
	area_dano_col.disabled = true
	objetivo = get_tree().get_first_node_in_group("Player")

	# Barra de vida: aparece junto con el jefe
	if barra_scene:
		var barra = barra_scene.instantiate()
		get_tree().current_scene.add_child.call_deferred(barra)
		await barra.ready          # espera a que la barra esté lista
		barra.conectar(self)

	# Entrada: unos segundos sin poder ser herido ni atacar
	await get_tree().create_timer(1.5).timeout
	if estado != Estado.MUERTE:
		estado = Estado.PERSECUCION


func _physics_process(delta: float) -> void:
	if estado == Estado.MUERTE:
		return
	cooldown_ataque = max(cooldown_ataque - delta, 0.0)

	match estado:
		Estado.PERSECUCION:
			_perseguir()
		Estado.ATAQUE:
			velocity = carga_vel
			_danio_por_contacto()
		_:
			velocity = Vector2.ZERO

	move_and_slide()
	_animar()


func _perseguir() -> void:
	if not is_instance_valid(objetivo):
		objetivo = get_tree().get_first_node_in_group("Player")
		velocity = Vector2.ZERO
		return
	var dir := (objetivo.global_position - global_position).normalized()
	velocity = dir * velocidad * (1.0 if fase == 1 else 1.4)

	if cooldown_ataque <= 0.0:
		_elegir_ataque()


var ultimo_ataque := ""

func _elegir_ataque() -> void:
	var dist := global_position.distance_to(objetivo.global_position)
	var ataque := ""

	if dist <= rango_melee:
		ataque = "melee"
	elif dist <= rango_carga:
		ataque = "carga"
	else:
		return  # muy lejos: sigue persiguiendo

	# Si está cerca y repite, que igual golpee; la carga no se repite seguida
	if ataque == "carga" and ultimo_ataque == "carga":
		return

	ultimo_ataque = ataque
	match ataque:
		"melee": _ataque_melee()
		"carga": _ataque_carga()



# ---------- ATAQUES ----------

func _ataque_melee() -> void:
	if not await _telegrafiar(0.5): return
	var dir := (objetivo.global_position - global_position).normalized()
	area_dano.position = dir * 24.0   # el golpe sale hacia el jugador
	estado = Estado.ATAQUE
	area_dano_col.disabled = false
	await get_tree().create_timer(0.3).timeout
	area_dano.position = Vector2.ZERO
	_terminar_ataque()


func _ataque_carga() -> void:
	if not await _telegrafiar(0.7): return
	# La dirección se fija al empezar: el jugador puede esquivar
	var dir := (objetivo.global_position - global_position).normalized()
	estado = Estado.ATAQUE
	area_dano_col.disabled = false
	carga_vel = dir * velocidad_carga
	await get_tree().create_timer(0.5).timeout
	_terminar_ataque()


# Aviso visual antes de atacar. Devuelve false si el jefe murió mientras tanto.
func _telegrafiar(tiempo: float) -> bool:
	estado = Estado.TELEGRAFIA
	sprite.modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(tiempo).timeout
	sprite.modulate = Color.WHITE
	return estado != Estado.MUERTE


func _terminar_ataque() -> void:
	if estado == Estado.MUERTE:
		return
	area_dano_col.disabled = true
	carga_vel = Vector2.ZERO
	cooldown_ataque = 2.0 if fase == 1 else 1.2
	estado = Estado.PERSECUCION
	area_dano.position = Vector2.ZERO


func _danio_por_contacto() -> void:
	if area_dano_col.disabled:
		return
	for body in area_dano.get_overlapping_bodies():
		if body.is_in_group("Player") and body.has_method("recibir_danio"):
			body.recibir_danio(danio_contacto)  # la invulnerabilidad del jugador evita golpes repetidos


# ---------- VIDA ----------

func recibir_danio(cantidad: int) -> void:
	if estado == Estado.MUERTE or estado == Estado.ENTRADA:
		return
	vida_actual = max(vida_actual - cantidad, 0)
	vida_cambiada.emit(vida_actual, vida_maxima)

	# Destello al recibir golpe (si no está telegrafiando)
	if estado != Estado.TELEGRAFIA:
		sprite.modulate = Color(2, 2, 2)
		get_tree().create_timer(0.08).timeout.connect(func():
			if estado != Estado.MUERTE and estado != Estado.TELEGRAFIA:
				sprite.modulate = Color.WHITE)

	if vida_actual <= 0:
		_morir()
	elif fase == 1 and vida_actual <= vida_maxima / 2:
		fase = 2
		print("¡Fase 2!")


func _morir() -> void:
	estado = Estado.MUERTE
	velocity = Vector2.ZERO
	area_dano_col.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	jefe_muerto.emit()
	if sprite.sprite_frames.has_animation("death"):
		sprite.sprite_frames.set_animation_loop("death", false)
		sprite.play("death")
		await sprite.animation_finished
	else:
		await get_tree().create_timer(1.0).timeout
	queue_free()


func _animar() -> void:
	if estado == Estado.PERSECUCION:
		if velocity.x != 0.0:
			sprite.flip_h = velocity.x < 0.0
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
	elif estado == Estado.ENTRADA or estado == Estado.TELEGRAFIA:
		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
