extends CharacterBody2D

# Imports
@onready var mushy = $"."
@onready var sprite_2d = $Sprite2D
@onready var ray_cast_sight = $Sprite2D/RayCastSight
@onready var animation_player = $AnimationPlayer
@onready var death_timer = $DeathTimer 
@onready var collision_body = $CollisionPolygon2D2
@onready var hitbox = $DamageArea/Hitbox
@onready var attack_timer = $AttackTimer
@onready var player = %Player
@onready var flip_timer = $FlipTimer

# Signals
signal enemy_damaged

# Movement
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
const SPEED = 100
var direction
@export var sprint_multiplier = 1	
var last_direction
var can_flip = true

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
				# print((player.position - position).normalized().snapped(Vector2.ONE))
				direction = (player.position - position).normalized().snapped(Vector2.ONE).x
				sprint_multiplier = 1.5

			if ray_cast_sight.is_colliding():
				agro = false
				
		false:
			# Return 1 or -1 for direction
			direction = sign(direction)

			sprint_multiplier = 1

			if ray_cast_sight.is_colliding():
				direction = -direction

			if not is_dying and not animation_player.is_playing():
				animation_player.play(idle)

	# Stand in place when dying
	if is_dying:
		direction = 0
	
	# If enemy stops moving then set direction as last direction move
	if direction != 0:
		last_direction = direction
	else:
		direction = last_direction / 100

	if can_flip:
		# Face the direction of movement
		flip_timer.start()
		if direction > 0:
			# print("look right")
			mushy.scale.y = -0.1
			mushy.rotation = -PI
			can_flip = false
		if direction < 0:
			# print("look left")
			mushy.scale.y = 0.1
			mushy.rotation = 0
			can_flip = false

	# Clamp direction
	# direction = clamp(direction, -1, 1)

	# default movement side to side
	velocity.x = direction * SPEED * sprint_multiplier
	move_and_slide()

	# Add gravity.
	velocity.y += gravity * delta

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

func _on_flip_timer_timeout():
	can_flip = true
