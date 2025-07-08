extends Node2D

func _ready():
	$AnimatedSprite2D.play("zap")
	$ZapSFX.play()
	await get_tree().create_timer(0.4).timeout
	queue_free()

	# Remove after short delay
	await get_tree().create_timer(0.4).timeout
	queue_free()
