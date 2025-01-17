extends GridContainer

@onready var slots = get_children()
@onready var player = %Player

func _ready():
	for weapon in player.weapon_list:
		add_weapon(load(weapon))

func add_weapon(weapon: Weapon):
	for slot in slots:
		if slot.weapon == null:
			slot.weapon = weapon
			return
	print("Weapon slot full")
	
func remove_weapon(weapon: Weapon):
	for slot in slots:
		if slot.weapon == weapon:
			slot.weapon = null
			return
	print("Weapon not found")
