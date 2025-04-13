class_name ImageDatabase
extends Control

signal image_selected(uid: String, texture: Texture2D, metadata: Dictionary)

@export var image_folder: String = "res://assets/images/"
@export var thumbnail_size: Vector2 = Vector2(128, 128)
@export var supported_formats: PackedStringArray = [".png", ".jpg", ".webp"]
@export var metadata_file: String = "image_metadata.cfg"

@onready var search_input: TextEdit = %SearchInput
@onready var results_container : FlowContainer = %ResultsContainer
@onready var loading_overlay: Control = %LoadingOverlay
@onready var preview_popup: PreviewPopup = %PreviewPopup
@onready var preview_texture: TextureRect = %PreviewTexture

var image_cache: Dictionary = {}  
# Structure:
# {
#   uid: {
#     path: String,
#     texture: Texture2D,
#     thumbnail: Texture2D,
#     metadata: Dictionary
#   }
# }

var tag_filters: Array[String] = []
var current_search: String = ""

func _ready() -> void:
	loading_overlay.show()
	index_images()
	load_metadata()
	loading_overlay.hide()

	setup_ui()
	connect_signals()

func connect_signals() -> void:
	search_input.text_changed.connect(_on_search_changed)
	search_input.gui_input.connect(_on_search_input)
	preview_popup.closed.connect(_on_preview_closed)

# region: Metadata Management
func load_metadata() -> void:
	var config = ConfigFile.new()
	if config.load(metadata_file) != OK:
		push_error("Metadata file not found at: %s" % metadata_file)
		return

	# First ensure all sections exist in image_cache
	for section in config.get_sections():
		if not section in image_cache:
			push_warning("Metadata found for unknown image: %s, skipping" % section)
			continue
		
		# Update the metadata without overwriting other data
		image_cache[section].metadata["tags"] = config.get_value(section, "tags", [])
		image_cache[section].metadata["description"] = config.get_value(section, "description", "")

# Pre-index images, only handles .png and .jpg atm
func index_images() -> void:
	var dir = DirAccess.open(image_folder)
	if not dir:
		push_error("Failed to open image directory: " + image_folder)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if _is_image_file(file_name):
			_process_image_file(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

func _is_image_file(file_name: String) -> bool:
	for format in supported_formats:
		if file_name.ends_with(format):
			return true
	return false

func _process_image_file(file_name: String) -> void:
	var uid = file_name.get_basename().to_lower()
	var path = image_folder.path_join(file_name)

	var texture = load(path)
	if not texture or not texture is Texture2D:
		push_warning("Failed to load texture: " + path)
		return
	
	var image = texture.get_image()
	if not image:
		push_warning("Failed to get image data from texture: " + path)
		return
	
	image.resize(thumbnail_size.x, thumbnail_size.y)
	var thumbnail: Texture2D = ImageTexture.create_from_image(image)
	
	image_cache[uid] = {
		"path": path,
		"texture": texture,
		"thumbnail": thumbnail,
		"metadata": {
			"tags": [],
			"description": "",
		}
	}

func setup_ui() -> void:
	_clear_results()
	_populate_results()

func _clear_results() -> void:
	for child in results_container.get_children():
		child.queue_free()

func _populate_results() -> void:
	_clear_results()

	for uid in image_cache:
		if _matches_filters(uid):
			var card: ImageCard = preload("res://scenes/image_card.tscn").instantiate()
			results_container.add_child(card)

			card.setup(uid, image_cache[uid])
			card.card_pressed.connect(_on_image_card_selected)
			card.start_drag.connect(_on_image_drag_start)

func _matches_filters(uid: String) -> bool:
	var search_match = uid.contains(current_search) || \
					  image_cache[uid].metadata["description"].to_lower().contains(current_search)
	
	var tag_match = tag_filters.is_empty() || \
				   tag_filters.any(func(tag): return tag in image_cache[uid].metadata["tags"])
	
	return search_match && tag_match

func _on_search_changed() -> void:
	current_search = search_input.text.to_lower()
	_populate_results()

func _on_search_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		accept_event()

func _on_image_card_selected(uid: String) -> void:
	var texture = _load_texture(uid)
	var metadata = image_cache[uid].metadata
	if texture:
		preview_popup.setup(str(uid), metadata["description"])
		preview_texture.texture = texture
		preview_popup.show()

func _on_image_drag_start(uid: String, card_texture: Texture2D) -> void:
	var drag_data = {
		"uid": uid,
		"texture": card_texture,
		"metadata": image_cache[uid].metadata
	}
	var drag_preview = TextureRect.new()
	drag_preview.texture = card_texture
	set_drag_preview(drag_preview)
	
	image_selected.emit(str(uid), drag_data.texture, drag_data.metadata)

func _on_preview_closed() -> void:
	preview_popup.hide()

func _load_texture(uid: String) -> Texture2D:
	return image_cache[uid].texture

func _on_database_close_pressed() -> void:
	hide()
