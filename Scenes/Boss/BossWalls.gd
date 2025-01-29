extends Area2D

var health_points: int

@onready var gameHud = get_tree().get_root().get_node("Main").get_node("UI").get_node("GameHud")
@onready var main = get_tree().get_root().get_node("Main")
@onready var structures = get_tree().get_root().get_node("Main").structures
# Called when the node enters the scene tree for the first time.
func _ready():
	health_points = structures.WallUpgrade[structures.WallLevel]
	gameHud.get_node("WallsHPBar").max_value = structures.WallUpgrade[structures.WallLevel]
	gameHud.get_node("WallsHPBar").value = health_points


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health_points <= 0:
		main.game_over()


func _on_area_entered(area):
	if area.name == "EnemyHitBox":
		health_points -= area.owner.atk
		print("Walls HP: ", health_points)
		gameHud.loseWallHP(area.owner.atk)
