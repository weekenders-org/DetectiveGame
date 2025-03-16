extends Panel

@export var pins : Array[Panel] = []

func _ready() -> void:
	pins.clear()
	for child in get_children(false):
		if child is Panel:
			pins.append(child)

	print_debug(pins)
