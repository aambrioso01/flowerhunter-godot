extends CharacterBody2D

@export var SPEED = 120.0
const JUMP_VELOCITY = -330.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumps = 1
var lowJumpMultiplier = -40
var fallMultiplier = -3	
var sprintMultiplier = 1
var health = 100
var dying
var llama_mode

var idle_anim = "idle"
var jump_anim = "jump"
var hurt_anim = "hurt"
var roll_anim = "roll"

@onready var marker_2d = $Marker2D
@onready var animation_player = $AnimationPlayer
@onready var coyote_timer = $CoyoteTimer
@onready var death_timer = $DeathTimer

func _ready():
	# Set flags
	dying = false
	llama_mode = false
	# Listen for relevant signals
	Signals.player_damaged.connect(on_player_damaged)
	Signals.cake_collected.connect(self.on_cake_collected)

func _physics_process(delta):
	if not dying and animation_player.current_animation != 'transform':
		match llama_mode:
			true:
				idle_anim = 'llama_idle'
				jump_anim = 'llama_jump'
				hurt_anim = 'llama_hurt'
				roll_anim = 'llama_roll'
			false:
				idle_anim = 'idle'
				jump_anim = 'jump'
				hurt_anim = 'hurt'
				roll_anim = 'roll'
			
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

		# Rolling dodge move
		if Input.is_action_just_pressed("roll"):
			animation_player.play(roll_anim)

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

		if not dying:
			# After landing on the grounda
			if is_on_floor():
				# Play animations
				animation_player.queue(idle_anim)
				# Reset jumps
				jumps = 1
			# While in the air
			else:
				# Play animations	
				animation_player.queue(jump_anim)

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
		if was_on_floor and not is_on_floor():
			# Wait time for player to jump
			coyote_timer.start()

	else:
		velocity = Vector2(0, 0)

func jump(jumps_remaining):
	if jumps_remaining > 0:
			velocity.y = JUMP_VELOCITY
			animation_player.play(jump_anim)

# Player took damage and loses health
func on_player_damaged(amount):
	if not dying:
		animation_player.play(hurt_anim)
		health -= amount
		if health <= 0:
			die()
		elif llama_mode:
			animation_player.play('transform')
			llama_mode = false

# Player is out of health
func die():
	# Start death sequence
	dying = true
	# Stop any other animation
	animation_player.stop()
	# Play death animation
	animation_player.queue("death")
	
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

func on_cake_collected():
	llama_mode = true
	animation_player.play('transform')
