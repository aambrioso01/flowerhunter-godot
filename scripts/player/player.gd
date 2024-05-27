extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -330.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var DOUBLEJUMP = 1
var jumps = DOUBLEJUMP
var fallMultiplier = -3
var lowJumpMultiplier = -40
var sprintMultiplier = 1

var idle_anim = "new_idle"
var jump_anim = "new_jump"

@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_puff = $AnimatedSprite2D/AnimatedPuff
@onready var coyote_timer = $CoyoteTimer

#@onready var joystick = $"../TouchPad/Joystick"
#@onready var touch_screen_button = $"../TouchPad/TouchScreenButton"

# Parameters for the dynamic scaling of joystick movment
#var a: float = 0.6
#var t: float = 0.0
#var max_scale: float = 1 # Maximum scale factor

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Player is starting to sprint
	if Input.is_action_just_pressed("sprint"):
		# Increase speed
		sprintMultiplier = 1.4
	if Input.is_action_just_released("sprint"):
		sprintMultiplier = 1
	# Player is falling
	if velocity.y > 0: 
		# Falling is faster than jumping
		velocity += Vector2.UP * (fallMultiplier)
	# Player just jumped
	elif velocity.y < 0 and Input.is_action_just_released("jump"):
	# Jump Height depends on how long button is held
		velocity += Vector2.UP * (lowJumpMultiplier)

	# Jump pressed and player is on the ground
	if Input.is_action_just_pressed("jump"):
		jump(jumps)
		if coyote_timer.is_stopped():
			jumps -= 1

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")

	#var scale = 1
	## Get left/right info from joystick and set direction
	#if joystick.is_pressed():
		#direction = joystick.get_joystick_direction().x
		#t += delta  # Increase time by the delta time
		#scale = min(exp(a * t), max_scale)  # Calculate the exponential scale factor
	#else:
		#joystick.re_center()
		#scale = 1
		#t = 0

	# Flip direction of sprite
	if direction > 0:
		animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false

	# After landing on the ground
	if is_on_floor():		
		# Play animations
		animated_sprite.play(idle_anim)
		# Reset jumps
		jumps = DOUBLEJUMP
	# While in the air
	else:
		# Play animationss		
		animated_sprite.play(jump_anim)

	# Move player
	if direction:
		velocity.x = direction * SPEED * sprintMultiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Check if player is standing on something they can jump off	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	# After moving, the player is in the air
	if was_on_floor and !is_on_floor():
		# Wait time for player to jump
		coyote_timer.start()
	
	## Jump once when button state switches from not pressed to pressed
	#if touch_screen_button.is_pressed():
		#jump(jumps)
		#if coyote_timer.is_stopped():
			#jumps -= 1

func jump(jumps):
	if jumps > 0:
			velocity.y = JUMP_VELOCITY
			animated_puff.play("jump")
	else:
		print("cant jump")
