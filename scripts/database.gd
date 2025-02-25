extends Control

@onready var results : FlowContainer = $VBoxContainer/MarginContainer/BodyContainer/ContentMargin/Content/Results
@onready var search_text: TextEdit = $VBoxContainer/MarginContainer/BodyContainer/SearchContainer/SeatchText
@onready var preview: Panel = $ImagePreview
@onready var pic_scene: PackedScene = preload("res://scenes/picture.tscn")

func _on_search_pressed() -> void:
	var picture : PictureButton = pic_scene.instantiate()
	picture.preview = preview
	search_text.clear()
	results.add_child(picture)

func _on_database_close_pressed() -> void:
	hide()

func _on_image_close_pressed() -> void:
	preview.hide()
