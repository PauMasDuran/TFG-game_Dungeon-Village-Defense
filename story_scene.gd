extends Control

# false = inici, true = final
var control:bool = true

@onready var main = get_tree().get_root().get_node("Main")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset():
	$MarginContainer/Panel/MarginContainer/ScrollContainer/Label1.visible = true
	$MarginContainer/Panel/MarginContainer/ScrollContainer/Label2.visible = false
	control = true

func _on_next_button_pressed():
	if !control:
		$MarginContainer/Panel/MarginContainer/ScrollContainer/Label1.visible = true
		$MarginContainer/Panel/MarginContainer/ScrollContainer/Label2.visible = false
		$NextButton.text = "Next"
		control = true
		main.resetGame()
		get_parent().go_to_game_reset()
	else:
		$MarginContainer/Panel/MarginContainer/ScrollContainer/Label1.visible = false
		$MarginContainer/Panel/MarginContainer/ScrollContainer/Label2.visible = true
		$NextButton.text = "Play Again"
		control = false
	visible = false
