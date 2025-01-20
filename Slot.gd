extends PanelContainer
class_name Slot

var custom_size = Vector2(150,150)

@onready var texture_rect = $TextureRect

@export var weapon: Weapon = null:
	set(value):
		weapon = value
		
		if get_parent().name == "CurrentWeapon":
			print("equip:", weapon)
			get_parent().equip(weapon)
		
		if value != null:
			texture_rect.texture = value.icon
		else:
			texture_rect.texture = null
			
func get_preview():
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture_rect.texture
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.custom_minimum_size = custom_size
	
	var preview = Control.new()
	preview.add_child(preview_texture)
	preview_texture.position = -0.5 * custom_size
	
	return preview

# func gui_input(event):
# 	print("btn index", event.button_index)
# 	if event is InputEventMouseButton and event.pressed:
# 		_on_slot_clicked()

# func _on_slot_clicked():
# 	print("slot clicked", self)
# 	var temp = weapon
# 	weapon = self.weapon
# 	self.weapon = temp

# # Optional: if you need a function to set the weapon for this slot
# func set_weapon(new_weapon):
# 	weapon = new_weapon
	
func _get_drag_data(_at_position):
	set_drag_preview(get_preview())
	return self
	
func _can_drop_data(_pos, data):
	return data is Slot
	
func _drop_data(_at_position, data):
	print(data)
	var temp = weapon
	weapon = data.weapon
	data.weapon = temp
	
