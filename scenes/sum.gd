extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var res = 0
	for i in GameData.inventory.items.keys():
		if GameData.get_item_price(i) != null:
			res += GameData.inventory.items[i] * GameData.get_item_price(i)
	text = str(res)
