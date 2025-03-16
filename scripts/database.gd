extends Control

@export var folder_path: String = "res://images/"
@export var debug_img_paths: PackedStringArray = []

@onready var results : FlowContainer = $VBoxContainer/MarginContainer/BodyContainer/ContentMargin/Content/Results
@onready var search_text: TextEdit = $VBoxContainer/MarginContainer/BodyContainer/SearchContainer/SeatchText
@onready var preview: Panel = $ImagePreview
@onready var not_found: Label = $NotFoundLabel
@onready var pic_scene: PackedScene = preload("res://scenes/picture.tscn")

var image_paths = {}

var debug: bool = OS.is_debug_build()

func _ready() -> void:
	if folder_path.is_empty():
		push_error("Folder path is empty")
		return
	index_images()

func _input(event: InputEvent) -> void:
	if debug and (event.is_action_pressed("debug_board_show")):
		show()

# Pre-index images, only handles .png and .jpg atm
func index_images() -> void:
	image_paths.clear()
	debug_img_paths.clear()
	
	var dir :  DirAccess = DirAccess.open(folder_path)
	if dir == null:
		push_error("Failed to open directory: " + folder_path)
		return
	
	if dir.list_dir_begin() != OK:
		push_error("Failed to list directory: " + folder_path)
		return
	
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".png") or file_name.ends_with(".jpg"):
			var name_no_ext = file_name.get_basename().to_lower()
			image_paths[name_no_ext] = folder_path + file_name
			if (debug):
				debug_img_paths.append(name_no_ext + " -> " + file_name)
		file_name = dir.get_next()
	print_debug(debug_img_paths)

func search_image(search_name: String) -> String:
	return image_paths.get(search_name.to_lower(), "")

func load_texture(image_name: String) -> Texture2D:
	var file_path = search_image(image_name)
	if file_path == "":
		return null
	
	var tex = load(file_path)
	if tex is Texture2D:
		return tex
	
	print_debug(image_name + "not found.")
	return null

func clear_search() -> void:
	search_text.clear()
	not_found.hide()
	for child in results.get_children():
		results.remove_child(child)
		child.queue_free()

func _on_search_pressed() -> void:
	var search_str = search_text.text
	var texture = load_texture(search_str)
	clear_search()

	if (texture != null):
		var picture : PictureButton = pic_scene.instantiate()
		picture.setup(preview, texture)
		results.add_child(picture)
	else:
		not_found.text = search_str + " not found."
		not_found.show()

func _on_database_close_pressed() -> void:
	hide()

func _on_image_close_pressed() -> void:
	preview.hide()
	clear_search()
