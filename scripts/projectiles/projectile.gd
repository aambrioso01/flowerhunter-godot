extends Area2D

@export var Impact : PackedScene
var direction : Vector2 = Vector2.RIGHT
var damage : float = 1
var speed : float = 400

func _process(delta):
	position += direction * speed * delta
	
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		damage_enemy(body, damage)
		
	# Impact
	var impact = Impact.instantiate()
	impact.position = position
	get_parent().add_child(impact)
	queue_free()

func damage_enemy(enemy, damage_amount):
	enemy.emit_signal("enemy_damaged", damage_amount)

func set_direction(flip_direction, frame):
	$Sprite2D.frame = frame
	if flip_direction > 0:
		$Sprite2D.scale.x = -$Sprite2D.scale.x
		direction = Vector2.RIGHT
	elif flip_direction < 0:
		direction = Vector2.LEFT

func _on_screen_exited():
	queue_free()
