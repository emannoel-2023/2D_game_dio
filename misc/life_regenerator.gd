extends Node2D

@export var regeneratio_amount: int = 10


func _ready():
	%Area2D.body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D)-> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.heal(regeneratio_amount)
		if player:
			player.meat_collected.emit(regeneratio_amount)
		queue_free()
	
