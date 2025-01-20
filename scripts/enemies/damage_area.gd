extends Area2D

var damage_power = 1
var enemy_velocity 
@onready var player = get_tree().current_scene.find_child("Player")
@onready var damage_impact = player.get_node("DamageImpact")
@onready var animation_player = player.get_node("ImpactPlayer")

# Player touched enemy hitbox
func _on_body_entered(body):
	# Identify player
	if body.is_in_group("player"):
		# Get enemy velocity
		enemy_velocity = get_parent().velocity
		# Apply damage and knockback to player
		Signals.player_damaged.emit(damage_power, enemy_velocity)

		# damage_impact.position.x = get_parent().position.x - position.x
		damage_impact.position.x = get_parent().global_position.distance_to(player.global_position)
		# damage_impact.position.x = (player.position - get_parent().position).normalized().x

		animation_player.play("impact")
		
