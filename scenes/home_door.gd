extends Area2D

@export var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("ui_up"):
		for body in get_overlapping_bodies():
			if body == player:
				pass #Enter home
