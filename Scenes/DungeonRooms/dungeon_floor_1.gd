extends Node2D

@onready var tile_map_layer = $TileMapLayerTerrain
@onready var tile_map_layer_decoration = $TileMapLayerDecoration

@onready var main = get_tree().get_root().get_node("Main")

var floor_tile := Vector2i(7,5)

var floor_number : int
var wall_id: int
var floor_id : int

var bones1_tile := Vector2i(0,21)
var bones2_tile := Vector2i(1,21)
var blood1_tile := Vector2i(0,22)
var blood2_tile := Vector2i(1,22)

var player = preload("res://Scenes/Player/player.tscn")
var slime = preload("res://Scenes/Mobs/slime.tscn")
var monster_spawner = preload("res://Scenes/Mobs/monster_spawner.tscn")
var dungeon_stairs = preload("res://Scenes/DungeonRooms/dungeon_stairs.tscn")
var chest_loot = preload("res://Scenes/DungeonRooms/chest_loot.tscn")
var camera = preload("res://Scenes/Player/game_camera.tscn")
# Constants defining the grid size, cell size, and room parameters
const WIDTH = 32
const HEIGHT = 32
const CELL_SIZE = 64
const MIN_ROOM_SIZE = 2
const MAX_ROOM_SIZE = 4
const MAX_ROOMS = 20

# Arrays to hold the grid data and the list of rooms
var grid = []
var rooms = []
var roomIndex = []

# _ready is called when the node is added to the scene
func _ready():
	floor_number = main.actual_dungeon_floor
	wall_id = floor_number
	floor_id = floor_number + 4
	# Initialize the random number generator
	randomize()
	# Create the grid filled with walls
	initialize_grid()
	# Generate the dungeon by placing rooms and connecting them
	generate_dungeon()
	# Draw the dungeon on the screen
	draw_dungeon()
	
	instantiate_player()
	
	randomize_room_content()
	
	create_exit()
	
	add_loot()
	
	add_enemies()

# Initializes the grid with all cells set to walls (represented by 1)
func initialize_grid():
	for x in range(WIDTH):
		grid.append([])  # Add a new row to the grid
		for y in range(HEIGHT):
			grid[x].append(1)  # Fill each cell in the row with 1 (wall)
			
func generate_dungeon():
	for i in range(MAX_ROOMS):
		# Generate a room with random size and position
		var room = generate_room()
		# Attempt to place the room in the grid
		if place_room(room):
			# If this isn't the first room, connect it to the previous room
			if rooms.size() > 0:
				connect_rooms(rooms[-1], room)  # Connect the new room to the last placed room
			# Add the room to the list of rooms in the dungeon
			rooms.append(room)
 
# Generates a room with random width, height, and position within the grid
func generate_room():
	# Determine room width and height randomly within the specified range
	var width = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var height = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	# Position the room randomly within the grid, ensuring it fits within the boundaries
	var x = randi() % (WIDTH - width - 1) + 1
	var y = randi() % (HEIGHT - height - 1) + 1
	# Return the room as a Rect2 object representing its position and size
	return Rect2(x, y, width, height)
	
	
# Attempts to place the room on the grid, ensuring no overlap with existing rooms
func place_room(room):
	# Check if the room overlaps with any existing floors (cells set to 0)
	for x in range(room.position.x - 1, room.end.x + 1):
		for y in range(room.position.y - 1, room.end.y + 1):
			if x == 0 or y == 0 or x == WIDTH - 1 or y == HEIGHT - 1:
				return false 
			if grid[x][y] == 0:  
				return false  
	
	# If no overlap is found, mark the room area as floors (set cells to 0)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0  # 0 represents a floor
	return true  # Room successfully placed, return true
	
