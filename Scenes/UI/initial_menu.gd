extends Control

signal play_pressed
signal options_pressed

func _on_start_game_button_pressed():
	play_pressed.emit()


func _on_options_button_pressed():
	pass # Replace with function body.


func _on_exit_game_button_pressed():
	get_tree().quit()
