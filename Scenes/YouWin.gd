extends Control

@onready var reward_grid = $MainContainer/RewardGrid
@onready var confirm_label = $MainContainer/ConfirmLabel
@onready var music_player = $VictoryMusic
@onready var main_menu_button = $MainContainer/MainMenuButton

var reward_data = {}
var reward_loader = RewardLoader  # Autoloaded singleton

func _ready():
	print("YouWin _ready() called")
	if music_player:
		music_player.play()
	else:
		print("Music player not found")
	
	# Wait for RewardLoader to be ready and force reload if needed
	await get_tree().process_frame
	
	# Force reload rewards if they're empty
	if RewardLoader.get_all_rewards().is_empty():
		print("🔄 Forcing RewardLoader to reload...")
		RewardLoader.load_rewards()
	
	generate_random_rewards()
	show_reward_choices()

func generate_random_rewards():
	print("generate_random_rewards() called")
	
	# Don't call load_rewards() again - it's already called in RewardLoader's _ready()
	reward_data.clear()
	var all_rewards = []
	var rewards_dict = reward_loader.get_all_rewards()
	
	print("✅ Rewards dict loaded from RewardLoader:", rewards_dict)
	
	# Check if rewards_dict is empty
	if rewards_dict.is_empty():
		print("⚠️ WARNING: rewards_dict is empty! RewardLoader may not have loaded properly.")
		return
	
	for category in rewards_dict.keys():
		for reward in rewards_dict[category]:
			var reward_with_type = reward.duplicate()
			reward_with_type["type"] = category
			reward_with_type["image_path"] = reward["image"]  # Already full path
			all_rewards.append(reward_with_type)
	
	all_rewards.shuffle()
	
	for i in range(min(3, all_rewards.size())):
		reward_data[str(i)] = all_rewards[i]
	
	print("Generated reward_data:", reward_data)

func show_reward_choices():
	if not reward_grid or not confirm_label:
		print("ERROR: reward_grid or confirm_label is null!")
		return
	
	for child in reward_grid.get_children():
		child.queue_free()
	
	confirm_label.text = "Choose one reward:"
	
	for i in reward_data.keys():
		var reward = reward_data[i]
		var tex_button = TextureButton.new()
		
		var texture = load(reward.image_path)
		if texture:
			tex_button.texture_normal = texture
		else:
			print("⚠ Failed to load texture at: " + reward.image_path)
			continue
		
		tex_button.name = i
		tex_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		tex_button.custom_minimum_size = Vector2(128, 128)
		tex_button.pressed.connect(_on_reward_selected.bind(i))
		reward_grid.add_child(tex_button)

func _on_reward_selected(index):
	var selected = reward_data.get(index, null)
	if selected:
		GlobalInventory.add_reward(selected.type, selected.name)
		confirm_label.text = "You picked: " + selected.name
		
		for child in reward_grid.get_children():
			child.queue_free()
		
		var continue_btn = Button.new()
		continue_btn.text = "Continue"
		continue_btn.pressed.connect(_go_to_main_menu)
		reward_grid.add_child(continue_btn)

func _go_to_main_menu():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