# Connects two rooms with a corridor, allowing for a customizable corridor width
func connect_rooms(room1, room2, corridor_width=1):
	# Determine the starting point for the corridor (center of room1)
	var start = Vector2(
		int(room1.position.x + room1.size.x / 2),
		int(room1.position.y + room1.size.y / 2)
	)
	# Determine the ending point for the corridor (center of room2)
	var end = Vector2(
		int(room2.position.x + room2.size.x / 2),
		int(room2.position.y + room2.size.y / 2)
	)
	
	var current = start
	
	# First, move horizontally towards the end point
	while current.x != end.x:
		# Move one step left or right
		current.x += 1 if end.x > current.x else -1
		# Create a corridor with the specified width
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				# Ensure we don't go out of grid bounds
				if current.y + j >= 0 and current.y + j < HEIGHT and current.x + i >= 0 and current.x + i < WIDTH:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor
 
	# Then, move vertically towards the end point
	while current.y != end.y:
		# Move one step up or down
		current.y += 1 if end.y > current.y else -1
		# Create a corridor with the specified width
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				# Ensure we don't go out of grid bounds
				if current.x + i >= 0 and current.x + i < WIDTH and current.y + j >= 0 and current.y + j < HEIGHT:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor
					

func draw_dungeon():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2i(x,y)
			if grid[x][y] == 0:
				draw_dungeon_decorations(tile_position)
				draw_floor(tile_position,x,y)
				#tile_map_layer.set_cell(tile_position,1,floor_tile)
			elif grid[x][y] == 1 and y < HEIGHT - 1 and x < WIDTH - 1:
				draw_walls(tile_position,x,y)
			else:
				tile_map_layer.set_cell(tile_position,wall_id,Vector2i(6,2))

