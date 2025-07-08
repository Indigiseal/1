extends RigidBody2D

@export var suction_strength: float = 4000.0
@export var max_speed: float = 600.0
@export var disappear_distance: float = 4.0

var original_scale: Vector2

func _ready():
	original_scale = scale
	gravity_scale = 0.3
	linear_damp = 0.8
	angular_damp = 0.5

	# Play sound on spawn
	if has_node("EmitSound"):
		$EmitSound.play()

func _physics_process(delta):
	if not is_inside_tree():
		return

	if not has_meta("target_position"):
		return

	var target_position = get_meta("target_position") as Vector2
	var to_target = target_position - global_position
	var distance = to_target.length()

	if distance <= disappear_distance:
		disappear_effect()
		return

	var direction = to_target.normalized()
	var force_strength = suction_strength * (1.0 / max(distance, 10.0))
	apply_central_force(direction * force_strength * delta)

	# Override linear velocity for consistent pull
	var desired_velocity = direction * min(max_speed, force_strength / 100.0)
	linear_velocity = linear_velocity.lerp(desired_velocity, 0.2)

func disappear_effect():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_property(self, "angular_velocity", angular_velocity * 4, 0.15)
	tween.tween_callback(queue_free).set_delay(0.15)
