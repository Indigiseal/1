extends Node2D

@onready var word_manager = $WordManager
@onready var WordTarget = preload("res://Effects/Scenes/WordTarget.tscn")
@onready var ZapHitScene = preload("res://Effects/Scenes/ZapHit.tscn")
@onready var StarDustScene = preload("res://Effects/Scenes/StarDust.tscn")
@onready var BouncyStarScene = preload("res://Effects/Scenes/BouncyStar.tscn")
@onready var BouncyStarVariantScene = preload("res://Effects/Scenes/BouncyStarVariant.tscn")
@onready var voice_player = $VoicePlayer
@onready var player = $Player
# UI references
@onready var heart1 = $UI/HBoxContainer/HeartBar/Heart1
@onready var heart2 = $UI/HBoxContainer/HeartBar/Heart2
@onready var heart3 = $UI/HBoxContainer/HeartBar/Heart3
@onready var energy_bar = $UI/HBoxContainer/EnergyBar
# Textures
@onready var heart_full = preload("res://Effects/UIbar/heart_full.png")
@onready var heart_empty = preload("res://Effects/UIbar/heart_empty.png")

# Game state
var correct_word = ""
var energy = Global.energy  # Pull from Global at scene start

const MAX_HEALTH = 3
var health = MAX_HEALTH

const MAX_ENERGY = 120
var word_attempts: Dictionary = {}

var suction_target: Node2D
var current_word_stream: AudioStream = null

func _ready():
	randomize()
	setup_suction_target()
	update_hearts()

	# 🔧 DEBUG: Print initial state
	WordSelection.print_debug_info()

	# Step 1: Load all words
	word_manager.load_words_from_json("res://Data/word_data.json")

	# Step 2: Filter to only selected 12 preview words
	var selected_words = WordSelection.selected_words
	var filtered_data := {}

	for word in selected_words:
		if word_manager.words_data.has(word):
			filtered_data[word] = word_manager.words_data[word]

	# Step 3: Replace words_data with filtered set
	word_manager.words_data = filtered_data

	# Step 4: Continue normally
	spawn_targets()

func setup_suction_target():
	suction_target = Node2D.new()
	suction_target.name = "SuctionTarget"

	var suction_script = load("res://SuctionTarget.gd")
	suction_target.set_script(suction_script)

	await get_tree().process_frame
	var energy_bar_world_pos = energy_bar.get_global_rect().get_center()
	suction_target.global_position = energy_bar_world_pos

	add_child(suction_target)
	suction_target.energy_bar_ref = energy_bar
	
	
func _on_repeat_button_pressed():
	if current_word_stream:
		voice_player.stream = current_word_stream
		voice_player.play()
		
func check_word(word_clicked):
	print("🖱 You clicked:", word_clicked)

	var clicked_target: Node = null
	var clicked_index := -1

	# Find which word was clicked and its index
	var i := 0
	for child in get_children():
		if child is Area2D and "word_text" in child and child.word_text == word_clicked:
			clicked_target = child
			clicked_index = i
			break
		if child is Area2D and "word_text" in child:
			i += 1

	if clicked_target == null:
		print("⚠️ Clicked target not found!")
		return

	# Track attempts if not yet initialized
	if not word_attempts.has(correct_word):
		word_attempts[correct_word] = 0

	# ✅ Correct word clicked
	if word_clicked == correct_word:
		print("✅ Correct!")
		word_manager.mark_word_correct(correct_word)

		# ✅ Track this word as mastered
		if not WordSelection.mastered_words.has(correct_word):
			WordSelection.mastered_words.append(correct_word)

		# Monster hit effects
		var monster = get_node_or_null("EnemyMonster")
		if monster:
			var lightning_scene = preload("res://Effects/Scenes/Lightning.tscn")
			var lightning = lightning_scene.instantiate()
			lightning.global_position = monster.global_position
			add_child(lightning)

			if monster.has_method("play_hit_animation"):
				monster.play_hit_animation()
		else:
			print("⚠️ No monster or method found")

		# Sparkles at clicked word
		if clicked_target.has_node("WordLabel"):
			spawn_star_dust_collision(clicked_target.get_node("WordLabel").global_position)
		else:
			spawn_star_dust_collision(clicked_target.global_position)

		# Energy increase logic based on attempts
		var attempts = word_attempts[correct_word]
		if attempts == 0:
			energy += 10
		elif attempts == 1:
			energy += 5
		else:
			energy += 0

		word_attempts.erase(correct_word)  # Clear attempts for next word

		energy = clamp(energy, 0, MAX_ENERGY)
		Global.energy = energy  # Save to global
		update_energy_bar()

		# Debug info and batch handling
		WordSelection.print_debug_info()
		if WordSelection.is_current_batch_complete():
			print("🎉 Current batch completed!")
			if WordSelection.current_batch_index == 1:
				print("🚪 First batch complete - Entering Boss Room...")
				get_tree().change_scene_to_file("res://Scenes/BossFight.tscn")
			else:
				print("📚 Moving to next word batch")
				var next_batch = WordSelection.advance_to_next_batch(12)
				WordSelection.selected_words = next_batch
				get_tree().reload_current_scene()
			return

	else:
		print("❌ Wrong!")
		word_attempts[correct_word] += 1  # Count this as a miss
		health -= 1
		update_hearts()
		if health <= 0:
			game_over()
			return

	# Clear old targets
	for child in get_children():
		if child.name == "WordTarget" or (child is Area2D and "word_text" in child):
			var cleanup_timer := get_tree().create_timer(0.3)
			cleanup_timer.timeout.connect(child.queue_free)

	await get_tree().create_timer(0.6).timeout
	spawn_targets()


