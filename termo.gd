extends Weapon

func _ready() -> void:
	super._ready()
	damage = 30
	stamina_cost = 35.0
	attack_duration = 0.6   # lento
	cooldown = 0.4


func _play_attack_animation() -> void:
	sprite.play("swing_heavy")
	# Activás el hitbox a mitad del swing, no desde el frame 0,
	# para que el golpe coincida con el momento visual del impacto
	await get_tree().create_timer(attack_duration * 0.4).timeout
	_enable_hitbox()
	await get_tree().create_timer(attack_duration * 0.4).timeout
	_finish_attack()
