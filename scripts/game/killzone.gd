extends Area2D
@onready var timer = $Timer
@onready var game_manager = %GameManager

# Player has died
func _on_body_entered(body):
	if body.is_in_group("player"):
		print("player entered enemy")
		Signals.player_damaged.emit(20)
