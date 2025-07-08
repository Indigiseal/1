extends Camera2D

var shake_strength := 0.0
var shake_decay := 5.0
var shake_offset := Vector2.ZERO

func _process(delta):
	if shake_strength > 0:
		shake_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
		offset = shake_offset
		shake_strength = max(shake_strength - shake_decay * delta, 0)
	else:
		offset = Vector2.ZERO

func start_shake(strength: float):
	shake_strength = strength
