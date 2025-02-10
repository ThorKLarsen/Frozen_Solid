extends Node2D

@export var player: CharacterBody2D
@export var ui: OnScreenUI

var game_is_started: bool = true

func _ready():
	ui.game_started.connect(_on_game_started)
	$Boss.cycle_finished.connect(_on_boss_cycle_finished)
	GameData.update_player(player)

	
	if GameData.day == 0:
		ui.show_main_menu()
		game_is_started = false
	elif GameData.day > 0:
		ui.show_payout_summary()

func _on_game_started():
	if GameData.day == 0:
		$Boss.start_cycle()

func _on_boss_cycle_finished():
	game_is_started = true

func _on_trigger_target_entered():
	if !game_is_started:
		return
	if await $CanvasLayer.do_confirm("Want to start day " + str(GameData.day+1) + "?"):
		
		GameData.start_day()
		
		var game_scene = Constants.SCENE_GAME
		var game = game_scene.instantiate()
		get_tree().root.add_child(game)
		queue_free()


func _on_upgrade_station_target_entered():
	if !game_is_started:
		return
	print("UPGRADE")
	ui.show_upgrade_menu()
