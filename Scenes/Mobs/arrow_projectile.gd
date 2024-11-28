extends CharacterBody2D

var speed = 100

var direction : Vector2
var spawnPos : Vector2
var spawnRot : float
var zdex : int
var player : CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_root().get_node("Main").get_node("DungeonGenerator") != null:
		player = get_tree().get_root().get_node("Main").get_node("DungeonGenerator").get_node("Player")
	elif get_parent().get_node("Player") != null:
		player = get_parent().get_node("Player")
	elif get_tree().get_root().get_node("Main").get_node("BossArena") != null:
		player = get_tree().get_root().get_node("Main").get_node("BossArena").get_node("Player")
	elif get_tree().get_root().get_node("Main").get_node("DungeonFloorGenerator") != null:
		player = get_tree().get_root().get_node("Main").get_node("DungeonFloorGenerator").get_node("Player")
	global_position = spawnPos
	global_rotation = spawnRot
	direction = Vector2(cos(spawnRot), sin(spawnRot))
	z_index = zdex


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	move_and_collide(direction * speed * delta)




func _on_area_2d_area_entered(area):
	if area.name == "PlayerHurtBox":
		queue_free()
	elif area.name == "HitBox":
		player.gotHitByPlayer()
		queue_free()


func _on_enemy_hit_box_body_entered(body):
	if body is TileMapLayer:
		queue_free()
