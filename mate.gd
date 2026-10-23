extends Weapon

func _ready() -> void:
	super._ready()
	damage = 12
	stamina_cost = 12.0
	attack_duration = 0.15  # rápido
	cooldown = 0.1


func _play_attack_animation() -> void:
	sprite.play("swing_fast")
	_enable_hitbox()
	var tween := create_tween()
	tween.tween_property(hitbox, "position", Vector2(40, 0), 0.1)
	tween.tween_property(hitbox, "position", Vector2(10, 0), 0.1)
	await tween.finished
	_finish_attack()
