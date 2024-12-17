extends Button

#false = menu button, true = buy button
@export var buttonType: bool = false
@onready var main = get_tree().get_root().get_node("Main")
@export var able: bool = true


func _on_mouse_entered():
	main.get_node("UI").get_node("HoverSound").play()


func _on_button_up():
	if !buttonType:
		main.get_node("UI").get_node("ClickSound").play()
	else:
		if able:
			main.get_node("UI").get_node("BuySound").play()
		else:
			main.get_node("UI").get_node("DeniedSound").play()
