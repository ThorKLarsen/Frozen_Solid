extends HBoxContainer

@export var price_tag: Label

var starting_price = 300
var price_increase = 200

var price: int:
	set(value):
		price_tag.text = str(value)
		price = value
	get():
		return starting_price + price_increase * GameData.upgrades[5]

# Called when the node enters the scene tree for the first time.
func _ready():
	price_tag.text = str(price)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func do_upgrade():
	GameData.bonus_ore += 1
	GameData.upgrades[5] += 1

func _on_my_button_button_pressed():
	if GameData.credits >= price:
		GameData.credits -= price
		do_upgrade()
		price_tag.text = str(price)
