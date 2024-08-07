extends Area2D
@onready var timer = $Timer
@onready var game_manager = %GameManager

# Player has died
func _on_body_entered(_body):
	# print("kill zone", body)
	# if body == player
	# #Slow-mo death
	Engine.time_scale = 0.20
	timer.start()

# Wait time it takes to die
func _on_timer_timeout():
	if SaveManager.lives >= 0:
		# Player has lost a life
		Signals.lost_life.emit()
		# Reset time to normal speed after death
		Engine.time_scale = 1
		# Reload
		get_tree().reload_current_scene()
	if SaveManager.lives < 0:
		# Player has died
		GameManager.game_over()
