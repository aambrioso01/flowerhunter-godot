extends Area2D

@onready var animation_player = $AnimationPlayer

func _on_body_entered(_body):
	animation_player.play("pickup")
	Signals.cake_collected.emit()
