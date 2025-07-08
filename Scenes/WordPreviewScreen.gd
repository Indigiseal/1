extends Control

@onready var word_grid = $WordListContainer/WordGridContainer
@onready var title_label = $TitleLabel
@onready var start_button = $StartButton
@onready var button_sound = $ButtonClickSound
@onready var WordButtonScene = preload("res://WordButton.tscn") # Make sure this path is correct

var should_change_scene := false  # flag to know when to switch

func _ready():
	title_label.text = "Words to Practice:"
	
	var file = FileAccess.open("res://Data/word_data.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(text)
		if data is Dictionary:
			var all_words = data.keys()
			all_words.sort()
			
			# ✅ Initialize word system with full word list
			WordSelection.initialize_word_pool(all_words)
			
			# ✅ Show the first 12 selected words
			for word in WordSelection.selected_words:
				var button = WordButtonScene.instantiate()
				button.get_node("Label").text = word
				word_grid.add_child(button)

func _on_StartButton_pressed():
	print("▶️ Start button pressed!")
	button_sound.play()
	should_change_scene = true

func _on_button_click_sound_finished():
	if should_change_scene:
		get_tree().change_scene_to_file("res://Main.tscn")
