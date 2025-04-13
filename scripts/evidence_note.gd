class_name EvidenceNote
extends Panel

signal note_moved(note: EvidenceNote)
signal connection_started(from_note: EvidenceNote, from_position: Vector2)
signal connection_completed(from_note: EvidenceNote)

@onready var pin: TextureButton = $Pin
@onready var content: TextureRect = $MarginContainer/Content

var uid: String
var dragging := false
var drag_offset: Vector2
var connecting := false

func setup(new_uid: String, texture: Texture2D, _metadata: Dictionary) -> void:
	uid = new_uid
	content.texture = texture

	pin.button_down.connect(_on_pin_pressed)
	pin.button_up.connect(_on_pin_button_up)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not connecting:
			start_dragging(event)
		elif not event.pressed and dragging:
			stop_dragging()

func _on_pin_pressed() -> void:
	print("start connection")
	start_connection()

func _on_pin_button_up() -> void:
	print("end connection")
	if connecting:
		complete_connection()

func start_dragging(event: InputEventMouseButton) -> void:
	dragging = true
	drag_offset = event.position
	pin.visible = false
	z_index = 1

func stop_dragging() -> void:
	dragging = false
	pin.visible = true
	z_index = 0
	note_moved.emit(self)

func start_connection() -> void:
	connecting = true
	dragging = false
	connection_started.emit(self, pin.global_position + pin.size/2)

func complete_connection() -> void:
	connecting = false
	connection_completed.emit(self)

func get_pin_position() -> Vector2:
	return pin.global_position + pin.size/2

func _process(_delta: float) -> void:
	if dragging:
		position = get_global_mouse_position() - drag_offset
