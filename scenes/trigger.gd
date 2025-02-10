extends Area2D

signal target_entered()

@export var target: CharacterBody2D

func _on_body_entered(body):
	if body == target:
		target_entered.emit()
