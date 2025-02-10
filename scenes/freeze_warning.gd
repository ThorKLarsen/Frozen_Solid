extends Control

@export var warn_sound: Node
@onready var warn_label = $Label2
var warn_timer = 0
var warn_wait = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.freeze_50.connect(_on_freeze_50)
	GameData.freeze_25.connect(_on_freeze_25)
	GameData.freeze_10.connect(_on_freeze_10)
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

func _on_freeze_50():
	warn_timer += 3
	warn_label.text = "FREEZING\n50%"
	warn_sound.play()
func _on_freeze_25():
	warn_timer += 4
	warn_label.text = "FREEZING\n25%"
	warn_sound.play()
func _on_freeze_10():
	warn_timer += 10
	warn_label.text = "FREEZING\n10%"
	warn_sound.play()
