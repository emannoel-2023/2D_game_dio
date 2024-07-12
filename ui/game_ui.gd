extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var meat_label: Label = %MeatLabel

var timer_elapsed:float = 0.0
var meat_counter:int = 0
var player_connected: bool = false

func _ready():
	meat_label.text = str(meat_counter)
func _process(delta: float):
	timer_elapsed += delta
	var timer_elapsed_in_seconds: int = floori(timer_elapsed)
	var seconds:int = timer_elapsed_in_seconds % 60
	var minutes:int = timer_elapsed_in_seconds / 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

	if not player_connected and GameManager.player:
		GameManager.player.meat_collected.connect(on_meat_collected)
		player_connected = true

func on_meat_collected(regeneration_value:int)-> void:
	meat_counter += 1
	meat_label.text = str(meat_counter)
