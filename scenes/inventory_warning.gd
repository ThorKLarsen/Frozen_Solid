extends Control

@onready var warn_sound = $WarningSound
var warn_timer = 0
var warn_wait = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.inventory_full.connect(_on_inventory_full)
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if warn_timer > 0:
		warn_timer -= delta
		if cos(warn_timer * 10) > 0:
			hide()
		else:
			show()
		if warn_timer < 0:
			hide()
			warn_sound.stop()

func _on_inventory_full():
	warn_timer = warn_wait
	warn_sound.play()
