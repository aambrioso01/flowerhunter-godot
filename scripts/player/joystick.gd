extends TouchScreenButton

@onready var knob = $Knob
@onready var max_distance = shape.radius

var center: Vector2 = texture_normal.get_size() / 2
var touched: bool = false

func _ready():
	set_process(false)
#
## Detect if joystick is in use
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			set_process(true)

func _process(delta):
	knob.global_position = get_global_mouse_position()
	# Limit the movement of the knob to the size of the joystick
	knob.position = center + (knob.position - center).limit_length(max_distance)

# Create vector for movement from stick position	
func get_joystick_direction() -> Vector2:
	var direction = knob.position - center
	return direction.normalized()

# If not touched, stick snaps back to center
func re_center():
	set_process(false)
	knob.position = center
