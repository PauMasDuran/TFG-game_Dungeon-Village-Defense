extends Area2D

var health_points: int

@onready var gameHud = get_tree().get_root().get_node("Main").get_node("UI").get_node("GameHud")
@onready var main = get_tree().get_root().get_node("Main")
# Called when the node enters the scene tree for the first time.
func _ready():
	health_points = main.BossArenaWallsHP
	gameHud.get_node("WallsHPBar").value = health_points


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	if area.name == "EnemyHitBox":
		health_points -= 1
		print("Walls HP: ", health_points)
	if area.name == "HitBox":
		health_points -= 1
		print("Walls HP: ", health_points)
	gameHud.loseWallHP(1)
