extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "= "
	text += str(GameData.inventory.items[GameData.ItemTypes.STONE])
	text += " x "
	text += str(GameData.get_item_price(GameData.ItemTypes.STONE))
