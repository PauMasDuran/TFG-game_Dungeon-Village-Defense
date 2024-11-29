extends Control

signal dungeon_pressed
signal training_pressed
signal smith_pressed
signal structures_pressed
signal boss_pressed

@onready var playerResources = get_tree().get_root().get_node("Main").playerResources
@onready var main = get_tree().get_root().get_node("Main")

func _ready():
	main.actualizeResourcesSignal.connect(actualizeHoursAndDays)
	actualizeHoursAndDays()

func actualizeHoursAndDays():
	$ButtonsContainer/VBoxContainer2/HBoxContainer/HoursRemaining.text = "Hours Remaining:\n" + str(playerResources.HoursRemaining)
	$ButtonsContainer/VBoxContainer2/HBoxContainer/DaysUntilBoss.text = "Days till Boss:\n" + str(playerResources.DaysRemaining)

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