func update_energy_bar():
	var tween = create_tween()
	tween.tween_property(energy_bar, "value", energy, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func update_hearts():
	var hearts = [heart1, heart2, heart3]
	for i in range(MAX_HEALTH):
		hearts[i].texture = heart_full if i < health else heart_empty

func game_over():
	print("💀 GAME OVER")
	get_tree().paused = true
	
func _on_quit_button_pressed():
	get_tree().quit()
	
func spawn_targets():
	# 🔧 FIXED: Ensure correct word is always in the displayed options
	var unmastered = []
	for word in WordSelection.selected_words:
		if not WordSelection.mastered_words.has(word):
			unmastered.append(word)

	print("🔍 Unmastered words for this round:", unmastered)

	# Step 1: Choose the correct word first (prefer unmastered)
	if unmastered.size() > 0:
		correct_word = unmastered.pick_random()
	else:
		# Fallback: if no unmastered words, pick from all selected words
		correct_word = WordSelection.selected_words.pick_random()

	print("🔊 Correct word is:", correct_word)

	# Step 2: Build options array starting with the correct word
	var options = [correct_word]

	# Step 3: Add 2 more words to make 3 total
	var remaining_words = WordSelection.selected_words.duplicate()
	remaining_words.erase(correct_word)  # Remove correct word so we don't duplicate it

	# Prefer adding unmastered words first
	var remaining_unmastered = []
	for word in remaining_words:
		if not WordSelection.mastered_words.has(word):
			remaining_unmastered.append(word)

	# Add unmastered words first
	while options.size() < 3 and remaining_unmastered.size() > 0:
		var word_to_add = remaining_unmastered.pick_random()
		options.append(word_to_add)
		remaining_unmastered.erase(word_to_add)
		remaining_words.erase(word_to_add)

	# If we still need more words, add mastered ones
	while options.size() < 3 and remaining_words.size() > 0:
		var word_to_add = remaining_words.pick_random()
		options.append(word_to_add)
		remaining_words.erase(word_to_add)

	# If we still don't have 3 words (shouldn't happen), fill with any available
	if options.size() < 3:
		var all_available = WordSelection.selected_words.duplicate()
		while options.size() < 3 and all_available.size() > 0:
			var word_to_add = all_available.pick_random()
			if not options.has(word_to_add):
				options.append(word_to_add)
			all_available.erase(word_to_add)

	# Shuffle the options so correct word isn't always first
	options.shuffle()

	print("🎯 Final options to display:", options)
	print("✅ Correct word '", correct_word, "' is in options:", options.has(correct_word))

	# Debug
	print("🔍 Available words in data:", word_manager.words_data.keys())

	# Get sound path
	var word_data = word_manager.words_data.get(correct_word, {})
	var sound_path = ""

	if word_data is Dictionary:
		if word_data.has("sound_path"):
			var sound_data = word_data["sound_path"]
			if sound_data is String:
				sound_path = sound_data
			elif sound_data is Dictionary and sound_data.has("sound_path"):
				sound_path = sound_data["sound_path"]

	print("📁 Final sound_path:", sound_path)

	# Play the sound
	if sound_path is String and sound_path != "":
		if ResourceLoader.exists(sound_path):
			current_word_stream = load(sound_path)
			voice_player.stream = current_word_stream
			voice_player.play()
			print("✅ Sound loaded and playing:", sound_path)
		else:
			print("❌ Sound file not found:", sound_path)
			current_word_stream = null
	else:
		print("⚠️ Invalid sound path")
		current_word_stream = null

	# Display words
	var screen_size = get_viewport().get_visible_rect().size
	var center_x = screen_size.x * 0.5
	var start_y = screen_size.y * 0.25
	var spacing = 70

	for i in range(options.size()):
		var word_target = WordTarget.instantiate()
		add_child(word_target)

		word_target.word_text = options[i]

		if word_target.has_node("WordLabel"):
			word_target.get_node("WordLabel").text = options[i]

		var position = Vector2(center_x, start_y + (i * spacing))
		word_target.global_position = position

		print("📍 Spawned word target:", options[i], "at position:", position)

		
func spawn_star_dust_collision(from_pos: Vector2):
	for i in range(randi_range(3, 6)):
		var use_variant = randf() < 0.25
		var star_scene = BouncyStarVariantScene if use_variant else BouncyStarScene
		var star = star_scene.instantiate()
		add_child(star)

		star.global_position = from_pos
		star.add_to_group("bouncy_stars")

		var random_direction = Vector2.from_angle(randf() * TAU)
		star.linear_velocity = random_direction * randf_range(80, 150)
		star.angular_velocity = randf_range(-8, 8)

		# 🧁 Play the cute sound!
		var sound_player = star.get_node_or_null("EmitSound")
		if sound_player:
			sound_player.play()
