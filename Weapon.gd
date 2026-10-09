extends Node2D
class_name Weapon

@export var damage: int = 10
@export var stamina_cost: float = 20.0
@export var attack_duration: float = 0.3  # cuánto tarda la animación completa
@export var cooldown: float = 0.2         # tiempo antes de poder atacar de nuevo

var can_attack := true
var hit_targets: Array = []  # evita golpear al mismo enemigo varias veces en un swing

@onready var hitbox: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal attack_finished

func _ready() -> void:
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func do_attack() -> void:
	if not can_attack:
		return
	can_attack = false
	hit_targets.clear()
	_play_attack_animation()


func _play_attack_animation() -> void:
	# Cada arma sobreescribe esto con su propio comportamiento
	pass


func _enable_hitbox() -> void:
	hitbox.monitoring = true


func _disable_hitbox() -> void:
	hitbox.monitoring = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body in hit_targets:
		return
	if body.has_method("take_damage"):
		hit_targets.append(body)
		body.take_damage(damage)


func _finish_attack() -> void:
	_disable_hitbox()
	attack_finished.emit()
	await get_tree().create_timer(cooldown).timeout
	can_attack = true
