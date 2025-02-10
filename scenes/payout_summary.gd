extends NinePatchRect

@export var grid: GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	propagate_call("set_process", [false])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_summary():
	show()
	propagate_call("set_process", [true])

func _on_my_button_button_pressed():
	hide()
	propagate_call("set_process", [false])
	GameData.payout()
