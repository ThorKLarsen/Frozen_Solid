extends VBoxContainer

var torch_recipe = [
	[GameData.ItemTypes.ORE, 2],
	[GameData.ItemTypes.STONE, 1]
]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func craft_recipe(recipe:Array, result: GameData.ItemTypes, amount: int = 1):
	if GameData.inventory.remove_items_from_recipe(recipe):
		GameData.inventory.add_items(result, amount)

func _on_torch_craft_button_button_pressed():
	craft_recipe(torch_recipe, GameData.ItemTypes.TORCH)
