class_name OnScreenUI extends CanvasLayer
# Used for interfacing with the UI

signal confirm_result(is_confirmed)
signal game_started

@export var confirm: Control
@export var payout_summary: Control
@export var upgrade_menu: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	confirm.hide()
	$Control/MainMenu.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_payout_summary():
	payout_summary.show_summary() 

func show_upgrade_menu():
	upgrade_menu.show()

func show_main_menu():
	$Control/MainMenu.show()

func do_confirm(text):
	confirm.show()
	$Control/Confirm/MarginContainer/VBoxContainer/Label.text = text
	var result = await confirm_result
	confirm.hide()
	return result

func _on_confirm_no_button_pressed():
	confirm_result.emit(false)

func _on_confirm_yes_button_pressed():
	confirm_result.emit(true)

func _on_start_game_button_pressed():
	game_started.emit()
	$Control/MainMenu.hide()
