extends Panel
class_name PreviewPopup

signal closed

@onready var desc: Label = %Description
@onready var titleLabel: Label = $VBoxContainer/HBoxContainer/Panel/TitleLabel

func _on_close_button_pressed() -> void:
	closed.emit()

func setup(title: String, description: String) -> void:
	titleLabel.text = title
	desc.text = description
