extends Node

@onready var main_menu_button = $MainMenuButton
@onready var reward_grid = $VBoxContainer/RewardGrid

const SAVE_PATH = "user://save_data/rewards.json"
var rewards: Array = []

func _ready():
	load_rewards()
	
	if reward_grid:
		show_icons()
	else:
		print("❌ reward_grid is null - check node path!")

	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	else:
		print("❌ main_menu_button is null - check node path!")

func load_rewards():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var text = file.get_as_text()
			var result = JSON.parse_string(text)
			if typeof(result) == TYPE_ARRAY:
				rewards = result
				print("✅ Rewards loaded: ", rewards)
			else:
				push_error("❌ Failed to parse rewards.json as array")
			file.close()
	else:
		print("⚠ No save file found at: ", SAVE_PATH)

func show_icons():
	if reward_grid == null:
		print("❌ reward_grid is null in show_icons!")
		return

	for child in reward_grid.get_children():
		child.queue_free()

	for reward in rewards:
		var image_path = reward.get("image", "")
		if image_path != "":
			var texture := load(image_path)
			if texture:
				var icon = TextureButton.new()
				icon.texture_normal = texture
				icon.stretch_mode = TextureButton.STRETCH_KEEP

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