func draw_walls(tile_position,x,y):
	var floor_tiles_nearby = 8 - grid[x - 1][y - 1] - grid[x][y - 1] - grid[x + 1][y - 1] - grid[x + 1][y] - grid[x + 1][y + 1] - grid[x][y + 1] - grid[x - 1][y + 1] - grid[x - 1][y]
	print(floor_tiles_nearby)
	if floor_tiles_nearby == 0:
		tile_map_layer.set_cell(tile_position,wall_id,Vector2i(6,2))
	
	if floor_tiles_nearby == 1:
		
		var wall_tile_up_right := Vector2i(1,2)
		var wall_tile_up_left := Vector2i(0,2)
		var wall_tile_down_right := Vector2i(1,3)
		var wall_tile_down_left := Vector2i(0,3)
		
		if grid[x - 1][y - 1] == 0: 
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_down_right)
		elif grid[x - 1][y + 1] == 0: 
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_up_right)
		elif grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_up_left)
		elif grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_down_left)
	
	if floor_tiles_nearby == 2:
		var wall_individual_corridor_vertical_mid := Vector2i(2,0)
		var wall_individual_corridor_horizontal_mid := Vector2i(2,1)
		var wall_tile_up := Vector2i(4,3)
		var wall_tile_down := Vector2i(5,3)
		var wall_tile_right := Vector2i(5,2)
		var wall_tile_left := Vector2i(4,2)
		
		if grid[x - 1][y] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_vertical_mid)
		elif grid[x][y - 1] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_horizontal_mid)
		elif grid[x - 1][y + 1] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(6,5))
		elif grid[x - 1][y - 1] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(6,4))
		elif grid[x - 1][y - 1] == 0 and grid[x - 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(3,3))
		elif grid[x - 1][y - 1] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(3,2))
		elif grid[x + 1][y - 1] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(2,3))
		elif grid[x + 1][y + 1] == 0 and grid[x - 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(2,2))
		elif grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_down)
		elif grid[x][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_up)
		elif grid[x + 1][y] == 0:  
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_right)
		elif grid[x - 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_left)
	
	if floor_tiles_nearby == 3:
		var wall_tile_up := Vector2i(4,3)
		var wall_tile_down := Vector2i(5,3)
		var wall_tile_right := Vector2i(5,2)
		var wall_tile_left := Vector2i(4,2)
		if grid[x][y + 1] == 0 and grid[x + 1][y + 1] == 0 and grid[x - 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_down)
		elif grid[x][y - 1] == 0 and grid[x - 1][y - 1] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_up)
		elif grid[x + 1][y] == 0 and grid[x + 1][y - 1] == 0 and grid[x + 1][y + 1] == 0:  
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_right)
		elif grid[x - 1][y] == 0 and grid[x - 1][y + 1] == 0 and grid[x - 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_tile_left)
		elif grid[x - 1][y - 1] == 0 and grid[x - 1][y + 1] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(4,5))
		elif grid[x + 1][y - 1] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(5,5))
		elif grid[x][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(5,4))
		elif grid[x - 1][y - 1] == 0 and grid[x][y - 1] == 0 and grid[x - 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(4,4))
		elif grid[x - 1][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(2,4))
		elif grid[x - 1][y] == 0 and grid[x - 1][y + 1] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(2,5))
		elif grid[x - 1][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(3,4))
		elif grid[x - 1][y + 1] == 0 and grid[x + 1][y] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(3,5))
		elif grid[x][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(7,3))
		elif grid[x - 1][y] == 0 and grid[x - 1][y - 1] == 0 and grid[x][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(7,1))
		elif grid[x + 1][y] == 0 and grid[x + 1][y + 1] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(7,4))
		elif grid[x - 1][y] == 0 and grid[x - 1][y + 1] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(7,2))
		elif grid[x - 1][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(2,5))
		elif grid[x - 1][y + 1] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(5,5))
		elif grid[x + 1][y - 1] == 0 and grid[x][y - 1] == 0 and grid[x - 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(4,4))
		elif grid[x + 1][y + 1] == 0 and grid[x + 1][y] == 0 and grid[x - 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(3,4))
		elif grid[x - 1][y - 1] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(4,5))
		elif grid[x - 1][y + 1] == 0 and grid[x - 1][y] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(2,4))
		elif grid[x - 1][y - 1] == 0 and grid[x][y - 1] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(5,4))
		elif grid[x - 1][y + 1] == 0 and grid[x + 1][y] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(3,5))

	if floor_tiles_nearby == 4:
		var wall_corridor_up_left := Vector2i(7,1)
		var wall_corridor_down_left := Vector2i(7,2)
		var wall_corridor_up_right := Vector2i(7,3)
		var wall_corridor_down_right := Vector2i(7,4)
		
		if grid[x + 1][y - 1] == 0 and grid[x + 1][y] == 0 and grid[x][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_corridor_up_right)
		elif grid[x - 1][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_corridor_up_left)
		elif grid[x + 1][y + 1] == 0 and grid[x + 1][y] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_corridor_down_right)
		elif grid[x - 1][y + 1] == 0 and grid[x - 1][y] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_corridor_down_left)
		elif grid[x - 1][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x - 1][y + 1] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(7,0))
		elif grid[x - 1][y - 1] == 0 and grid[x][y - 1] == 0 and grid[x + 1][y - 1] == 0:
			if grid[x + 1][y + 1] == 0:
				tile_map_layer.set_cell(tile_position,wall_id,Vector2i(5,4))
			elif grid[x - 1][y + 1] == 0:
				tile_map_layer.set_cell(tile_position,wall_id,Vector2i(4,4))
		elif grid[x - 1][y + 1] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y + 1] == 0:
			if grid[x - 1][y - 1] == 0:
				tile_map_layer.set_cell(tile_position,wall_id,Vector2i(4,5))
			elif grid[x + 1][y - 1] == 0:
				tile_map_layer.set_cell(tile_position,wall_id,Vector2i(5,5))
		elif grid[x - 1][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x - 1][y + 1] == 0:
			if grid[x + 1][y - 1] == 0:
				tile_map_layer.set_cell(tile_position,wall_id,Vector2i(2,4))
			elif grid[x + 1][y + 1] == 0:
				tile_map_layer.set_cell(tile_position,wall_id,Vector2i(2,5))
		elif grid[x + 1][y - 1] == 0 and grid[x + 1][y] == 0 and grid[x + 1][y + 1] == 0:
			if grid[x - 1][y - 1] == 0:
				tile_map_layer.set_cell(tile_position,wall_id,Vector2i(3,4))
			elif grid[x - 1][y + 1] == 0:
				tile_map_layer.set_cell(tile_position,wall_id,Vector2i(3,5))
		elif grid[x][y - 1] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(2,1))
		elif grid[x - 1][y] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(2,0))
		elif grid[x][y - 1] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(7,3))
		elif grid[x - 1][y] == 0 and grid[x][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(7,1))
		elif grid[x + 1][y] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(7,4))
		elif grid[x - 1][y] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(7,2))

	if floor_tiles_nearby == 5:
		
		var wall_individual_corridor_vertical_bot := Vector2i(6,0)
		var wall_individual_corridor_vertical_top := Vector2i(5,1)
		var wall_individual_corridor_horizontal_right := Vector2i(5,0)
		var wall_individual_corridor_horizontal_left := Vector2i(6,1)
		var wall_individual_corridor_vertical_mid := Vector2i(2,0)
		var wall_individual_corridor_horizontal_mid := Vector2i(2,1)
		
		if  grid[x - 1][y] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_vertical_bot)
		elif  grid[x - 1][y] == 0 and grid[x][y - 1] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_vertical_top)
		elif  grid[x][y - 1] == 0 and grid[x + 1][y] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_horizontal_right)
		elif grid[x][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_horizontal_left)
		elif grid[x - 1][y] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_vertical_mid)
		elif grid[x][y - 1] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_horizontal_mid)
	
		var wall_corridor_up_left := Vector2i(7,1)
		var wall_corridor_down_left := Vector2i(7,2)
		var wall_corridor_up_right := Vector2i(7,3)
		var wall_corridor_down_right := Vector2i(7,4)
		
		if grid[x + 1][y - 1] == 0 and grid[x + 1][y] == 0 and grid[x][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_corridor_up_right)
		elif grid[x - 1][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_corridor_up_left)
		elif grid[x + 1][y + 1] == 0 and grid[x + 1][y] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_corridor_down_right)
		elif grid[x - 1][y + 1] == 0 and grid[x - 1][y] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_corridor_down_left)
	
		if grid[x][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x + 1][y] == 0 and grid[x - 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(1,0))
		elif grid[x - 1][y - 1] == 0 and grid[x][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(0,0))
		elif grid[x - 1][y] == 0 and grid[x - 1][y + 1] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(0,1))
		elif grid[x][y + 1] == 0 and grid[x + 1][y + 1] == 0 and grid[x + 1][y] == 0 and grid[x - 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(1,1))
			
		if grid[x - 1][y - 1] == 0 and grid[x][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x - 1][y + 1] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(3,0))
		elif grid[x - 1][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x + 1][y] == 0 and grid[x + 1][y + 1] == 0 and grid[x - 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(4,1))
		elif grid[x - 1][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x - 1][y + 1] == 0 and grid[x + 1][y + 1] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(3,1))
		elif grid[x - 1][y - 1] == 0 and grid[x - 1][y + 1] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y + 1] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(4,0))
	
	if floor_tiles_nearby == 6:
		var wall_individual_corridor_vertical_mid := Vector2i(2,0)
		var wall_individual_corridor_horizontal_mid := Vector2i(2,1)
		
		if grid[x - 1][y - 1] == 0 and grid[x][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x + 1][y] == 0 and grid[x + 1][y + 1] == 0 and grid[x - 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(1,0))
		elif grid[x - 1][y - 1] == 0 and grid[x][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x - 1][y + 1] == 0 and grid[x + 1][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(0,0))
		elif grid[x - 1][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x - 1][y + 1] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y + 1] == 0 and grid[x + 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(0,1))
		elif grid[x - 1][y + 1] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y + 1] == 0 and grid[x + 1][y] == 0 and grid[x + 1][y - 1] == 0 and grid[x - 1][y - 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(1,1))
		elif grid[x][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x + 1][y] == 0 and grid[x + 1][y + 1] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(5,0))
		elif grid[x][y - 1] == 0 and grid[x - 1][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x - 1][y + 1] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(6,1))
		elif grid[x - 1][y] == 0 and grid[x - 1][y - 1] == 0 and grid[x][y - 1] == 0 and grid[x + 1][y - 1] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(5,1))
		elif grid[x - 1][y] == 0 and grid[x - 1][y + 1] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y + 1] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,Vector2i(6,0))
		elif grid[x - 1][y] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_vertical_mid)
		elif grid[x][y - 1] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_horizontal_mid)
	
	if floor_tiles_nearby == 7:
		var wall_individual_corridor_vertical_bot := Vector2i(6,0)
		var wall_individual_corridor_vertical_top := Vector2i(5,1)
		var wall_individual_corridor_horizontal_right := Vector2i(5,0)
		var wall_individual_corridor_horizontal_left := Vector2i(6,1)
		
		if  grid[x - 1][y] == 0 and grid[x][y + 1] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_vertical_bot)
		elif  grid[x - 1][y] == 0 and grid[x][y - 1] == 0 and grid[x + 1][y] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_vertical_top)
		elif  grid[x][y - 1] == 0 and grid[x + 1][y] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_horizontal_right)
		elif grid[x][y - 1] == 0 and grid[x - 1][y] == 0 and grid[x][y + 1] == 0:
			tile_map_layer.set_cell(tile_position,wall_id,wall_individual_corridor_horizontal_left)
	
	if floor_tiles_nearby == 8:
		tile_map_layer.set_cell(tile_position,wall_id,Vector2i(6,3))
		
	else:
		#tile_map_layer.set_cell(tile_position,wall_id,Vector2i(6,2))
		pass


