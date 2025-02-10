extends Node2D

@export var game_manager: Node2D
@export var player: CharacterBody2D

@export var tiles: TileMapLayer
@export var rock_outline: TileMapLayer
@export var foreground: TileMapLayer
@export var break_progress: TileMapLayer

@export_category("Noise maps")
@export var ore_noise: FastNoiseLite
@export var ore_threshold: float = 0.25
@export var ice_noise: FastNoiseLite
@export var ice_threshold: float = 0.25
@export var cave_noise: FastNoiseLite
@export var cave_threshold: float = 0.3

signal tile_breaking(coords)
signal tile_broken(coords)
signal tile_mined(coords)

enum TileType{
	UNBREAKABLE,
	AIR,
	ROCK,
	ICE,
	ORE,
	GEM,
	TORCH,
}

var map_width = Constants.map_width
var map_depth = Constants.map_depth
var sky_height =Constants.sky_height

var tile_type_map: Dictionary = {}
var light_map: Dictionary = {}

var air_tile_coords = [Vector2i(9, 4), Vector2i(8,4), Vector2i(7,4), Vector2i(6,4), Vector2i(5,4), Vector2i(4,4)]
var air_tile_light_levels = [0, 2, 4, 8, 12, 15]
var air_tile_max_light_level = 15

var rock_tile_coords = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),]
var ice_tile_coords = [Vector2i(8, 6), Vector2i(8, 7), Vector2i(9, 6), Vector2i(9, 7)]
var gem_tile_coords = [Vector2i(2, 2), Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3),]

var ore_tile_center_coord = Vector2i(1, 5)
var rock_outline_center = Vector2i(5, 1)
var torch_coords = Vector2i(6, 6)
var torch_light_level = 10

var break_sprite_coords = [
	Vector2i(3, 0),
	Vector2i(3, 1),
	Vector2i(3, 3)
]
var breaking_tiles: Dictionary = {}
var break_fade_time = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	ore_noise.seed = randi()
	ice_noise.seed = randi()
	cave_noise.seed = randi()
	player.mine_block.connect(_on_player_mine_tile)
	generate_map()

func _input(event):
	if event.is_action_pressed("place_torch"):
		var coords = tiles.local_to_map(player.position)
		if tile_type_map[coords] == TileType.AIR:
			if foreground.get_cell_atlas_coords(coords) == Vector2i(-1, -1):
				if GameData.inventory.remove_items(GameData.ItemTypes.TORCH, 1):
					place_torch(coords)

func generate_map():
	for i in range(map_width):
		for j in range(-sky_height, map_depth):
			light_map[Vector2i(i, j)] = 0
			if i == 0 or i == map_width-1 or j == map_depth-1:
				set_tile(Vector2i(i, j), TileType.UNBREAKABLE, false)
			elif j < 0:
				set_tile(Vector2i(i, j), TileType.AIR, false)
			else:
				var type
				type = get_tile_from_noise(Vector2i(i, j))
				if j <= 1 and type == TileType.AIR:
					type = TileType.ROCK
				if randf() > lerp(0.99, 0.85, float(j)/float(map_depth)):
					type = TileType.GEM
				set_tile(Vector2i(i, j), type, false)
	 
	setup_light_map()
	
	for i in range(map_width):
		for j in range(-sky_height, map_depth):
			update_tile(Vector2i(i, j))
			update_rock_outline(Vector2i(i, j))
	


func set_tile(coords: Vector2i, type: TileType, do_update = true):
	tile_type_map[coords] = type
	if do_update:
		update_tile(coords)

func empty_tile(coords: Vector2i):
	#tiles.set_cell(pos, 0, Vector2i(4, 4))
	set_tile(coords, TileType.AIR)
	update_rock_outline(coords)

func place_torch(coords: Vector2i):
	set_tile(coords, TileType.TORCH)

func update_tile(coords: Vector2i):
	var type = tile_type_map[coords]
	var atlas_coords = Vector2i(0, 0)
	match(type):
		TileType.UNBREAKABLE:
			atlas_coords = Vector2i(9, 5)
		TileType.AIR:
			var light_level = get_tile_light_level(coords)
			var index = air_tile_light_levels.bsearch(light_level)
			atlas_coords = air_tile_coords[index]
		TileType.ROCK:
			atlas_coords = rock_tile_coords.pick_random()
		TileType.ICE:
			atlas_coords = ice_tile_coords.pick_random()
		TileType.ORE:
			var left_is_ore = tile_type_map[coords + Vector2i(-1, 0)] == TileType.ORE
			var right_is_ore = tile_type_map[coords + Vector2i(1, 0)] == TileType.ORE
			var up_is_ore = tile_type_map[coords + Vector2i(0, -1)] == TileType.ORE
			var down_is_ore = tile_type_map[coords + Vector2i(0, 1)] == TileType.ORE
			atlas_coords = get_tile_texture_coords_from_neighbors(
				ore_tile_center_coord, left_is_ore, right_is_ore, up_is_ore, down_is_ore,
			)
		TileType.GEM:
			atlas_coords = gem_tile_coords.pick_random()
		TileType.TORCH:
			atlas_coords = air_tile_coords[-1]
			foreground.set_cell(coords, 0, torch_coords)
			if light_map[coords] < torch_light_level:
				light_map[coords] = torch_light_level
			update_light_map_from_source(coords, true)
	tiles.set_cell(coords, 0, atlas_coords)

