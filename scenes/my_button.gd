class_name MyButton extends TextureRect

signal button_pressed
signal button_released

@export var top_button: TextureRect
@export var input_shortcut: String

var is_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if not visible:
		return
	if event is InputEventMouseButton:
		if event.is_pressed():
			var mouse_pos = get_global_mouse_position()
			var poly = [
				Vector2(global_position),
				Vector2(global_position.x + size.x, global_position.y),
				Vector2(global_position.x + size.x, global_position.y + size.y),
				Vector2(global_position.x, global_position.y + size.y)
			]
			if Geometry2D.is_point_in_polygon(mouse_pos, poly):
				press()
		
		if event.is_released():
			if is_pressed:
				release()
	elif input_shortcut.length() > 0:
		return
		if has_focus():
			if event.is_action_pressed(input_shortcut):
				press()
				release()
	
	
func press():
	if !is_pressed:
		is_pressed = true
		button_pressed.emit()
		top_button.hide()

func release():
	if is_pressed:
		is_pressed = false
		button_released.emit()
		top_button.show()
