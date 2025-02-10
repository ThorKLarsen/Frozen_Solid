extends AnimatedSprite2D

signal cycle_finished

var start_pos: Vector2
var end_pos: Vector2 = Vector2(-15, 0)

var speed: float = 10
var talk_timer: float = 12
var state = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = position
	end_pos = start_pos + end_pos
	set_process(false)
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == 0:
		show()
		flip_h = true
		play("walk")
		position = position.move_toward(end_pos, speed * delta)
		if position == end_pos:
			state += 1
			GameData.send_message(Messages.boss_1)
			GameData.send_message(Messages.boss_2)
			print("yes")
	elif state == 1:
		play("idle")
		talk_timer -= delta
		if talk_timer <= 0:
			state += 1
			position.x += 2
	elif state == 2:
		play("walk")
		flip_h = false
		position = position.move_toward(start_pos, speed * delta)
		if position == start_pos:
			state += 1
	else:
		cycle_finished.emit()
		hide()
		set_process(false)

func start_cycle():
	show()
	set_process(true)