func setup_light_map():
	# Setup sky light
	for i in range(map_width):
		for j in range(-sky_height, map_depth):
			var coords = Vector2i(i, j)
			if tile_type_map[coords] == TileType.AIR:
				if coords.y < 0:
					light_map[coords] = air_tile_max_light_level
				elif light_map[coords + Vector2i(0, -1)] == air_tile_max_light_level or coords.y == 0:
					light_map[coords] = air_tile_max_light_level
					update_light_map_from_source(coords)

func update_light_map_from_source(coords: Vector2i, do_update = false):
	var source_light = light_map[coords]
	_update_light_map_from_source_recursive(coords, source_light, do_update)
	#if do_update:
		#update_tile(coords)

func _update_light_map_from_source_recursive(coords, light_level, do_update):
	light_level -= 1
	if light_level <= 0:
		return
	var neighbors = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for n in neighbors:
		var cur_coords = coords + n
		if not is_inside_map(cur_coords):
			continue
		if tile_type_map[cur_coords] == TileType.AIR:
			if light_level > light_map[cur_coords]:
				light_map[cur_coords] = light_level
				_update_light_map_from_source_recursive(cur_coords, light_level, do_update)
				if do_update:
					update_tile(cur_coords)

func get_tile_light_level(coords: Vector2i, update_source = null) -> int:
	return light_map[coords]

func is_inside_map(coords: Vector2i) -> bool:
	if coords.y < -sky_height or coords.y >= map_depth:
		return false
	if coords.x < 0 or coords.x >= map_width:
		return false
	return true

func update_rock_outline(coords: Vector2i):
	var matches = [TileType.ROCK, TileType.ORE]
	if tile_type_map[coords] in matches:
		var left = tile_type_map[coords + Vector2i(-1, 0)] in matches
		var right = tile_type_map[coords + Vector2i(1, 0)] in matches
		var up = tile_type_map[coords + Vector2i(0, -1)] in matches
		var down = tile_type_map[coords + Vector2i(0, 1)] in matches
		var atlas_coords = get_tile_texture_coords_from_neighbors(
			rock_outline_center, left, right, up, down
		)
		rock_outline.set_cell(coords, 0, atlas_coords)
	else:
		rock_outline.erase_cell(coords)

func get_tile_texture_coords_from_neighbors(
	center: Vector2i, left: bool, right: bool, up: bool, down: bool
):
	var texture_coords = center
	if not left and not right:
		texture_coords += Vector2i(2, 0)
	elif not left:
		texture_coords += Vector2i(-1, 0)
	elif not right:
		texture_coords += Vector2i(1, 0)
	if not up and not down:
		texture_coords += Vector2i(0, 2)
	elif not up:
		texture_coords += Vector2i(0, -1)
	elif not down:
		texture_coords += Vector2i(0, 1)
	return texture_coords

func get_tile_from_noise(coords: Vector2i):
	var type = TileType.ROCK
	if ore_noise.get_noise_2dv(coords) > ore_threshold:
		type = TileType.ORE
	elif cave_noise.get_noise_2dv(coords) > cave_threshold:
		type = TileType.AIR
	elif ice_noise.get_noise_2dv(coords) > ice_threshold:
		type = TileType.ICE
	return type



func _on_player_mine_tile(pos, dir):
	var mine_pos = tiles.local_to_map(pos) + dir
	if not tiles.get_cell_tile_data(mine_pos).get_custom_data("mineable"):
		return
	tile_mined.emit(mine_pos)
	
	# If tile already is being broken, we just get the map entry
	if mine_pos in breaking_tiles.keys():
		breaking_tiles[mine_pos][0] += 1
		
		# If we are out of break sprites, we have finished mining the tile
		if breaking_tiles[mine_pos][0] >= break_sprite_coords.size():
			tile_breaking.emit(mine_pos)
			break_progress.set_cell(mine_pos)
			breaking_tiles.erase(mine_pos)
			empty_tile(mine_pos)
			tile_broken.emit(mine_pos)
			return
	# We make a new entry for the mined tile.
	else:
		breaking_tiles[mine_pos] = [0, 0]
	
	# Update break_progress tilemap
	var tile_coords = break_sprite_coords[breaking_tiles[mine_pos][0]]
	break_progress.set_cell(mine_pos, 0, tile_coords)
	breaking_tiles[mine_pos][1] = break_fade_time
	


func _on_tile_broken(coords):
	var neighbors = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for n in neighbors:
		var neighbor_coords = coords + n
		if not is_inside_map(neighbor_coords):
			continue
		if tile_type_map[neighbor_coords] == TileType.AIR:
			update_light_map_from_source(neighbor_coords, true)


func _on_tile_breaking(coords):
	var type = tile_type_map[coords]
	if type == TileType.ROCK:
		if randf() > 0.25:
			GameData.inventory.add_items(GameData.ItemTypes.STONE)
	if type == TileType.ORE:
		GameData.inventory.add_items(GameData.ItemTypes.ORE)
	if type == TileType.GEM:
		GameData.inventory.add_items(GameData.ItemTypes.GEM)
