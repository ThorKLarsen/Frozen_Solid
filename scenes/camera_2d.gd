extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	limit_left = -96
	limit_right = (Constants.map_width-1) * Constants.game_scale * Constants.tile_width
	limit_bottom = Constants.map_depth * Constants.game_scale * Constants.tile_width

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
