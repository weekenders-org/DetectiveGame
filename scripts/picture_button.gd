class_name PictureButton extends TextureButton

@export var preview: Panel = null

func setup(previewPanel: Panel, texture: Texture2D):
	preview = previewPanel
	texture_normal = texture

func _on_pressed() -> void:
	var stylebox = preview.get_theme_stylebox("panel")
	stylebox.texture = texture_normal
	preview.add_theme_stylebox_override("panel", stylebox)
	preview.show()
