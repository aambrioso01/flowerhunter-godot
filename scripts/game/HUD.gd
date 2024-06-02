extends CanvasLayer

@onready var gem_count = $GemCount
@onready var berry_bar = $BerryBar

@onready var icon = $Life/Icon
@onready var icon_1 = $Life/Icon1
@onready var icon_2 = $Life/Icon2

func _ready():
	# Set gem counter to number in save file
	gem_count.text = str(SaveManager.gems)
	# Listen for gem collection event
	Signals.gem_collected.connect(self._on_gem_collected)

	# Set berry bar to value in save file
	berry_bar.init_health(SaveManager.berries)
	# Listen for gem collection event
	Signals.berry_collected.connect(self._on_berry_collected)

	# Listen for death event
	Signals.lost_life.connect(self._on_lost_life)
	
	match SaveManager.lives:
		3:
			icon.visible = true
			icon_1.visible = true
			icon_2.visible = true
		2:
			icon.visible = true
			icon_1.visible = true
			icon_2.visible = false
		1:
			icon.visible = true
			icon_1.visible = false
			icon_2.visible = false
		_:
			icon.visible = false
			icon_1.visible = false
			icon_2.visible = false
			
func _on_lost_life():
	# Update life count
	SaveManager.lives -= 1
	# Reset berry bar
	SaveManager.berries = 0

func _on_gem_collected():
	SaveManager.gems += 1
	gem_count.text = str(SaveManager.gems)

func _on_berry_collected():
	SaveManager.berries += 1
	berry_bar.health = SaveManager.berries
