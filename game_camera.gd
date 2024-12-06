extends Camera2D

@onready var player = get_parent().get_node("Player")

var is_dungeon_boss_battle:bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_dungeon_boss_battle:
		position = Vector2i(576,704)
	else:
		position = player.position
