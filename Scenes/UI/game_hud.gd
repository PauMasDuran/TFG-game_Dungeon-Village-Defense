extends Control

@onready var playerStats = get_tree().get_root().get_node("Main").playerStats
@onready var playerResources = get_tree().get_root().get_node("Main").playerResources
@onready var wallsHP = get_tree().get_root().get_node("Main").BossArenaWallsHP
# 0 = dungeon, 1 = bossArena
var gameMode: int 

func _ready():
	$HPBar.max_value = playerStats.MaxHp
	$SPBar.max_value = playerStats.MaxSp
	$BossHPBar.max_value = wallsHP
	actualizeResources()

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

func loseWallHP(quantity):
	$WallsHPBar.value -= quantity

func isDungeonMode():
	$WallsHPBar.visible = false

func isBossMode():
	$WallsHPBar.visible = true

func actualizeResources():
	$GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(playerResources.Gold)
	$GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(playerResources.Crystals)
