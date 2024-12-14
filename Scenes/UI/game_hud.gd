extends Control

@onready var playerStats = get_tree().get_root().get_node("Main").playerStats
@onready var playerResources = get_tree().get_root().get_node("Main").playerResources
@onready var wallsHP = get_tree().get_root().get_node("Main").BossArenaWallsHP
@onready var main = get_tree().get_root().get_node("Main")
# 0 = dungeon, 1 = bossArena
var gameMode: int 



func _ready():
	$HPBar.max_value = playerStats.MaxHp
	$SPBar.max_value = playerStats.MaxSp
	$BossHPBar.max_value = wallsHP
	actualizeResources()
	
	

func _process(delta):
	$DungeonTimerLabel.text = "%02d:%02d" % time_left_to_dungeon()

func time_left_to_dungeon():
	var time_left = $DungeonTimer.time_left
	var minute = floor(time_left / 60)
	var second = int(time_left) % 60
	return [minute, second]

func gainHP(quantity):
	$HPBar.value += quantity

func loseHP(quantity):
	$HPBar.value -= quantity

func gainSP(quantity):
	$SPBar.value += quantity

func loseSP(quantity):
	$SPBar.value -= quantity

func resetSP():
	$SPBar.value = $SPBar.max_value 

func resetHP():
	$HPBar.value = $HPBar.max_value

func loseWallHP(quantity):
	$WallsHPBar.value -= quantity

func isDungeonMode():
	$WallsHPBar.visible = false

func isBossMode():
	$WallsHPBar.visible = true

func actualizeResources():
	$GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(playerResources.Gold)
	$GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(playerResources.Crystals)


func _on_dungeon_timer_timeout():
	main.exit_dungeon()
