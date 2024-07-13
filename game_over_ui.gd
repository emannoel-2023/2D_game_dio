class_name GameOverUI
extends CanvasLayer

@onready var time_label:Label = %TimeLabel
@onready var monster_label:Label = %MonstersLabel

@export var restart_delay:float = 5.0
var start_cooldown: float

func _ready():
	time_label.text = GameManager.time_elapse_string
	monster_label.text = str(GameManager.monster_defeated_counter)
	start_cooldown = restart_delay

func _process(delta):
	start_cooldown -= delta
	if start_cooldown <= 0.0:
		restart_game()
		
func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
	print("restatr game please")
	
