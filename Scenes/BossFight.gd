extends Node2D

@onready var player_shot_scene = preload("res://Scenes/PLayerShot.tscn")
@onready var boss_sprite = $Boss/AnimatedSprite2D
@onready var boss_health_bar = $CanvasLayer/BossHealthBar
@onready var shoot_sound = $HitSound
@onready var energy_bar = $CanvasLayer/EnergyBar
@onready var player = $Player
@onready var fight_music = $FightMusic

var boss_start_y := 0.0
var bob_timer := 0.0
var bob_speed := 2.0
var bob_height := 40.0
var boss_health = 100
const MAX_BOSS_HEALTH = 100
const MAX_ENERGY = 120
var shooting = false
var shoot_timer := 0.0
var shoot_interval := 0.2
var boss_defeated = false

func _ready():
	boss_start_y = boss_sprite.global_position.y
	setup_dissolve_material()

	if OS.is_debug_build():
		Global.energy = 120

	energy_bar.max_value = MAX_ENERGY
	energy_bar.value = Global.energy

	boss_health = MAX_BOSS_HEALTH
	if boss_health_bar:
		boss_health_bar.max_value = MAX_BOSS_HEALTH
		boss_health_bar.value = boss_health

	if fight_music:
		fight_music.play()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		shooting = event.pressed

func _process(delta):
	if boss_defeated:
		return

	if shooting and Global.energy >= 5:
		shoot_timer += delta
		if shoot_timer >= shoot_interval:
			shoot_timer = 0.0
			shoot_projectile()

	bob_timer += delta
	var offset_y = sin(bob_timer * bob_speed) * bob_height
	boss_sprite.global_position.y = boss_start_y + offset_y

func shoot_projectile():
	var shot = player_shot_scene.instantiate()
	add_child(shot)
	shot.global_position = player.global_position
	var direction = (boss_sprite.global_position - player.global_position).normalized()
	shot.direction = direction

	Global.energy -= 5
	energy_bar.value = Global.energy

func take_damage(amount: int):
	if boss_defeated:
		return

	boss_health -= amount
	boss_health = clamp(boss_health, 0, MAX_BOSS_HEALTH)
	update_health_bar()
	animate_hit()

	if boss_health <= 0:
		boss_defeated = true
		start_dissolve_effect()
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://Scenes/YouWin.tscn")

func update_health_bar():
	if boss_health_bar:
		boss_health_bar.value = boss_health

func animate_hit():
	if boss_sprite and not boss_defeated:
		var tween = create_tween()
		tween.tween_property(boss_sprite, "scale", Vector2(1.2, 1.2), 0.05)
		tween.tween_property(boss_sprite, "scale", Vector2(1, 1), 0.1)

func start_dissolve_effect():
	print("Starting dissolve effect...")

	if not boss_sprite:
		print("Error: boss_sprite is null!")
		return

	if fight_music and fight_music.playing:
		fight_music.stop()

	var victory_music = get_node_or_null("VictoryMusic")
	if victory_music:
		victory_music.play()

	var camera = get_node_or_null("MainCamera")
	if camera and camera.has_method("start_shake"):
		camera.start_shake(10.0)

	var mat: Material = boss_sprite.material
	if not mat or not mat is ShaderMaterial:
		print("No dissolve shader found, using simple fade effect...")
		var fade_tween = create_tween()
		fade_tween.tween_property(boss_sprite, "modulate:a", 0.0, 1.5)
		fade_tween.tween_callback(func(): boss_sprite.queue_free())
		return

	var shader_mat = mat as ShaderMaterial
	if not shader_mat.shader:
		print("Error: ShaderMaterial has no shader assigned!")
		return

	if not shader_mat.get_property_list().any(func(prop): return prop.name == "shader_parameter/dissolve_amount"):
		print("Error: Shader doesn't have 'dissolve_amount' parameter!")
		return

	print("All checks passed, starting dissolve tween...")
	shader_mat.set_shader_parameter("dissolve_amount", 0.0)
	var dissolve_tween = create_tween()
	dissolve_tween.tween_property(shader_mat, "shader_parameter/dissolve_amount", 1.0, 1.5)
	dissolve_tween.tween_callback(func(): boss_sprite.queue_free())

func _on_quit_button_pressed():
	get_tree().quit()

func setup_dissolve_material():
	if not boss_sprite:
		print("Error: Boss sprite not found!")
		return

	if boss_sprite.material and boss_sprite.material is ShaderMaterial:
		print("Boss already has a ShaderMaterial")
		return

	var shader_material = ShaderMaterial.new()
	var shader_path = "res://Shaders/dissolve_shader.gdshader"
	if ResourceLoader.exists(shader_path):
		var dissolve_shader = load(shader_path)
		shader_material.shader = dissolve_shader
		print("Loaded existing dissolve shader")
	else:
		print("Dissolve shader not found at: " + shader_path)
		print("Please create the dissolve shader manually in the editor")
		return

	shader_material.set_shader_parameter("dissolve_amount", 0.0)
	boss_sprite.material = shader_material
