extends Node

@onready var archer = preload("res://Scenes/Player/archer.tscn") 
# Called when the node enters the scene tree for the first time.

var archers_level: int = 1

var walls_position_y = 503

func spawn_archers():
	for index in range(archers_level):
		var archer_instance = archer.instantiate()
		archer_instance.position = Vector2i(remap(index + 1,0,archers_level + 1,30,1000),walls_position_y)
		add_child(archer_instance)
		print("archer: ",index)
	
