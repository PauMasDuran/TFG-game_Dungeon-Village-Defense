extends Node2D

@onready var tilemap = $TileMapLayerTerrain

var tiles_walls_id = 0
var tiles_floor_id = 4

@onready var main = get_tree().get_root().get_node("Main")

var tilemap_default_doors = []

var boss_battle_triggered: bool = false

func _ready():
	actualise_cells()

func actualise_cells():
	for cell in tilemap.get_used_cells():
		print(cell)
		if tilemap.get_cell_source_id(cell) == tiles_walls_id:
			tilemap.set_cell(cell,main.actual_dungeon_floor,tilemap.get_cell_atlas_coords(cell))
		elif tilemap.get_cell_source_id(cell) == tiles_floor_id:
			tilemap.set_cell(cell,main.actual_dungeon_floor + 4,tilemap.get_cell_atlas_coords(cell))


func boss_battle_mode():
	var x_cells_positions = [3,4,5,6]
	var y_cells_positions = [-1,0,5,6]
	var count = -1
	for celly in y_cells_positions:
		count += 1
		for cellx in x_cells_positions:
			tilemap_default_doors.append(tilemap.get_cell_atlas_coords(Vector2i(cellx,celly)))
			if count % 2 == 0:
				tilemap.set_cell(Vector2i(cellx,celly), main.actual_dungeon_floor, Vector2i(4,3))
			else:
				tilemap.set_cell(Vector2i(cellx,celly), main.actual_dungeon_floor, Vector2i(5,3))

func normal_mode():
	var x_cells_positions = [3,4,5,6]
	var y_cells_positions = [-1,0,5,6]
	var count = 0
	var totalcounter = 0
	for celly in y_cells_positions:
		count = 0
		for cellx in x_cells_positions:
			if count % 3 == 0:
				tilemap.set_cell(Vector2i(cellx,celly), main.actual_dungeon_floor,tilemap_default_doors[totalcounter])
			else:
				tilemap.set_cell(Vector2i(cellx,celly), main.actual_dungeon_floor + 4,tilemap_default_doors[totalcounter])
			totalcounter += 1
			count += 1



func _on_door_detector_body_entered(body):
	if body.name == "Player" and !boss_battle_triggered:
		boss_battle_mode()
		boss_battle_triggered = true
		$Timer.start()


func _on_timer_timeout():
	print("shoudl have turned")
	normal_mode()
	
