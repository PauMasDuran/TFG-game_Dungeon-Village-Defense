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
			drop_loot()
			opened = true

func drop_loot():
	var lootQuantity = randi_range(50,100) 
	main.addGold(lootQuantity * main.actual_dungeon_floor)
	lootQuantity = randi_range(50,100) 
	main.addCrystals(lootQuantity * main.actual_dungeon_floor)
