extends Node

var playerStats = {
	"MaxHp": 10,
	"MaxSp": 10,
	"Atk": 1,
	"Spd": 250,
	"SpDrain": 5,
	"SprintSpd": 300
}

var playerResources = {
	"Gold": 1000,
	"Crystals": 1000,
	"HoursRemaining": 9,
	"DaysRemaining": 6
}

var trainStats = {
	"HPLevel": 0,
	"HPTraining": [35, 70, 100, 175, 300, 500],
	"ATKLevel": 0,
	"ATKTraining": [10, 20, 30, 40, 50, 60],
	"SPDLevel": 0,
	"SPDTraining": [120, 140, 160, 190, 220, 280]
}

var smith = {
	"SPLevel": 0,
	"SPCapacity": [25, 50, 100, 175, 300, 500],
	"SPDrainLevel": 0,
	"SPDrain": [5, 10, 20, 35, 60, 90],
	"SprintLevel": 5,
	"SprintBoots": [300, 350, 400, 450, 500, 600]
}

var structures = {
	"WallLevel":0,
	"WallUpgrade": [100,150,200,250,300,350],
	"DecoyLevel":0,
	"DecoyUpgrade": [30,70,120,170,250,310],
	"HealLevel":0,
	"HealUpgrade": [5,10,15,30,50,75],
	"ArcherLevel":0,
	"ArcherUpgrade": [1,2,3,4,5,6],
	}

var upgradeCostGold = [100,200,400,700,1000,1500]
var upgradeCostCrystal = [50,75,100,125,250,300]

var BossArenaWallsHP : int = 100

var dungeon_node
var boss_arena_node

@onready var gamehud = $UI/GameHud

signal actualizeResourcesSignal

var actual_dungeon_floor: int

var dungeon_boss_room: bool = false

@onready var dungeonScene = load("res://Scenes/DungeonRooms/dungeon_generator.tscn")
@onready var testScene = load("res://Scenes/DungeonRooms/test_room.tscn")
@onready var bossScene = load("res://Scenes/Boss/boss_arena.tscn")
@onready var dungeonFloor1 = load("res://Scenes/DungeonRooms/dungeon_floor_generator.tscn")
@onready var dungeonBossFloor = load("res://Scenes/DungeonRooms/dungeon_floor_boss.tscn")
@onready var tutorialDungeon = load("res://Scenes/DungeonRooms/tutorial_dungeon.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	resetDay()
	dungeon_boss_room = false
	$Music.play_menu_music()


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
	gamehud.get_node("DungeonTimer").wait_time = playerResources.HoursRemaining * 60
	gamehud.get_node("DungeonTimer").start()
	$Music.play_dungeon_music()
		#change to strech viewport
	
	dungeon_node = dungeon_instance

func start_boss_scene():
	$Music.play_final_boss_music()
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var bossArena_instance = bossScene.instantiate()
	add_child(bossArena_instance)
	
	boss_arena_node = $BossArena

func exit_dungeon():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	dungeon_node.queue_free()
	$UI.return_from_dungeon()
	resetDay()
	$Music.play_menu_music()
	#change to stretch canvas items

func exit_boss_arena():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	boss_arena_node.queue_free()
	$UI.return_from_dungeon()
	$UI.go_story_screen()

func go_to_next_dungeon_floor():
	if $TutorialDungeon != null:
		$TutorialDungeon.queue_free()
	elif $DungeonFloorBoss != null:
		$DungeonFloorBoss.queue_free()
	else:
		$DungeonFloorGenerator.queue_free()
	remove_all_children($Projectiles)
	if !dungeon_boss_room:
		actual_dungeon_floor += 1
		
	$UI.go_to_next_dungeon_floor()
	#var dungeon_instance = dungeonScene.instantiate()
	$TimerBetweenDungeonScenes.start()
	gamehud.get_node("DungeonTimer").paused = true


func remove_all_children(node: Node):
	for child in node.get_children():
		child.queue_free()


func _on_timer_between_dungeon_scenes_timeout():
	var dungeon_instance = null
	if dungeon_boss_room:
		dungeon_instance = dungeonBossFloor.instantiate()
		dungeon_boss_room = false
		$Music.play_dungeon_boss_music()
	else:
		dungeon_instance = dungeonFloor1.instantiate()
		dungeon_boss_room = true
		$Music.play_dungeon_music()
	add_child(dungeon_instance)
	dungeon_node = dungeon_instance
	$UI.arrive_to_next_dungeon_floor()
	gamehud.get_node("DungeonTimer").paused = false

func game_over():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	boss_arena_node.queue_free()
	$UI.return_from_dungeon()
	$UI.go_to_game_over()

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

func loseHours(Quantity):
	playerResources.HoursRemaining -= Quantity
	actualizeResourcesSignal.emit()

func resetDay():
	gamehud.get_node("DungeonTimer").stop()
	playerResources.HoursRemaining = 12
	playerResources.DaysRemaining -= 1
	actualizeResourcesSignal.emit()
	dungeon_boss_room = false

func resetGame():
	trainStats.HPLevel = 0
	trainStats.ATKLevel = 0
	trainStats.SPDLevel = 0
	$UI/TrainingMenu.upgradeStats()
	$UI/TrainingMenu.upgradePrices()
	smith.SPLevel = 0
	smith.SPDrainLevel = 0
	smith.SprintLevel = 0
	$UI/SmithMenu.upgradeStats()
	$UI/SmithMenu.upgradePrices()
	structures.WallLevel = 0
	structures.DecoyLevel = 0
	structures.HealLevel = 0
	structures.ArcherLevel = 0
	$UI/StructuresMenu.upgradePrices()
	playerResources.Gold = 1000
	playerResources.Crystals = 1000
	playerResources.DaysRemaining = 6
	resetDay()
	dungeon_boss_room = false
	$Music.play_menu_music()
	$UI.storyShown = false
	$UI/StoryScene.reset()
