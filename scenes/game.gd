extends Node2D

signal enter_house()

@export var player: CharacterBody2D
@export var tilemaps: Tilemaps
@export var ui: CanvasLayer

func _ready():
	#Setup the map and player. This runs on the start of each new day.
	GameData.update_player(player)
	player.position = Vector2(40, -4.2)
	
	tilemaps.generate_map()
	spawn_monsters()
	
	#Give each enemy a pointer to the player for pathfinding.
	for c in get_children():
		if c.is_in_group("enemy"):
			c.player = player
	
	# Display a message at the start of the day. 
	if GameData.day == 1:
		GameData.send_message(Messages.day_1)
	elif GameData.day == 2:
		GameData.send_message(Messages.day_2)
	elif GameData.day == 3:
		GameData.send_message(Messages.day_3)
	elif GameData.day == 4:
		GameData.send_message(Messages.day_4)
	elif GameData.day == 5:
		GameData.send_message(Messages.day_5)
	elif GameData.day == 8:
		GameData.send_message(Messages.day_8)

# Spawn a preset number of monsters on the map. The map needs to be generated first.
# We do this by first finding all the empty tiles, then distribute thee monsters uniformly
# out on those. This gives bigger caverns a larger chance to contain monsters.
func spawn_monsters():
	# Number of monsters to spawn
	var n_bats = 5
	var n_frogs = 5
	
	# Array of empty tile coordinates
	var empty = []
	
	# Find empty tiles
	for i in range(tilemaps.map_width):
		for j in range(2, tilemaps.map_depth):
			var coords = Vector2i(i, j)
			if tilemaps.tile_type_map[coords] == tilemaps.TileType.AIR:
				empty.append(coords)
	
	# Distribute the monsters
	for i in range(n_bats):
		var pos = empty.pick_random()
		spawn_monster(pos, Constants.SCENE_BAT)
	for i in range(n_frogs):
		var pos = empty.pick_random()
		spawn_monster(pos, Constants.SCENE_FROG)

# Spawns a monster on the given position. 'scene' should be a packed scene.
func spawn_monster(pos: Vector2i, scene: PackedScene):
	var monster = scene.instantiate()
	add_child(monster)
	monster.position = tilemaps.tiles.map_to_local(pos)


func _on_trigger_target_entered():
	var confirm
	print(GameData.cold)
	if GameData.cold > 25:
		confirm = await ui.do_confirm("Are you done mining for the day?")
	else:
		confirm = true
	if confirm:
		GameData.end_day()
		var house_scene = Constants.SCENE_HOUSE
		var house = house_scene.instantiate()
		get_tree().root.add_child(house)
		queue_free()
