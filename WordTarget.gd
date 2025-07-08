extends Area2D

@export var word_text: String
@onready var animation_player = $AnimationPlayer

var game_manager

func _ready():
	if has_node("WordLabel"):
		$WordLabel.text = word_text
	else:
		print("⚠️ WordLabel not found!")

	game_manager = get_node("/root/Main")

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("🧠 Word clicked:", word_text)

		if animation_player.has_animation("pulse"):
			animation_player.play("pulse")

		if game_manager:
			game_manager.check_word(word_text)
