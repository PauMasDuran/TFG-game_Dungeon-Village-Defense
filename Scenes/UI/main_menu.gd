extends Control

signal dungeon_pressed
signal training_pressed
signal smith_pressed
signal structures_pressed
signal boss_pressed

func _on_dungeon_button_pressed():
	dungeon_pressed.emit()


func _on_training_button_pressed():
	training_pressed.emit()


func _on_smith_pressed():
	smith_pressed.emit()


func _on_structures_pressed():
	structures_pressed.emit()


func _on_boss_pressed():
	boss_pressed.emit()
