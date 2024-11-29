extends Area2D

@export var customText : String 
# Called when the node enters the scene tree for the first time.
func _ready():
	customText = customText.replace("/n", "\n")
	$Control.visible = false
	$Control/MarginContainer/signpostText.text = customText




func _on_body_entered(body):
	if body.name == "Player":
		print("player entered")
		$Control.visible = true


func _on_body_exited(body):
	if body.name == "Player":
		print("player exited")
		$Control.visible = false
