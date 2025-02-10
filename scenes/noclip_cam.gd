extends Node2D

const SPEED = 400

func _process(delta):
	if Input.is_action_pressed("ui_up"):
		position.y -= SPEED*delta
	if Input.is_action_pressed("ui_down"):
		position.y += SPEED*delta
	if Input.is_action_pressed("ui_left"):
		position.x -= SPEED*delta
	if Input.is_action_pressed("ui_right"):
		position.x += SPEED*delta
