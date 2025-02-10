extends Node

signal message_sent(message)
signal inventory_full
signal freeze_50
signal freeze_25
signal freeze_10
signal game_won
signal game_lost

enum GameState{
	HOUSE,
	MINING,
}

var game_state = GameState.HOUSE
var day = 0
var credits = 0
var credits_goal = 10000
var mining_speed = 1.2
var upgrades = [0, 0, 0, 0, 0, 0]

var player: CharacterBody2D

var freeze_counter = 0

func _ready():
	inventory = Inventory.new()
	player = get_tree().root.find_child("Miner", true, false)
	
func _process(delta):
	if player != null and game_state == GameState.MINING:
		cold -= cold_decay * delta * (1 + player.position.y/64)
		if cold <= 0:
			game_over()
		if freeze_counter == 0 and cold < 50:
			freeze_50.emit()
			freeze_counter += 1
		elif freeze_counter == 1 and cold < 25:
			freeze_25.emit()
			freeze_counter += 1
		elif freeze_counter == 2 and cold < 10:
			freeze_10.emit()
			freeze_counter += 1
	
	if day == 10 and game_state == GameState.HOUSE:
		payout()
		if credits >= credits_goal:
			game_won.emit()
		else:
			game_lost.emit()
			game_over()

func update_player(player):
	print("UPDATED")
	self.player = player

func start_day():
	day += 1
	game_state = GameState.MINING
	health = max_health
	cold = max_cold
	freeze_counter = 0

func end_day():
	game_state = GameState.HOUSE
	cold = max_cold

## Inventory

var stone_price = 1
var ore_price = 10
var gem_price = 100

var bonus_ore = 0

enum ItemTypes{
	STONE,
	ORE,
	GEM,
	TORCH,
}
var inventory: Inventory
class Inventory:
	var items: Dictionary = {}
	var capacity: int = 20
	var size: int = 0
	func _init():
		for i in ItemTypes.values():
			items[i] = 0

	# Adds items of the given type. Returns the remainding number of items (if capacity was reached).
	func add_items(type: ItemTypes, amount: int = 1) -> int:
		if type == ItemTypes.ORE:
			amount += GameData.bonus_ore
		if size + amount <= capacity:
			items[type] += amount
			size += amount
			if size == capacity:
				GameData.inventory_full.emit()
			return 0
		else:
			GameData.inventory_full.emit()
			var items_to_add = capacity - size
			items[type] += items_to_add
			size = capacity
			return amount - items_to_add

	# Removes items of the given type. Returns true if successful, false if failed to remove.
	func remove_items(type: ItemTypes, amount: int = 1) -> bool:
		if items[type] >= amount:
			items[type] -= amount
			size -= amount
			return true
		else:
			return false
	
	# Expects 'recipe' to be an array of arrays, each of the form [ItemType, int].
	# Items cannot be repeated. Returns similar to 'remove_items'
	func remove_items_from_recipe(recipe: Array):
		# First we check if the required items are in the inventory
		for entry in recipe:
			var type = entry[0]
			var amount = entry[1]
			if items[type] < amount:
				return false
		# Then, if successful, we remove the items
		for entry in recipe:
			var type = entry[0]
			var amount = entry[1]
			items[type] -= amount
			size -= amount
		return true

	# Removes all items
	func clear():
		var torches = items[GameData.ItemTypes.TORCH]
		for i in ItemTypes.values():
			items[i] = 0
		items[GameData.ItemTypes.TORCH] = torches
		size = torches

func get_item_price(type: ItemTypes):
	match(type):
		ItemTypes.STONE:
			return stone_price
		ItemTypes.ORE:
			return ore_price
		ItemTypes.GEM:
			return gem_price

func payout():
	var res = 0
	for i in GameData.inventory.items.keys():
		if GameData.get_item_price(i) != null:
			res += GameData.inventory.items[i] * GameData.get_item_price(i)
	credits += res
	inventory.clear()


## === COLD ===
var cold: float = 100
var max_cold: float = 100
var cold_decay: float = 0.6

## === HEALTH ===
var health: float = 100
var max_health: float = 100

func add_health(value: float):
	health += value
	if health > max_health:
		health = max_health

func damage_health(value: float):
	health -= value
	if health <= 0:
		game_over()


func game_over():
	reset()
	get_tree().root.find_child("Game", false, false).queue_free()
	var house_scene = Constants.SCENE_HOUSE
	var house = house_scene.instantiate()
	get_tree().root.add_child(house)


## === MESSAGES ===

func send_message(message: String):
	message_sent.emit(message)

func reset():
	health = 100
	max_health = 100
	cold = 100
	cold_decay = 0.5
	game_state = GameState.HOUSE
	day = 0
	credits = 0
	credits_goal = 10000
	mining_speed = 1.2
	upgrades = [0, 0, 0, 0, 0, 0]
	freeze_counter = 0
	stone_price = 1
	ore_price = 10
	gem_price = 100
	bonus_ore = 0
	inventory = Inventory.new()
