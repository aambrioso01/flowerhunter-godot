extends GridContainer

@onready var slots = get_children()

func _ready():
	add_weapon(load("res://resources/pink_sword.tres"))
	add_weapon(load("res://resources/main_bow.tres"))
	add_weapon(load("res://resources/staff.tres"))
	add_weapon(load("res://resources/gun.tres"))

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
