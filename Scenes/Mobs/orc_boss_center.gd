extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_teleporter_center_body_entered(body):
	if body.name == "KingOrc":
		body.is_in_teleporter = true


func _on_teleporter_center_body_exited(body):
	if body.name == "KingOrc":
		body.is_in_teleporter = false
