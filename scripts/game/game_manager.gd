extends Node
@onready var coin_count = $HUD/CoinCount
@onready var icon_1 = $HUD/Life/Icon1
@onready var icon_2 = $HUD/Life/Icon2
@onready var icon_3 = $HUD/Life/Icon3

var lives = 3

func remove_life():
	get_node("HUD/Life/Icon" + str(lives)).hide()
	lives -= 1
