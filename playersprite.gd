extends Node2D

# Controls floating motion
@export var float_amplitude := 5.0      # How far up/down the cat moves
@export var float_speed := 1.5          # How fast it bobs

@onready var initial_position := position
@onready var smoke_trail := $SmokeTrail

func _process(delta):
	# Smooth vertical floating
	var offset = sin(Time.get_ticks_msec() / 1000.0 * float_speed) * float_amplitude
	position.y = initial_position.y + offset

	# Optional: toggle smoke only when visible/moving
	if smoke_trail:
		smoke_trail.emitting = true
