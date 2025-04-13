class_name ImageCard
extends Button

signal card_pressed(uid: String)
signal start_drag(uid: String, texture: Texture2D)

@onready var thumbnail: TextureRect = %Thumbnail
@onready var tags_container: HBoxContainer = %TagsContainer

var uid: String
var metadata: Dictionary
# {
#   uid: {
#     path: String,
#     texture: Texture2D,
#     thumbnail: Texture2D,
#     metadata: Dictionary
#   }
# }

func setup(new_uid: String, data: Dictionary) -> void:
	uid = new_uid
	metadata = data["metadata"] 
	
	if data.has("thumbnail") and data["thumbnail"] != null:
		thumbnail.set_texture(data["thumbnail"])
	else:
		push_warning("No thumbnail???.")

	_populate_tags()

func _populate_tags() -> void:
	for child in tags_container.get_children():
		child.queue_free()

	for tag in metadata.tags:
		var label = Label.new()
		label.text = "#" + tag
		tags_container.add_child(label)

func _get_drag_data(_position: Vector2) -> Variant:
	var preview = TextureRect.new()
	preview.texture = thumbnail.texture
	start_drag.emit(uid, thumbnail.texture)
	return {"type": "image_card", "uid": uid}

func _pressed() -> void:
	emit_signal("card_pressed", uid)

#func _make_custom_tooltip(_for_text: String) -> Object:
	#var tooltip = preload("res://ui/image_tooltip.tscn").instantiate()
	#tooltip.set_metadata(metadata)
	#return tooltip
