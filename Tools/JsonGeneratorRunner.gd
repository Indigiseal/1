extends Node

func _ready():
	generate_word_json("res://Sounds/Words/", "res://Data/word_data.json")

func generate_word_json(sound_folder: String, output_path: String):
	var dir = DirAccess.open(sound_folder)
	if dir == null:
		print("❌ Failed to open folder:", sound_folder)
		return

	var result = {}

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".ogg") or file_name.ends_with(".mp3")):
			var word = file_name.get_basename()  # e.g., "cat"
			result[word] = {
				"sound_path": sound_folder + file_name,
				"times_correct": 0
			}
		file_name = dir.get_next()
	dir.list_dir_end()

	var json_text = JSON.stringify(result, "\t")  # Pretty print

	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if file:
		file.store_string(json_text)
		file.close()
		print("✅ word_data.json created with", result.size(), "words.")
	else:
		print("❌ Failed to write file:", output_path)
