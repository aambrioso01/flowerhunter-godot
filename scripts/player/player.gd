extends CharacterBody2D

# Physical properties
const SPEED = 140
const JUMP_VELOCITY = -330
@export var boost = 1.0
var sprint_multiplier = 1.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps = 1
var lowJumpMultiplier = -30
var fallMultiplier = -2	

# Health and status
var health = 100
var dying
var llama_mode

# Animations
var idle
var run
var jump
var hurt
var roll
var interruptions

# References to other nodes
@onready var marker_2d = $Marker2D
@onready var animation = $AnimationPlayer
@onready var weapon = $WeaponFX
@onready var coyote_timer = $CoyoteTimer
@onready var death_timer = $DeathTimer

# Resources
@export var current_weapon: Weapon:
	set(value):
		current_weapon = value

func _ready():
	# Set flags
	dying = false
	llama_mode = false
	# Listen for relevant signals
	Signals.player_damaged.connect(on_player_damaged)
	Signals.cake_collected.connect(self.on_cake_collected)

func _physics_process(delta):
	if not dying and animation.current_animation != 'transform':
		match llama_mode:
			true:
				idle = 'llama_idle'
				run = 'llama_run'
				jump = 'llama_jump'
				hurt = 'llama_hurt'
				roll = 'llama_roll'
			false:
				idle = 'idle'
				run = 'idle'
				jump = 'jump'
				hurt = 'hurt'
				roll = 'roll'

		interruptions = [hurt, roll]

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
			sprint_multiplier = 1.4
		if Input.is_action_just_released("sprint"):
			sprint_multiplier = 1

		# Rolling dodge move
		if Input.is_action_just_pressed("roll"):
			play_animation(roll)

		# Jump pressed and player is on the ground
		if Input.is_action_just_pressed("jump"):
			check_jump(jumps)
			if coyote_timer.is_stopped():
				jumps -= 1

		# Jump pressed and player is on the ground
		if Input.is_action_just_pressed("weapon"):
			pass

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
			# Reset jumps
			jumps = 1
			# Play animations
			if animation.current_animation not in interruptions:
				if velocity.x >= -1 and velocity.x <= 1:
					play_animation(idle)
				else:
					play_animation(run)
		# While in the air
		else:
			# Add the gravity.
			velocity.y += gravity * delta
			# Play animations	
			# play_animation(jump)

		# Move player
		if direction:
			velocity.x = direction * SPEED * boost * sprint_multiplier
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Flip direction of sprite
		if direction > 0:
			marker_2d.scale.x = 1
			# animated_sprite.flip_h = true
		elif direction < 0:
			marker_2d.scale.x = -1
			# animated_sprite.flip_h = false

		# Check if player is standing on something they can jump off	
		var was_on_floor = is_on_floor()

		move_and_slide()
		
		# After moving, the player is in the air
		if was_on_floor and not is_on_floor():
			# Wait time for player to jump
			coyote_timer.start()

	else:
		velocity = Vector2(0, 0)

func check_jump(jumps_remaining):
	if jumps_remaining > 0:
			velocity.y = JUMP_VELOCITY
			play_animation(jump)

# Player took damage and loses health
func on_player_damaged(amount):
	if not dying:
		play_animation(hurt)
		health -= amount
		if health <= 0:
			die()
		elif llama_mode:
			play_animation('transform')
			llama_mode = false

# Player is out of health
func die():
	# Start death sequence
	dying = true
	# Stop any other animation
	animation.stop()
	# Play death animation
	play_animation("death")
	
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
	play_animation('transform')

func play_animation(animation_name):
	animation.play(animation_name)

	if current_weapon != null:
		$Marker2D/Weapon.texture = current_weapon.texture
		weapon.play(current_weapon.animation)
