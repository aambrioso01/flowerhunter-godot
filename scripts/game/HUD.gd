extends CanvasLayer

@onready var gem_count = $GemCount

func _ready():
	gem_count.text = str(SaveManager.gems)
	Signals.gem_collected.connect(self._on_gem_collected)

func _on_gem_collected():
	SaveManager.gems += 1
	gem_count.text = str(SaveManager.gems)
