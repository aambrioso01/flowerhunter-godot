extends Area2D
@onready var timer = $Timer
@onready var game_manager = %GameManager

# Player has died
func _on_body_entered(body):
	print("You died")
	# Slow-mo death
	Engine.time_scale = 0.20
	# Remove collison body
	body.get_node("CollisionShape2D").queue_free()
	# Wait time it takes to die
	timer.start()

func _on_timer_timeout():
	# Player has lost a life
	
	
	# Reset time to normal speed after death
	Engine.time_scale = 1
	# Reload
	get_tree().reload_current_scene()
