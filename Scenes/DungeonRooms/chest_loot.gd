extends Area2D

var opened = false
@onready var main = get_tree().get_root().get_node("Main")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D/AnimationPlayer.play("chest_closed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_body_entered(body):
	if body.name == "Player":
		$Sprite2D/AnimationPlayer.play("chest_opened")
		if opened == false:
			main.addGold(50)
			main.addCrystals(50)
			opened = true
