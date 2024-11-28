extends MarginContainer

@export var is_player_resources : bool
# Called when the node enters the scene tree for the first time.
@onready var playerResources = get_tree().get_root().get_node("Main").playerResources
@onready var main = get_tree().get_root().get_node("Main")

func _ready():
	main.actualizeResourcesSignal.connect(actualizeResources)


func actualizeResources():
	if is_player_resources:
		$VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(playerResources.Gold)
		$VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(playerResources.Crystals)
