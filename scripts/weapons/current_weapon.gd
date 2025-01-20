extends GridContainer

func equip(weapon):
	get_tree().current_scene.find_child("Player").current_weapon = weapon
