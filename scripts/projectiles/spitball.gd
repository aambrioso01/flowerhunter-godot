extends Node2D

var speed = -10000
var damage = 25

@export var Impact : PackedScene

func _physics_process(delta):
	position += transform.x * speed * delta

func damage_enemy(enemy, damage_amount):
	enemy.emit_signal("enemy_damaged", damage_amount)

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		damage_enemy(body, damage)
		
	# Impact
	var impact = Impact.instantiate()
	impact.position = position
	get_parent().add_child(impact)
	queue_free()
