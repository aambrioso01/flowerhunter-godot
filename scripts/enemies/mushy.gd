extends CharacterBody2D

const SPEED = 60

var direction = 1
var health = 100

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var death_timer = $DeathTimer

func _ready():
	# Listen for damage taken
	Signals.enemy_damaged.connect(on_enemy_damaged)

func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = false
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = true

	position.x += direction * SPEED * delta

func on_enemy_damaged(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	# play death animation
	death_timer.start()
	animated_sprite.play("dying")
	animation_player.play("death")

func _on_death_timer_timeout():
	queue_free()
