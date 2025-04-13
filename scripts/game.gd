extends Node

@onready var board: DetectiveBoard = $Board
@onready var database: ImageDatabase = $Database
@onready var menu_button: MenuButton = $MenuButton

func _ready() -> void:
	var popup = menu_button.get_popup()
	popup.id_pressed.connect(_on_menu_item_selected)

func _on_menu_item_selected(id: int):
	match id:
		0:
			database.show()
		_:
			print("Not implemented")

func _on_database_image_selected(uid: String, texture: Texture2D, metadata: Dictionary) -> void:
	var position = board.get_local_mouse_position()
	board.add_note_from_database(uid, texture, metadata, position)
