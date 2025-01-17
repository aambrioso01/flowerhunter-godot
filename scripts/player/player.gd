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
@export var knockback_power = 5 

# Health and status
var health = 100
var is_dying
var llama_mode
var next_weapon_index
var weapon_list = [
	"res://resources/pink_sword.tres",
	"res://resources/main_bow.tres",
	"res://resources/staff.tres",
	"res://resources/gun.tres"
]

# Animations
var idle
var run
var jump
var hurt
var roll
var basic_attack
var super_attack
var interruptions
var prefix = "llama/"

# References to other nodes
@onready var marker_2d = $Marker2D
@onready var animation = $AnimationPlayer
@onready var weapon = $Marker2D/Weapon/WeaponFX
@onready var projectile_spawn = $Marker2D/Weapon/ProjectileSpawn

@onready var coyote_timer = $CoyoteTimer
@onready var death_timer = $DeathTimer

# Weapon resources
@export var current_weapon: Weapon:
	set(value):
		current_weapon = value

@export var projectile_node : PackedScene

func _ready():
	# Set flags
	is_dying = false
	llama_mode = false

	# Listen for relevant signals
	Signals.player_damaged.connect(on_player_damaged)
	Signals.cake_collected.connect(self.on_cake_collected)

	# Load default weapon
	current_weapon = load(weapon_list[0])
	# Update weapon sprites
	$Marker2D/Weapon/WeaponGFX.texture = current_weapon.texture
	# Set next weapon
	next_weapon_index = 1

func _physics_process(delta):
	if not is_dying and animation.current_animation != 'transform':
		if llama_mode:
			idle = 'llama/idle'
			run = 'llama/run'
			jump = 'llama/jump'
			hurt = 'llama/hurt'
			roll = 'llama/roll'
			basic_attack = 'llama/basic_attack'
			super_attack = 'super'
		else:
			idle = 'idle'
			run = 'idle'
			jump = 'jump'
			hurt = 'hurt'
			roll = 'roll'
			basic_attack = 'basic_attack'
			super_attack = 'super'

		interruptions = [hurt, roll, basic_attack, super_attack]
		# By default play idle
		if not animation.is_playing():
			play_animation_with_weapon(idle)

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

		### COMBAT ###
		# Player attack
		if Input.is_action_just_pressed("basic_attack"):
			play_animation_with_weapon(basic_attack)

		if Input.is_action_just_pressed("super"):
			play_animation_with_weapon(super_attack)

		if Input.is_action_just_released("super"):
			play_animation_with_weapon(idle)


		# Switch weapon
		if Input.is_action_just_pressed("switch_weapon"):
			# Load next weapon from inventory
			current_weapon = load(weapon_list[next_weapon_index])

			# Update weapon sprites
			$Marker2D/Weapon/WeaponGFX.texture = current_weapon.texture

			# Start playing idle weapon animation

			weapon.play(current_weapon.animation + 'idle')

			# If at the end of the inventory, next weapon is the first item in the inventory
			if next_weapon_index < (weapon_list.size() - 1):
				next_weapon_index += 1
			elif next_weapon_index == (weapon_list.size() - 1):
				next_weapon_index = 0


		### MOVEMENT ###
		# Player is starting to sprint
		if Input.is_action_just_pressed("sprint"):
			# Increase speed
			sprint_multiplier = 1.4
		if Input.is_action_just_released("sprint"):
			sprint_multiplier = 1

		# Rolling dodge move
		if Input.is_action_just_pressed("roll"):
			animation.play(roll)

		# Jump pressed and player is on the ground
		if Input.is_action_just_pressed("jump"):
			check_jump(jumps)
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

		# Idle if doing nothing else
		if !animation.is_playing():
			play_animation_with_weapon(idle)

		# After landing on the ground
		if is_on_floor():
			# Reset jumps
			jumps = 1
			# Play animations
			if not animation.current_animation in interruptions:
				if velocity.x >= -1 and velocity.x <= 1:
					animation.play(run)
		# While in the air
		else:
			# Add the gravity.
			velocity.y += gravity * delta

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
			animation.play(jump)

# Player took damage and loses health
func on_player_damaged(amount):
	if not is_dying:
		knockback()
		animation.play(hurt)
		health -= amount
		if health <= 0:
			die()
		elif llama_mode:
			animation.play('transform')
			llama_mode = false

# Player is out of health
func die():
	# Start 	 sequence
	is_dying = true
	# Stop any other animation
	animation.stop()
	# Play death animation
	animation.play("death")
	
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
	animation.play('transform')

func play_animation_with_weapon(animation_name):
	animation.play(animation_name)

	if current_weapon != null:
		if llama_mode and prefix in animation_name:
			animation_name = animation_name.erase(0, prefix.length())
		weapon.play(current_weapon.animation + animation_name)

func shoot_projectile():
	var projectile = projectile_node.instantiate()
	projectile.position = projectile_spawn.global_position
	projectile.set_direction($Marker2D.scale.x, current_weapon.projectile)
	projectile.damage = current_weapon.damage
	get_tree().current_scene.add_child(projectile)

func knockback():
	print("knockback")
	var knock_direction = -velocity.normalized() * knockback_power
	velocity = knock_direction
	move_and_slide()
	print_debug(velocity)
