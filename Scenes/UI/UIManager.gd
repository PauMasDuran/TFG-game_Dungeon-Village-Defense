extends CanvasLayer

@onready var initial_menu = $InitialMenu
@onready var main_menu = $MainMenu
@onready var training_menu = $TrainingMenu
@onready var smith_menu = $SmithMenu
@onready var structures_menu = $StructuresMenu
@onready var game_hud = $GameHud

@onready var main = get_tree().get_root().get_node("Main")

var storyShown: bool = false

func _ready():
	initial_menu.play_pressed.connect(initial_menu_play_pressed)
	initial_menu.options_pressed.connect(initial_menu_options_pressed)
	main_menu.dungeon_pressed.connect(main_menu_enter_dungeon_pressed)
	main_menu.smith_pressed.connect(main_menu_smith_pressed)
	main_menu.training_pressed.connect(main_menu_train_stats_pressed)
	main_menu.structures_pressed.connect(main_menu_structures_pressed)
	main_menu.boss_pressed.connect(main_menu_boss_pressed)
	

func initial_menu_play_pressed():
	main_menu.visible = true
	if !storyShown:
		$StoryScene.visible = true
		storyShown = true
	
func initial_menu_options_pressed():
	$OptionsMenu.visible = true
	
func main_menu_enter_dungeon_pressed():
	game_hud.visible = true
	game_hud.isDungeonMode()
	initial_menu.visible = false
	main_menu.visible = false
	#get_parent().start_test_scene()
	get_parent().start_dungeon_scene()
	

func return_from_dungeon():
	game_hud.visible = false
	initial_menu.visible = true
	main_menu.visible = true

func main_menu_train_stats_pressed():
	training_menu.visible = true
	
func main_menu_smith_pressed():
	smith_menu.visible = true
	
func main_menu_structures_pressed():
	structures_menu.visible = true

func main_menu_boss_pressed():
	game_hud.visible = true
	game_hud.isBossMode()
	initial_menu.visible = false
	main_menu.visible = false
	get_parent().start_boss_scene()

func go_to_next_dungeon_floor():
	game_hud.visible = false
	$DungeonFloorTitlesUI.set_title(main.actual_dungeon_floor,main.dungeon_boss_room)
	$DungeonFloorTitlesUI.visible = true

func arrive_to_next_dungeon_floor():
	$DungeonFloorTitlesUI.visible = false
	game_hud.visible = true

func go_to_game_over(): #Used when player dies in final arena
	game_hud.visible = false
	$GameOver.visible = true

func go_to_game_reset():
	$GameOver.visible = false
	$MainMenu.visible = false

func go_story_screen():
	$StoryScene.visible = true
