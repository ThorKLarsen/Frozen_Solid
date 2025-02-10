extends Node

# Game constants

const map_width = 75
const map_depth = 80
const sky_height = 10

const game_scale = 12
const tile_width = 8

# preloaded scenes

var SCENE_GAME = load("res://scenes/game.tscn")
var SCENE_HOUSE = load("res://scenes/house.tscn")

const SCENE_BAT = preload("res://scenes/bat.tscn")
const SCENE_FROG = preload("res://scenes/frog_monster.tscn")
