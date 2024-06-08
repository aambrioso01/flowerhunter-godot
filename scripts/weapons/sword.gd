extends Node2D

@onready var attack_timer = $AttackTimer
@onready var sword_sprite = $AnimatedSprite2D

var basic_attack = "basic_attack"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Listen for gem collection event
	Signals.basic_attack.connect(self._on_basic_attack)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_basic_attack():
	if attack_timer.is_stopped():
		sword_sprite.play(basic_attack)
		attack_timer.start()
