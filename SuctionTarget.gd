extends Node2D

@export var energy_bar_ref: TextureProgressBar
@export var suction_radius: float = 800.0
@export var disappear_radius: float = 20.0

func _ready():
	# Make this invisible - it's just a target point
	visible = false

func get_stars_in_range() -> Array:
	var stars = []
	var all_nodes = get_tree().get_nodes_in_group("bouncy_stars")
	
	for node in all_nodes:
		if node is RigidBody2D:
			var distance = global_position.distance_to(node.global_position)
			if distance <= suction_radius:
				stars.append(node)
	
	return stars

func _physics_process(delta):
	var nearby_stars = get_stars_in_range()
	
	for star in nearby_stars:
		apply_suction_to_star(star, delta)

func apply_suction_to_star(star: RigidBody2D, delta: float):
	var to_target = global_position - star.global_position
	var distance = to_target.length()
	
	if distance <= disappear_radius:
		# Star reached the target
		star_collected(star)
		return
	
	# Apply suction force
	var direction = to_target.normalized()
	var force_strength = 5000.0 * (suction_radius / max(distance, 10.0))
	
	star.apply_central_force(direction * force_strength * delta)
	
	# Also override velocity for more reliable movement
	var desired_velocity = direction * min(800.0, force_strength / 100.0)
	star.linear_velocity = star.linear_velocity.lerp(desired_velocity, 0.2)

func star_collected(star: RigidBody2D):
	# Play cute sound
	if star.has_node("PopSound"):
		star.get_node("PopSound").play()

	# Flash the energy bar
	if energy_bar_ref:
		flash_energy_bar()
	
	# Create disappear effect on the star
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(star, "scale", Vector2.ZERO, 0.15)
	tween.tween_property(star, "modulate:a", 0.0, 0.15)
	tween.tween_property(star, "angular_velocity", star.angular_velocity * 5, 0.15)
	
	tween.tween_callback(star.queue_free).set_delay(0.15)

func flash_energy_bar():
	if not energy_bar_ref:
		return

	var flash_node = energy_bar_ref.get_node("FlashOverlay")
	if not flash_node:
		print("⚠️ No FlashOverlay node found!")
		return

	flash_node.visible = true

	var flash_color := Color(1, 0.5, 1, 0.9)  # soft orange glow (change as you like)
	var transparent := Color(flash_color.r, flash_color.g, flash_color.b, 0.0)

	var tween = create_tween()
	tween.set_parallel(true)

	# Flash 1
	tween.tween_property(flash_node, "modulate", flash_color, 0.03)
	tween.tween_property(flash_node, "modulate", transparent, 0.1).set_delay(0.05)

	# Flash 2

	tween.tween_callback(func(): flash_node.visible = false).set_delay(0.31)
