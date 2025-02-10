extends Node2D

signal enter_house()

@export var player: CharacterBody2D
@export var tilemaps: Node2D
@export var ui: CanvasLayer

func _ready():
	GameData.update_player(player)
	spawn_monsters()
	player.position = Vector2(40, -4.2)
	
	for c in get_children():
		if c.is_in_group("enemy"):
			c.player = player
	
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

func spawn_monsters():
	var n_bats = 5
	var n_frogs = 5
	
	var empty = []
	
	for i in range(tilemaps.map_width):
		for j in range(2, tilemaps.map_depth):
			var coords = Vector2i(i, j)
			if tilemaps.tile_type_map[coords] == tilemaps.TileType.AIR:
				empty.append(coords)
	
	for i in range(n_bats):
		var pos = empty.pick_random()
		spawn_monster(pos, Constants.SCENE_BAT)
	for i in range(n_frogs):
		var pos = empty.pick_random()
		spawn_monster(pos, Constants.SCENE_FROG)

func spawn_monster(pos: Vector2i, scene):
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
