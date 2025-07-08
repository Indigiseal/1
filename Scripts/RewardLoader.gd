extends Node

var all_rewards = {}
var icon_lookup = {}

func _ready():
	print("🔄 RewardLoader _ready() starting...")
	load_rewards()
	generate_icon_lookup()
	print("🔄 RewardLoader _ready() finished. all_rewards has ", all_rewards.size(), " categories")

func load_rewards():
	print("RewardLoader: Attempting to load rewards.json")
	
	var file_path = "res://Assets/rewards.json"
	
	# Check if file exists
	if not FileAccess.file_exists(file_path):
		push_error("❌ RewardLoader: File not found at " + file_path)
		# Try to list what files ARE in the directory
		var dir = DirAccess.open("res://Assets/Rewards/")
		if dir:
			print("📁 Files in res://Assets/Rewards/:")
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				print("  - " + file_name)
				file_name = dir.get_next()
			dir.list_dir_end()
		else:
			print("📁 Could not open res://Assets/Rewards/ directory")
		return
	
	print("✅ File exists at: " + file_path)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("❌ RewardLoader: Could not open rewards.json")
		var error = FileAccess.get_open_error()
		print("File open error code: ", error)
		return
	
	var file_content = file.get_as_text()
	file.close()
	
	print("📄 Raw JSON content length: ", file_content.length())
	print("📄 First 100 chars: ", file_content.substr(0, 100))
	
	# Check if file content is empty
	if file_content.is_empty():
		push_error("❌ RewardLoader: rewards.json file is empty")
		return
	
	var json = JSON.new()
	var parse_result = json.parse(file_content)
	
	if parse_result == OK:
		var data = json.data
		print("✅ JSON parsed successfully")
		print("✅ Data type: ", typeof(data))
		
		if typeof(data) == TYPE_DICTIONARY:
			all_rewards = data
			print("🎉 Rewards loaded into memory:")
			for category in all_rewards.keys():
				print("  - Category '", category, "' has ", all_rewards[category].size(), " items")
		else:
			push_error("❌ RewardLoader: Expected dictionary in rewards.json, got " + str(typeof(data)))
	else:
		push_error("❌ RewardLoader: Failed to parse rewards.json. Error code: " + str(parse_result))
		print("JSON error: ", json.get_error_message())

func get_all_rewards() -> Dictionary:
	print("🔍 get_all_rewards() called, returning ", all_rewards.size(), " categories")
	return all_rewards

func generate_icon_lookup():
	icon_lookup.clear()
	var folders = {
		"Pet": "res://Assets/Rewards/Pets/",
		"Accessory": "res://Assets/Rewards/Accessories/",
		"Gem": "res://Assets/Rewards/GemIcon.png",
		"Coin": "res://Assets/Rewards/CoinIcon.png"
	}
	
	for type in folders.keys():
		var path = folders[type]
		if type == "Gem" or type == "Coin":
			icon_lookup[type] = { "default": path }
			continue
		
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir() and file_name.ends_with(".png"):
					var reward_name = file_name.get_basename()
					if not icon_lookup.has(type):
						icon_lookup[type] = {}
					icon_lookup[type][reward_name] = path + file_name
				file_name = dir.get_next()
			dir.list_dir_end()
		else:
			push_error("Could not open folder: " + path)

func get_icon_path(reward_type: String, reward_name: String) -> String:
	for reward in all_rewards.get(reward_type, []):
		if reward.name == reward_name:
			return reward.image  # it's already the full path
	return ""
