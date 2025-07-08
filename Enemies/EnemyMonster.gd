extends Node2D

@onready var animation_player = $AnimationPlayer

func play_hit_animation():
	if animation_player.has_animation("hit"):
		animation_player.play("hit")
