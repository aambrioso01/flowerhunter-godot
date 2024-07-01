extends CharacterBody2D

@onready var player = %Player

@onready var sprite_2d = $Sprite2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_sight = $Sprite2D/RayCastSight
@onready var animation_player = $AnimationPlayer
@onready var death_timer = $DeathTimer 
@onready var collision_body = $CollisionPolygon2D2
@onready var hitbox = $DamageArea/Hitbox
@onready var attack_timer = $AttackTimer

signal enemy_damaged

const SPEED = 60
var direction = 1
var health = 100
var punch_anim = 'punch'
var idle_anim = 'idle'
var dying_anim = 'dying'
var dying = false
var agro = false
var fight_moves = ["swipe", "stomp", "dash"]
var current_move = 0
var is_attacking = false

func _ready():
	# Listen for damage taken
	enemy_damaged.connect(on_enemy_damaged)

	# Connect the animation_finished signal to the on_animation_finished function
	# animation_player.connect("animation_finished", on_animation_finished)

	# Start playing the first animation
	# animation_player.play(fight_moves[current_move])

func _process(delta):
	match agro:
		true:
			# Enemy is aware of and aggressive towards player
			if not dying:
				if attack_timer.is_stopped():
					if animation_player.current_animation == idle_anim:
						animation_player.stop()
					attack_timer.start()
					play_random_move()
				# Move towards player
				direction = (player.position - position).normalized().x
		false:
			if not dying and not animation_player.is_playing():
				print("idle overwrite")	
				animation_player.play("idle")
	
			if ray_cast_sight.is_colliding():
				direction = -direction

	# Stand in place when dying
	if dying:
		direction = 0
	
	# Face the direction of movementd
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
	dying = true
	animation_player.play("dying")

func play_random_move():
	var move = fight_moves.pick_random()
	animation_player.queue(move)

	#if is_attacking:
		#var move = fight_moves.pick_random()
		#animated_sprite.play(move)
		
# func on_animation_finished():
# 	# Move to the next animation in the queue
# 	current_move += 1
# 	print(" Move to the next animation in the queue")
# 	is_attacking = false

# 	# If the current_move is within the bounds of the fight_moves
# 	if current_move < fight_moves.size():
# 		# Play the next animation
# 		animation_player.play(fight_moves[current_move])
