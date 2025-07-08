extends Control

@onready var word_list_container = $VBoxContainer
@onready var start_button = $StartButton

var words_data = {}

func _ready():
	# Load the JSON file
	var file = FileAccess.open("res://Data/word_data.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			words_data = parsed
			setup_word_batches()
			show_word_list()
		else:
			print("❌ Invalid JSON format.")
	else:
		print("❌ Could not open word_data.json.")

	start_button.pressed.connect(_on_start_pressed)

func setup_word_batches():
	# Load all words into WordSelection singleton
	var all_words = words_data.keys()
	all_words.shuffle()

	WordSelection.all_words = all_words
	WordSelection.current_batch_index = 0
	WordSelection.mastered_words = []
	WordSelection.selected_words = WordSelection.get_next_batch(12)

func show_word_list():
	for word in WordSelection.selected_words:
		var label = Label.new()
		label.text = word.capitalize()
		word_list_container.add_child(label)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")
