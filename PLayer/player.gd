class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3

@export_category("Sword")
@export var sword_damage:int = 4

@export_category("Ritual")
@export var ritual_damage: int = 5

@export var ritual_interval: float = 30.0
@export var ritual_scene: PackedScene

@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab:PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitBoxArea
@onready var health_progress_bar = $HealthProgressBar
@onready var damage_digit_marker = $DamageDigitMarker

var input_vector:Vector2 = Vector2(0,0)
var is_running: bool = false
var ass_running: bool = false
var is_attackging: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0
var damage_amount: int
var damage_digit_prefab:PackedScene

signal meat_collected(value: int)

func _ready():
	GameManager.player = self
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")
	meat_collected.connect(func(value:int): GameManager.meat_counter += 1)

func _process(delta: float)-> void:
	GameManager.player_position = position
	read_input()

	#ataque
	if Input.is_action_just_pressed("atack"):
		attack()
	#processar ataque
	update_attack_cooldown(delta)

	#processar animação e rotação do sprite
	if not is_attackging:
		rotate_sprite()
	play_run_idle_animation()
	
	#processar dano
	update_hitbox_detection(delta)
	
	#Ritual
	update_ritual(delta)
	
	#Atualizar Health bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

func _physics_process(delta: float)-> void:
	#modificar velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attackging:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()

func update_attack_cooldown(delta:float)-> void:
	#atualizar temporizador do ataque
	if is_attackging:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attackging = false
			is_running = false 
			animation_player.play("idle")

func update_ritual(delta:float)-> void:
	#atualiza temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0:
		return
	ritual_cooldown = ritual_interval
	create_ritual()
	
func create_ritual()->void:
	#Criar o ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)

func read_input()-> void:
	#obter o input vector
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down")

	#apagar o dead zone do input_vector
	var dead_zone = 0.15
	if abs(input_vector.x) < dead_zone:
		input_vector.x = 0.0
	if abs(input_vector.y) < dead_zone:
		input_vector.y = 0.0

	#atualizar os is_running
	ass_running = is_running
	is_running = not input_vector.is_zero_approx()

func attack()-> void:
	if is_attackging:
		return
		#toca animação de ataque
	animation_player.play("atack_side_1")
	#configurar temporizador
	attack_cooldown = 0.6
	is_attackging=true

func play_run_idle_animation() -> void:
	#tocar animação
	if not is_attackging:
		if ass_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite() -> void:
	#girar sprite
	if input_vector.x > 0 :
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func deal_damage_to_enemies()-> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(sword_damage)


func update_hitbox_detection(delta:float)-> void:
	#hitbox cooldown
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0:
		return

	#frequencia
	hitbox_cooldown = 0.5

	#detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies") and body is Enemy:
			var enemy: Enemy = body
			match enemy.enemy_type:
				"Pawn":
					damage_amount = 4
					print("Dano do operario: ", damage_amount)
				"Sheep":
					damage_amount = 2
					print("Dano da ovelha: ", damage_amount)
				"Goblin":
					damage_amount = 10
					print("Dano do goblin: ", damage_amount)
				_:
					damage_amount = 2  # Valor padrão caso o tipo não corresponda a nenhum dos anteriores
					print("Dano do ", enemy.enemy_type, ": ", damage_amount)
			# Aplica o dano ao jogador
			damage(damage_amount)

func damage(amount: int)-> void:
	#processar morte
	if health <= 0:
		die()

	if health <= 0:
		return
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


func die()-> void:
	GameManager.end_game()
	if death_prefab:
		var death_obj = death_prefab.instantiate()
		death_obj.position = position
		get_parent().add_child(death_obj)

	queue_free()

func piscar_node()-> void:
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func heal(amount: int)-> int:
	health += amount
	if health > max_health:
		health = max_health
	print(" recebeu cura de ",amount,"vida total",health)
	return health
