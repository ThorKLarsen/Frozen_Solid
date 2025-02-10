extends NinePatchRect

var show_time = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	GameData.game_won.connect(_on_game_won)
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	show_time -= delta
	if show_time <= 0:
		show_time = 15
		hide()
		set_process(false)

func _on_game_won():
	show()
	set_process(true)
