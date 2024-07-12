extends Node2D

@export var creatures: Array[PackedScene]
@export var mobs_per_minute: float = 60.0
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
	interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	#checar se o ponto é valido
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1000
	var results = world_state.intersect_point(parameters, 1)
	if not results.is_empty():
		return
	
	#instancia a criatura
	instanciate_creature()
	
func instanciate_creature():
	var point = get_point()
	var index = randi_range(0, creatures.size()-1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = point
	get_parent().add_child(creature)
