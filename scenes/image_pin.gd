extends Panel

@onready var pin : TextureRect = $Pin
@onready var image: TextureRect = $MarginContainer/Image

var dragging: bool = false
var drag_offset: Vector2

func _ready() -> void:
	pass 

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not dragging:
				pin.visible = false
			dragging = true
			drag_offset = get_global_mouse_position() - global_position
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if dragging:
				pin.visible = true
			dragging = false

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - drag_offset
