extends ProgressBar

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

var health = 0 : set = _set_health

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health > prev_health:
		timer.start()
	else:
		progress_bar.value = health

func init_health(_health):
	health = _health
	max_value = SaveManager.full_berries
	value = health
	progress_bar.max_value = health
	progress_bar.value = health

func _on_timer_timeout():
	progress_bar.value = health
