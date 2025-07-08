extends Node2D

@onready var impact_sprite = $PinkLightning
@onready var animation_player = $AnimationPlayer

func _ready():
	# Play the animation when the node is ready
	animation_player.play("zap")

	# Queue free after animation finishes
	animation_player.connect("animation_finished", _on_animation_finished)

func _on_animation_finished(anim_name: String):
	if anim_name == "zap":
		queue_free()
