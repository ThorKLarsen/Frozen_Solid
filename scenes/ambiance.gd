extends AudioStreamPlayer

var timer: float = 0
var wait: float = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = randf_range(0.5, 1.5) * wait


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer -= delta
	if timer <= 0:
		timer = randf_range(0.5, 1.5) * wait
		if randf() > 0.5:
			play()
