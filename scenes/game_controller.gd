extends Node2D

func _ready():
	

func make_game():
	var game_scene = preload("res://scenes/game.tscn")
	var game = game_scene.instantiate()
	
	add_child(game)

func make_house():
	var house_scene = preload("res://scenes/house.tscn")
	var house = house_scene.instantiate()
	add_child(house)
