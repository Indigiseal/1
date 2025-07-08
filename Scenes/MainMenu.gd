extends Node2D

@onready var click_sound = $ExitButton/ClickSound

func _on_exit_button_pressed():
	click_sound.play()
	await click_sound.finished  # Wait for sound to finish
	get_tree().quit()

func _on_word_preview_screen_button_pressed():
	click_sound.play()
	await click_sound.finished  # Wait for sound to finish
	get_tree().change_scene_to_file("res://Scenes/word_preview_screen.tscn")

func _on_store_button_pressed():
	click_sound.play()
	await click_sound.finished  # Wait for sound to finish
	get_tree().change_scene_to_file("res://Scenes/Store.tscn")

func _on_reward_inventory_button_pressed():
	click_sound.play()
	await click_sound.finished  # Wait for sound to finish
	get_tree().change_scene_to_file("res://Scenes/RewardInventory.tscn")
