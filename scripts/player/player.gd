extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -330.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumps = 1
var lowJumpMultiplier = -40
var fallMultiplier = -3	
var sprintMultiplier = 1
var health = 100

var idle_anim = "new_idle"
var jump_anim = "new_jump"

@onready var marker_2d = $Marker2D
@onready var animated_sprite = $Marker2D/AnimatedSprite2D
@onready var animated_puff = $Marker2D/AnimatedSprite2D/AnimatedPuff
@onready var coyote_timer = $CoyoteTimer
@onready var death_timer = $DeathTimer

func _ready():
	# Listen for damage taken
	Signals.player_damaged.connect(on_player_damaged)

func _physics_process(delta):		
	# Player heals
	if Input.is_action_just_pressed("berry_heal"):
		if SaveManager.berries >= SaveManager.full_berries:
			if SaveManager.lives < 3:
				Signals.berry_heal.emit()
			else:
				print("Max lives")
		# Player attempted to heal without enough berries
		else:
			print("Not enough berries!")

	# Player attack
	if Input.is_action_just_pressed("basic_attack"):
		Signals.basic_attack.emit()
	
	# Player is starting to sprint
	if Input.is_action_just_pressed("sprint"):
		# Increase speed
		sprintMultiplier = 1.4
	if Input.is_action_just_released("sprint"):
		sprintMultiplier = 1

	# Jump pressed and player is on the ground
	if Input.is_action_just_pressed("jump"):
		jump(jumps)
		if coyote_timer.is_stopped():
			jumps -= 1

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")

	# Player is falling
	if velocity.y > 0: 
		# Falling is faster than jumping
		velocity += Vector2.UP * (fallMultiplier)
	# Player just jumped
	elif velocity.y < 0 and Input.is_action_just_released("jump"):
	# Jump Height depends on how long button is held
		velocity += Vector2.UP * (lowJumpMultiplier)

	# After landing on the ground
	if is_on_floor():		
		# Play animations
		animated_sprite.play(idle_anim)
		# Reset jumps
		jumps = 1
	# While in the air
	else:
		# Play animationss		
		animated_sprite.play(jump_anim)

	# Move player
	if direction:
		velocity.x = direction * SPEED * sprintMultiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Flip direction of sprite
	if direction > 0:
		marker_2d.scale.x = 1
		# animated_sprite.flip_h = true
	elif direction < 0:
		marker_2d.scale.x = -1
		# animated_sprite.flip_h = false

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Check if player is standing on something they can jump off	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	# After moving, the player is in the air
	if was_on_floor and !is_on_floor():
		# Wait time for player to jump
		coyote_timer.start()

func jump(jumps_remaining):
	if jumps_remaining > 0:
			velocity.y = JUMP_VELOCITY
			animated_puff.play("jump")

# Player took damage and loses health
func on_player_damaged(amount):
	health -= amount
	if health <= 0:
		die()

# Player is out of health
func die():
# 	# play death animation
# 	death_timer.start()
# 	animated_sprite.play("dying")
# 	animation_player.play("death")
	
	# Slow-mo death
	Engine.time_scale = 0.20
	# Remove collison body
	get_node("CollisionShape2D").queue_free()
	# Wait time it takes to die
	death_timer.start()

func _on_death_timer_timeout():
	if SaveManager.lives >= 0:
		# Player has lost a life
		Signals.lost_life.emit()
		# Reset time to normal speed after death
		Engine.time_scale = 1
		# Reload
		get_tree().reload_current_scene()
	if SaveManager.lives < 0:
		# Player has died
		GameManager.game_over()
