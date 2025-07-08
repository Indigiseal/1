extends Node

var rewards = []

const SAVE_PATH = "user://save_data/rewards.json"

func add_reward(type: String, name: String):
	rewards.append({ "type": type, "name": name })
	save_rewards()

func save_rewards():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(rewards))
		file.close()
		print("Rewards saved to disk")
	else:
		push_error("Failed to open file for saving rewards")
		
func save_inventory():
	var save_path = "user://save_data/rewards_save.json"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var data = {
			"rewards": rewards
		}
		file.store_string(JSON.stringify(data, "\t"))  # Pretty print
		file.close()
		print("✅ Rewards saved to: ", save_path)

func load_rewards():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var text = file.get_as_text()
			var result = JSON.parse_string(text)
			if typeof(result) == TYPE_ARRAY:
				rewards = result
				print("Rewards loaded from disk")
