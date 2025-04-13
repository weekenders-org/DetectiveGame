@tool
extends EditorScript

func _run() -> void:
	var image_folder = "res://assets/images/"  # Must match your actual folder
	var metadata_file = "res://image_metadata.cfg"  # Where to save metadata
	
	# Scan images and generate config
	var config = ConfigFile.new()
	var dir = DirAccess.open(image_folder)
	
	if not dir:
		push_error("Failed to open directory: " + image_folder)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.get_extension() in ["png", "jpg", "webp"]:
			var uid = file_name.get_basename().to_lower()
			config.set_value(uid, "tags", [uid])  # Default tags
			config.set_value(uid, "description", "")
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	# Save the file
	if config.save(metadata_file) == OK:
		print("Metadata generated at: ", metadata_file)
	else:
		push_error("Failed to save metadata file")
