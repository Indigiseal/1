extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10

var direction: Vector2 = Vector2.ZERO

func _ready():
	print("🟢 PlayerShot ready at:", global_position)
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	# Move the projectile in the direction it was fired
	global_position += direction * speed * delta

	# Remove projectile if it goes off screen (optional cleanup)
	if global_position.x < -100 or global_position.x > 1200 or global_position.y < -100 or global_position.y > 800:
		queue_free()

func _on_area_entered(area):
	print("🎯 Hit detected with:", area.name)
	if area.name == "Boss":
		print("💥 Boss hit! Calling damage.")
		# ✅ Correct way to call function in BossFight.gd
		get_tree().current_scene.call("take_damage", damage)
		queue_free()
