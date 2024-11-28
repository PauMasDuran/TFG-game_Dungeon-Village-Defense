extends Node

var playerStats = {
	"MaxHp": 10,
	"MaxSp": 10,
	"Atk": 1,
	"Spd": 250
}

var playerResources = {
	"Gold": 100,
	"Crystals": 100
}

var trainStats = {
	"HPLevel": 0,
	"HPTraining": [25, 50, 100, 175, 300, 500],
	"ATKLevel": 0,
	"ATKTraining": [5, 15, 30, 60, 90, 120],
	"SPDLevel": 0,
	"SPDTraining": [80, 100, 150, 200, 250, 300]
}

var upgradeCostGold = [100,200,400,700,1000,1500]
var upgradeCostCrystal = [50,75,100,125,250,300]

var BossArenaWallsHP : int = 100

var dungeon_node

@onready var gamehud = $UI/GameHud

signal actualizeResourcesSignal

var actual_dungeon_floor: int

@onready var dungeonScene = load("res://Scenes/DungeonRooms/dungeon_generator.tscn")
@onready var testScene = load("res://Scenes/DungeonRooms/test_room.tscn")
@onready var bossScene = load("res://Scenes/Boss/boss_arena.tscn")
@onready var dungeonFloor1 = load("res://Scenes/DungeonRooms/dungeon_floor_generator.tscn")
@onready var tutorialDungeon = load("res://Scenes/DungeonRooms/tutorial_dungeon.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func start_test_scene():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var instance = testScene.instantiate()
	add_child(instance)
	
	#change to strech viewport
	


func start_dungeon_scene():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	actual_dungeon_floor = -1
	#var dungeon_instance = dungeonScene.instantiate()
	var dungeon_instance = tutorialDungeon.instantiate()
	add_child(dungeon_instance)
		#change to strech viewport
	
	dungeon_node = $DungeonFloorGenerator

func start_boss_scene():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var bossArena_instance = bossScene.instantiate()
	add_child(bossArena_instance)
	
	

func exit_dungeon():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	dungeon_node.queue_free()
	$UI.return_from_dungeon()
	
	#change to stretch canvas items

func go_to_next_dungeon_floor():
	if $TutorialDungeon != null:
		$TutorialDungeon.queue_free()
	else:
		$DungeonFloorGenerator.queue_free()
	remove_all_children($Projectiles)
	actual_dungeon_floor += 1
	$UI.go_to_next_dungeon_floor()
	#var dungeon_instance = dungeonScene.instantiate()
	$TimerBetweenDungeonScenes.start()


func remove_all_children(node: Node):
	for child in node.get_children():
		child.queue_free()


func _on_timer_between_dungeon_scenes_timeout():
	var dungeon_instance = dungeonFloor1.instantiate()
	add_child(dungeon_instance)
	dungeon_node = $DungeonFloorGenerator
	$UI.arrive_to_next_dungeon_floor()


func addGold(Quantity):
	playerResources.Gold += Quantity
	actualizeResourcesSignal.emit()

func loseGold(Quantity):
	playerResources.Gold -= Quantity
	actualizeResourcesSignal.emit()

func addCrystals(Quantity):
	playerResources.Crystals += Quantity
	actualizeResourcesSignal.emit()

func loseCrystals(Quantity):
	playerResources.Crystals -= Quantity
	actualizeResourcesSignal.emit()
