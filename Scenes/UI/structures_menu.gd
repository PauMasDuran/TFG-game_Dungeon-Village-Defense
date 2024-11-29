extends Control


@onready var main = get_tree().get_root().get_node("Main")

@onready var playerResources = get_tree().get_root().get_node("Main").playerResources
# Called when the node enters the scene tree for the first time.
func _ready():
	main.actualizeResourcesSignal.connect(actualizeHoursAndDays)
	actualizeHoursAndDays()

func actualizeHoursAndDays():
	$MarginContainer/VBoxContainer/HBoxContainer/HoursRemaining.text = "Hours Remaining:\n" + str(playerResources.HoursRemaining)
