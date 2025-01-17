extends Area2D

@onready var animation_player = $AnimationPlayer

# Player touched enemy
func _on_body_entered(body):
	# print("new body entered:", body)
	if body.is_in_group("player"):
		Signals.player_damaged.emit(20)
		animation_player.play("impact")
