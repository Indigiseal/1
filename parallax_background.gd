extends ParallaxBackground

@export var scroll_speed := Vector2(-100, 0)

func _process(delta):
	# Use scroll_base_offset instead of scroll_offset for absolute movement
	scroll_base_offset += scroll_speed * delta
