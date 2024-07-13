class_name Enemy
extends Node2D

@export var health: int = 10
@export var enemy_type: String = "default"  # Adiciona uma variável exportada para o tipo de inimigo
@export var death_prefab:PackedScene
@onready var damage_digit_marker = $DamageDigitMarker
var damage_digit_prefab:PackedScene

@export var drop_chance:float = 0.1
@export var drop_items: Array[PackedScene]
@export var drop_chances:Array[float]
func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")
func damage(amount: int)-> void:
	health -= amount
	
	#cria damage digit
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	#piscar node
	piscar_node()

	#processar morte
	if health <= 0:
		die()

func die()-> void:
	#caveira de morte
	if death_prefab:
		var death_obj = death_prefab.instantiate()
		death_obj.position = position
		get_parent().add_child(death_obj)
		
	#Drop
	if randf() <= drop_chance:
		drop_item()
		
	GameManager.monster_defeated_counter += 1
		
	#liberar node
	queue_free()

func piscar_node()-> void:
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)


func drop_item()->void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)

func get_random_drop_item() -> PackedScene:
	#listas com um item
	if drop_items.size() == 1:
		return drop_items[0]
	
	#calcular chance maxima
	var max_chance:float = 0.0
	for drop_chance in drop_chances:
		max_chance += drop_chance
	
	#jogar dado
	var random_value = randf() * max_chance
	
	#girar a roleta 
	var needle:float = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance
	return drop_items[0]
	
	
	
	
