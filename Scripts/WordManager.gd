extends Node

var words_data = {}  # { word: { "count": int, "sound_path": String } }

func load_words_from_json(json_path: String):
	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		print("❌ Could not open file:", json_path)
		return
	
	var content = file.get_as_text()
	var parsed = JSON.parse_string(content)

	if typeof(parsed) != TYPE_DICTIONARY:
		print("❌ Invalid JSON format!")
		return

	for word in parsed.keys():
		words_data[word] = {
			"count": 0,
			"sound_path": parsed[word]
		}
	print("✅ Loaded", words_data.size(), "words.")

func get_next_word_options(count: int = 3) -> Array:
	var remaining = words_data.keys().filter(func(w):
		return words_data[w]["count"] < 3
	)
	remaining.shuffle()
	return remaining.slice(0, count)

func mark_word_correct(word: String):
	if words_data.has(word):
		words_data[word]["count"] += 1
