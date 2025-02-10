extends TileMapLayer

@export var player: CharacterBody2D

var break_sprite_coords = [
	Vector2i(3, 0),
	Vector2i(3, 1),
	Vector2i(3, 2),
	Vector2i(3, 3)
]
var breaking_tiles: Dictionary = {}
var break_fade_time = 10

signal break_tile(pos)

# Called when the node enters the scene tree for the first time.
func _ready():
	player.mine_block.connect(_on_player_mine_block)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_mine_block(pos, dir):
	var mine_pos = local_to_map(pos) + dir
	if not get_cell_tile_data(mine_pos).get_custom_data("mineable"):
		return
	
	if mine_pos in breaking_tiles.keys():
		breaking_tiles[mine_pos][0] += 1
		if breaking_tiles[mine_pos][0] >= break_sprite_coords.size():
			set_cell(mine_pos)
			break_tile.emit(mine_pos)
			breaking_tiles.erase(mine_pos)
			return
	else:
		breaking_tiles[mine_pos] = [0, 0]
	var tile_coords = break_sprite_coords[breaking_tiles[mine_pos][0]]
	set_cell(mine_pos, 0, tile_coords)
	breaking_tiles[mine_pos][1] = break_fade_time
