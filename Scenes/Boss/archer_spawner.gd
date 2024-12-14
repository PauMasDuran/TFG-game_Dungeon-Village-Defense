extends Node

@onready var archer = preload("res://Scenes/Player/archer.tscn") 
# Called when the node enters the scene tree for the first time.
@onready var structures = get_tree().get_root().get_node("Main").structures

var archers_level: int 

var walls_position_y = 503

func _ready():
	archers_level = structures.ArcherUpgrade[structures.ArcherLevel]

func spawn_archers():
	for index in range(archers_level):
		var archer_instance = archer.instantiate()
		archer_instance.position = Vector2i(remap(index + 1,0,archers_level + 1,30,615),walls_position_y)
		add_child(archer_instance)
		print("archer: ",index)
	
