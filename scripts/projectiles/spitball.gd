extends Area2D

var speed = -10000

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.queue_free()
	queue_free()
