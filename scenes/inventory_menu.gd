extends NinePatchRect

@export var text_box: Control

@onready var sound_open: AudioStreamPlayer2D = $MenuOpen

var enter_wait = 0.5
var enter_timer = 0.0
var open_y = 68
var close_y = 237
var open_speed = abs(close_y - open_y)/enter_wait

var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_open and open_y != position.y:
		position.y = move_toward(position.y, open_y, open_speed * delta)
	if !is_open and close_y != position.y:
		position.y = move_toward(position.y, close_y, open_speed * delta)


func _input(event):
	if event.is_action_pressed("open_inventory"):
		is_open = !is_open
		if is_open:
			sound_open.play()
			#text_box.close()
		else:
			sound_open.play()
			#text_box.open()
