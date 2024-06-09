extends Node2D

var speed = -10000
var damage = 25

@export var Impact : PackedScene

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		Signals.enemy_damaged.emit(damage)
		
	# Impact
	var impact = Impact.instantiate()
	impact.position = position
	get_parent().add_child(impact)
	queue_free()
