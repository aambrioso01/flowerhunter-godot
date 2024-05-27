extends CanvasLayer

@onready var camera = $"../Camera2D"

func _process(delta):
	if camera:
		offset = camera.global_position
