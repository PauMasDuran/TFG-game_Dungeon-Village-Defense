extends Node2D
@onready var tile_map_layer = $TileMapLayerTerrain
@onready var tile_map_layer_decoration = $TileMapLayerDecoration

var floor_tile_odd := Vector2i(2,0)
var floor_tile_even := Vector2i(0,7)
var wall_tile := Vector2i(0,1)
var wall_top_tile := Vector2i(1,1)

var bones1_tile := Vector2i(0,21)
var bones2_tile := Vector2i(1,21)
var blood1_tile := Vector2i(0,22)
var blood2_tile := Vector2i(1,22)

var player = preload("res://Scenes/Player/player.tscn")
var slime = preload("res://Scenes/Mobs/slime.tscn")
var monster_spawner = preload("res://Scenes/Mobs/monster_spawner.tscn")
var dungeon_stairs = preload("res://Scenes/DungeonRooms/dungeon_stairs.tscn")
var chest_loot = preload("res://Scenes/DungeonRooms/chest_loot.tscn")
# Constants defining the grid size, cell size, and room parameters
const WIDTH = 64
const HEIGHT = 64
const CELL_SIZE = 32
const MIN_ROOM_SIZE = 5
const MAX_ROOM_SIZE = 10
const MAX_ROOMS = 15

# Arrays to hold the grid data and the list of rooms
var grid = []
var rooms = []
var roomIndex = []

# _ready is called when the node is added to the scene
func _ready():
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
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:  # If the cell is already a floor
				return false  # Room cannot be placed, return false
	
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
				if (x + y) % 2 == 0:
					tile_map_layer.set_cell(tile_position,0,floor_tile_even)
				else:
					tile_map_layer.set_cell(tile_position,0,floor_tile_odd)
			elif grid[x][y] == 1:
				if y < HEIGHT - 1 and grid[x][y + 1] == 0:
					tile_map_layer.set_cell(tile_position,0,wall_top_tile)
				elif y < HEIGHT - 1 and grid[x][y - 1] == 0:
					tile_map_layer.set_cell(tile_position,0,wall_tile)
				#corners and horizontal and lower walls
				elif x < WIDTH - 1 and grid[x + 1][y] == 0 or y < HEIGHT - 1 and grid[x - 1][y] == 0 or y < HEIGHT - 1 and x < WIDTH - 1 and grid[x - 1][y - 1] == 0 or y < HEIGHT - 1 and x < WIDTH - 1 and grid[x - 1][y + 1] == 0 or y < HEIGHT - 1 and x < WIDTH - 1 and grid[x + 1][y + 1] == 0 or y < HEIGHT - 1 and x < WIDTH - 1 and grid[x + 1][y - 1] == 0:
					tile_map_layer.set_cell(tile_position,0,wall_tile)
			else:
				tile_map_layer.set_cell(tile_position,0,Vector2i(-1,-1))

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
		tile_map_layer_decoration.set_cell(tile_position,0,decoration_tile)

func instantiate_player():
	var player_instance = player.instantiate()
	var spawn_room_position = Vector2(
		int((rooms[0].position.x + rooms[0].size.x / 2) * 32),
		int((rooms[0].position.y + rooms[0].size.y / 2) * 32)
	)
	print(spawn_room_position)
	player_instance.position = spawn_room_position
	add_child(player_instance)

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
