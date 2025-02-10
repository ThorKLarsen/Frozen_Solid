extends NinePatchRect

var enter_wait = 0.5
var enter_timer = 0.0
var open_y = 0
var close_y = -52
var open_speed = abs(close_y - open_y)/enter_wait

var is_open = false

@onready var text_field = $TextLayer/TextField
@onready var char_sound: AudioStreamPlayer = $AudioStreamPlayer2D
var text_settings: String = "[font=res://font/PixelOperator.ttf][font_size=32]"

var message_queue = []
var char_queue = []

var timer_char: float = 0
var wait_char: float = 3.0/60.0
var timer_message: float = 0
var wait_message: float = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	text_field.text = text_settings
	GameData.message_sent.connect(_on_message_sent)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_open and open_y != position.y:
		position.y = move_toward(position.y, open_y, open_speed * delta)
		$TextLayer.offset.y = position.y * 3
	if !is_open and close_y != position.y:
		position.y = move_toward(position.y, close_y, open_speed * delta)
		$TextLayer.offset.y = position.y * 3
	
	if !char_queue.is_empty():
		timer_char -= delta
		if timer_char <= 0:
			timer_char += wait_char
			var char = char_queue.pop_front()
			text_field.text += char
			if char != ' ' and char != '\n':
				char_sound.play()
	else:
		char_sound.stop()
		timer_char = 0
		timer_message -= delta
		if timer_message <= 0:
			if !message_queue.is_empty():
				show_next_message()
				timer_message = wait_message
			else:
				text_field.text = text_settings
				close()

func _input(event):
	pass
	#if event.is_action_pressed("open_textbox"):
		#is_open = !is_open

func open():
	is_open = true
func close():
	is_open = false


func add_message(message: String):
	message_queue.append(message)

func show_next_message():
	open()
	text_field.text = text_settings
	timer_char = 0
	var message = message_queue.pop_front()
	for char in message:
		char_queue.append(char)

func _on_message_sent(message: String):
	message_queue.append(message)
