extends Node

var game_over_scene:PackedScene = preload("res://scenes/levels/transitions/game_over.tscn")

func game_over():
	# Display game over screen
	get_tree().change_scene_to_packed(game_over_scene)
