extends Control

@onready var main = get_tree().get_root().get_node("Main")

func _ready():
	pass # Replace with function body.



func _process(delta):
	pass


func _on_play_again_button_pressed():
	main.resetGame()
	get_parent().go_to_game_reset()


func _on_exit_button_pressed():
	get_tree().quit()