func draw_floor(tile_position,x,y):
	var wall_tiles_nearby = grid[x - 1][y - 1] + grid[x][y - 1] + grid[x + 1][y - 1] + grid[x + 1][y] + grid[x + 1][y + 1] + grid[x][y + 1] + grid[x - 1][y + 1] + grid[x - 1][y]
	
	if wall_tiles_nearby == 0:
		tile_map_layer.set_cell(tile_position,floor_id,Vector2i(7,5))
	
	if wall_tiles_nearby == 1:
		
		var wall_tile_up_right := Vector2i(1,2)
		var wall_tile_up_left := Vector2i(0,2)
		var wall_tile_down_right := Vector2i(1,3)
		var wall_tile_down_left := Vector2i(0,3)
		
		var wall_tile_up := Vector2i(4,3)
		var wall_tile_down := Vector2i(5,3)
		var wall_tile_right := Vector2i(5,2)
		var wall_tile_left := Vector2i(4,2)
		
		if grid[x - 1][y - 1] == 1: 
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_down_right)
		elif grid[x - 1][y + 1] == 1: 
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_up_right)
		elif grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_up_left)
		elif grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_down_left)
		elif grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_down)
		elif grid[x][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_up)
		elif grid[x + 1][y] == 1:  
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_right)
		elif grid[x - 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_left)
	
	if wall_tiles_nearby == 2:
		
		var wall_individual_corridor_vertical_mid := Vector2i(2,0)
		var wall_individual_corridor_horizontal_mid := Vector2i(2,1)
		var wall_tile_up := Vector2i(4,3)
		var wall_tile_down := Vector2i(5,3)
		var wall_tile_right := Vector2i(5,2)
		var wall_tile_left := Vector2i(4,2)
		
		
		if grid[x - 1][y] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_vertical_mid)
		elif grid[x][y - 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_horizontal_mid)
		elif grid[x - 1][y + 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(6,5))
		elif grid[x - 1][y - 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(6,4))
		elif grid[x - 1][y - 1] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,3))
		elif grid[x - 1][y - 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,2))
		elif grid[x + 1][y - 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,3))
		elif grid[x + 1][y + 1] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,2))
		elif grid[x - 1][y] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,0))
		elif grid[x][y - 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,1))
		elif grid[x][y + 1] == 1 and grid[x - 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,5))
		elif grid[x][y + 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(5,5))
		elif grid[x - 1][y] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,4))
		elif grid[x - 1][y] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,5))
		elif grid[x][y - 1] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,4))
		elif grid[x][y - 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(5,4))
		elif grid[x + 1][y] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,5))
		elif grid[x + 1][y] == 1 and grid[x - 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,4))
		elif grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_down)
		elif grid[x][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_up)
		elif grid[x + 1][y] == 1:  
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_right)
		elif grid[x - 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_left)
	
	
	if wall_tiles_nearby == 3:
		var wall_tile_up := Vector2i(4,3)
		var wall_tile_down := Vector2i(5,3)
		var wall_tile_right := Vector2i(5,2)
		var wall_tile_left := Vector2i(4,2)
		if grid[x][y + 1] == 1 and grid[x + 1][y + 1] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_down)
		elif grid[x][y - 1] == 1 and grid[x - 1][y - 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_up)
		elif grid[x + 1][y] == 1 and grid[x + 1][y - 1] == 1 and grid[x + 1][y + 1] == 1:  
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_right)
		elif grid[x - 1][y] == 1 and grid[x - 1][y + 1] == 1 and grid[x - 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_tile_left)
		elif grid[x - 1][y - 1] == 1 and grid[x - 1][y + 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,5))
		elif grid[x + 1][y - 1] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(5,5))
		elif grid[x][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(5,4))
		elif grid[x - 1][y - 1] == 1 and grid[x][y - 1] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,4))
		elif grid[x - 1][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,4))
		elif grid[x - 1][y] == 1 and grid[x - 1][y + 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,5))
		elif grid[x - 1][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,4))
		elif grid[x - 1][y + 1] == 1 and grid[x + 1][y] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,5))
		elif grid[x][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(7,3))
		elif grid[x - 1][y] == 1 and grid[x - 1][y - 1] == 1 and grid[x][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(7,1))
		elif grid[x + 1][y] == 1 and grid[x + 1][y + 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(7,4))
		elif grid[x - 1][y] == 1 and grid[x - 1][y + 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(7,2))
		elif grid[x - 1][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,5))
		elif grid[x - 1][y + 1] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(5,5))
		elif grid[x + 1][y - 1] == 1 and grid[x][y - 1] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,4))
		elif grid[x + 1][y + 1] == 1 and grid[x + 1][y] == 1 and grid[x - 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,4))
		elif grid[x - 1][y - 1] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,5))
		elif grid[x - 1][y + 1] == 1 and grid[x - 1][y] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,4))
		elif grid[x - 1][y - 1] == 1 and grid[x][y - 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(5,4))
		elif grid[x - 1][y + 1] == 1 and grid[x + 1][y] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,5))
		elif grid[x - 1][y + 1] == 1 and grid[x - 1][y - 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(0,4))
		elif grid[x + 1][y + 1] == 1 and grid[x - 1][y - 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(1,4))
		elif grid[x + 1][y + 1] == 1 and grid[x - 1][y + 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(1,5))
		elif grid[x + 1][y + 1] == 1 and grid[x - 1][y + 1] == 1 and grid[x - 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(0,5))
		elif grid[x][y - 1] == 1 and grid[x - 1][y + 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,0))
		elif grid[x - 1][y - 1] == 1 and grid[x + 1][y] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,1))
		elif grid[x - 1][y] == 1 and grid[x + 1][y + 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,1))
		elif grid[x - 1][y - 1] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,0))
		elif grid[x - 1][y] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,0))
		elif grid[x][y - 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,1))

	if wall_tiles_nearby == 4:
		var wall_corridor_up_left := Vector2i(7,1)
		var wall_corridor_down_left := Vector2i(7,2)
		var wall_corridor_up_right := Vector2i(7,3)
		var wall_corridor_down_right := Vector2i(7,4)
		
		if grid[x + 1][y - 1] == 1 and grid[x + 1][y] == 1 and grid[x][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_corridor_up_right)
		elif grid[x - 1][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_corridor_up_left)
		elif grid[x + 1][y + 1] == 1 and grid[x + 1][y] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_corridor_down_right)
		elif grid[x - 1][y + 1] == 1 and grid[x - 1][y] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_corridor_down_left)
		elif grid[x - 1][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x - 1][y + 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(7,0))
		elif grid[x - 1][y] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,0))
		elif grid[x][y - 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,1))
		elif grid[x - 1][y - 1] == 1 and grid[x][y - 1] == 1 and grid[x + 1][y - 1] == 1:
			if grid[x + 1][y + 1] == 1:
				tile_map_layer.set_cell(tile_position,floor_id,Vector2i(5,4))
			elif grid[x - 1][y + 1] == 1:
				tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,4))
		elif grid[x - 1][y + 1] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y + 1] == 1:
			if grid[x - 1][y - 1] == 1:
				tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,5))
			elif grid[x + 1][y - 1] == 1:
				tile_map_layer.set_cell(tile_position,floor_id,Vector2i(5,5))
		elif grid[x - 1][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x - 1][y + 1] == 1:
			if grid[x + 1][y - 1] == 1:
				tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,4))
			elif grid[x + 1][y + 1] == 1:
				tile_map_layer.set_cell(tile_position,floor_id,Vector2i(2,5))
		elif grid[x + 1][y - 1] == 1 and grid[x + 1][y] == 1 and grid[x + 1][y + 1] == 1:
			if grid[x - 1][y - 1] == 1:
				tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,4))
			elif grid[x - 1][y + 1] == 1:
				tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,5))
		


	if wall_tiles_nearby == 5:
		
		var wall_individual_corridor_vertical_bot := Vector2i(6,0)
		var wall_individual_corridor_vertical_top := Vector2i(5,1)
		var wall_individual_corridor_horizontal_right := Vector2i(5,0)
		var wall_individual_corridor_horizontal_left := Vector2i(6,1)
		var wall_individual_corridor_vertical_mid := Vector2i(2,0)
		var wall_individual_corridor_horizontal_mid := Vector2i(2,1)
		
		if  grid[x - 1][y] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_vertical_bot)
		elif  grid[x - 1][y] == 1 and grid[x][y - 1] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_vertical_top)
		elif  grid[x][y - 1] == 1 and grid[x + 1][y] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_horizontal_right)
		elif grid[x][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_horizontal_left)
		elif grid[x - 1][y] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_vertical_mid)
		elif grid[x][y - 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_horizontal_mid)
	
		var wall_corridor_up_left := Vector2i(7,1)
		var wall_corridor_down_left := Vector2i(7,2)
		var wall_corridor_up_right := Vector2i(7,3)
		var wall_corridor_down_right := Vector2i(7,4)
		
		if grid[x + 1][y - 1] == 1 and grid[x + 1][y] == 1 and grid[x][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_corridor_up_right)
		elif grid[x - 1][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_corridor_up_left)
		elif grid[x + 1][y + 1] == 1 and grid[x + 1][y] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_corridor_down_right)
		elif grid[x - 1][y + 1] == 1 and grid[x - 1][y] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_corridor_down_left)
	
		if grid[x][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x + 1][y] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(1,0))
		elif grid[x - 1][y - 1] == 1 and grid[x][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(0,0))
		elif grid[x - 1][y] == 1 and grid[x - 1][y + 1] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(0,1))
		elif grid[x][y + 1] == 1 and grid[x + 1][y + 1] == 1 and grid[x + 1][y] == 1 and grid[x - 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(1,1))
		
		if grid[x - 1][y - 1] == 1 and grid[x][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x - 1][y + 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,0))
		elif grid[x - 1][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x + 1][y] == 1 and grid[x + 1][y + 1] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,1))
		elif grid[x - 1][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x - 1][y + 1] == 1 and grid[x + 1][y + 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(3,1))
		elif grid[x - 1][y - 1] == 1 and grid[x - 1][y + 1] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y + 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(4,0))
	
	if wall_tiles_nearby == 6:
		var wall_individual_corridor_vertical_mid := Vector2i(2,0)
		var wall_individual_corridor_horizontal_mid := Vector2i(2,1)
		
		if grid[x - 1][y - 1] == 1 and grid[x][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x + 1][y] == 1 and grid[x + 1][y + 1] == 1 and grid[x - 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(1,0))
		elif grid[x - 1][y - 1] == 1 and grid[x][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x - 1][y + 1] == 1 and grid[x + 1][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(0,0))
		elif grid[x - 1][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x - 1][y + 1] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y + 1] == 1 and grid[x + 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(0,1))
		elif grid[x - 1][y + 1] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y + 1] == 1 and grid[x + 1][y] == 1 and grid[x + 1][y - 1] == 1 and grid[x - 1][y - 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(1,1))
		elif grid[x][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x + 1][y] == 1 and grid[x + 1][y + 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(5,0))
		elif grid[x][y - 1] == 1 and grid[x - 1][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x - 1][y + 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(6,1))
		elif grid[x - 1][y] == 1 and grid[x - 1][y - 1] == 1 and grid[x][y - 1] == 1 and grid[x + 1][y - 1] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(5,1))
		elif grid[x - 1][y] == 1 and grid[x - 1][y + 1] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y + 1] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,Vector2i(6,0))
		elif grid[x - 1][y] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_vertical_mid)
		elif grid[x][y - 1] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_horizontal_mid)
	
	if wall_tiles_nearby == 7:
		var wall_individual_corridor_vertical_bot := Vector2i(6,0)
		var wall_individual_corridor_vertical_top := Vector2i(5,1)
		var wall_individual_corridor_horizontal_right := Vector2i(5,0)
		var wall_individual_corridor_horizontal_left := Vector2i(6,1)
		
		if  grid[x - 1][y] == 1 and grid[x][y + 1] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_vertical_bot)
		elif  grid[x - 1][y] == 1 and grid[x][y - 1] == 1 and grid[x + 1][y] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_vertical_top)
		elif  grid[x][y - 1] == 1 and grid[x + 1][y] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_horizontal_right)
		elif grid[x][y - 1] == 1 and grid[x - 1][y] == 1 and grid[x][y + 1] == 1:
			tile_map_layer.set_cell(tile_position,floor_id,wall_individual_corridor_horizontal_left)
	
	if wall_tiles_nearby == 8:
		tile_map_layer.set_cell(tile_position,floor_id,Vector2i(6,3))
	

