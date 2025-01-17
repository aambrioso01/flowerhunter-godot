extends CharacterBody2D

# Imports
@onready var sprite_2d = $Sprite2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_sight = $Sprite2D/RayCastSight
@onready var animation_player = $AnimationPlayer
@onready var death_timer = $DeathTimer 
@onready var collision_body = $CollisionPolygon2D2
@onready var hitbox = $DamageArea/Hitbox
@onready var attack_timer = $AttackTimer
@onready var player = %Player

# Signals
signal enemy_damaged

# Movement
const SPEED = 70
var direction
@export var sprint_multiplier = 2	

# Status
var health
var is_dying = false
var agro = false
var can_attack = true

# Animations
var punch = 'punch'
var idle = 'idle'	
var dying = 'dying'
var fight_moves = ["swipe", "stomp", "dash"]

func _ready():
	# Listen for damage taken
	enemy_damaged.connect(on_enemy_damaged)

	# Default status
	direction = 1
	health = 100

func _process(delta):
	match agro:
		true:
			# Enemy is aware of and aggressive towards player
			if not is_dying:
				play_random_move()
				# Move towards player
				direction = (player.position - position).normalized().x * sprint_multiplier
			if ray_cast_sight.is_colliding():
				agro = false
		false:
			if ray_cast_sight.is_colliding():
				direction = -direction

			if not is_dying and not animation_player.is_playing():
				animation_player.play(idle)

	# Stand in place when dying
	if is_dying:
		direction = 0
	
	# Face the direction of movement
	if direction > 0:
		sprite_2d.scale.x = -1
	elif direction < 0:
		sprite_2d.scale.x = 1

	# default movement side to side
	position.x += direction * SPEED * delta

func on_enemy_damaged(amount):
	health -= amount
	if health <= 0:
		die()

# Timed death sequence
func die():
	is_dying = true
	animation_player.play(dying)

func play_random_move():
	if can_attack:
		var move = fight_moves.pick_random()
		animation_player.play(move)

		attack_timer.start()
		can_attack = false
	elif not animation_player.is_playing():
		animation_player.play(idle)
		
func _on_attack_timer_timeout():
	can_attack = true
