extends Node

@export var mob_spawner: MobSpawner
@export var spawn_rate_initial:float = 60.0
@export var spawn_rate_per_minute: float = 30.0
@export var time_wave:float = 20.0
@export var wave_intensity:float = 0.5
var time:float = 0.0


func _process(delta: float)-> void:
	#ignorar game over
	if GameManager.is_game_over: return
	
	#temporizador
	time += delta
	
	#Dificuldade linear
	var spawn_rate = spawn_rate_initial + spawn_rate_per_minute * time
	
	#sistema de ondas
	var sin_wave = sin((time * TAU)/ time_wave)
	var wave_factor = remap(sin_wave, -1.0, 1.0, wave_intensity, 1)
	spawn_rate *= wave_factor
	
	#aplica dificuldade
	mob_spawner.mobs_per_minute = spawn_rate
