extends Node

signal  game_over

var player: Player
var player_position: Vector2
var is_game_over: bool = false
var timer_elapsed:float = 0.0
var meat_counter:int = 0
var time_elapse_string: String
var monster_defeated_counter: int = 0

func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()


func _process(delta: float):
	timer_elapsed += delta
	var timer_elapsed_in_seconds: int = floori(timer_elapsed)
	var seconds:int = timer_elapsed_in_seconds % 60
	var minutes:int = timer_elapsed_in_seconds / 60
	time_elapse_string = "%02d:%02d" % [minutes, seconds]


func reset():
	player = null
	player_position - Vector2.ZERO
	is_game_over = false
	timer_elapsed= 0.0
	meat_counter = 0
	time_elapse_string= "00:00"
	monster_defeated_counter = 0
	for connections in game_over.get_connections():
		game_over.disconnect(connections.callable)
