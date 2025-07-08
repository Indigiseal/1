extends Node2D

@onready var click_sound = $ExitButton/ClickSound

func _on_exit_button_pressed():
	click_sound.play()
	await click_sound.finished  # Wait for sound to finish
	get_tree().quit()
