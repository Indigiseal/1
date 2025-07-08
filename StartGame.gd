extends Control

@onready var word_list_container = $VBoxContainer
@onready var start_button = $StartButton

var words_data = {}

func _ready():
	# Load the JSON file manually
	var file = FileAccess.open("res://Data/word_data.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			words_data = parsed
			show_word_list()
		else:
			print("❌ Invalid JSON format.")
	else:
		print("❌ Could not open word_data.json.")

	start_button.pressed.connect(_on_start_pressed)

func show_word_list():
	for word in words_data.keys():
		var label = Label.new()
		label.text = word.capitalize()
		word_list_container.add_child(label)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")  # Your main game scene
