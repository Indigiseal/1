extends Node2D

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("zap")
	await get_tree().create_timer(0.4).timeout
	queue_free()
