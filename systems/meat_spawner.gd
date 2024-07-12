extends Node2D

@export var meats: PackedScene
@export var meats_per_minute: float = 8.0
@onready var path_follow_2d = %PathFollow2D
var cooldown: float = 0.0
var interval: float 

func _process(delta: float):
	#temporizador
	cooldown_calc(delta)

func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position

func cooldown_calc(delta:float):
	#temporizador
	cooldown -= delta
	if cooldown > 0:
		return
	#frequencia por minuto
	interval = 60.0 / meats_per_minute
	cooldown = interval
	
	#instancia a criatura
	instanciate_creature()
	
func instanciate_creature():
	var meat_scene = meats
	var meat = meat_scene.instantiate()
	meat.global_position = get_point()
	get_parent().add_child(meat)