func draw_dungeon_decorations(tile_position):
	var decoration_selector = randi_range(0,50)
	var decoration_tile : Vector2i = Vector2i(0,0)
	if decoration_selector == 0:
		decoration_tile = blood1_tile
	elif decoration_selector == 1:
		decoration_tile = blood2_tile
	elif decoration_selector == 2:
		decoration_tile = bones1_tile
	elif decoration_selector == 3:
		decoration_selector = bones2_tile
	else:
		pass
	if decoration_tile != Vector2i(0,0):
		tile_map_layer_decoration.set_cell(tile_position,1,decoration_tile)

func instantiate_player():
	var player_instance = player.instantiate()
	var camera_instance = camera.instantiate()
	var spawn_room_position = Vector2(
		int((rooms[0].position.x + rooms[0].size.x / 2) * CELL_SIZE),
		int((rooms[0].position.y + rooms[0].size.y / 2) * CELL_SIZE)
	)
	print(spawn_room_position)
	player_instance.position = spawn_room_position
	add_child(player_instance)
	add_child(camera_instance)
	
	
	$Player.camera = $GameCamera
	$GameCamera.player = $Player


func create_exit():
	var stairs_instance = dungeon_stairs.instantiate()
	var exit_room_position = Vector2i(
		int((rooms[roomIndex[0]].position.x + rooms[roomIndex[0]].size.x / 2) * CELL_SIZE),
		int((rooms[roomIndex[0]].position.y + rooms[roomIndex[0]].size.y / 2) * CELL_SIZE)
	)
	
	stairs_instance.position = exit_room_position
	add_child(stairs_instance)
	print("Escape room",roomIndex[0])

func add_loot():
	for n in range(1,3):
		var chests_instance = chest_loot.instantiate()
		var chests_room_position = Vector2i(
		int((rooms[roomIndex[n]].position.x + rooms[roomIndex[n]].size.x / 2) * CELL_SIZE),
		int((rooms[roomIndex[n]].position.y + rooms[roomIndex[n]].size.y / 2) * CELL_SIZE)
		)
		chests_instance.position = chests_room_position
		add_child(chests_instance)
		print("loot room",roomIndex[n])
	


func add_enemies():
	
	for n in range(rooms.size() - 1):
		var monster_spawner_instance = monster_spawner.instantiate()
		var spawn_room_position = Vector2(
			int((rooms[roomIndex[n]].position.x + rooms[roomIndex[n]].size.x / 2) * CELL_SIZE),
			int((rooms[roomIndex[n]].position.y + rooms[roomIndex[n]].size.y / 2) * CELL_SIZE)
		)
		if n > 2:
			print(spawn_room_position)
			monster_spawner_instance.position = spawn_room_position
			add_child(monster_spawner_instance)
			print("Enemy Room", roomIndex[n])

func randomize_room_content():
	for num in range(1, rooms.size()):
		roomIndex.append(num)
	roomIndex.shuffle()
