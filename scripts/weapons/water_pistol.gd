extends Node2D

@onready var attack_timer = $AttackTimer
@onready var sword_sprite = $AnimatedSprite2D
@onready var muzzle = $Muzzle

var basic_attack = "basic_attack"

@export var Bullet : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	# Listen for gem collection event
	Signals.basic_attack.connect(self._on_basic_attack)

func _on_basic_attack():
	if attack_timer.is_stopped():
		sword_sprite.play(basic_attack)
		attack_timer.start()

		# Add the projectile node as a child of the pistol
		shoot()

func shoot():
	var b = Bullet.instantiate()
	owner.owner.add_child(b)
	b.transform = $Muzzle.global_transform
