extends Area2D

@onready var main_node = get_tree().get_root().get_node("Main")
# Called when the node enters the scene tree for the first time.
func _ready():
	print(main_node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player" and main_node.actual_dungeon_floor < 3:
		main_node.go_to_next_dungeon_floor()
	elif body.name == "Player" and main_node.actual_dungeon_floor == 3:
		main_node.exit_dungeon()
