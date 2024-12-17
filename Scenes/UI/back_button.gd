extends Button

#false = menu button, true = buy button
@export var buttonType: bool = false

@onready var main = get_tree().get_root().get_node("Main")


func _on_pressed():
	get_parent().visible = false
	


func _on_button_up():
	if !buttonType:
		main.get_node("UI").get_node("ClickSound").play()



func _on_mouse_entered():
	main.get_node("UI").get_node("HoverSound").play()
