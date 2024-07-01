extends Area2D

@onready var agro_timer = $Timer

var	enemy

func _ready():
	enemy = get_parent()

func _on_body_entered(body):
	# Enemy becomes aware of and aggressive towards player
	if body.is_in_group("player") and enemy:
		# Trigger agro status in enemey script
		agro_timer.stop()
		enemy.agro = true

# Player got out of range
func _on_body_exited(body):
	# Wait 1s
	if body.is_in_group("player"):
		# start or restart aggressive status timer
		if agro_timer.is_stopped():
			agro_timer.start()

func _on_timer_timeout():
	# Return enmey to idle state
	#print("agro timer timeout")
	enemy.agro = false
