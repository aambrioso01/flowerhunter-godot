extends Panel

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("inventory"):
		open_mode()
	
func open_mode():
	visible = !visible
