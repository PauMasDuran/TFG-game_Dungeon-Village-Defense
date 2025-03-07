extends Camera2D

@onready var player = get_parent().get_node("Player")

var is_dungeon_boss_battle:bool = false
@export var is_boss_battle: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if is_boss_battle:
		print("working")
		limit_bottom = 17 *32
		limit_left = 0
		limit_top = 0
		limit_right =  32*32

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_dungeon_boss_battle:
		position = Vector2i(576,704)
	elif is_boss_battle == true:
		position.y = player.position.y
	else:
		position = player.position
